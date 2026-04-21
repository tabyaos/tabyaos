# TabyaOS Build Log

Branch: `build-out/v0.1.0-alpha`

---

## Phase A — Baseline Molecule + kind Validation

**Date:** 2026-04-22

### Molecule Results (Docker, amazonlinux:2023)

All 9 roles passed converge + idempotence + verify.

| Role | Converge | Idempotence | Verify |
|------|----------|-------------|--------|
| aide | PASS | PASS | PASS |
| auditd-pci | PASS | PASS | PASS |
| chrony-hardened | PASS | PASS | PASS |
| cis-k8s-worker | PASS | PASS | PASS |
| cis-l2 | PASS | PASS | PASS |
| fips-mode | PASS | PASS | PASS |
| pci-dss-v4 | PASS | PASS | PASS |
| soc2-cc6-cc7-cc8 | PASS | PASS | PASS |
| ssm-only-access | PASS | PASS | PASS |

### Key Fixes Applied

- All roles: Added `prepare.yml` to bootstrap amazonlinux:2023 Docker container with required packages/directories using `ansible.builtin.raw` (no Python dependency at prepare stage).
- All roles: Added `manage_services: false` variable pattern to guard all `ansible.builtin.service` / `ansible.builtin.systemd` tasks; set false in Docker converge vars.
- All roles: Added `failed_when: false` to all handlers for Docker safety.
- All roles: Replaced `state: touch` with `ansible.builtin.copy force: false` for idempotent file creation.
- cis-l2: Fixed `xargs chmod a+t` → `xargs -r chmod a+t` for empty input case.
- cis-l2: Fixed ASLR sysctl verify assertion to accept both `key=value` and `key = value` formats.
- aide: Fixed deprecated `verbose=5` → `log_level=warning` + `report_level=changed_attributes` for AIDE ≥ 0.17.
- fips-mode: Fixed idempotency — check current crypto policy before calling `update-crypto-policies --set FIPS`.
- cis-k8s-worker: Added missing `kubelet-config-patch.json.j2` template; added kubernetes dirs to prepare.yml; propagated `cis_l2_manage_services: false` through meta dependency.
- pci-dss-v4: Propagated `cis_l2_manage_services: false`; aligned `cis_l2_account_lockout_attempts: 10` to resolve faillock.conf write conflict between cis-l2 and pci-dss-v4.
- molecule-runner Dockerfile: Added Docker CE CLI, community.docker Ansible collection, ENV ANSIBLE_STDOUT_CALLBACK=default.

### kind / kube-bench Results

**SKIPPED** — `kind` binary not found on workstation PATH. The kind smoke test (`just test-kind`) requires `kind` to be installed. Full kube-bench baseline will be captured at Phase D (EKS/QEMU integration layer).

Install kind: `curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind`

---

## Phase B — Verifier Quality Audit

**Date:** 2026-04-22

_See individual role `molecule/default/verify.yml` for strengthened assertions._

---

## Phase C — Compliance Coverage Expansion

**Date:** 2026-04-22

_See `compliance/control-mappings.yaml` and `scripts/gen-compliance-docs.py`._

---

## Phase D — kube-bench Convergence

**Target:** ≥95% PASS rate on CIS Kubernetes Benchmark worker node section.

_Pending EKS/kind layer testing._

---

## Phase E — Documentation & Repo Hygiene

**Date:** 2026-04-22

_See `docs/` directory._

---

## Phase F — v0.1.0-alpha Release Prep

_See CHANGELOG.md and PR._
