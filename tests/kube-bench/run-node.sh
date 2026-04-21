#!/usr/bin/env bash
# Run kube-bench directly on a node (via SSH or SSM) and save results.
# Usage:
#   ./tests/kube-bench/run-node.sh [--json] [--ssm <instance-id>] [--output <file>]
#
# Prerequisites on the target node:
#   - kube-bench binary at /usr/local/bin/kube-bench  OR
#   - Docker / containerd available (will use aquasec/kube-bench image)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASELINE_DIR="${SCRIPT_DIR}/baseline"
OUTPUT_FORMAT="text"
OUTPUT_FILE=""
SSM_INSTANCE_ID=""
BENCHMARK="eks-1.4.0"

usage() {
  cat <<EOF
Usage: $0 [options]

Options:
  --json                   Output JSON instead of human-readable text
  --ssm <instance-id>      Run via AWS SSM Session Manager (no SSH needed)
  --output <file>          Write output to file (default: baseline/TIMESTAMP.txt)
  --benchmark <name>       kube-bench benchmark name (default: eks-1.4.0)
  -h, --help               Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --json)       OUTPUT_FORMAT="json"; shift ;;
    --ssm)        SSM_INSTANCE_ID="$2"; shift 2 ;;
    --output)     OUTPUT_FILE="$2"; shift 2 ;;
    --benchmark)  BENCHMARK="$2"; shift 2 ;;
    -h|--help)    usage; exit 0 ;;
    *)            echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
if [[ -z "${OUTPUT_FILE}" ]]; then
  EXT="${OUTPUT_FORMAT}"
  OUTPUT_FILE="${BASELINE_DIR}/${TIMESTAMP}-node.${EXT}"
fi

mkdir -p "${BASELINE_DIR}"

BENCH_CMD="kube-bench run --targets=node --benchmark=${BENCHMARK}"
[[ "${OUTPUT_FORMAT}" == "json" ]] && BENCH_CMD+=" --json"

run_local() {
  if command -v kube-bench &>/dev/null; then
    sudo ${BENCH_CMD} | tee "${OUTPUT_FILE}"
  elif command -v docker &>/dev/null; then
    docker run --rm \
      --pid=host \
      -v /etc:/etc:ro \
      -v /var:/var:ro \
      -v /usr/bin:/usr/local/mount-from-host/bin:ro \
      aquasec/kube-bench:latest \
      ${BENCH_CMD} | tee "${OUTPUT_FILE}"
  else
    echo "ERROR: Neither kube-bench binary nor docker found on this node." >&2
    exit 1
  fi
}

run_via_ssm() {
  local instance_id="$1"
  echo "Running kube-bench via SSM on ${instance_id}..."
  aws ssm start-session \
    --target "${instance_id}" \
    --document-name "AWS-RunShellScript" \
    --parameters "commands=[\"${BENCH_CMD}\"]" \
    --output text | tee "${OUTPUT_FILE}"
}

echo "=== TabyaOS kube-bench run: ${TIMESTAMP} ==="
echo "Benchmark : ${BENCHMARK}"
echo "Format    : ${OUTPUT_FORMAT}"
echo "Output    : ${OUTPUT_FILE}"
echo ""

if [[ -n "${SSM_INSTANCE_ID}" ]]; then
  run_via_ssm "${SSM_INSTANCE_ID}"
else
  run_local
fi

echo ""
echo "Results saved to: ${OUTPUT_FILE}"

# Summarise PASS/FAIL counts from JSON output for quick review.
if [[ "${OUTPUT_FORMAT}" == "json" ]] && command -v jq &>/dev/null; then
  echo ""
  echo "=== Summary ==="
  jq -r '
    .Controls[]?.tests[]?.results[]? |
    select(.status != null) |
    .status
  ' "${OUTPUT_FILE}" | sort | uniq -c | sort -rn
fi
