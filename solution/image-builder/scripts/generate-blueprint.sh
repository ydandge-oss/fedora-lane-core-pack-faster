#!/usr/bin/env bash
# Merge Expansion Pack blueprint with firstboot script into a compose-ready TOML.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEMPLATE="$ROOT/fl-rhel-gold.blueprint.toml"
OUT="$ROOT/fl-rhel-gold.toml"
FIRSTBOOT="$ROOT/files/fl-gold-firstboot.sh"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Missing $TEMPLATE"
  exit 1
fi
if [[ ! -f "$FIRSTBOOT" ]]; then
  echo "Missing $FIRSTBOOT"
  exit 1
fi

python3 - <<PY
from pathlib import Path
root = Path(r"""$ROOT""")
template = (root / "fl-rhel-gold.blueprint.toml").read_text()
script = (root / "files/fl-gold-firstboot.sh").read_text().rstrip("\n") + "\n"
if '"""' in script:
    raise SystemExit("firstboot script must not contain triple quotes")
out = template.replace("__FIRSTBOOT_SCRIPT__", script)
(root / "fl-rhel-gold.toml").write_text(out)
print(f"Wrote {root / 'fl-rhel-gold.toml'}")
PY
