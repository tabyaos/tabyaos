#!/usr/bin/env bash
# Compare two kube-bench JSON result files and show regressions / improvements.
# Usage: ./compare-baseline.sh <before.json> <after.json>
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <before.json> <after.json>"
  exit 1
fi

BEFORE="$1"
AFTER="$2"

command -v jq &>/dev/null || { echo "jq is required"; exit 1; }

extract_results() {
  local file="$1"
  jq -r '
    .Controls[]?.tests[]?.results[]? |
    select(.test_number != null) |
    "\(.test_number)\t\(.status)\t\(.test_desc)"
  ' "${file}"
}

echo "=== kube-bench delta: ${BEFORE} → ${AFTER} ==="
echo ""

BEFORE_TMP="$(mktemp)"
AFTER_TMP="$(mktemp)"
trap 'rm -f "${BEFORE_TMP}" "${AFTER_TMP}"' EXIT

extract_results "${BEFORE}" | sort > "${BEFORE_TMP}"
extract_results "${AFTER}"  | sort > "${AFTER_TMP}"

echo "--- REGRESSIONS (was PASS, now FAIL) ---"
comm -23 \
  <(grep $'\tPASS\t' "${BEFORE_TMP}" | awk -F'\t' '{print $1}') \
  <(grep $'\tPASS\t' "${AFTER_TMP}"  | awk -F'\t' '{print $1}') \
| while read -r test_id; do
    desc="$(grep "^${test_id}"$'\t' "${BEFORE_TMP}" | awk -F'\t' '{print $3}')"
    echo "  REGRESSION  ${test_id}  ${desc}"
  done

echo ""
echo "--- IMPROVEMENTS (was FAIL/WARN, now PASS) ---"
comm -13 \
  <(grep $'\tPASS\t' "${BEFORE_TMP}" | awk -F'\t' '{print $1}') \
  <(grep $'\tPASS\t' "${AFTER_TMP}"  | awk -F'\t' '{print $1}') \
| while read -r test_id; do
    desc="$(grep "^${test_id}"$'\t' "${AFTER_TMP}" | awk -F'\t' '{print $3}')"
    echo "  FIX          ${test_id}  ${desc}"
  done

echo ""
echo "--- TOTALS ---"
echo "Before: $(grep -c $'\tPASS\t' "${BEFORE_TMP}" || true) PASS / $(grep -c $'\tFAIL\t' "${BEFORE_TMP}" || true) FAIL / $(grep -c $'\tWARN\t' "${BEFORE_TMP}" || true) WARN"
echo "After:  $(grep -c $'\tPASS\t' "${AFTER_TMP}"  || true) PASS / $(grep -c $'\tFAIL\t' "${AFTER_TMP}"  || true) FAIL / $(grep -c $'\tWARN\t' "${AFTER_TMP}"  || true) WARN"
