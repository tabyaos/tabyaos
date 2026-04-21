# TabyaOS

**Every node, a redoubt.**

An opinionated, hardened operating system for Kubernetes worker nodes. Ships with CIS Level 2, PCI-DSS v4.0, and SOC 2 Type II controls pre-applied and audit-traceable. Runs on EKS, OpenShift, bare-metal, and on-prem KVM.

## What you get

- Hardened node images in four formats: AMI (AWS), QCOW2 (KVM), ISO (bare-metal), and OCI (container host).
- Every control is traceable to a named compliance requirement (CIS AL2023, CIS Kubernetes Worker, PCI-DSS v4.0, SOC 2 Trust Service Criteria).
- Cosign-signed releases with CycloneDX SBOMs.
- kube-bench, inspec, and OpenSCAP test suites in the box.
- Weekly security-patched builds.

## Why Tabya exists

Producing worker-node compliance evidence for a stock Amazon Linux or Ubuntu K8s deployment is 40+ hours of auditor-facing work per cycle. TabyaOS is built so that the node side of the audit is already done — your QSA gets signed, dated, machine-readable attestations on demand.

## Status

Pre-alpha. Public launch targeted for Week 16. See [`CLAUDE.md`](./CLAUDE.md) for the full plan.

| Phase | Milestone | ETA |
|-------|-----------|-----|
| 0 | Packer scaffold, AL2023 EKS-joining AMI, kube-bench baseline | Week 1–3 |
| 1 | CIS Level 2 baseline applied | Week 4–6 |
| 2 | PCI-DSS v4.0 controls + mapping | Week 7–9 |
| 3 | SOC 2 Type II overlay + Debian 12 base | Week 10–12 |
| 4 | CI/CD, signed releases, SBOMs | Week 13–15 |
| 5 | Public launch on tabya.io | Week 16 |
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