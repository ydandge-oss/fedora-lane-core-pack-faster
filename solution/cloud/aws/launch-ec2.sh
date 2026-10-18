#!/usr/bin/env bash
# Launch Expansion Pack gold PoC on AWS EC2 (RHDP Blank OPEN).
# Applies cloud-init gold baseline (SSH 2222, httpd:35443, SELinux, fladmins).
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
resolve_rhel_ami
render_userdata

echo "[aws] Launching $NAME_TAG ($INSTANCE_TYPE) AMI=$AMI_ID"

RUN_ARGS=(
  ec2 run-instances
  --image-id "$AMI_ID"
  --instance-type "$INSTANCE_TYPE"
  --key-name "$KEY_NAME"
  --security-group-ids "$SG_ID"
  --user-data "file://${USER_DATA_FILE}"
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":30,"VolumeType":"gp3","DeleteOnTermination":true}}]'
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${NAME_TAG}},{Key=Project,Value=fedora-lane-gold},{Key=Role,Value=gold-poc}]"
  --count 1
  --query 'Instances[0].InstanceId'
  --output text
)

if [[ -n "$SUBNET_ID" ]]; then
  RUN_ARGS+=(--subnet-id "$SUBNET_ID" --associate-public-ip-address)
fi

INSTANCE_ID=$(aws "${RUN_ARGS[@]}")
echo "[aws] InstanceId=$INSTANCE_ID"

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
aws ec2 wait instance-status-ok --instance-ids "$INSTANCE_ID" || true

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)

python3 - <<PY
import json
from pathlib import Path
Path(r"""$out_dir/aws-outputs.json""").write_text(json.dumps({
  "instance_id": "$INSTANCE_ID",
  "public_ip": "$PUBLIC_IP",
  "ssh_user": "$SSH_USER",
  "ssh_key": "$SSH_PRIVATE_KEY",
  "ssh_bootstrap": f"ssh -i $SSH_PRIVATE_KEY -p 22 $SSH_USER@$PUBLIC_IP",
  "ssh_gold": f"ssh -i $SSH_PRIVATE_KEY -p 2222 fladmin1@$PUBLIC_IP",
  "httpd": f"http://$PUBLIC_IP:35443/",
}, indent=2) + "\n")
print("Wrote aws-outputs.json")
PY

echo
echo "============================================================"
echo " Gold PoC EC2 launched"
echo "   Instance: $INSTANCE_ID"
echo "   Public IP: $PUBLIC_IP"
echo "   Wait ~3–5 min for cloud-init, then:"
echo "     ./verify-remote.sh"
echo "   SSH (after firstboot):"
echo "     ssh -i $SSH_PRIVATE_KEY -p 2222 fladmin1@$PUBLIC_IP"
echo "   httpd: http://${PUBLIC_IP}:35443/"
echo " Terminate: ./terminate-ec2.sh"
echo "============================================================"
