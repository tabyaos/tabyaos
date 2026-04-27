# Data Sovereignty and Regulated Infrastructure

Hyperscalers are sufficient for most workloads. For a specific class of regulated operators — Turkish fintech institutions, EU financial entities under DORA, government-adjacent workloads — they introduce compliance problems that cannot be solved by configuration alone. This document explains why, and how TabyaOS addresses the node-level portion of the problem.

## The Regulatory Landscape

### BDDK İYBT 2020-9 (Turkey)

The Bankacılık Düzenleme ve Denetleme Kurumu's *Bilgi Sistemleri ve Bankacılık Süreçlerinin Yönetimine Dair Yönetmelik* (Information Systems and Banking Process Management Regulation, 2020-9) requires BRSA-licensed banks, participation banks, and payment institutions to:

- Retain critical data and system infrastructure within the Republic of Turkey's geographic borders.
- Demonstrate that system hardening meets documented and auditable standards.
- Maintain audit logs that are tamper-evident and reviewer-accessible on demand.
- Perform risk assessments of third-party service providers, including cloud vendors.

Clause 11 of İYBT 2020-9 specifically addresses physical and logical security of information systems. The regulation does not prohibit cloud usage categorically, but it requires that data residency, access control, and audit evidence satisfy Turkish banking supervisory standards — requirements that public cloud shared-responsibility models satisfy only partially for the worker-node layer.

In practice, this means many BDDK-licensed institutions operate on-premises Kubernetes clusters in Turkish datacenters (co-location or private) where the institution retains physical and logical control of the underlying infrastructure. Buying a stock OS image from a cloud marketplace and running it on-premises does not, by itself, provide the compliance evidence chain that BDDK auditors expect.

### KVKK (Turkey)

The *Kişisel Verilerin Korunması Kanunu* (Personal Data Protection Law, Law No. 6698) and its implementing regulations require data controllers processing Turkish citizens' personal data to implement technical and organizational measures proportionate to the sensitivity of the data. The KVKK Board's technical security guidance maps closely to ISO 27001 and CIS controls for infrastructure hardening.

While KVKK does not prescribe a specific OS configuration, processors handling sensitive categories of data (financial, health, identity) face elevated scrutiny of their infrastructure controls during Board investigations. A documented, test-verified hardening baseline with machine-readable control mappings provides a defensible evidentiary record.

### DORA (European Union)

The EU's Digital Operational Resilience Act (Regulation (EU) 2022/2554), effective January 2025, imposes binding operational resilience requirements on EU financial entities including banks, investment firms, payment institutions, and critical ICT third-party service providers. DORA's Article 9 (ICT security policies) and Articles 11-12 (ICT business continuity and backup) have direct implications for K8s worker node configuration:

- Systems processing financial data must have documented, tested hardening baselines.
- Patch and vulnerability management must follow risk-proportionate timelines (critical: 1 business day notification; high: risk-based remediation window).
- ICT third-party risk management requires that technology supply chain components have verifiable provenance.

Cosign-signed SBOMs with a traceable build chain directly address the DORA provenance requirement for the OS image layer.

## Why Hyperscalers Are Insufficient (for This Layer)

The framing of "cloud vs. on-prem" misses the point. The issue is specific to the worker-node layer of a Kubernetes cluster:

**Shared responsibility stops at the hypervisor.** AWS, Azure, and GCP harden their hypervisor and network infrastructure. The guest OS on an EC2 instance, a VM in Azure, or a GKE node is the customer's responsibility. The regulatory obligations above apply to that guest OS layer.

**Managed services do not solve worker-node compliance.** EKS Managed Node Groups use AWS-supplied AMIs (EKS-optimized Amazon Linux 2023). These AMIs are not CIS Level 2 hardened out of the box. Running `kube-bench` against a fresh EKS worker node will typically yield 40–60% PASS rates before any hardening. The AWS Shared Responsibility Model explicitly places OS hardening in the customer's scope.

**Data residency requires substrate control.** For BDDK-regulated entities, even a region-local AWS datacenter in Turkey may not satisfy the residency requirement if the IAM control plane, audit log egress, or key management infrastructure routes through non-Turkish systems. On-premises infrastructure with physical control satisfies residency requirements without ambiguity.

**Audit evidence must be presentable on demand.** A QSA or BDDK auditor cannot log into AWS to verify your node hardening. You need a signed, reproducible evidence bundle — a kube-bench report signed at build time against a known image SHA — that the auditor can verify offline.

## How TabyaOS Maps to Sovereign Infrastructure Deployments

### Artifact Formats and Deployment Targets

| Format | Target Infrastructure | Sovereignty Profile |
|--------|----------------------|---------------------|
| QCOW2 | KVM / libvirt / oVirt / OpenStack | Full host control; ideal for Turkish DC operators |
| ISO | Bare-metal PXE / IPMI boot | Maximum substrate control; air-gapped environments |
| OCI image | Flatcar, Talos, or OCI-capable runtimes | Container-native; supply chain verifiable |
| AMI | AWS EC2 / EKS Managed Node Groups | Cloud-hosted; suitable where AWS residency is acceptable |

For a Turkish banking institution operating a private KVM cluster in a co-location facility in Istanbul, the QCOW2 artifact is the correct starting point. The Packer build runs on the institution's own infrastructure or a trusted CI environment; the resulting image is signed with Cosign; the kube-bench baseline is captured at build time; and the attestation bundle is stored in the institution's own object store or document management system.

### Compliance Evidence Chain

```
Packer build (reproducible HCL, version-pinned)
  └─ Ansible playbook (11 roles, every task annotated with framework ID)
       └─ Cosign signature (keyless OIDC or institutional key)
            └─ SBOM (CycloneDX, lists all packages and versions)
                 └─ kube-bench results (per-node, per-build)
                      └─ InSpec report (post-build verification)
                           └─ control-mappings.yaml (machine-readable cross-reference)
```

Every link in this chain is reproducible, signed, and verifiable without access to any third-party system. An auditor with the public Cosign key, the Git SHA, and the evidence bundle can reconstruct the full compliance picture without calling AWS or any cloud vendor.

### BDDK-Specific Deployment Notes

BDDK İYBT Article 11.2 requires that hardening procedures be documented and traceable to recognized standards. The `compliance/control-mappings.yaml` file provides a machine-readable mapping from every TabyaOS control to its CIS, PCI-DSS, SOC 2, or NIST requirement ID. This mapping can be exported to CSV or PDF for auditor submission.

BDDK also requires that privileged access to systems be restricted and logged. TabyaOS's `ssm-only-access` role disables SSH entirely and routes privileged access through AWS SSM Session Manager (or equivalent bastion on-prem). The `auditd-pci` role writes immutable audit logs covering all privileged command execution, file integrity events, and authentication events.

> **Overlay status:** A BDDK İYBT 2020-9 specific control overlay is under development at `compliance/overlays/bddk-iybt.yaml`. All entries in that overlay are marked `REQUIRES_LEGAL_REVIEW: true`. TabyaOS does not claim BDDK certification. The overlay is a mapping scaffold to assist operators in preparing their compliance documentation; it requires review by qualified legal counsel and a BDDK-recognized auditor before use in an actual audit submission.

## The Threat Model for Sovereign Infrastructure

Sovereign infrastructure deployments face a different threat profile than public-cloud deployments.

**Physical access is a realistic attack surface.** In a shared co-location facility, physical access to server hardware is constrained but not zero. AIDE (file integrity monitoring), immutable audit logs, and Secure Boot (where the platform supports it) provide detection and evidence-preservation capabilities.

**Supply chain attacks are higher-priority.** When you control the substrate, the attack surface shifts toward the software supply chain. A compromised base OS image, a backdoored Ansible role, or a tampered package repository can persist undetected. Cosign-signed builds with SBOM publication address this: any deviation from the signed baseline is detectable.

**Insider threat models differ.** On-premises infrastructure concentrates privileged access in a smaller group of administrators. The `auditd-pci` and `ssm-only-access` roles implement the principle of least privilege and full audit trail for all privileged sessions, which is the primary technical control for insider threat scenarios in regulated environments.

**Network perimeter is customer-controlled.** Unlike public cloud, on-premises K8s nodes sit behind a network boundary that the operator fully controls. This is an advantage — but it also means that the baseline network policy and CIS network hardening controls (IP forwarding, redirect controls, kernel networking parameters) must be applied correctly from the start. TabyaOS applies these at the node OS level; cluster-level network policy (Calico, Cilium) is out of scope but complementary.

## Summary

The regulatory requirements imposed by BDDK İYBT 2020-9, KVKK, and DORA create concrete technical obligations at the Kubernetes worker-node layer that stock OS images and cloud-provider managed nodes do not satisfy. TabyaOS provides the hardening baseline, test evidence, and signed artifact chain needed to build a defensible compliance posture for on-premises and sovereign-infrastructure deployments. It is one component of a complete compliance program — not a substitute for legal counsel, QSA engagement, or cluster-level security architecture.
