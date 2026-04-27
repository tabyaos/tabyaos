# Getting Started with TabyaOS

TabyaOS produces hardened OS images for Kubernetes worker nodes — QCOW2 (KVM/on-prem), ISO (bare-metal), OCI, and AMI (AWS EKS). This guide walks through building your first image and verifying it passes compliance checks.

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Packer | ≥ 1.10 | `brew install packer` / [packer.io](https://developer.hashicorp.com/packer/install) |
| Ansible | ≥ 2.17 | `pip install ansible-core==2.17.*` |
| just | ≥ 1.25 | `brew install just` / `winget install Casey.Just` |
| Docker | ≥ 24 | For Molecule unit tests |
| AWS CLI | ≥ 2 | For EKS smoke tests only |

AWS credentials with EC2 permissions are required for AMI builds. For local development (QCOW2/ISO), only Packer + QEMU are needed.

## Quick Start — AMI Build

```bash
# 1. Clone and validate
git clone https://github.com/tabyaos/tabyaos.git
cd tabyaos
just validate              # packer validate

# 2. Build a hardened AL2023 EKS AMI
just build                 # packer build packer/al2023/

# 3. Run Molecule unit tests (all 9 roles)
just build-molecule-runner # one-time: build the Docker test runner
just test-molecule         # runs all roles sequentially
```

## Project Structure

```
tabyaos/
├── packer/al2023/          Packer HCL — builds AMI, QCOW2, ISO
├── ansible/
│   ├── roles/              9 hardening roles (see below)
│   └── playbooks/          harden.yml — applies all roles in order
├── tests/
│   ├── kube-bench/         kube-bench result baselines
│   ├── inspec/             InSpec profiles for post-build verification
│   └── smoke/kind/         kind + nginx smoke test
├── compliance/
│   ├── control-mappings.yaml   machine-readable framework mapping
│   └── generated/              auto-generated compliance docs (just gen-docs)
└── docs/                   this documentation
```

## Ansible Roles

| Role | Purpose | Key Frameworks |
|------|---------|---------------|
| `cis-l2` | CIS Amazon Linux 2023 Level 2 baseline | CIS AL2023 L2 |
| `auditd-pci` | PCI-DSS audit rules (Req 10.2.x) | PCI-DSS v4.0 |
| `aide` | File integrity monitoring | CIS 1.3, PCI Req 11.3 |
| `chrony-hardened` | NTP with Amazon Time Sync Service | PCI Req 10.6 |
| `fips-mode` | FIPS 140-2/3 kernel crypto | FIPS, PCI Req 4 |
| `cis-k8s-worker` | CIS Kubernetes Benchmark worker section | CIS K8s v1.8 |
| `pci-dss-v4` | PCI-DSS v4.0 node controls (Req 1,2,5-8,10,11) | PCI-DSS v4.0 |
| `soc2-cc6-cc7-cc8` | SOC 2 Type II CC6/CC7/CC8 overlay | SOC 2 TSC |
| `ssm-only-access` | Disable SSH, enforce SSM-only access | PCI Req 8.2, SOC 2 CC6 |

## Running Tests

### Molecule (unit tests — Docker, no AWS needed)

```bash
# All roles
just test-molecule

# Single role
just test-molecule-role cis-l2

# With verbose output
MSYS_NO_PATHCONV=1 docker run --rm \
  -v $(pwd):/project \
  -v /var/run/docker.sock:/var/run/docker.sock \
  tabyaos/molecule-runner:latest \
  "cd ansible/roles/cis-l2 && molecule test -v"
```

### kube-bench (requires a running cluster)

```bash
# Local kind cluster
just test-kind

# Existing EKS cluster
kubectl apply -f tests/kube-bench/job.yaml
kubectl logs job/kube-bench
```

### Smoke test (requires EKS cluster)

```bash
just smoke
```

## Configuration Variables

Each role exposes variables in `defaults/main.yml`. Override them in your Packer `vars/` file or Ansible group_vars.

Common overrides:

```yaml
# cis-l2
cis_l2_separate_tmp: false          # true if /tmp is a separate partition
cis_l2_account_lockout_attempts: 5  # PAM faillock deny count

# chrony-hardened
chrony_ntp_servers:
  - 169.254.169.123                  # Amazon Time Sync (always include this)
  - time.aws.com

# pci-dss-v4
pci_dss_session_timeout_seconds: 900
pci_dss_install_antimalware: true    # installs ClamAV (slow, disable in CI)
```

## Compliance Docs

Generate human-readable compliance coverage reports:

```bash
just gen-docs
# outputs: compliance/generated/by-framework/, by-role/, coverage-summary.md
```

## Adding a New Control

1. Add the task to the appropriate role's `tasks/` directory, referencing the framework requirement ID in the task name.
2. Add an assertion to the role's `molecule/default/verify.yml`.
3. Add an entry to `compliance/control-mappings.yaml`.
4. Run `just gen-docs` to update the generated docs.
5. Run `just test-molecule-role <role>` to verify the test passes.

## Getting Help

- Open an issue: [github.com/tabyaos/tabyaos/issues](https://github.com/tabyaos/tabyaos/issues)
- Enterprise support: [tabya.io/enterprise](https://tabya.io/enterprise)
