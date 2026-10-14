#!/usr/bin/env bash
# Pre-flight checklist for Part 1 / Part 2 demos (no Ansible).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
ok=0
fail=0

check() {
  local desc="$1"
  shift
  if "$@"; then
    echo "OK   — $desc"
    ok=$((ok + 1))
  else
    echo "FAIL — $desc"
    fail=$((fail + 1))
  fi
}

echo "Fedora Lane RHEL pilot — demo checklist"
echo "Repo: $ROOT"
echo

check "Image Builder blueprint present" test -f "$ROOT/solution/image-builder/fl-rhel-baseline.toml"
check "Kickstart sample present" test -f "$ROOT/solution/kickstart/fl-rhel-baseline.ks"
check "Day-2 runbook present" test -f "$ROOT/docs/runbook-rhel-day2.md"
check "Solution overview present" test -f "$ROOT/docs/solution-overview.md"
check "Inventory-sync app present" test -f "$ROOT/solution/inventory-sync/app/main.py"

if command -v python3 >/dev/null 2>&1; then
  check "Python 3 available for local API demo" true
else
  check "Python 3 available for local API demo" false
fi

echo
echo "Summary: $ok passed, $fail failed"
exit "$fail"
