#!/usr/bin/env bash
# Build Fedora Lane RHEL 10 bootc gold OCI image (Image Mode path)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TAG="${FL_BOOTC_TAG:-localhost/fl-rhel10-bootc-gold:latest}"

echo "[image-mode] Building $TAG from $ROOT/Containerfile"
echo "[image-mode] Ensure: podman login registry.redhat.io"

podman build -t "$TAG" -f "$ROOT/Containerfile" "$ROOT"
podman images "$TAG"
echo "[image-mode] Next: ./scripts/build-disk.sh ami|raw|qcow2"
