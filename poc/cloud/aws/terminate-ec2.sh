#!/usr/bin/env bash
# Terminate the Fedora Lane PoC EC2 instance created by launch-ec2.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
AWS_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/poc/output/aws-outputs.json"
ENV_FILE="${FL_AWS_ENV:-$AWS_DIR/env.local}"

die() { echo "ERROR: $*" >&2; exit 1; }
command -v aws >/dev/null || die "AWS CLI not found"
[[ -f "$OUT" ]] || die "Missing $OUT — nothing to terminate (or set INSTANCE_ID=i-xxxx)"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  export AWS_DEFAULT_REGION="${AWS_REGION:-us-east-1}"
fi

INSTANCE_ID="${INSTANCE_ID:-$(python3 -c "import json;print(json.load(open('$OUT'))['instance_id']['value'])")}"
[[ -n "$INSTANCE_ID" && "$INSTANCE_ID" != "None" ]] || die "No instance_id"

echo "[ec2] Terminating $INSTANCE_ID ..."
aws ec2 terminate-instances --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-terminated --instance-ids "$INSTANCE_ID"
echo "[ec2] Terminated."

# Optional: delete PoC SG if empty (best-effort)
if [[ -f "$ENV_FILE" ]]; then
  NAME_TAG="${NAME_TAG:-fl-poc-aws-ecom}"
  SG_NAME="${NAME_TAG}-sg"
  SG_ID=$(aws ec2 describe-security-groups \
    --filters Name=group-name,Values="$SG_NAME" \
    --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)
  if [[ -n "$SG_ID" && "$SG_ID" != "None" ]]; then
    aws ec2 delete-security-group --group-id "$SG_ID" 2>/dev/null \
      && echo "[ec2] Deleted security group $SG_ID" \
      || echo "[ec2] Left security group $SG_ID (still in use or default rules)"
  fi
fi

rm -f "$OUT"
echo "Removed $OUT"
