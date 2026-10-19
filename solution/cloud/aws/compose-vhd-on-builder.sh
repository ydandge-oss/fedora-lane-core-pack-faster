#!/usr/bin/env bash
# Compose Azure gold VHD only (local Image Builder) on an existing or new builder EC2.
#
# Usage:
#   ./compose-vhd-on-builder.sh                 # launch new builder + compose vhd
#   ./compose-vhd-on-builder.sh <BUILDER_IP>    # reuse existing builder
#
# Output: VHD uploaded to s3://$AWS_BUCKET/gold/  +  output/gold-vhd.json
# Time: often 45–120 minutes. Requires RHSM on builder (sudo rhc connect).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

need_aws
load_env
detect_ssh_cidr
ensure_keypair
resolve_vpc
ensure_sg

: "${AWS_AMI_NAME:=fl-rhel-gold}"
: "${AWS_BUCKET:=}"
if [[ -z "$AWS_BUCKET" ]]; then
  ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
  AWS_BUCKET="fl-gold-${ACCOUNT}-${AWS_REGION}"
fi

echo "[vhd] Ensuring S3 bucket s3://${AWS_BUCKET}..."
if ! aws s3api head-bucket --bucket "$AWS_BUCKET" 2>/dev/null; then
  if [[ "$AWS_REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$AWS_BUCKET"
  else
    aws s3api create-bucket --bucket "$AWS_BUCKET" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
fi

IP="${1:-}"
INSTANCE_ID=""

if [[ -z "$IP" ]]; then
  resolve_rhel_ami
  BUILDER_NAME="${NAME_TAG}-vhd-builder"
  echo "[vhd] Launching builder $BUILDER_NAME ($BUILDER_INSTANCE_TYPE, ${BUILDER_VOLUME_GB}G)"
  RUN_ARGS=(
    ec2 run-instances
    --image-id "$AMI_ID"
    --instance-type "$BUILDER_INSTANCE_TYPE"
    --key-name "$KEY_NAME"
    --security-group-ids "$SG_ID"
    --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"VolumeSize\":${BUILDER_VOLUME_GB},\"VolumeType\":\"gp3\",\"DeleteOnTermination\":true}}]"
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${BUILDER_NAME}},{Key=Project,Value=fedora-lane-gold},{Key=Role,Value=image-builder-vhd}]"
    --count 1
    --query 'Instances[0].InstanceId'
    --output text
  )
  if [[ -n "$SUBNET_ID" ]]; then
    RUN_ARGS+=(--subnet-id "$SUBNET_ID" --associate-public-ip-address)
  fi
  INSTANCE_ID=$(aws "${RUN_ARGS[@]}")
  aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
  aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID" || true
  IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
  [[ -n "$IP" && "$IP" != "None" ]] || die "Builder has no public IP"
  echo "[vhd] Builder $INSTANCE_ID @ $IP"
  wait_ssh "$IP" 22 "$SSH_USER"
else
  echo "[vhd] Reusing builder at $IP"
  wait_ssh "$IP" 22 "$SSH_USER"
fi

REMOTE=/home/ec2-user/fl-image-builder
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$SSH_PRIVATE_KEY" "${SSH_USER}@${IP}" "mkdir -p $REMOTE"
rsync -az -e "ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $SSH_PRIVATE_KEY" \
  --exclude 'rhel-*-ami-*/' \
  --exclude 'rhel-*-vhd-*/' \
  --exclude '*.raw' \
  --exclude '*.vhd' \
  "$repo_root/solution/image-builder/" "${SSH_USER}@${IP}:$REMOTE/"

PUB=$(ssh-keygen -y -f "$SSH_PRIVATE_KEY" 2>/dev/null || true)
if [[ -n "$PUB" ]]; then
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
    -i "$SSH_PRIVATE_KEY" "${SSH_USER}@${IP}" \
    "python3 - <<'PY'
from pathlib import Path
import re
pub = '''$PUB'''.strip()
for name in ['fl-rhel-gold.toml','fl-rhel-gold.blueprint.toml']:
    p = Path('$REMOTE')/name
    if not p.exists(): continue
    t = p.read_text()
    t2, n = re.subn(r'key = \"ssh-[^\"]+\"', f'key = \"{pub}\"', t)
    p.write_text(t2)
    print(name, 'keys', n)
PY"
fi

mkdir -p "$out_dir"
python3 - <<PY
import json
from pathlib import Path
Path(r"""$out_dir/vhd-builder-outputs.json""").write_text(json.dumps({
  "instance_id": "$INSTANCE_ID" or None,
  "public_ip": "$IP",
  "bucket": "$AWS_BUCKET",
  "role": "vhd-compose",
}, indent=2) + "\n")
PY

echo "[vhd] Starting Image Builder VHD compose on $IP (long)..."
# shellcheck disable=SC2029
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
  -i "$SSH_PRIVATE_KEY" "${SSH_USER}@${IP}" \
  "sudo bash -s" <<EOS
set -euo pipefail
export AWS_REGION='$AWS_REGION'
export AWS_BUCKET='$AWS_BUCKET'
export AWS_ACCESS_KEY_ID='${AWS_ACCESS_KEY_ID:-}'
export AWS_SECRET_ACCESS_KEY='${AWS_SECRET_ACCESS_KEY:-}'
export AWS_DEFAULT_REGION='$AWS_REGION'
mkdir -p /root/.aws
cat >/root/.aws/credentials <<'CRED'
[default]
aws_access_key_id = ${AWS_ACCESS_KEY_ID:-}
aws_secret_access_key = ${AWS_SECRET_ACCESS_KEY:-}
CRED
cat >/root/.aws/config <<CONF
[default]
region = ${AWS_REGION}
output = json
CONF
export AWS_SHARED_CREDENTIALS_FILE=/root/.aws/credentials
export AWS_CONFIG_FILE=/root/.aws/config
export AWS_PROFILE=default
export HOME=/root

# RHSM required for Image Builder depsolve (Marketplace RHUI is not enough).
# After rhc connect, status is often "Registered" (not always "Current").
if ! subscription-manager status 2>/dev/null | grep -qiE 'Overall Status: (Current|Registered)'; then
  echo "ERROR: Builder is not RHSM-subscribed."
  echo "  ssh -i ... ${SSH_USER}@${IP}"
  echo "  sudo rhc connect"
  echo "Then re-run: ./compose-vhd-on-builder.sh ${IP}"
  subscription-manager status 2>/dev/null || true
  exit 2
fi
echo "RHSM OK: $(subscription-manager status 2>/dev/null | grep -i 'Overall Status' || echo registered)"

cd '$REMOTE'
chmod +x scripts/*.sh files/*.sh 2>/dev/null || true
./scripts/install-image-builder.sh
./scripts/generate-blueprint.sh || true
echo "=== COMPOSE VHD (Azure gold) ==="
./scripts/compose.sh vhd
# Prefer official AWS CLI v2 — RHEL awscli2 RPM often breaks on OpenSSL symbol mismatch
if [[ ! -x /usr/local/bin/aws ]]; then
  dnf install -y unzip >/dev/null
  cd /tmp
  curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  rm -rf aws
  unzip -qo awscliv2.zip
  ./aws/install --update
fi
AWS_BIN=/usr/local/bin/aws
command -v "\$AWS_BIN" >/dev/null || AWS_BIN=\$(command -v aws)
mkdir -p /tmp/fl-vhd-out
# Prefer largest .vhd as the gold artifact
BEST=\$(find /home/ec2-user /var/tmp /tmp /root '$REMOTE' -type f -name '*.vhd' 2>/dev/null | xargs -r ls -1S 2>/dev/null | head -1 || true)
if [[ -z "\$BEST" ]]; then
  BEST=\$(find /home/ec2-user /var/tmp /tmp /root '$REMOTE' -type f -name '*.raw' 2>/dev/null | xargs -r ls -1S 2>/dev/null | head -1 || true)
fi
if [[ -z "\$BEST" ]]; then
  echo "ERROR: No .vhd/.raw found after compose"
  exit 1
fi
bn=\$(basename "\$BEST")
echo "Uploading \$BEST -> s3://${AWS_BUCKET}/gold/\$bn"
"\$AWS_BIN" s3 cp "\$BEST" "s3://${AWS_BUCKET}/gold/\$bn"
echo "\$bn" > /tmp/fl-vhd-out/primary.txt
echo "PRIMARY=\$BEST"
"\$AWS_BIN" s3 ls "s3://${AWS_BUCKET}/gold/" || true
echo "=== VHD COMPOSE DONE ==="
EOS

PRIMARY=$(aws s3 ls "s3://${AWS_BUCKET}/gold/" | awk '{print $4}' | grep -E '\.vhd$' | tail -1 || true)
if [[ -z "$PRIMARY" ]]; then
  PRIMARY=$(aws s3 ls "s3://${AWS_BUCKET}/gold/" | awk '{print $4}' | grep -E '\.(raw|vhd)$' | tail -1 || true)
fi

S3_URI=""
if [[ -n "$PRIMARY" ]]; then
  S3_URI="s3://${AWS_BUCKET}/gold/${PRIMARY}"
fi

python3 - <<PY
import json
from pathlib import Path
Path(r"""$out_dir/gold-vhd.json""").write_text(json.dumps({
  "s3_uri": "$S3_URI" or None,
  "s3_prefix": "s3://$AWS_BUCKET/gold/",
  "object": "$PRIMARY" or None,
  "builder_ip": "$IP",
  "builder_instance_id": "$INSTANCE_ID" or None,
  "bucket": "$AWS_BUCKET",
}, indent=2) + "\n")
print("Wrote gold-vhd.json")
PY

if [[ -z "$S3_URI" ]]; then
  echo "WARN: No .vhd found in s3://${AWS_BUCKET}/gold/ yet — check builder logs."
  echo "  ssh -i $SSH_PRIVATE_KEY ${SSH_USER}@${IP}"
  exit 1
fi

echo
echo "============================================================"
echo " Azure gold VHD ready in S3"
echo "   $S3_URI"
echo " Next:"
echo "   # download to Mac"
echo "   aws s3 cp $S3_URI $out_dir/"
echo "   # then Azure Blank OPEN → solution/cloud/azure/"
echo "   cd ../azure && cp -n env.example env.local  # fill Azure creds"
echo "   ./upload-vhd.sh $out_dir/$(basename "$PRIMARY")"
echo "   ./create-image.sh && ./launch-vm.sh && ./verify-remote.sh"
echo "============================================================"
