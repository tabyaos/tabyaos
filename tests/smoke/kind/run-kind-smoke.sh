#!/usr/bin/env bash
# TabyaOS kind smoke test.
# Creates a 1-node kind cluster, runs kube-bench + the standard smoke workload,
# collects results, then tears down the cluster.
#
# Usage:
#   ./tests/smoke/kind/run-kind-smoke.sh [--keep-cluster] [--node-image <img>]
#
# Options:
#   --keep-cluster   Don't delete the kind cluster after the run (useful for debugging).
#   --node-image     Use a custom kind node image (e.g. a locally-loaded hardened image).
#   --results-dir    Where to write JSON results (default: tests/kube-bench/baseline/).
#
# Prerequisites: kind, kubectl, docker

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
RESULTS_DIR="${REPO_ROOT}/tests/kube-bench/baseline"
KEEP_CLUSTER=false
NODE_IMAGE=""
CLUSTER_NAME="tabyaos-smoke"
TIMEOUT=300

PASS=0; FAIL=0

pass() { echo "  PASS  $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL  $1"; FAIL=$((FAIL + 1)); }
header() { echo ""; echo "── $1 ──"; }

while [[ $# -gt 0 ]]; do
  case $1 in
    --keep-cluster) KEEP_CLUSTER=true; shift ;;
    --node-image)   NODE_IMAGE="$2"; shift 2 ;;
    --results-dir)  RESULTS_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Prereq check ───────────────────────────────────────────────────────────────
for cmd in kind kubectl docker; do
  if ! command -v "$cmd" &>/dev/null; then
    echo "ERROR: $cmd is required but not found in PATH"
    exit 1
  fi
done

mkdir -p "${RESULTS_DIR}" /tmp/tabyaos-kind-results

cleanup() {
  if [[ "${KEEP_CLUSTER}" == "false" ]]; then
    echo ""
    echo "── Cleanup: deleting kind cluster '${CLUSTER_NAME}' ──"
    kind delete cluster --name "${CLUSTER_NAME}" 2>/dev/null || true
  else
    echo ""
    echo "── Cluster '${CLUSTER_NAME}' retained (--keep-cluster). Delete with: kind delete cluster --name ${CLUSTER_NAME} ──"
  fi
}
trap cleanup EXIT

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"

echo "=== TabyaOS kind smoke test: ${TIMESTAMP} ==="
echo "Cluster    : ${CLUSTER_NAME}"
echo "Results    : ${RESULTS_DIR}"
[[ -n "${NODE_IMAGE}" ]] && echo "Node image : ${NODE_IMAGE}"
echo ""

# ── 1. Create kind cluster ────────────────────────────────────────────────────
header "1. Create kind cluster"

CONFIG_ARGS=(--config "${SCRIPT_DIR}/kind-config.yaml")
[[ -n "${NODE_IMAGE}" ]] && CONFIG_ARGS+=(--image "${NODE_IMAGE}")

# Delete any stale cluster with same name.
kind delete cluster --name "${CLUSTER_NAME}" 2>/dev/null || true

if kind create cluster --name "${CLUSTER_NAME}" "${CONFIG_ARGS[@]}"; then
  pass "kind cluster '${CLUSTER_NAME}' created"
else
  fail "kind cluster creation failed"
  exit 1
fi

# ── 2. Wait for node ready ────────────────────────────────────────────────────
header "2. Node readiness"
if kubectl wait node \
     --all \
     --for=condition=Ready \
     --timeout="${TIMEOUT}s" 2>/dev/null; then
  NODES=$(kubectl get nodes --no-headers | wc -l)
  pass "${NODES} node(s) Ready"
else
  fail "Node(s) did not reach Ready within ${TIMEOUT}s"
fi

# ── 3. kube-bench ─────────────────────────────────────────────────────────────
header "3. kube-bench (cis-1.8 benchmark)"
kubectl apply -f "${SCRIPT_DIR}/kube-bench-job.yaml"

if kubectl -n kube-system wait \
     --for=condition=complete \
     job/kube-bench-kind \
     --timeout="${TIMEOUT}s" 2>/dev/null; then
  pass "kube-bench job completed"

  BENCH_RESULTS="${RESULTS_DIR}/${TIMESTAMP}-kind.json"
  kubectl -n kube-system logs job/kube-bench-kind > "${BENCH_RESULTS}" 2>/dev/null || true
  echo "  Results: ${BENCH_RESULTS}"

  if command -v jq &>/dev/null; then
    BENCH_FAIL=$(jq -r '
      .Controls[]?.tests[]?.results[]? |
      select(.status == "FAIL") | .test_number
    ' "${BENCH_RESULTS}" 2>/dev/null | wc -l | tr -d ' ')
    BENCH_PASS=$(jq -r '
      .Controls[]?.tests[]?.results[]? |
      select(.status == "PASS") | .test_number
    ' "${BENCH_RESULTS}" 2>/dev/null | wc -l | tr -d ' ')
    echo "  kube-bench: ${BENCH_PASS} PASS / ${BENCH_FAIL} FAIL"
  fi
else
  fail "kube-bench job did not complete within ${TIMEOUT}s"
  kubectl -n kube-system describe job/kube-bench-kind 2>/dev/null || true
fi

kubectl -n kube-system delete job kube-bench-kind --ignore-not-found 2>/dev/null || true

# ── 4. Workload smoke test ─────────────────────────────────────────────────────
header "4. Workload smoke (delegates to smoke-test.sh)"
chmod +x "${SCRIPT_DIR}/../smoke-test.sh"
if TABYAOS_SMOKE_NS="tabyaos-kind-${TIMESTAMP}" "${SCRIPT_DIR}/../smoke-test.sh"; then
  pass "Workload smoke test passed"
else
  fail "Workload smoke test failed"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "=== kind smoke test summary ==="
echo "PASS: ${PASS}"
echo "FAIL: ${FAIL}"
echo ""
[[ "${FAIL}" -gt 0 ]] && { echo "RESULT: FAILED"; exit 1; }
echo "RESULT: ALL PASSED"
