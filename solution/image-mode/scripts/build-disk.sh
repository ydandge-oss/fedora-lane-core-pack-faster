#!/usr/bin/env bash
# Convert bootc OCI image → disk using local bootc-image-builder (not hosted service)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TYPE="${1:-qcow2}"   # qcow2 | raw | ami
TAG="${FL_BOOTC_TAG:-localhost/fl-rhel10-bootc-gold:latest}"
OUT="${FL_BIB_OUT:-$ROOT/output}"
BIB_IMAGE="${FL_BIB_IMAGE:-quay.io/centos-bootc/bootc-image-builder:latest}"
CONFIG="$ROOT/bib-config.toml"

mkdir -p "$OUT"

case "$TYPE" in
  qcow2|raw|ami) ;;
  *)
    echo "Usage: $0 [qcow2|raw|ami]"
    exit 1
    ;;
esac

echo "[image-mode] Converting $TAG → type=$TYPE"
echo "[image-mode] Output dir: $OUT"
echo "[image-mode] Using local BIB container: $BIB_IMAGE"

# Local privileged convert — this is NOT console.redhat.com hosted Image Builder
sudo podman run --rm -it --privileged --pull=newer \
  -v "$OUT:/output" \
  -v "$CONFIG:/config.toml:ro" \
  --security-opt label=type:unconfined_t \
  "$BIB_IMAGE" \
  --type "$TYPE" \
  --config /config.toml \
  "$TAG"

echo "[image-mode] Done. Artifacts under $OUT"
echo "[image-mode] Upload/import to AWS or Azure Blank OPEN — see docs/poc-steps-image-mode.md"
