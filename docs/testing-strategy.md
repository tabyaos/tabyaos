# TabyaOS Testing Strategy

TabyaOS uses a **four-layer testing pyramid**. Each layer catches a different class of failure, runs on different infrastructure, and has a different cost-to-feedback ratio. Layers run sequentially in CI: a failure in an inner layer blocks the outer layers from running.

```
          ┌───────────────────────────────────────────────┐
          │  Layer 4 — EKS (AWS, full end-to-end)         │  slowest, most expensive
          │  nightly + main-branch merges only            │  ~15–30 min, $0.50/run
          ├───────────────────────────────────────────────┤
          │  Layer 3 — kind (local K8s, no AWS)           │  medium speed
          │  every PR + every push to main                │  ~5–10 min, free
          ├───────────────────────────────────────────────┤
          │  Layer 2 — QEMU (full OS, local VM)           │  slow but AWS-free
          │  manual + release tags                        │  ~20–40 min, free
          ├───────────────────────────────────────────────┤
          │  Layer 1 — Molecule (Docker, role unit tests) │  fastest
          │  every PR + every push to main                │  ~2–5 min, free
          └───────────────────────────────────────────────┘
```

---

## Layer 1 — Molecule (Docker, role-level unit tests)

**What it tests:** Individual Ansible role correctness and idempotency inside an `amazonlinux:2023` Docker container.

**What it does NOT test:** Kernel-level operations (SELinux enforcing, FIPS kernel flag, kernel module loading), systemd service state (limited in Docker), AWS-specific bootstrap.

**When it runs:** Every PR, every push to main. Fastest feedback — runs in ~2–5 min per role, 9 roles in parallel.

**Files:**
- `ansible/roles/<role>/molecule/default/` — molecule.yml, converge.yml, verify.yml
- `ci/molecule-runner.dockerfile` — Docker image for Windows local dev

**Running locally:**

```bash
# Linux / macOS (molecule installed natively):
cd ansible/roles/cis-l2
molecule test               # converge + idempotency + verify + cleanup

molecule converge           # apply role only (keep container alive)
molecule verify             # run verify.yml only
molecule login              # SSH into the test container

# All roles in parallel:
just test-molecule

# Windows (molecule runs inside Docker via DooD):
just build-molecule-runner  # build the runner image once
just test-molecule          # uses Docker on Windows
```

**Idempotency check:** Molecule re-runs `converge.yml` after the first apply and asserts zero `changed` tasks. Any task that is not idempotent will fail this check.

**Known Docker limitations per role:**

| Role | Limitation | Validated at |
|------|-----------|-------------|
| `cis-l2` | SELinux `setenforce 1` silently ignored | QEMU / EKS |
| `fips-mode` | `fips-mode-setup --enable` has no effect | QEMU (after reboot) |
| `cis-k8s-worker` | kubelet not installed | EKS |
| `ssm-only-access` | `amazon-ssm-agent` not in container repo | EKS |

---

## Layer 2 — QEMU (full OS, no AWS)

**What it tests:** Complete OS-level hardening on a real AL2023 VM: kernel parameters, SELinux enforcement, FIPS mode, module blacklisting, auditd rules loaded by the kernel, boot-time configuration.

**When it runs:** Manually during development (`just build-qemu`), and triggered by release tags (via the build workflow's QEMU job — to be added in a future PR).

**Files:**
- `packer/al2023/qemu.pkr.hcl` — Packer QEMU builder
- `packer/al2023/qemu-variables.pkr.hcl` — QEMU-specific variables
- `packer/al2023/cloud-init/` — NoCloud seed for SSH bootstrap

**Running locally:**

```bash
# Prerequisites (already installed via Justfile):
#   Windows: QEMU 10.2+ (C:\Program Files\QEMU), added to PATH
#   Linux:   sudo apt install qemu-system-x86 qemu-utils

# 1. Build the QCOW2 image (downloads ~750 MB AL2023 base image on first run):
just build-qemu

# 2. Boot the finished image interactively (serial console):
just boot-qemu
# SSH in: ssh -p 12222 ec2-user@localhost

# 3. To run kube-bench against the QEMU VM:
./tests/kube-bench/run-node.sh \
  --json \
  --output tests/kube-bench/baseline/after-qemu-hardening.json
# (Run from inside the VM via: ssh -p 12222 ec2-user@localhost)
```

**QEMU on Windows notes:**
- Accelerator: QEMU uses WHPX (Windows Hypervisor Platform) on Windows 11.
  Set `qemu_accelerator=whpx` in `vars/al2023.auto.pkrvars.hcl` for best performance.
  Requires: Settings → Windows Features → Windows Hypervisor Platform ✅
- If WHPX is unavailable, falls back to TCG software emulation (~10× slower).
- See [packer/README.md](../packer/README.md) for the full variable reference.

---

## Layer 3 — kind (local Kubernetes, no AWS)

**What it tests:** Cluster-level behaviour: namespace creation, Deployment rollout, NetworkPolicy enforcement, Pod Security Admission rejecting privileged containers, kube-bench CIS 1.8 (kubeadm baseline).

**What it does NOT test:** EKS-specific bootstrap (`/etc/eks/bootstrap.sh`), kubelet EKS configuration, IAM node roles, AWS CNI.

**When it runs:** Every PR, every push to main. Runs after molecule passes.

**Files:**
- `tests/smoke/kind/kind-config.yaml` — 1-node cluster with PSA enabled
- `tests/smoke/kind/kube-bench-job.yaml` — kube-bench Job (cis-1.8 benchmark)
- `tests/smoke/kind/run-kind-smoke.sh` — orchestration script

**Running locally:**

```bash
# Prerequisites (installed):
#   kind v0.31  (added to PATH after new shell)
#   kubectl v1.34 (already present)
#   Docker Desktop

# Run the full kind smoke suite:
just test-kind

# Keep the cluster alive for debugging:
./tests/smoke/kind/run-kind-smoke.sh --keep-cluster

# Load a locally-built Docker node image:
kind load docker-image tabyaos-node:latest --name tabyaos-smoke
./tests/smoke/kind/run-kind-smoke.sh --node-image tabyaos-node:latest
```

---

## Layer 4 — EKS (AWS, full end-to-end)

**What it tests:** Real EKS worker node join (`/etc/eks/bootstrap.sh`), IAM node role, VPC CNI, kubelet EKS configuration, kube-bench `eks-1.4.0` benchmark, full smoke workload against a hardened AMI.

**When it runs:**
- Every merge to `main` (post-kind-smoke gate)
- Nightly cron (02:00 UTC)
- Manual dispatch with `run_eks: true`

**Files:**
- `tests/kube-bench/job.yaml` — kube-bench Job (eks-1.4.0 benchmark)
- `tests/smoke/smoke-test.sh` — workload smoke (nginx + network policy + PSA)
- `.github/workflows/test.yml` — CI orchestration

**Required GitHub Secrets:**

| Secret | Description |
|--------|-------------|
| `AWS_TEST_ROLE_ARN` | IAM role ARN for test runner (OIDC trust to GitHub Actions) |
| `AWS_PACKER_ROLE_ARN` | IAM role ARN for Packer AMI builds |

**Running manually:**

```bash
# Configure AWS credentials first (OIDC or static creds):
export AWS_REGION=us-east-1
aws eks update-kubeconfig --name tabyaos-ci-cluster

# Run kube-bench (in-cluster job):
kubectl apply -f tests/kube-bench/job.yaml
kubectl -n kube-system wait --for=condition=complete job/kube-bench-node --timeout=300s
kubectl -n kube-system logs job/kube-bench-node | tee tests/kube-bench/baseline/manual-eks.json

# Compare against previous baseline:
just kube-bench-diff tests/kube-bench/baseline/before-hardening.json \
                     tests/kube-bench/baseline/manual-eks.json

# Run workload smoke test:
just smoke
```

---

## Compliance scoring targets

| Benchmark | Layer | Target | Blocking |
|-----------|-------|--------|---------|
| molecule idempotency | L1 | 0 changed tasks | ✅ CI blocks |
| CIS AL2023 L2 (file/config checks) | L1 | 100% asserts pass | ✅ CI blocks |
| kind / CIS K8s 1.8 | L3 | 0 critical FAIL | ✅ CI blocks |
| EKS / CIS K8s eks-1.4.0 | L4 | 0 FAIL on 4.2.x | ✅ CI blocks |
| EKS / CIS K8s eks-1.4.0 overall | L4 | ≥ 95% PASS | 📊 tracked, not blocking |

---

## Local tool installation summary (Windows 11)

All required tools are installed and on PATH after running through the setup once:

| Tool | Version | Install method | Status |
|------|---------|---------------|--------|
| Docker Desktop | 29.3.1 | Pre-installed | ✅ |
| kubectl | 1.34.1 | Pre-installed | ✅ |
| QEMU | 10.2.0 | `winget install SoftwareFreedomConservancy.QEMU` | ✅ |
| kind | 0.31.0 | `winget install Kubernetes.kind` | ✅ (new shell) |
| Packer | ≥ 1.10 | `winget install Hashicorp.Packer` | install if missing |
| just | any | `winget install Casey.Just` | install if missing |
| molecule | 6.x | `pip install molecule[docker]` | ✅ (via Docker runner) |
| ansible | 2.17.x | `pip install ansible` | ✅ (via Docker runner) |

> **molecule on Windows:** Python's `fcntl` module is POSIX-only, so molecule cannot run natively on Windows. Use `just build-molecule-runner` + `just test-molecule` to run molecule inside a Docker container that has full POSIX support. CI always runs on Linux (ubuntu-latest) so this is a local-dev-only concern.

> **kind PATH:** kind's binary was installed to `C:\Users\PC\AppData\Local\Microsoft\WinGet\Packages\` — open a **new terminal** after installation for the `kind` alias to be available.

> **QEMU accelerator on Windows 11:** Enable *Windows Hypervisor Platform* in Windows Features (not Hyper-V), then set `qemu_accelerator = "whpx"` in `packer/al2023/vars/al2023.auto.pkrvars.hcl` for hardware-accelerated builds.
