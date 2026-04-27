# TabyaOS

**Every node, a redoubt.**

An opinionated, hardened operating system for Kubernetes worker nodes. Ships with CIS Level 2, PCI-DSS v4.0, and SOC 2 Type II controls pre-applied and audit-traceable. Runs on on-prem KVM, bare-metal, OCI environments, and AWS EKS.

## What you get

- **Three base OS targets:** Amazon Linux 2023, Debian 12 (on-prem/OpenShift), RHEL 9 (enterprise/FedRAMP).
- **11 Ansible hardening roles** — all Molecule-tested (converge + idempotence + verify in Docker).
- **Four artifact formats:** QCOW2 (KVM/on-prem), ISO (bare-metal), OCI image (container-native), AMI (AWS EKS).
- **48 controls** mapped across CIS AL2023 L2, CIS Kubernetes v1.8, PCI-DSS v4.0, SOC 2 Type II, NIST 800-53.
- Every control references its framework requirement (`# CIS AL2023 5.2.3`, `# PCI-DSS v4.0 Req 10.2.1.1`).
- Cosign-signed releases with CycloneDX SBOMs.
- kube-bench and OpenSCAP test suites in the box.

Built for environments where data sovereignty matters — Turkish fintech, EU regulated infrastructure, and government-classified workloads where hyperscaler residency is a compliance risk.

## Why Tabya exists

Producing worker-node compliance evidence for a stock Amazon Linux or Ubuntu K8s deployment is 40+ hours of auditor-facing work per cycle. TabyaOS is built so that the node side of the audit is already done — your QSA gets signed, dated, machine-readable attestations on demand.

## Status

**v0.1.0-alpha** — hardening baseline complete. Working toward public launch.

| Phase | Milestone | Status |
|-------|-----------|--------|
| 0 | Packer scaffold, AL2023 EKS-joining AMI | ✅ Done |
| 1 | CIS Level 2 baseline (9 Ansible roles, all Molecule-tested) | ✅ Done |
| 2 | PCI-DSS v4.0 controls + compliance mapping | ✅ Done |
| 3 | SOC 2 Type II overlay, CI/CD, signed releases, SBOM | ✅ Done |
| 4 | Debian 12 + RHEL 9 base images (11 roles total, all Molecule-tested) | ✅ Done |
| 5 | Public launch on tabya.io, Show HN | 🔜 Next |
| 6 | First enterprise support contracts | Month 7–9 |
| 7 | AWS Marketplace listing (post-LLC) | Month 12–18 |

## Commercial tier

OSS forever for the core. Paid tiers add:

- Enterprise support with SLA on patch response
- Signed Compliance Attestation Pack (QSA-ready audit reports)
- 18-month LTS releases
- Private registry + air-gapped delivery
- Custom framework overlays (FedRAMP, HIPAA, DORA, PSD2)

Pricing starts at around $500/month per cluster. Contact: info@tabya.io.

## License

[Business Source License 1.1](./LICENSE) — free for non-production and non-competing production use. Converts to Apache 2.0 four years after each release.

## Links

- Website: [tabya.io](https://tabya.io) *(under construction)*
- OSS hub: [tabya.org](https://tabya.org) *(under construction)*
- GitHub: [github.com/tabyaos](https://github.com/tabyaos)

## Company

Tabya is being built out of Istanbul by a team with 10+ years of on-prem Kubernetes, AWS, and fintech infrastructure experience. US entity (Delaware LLC) formation scheduled ahead of the first enterprise contract.
