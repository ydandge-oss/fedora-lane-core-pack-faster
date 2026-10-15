#!/usr/bin/env bash
# Compose Fedora Lane gold image with local RHEL Image Builder (image-builder CLI).
# Doc: https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/
#
# Usage:
#   sudo ./scripts/compose.sh ami          # AWS
#   sudo ./scripts/compose.sh vhd          # Azure
#   sudo ./scripts/compose.sh qcow2        # local/libvirt test
#
# Env (optional):
#   BLUEPRINT=./fl-rhel-gold.toml
#   DISTRO=rhel-10
#   AWS_REGION / AWS_BUCKET / AWS_AMI_NAME  — auto-upload AMI when set
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

IMAGE_TYPE="${1:-}"
if [[ -z "$IMAGE_TYPE" ]]; then
  echo "Usage: $0 <ami|vhd|qcow2|image-installer|...>"
  echo "Supported types: image-builder list"
  exit 1
fi

BLUEPRINT="${BLUEPRINT:-$ROOT/fl-rhel-gold.toml}"
DISTRO="${DISTRO:-rhel-10}"

if [[ ! -f "$BLUEPRINT" ]]; then
  echo "Blueprint missing: $BLUEPRINT"
  echo "Run: ./scripts/generate-blueprint.sh"
  exit 1
fi

if grep -q 'AAAREPLACE_WITH_REAL_PUBLIC_KEY' "$BLUEPRINT"; then
  echo "ERROR: Replace AAAREPLACE_WITH_REAL_PUBLIC_KEY in $BLUEPRINT with your SSH public key(s)."
  exit 1
fi

if ! command -v image-builder >/dev/null 2>&1; then
  echo "Installing image-builder packages..."
  dnf install -y image-builder osbuild osbuild-depsolve-dnf
fi

echo "=== Available image types ==="
image-builder list || true

BUILD_ARGS=(build "$IMAGE_TYPE" --blueprint "$BLUEPRINT" --distro "$DISTRO")

if [[ "$IMAGE_TYPE" == "ami" && -n "${AWS_BUCKET:-}" ]]; then
  BUILD_ARGS+=(
    --aws-region "${AWS_REGION:-us-east-1}"
    --aws-bucket "$AWS_BUCKET"
    --aws-ami-name "${AWS_AMI_NAME:-fl-rhel-gold}"
  )
  echo "AMI will upload to s3://${AWS_BUCKET} as ${AWS_AMI_NAME:-fl-rhel-gold}"
fi

echo "=== Composing $IMAGE_TYPE from $BLUEPRINT (distro=$DISTRO) ==="
# shellcheck disable=SC2086
image-builder "${BUILD_ARGS[@]}"

echo
echo "Compose finished. Artifacts are in the current directory (or image-builder output path)."
echo "Next: deploy per solution/cloud/aws-deploy.md or azure-deploy.md"
echo "Then on the VM: sudo bash solution/scripts/verify-gold-image.sh"
