#!/usr/bin/env bash
# Build poc/output/hybrid-inventory.yml from Terraform outputs (if present).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="$ROOT/poc/output"
AWS_OUT="$OUT/aws-outputs.json"
AZ_OUT="$OUT/azure-outputs.json"
INV="$OUT/hybrid-inventory.yml"

mkdir -p "$OUT"

AWS_IP=""
AZ_IP=""
AWS_SITE="aws-us-east-1"
AZ_SITE="azure-westeurope"

if [[ -f "$AWS_OUT" ]]; then
  AWS_IP=$(python3 -c "import json;print(json.load(open('$AWS_OUT'))['public_ip']['value'])")
  AWS_SITE=$(python3 -c "import json;print(json.load(open('$AWS_OUT')).get('site_label',{}).get('value','aws-us-east-1'))")
fi
if [[ -f "$AZ_OUT" ]]; then
  AZ_IP=$(python3 -c "import json;print(json.load(open('$AZ_OUT'))['public_ip']['value'])")
  AZ_SITE=$(python3 -c "import json;print(json.load(open('$AZ_OUT')).get('site_label',{}).get('value','azure-westeurope'))")
fi

# Allow env overrides
AWS_IP="${FL_AWS_IP:-$AWS_IP}"
AZ_IP="${FL_AZURE_IP:-$AZ_IP}"
AWS_USER="${FL_AWS_SSH_USER:-ec2-user}"
AZ_USER="${FL_AZURE_SSH_USER:-fladmin}"
AWS_KEY="${FL_AWS_SSH_KEY:-$HOME/.ssh/id_ed25519}"
AZ_KEY="${FL_AZURE_SSH_KEY:-$HOME/.ssh/id_ed25519}"

if [[ -z "$AWS_IP" || -z "$AZ_IP" ]]; then
  cat <<EOF
Missing AWS and/or Azure IPs.
Options:
  1) terraform apply in poc/cloud/aws and poc/cloud/azure, then:
       terraform output -json > poc/output/aws-outputs.json
       terraform output -json > poc/output/azure-outputs.json
  2) Export: FL_AWS_IP=... FL_AZURE_IP=... FL_AWS_SSH_KEY=... FL_AZURE_SSH_KEY=...
  3) Copy poc/cloud/inventory.example.yml to poc/output/hybrid-inventory.yml and edit.
EOF
  exit 1
fi

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

echo "Wrote $INV"
cat "$INV"
