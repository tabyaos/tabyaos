# Tabya / TabyaOS — Hardened Kubernetes Node Distribution

> Context file for Claude Code. Read this before doing any work in this repo.

## Current status

- ✅ Brand finalized: **Tabya** (company), **TabyaOS** (flagship product)
- ✅ Domains registered: **tabya.io** (primary), **tabya.org** (defensive / OSS hub)
- ✅ GitHub organization created: **github.com/tabyaos**
- ✅ Local repo `git init` complete
- ☐ First commit pending
- ☐ License file pending (BSL 1.1 template included in repo)
- ☐ Packer scaffold — start here

## One-line pitch

**TabyaOS is an opinionated, hardened operating system image for Kubernetes worker nodes — pre-configured to pass PCI-DSS v4.0, SOC 2 Type II, and CIS Level 2 controls out of the box.**

Tagline (working): *"Every node, a redoubt."*

## Etymology & brand

*Tabya* (طابية) is Ottoman Turkish for "redoubt" — a small, independent, fortified defensive position. In 19th-century coastal and frontier warfare, a line of tabyas formed the backbone of strategic defense. Every TabyaOS-hardened node is one such redoubt: self-defending, audit-ready, interchangeable, and collectively forming a compliant cluster.

## What this product actually is

A build toolkit + opinionated hardened OS image set, distributed as:

1. **Open-source core** (this repo, `github.com/tabyaos/tabyaos`)
   - Packer HCL configurations for AL2023, Debian 12, RHEL 9 bases
   - Ansible roles implementing CIS L2 + PCI-DSS v4.0 + SOC 2 Type II controls
   - Control-to-requirement mapping tables (machine-readable YAML)
   - kube-bench / inspec / OpenSCAP test suites
   - GitHub Actions pipelines for building, testing, signing releases
   - Cosign-signed SBOMs with every release
   - Multi-format outputs: AMI, QCOW2, ISO, OCI image

2. **Commercial layer** (future private repo, `github.com/tabyaos/tabyaos-enterprise`)
   - Enterprise support with SLA (patch response times, direct engineering access)
   - **Signed Compliance Attestation Pack** — QSA-ready audit reports in standardized formats
   - Long-term support (LTS) releases — 18-month security patch guarantee
   - Private registry mirror with air-gapped delivery
   - Custom control overlays (FedRAMP, HIPAA, DORA, PSD2)

## Target customer

Primary: fintech / card-issuing / BaaS platforms running Kubernetes — hybrid or cloud-native — who need auditable compliance evidence for worker nodes. Buyer persona: Platform Engineering Lead, Head of Compliance, or CISO at a Series A–C fintech or mid-market processor.

Secondary (broader open-source reach): any regulated K8s operator (healthcare, gov-adjacent, DORA-exposed EU operators).

Initial commercial ACV: $500–$1,500 / month per cluster for enterprise support. Target at 18 months: 10–20 paying accounts = $10–25k MRR.

## Why self-release first, marketplace later

- AWS Marketplace requires eligible-jurisdiction incorporation; Turkey is excluded from EMEA seller operations.
- Delaware LLC via Stripe Atlas is the standard workaround, but that's 4-8 weeks + ongoing US tax overhead — not worth it before there's paying demand.
- Marketplace listing adds another 4-8 weeks of AWS review after incorporation.
- Self-release is also strategically correct: the product targets EKS + OpenShift + bare-metal + on-prem KVM. Marketplace would lock it to one cloud.
- Revisit marketplace (AWS + GCP + Azure) once there are 5+ paying enterprise support contracts.

## Founder context

- Expertise: on-prem Kubernetes (OpenShift, kubeadm), AWS, DevOps, fintech/card-issuing domain.
- Working mode: part-time, alongside existing consulting income. No VC pressure.
- Legal status: initial operations via spouse's Turkish sole proprietorship (şahıs şirketi) for early community work and consulting revenue. **Delaware LLC via Stripe Atlas to be formed at first inbound enterprise inquiry** (need US entity for W-9, USD banking, enterprise procurement).
- Language: Turkish preferred for discussion; all code, commits, docs, and customer-facing materials in English.

## Strategic frame

Three-legged strategy (do not re-litigate unless asked):

1. **(Primary) TabyaOS — this repo.** Open-source hardened K8s node distribution + commercial support tier.
2. **(Supporting) Productized consulting.** "PCI-DSS K8s Accelerator — 4-week fixed-price engagement, $25-50k." Feeds reference customers back into TabyaOS. Separate repo.
3. **(Top-of-funnel) Content / community.** Blog posts, conference talks, OSS releases of ancillary tools. Drives inbound.

Full SaaS scanner was considered and deferred — wrong business model for a solo founder.

## Compliance scope

**Node-level controls only.** Explicitly out of scope: application-level compliance, CDE network segmentation (belongs in cluster design), HSM integration (customer-provided), tokenization service (orchestration).

In-scope frameworks:

- **CIS Amazon Linux 2023 / Debian 12 / RHEL 9 Benchmark — Level 2** (full baseline)
- **CIS Kubernetes Benchmark — Worker Node section** (kubelet, container runtime, PKI, network)
- **PCI-DSS v4.0** — requirements 1, 2, 5, 6, 7, 8, 10, 11 (node-applicable subset). Full mapping in `compliance/pci-dss-v4.md`.
- **SOC 2 Type II** — Trust Service Criteria CC6 (Logical & Physical Access), CC7 (System Operations), CC8 (Change Management). Control overlay in `compliance/soc2-type-ii.md`.
- **NIST 800-53 Rev 5** — selected moderate-baseline controls (for FedRAMP-adjacent customers).

## Realistic timeline

- **Weeks 1–3** — Packer scaffold, AL2023 base, join test EKS cluster, pass kube-bench (unhardened baseline).
- **Weeks 4–6** — CIS L2 baseline applied via Ansible, kube-bench + inspec green.
- **Weeks 7–9** — PCI-DSS v4.0 controls layered, mapping doc written.
- **Weeks 10–12** — SOC 2 Type II controls overlay, Debian 12 base added.
- **Weeks 13–15** — CI/CD pipeline, GitHub Releases publishing signed AMI/QCOW2/ISO, Cosign SBOM.
- **Week 16** — Public launch: Hacker News Show HN, docs site on tabya.io, first 3 blog posts.
- **Weeks 17–24** — Community building, inbound enterprise inquiries, first design partners.
- **Month 7–9** — First 1–2 paid enterprise support contracts. Delaware LLC formation in parallel.
- **Month 10–12** — SOC 2 Type I for Tabya (the company). 5+ paying customers.
- **Month 12–18** — AWS Marketplace listing under LLC, SOC 2 Type II, broader commercial push.

**First customer inquiry expected: Month 4–5. First paid revenue: Month 7–9.**

## Kill criteria (decide early, not in hindsight)

If by Month 9 none of the following are true, pivot or shut down:

- GitHub stars > 500
- ≥ 3 unsolicited enterprise support inquiries
- ≥ 1 signed design partner (paid or unpaid but with reference rights)
- ≥ 1 QSA firm has indicated willingness to accept TabyaOS attestation in audits

## Open questions (decide when relevant)

1. **Base OS default.** AL2023 ships first (broadest EKS use). Debian 12 second (on-prem / OpenShift portability). RHEL 9 third (enterprise / FedRAMP). Bottlerocket explicitly parked — it's a different product category.
2. **FIPS 140-2/3 validation.** Using FIPS-validated modules via RHEL/UBI or AWS crypto libraries vs. claiming "FIPS-ready." Full validation is $100k+ — defer. Start with "FIPS mode enabled using underlying-OS-validated modules."
3. **Attestation Pack pricing model.** Subscription ($500-1500/mo) vs. per-audit ($5-15k). Lean subscription to align with SaaS-like recurring revenue.
4. **Delaware LLC timing.** Tentative: form when first inbound enterprise inquiry arrives.

## Repo layout (planned)

```
tabyaos/
├── CLAUDE.md
├── README.md
├── LICENSE                          # BSL 1.1 (needs legal review before 1.0 release)
├── .gitignore
├── CODE_OF_CONDUCT.md               # to add later
├── CONTRIBUTING.md                  # to add later
├── SECURITY.md                      # vuln disclosure — add before public launch
├── packer/
│   ├── al2023/
│   │   ├── al2023.pkr.hcl
│   │   ├── variants/                # ami-eks, qcow2-kvm, iso-baremetal, oci
│   │   └── vars/
│   ├── debian12/
│   └── rhel9/
├── ansible/
│   ├── roles/
│   │   ├── cis-l2/                  # CIS OS Benchmark Level 2
│   │   ├── cis-k8s-worker/          # CIS Kubernetes Benchmark
│   │   ├── pci-dss-v4/              # PCI-DSS v4.0 node controls
│   │   ├── soc2-cc6-cc7-cc8/        # SOC 2 overlay
│   │   ├── auditd-pci/              # audit daemon rules
│   │   ├── aide/                    # file integrity monitoring
│   │   ├── chrony-hardened/         # time sync
│   │   ├── fips-mode/               # FIPS enablement
│   │   └── ssm-only-access/         # no SSH, SSM agent only
│   └── playbooks/
│       └── harden.yml
├── tests/
│   ├── kube-bench/
│   ├── inspec/
│   ├── openscap/                    # SCAP Security Guide profiles
│   └── smoke/                       # spin-up-real-EKS test
├── compliance/
│   ├── control-mappings.yaml        # machine-readable cross-framework map
│   ├── cis-l2.md
│   ├── pci-dss-v4.md
│   ├── soc2-type-ii.md
│   └── nist-800-53.md
├── attestation/
│   ├── templates/                   # QSA-ready report templates (jinja2)
│   └── schemas/                     # JSON Schema for evidence payloads
├── .github/
│   ├── workflows/
│   │   ├── build.yml
│   │   ├── test.yml
│   │   ├── release.yml
│   │   ├── publish-sbom.yml
│   │   └── security-scan.yml
│   └── ISSUE_TEMPLATE/
└── docs/
    ├── strategy.md                  # preserved strategic context
    ├── architecture.md
    ├── getting-started.md
    ├── running-on-eks.md
    ├── running-on-openshift.md
    ├── running-on-baremetal.md
    ├── enterprise.md                # commercial tier overview
    └── threat-model.md
```

## Working agreements for Claude Code

- **Language:** All code, comments, commit messages, docs, and customer-facing strings in English. Discussion with the founder in this chat can be Turkish.
- **Packer:** HCL2 syntax only. Never JSON. `amazon-ebs`, `qemu`, and `docker` builders. Multi-arch (x86_64 + arm64) targets.
- **Ansible:** All hardening is idempotent. Every control has a comment referencing its framework ID (`# PCI-DSS v4.0 Req 10.2.1.1`, `# CIS AL2023 5.2.3`, `# SOC 2 CC6.1`). Use `ansible-lint` in CI.
- **Testing:** Default test surface = a real EKS 1.31 cluster + a KVM VM + a bare-metal ISO boot. No mocks for smoke tests.
- **Signing:** Every release artifact (AMI, QCOW2, ISO, OCI) must be Cosign-signed with keyless OIDC via GitHub Actions. SBOM (CycloneDX) published alongside every release.
- **Secrets:** Never commit AWS credentials, AMI IDs, OIDC tokens. Use GitHub OIDC for all cloud auth in CI.
- **Licensing:** All OSS code under BSL 1.1. Commercial layer in a separate private repo, not in this one.
- **Documentation:** Every new control-role includes a markdown doc under `compliance/` explaining what it does, which requirement it addresses, and how to verify it passed.

## What to work on next (suggested order)

1. **Bootstrap `packer/al2023/`.** Minimal HCL that builds an EKS-compatible AL2023 AMI with no hardening. Verify it joins an EKS cluster.
2. **Add kube-bench test harness.** Green baseline before any hardening.
3. **Layer CIS L2 via Ansible.** Verify kube-bench and inspec scores.
4. **Add PCI-DSS v4.0 controls.** Document each in `compliance/pci-dss-v4.md`.
5. **Add SOC 2 overlay.** Map CC6/CC7/CC8 controls to existing + new tasks.
6. **Write smoke test.** Real EKS cluster spin-up + nginx workload + PCI-facing network policy.
7. **CI/CD.** GitHub Actions: build on PR, test matrix, release on tag, SBOM + Cosign sign.
8. **Docs site at tabya.io.** Static site (likely MkDocs Material or Docusaurus).
9. **Public launch.** Hacker News Show HN + 3 blog posts + submit to CNCF security landscape.

## Non-negotiables

- Every control added to TabyaOS is traceable to a named framework requirement. No "security theater" hardening.
- Every release is cryptographically signed and SBOM-published. Non-negotiable for compliance buyers.
- Breaking changes to hardened defaults require a CHANGELOG entry + migration note.
- No telemetry from OSS builds. Commercial support tier may include opt-in telemetry (and must be opt-in).

## Suggested first prompt for Claude Code in this repo

> *Read CLAUDE.md in full. Then start with step 1 in 'What to work on next': bootstrap `packer/al2023/` with a minimal HCL that builds an EKS-compatible Amazon Linux 2023 AMI with no hardening. Include: Packer init config, AWS auth via environment variables (OIDC to be added later), a `justfile` or `Makefile` with `build`, `validate`, and `clean` targets, and a top-level `packer/README.md` explaining how to run it locally. Do not add any hardening yet — this pass is just proving the EKS-join baseline works.*