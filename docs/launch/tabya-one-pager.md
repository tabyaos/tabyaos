# Tabya — Product Overview

> *Convert to PDF for partner/prospect distribution. Designed to fit one A4 page at 10pt font.*

---

## What Tabya Does

Tabya builds **TabyaOS** — a hardened Kubernetes worker node OS that arrives pre-configured to pass PCI-DSS v4.0, SOC 2 Type II, CIS Level 2, and BDDK İYBT controls out of the box, with a cryptographically signed compliance evidence chain included in every build.

---

## TabyaOS in Three Points

- **Pre-hardened, not post-hardened.** 11 Ansible roles bake CIS, PCI-DSS, SOC 2, and FIPS controls into the image at build time — not applied as a post-deployment script that can drift or be skipped.
- **Evidence-first design.** Every control maps to a named framework requirement. Every build produces a Cosign-signed kube-bench report, InSpec results, CycloneDX SBOM, and a control-mapping CSV. Your QSA gets a signed evidence bundle, not a screenshot.
- **Infrastructure-agnostic.** Ships as QCOW2 (KVM), ISO (bare-metal), OCI image, and AMI. Works on a Turkish datacenter KVM cluster and on AWS EKS with the same hardening baseline.

---

## Compliance Frameworks

| Framework | Coverage |
|-----------|---------|
| CIS Amazon Linux 2023 Level 2 | Full benchmark |
| CIS Kubernetes Benchmark v1.8 | Worker node section (kubelet, PKI, runtime) |
| PCI-DSS v4.0 | Requirements 1, 2, 5, 6, 7, 8, 10, 11 (node-applicable) |
| SOC 2 Type II | CC6, CC7, CC8 |
| NIST SP 800-53 Rev 5 | Selected moderate baseline |
| FIPS 140-2/3 | Mode enabled via kernel + crypto provider |
| BDDK İYBT 2020-9 | **Overlay in development** — scaffold available, pending legal review |
| KVKK | **Overlay in development** — scaffold available, pending legal review |
| DORA | On roadmap for Q4 2026 |

---

## Artifact Formats

```
QCOW2  →  KVM / libvirt / OpenStack / Turkish DC on-prem clusters
ISO    →  Bare-metal PXE boot / air-gapped / IPMI provisioning
OCI    →  Flatcar, Talos, container-native K8s runtimes
AMI    →  AWS EKS Managed Node Groups / EC2
```

---

## Architecture (simplified)

```
┌─────────────────────────────────────────────────────┐
│  Packer HCL (reproducible, version-pinned build)    │
│     └─ Ansible (11 roles, framework-annotated)      │
│           └─ QCOW2 / ISO / OCI / AMI artifact       │
│                └─ Cosign signature + SBOM            │
│                     └─ kube-bench + InSpec evidence  │
│                          └─ Attestation Pack (PDF)   │
└─────────────────────────────────────────────────────┘
```

---

## Pricing

| Tier | Price | Includes |
|------|-------|---------|
| **Open-source core** | Free | All 11 roles, Packer builds, Molecule tests, community GitHub Issues |
| **Starter** | $499/cluster/month | SLA patch response, Attestation Pack, email support |
| **Professional** | $999/cluster/month | Starter + 18-month LTS + private registry mirror |
| **Enterprise** | $1,499/cluster/month | Professional + custom overlays + direct engineering access |

Annual billing: 2 months free. Partner / DC-operator wholesale pricing available — contact us.

---

## Open-Source & Licensing

TabyaOS is open-source under the **Business Source License 1.1** (BSL 1.1). Free for non-competing production use. Converts to Apache 2.0 four years after each release. Source: [github.com/tabyaos/tabyaos](https://github.com/tabyaos/tabyaos)

---

## About Tabya

Tabya is being built out of Istanbul by engineers with 10+ years of on-premises Kubernetes, AWS, and fintech/card-issuing infrastructure experience. The name *Tabya* (طابية) is Ottoman Turkish for "redoubt" — a self-defending, independent fortified position. Every TabyaOS-hardened node is one such redoubt.

---

**Contact:** info@tabya.io  |  [tabya.io](https://tabya.io)  |  [@tabyaos](https://github.com/tabyaos)

*US entity (Delaware LLC) formation in progress. Current operations through Turkish sole proprietorship.*
