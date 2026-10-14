#!/usr/bin/env bash
# Launch a Fedora Lane PoC EC2 instance with the shared cloud-init baseline.
# Uses Amazon EC2 via AWS CLI — no Terraform.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
AWS_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT="$ROOT/poc/output"
USER_DATA="$ROOT/poc/cloud/cloud-init/fl-rhel-baseline.yaml"
ENV_FILE="${FL_AWS_ENV:-$AWS_DIR/env.local}"

die() { echo "ERROR: $*" >&2; exit 1; }

command -v aws >/dev/null || die "AWS CLI not found. Install: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
command -v python3 >/dev/null || die "python3 required"
[[ -f "$USER_DATA" ]] || die "Missing user-data: $USER_DATA"
[[ -f "$ENV_FILE" ]] || die "Missing $ENV_FILE — copy env.example to env.local and edit"

# shellcheck disable=SC1090
source "$ENV_FILE"

: "${AWS_REGION:?}"
: "${INSTANCE_TYPE:?}"
: "${KEY_NAME:?}"
: "${SSH_CIDR:?}"
: "${NAME_TAG:=fl-poc-aws-ecom}"
: "${SSH_USER:=ec2-user}"
: "${SSH_PRIVATE_KEY:=}"
: "${AMI_ID:=}"
: "${SUBNET_ID:=}"
: "${VPC_ID:=}"

mkdir -p "$OUT"
export AWS_DEFAULT_REGION="$AWS_REGION"

echo "[ec2] Region=$AWS_REGION Name=$NAME_TAG Type=$INSTANCE_TYPE"

# Resolve VPC
if [[ -z "$VPC_ID" ]]; then
  VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
    --query 'Vpcs[0].VpcId' --output text)
  [[ "$VPC_ID" != "None" && -n "$VPC_ID" ]] || die "No default VPC; set VPC_ID in env.local"
fi
echo "[ec2] VPC=$VPC_ID"

# Security group (create or reuse by name)
SG_NAME="${NAME_TAG}-sg"
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values="$SG_NAME" Name=vpc-id,Values="$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' --output text 2>/dev/null || true)

if [[ -z "$SG_ID" || "$SG_ID" == "None" ]]; then
  echo "[ec2] Creating security group $SG_NAME"
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Fedora Lane PoC SSH + inventory-sync" \
    --vpc-id "$VPC_ID" \
    --query GroupId --output text)
  aws ec2 create-tags --resources "$SG_ID" --tags Key=Project,Value=fedora-lane-poc Key=Name,Value="$SG_NAME"
  aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
    --ip-permissions \
      "IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges=[{CidrIp=${SSH_CIDR},Description=SSH}]" \
      "IpProtocol=tcp,FromPort=8080,ToPort=8080,IpRanges=[{CidrIp=${SSH_CIDR},Description=InventorySync}]"
else
  echo "[ec2] Reusing security group $SG_ID"
fi

# AMI
if [[ -z "$AMI_ID" ]]; then
  echo "[ec2] Looking up latest RHEL 9 x86_64 Hourly AMI (owner 309956199498)..."
  AMI_ID=$(aws ec2 describe-images \
    --owners 309956199498 \
    --filters \
      "Name=name,Values=RHEL-9.*_HVM-*-x86_64-*-Hourly2-GP3" \
      "Name=architecture,Values=x86_64" \
      "Name=virtualization-type,Values=hvm" \
      "Name=root-device-type,Values=ebs" \
      "Name=state,Values=available" \
    --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
    --output text)
  if [[ -z "$AMI_ID" || "$AMI_ID" == "None" ]]; then
    echo "[ec2] RHEL AMI not found — trying Rocky Linux 9 (practice fallback)..."
    AMI_ID=$(aws ec2 describe-images \
      --owners 679593333241 \
      --filters \
        "Name=name,Values=Rocky-9*x86_64*" \
        "Name=architecture,Values=x86_64" \
        "Name=state,Values=available" \
      --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
      --output text)
  fi
  [[ -n "$AMI_ID" && "$AMI_ID" != "None" ]] || die "Could not find AMI. Set AMI_ID in env.local"
fi
echo "[ec2] AMI=$AMI_ID"

RUN_ARGS=(
  ec2 run-instances
  --image-id "$AMI_ID"
  --instance-type "$INSTANCE_TYPE"
  --key-name "$KEY_NAME"
  --security-group-ids "$SG_ID"
  --user-data "file://${USER_DATA}"
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":20,"VolumeType":"gp3","DeleteOnTermination":true}}]'
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME_TAG}},{Key=Project,Value=fedora-lane-poc},{Key=Site,Value=aws-${AWS_REGION}},{Key=Role,Value=cloud_app}]"
  --count 1
  --query 'Instances[0].InstanceId'
  --output text
)

if [[ -n "$SUBNET_ID" ]]; then
  RUN_ARGS+=(--subnet-id "$SUBNET_ID" --associate-public-ip-address)
fi

echo "[ec2] Launching instance..."
INSTANCE_ID=$(aws "${RUN_ARGS[@]}")
echo "[ec2] InstanceId=$INSTANCE_ID"

echo "[ec2] Waiting for running + status OK..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID" || true

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicDnsName' --output text)

python3 - <<PY
import json
from pathlib import Path
out = Path(r"""$OUT/aws-outputs.json""")
out.write_text(json.dumps({
  "public_ip": {"value": "$PUBLIC_IP"},
  "public_dns": {"value": "$PUBLIC_DNS"},
  "instance_id": {"value": "$INSTANCE_ID"},
  "site_label": {"value": "aws-$AWS_REGION"},
  "ssh_user": {"value": "$SSH_USER"},
  "ssh_key": {"value": "$SSH_PRIVATE_KEY"},
  "health_url": {"value": f"http://$PUBLIC_IP:8080/health"},
  "ssh_example": {"value": f"ssh -i $SSH_PRIVATE_KEY $SSH_USER@$PUBLIC_IP"},
}, indent=2) + "\n")
print(f"Wrote {out}")
PY

echo
echo "============================================================"
echo " EC2 launched for Fedora Lane PoC"
echo "   Instance: $INSTANCE_ID"
echo "   Public IP: $PUBLIC_IP"
echo "   Health (after ~2-3 min cloud-init): http://${PUBLIC_IP}:8080/health"
echo "   SSH: ssh -i ${SSH_PRIVATE_KEY:-<your-key.pem>} ${SSH_USER}@${PUBLIC_IP}"
echo "============================================================"
echo "Cloud-init installs packages + starts inventory-sync — wait a few minutes, then:"
echo "  ./poc/cloud/scripts/write-inventory.sh"
echo "  ./poc/run-poc.sh --remote"
echo "Terminate when done: ./poc/cloud/aws/terminate-ec2.sh"
