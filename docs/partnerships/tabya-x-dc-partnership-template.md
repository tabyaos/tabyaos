# Tabya × [Partner Name] — Partnership Proposal

> **Template instructions:** Replace all `[bracketed]` fields before sending. This document is a working template; customise the engagement model section to match the specific partner's position.

---

## Executive Summary

Tabya and [Partner Name] share a common customer base: regulated infrastructure operators who need Kubernetes worker nodes that satisfy BDDK, KVKK, and CIS Level 2 requirements from day one. This proposal outlines three engagement models ranging from a technical design partnership to a resale arrangement, starting with a 90-day pilot on a single cluster at [Partner's customer / internal workload].

---

## The Opportunity

### Partner's position

[Partner Name] operates [N] racks / [X] TB of compute across [location(s)] serving [customer profile — fintech, banking, government, etc.]. Partners deploying Kubernetes for customers face a recurring problem: each tenant who needs PCI-DSS or BDDK compliance requires the platform team to produce worker-node hardening evidence, which today takes [estimated hours] of manual work per audit cycle.

### Tabya's value proposition

TabyaOS delivers a pre-hardened Kubernetes worker node image with:

- **11 Ansible roles** covering CIS Level 2, PCI-DSS v4.0, SOC 2 Type II, and FIPS controls.
- **Machine-readable control mappings** traceable to every framework requirement.
- **Cosign-signed SBOM** per build — verifiable supply chain provenance.
- **Four artifact formats:** QCOW2 (KVM), ISO (bare-metal), OCI, AMI — suitable for any infrastructure substrate.
- **Compliance attestation pack** (enterprise tier): a signed evidence bundle that a QSA or BDDK auditor can verify offline without cloud vendor access.

The partner outcome: tenant clusters arrive pre-hardened; the compliance evidence chain is ready before the auditor's first meeting; the platform team stops producing bespoke hardening scripts per tenant.

---

## Three Engagement Models

### Model A — Design Partner (No commercial commitment)

**Structure:** [Partner Name] deploys TabyaOS on one internal or tenant cluster. Tabya provides direct engineering support, early access to the BDDK İYBT overlay (when ready), and a named reference in case studies (optional). No revenue exchange.

**Partner commits to:**
- Running the TabyaOS Molecule test suite on their infrastructure.
- Providing feedback on QCOW2 artifact format, BDDK-overlay gaps, and operational integration pain points.
- One written reference or case study quote (optional; can be anonymised).

**Tabya commits to:**
- Weekly engineering sync for 90 days.
- Direct Slack/Teams channel with the Tabya engineering team.
- Prioritising feature requests that emerge from the pilot.

**Suitable when:** Partner wants to evaluate the product before committing to a commercial arrangement. Zero financial risk. Suitable as a first step for any engagement model.

---

### Model B — Co-sell

**Structure:** [Partner Name] identifies tenant customers with BDDK/KVKK/CIS compliance requirements. Tabya delivers the TabyaOS license and attestation pack directly to the tenant; partner receives a referral fee.

**Commercial terms:**
- Referral fee: 20% of first-year ACV per referred customer.
- Partner is not responsible for support, billing, or SLA delivery — that remains Tabya's.
- Partner benefits from having a ready answer for the "how do we harden our K8s nodes?" question from tenants without building an in-house capability.

**Suitable when:** Partner's primary business is infrastructure delivery, not compliance consulting. Low operational overhead for the partner.

---

### Model C — Resell / White-label

**Structure:** [Partner Name] licenses TabyaOS from Tabya at wholesale pricing and resells it to tenants as part of a managed Kubernetes offering, potentially under the partner's brand.

**Commercial terms:**
- Wholesale price: 50–70% of Tabya list price per cluster per month (exact rate TBD based on volume commitment).
- Partner handles first-line support; Tabya provides second-line engineering escalation.
- Partner controls customer pricing and margin.
- White-label terms: Tabya logo in "powered by" attribution; partner brand as primary.

**Suitable when:** Partner wants to own the customer relationship and incorporate compliant K8s nodes as a differentiated feature of their managed infrastructure offering.

---

## Proposed First-Step Pilot

Regardless of long-term engagement model, we propose a 90-day Design Partner pilot (Model A) as the starting point.

**Pilot scope:**
- One cluster (3–5 worker nodes) on [Partner's KVM / bare-metal infrastructure].
- TabyaOS QCOW2 artifact for KVM deployment.
- Molecule verification run on partner's infrastructure to confirm idempotency.
- kube-bench baseline capture against a fresh node and a hardened node.
- BDDK gap analysis: which current TabyaOS controls map to İYBT Article 11.2, and which gaps remain for the overlay.

**Success criteria:**
- kube-bench PASS rate ≥ 85% on CIS Kubernetes worker node section after hardening (target: ≥ 95%).
- BDDK gap list produced and reviewed.
- Partner engineering team can independently run `just test-molecule` and validate results.

**Timeline:**

| Week | Milestone |
|------|-----------|
| 1 | QCOW2 artifact deployed, first kube-bench baseline captured |
| 2–3 | Molecule test suite run on partner infra; idempotency confirmed |
| 4–6 | BDDK gap analysis; overlay scaffold reviewed |
| 7–10 | Hardened image tuned to partner's kernel/NIC/storage configuration |
| 11–12 | Final kube-bench report; pilot review meeting |

---

## Commercial Framework

For Model B or C engagements following a successful pilot:

| Parameter | Value |
|-----------|-------|
| Tabya list price | $499–$1,499/cluster/month (Starter→Enterprise) |
| Partner wholesale (Model C) | 50–70% of list (volume dependent) |
| Referral fee (Model B) | 20% of first-year ACV per referred account |
| Minimum commitment | No minimum for pilot; discuss for post-pilot commercial |
| Billing | Monthly, invoiced; annual available at 2 months free |
| Currency | USD (international) or TRY (local partners, if mutually agreed) |

Pricing is indicative. Formal commercial terms require a signed Order Form referencing the Master Service Agreement.

---

## Joint Roadmap Items

The following items are on the Tabya roadmap and directly relevant to the partnership:

| Item | Expected | Relevance |
|------|----------|-----------|
| BDDK İYBT 2020-9 overlay (scaffold → reviewed) | Q3 2026 | Core requirement for Turkish banking customers |
| KVKK data-residency control overlay | Q3 2026 | Required for KVKK-scope data processors |
| DORA ICT resilience overlay | Q4 2026 | EU financial entities |
| Tabya Attest CLI | Q2 2026 | Standalone evidence generation without image rebuild |
| Turkish-language audit report template | Q3 2026 | Required for BDDK submission |

Partner feedback on roadmap priorities will directly influence scheduling.

---

## Legal Scaffolding Requirements

Before entering any commercial arrangement, both parties need:

1. **MoU (Memorandum of Understanding)** — non-binding statement of intent covering pilot scope, IP ownership, and reference rights. Recommended before the pilot begins.
2. **NDA** — mutual non-disclosure covering product roadmaps, customer data, and commercial terms. Can be combined with MoU.
3. **IP ownership is clear:** TabyaOS and all Tabya tooling remain Tabya's IP. Partner contributions (configuration profiles, custom overlays developed jointly) follow a joint-contribution agreement if they are to be incorporated into the open-source core.
4. **No exclusivity in v1:** Tabya cannot offer geographic or vertical exclusivity at this stage. A right-of-first-refusal on BDDK-specific features for [Partner]'s customer base can be discussed for post-pilot arrangements.
5. **BSL 1.1 awareness:** The TabyaOS open-source core is licensed under Business Source License 1.1 — free for non-competing production use, converts to Apache 2.0 in 4 years. Enterprise tier is a separate commercial license.

For a pilot (Model A), a signed MoU + NDA is sufficient. For commercial engagement (Models B or C), a full Master Service Agreement and Order Form are required.

---

## Next Steps

| Action | Owner | By |
|--------|-------|----|
| Confirm pilot cluster specification (KVM host, CPU, RAM, storage) | [Partner] | [Date] |
| Share Tabya TabyaOS QCOW2 artifact and deployment guide | Tabya | Within 3 business days of MoU signature |
| Draft and sign MoU + NDA | Both | [Date] |
| Schedule pilot kick-off call (1 hour, engineering + legal) | Both | [Date] |
| Define BDDK gap-analysis scope and methodology | Both | Week 1 of pilot |

---

*Prepared by Tabya — [Date]. This document is confidential and intended for the named partner only. Contact: info@tabya.io*
