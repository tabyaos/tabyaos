# PCI-DSS v4.0 — TabyaOS Node-Level Control Implementation

**Scope:** Worker node OS configuration only.
Out of scope: application-level controls, CDE network segmentation, HSM, tokenization.

---

## Requirement 1 — Install and maintain network security controls

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 1.3.1 | Restrict inbound traffic to only what is necessary | Unnecessary services removed; firewall via nftables | `cis-l2` (2_services) | ✅ |
| 1.3.2 | Restrict outbound traffic from the CDE | sysctl source routing disabled; network policies enforced by K8s CNI | `cis-l2` (3_network) | ✅ |

## Requirement 2 — Apply secure configurations to all system components

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 2.2.1 | System configuration standards | CIS AL2023 L2 applied as baseline | `cis-l2` | ✅ |
| 2.2.2 | Change vendor defaults | SSH default config replaced; auditd defaults overridden | `cis-l2` | ✅ |
| 2.2.3 | Wireless disabled | nmcli wifi off; bluetooth module blacklisted | `pci-dss-v4` | ✅ |
| 2.2.4 | Only necessary services enabled | All unnecessary services removed | `cis-l2` (2_services) | ✅ |
| 2.2.5 | Security-relevant kernel parameters | dmesg_restrict, kptr_restrict set | `pci-dss-v4` | ✅ |

## Requirement 5 — Protect all systems and networks from malicious software

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 5.2.1 | Anti-malware solution deployed | ClamAV (opt-in via `pci_dss_install_antimalware: true`) | `pci-dss-v4` | ⚠️ opt-in |
| 5.3.4 | Automatic updates for anti-malware | freshclam daily cron | `pci-dss-v4` | ⚠️ opt-in |

> **Note:** In an immutable AMI workflow, the anti-malware defence is provided by the hardened base image + AIDE (Req 11.3) + SELinux enforcing. ClamAV is available but most K8s operators rely on image scanning (Trivy, ECR scanning) instead.

## Requirement 6 — Develop and maintain secure systems and software

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 6.3.3 | Security patches applied | `dnf update --security` during Packer build | Packer provisioner | ✅ |
| 6.4.1 | Public-facing web services disabled | httpd, nginx disabled | `pci-dss-v4` | ✅ |
| 6.5.1 | Changes managed via change control | Immutable AMI — all changes through signed Packer build + CI | `soc2-cc6-cc7-cc8` | ✅ |

## Requirement 7 — Restrict access to system components and cardholder data

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 7.2.1 | Access control system implemented | sudo requires authentication; wheel group enforced | `pci-dss-v4` | ✅ |
| 7.2.2 | All privileged access logged | sudo log at /var/log/sudo.log | `pci-dss-v4` | ✅ |

## Requirement 8 — Identify users and authenticate access to system components

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 8.2.1 | Only known, approved users can access systems | SSH disabled; SSM Session Manager only | `ssm-only-access` | ✅ |
| 8.2.8 | Session idle timeout ≤ 15 min | TMOUT=900 set via /etc/profile.d | `pci-dss-v4` | ✅ |
| 8.3.4 | Account lockout after ≤ 10 failed attempts | faillock deny=10 | `pci-dss-v4` | ✅ |
| 8.3.6 | Password complexity requirements | pwquality minlen=14, minclass=4 | `cis-l2` (5_access) | ✅ |
| 8.4.2 | MFA required | MFA enforced at IdP/SSO level (out of node scope) | N/A — note in playbook | 📝 |

## Requirement 10 — Log and monitor all access to system components and cardholder data

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 10.2.1.1 | Audit all access to CHD | auditd rules with `pci_chd_access` tag | `auditd-pci` | ✅ |
| 10.2.1.2 | Audit administrative actions | sudoers, passwd, group watched by auditd | `auditd-pci` | ✅ |
| 10.2.1.3 | Audit access to audit trails | /var/log/audit watched | `auditd-pci` | ✅ |
| 10.2.1.4 | Audit authentication mechanism changes | /etc/pam.d, /etc/security, sshd_config watched | `auditd-pci` | ✅ |
| 10.2.1.5 | Audit privileged command use | execve with euid=0 and auid>=1000 | `auditd-pci` | ✅ |
| 10.2.1.6 | Audit audit log init/stop/pause | auditd binary and init script watched | `auditd-pci` | ✅ |
| 10.2.1.7 | Audit system object creation/deletion | mknod, unlink, rename syscalls | `auditd-pci` | ✅ |
| 10.3.2 | Audit log files protected from modification | /var/log/audit mode 0700; audit.log mode 0600 | `auditd-pci` | ✅ |
| 10.5.1 | Audit logs cannot be deleted | write_logs=yes; admin_space_left_action=halt | `cis-l2` (4_logging) | ✅ |
| 10.6.1 | Time synchronisation configured | chronyd with Amazon Time Sync Service | `chrony-hardened` | ✅ |
| 10.7.1 | Audit log retention ≥ 12 months | logrotate rotate=52 (weeks) | `cis-l2` (4_logging) | ✅ |

## Requirement 11 — Test security of systems and networks regularly

| Req | Control | Implementation | Ansible Role | Status |
|-----|---------|---------------|--------------|--------|
| 11.3.1 | File integrity monitoring deployed | AIDE with daily cron check | `aide` | ✅ |
| 11.3.2 | FIM alerts on unauthorized change | AIDE output logged to syslog | `aide` | ✅ |
| 11.4.1 | Penetration testing methodology | kube-bench + inspec run in CI | `tests/kube-bench/` | ✅ |

---

## Verification

Run the compliance check playbook after hardening:

```bash
# Run kube-bench
./tests/kube-bench/run-node.sh --json --output tests/kube-bench/baseline/after-pci-hardening.json

# Compare against baseline
./tests/kube-bench/compare-baseline.sh \
  tests/kube-bench/baseline/before-hardening.json \
  tests/kube-bench/baseline/after-pci-hardening.json
```

Each control in this document maps to a machine-readable entry in [control-mappings.yaml](control-mappings.yaml).
