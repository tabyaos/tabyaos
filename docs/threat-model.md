# TabyaOS Threat Model

TabyaOS is scoped to **worker node OS-level threats**. Application-level threats, network segmentation, and HSM integration are out of scope and belong in cluster design / workload configuration.

## Trust Boundaries

```
┌──────────────────────────────────────────────────────┐
│  AWS Account boundary                                 │
│  ┌────────────────────────────────────────────────┐  │
│  │  VPC / EKS Cluster                             │  │
│  │  ┌──────────────────────────────────────────┐  │  │
│  │  │  Worker Node (TabyaOS boundary)          │  │  │
│  │  │                                          │  │  │
│  │  │  OS kernel   ← FIPS mode                 │  │  │
│  │  │  kubelet     ← CIS K8s hardened           │  │  │
│  │  │  containerd  ← SystemdCgroup, seccomp     │  │  │
│  │  │  audit daemon← PCI/SOC2 rules             │  │  │
│  │  │  filesystem  ← AIDE, read-only /boot      │  │  │
│  │  │  network     ← iptables, no SSH           │  │  │
│  │  └──────────────────────────────────────────┘  │  │
│  │                                                  │  │
│  │  Control Plane ← AWS managed (out of scope)      │  │
│  └────────────────────────────────────────────────┘  │
│                                                       │
│  AWS SSM ← Only allowed remote access path           │
└──────────────────────────────────────────────────────┘
```

## Threat Actors

| Actor | Capability | Mitigation |
|-------|-----------|------------|
| External attacker | Network access, internet | No SSH (iptables DROP port 22), SSM-only access |
| Compromised container | Pod escape attempt | seccomp profile, AppArmor, read-only /proc mounts |
| Malicious insider | SSH key, console access | No SSH keys on node; SSM session logged to CloudTrail |
| Supply chain attacker | Tampered package / image | Cosign signature verification; SBOM; AIDE monitors /usr/bin |
| Privilege escalation | Kernel exploit, SUID | ASLR, kptr_restrict=2, dmesg_restrict=1; SUID audited |

## Mitigated Attack Surfaces

### 1. Remote Access
- **Threat**: Brute-force or key theft enabling SSH login
- **Control**: `ssm-only-access` — sshd disabled + iptables DROP port 22
- **Evidence**: `CIS AL2023 5.2`, `PCI-DSS v4.0 Req 8.2.1`

### 2. Kernel Exploitation
- **Threat**: Local privilege escalation via kernel memory disclosure
- **Controls**: ASLR (`kernel.randomize_va_space=2`), `kernel.kptr_restrict=2`, `kernel.dmesg_restrict=1`
- **Evidence**: `CIS AL2023 1.5.2`, `PCI-DSS v4.0 Req 2.2.5`

### 3. USB / Removable Media
- **Threat**: Data exfiltration via USB
- **Control**: `usb-storage` module blacklisted in `/etc/modprobe.d/`
- **Evidence**: `CIS AL2023 1.1.1.4`

### 4. Wireless Attack Surface
- **Threat**: Rogue WiFi access point or Bluetooth MITM
- **Control**: `bluetooth` module blacklisted + `nmcli radio wifi off`
- **Evidence**: `PCI-DSS v4.0 Req 2.2.4`

### 5. Cryptographic Downgrade
- **Threat**: Weak cipher negotiation (SWEET32, POODLE, FREAK)
- **Controls**: FIPS crypto policy; TLS 1.2 minimum on kubelet; strong cipher suites
- **Evidence**: `PCI-DSS v4.0 Req 4.2.1`, `CIS K8s 4.2.12`

### 6. Tampered Binaries
- **Threat**: Attacker modifies system binaries post-compromise
- **Control**: AIDE monitors `/usr/bin`, `/usr/sbin`, `/etc`, `/boot` with SHA-512
- **Evidence**: `CIS AL2023 1.3.1`, `PCI-DSS v4.0 Req 11.3.1`

### 7. Log Tampering
- **Threat**: Attacker deletes audit logs to cover tracks
- **Controls**: `write_logs=yes`, `/var/log/audit` mode 0700, `max_log_file_action` configured
- **Evidence**: `PCI-DSS v4.0 Req 10.3.2`, `SOC 2 CC7.2`

### 8. Credential Exposure
- **Threat**: Kernel pointers or dmesg output exposing ASLR base addresses
- **Controls**: `kernel.kptr_restrict=2`, `kernel.dmesg_restrict=1`
- **Evidence**: `PCI-DSS v4.0 Req 2.2.5`

### 9. Time Manipulation
- **Threat**: NTP manipulation to invalidate log timestamps for forensics
- **Control**: Chrony configured with Amazon Time Sync Service + AWS NTP pool; `cmdport 0`
- **Evidence**: `PCI-DSS v4.0 Req 10.6.1`

### 10. Kubernetes API Abuse
- **Threat**: Unauthenticated kubelet access (anonymous auth, read-only port)
- **Controls**: `--anonymous-auth=false`, `--read-only-port=0`, Webhook authorization
- **Evidence**: `CIS K8s 4.2.1`, `CIS K8s 4.2.4`

## Out of Scope

These are valid threats but explicitly **not addressed at the node OS layer**:

| Threat | Where it belongs |
|--------|-----------------|
| Application secrets in env vars | Workload configuration (Vault, Sealed Secrets) |
| Container image vulnerabilities | Image scanning pipeline (Trivy, Snyk) |
| CDE network segmentation | VPC design, Network Policies, AWS Security Groups |
| HSM key management | Customer-managed HSM (CloudHSM, Thales) |
| K8s RBAC misconfiguration | Control plane hardening (separate scope) |
| etcd encryption at rest | Control plane (AWS managed for EKS) |

## Residual Risk

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Zero-day kernel exploit | Low | High | Defense-in-depth (ASLR, seccomp, cgroups); rapid patch SLA via LTS channel |
| FIPS module compromise | Very Low | Critical | AWS-validated crypto modules; quarterly CVE review |
| Supply chain (Packer/Ansible) | Low | High | Pinned versions, GitHub Actions OIDC, Cosign verification |
| SSM agent vulnerability | Low | High | SSM sessions logged to CloudTrail; agent auto-updated |
