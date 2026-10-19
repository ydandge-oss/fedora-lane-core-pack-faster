#!/usr/bin/env bash
# Upload a local gold .vhd to Azure as a page blob (required for OS disks).
#
# Usage:
#   ./upload-vhd.sh /path/to/fl-rhel-gold.vhd
#   ./upload-vhd.sh          # uses VHD_PATH from env.local or downloads hint from AWS gold-vhd.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

load_env
az_login
ensure_rg

VHD="${1:-${VHD_PATH:-}}"
if [[ -z "$VHD" ]]; then
  AWS_VHD_JSON="$repo_root/solution/cloud/aws/output/gold-vhd.json"
  if [[ -f "$AWS_VHD_JSON" ]]; then
    OBJ=$(python3 -c "import json;print(json.load(open(r'''$AWS_VHD_JSON''')).get('object') or '')")
    S3=$(python3 -c "import json;print(json.load(open(r'''$AWS_VHD_JSON''')).get('s3_uri') or '')")
    if [[ -n "$OBJ" && -n "$S3" ]]; then
      echo "[azure] Downloading $S3 (needs AWS env from solution/cloud/aws/env.local)..."
      # shellcheck disable=SC1091
      set -a; source "$repo_root/solution/cloud/aws/env.local"; set +a
      export AWS_DEFAULT_REGION="${AWS_REGION:-}"
      mkdir -p "$out_dir"
      aws s3 cp "$S3" "$out_dir/$OBJ"
      VHD="$out_dir/$OBJ"
    fi
  fi
fi

[[ -n "$VHD" && -f "$VHD" ]] || die "Pass path to .vhd: ./upload-vhd.sh ./output/something.vhd"

# Azure requires fixed VHD; convert if qemu-img available and file looks like qcow/raw
case "$VHD" in
  *.raw)
    command -v qemu-img >/dev/null || die "Have .raw but no qemu-img — brew install qemu"
    FIXED="$out_dir/$(basename "${VHD%.raw}").vhd"
    echo "[azure] Converting raw → fixed VHD: $FIXED"
    qemu-img convert -f raw -O vpc -o subformat=fixed,force_size "$VHD" "$FIXED"
    VHD="$FIXED"
    ;;
  *.qcow2)
    command -v qemu-img >/dev/null || die "Have qcow2 but no qemu-img — brew install qemu"
    FIXED="$out_dir/$(basename "${VHD%.qcow2}").vhd"
    echo "[azure] Converting qcow2 → fixed VHD: $FIXED"
    qemu-img convert -f qcow2 -O vpc -o subformat=fixed,force_size "$VHD" "$FIXED"
    VHD="$FIXED"
    ;;
esac

[[ "$VHD" == *.vhd ]] || die "Expected a .vhd file, got: $VHD"

# Storage account name: 3–24 lowercase alphanumeric
if [[ -z "${STORAGE_ACCOUNT:-}" ]]; then
  SUFFIX=$(echo "$AZURE_SUBSCRIPTION_ID" | tr -d '-' | cut -c1-8 | tr '[:upper:]' '[:lower:]')
  STORAGE_ACCOUNT="flgold${SUFFIX}"
fi

echo "[azure] Storage account: $STORAGE_ACCOUNT"
if ! az storage account show -g "$AZURE_RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" >/dev/null 2>&1; then
  az storage account create \
    -g "$AZURE_RESOURCE_GROUP" \
    -n "$STORAGE_ACCOUNT" \
    -l "$AZURE_LOCATION" \
    --sku Standard_LRS \
    --kind StorageV2 >/dev/null
fi

CONN=$(az storage account show-connection-string \
  -g "$AZURE_RESOURCE_GROUP" -n "$STORAGE_ACCOUNT" --query connectionString -o tsv)

az storage container create --name "$STORAGE_CONTAINER" --connection-string "$CONN" >/dev/null 2>&1 || true

BLOB=$(basename "$VHD")
SIZE=$(stat -f%z "$VHD" 2>/dev/null || stat -c%s "$VHD")
echo "[azure] Uploading $VHD ($SIZE bytes) as page blob → ${STORAGE_ACCOUNT}/${STORAGE_CONTAINER}/${BLOB}"
echo "[azure] This can take a long time for multi-GB VHDs..."

az storage blob upload \
  --connection-string "$CONN" \
  --container-name "$STORAGE_CONTAINER" \
  --type page \
  --file "$VHD" \
  --name "$BLOB" \
  --overwrite true

VHD_URI="https://${STORAGE_ACCOUNT}.blob.core.windows.net/${STORAGE_CONTAINER}/${BLOB}"

python3 - <<PY
import json
from pathlib import Path
Path(r"""$out_dir/vhd-upload.json""").write_text(json.dumps({
  "vhd_uri": "$VHD_URI",
  "blob": "$BLOB",
  "storage_account": "$STORAGE_ACCOUNT",
  "container": "$STORAGE_CONTAINER",
  "local_path": "$VHD",
  "resource_group": "$AZURE_RESOURCE_GROUP",
}, indent=2) + "\n")
print("Wrote vhd-upload.json")
PY

# Persist storage account for later scripts
if grep -q '^STORAGE_ACCOUNT=' "$env_file" 2>/dev/null; then
  sed -i.bak "s/^STORAGE_ACCOUNT=.*/STORAGE_ACCOUNT=${STORAGE_ACCOUNT}/" "$env_file"
else
  echo "STORAGE_ACCOUNT=${STORAGE_ACCOUNT}" >>"$env_file"
fi
if grep -q '^VHD_PATH=' "$env_file" 2>/dev/null; then
  sed -i.bak "s|^VHD_PATH=.*|VHD_PATH=${VHD}|" "$env_file"
else
  echo "VHD_PATH=${VHD}" >>"$env_file"
fi

echo
echo "Uploaded: $VHD_URI"
echo "Next: ./create-image.sh"
