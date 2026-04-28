# TabyaOS Architecture

TabyaOS produces **hardened, immutable operating system images** for Kubernetes worker nodes. Every image is reproducible, Cosign-signed, and ships an SBOM — giving compliance teams a cryptographically verifiable artefact for audit purposes.

## Build Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  GitHub Actions CI                                               │
│                                                                  │
│  PR / push        → Molecule tests (Docker, 9 roles)            │
│  Tag vX.Y.Z       → Packer build → Ansible harden → Sign/SBOM  │
└─────────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  Packer HCL2 build                                              │
│                                                                  │
│  Base image: Amazon Linux 2023 AMI (EKS-optimised)              │
│  Builders:   amazon-ebs  (→ AMI)                                │
│              qemu        (→ QCOW2, ISO)                         │
│              docker      (→ OCI image, used in Molecule tests)  │
│                                                                  │
│  Provisioner: ansible-playbook ansible/playbooks/harden.yml     │
└────────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  Ansible hardening playbook                                      │
│                                                                  │
│  Roles applied in order:                                         │
│    1. cis-l2           CIS AL2023 Level 2 baseline              │
│    2. auditd-pci       PCI-DSS v4.0 audit rules (Req 10.2.x)   │
│    3. aide             File integrity monitoring (CIS 1.3.x)     │
│    4. chrony-hardened  Time sync (PCI Req 10.6.1)               │
│    5. fips-mode        FIPS 140-2/3 kernel + crypto policy      │
│    6. cis-k8s-worker   CIS K8s Benchmark v1.8 worker section    │
│    7. pci-dss-v4       PCI-DSS v4.0 node controls               │
│    8. soc2-cc6-cc7-cc8 SOC 2 CC6/CC7/CC8 overlay               │
│    9. ssm-only-access  Disable SSH, enforce SSM access          │
└────────────────────────────────────────────────────────────────┘
         │
         ▼
┌────────────────────────────────────────────────────────────────┐
│  Release artefacts (per tag)                                     │
│                                                                  │
│  - AMI (us-east-1, us-west-2, eu-west-1 — multi-region copy)   │
│  - QCOW2 image (KVM / on-prem)                                  │
│  - ISO (bare-metal / QEMU smoke test)                           │
│  - OCI image (container-based smoke tests)                      │
│  - SBOM (CycloneDX JSON, attached to GitHub Release)            │
│  - Cosign signature (keyless OIDC via GitHub Actions OIDC)      │
└────────────────────────────────────────────────────────────────┘
```

## Role Dependency Graph

```
cis-k8s-worker ──depends on──▶ cis-l2
pci-dss-v4     ──depends on──▶ cis-l2, auditd-pci
soc2-cc6-cc7-cc8 ──depends on──▶ cis-l2, auditd-pci, aide
```

All other roles are standalone.

## Compliance Layers

| Layer | Role(s) | Framework |
|-------|---------|-----------|
| OS baseline | `cis-l2` | CIS AL2023 L2 |
| Audit logging | `auditd-pci`, `cis-l2` | PCI-DSS Req 10, SOC 2 CC7 |
| File integrity | `aide` | CIS 1.3, PCI-DSS Req 11.3 |
| Time sync | `chrony-hardened` | PCI-DSS Req 10.6 |
| Cryptography | `fips-mode` | FIPS 140-2/3, PCI-DSS Req 4 |
| K8s hardening | `cis-k8s-worker` | CIS K8s Benchmark v1.8 |
| PCI-DSS controls | `pci-dss-v4` | PCI-DSS v4.0 Req 1,2,5,6,7,8,10,11 |
| SOC 2 overlay | `soc2-cc6-cc7-cc8` | SOC 2 CC6, CC7, CC8 |
| Access control | `ssm-only-access` | PCI-DSS Req 8.2, SOC 2 CC6 |

Full cross-framework mapping: [`compliance/control-mappings.yaml`](compliance/control-mappings.yaml)

## Testing Layers

| Layer | Tool | When |
|-------|------|------|
| Unit (per role) | Molecule v6 + Docker | Every PR |
| Integration | kube-bench + inspec | Post-build on kind cluster |
| Smoke | nginx workload + PCI network policy | Post-build on EKS |
| Release gate | OpenSCAP | On tag |

## Image Variants

| Variant | Target | Builder |
|---------|--------|---------|
| `ami-eks` | EKS worker node | `amazon-ebs` |
| `qcow2-kvm` | On-prem KVM / OpenShift bare-metal | `qemu` |
| `iso-baremetal` | Bare-metal / QEMU smoke test | `qemu` (ISO) |
| `oci` | Container-based test & development | `docker` |

## Security Properties

Every TabyaOS image at release:

- **Immutable** — no SSH access, no package manager in production, SSM-only node access
- **Signed** — Cosign keyless signature via GitHub Actions OIDC (no long-lived keys)
- **Auditable** — SBOM (CycloneDX) attached to every release; all Ansible tasks reference framework requirement IDs
- **FIPS-ready** — FIPS mode enabled via kernel crypto + OpenSSL FIPS provider (full 140-3 validation via underlying AWS crypto libraries)
- **Reproducible** — Packer + Ansible pinned versions; deterministic builds from the same git ref
