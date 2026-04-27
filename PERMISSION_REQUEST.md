# Overnight Permission Request — 2026-04-28

The following actions are requested for tonight's autonomous run.
Approve by replacing each `[]` with `[x]` before going to sleep.
Sign at the bottom. I will not begin Phase 1 until the signature line is filled.

---

## Branch operations

- [x] Create branch `overnight/2026-04-28-bbatch` from `build-out/v0.1.0-alpha` (current HEAD: `41157f9`)
- [x] Push branch `overnight/2026-04-28-bbatch` to `origin` only — never `main`, never force-push

---

## File modifications — existing files

- [x] Modify `CLAUDE.md` — add "Strategic positioning (updated 2026-04-28)" section: on-prem pivot, Tabya parent-company framing, BDDK/KVKK/DORA overlays planned, updated kill criteria
- [x] Modify `README.md` — re-order artifact formats (QCOW2, ISO, OCI, AMI) + data-sovereignty sentence
- [x] Expand `compliance/control-mappings.yaml` — additions only, no edits to existing 48 entries; target ~80–96 controls via `local-ai.py expand-control`

---

## File creations — docs

- [x] Create `docs/sovereignty.md` — 800–1200 word technical doc: BDDK İYBT 2020-9, KVKK, DORA, artifact format mapping to sovereign infra, threat model
- [x] Create `docs/partnerships/tabya-x-dc-partnership-template.md` — 2-page partnership proposal template (resell / co-sell / design-partner models)
- [x] Create `docs/launch/tabya-one-pager.md` — 1-pager for design-partner conversations (pricing tiers, artifact formats, compliance frameworks)
- [x] Modify `docs/index.md` (if on-prem messaging update needed after reading)
- [x] Modify `docs/getting-started.md` (if on-prem first-step needs updating)
- [x] Modify `docs/enterprise.md` (if Tabya parent-company positioning needs updating)

---

## File creations — compliance overlays

- [x] Create `compliance/overlays/` directory
- [x] Create `compliance/overlays/bddk-iybt.yaml` — scaffold only; every entry marked `# REQUIRES_LEGAL_REVIEW: true`; drafted via `local-ai.py ask deep`; **no certification claims anywhere in docs**
- [x] Create `compliance/overlays/kvkk.yaml` — same constraints as above

---

## File creations — Tabya Attest CLI scaffold

- [x] Create `tabya-attest/` directory with Go 1.22 module scaffold:
  - `go.mod` (module `github.com/tabyaos/tabya-attest`)
  - `main.go` (cobra entrypoint)
  - `cmd/root.go`, `cmd/attest.go`, `cmd/version.go`
  - `internal/runner/kubebench.go` (stub)
  - `internal/runner/inspec.go` (stub)
  - `internal/bundle/cosign.go` (stub)
  - `README.md`
  - `Makefile`
  - `.golangci.yml`
- [x] Run `go build ./...` and `go vet ./...` — both must pass before committing

---

## File creations — infra / run management

- [x] Create `BUILD_LOG.md` — updated after each phase
- [x] Create `MORNING_REPORT.md` — written at end of run (or on stop condition)
- [x] Create `compliance/references/cis-al2023-l2-toc.md` stub if the file is missing (stub asks maintainer to fill)

---

## local-ai.py invocations

All calls are local, Ollama-only, no network:

- [x] Up to 60 × `expand-control` calls — model alias `devops` (devstral-small-2:24b); used for compliance control gap-fill
- [x] Up to 22 × `review-yaml` calls — model alias `coder` (qwen2.5-coder:32b); one tasks + one verify per role × 11 roles; **read-only audit, no auto-apply**
- [x] Up to 5 × `ask deep` calls — model alias `deep` (deepseek-coder:33b); used for BDDK/KVKK overlay drafting and sovereignty doc prose assistance
- [x] **Zero** `ask big` calls — "big" alias (gpt-oss:120b) is explicitly forbidden tonight

Estimated GPU runtime: ~3–4 hours on RTX 3090.

---

## Tests to run (local only — no AWS, no network calls)

- [x] `just test-molecule` — all 11 Molecule scenarios (sequential, via Docker runner); must stay green
- [x] `just test-kind` — k3d kube-bench baseline reconfirm; result captured to `tests/kube-bench/baseline/`
- [x] `mkdocs build --strict` — docs site validation; must produce zero errors

If any previously-green test turns red and cannot be fixed in 30 min, I will stop and write to `MORNING_REPORT.md`.

---

## Explicitly forbidden actions (will NOT be performed under any circumstances)

- `packer build` — no AWS API calls, no AMI creation
- `gh release create` or any GitHub release/publish operation
- `git push origin main` — main branch is untouchable
- `gh pr merge` — no auto-merge
- Any `npm publish`, `cargo publish`, `pip publish`, etc.
- Any DNS change or domain registration
- Any email send, Slack message, social media post
- Any AWS API call (EC2, IAM, S3, EKS, etc.)
- Any purchase, subscription, or payment

---

## Rationale summary

| Category | Why needed |
|---|---|
| CLAUDE.md / README.md update | Strategic pivot to on-prem decided today; docs must match |
| `docs/sovereignty.md` | Design-partner conversation with Turkish DC operator imminent; need credible technical framing |
| Partnership template + 1-pager | Maintainer needs materials for follow-up within 1–2 days |
| BDDK/KVKK overlays | Positions TabyaOS for Turkish fintech auditors; scaffolds only, legal-flagged |
| Control-mappings expansion | 48 → ~80+ controls closes documentation gaps without changing Ansible code |
| Tabya Attest scaffold | Next product already decided; creating Go scaffold tonight saves a session tomorrow |
| Verifier audit (read-only) | Quality check — findings go to morning report, maintainer decides fixes |
| Molecule + kind re-run | Confirm nothing broke after CI fixes pushed today |

---

## Sign-off

**Maintainer:** orhanozdogan (replace this line with your name/initials)
**Approved at:** 01:10

> Once you fill in the sign-off lines above and save the file, I will begin Phase 1.
> If this file is unsigned after 30 minutes, I will write MORNING_REPORT.md and stop.
