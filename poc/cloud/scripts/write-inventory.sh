#!/usr/bin/env bash
# Build poc/output/hybrid-inventory.yml from AWS EC2 / Azure outputs.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="$ROOT/poc/output"
AWS_OUT="$OUT/aws-outputs.json"
AZ_OUT="$OUT/azure-outputs.json"
INV="$OUT/hybrid-inventory.yml"

mkdir -p "$OUT"

json_get() {
  local file="$1" key="$2" default="${3:-}"
  python3 -c "
import json,sys
p=sys.argv[1]; k=sys.argv[2]; d=sys.argv[3]
try:
  data=json.load(open(p))
  v=data.get(k,{}).get('value', d)
  print(v if v is not None else d)
except Exception:
  print(d)
" "$file" "$key" "$default"
}

AWS_IP=""
AZ_IP=""
AWS_SITE="aws-us-east-1"
AZ_SITE="azure-westeurope"
AWS_USER="ec2-user"
AZ_USER="fladmin"
AWS_KEY="${HOME}/.ssh/id_ed25519"
AZ_KEY="${HOME}/.ssh/id_ed25519"

if [[ -f "$AWS_OUT" ]]; then
  AWS_IP=$(json_get "$AWS_OUT" public_ip)
  AWS_SITE=$(json_get "$AWS_OUT" site_label aws-us-east-1)
  AWS_USER=$(json_get "$AWS_OUT" ssh_user ec2-user)
  AWS_KEY=$(json_get "$AWS_OUT" ssh_key "$HOME/.ssh/id_ed25519")
fi
if [[ -f "$AZ_OUT" ]]; then
  AZ_IP=$(json_get "$AZ_OUT" public_ip)
  AZ_SITE=$(json_get "$AZ_OUT" site_label azure-westeurope)
  AZ_USER=$(json_get "$AZ_OUT" ssh_user fladmin)
  AZ_KEY=$(json_get "$AZ_OUT" ssh_key "$HOME/.ssh/id_ed25519")
fi

AWS_IP="${FL_AWS_IP:-$AWS_IP}"
AZ_IP="${FL_AZURE_IP:-$AZ_IP}"
AWS_USER="${FL_AWS_SSH_USER:-$AWS_USER}"
AZ_USER="${FL_AZURE_SSH_USER:-$AZ_USER}"
AWS_KEY="${FL_AWS_SSH_KEY:-$AWS_KEY}"
AZ_KEY="${FL_AZURE_SSH_KEY:-$AZ_KEY}"

if [[ -z "$AWS_IP" ]]; then
  cat <<EOF
Missing AWS EC2 public IP.
Launch with AWS CLI (recommended):
  cd poc/cloud/aws && cp env.example env.local   # edit
  ./launch-ec2.sh

Or set: FL_AWS_IP=... FL_AWS_SSH_KEY=...
EOF
  exit 1
fi

# Azure is optional for AWS-only demos
if [[ -z "$AZ_IP" ]]; then
  echo "NOTE: No Azure host found — writing AWS-only inventory for partial hybrid demo."
  cat > "$INV" <<EOF
hosts:
  aws_ecom:
    cloud: aws
    site: ${AWS_SITE}
    public_ip: "${AWS_IP}"
    ssh_user: ${AWS_USER}
    ssh_key: "${AWS_KEY}"
    health_url: "http://${AWS_IP}:8080/health"
EOF
else
  cat > "$INV" <<EOF
hosts:
  aws_ecom:
    cloud: aws
    site: ${AWS_SITE}
    public_ip: "${AWS_IP}"
    ssh_user: ${AWS_USER}
    ssh_key: "${AWS_KEY}"
    health_url: "http://${AWS_IP}:8080/health"
  azure_analytics:
    cloud: azure
    site: ${AZ_SITE}
    public_ip: "${AZ_IP}"
    ssh_user: ${AZ_USER}
    ssh_key: "${AZ_KEY}"
    health_url: "http://${AZ_IP}:8080/health"
EOF
fi

echo "Wrote $INV"
cat "$INV"
