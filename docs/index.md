# TabyaOS

**TabyaOS is an opinionated, hardened operating system image for Kubernetes worker nodes — pre-configured to pass PCI-DSS v4.0, SOC 2 Type II, and CIS Level 2 controls out of the box.**

> *Every node, a redoubt.*

## What is TabyaOS?

*Tabya* (طابية) is Ottoman Turkish for "redoubt" — a small, independent, fortified defensive position. TabyaOS treats every Kubernetes worker node as one such redoubt: self-defending, audit-ready, interchangeable.

TabyaOS is a **build toolkit + hardened image set**:

- Packer HCL configurations for Amazon Linux 2023, Debian 12, and RHEL 9
- 11 Ansible roles implementing CIS L2, PCI-DSS v4.0, SOC 2 Type II, and FIPS controls
- Four artifact formats: QCOW2 (KVM/on-prem), ISO (bare-metal), OCI, AMI (AWS EKS)
- kube-bench / InSpec / OpenSCAP test suites
- GitHub Actions pipelines with Cosign-signed releases and SBOM

## Why TabyaOS?

| Problem | TabyaOS Solution |
|---------|-----------------|
| "Which CIS controls are applied?" | Every Ansible task references its CIS/PCI/SOC2 requirement ID |
| "Can my QSA verify this?" | Cosign-signed SBOM + kube-bench/InSpec evidence bundle per build |
| "Does it work on KVM / bare-metal / EKS?" | Multi-format: QCOW2, ISO, OCI, AMI |
| "What if there's a CVE?" | Enterprise LTS: 18-month patch guarantee, 48h critical CVE SLA |

## Compliance Coverage

| Framework | Status |
|-----------|--------|
| CIS Amazon Linux 2023 Level 2 | ✅ Full benchmark |
| CIS Kubernetes Benchmark v1.8 | ✅ Worker node section |
| PCI-DSS v4.0 | ✅ Req 1,2,5,6,7,8,10,11 (node-applicable) |
| SOC 2 Type II | ✅ CC6, CC7, CC8 |
| NIST SP 800-53 Rev 5 | ✅ Selected moderate baseline |
| FIPS 140-2/3 | ✅ Mode enabled via kernel + OpenSSL provider |

## Quick Start

```bash
git clone https://github.com/tabyaos/tabyaos.git
cd tabyaos
just build-molecule-runner
just test-molecule
just build   # requires AWS credentials for AMI
```

See [Getting Started](getting-started.md) for full instructions.

## License

TabyaOS is licensed under the [Business Source License 1.1](https://github.com/tabyaos/tabyaos/blob/main/LICENSE).

The BSL allows free use for development, testing, and production in non-competing products. Commercial use of the enterprise compliance attestation features requires an [enterprise license](enterprise.md).
