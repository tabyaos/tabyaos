# Blog Post Outlines — TabyaOS Launch

Target: publish post #3 alongside Show HN. Posts #1 and #2 in the weeks after.

---

## Post 1: How we hardened 11 Ansible roles for PCI-DSS v4.0 on Kubernetes worker nodes

**Audience:** DevOps / platform engineers implementing compliance hardening
**Where:** tabya.io/blog or dev.to

1. Molecule testing patterns — Docker driver, amazonlinux:2023, converge + idempotence + verify pipeline
2. `manage_services` variable — gating service tasks for Docker-based unit tests without systemd
3. Idempotency fixes — `force: false` on copy, `b64decode` content assertions in verify.yml, `((PASS++))` set -e trap
4. PCI-DSS v4.0 mapping — tracing each Ansible task comment to a named framework requirement
5. Kubernetes-specific trade-offs — `ip_forward=1` for CNI despite CIS recommendation, sysctl format quirks

---

## Post 2: CIS Benchmark Level 2 on Amazon Linux 2023: what actually breaks

**Audience:** Security engineers implementing CIS on AL2023/EKS
**Where:** tabya.io/blog

1. `ip_forward` conflict — K8s CNI needs 1, CIS says 0. Solution: separate sysctl file for K8s overrides
2. ASLR sysctl format — `ansible.posix.sysctl` writes `key = value` (spaces), `grep key=value` fails. Always check both formats
3. `grep -c` with `set -e` — exit code 1 on no-match with `-c` still prints 0 but returns non-zero. The `|| echo 0` double-output trap
4. `((PASS++))` with `set -euo pipefail` — arithmetic false when var=0 exits shell silently
5. Real trade-offs — when and why to deviate from CIS L2 for production K8s

---

## Post 3: Every node, a redoubt — why we open-sourced a hardened K8s OS image

**Audience:** CISOs, compliance leads, fintech platform leads — Show HN companion
**Where:** tabya.io/blog (publish same day as Show HN)

1. The 40-hour audit problem — what it actually costs to produce worker-node compliance evidence per cycle
2. Why existing tools don't solve it — Bottlerocket is locked-down runtime, Chainguard is distroless, neither gives you PCI evidence
3. What TabyaOS is — Ansible roles + Packer + Molecule + signed releases. Every control traceable
4. BSL 1.1 model — free to use, not free to compete. Converts to Apache 2.0 in 4 years
5. What comes next — enterprise support tier, attestation pack, RHEL 9 / Debian 12 parity, AWS Marketplace
