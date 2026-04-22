# TabyaOS Enterprise

TabyaOS Enterprise adds support, long-term patch guarantees, and QSA-ready compliance evidence on top of the open-source core.

## What's Included

### Open-Source Core (this repo)

- All 9 hardening roles (CIS L2, PCI-DSS v4.0, SOC 2, FIPS, K8s)
- Molecule test suite
- Packer builds for AL2023 → AMI, QCOW2, ISO, OCI
- machine-readable compliance mappings
- kube-bench / InSpec / OpenSCAP test harness
- Community support via GitHub Issues

### Enterprise Tier (separate private repo)

| Feature | Description |
|---------|-------------|
| **SLA-backed patch response** | Critical CVE patches within 48 hours; high severity within 7 days |
| **Signed Compliance Attestation Pack** | Per-build QSA-ready evidence bundle: kube-bench results, InSpec/SCAP reports, Cosign audit trail, SBOM, control-mapping cross-reference |
| **Long-term support (LTS)** | 18-month security patch guarantee per LTS release |
| **Private registry mirror** | Air-gapped delivery for regulated environments |
| **Custom control overlays** | FedRAMP Moderate, HIPAA, DORA, PSD2 control profiles on request |
| **Direct engineering access** | Slack/Teams channel, quarterly architecture reviews |

## Pricing

| Plan | Price | Includes |
|------|-------|---------|
| **Starter** | $500/mo per cluster | SLA patches, Attestation Pack, email support |
| **Professional** | $1,000/mo per cluster | Starter + LTS + private mirror |
| **Enterprise** | $1,500/mo per cluster | Professional + custom overlays + direct engineering |

Annual billing available with 2 months free.

## Compliance Attestation Pack

Each build on the enterprise plan produces a signed evidence bundle:

```
attestation/
├── kube-bench-results.json      CIS K8s Benchmark score
├── inspec-report.html           InSpec profile results
├── scap-report.html             OpenSCAP XCCDF results
├── sbom.cyclonedx.json          Software Bill of Materials
├── cosign-bundle.json           Keyless signature bundle
├── control-mapping.csv          Framework requirement cross-reference
└── attestation-summary.pdf      QSA-ready narrative summary
```

The attestation bundle is signed with the same Cosign keyless signature as the image artefact. Your QSA can verify the chain from build to image to evidence.

## Supported Frameworks

| Framework | Coverage |
|-----------|---------|
| CIS Amazon Linux 2023 Level 2 | Full benchmark |
| CIS Kubernetes Benchmark v1.8 | Worker node section |
| PCI-DSS v4.0 | Requirements 1, 2, 5, 6, 7, 8, 10, 11 (node-applicable subset) |
| SOC 2 Type II | CC6, CC7, CC8 |
| NIST SP 800-53 Rev 5 | Selected moderate baseline controls |
| FedRAMP Moderate | Custom overlay (Enterprise plan) |
| HIPAA | Custom overlay (Enterprise plan) |

## Getting Started

Contact us for a design partner conversation:

- Email: [enterprise@tabya.io](mailto:enterprise@tabya.io)
- Schedule: [tabya.io/call](https://tabya.io/call)

Design partners receive the Enterprise plan at no charge during the evaluation period (up to 90 days) in exchange for reference rights and feedback sessions.

## FAQ

**Q: Can I use TabyaOS open-source in a regulated environment without paying?**

Yes. The OSS core is BSL 1.1 licensed and free to use. The enterprise tier adds support SLAs and the QSA-ready attestation reports — the controls themselves are all in the open-source repo.

**Q: Does TabyaOS work on non-AWS infrastructure?**

The AL2023 base targets EKS. The QCOW2/ISO builds work on any KVM host (on-prem, OpenShift bare-metal, GCP bare-metal instances). RHEL 9 base (for OpenShift) is on the roadmap.

**Q: What is the jurisdiction for the commercial entity?**

Initially via a Turkish şahıs şirketi for community work. A Delaware LLC will be formed when the first inbound enterprise inquiry arrives. All contracts can be structured to accommodate both jurisdictions.

**Q: Can you help us pass a PCI-DSS QSA audit?**

TabyaOS provides the node-level evidence. For a complete PCI-DSS engagement (scope definition, network segmentation, application controls), we offer a separate productized consulting engagement: *PCI-DSS K8s Accelerator — 4-week fixed-price, $25-50k*.
