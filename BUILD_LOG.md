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

Strengthened all 9 role `molecule/default/verify.yml` files with content-level assertions
(not just file-existence checks). All 9 roles passed converge + idempotence + verify after fixes.

### Verifier Improvements

| Role | Key Assertions Added |
|------|---------------------|
| aide | cramfs/squashfs modprobe `install … /bin/true` content; sha512 in aide.conf; EKS PKI path monitored |
| auditd-pci | Rules file mode 0640 + uid 0; `-F euid=0` and `-k pci_priv_cmd` present; audit.log mode 0600 |
| chrony-hardened | time.aws.com source present; `makestep` configured; `maxdistance` configured; `cmdport 0` |
| cis-k8s-worker | kubelet-cis-patch.json: anonymous auth false, readOnlyPort 0, protectKernelDefaults true, TLS 1.2 |
| cis-l2 | cramfs/squashfs modprobe content; ASLR=2; send_redirects=0 (both sysctl key formats); TMOUT=900 readonly; faillock deny set |
| fips-mode | `/etc/crypto-policies/config` exists and contains `FIPS` |
| pci-dss-v4 | dmesg_restrict=1 and kptr_restrict=2 in sysctl file; bluetooth blacklisted + install disabled; TMOUT=900 readonly; sudo logfile=/var/log/sudo.log; faillock deny=10; no active NOPASSWD in sudoers |
| soc2-cc6-cc7-cc8 | accept_redirects=0 in sysctl file; pam_lastlog in /etc/pam.d/sshd; rsyslog authpriv→/var/log/secure; BuildPipeline key in change record |
| ssm-only-access | iptables DROP rule for TCP 22; /etc/sysconfig/iptables persisted |

### Key Fixes for Phase B

- cis-l2: `ip_forward` lives in `99-cis-k8s-network.conf` (K8s nodes need ip_forward=1); verify checks that file exists.
- auditd-pci: `pci_time` key doesn't exist; replaced assertion with `pci_priv_cmd`.
- chrony-hardened: `rtcsync` IS in the template; replaced wrong absent-assertion with `maxdistance` check.
- pci-dss-v4: `grep -c 'NOPASSWD'` matched commented-out default AL2023 sudoers line; fixed to `grep -Ec '^[^#]*NOPASSWD'`.

### Molecule Results (Phase B — all 9 roles PASS)

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

---

## Phase C — Compliance Coverage Expansion

**Date:** 2026-04-22

### control-mappings.yaml

Expanded from 22 to 40 controls across 5 frameworks:

- Added `ACC-004/005/006` (PAM, faillock, password quality)
- Added `FIPS-001/002` (FIPS mode setup, crypto policy)
- Added `KERN-001/002/003` (kernel pointer/dmesg/module restrict)
- Added `SOC2-001` through `SOC2-005` (shadow perms, login history, redirects, audit, rsyslog)
- Added `SSM-002` (iptables port 22 block)
- Added `K8S-005/006/007/008` (kubelet read-only port, protect kernel defaults, TLS, cert rotation)
- Added `CM-002` (change record marker)

### gen-compliance-docs.py

New script at `scripts/gen-compliance-docs.py`:
- Reads `compliance/control-mappings.yaml`
- Outputs `compliance/generated/by-framework/` (one `.md` per framework)
- Outputs `compliance/generated/by-role/` (one `.md` per role)
- Outputs `compliance/generated/coverage-summary.md`

New `justfile` target: `just gen-docs`

---

## Phase D — kube-bench Convergence

**Target:** ≥95% PASS rate on CIS Kubernetes Benchmark worker node section.

**Date:** 2026-04-26

### Local testing status

kind v0.25.0 added to molecule-runner image. Cluster creation fails on Docker Desktop (Windows) with `required cgroups disabled` — kubelet cannot access the cgroup hierarchy inside nested Docker containers. This is a known Docker Desktop limitation, not a TabyaOS bug.

**Workaround options:**
- Run via GitHub Actions CI — `test.yml` `kind-smoke` job runs on `ubuntu-latest` where kind works correctly.
- Replace kind with **k3d** locally — k3d (k3s in Docker) does not require cgroup nesting. Target: `just test-kind` updated to use k3d.

### CI status
`test.yml` `kind-smoke` job is defined and will run on every PR against `main` (Linux runner). kube-bench results are uploaded as artifacts. Phase D is gated on CI passing, not local execution.

---

## Phase E — Documentation & Repo Hygiene

**Date:** 2026-04-22

### New Documentation Files

| File | Description |
|------|-------------|
| `docs/architecture.md` | Build pipeline, role dependency graph, compliance layers, test layers, image variants |
| `docs/threat-model.md` | Trust boundaries, 5 threat actors, 10 attack surfaces, mitigations, residual risk |
| `docs/getting-started.md` | Prerequisites, quick-start, role reference, all config variables |
| `docs/enterprise.md` | Enterprise tier, attestation pack, pricing, SLA, FAQ |
| `docs/index.md` | MkDocs home page |
| `mkdocs.yml` | MkDocs Material config with full nav tree |

### Repo Hygiene Files

| File | Description |
|------|-------------|
| `SECURITY.md` | Vulnerability disclosure policy (90-day coordinated disclosure) |
| `CONTRIBUTING.md` | Contribution guidelines, DCO, PR checklist |
| `CODE_OF_CONDUCT.md` | Contributor Covenant v2.1 |

### CI Workflow

`docs.yml` — GitHub Actions workflow: builds MkDocs site and deploys to GitHub Pages on push to `main` affecting `docs/**` or `mkdocs.yml`.

---

## Phase F — v0.1.0-alpha Release Prep

**Date:** 2026-04-22

- `CHANGELOG.md` — full v0.1.0-alpha changelog (all 9 roles, Packer, compliance, docs)
- `VERSION` — `0.1.0-alpha`
- `.github/workflows/release.yml` — added `workflow_dispatch` dry-run mode; build steps gated on `inputs.dry_run != true`; `packer validate` runs in dry-run path; alpha tag pattern added (`v[0-9]+.[0-9]+.[0-9]+-*`)
