#!/usr/bin/env bash
# TabyaOS k3d smoke test — kube-bench via k3s/k3d (Docker Desktop compatible).
# k3d does not require cgroup nesting, so it works on Docker Desktop for Windows.
#
# Prerequisites: k3d, kubectl, docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Allow override via env var — needed when script is copied to /tmp (BASH_SOURCE != repo)
REPO_ROOT="${REPO_ROOT:-$(cd "${SCRIPT_DIR}/../../.." && pwd)}"
RESULTS_DIR="${REPO_ROOT}/tests/kube-bench/baseline"
KEEP_CLUSTER=false
CLUSTER_NAME="tabyaos-smoke"
TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

PASS=0; FAIL=0
# ((PASS++)) returns exit 1 when PASS=0 (arithmetic false) — breaks set -e
pass() { echo "  PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL  $1"; FAIL=$((FAIL + 1)); }

while [[ $# -gt 0 ]]; do
  case $1 in
    --keep-cluster) KEEP_CLUSTER=true; shift ;;
    --results-dir)  RESULTS_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

cleanup() {
  if [[ "${KEEP_CLUSTER}" == "false" ]]; then
    echo "── Cleanup: deleting k3d cluster '${CLUSTER_NAME}' ──"
    k3d cluster delete "${CLUSTER_NAME}" 2>/dev/null || true
  fi
}
trap cleanup EXIT

mkdir -p "${RESULTS_DIR}"

echo "=== TabyaOS k3d smoke test: ${TIMESTAMP} ==="
echo "Cluster : ${CLUSTER_NAME}"
echo "Results : ${RESULTS_DIR}"
echo ""

# ── 1. Create k3d cluster ──────────────────────────────────────────────────────
echo "── 1. Create k3d cluster ──"
k3d cluster delete "${CLUSTER_NAME}" 2>/dev/null || true

if k3d cluster create "${CLUSTER_NAME}" --agents 0 --servers 1 --api-port 6443 --wait; then
  pass "k3d cluster '${CLUSTER_NAME}' created"
else
  fail "k3d cluster creation failed"; exit 1
fi

# k3d automatically updates ~/.kube/config on cluster creation — no manual
# kubeconfig patching needed. The API server is exposed on host.docker.internal
# when --api-port is specified.

# ── 2. Node ready ──────────────────────────────────────────────────────────────
echo "── 2. Node readiness ──"
if kubectl wait node --all --for=condition=Ready --timeout=120s 2>/dev/null; then
  pass "node(s) Ready"
else
  fail "node(s) did not reach Ready"; exit 1
fi

# ── 3. kube-bench ─────────────────────────────────────────────────────────────
echo "── 3. kube-bench (CIS Kubernetes Benchmark) ──"
kubectl apply -f "${REPO_ROOT}/tests/smoke/kind/kube-bench-job.yaml"

if kubectl -n kube-system wait \
     --for=condition=complete \
     job/kube-bench-kind \
     --timeout=120s 2>/dev/null; then
  pass "kube-bench job completed"
else
  fail "kube-bench job did not complete"; exit 1
fi

BENCH_RESULTS="${RESULTS_DIR}/${TIMESTAMP}-k3d.json"
kubectl -n kube-system logs job/kube-bench-kind > "${BENCH_RESULTS}" 2>/dev/null || true

if [[ -s "${BENCH_RESULTS}" ]]; then
  FAIL_COUNT=$(grep -c '"status": "FAIL"' "${BENCH_RESULTS}" 2>/dev/null || echo 0)
  PASS_COUNT=$(grep -c '"status": "PASS"' "${BENCH_RESULTS}" 2>/dev/null || echo 0)
  TOTAL=$((FAIL_COUNT + PASS_COUNT))
  if [[ ${TOTAL} -gt 0 ]]; then
    PASS_RATE=$(( (PASS_COUNT * 100) / TOTAL ))
    echo "  kube-bench: ${PASS_COUNT}/${TOTAL} PASS (${PASS_RATE}%)"
    [[ ${PASS_RATE} -ge 50 ]] && pass "kube-bench ≥50% baseline" || fail "kube-bench <50%"
  fi
  pass "kube-bench results saved to ${BENCH_RESULTS}"
fi

echo ""
echo "── Results ──"
echo "  PASS: ${PASS}  FAIL: ${FAIL}"
[[ ${FAIL} -eq 0 ]] && echo "All checks passed." || exit 1
