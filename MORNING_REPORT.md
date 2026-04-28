# Morning Report — 2026-04-28

Branch: `overnight/2026-04-28-bbatch`
Base: `build-out/v0.1.0-alpha` @ `41157f9`
Maintainer: orhanozdogan | Approved at: 01:10

---

## Summary

4 commits, 33 files changed, 2484 insertions, 12 deletions. All tests that could be run locally passed. Two manual verifications needed from the maintainer.

---

## Work completed

### Phase 1 — Strategic doc updates ✅

Updated docs to reflect the on-prem pivot and Tabya parent-company framing.

- **CLAUDE.md**: Added "Strategic positioning (updated 2026-04-28)" section covering Tabya as parent company; 4 planned products (TabyaOS, Attest, Stack, Watch); on-prem GTM priority order; artifact format priority (QCOW2→ISO→OCI→AMI); BDDK/KVKK/DORA overlay plans; design-partner pipeline notes. Updated kill criteria to include on-prem pivot condition.
- **README.md**: Re-ordered artifact formats to QCOW2, ISO, OCI, AMI. Added data-sovereignty sentence. Updated "runs on" description.
- **docs/sovereignty.md** (NEW, ~1,100 words): Technical doc covering BDDK İYBT 2020-9, KVKK, DORA regulatory obligations; hyperscaler limitations at the worker-node layer; TabyaOS artifact format mapping to sovereign-infra deployments; threat model for sovereign infrastructure.
- **docs/partnerships/tabya-x-dc-partnership-template.md** (NEW, ~2 pages): Partnership proposal template with 3 engagement models (design partner, co-sell, resell), 90-day pilot proposal, commercial framework, legal scaffolding requirements.
- **docs/launch/tabya-one-pager.md** (NEW): 1-pager for design-partner conversations with compliance framework table, artifact format diagram, pricing tiers.
- **docs/index.md, enterprise.md, getting-started.md**: Minor updates (11 roles, QCOW2-first artifact ordering).

### Phase 2 — Compliance audit expansion ✅

- **control-mappings.yaml**: Expanded from 48 → 74 controls (+26 entries):
  - MAINT-001..008: CIS AL2023 §6 system maintenance (file permissions, world-writable, SUID/SGID, password hygiene)
  - RHEL-001..010: `cis-rhel9` role was entirely unmapped — now has 10 entries covering all 6 task sections
  - DEB-009..011: `cis-debian12` gaps (services, logging, maintenance sections)
  - NET-003: IPv6 disable
  - LOG-004/005: rsyslog + journald persistence
  - K8S-009/010: kubelet event-qps and streaming timeout
- **compliance/overlays/bddk-iybt.yaml** (NEW): 8-control BDDK İYBT 2020-9 scaffold. Every entry marked `# REQUIRES_LEGAL_REVIEW: true`. Covers Articles 11 (access control, hardening, audit trail, monitoring), 12 (encryption, time sync), 13 (incident evidence), 14 (security testing).
- **compliance/overlays/kvkk.yaml** (NEW): 6-control KVKK Article 12 scaffold. Every entry marked `# REQUIRES_LEGAL_REVIEW: true`. Covers access control, audit logging, encryption, integrity, breach detection, system hardening baseline.
- **compliance/references/cis-al2023-l2-toc.md** (NEW stub): Gap analysis notes. Maintainer to populate with actual CIS AL2023 TOC.

### Phase 3 — Verifier quality re-audit

**DEFERRED.** Time limit (57 min from start) prevented Phase 3. The 22 `review-yaml` calls (~3 hours GPU time) would have exceeded the session window. All findings would be read-only; no Ansible code was modified.

**Recommendation:** Run Phase 3 in the next session:
```bash
for role in cis-l2 cis-k8s-worker pci-dss-v4 soc2-cc6-cc7-cc8 auditd-pci aide chrony-hardened fips-mode ssm-only-access cis-debian12 cis-rhel9; do
  python3 scripts/local-ai.py review-yaml ansible/roles/$role/tasks/main.yml > /tmp/review-$role-tasks.md
  python3 scripts/local-ai.py review-yaml ansible/roles/$role/molecule/default/verify.yml > /tmp/review-$role-verify.md
done
```

### Phase 4 — Tabya Attest CLI scaffold ✅

Created `tabya-attest/` Go 1.22 module scaffold:
- `main.go` + cobra CLI (`cmd/root.go`, `cmd/attest.go`, `cmd/version.go`)
- `internal/runner/kubebench.go` — `RunKubeBench` stub
- `internal/runner/inspec.go` — `RunInspec` stub
- `internal/bundle/cosign.go` — `Sign` stub
- `Makefile`, `.golangci.yml`, `README.md`

**NOTE: `go build` not verified** — Go is not installed on this workstation. Run `make build` and `make vet` to confirm compilation before merging.

### Phase 5 — Test pass (partial) ✅

- **`mkdocs build --strict`**: PASS after fixing nav entries and broken links.
  - Fixed: `docs/architecture.md` → correct `control-mappings.yaml` link
  - Fixed: `docs/testing-strategy.md` → GitHub URL for packer README
  - Added new pages to `mkdocs.yml` nav (sovereignty, partnerships, one-pager)
  - Copied `compliance/control-mappings.yaml` and generated compliance docs to `docs/compliance/`
- **Molecule (all 11 roles)**: NOT RUN locally — Docker runner requires `just test-molecule`; verified via CI. Last CI run had all roles at PASS (build-out/v0.1.0-alpha pre-fix). The overnight batch made no Ansible task changes.
- **`just test-kind`**: NOT RUN — requires Docker. No Ansible changes were made; baseline result unchanged.

---

## Audit findings — DO NOT auto-fix

From Phase 2.1 manual audit of `compliance/control-mappings.yaml`:

1. **`K8S-005`** has `CIS_K8s_v1.8: [5.1.3, 5.2.1]` — these are **Policy** controls (section 5), not **Worker Node** controls (section 4). The entry is for containerd configuration which should map to 5.x.x container runtime hardening. However, CIS K8s worker-node section stops at 4.2.x. Either the IDs are wrong (should be 4.x), or the entry should be removed from the K8s benchmark mapping. **Maintainer to decide.**
2. **`CM-002`** (`ansible_role: fips-mode`, title "Write node metadata marker") — the role assignment seems inconsistent. A "node metadata marker for audit trail" is a SOC 2 CC8.1 change management artifact but is implemented in the `fips-mode` role's main.yml. This may confuse future auditors expecting SOC 2 controls to live in the `soc2-cc6-cc7-cc8` role. **Maintainer to decide if this should move.**

---

## Items deferred to maintainer

1. **`compliance/references/cis-al2023-l2-toc.md`**: Stub created. Maintainer to populate with actual CIS AL2023 Level 2 TOC (requires free registration at cisecurity.org).
2. **BDDK/KVKK overlays**: Both are draft scaffolds. Legal review required before use in any compliance submission. Do NOT add `bddk-iybt` or `kvkk` to `frameworks:` list in control-mappings.yaml until legally reviewed.
3. **Go compilation**: `tabya-attest/` scaffold not compile-verified. Run `cd tabya-attest && go build ./... && go vet ./...` to confirm.
4. **Phase 3 verifier audit**: 22 `review-yaml` calls deferred — run in next session.
5. **BDDK overlay — Article reference accuracy**: The BDDK İYBT 2020-9 article numbers in `bddk-iybt.yaml` are based on general knowledge of the regulation. Before using in any submission, verify article numbers against the official text at https://www.resmigazete.gov.tr/ (Official Gazette, 15 September 2020).

---

## Open questions for the maintainer

1. Should the docs site include `testing-strategy.md`, `launch/blog-outlines.md`, and `launch/show-hn-draft.md` in the nav, or keep them as internal-only files?
2. Should `BDDK` and `KVKK` be added to the `frameworks:` list header in `control-mappings.yaml` now, or only after legal review?
3. The Tabya Attest CLI scaffold — should this live in a separate repo (`github.com/tabyaos/tabya-attest`) eventually? The current location (`tabya-attest/` in the monorepo) is convenient for scaffolding but the BSL 1.1 license boundary may differ for a CLI vs. the OS image.
4. `K8S-005` CIS IDs — keep, fix to correct 4.x IDs, or remove K8s benchmark mapping?

---

## Counts

| Metric | Value |
|--------|-------|
| Controls added to control-mappings.yaml | 26 (48 → 74) |
| New files created | 17 |
| Files modified | 9 |
| Lines added | 2,484 |
| Lines changed (removals) | 12 |
| local-ai.py invocations | 3 (2 × expand-control, 1 × ask deep) |
| Model call failures (garbage output) | 1 (deep model for BDDK overlay — wrote manually instead) |

---

## Test results

| Test | Result |
|------|--------|
| `mkdocs build --strict` | ✅ PASS |
| Molecule (11 roles) | ⏭ Not run locally — no Ansible changes; CI result still valid |
| `just test-kind` | ⏭ Not run locally — no relevant changes |
| `go build ./...` | ⏭ Go not installed; requires maintainer verification |
| `python3 -c "yaml.safe_load(...)"` on all new YAML | ✅ PASS |

---

## Recommended next steps

1. **Verify Go compilation**: `cd tabya-attest && go mod tidy && go build ./... && go vet ./...`
2. **Review and merge**: Check `overnight/2026-04-28-bbatch` PR, particularly CLAUDE.md additions and BDDK/KVKK overlay legal flags.
3. **Run Phase 3 verifier audit**: 22 `review-yaml` calls in next session; findings go to BUILD_LOG.md for maintainer review.
4. **Prepare for DC operator meeting**: Use `docs/partnerships/tabya-x-dc-partnership-template.md` and `docs/launch/tabya-one-pager.md`.
5. **Share sovereignty.md link** with the DC operator prospect as technical background.

---

## Stop reason

Session context limit (user notified: 57 min remaining when limit was 57 min). Work was stopped cleanly at Phase 6 after completing Phases 1, 2, 4, and 5. Phase 3 deferred.
