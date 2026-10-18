#!/usr/bin/env bash
# Upload an already-composed VHD from the builder to S3.
# Streams through this Mac's AWS CLI (avoids broken RHEL awscli/OpenSSL on builder).
#
# Usage: ./upload-vhd-from-builder.sh <BUILDER_IP> [remote-vhd-path]
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

need_aws
load_env

IP="${1:?Usage: $0 <BUILDER_IP> [remote-vhd-path]}"
REMOTE_VHD="${2:-/home/ec2-user/fl-image-builder/rhel-10.2-vhd-x86_64/rhel-10.2-vhd-x86_64.vhd}"

: "${AWS_BUCKET:=}"
if [[ -z "$AWS_BUCKET" ]]; then
  ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
  AWS_BUCKET="fl-gold-${ACCOUNT}-${AWS_REGION}"
fi

BN=$(basename "$REMOTE_VHD")
S3_URI="s3://${AWS_BUCKET}/gold/${BN}"

echo "[upload] Checking remote VHD on ${IP}..."
wait_ssh "$IP" 22 "$SSH_USER"

SIZE=$(ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$SSH_PRIVATE_KEY" "${SSH_USER}@${IP}" \
  "sudo stat -c%s '${REMOTE_VHD}'")
[[ -n "$SIZE" && "$SIZE" -gt 0 ]] || die "Missing or empty remote VHD: $REMOTE_VHD"

echo "[upload] Streaming ${REMOTE_VHD} (${SIZE} bytes) → ${S3_URI}"
echo "[upload] Uses Mac AWS CLI (long for ~26G — keep laptop awake)"

# stdin upload >5GiB needs --expected-size for multipart
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$SSH_PRIVATE_KEY" "${SSH_USER}@${IP}" \
  "sudo cat '${REMOTE_VHD}'" \
  | aws s3 cp - "$S3_URI" --expected-size "$SIZE" --cli-read-timeout 0 --cli-connect-timeout 60

aws s3 ls "s3://${AWS_BUCKET}/gold/"

mkdir -p "$out_dir"
python3 - <<PY
import json
from pathlib import Path
Path(r"""$out_dir/gold-vhd.json""").write_text(json.dumps({
  "s3_uri": "$S3_URI",
  "s3_prefix": "s3://$AWS_BUCKET/gold/",
  "object": "$BN",
  "builder_ip": "$IP",
  "size_bytes": int("$SIZE"),
  "bucket": "$AWS_BUCKET",
}, indent=2) + "\n")
print("Wrote gold-vhd.json")
PY

echo
echo "OK: $S3_URI"
echo "Next (Azure): cd ../azure && ./upload-vhd.sh"
