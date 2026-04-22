#!/usr/bin/env bash
# Run all Molecule scenarios sequentially.
# Sequential (not parallel) to avoid Docker network name conflicts.
set -euo pipefail

ROLES_DIR="${1:-/project/ansible/roles}"
PASS=0
FAIL=0
ERRORS=()

for role_path in $(find "${ROLES_DIR}" -maxdepth 1 -mindepth 1 -type d | sort); do
  role=$(basename "${role_path}")
  scenario="${role_path}/molecule/default/molecule.yml"
  [ -f "${scenario}" ] || continue

  printf "  %-28s" "${role}:"
  if (cd "${role_path}" && molecule test) >/tmp/molecule-"${role}".log 2>&1; then
    echo "PASS"
    PASS=$((PASS + 1))
  else
    echo "FAIL"
    FAIL=$((FAIL + 1))
    ERRORS+=("${role}")
    # Show the first fatal/assertion failure
    grep -m1 -A4 'fatal.*FAILED\|Assertion failed' /tmp/molecule-"${role}".log || \
      tail -10 /tmp/molecule-"${role}".log
  fi
done

echo ""
echo "Results: ${PASS} PASS, ${FAIL} FAIL"
if [ ${FAIL} -gt 0 ]; then
  echo "Failed roles: ${ERRORS[*]}"
  exit 1
fi
