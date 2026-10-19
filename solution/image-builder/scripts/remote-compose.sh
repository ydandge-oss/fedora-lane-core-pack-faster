#!/usr/bin/env bash
# Copy Image Builder assets to a RHEL 10 builder VM and start compose.
#
# Usage:
#   ./scripts/remote-compose.sh user@builder-host ami
#   ./scripts/remote-compose.sh user@builder-host vhd
#   ./scripts/remote-compose.sh user@builder-host qcow2
#
# Requires: SSH access to a subscribed RHEL 10 host (RHDP / lab).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-}"
IMAGE_TYPE="${2:-qcow2}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 user@rhel10-builder <ami|vhd|qcow2>"
  echo
  echo "This Mac cannot run RHEL Image Builder. Provision a subscribed RHEL 10 VM"
  echo "(e.g. RHDP), then re-run with SSH target."
  exit 1
fi

if grep -q 'AAAREPLACE_WITH_REAL_PUBLIC_KEY' "$ROOT/fl-rhel-gold.toml" 2>/dev/null; then
  echo "ERROR: Replace SSH public keys in fl-rhel-gold.toml first."
  exit 1
fi

REMOTE_DIR="~/fedora-lane-image-builder"

echo "=== Syncing blueprint + scripts to $TARGET:$REMOTE_DIR ==="
ssh "$TARGET" "mkdir -p $REMOTE_DIR"
rsync -az --delete \
  --exclude 'output/' \
  --exclude '*.qcow2' \
  --exclude '*.ami' \
  --exclude '*.vhd' \
  --exclude '*.raw' \
  "$ROOT/" "$TARGET:$REMOTE_DIR/"

echo "=== Installing Image Builder + composing $IMAGE_TYPE (long running) ==="
ssh -t "$TARGET" "bash -lc '
  set -euo pipefail
  cd $REMOTE_DIR
  sudo ./scripts/install-image-builder.sh
  sudo ./scripts/compose.sh $IMAGE_TYPE
  echo
  echo Compose artifacts:
  ls -lh ./*.$IMAGE_TYPE ./*.raw ./*.qcow2 2>/dev/null || ls -lh
'"

echo
echo "Done. Pull artifact with:"
echo "  scp '$TARGET:$REMOTE_DIR/*.$IMAGE_TYPE' ./output/"
