# AWS PoC — Expansion Pack gold image (RHDP Blank OPEN)

Prove Fedora Lane Expansion Pack controls on a real **EC2** instance using AWS CLI (no Terraform).

## Two paths

| Path | Script | What you get |
|---|---|---|
| **Expansion Pack (required for true gold image)** | `./compose-on-builder.sh` → `./launch-gold-ami.sh` | Local Image Builder compose → **gold AMI** → PoC VM from that AMI |
| Fast PoC (no gold AMI) | `./launch-ec2.sh` | Stock RHEL + cloud-init only |

**Proven runbook:** [`docs/aws-gold-ami-poc-runbook.md`](../../../docs/aws-gold-ami-poc-runbook.md)  
Short flow: [`docs/poc-gold-image-then-aws.md`](../../../docs/poc-gold-image-then-aws.md)

Fast PoC proves ports/services/security on AWS quickly. Separate `/var/log`,`/home`,`/tmp`,`/var/tmp` require the Image Builder AMI.

## Prerequisites

1. Order **AWS Blank OPEN** at [demo.redhat.com](https://demo.redhat.com) (associates)  
2. From the service overview, copy **Access Key ID** + **Secret** + region (often `us-east-2`)  
3. AWS CLI available — this repo vendors a copy under `.tools/aws-cli/aws` if needed  

```bash
# optional: use vendored CLI from repo root
export PATH="$PWD/.tools/aws-cli:$PATH"   # from repo root
aws --version
```

## Configure (do not commit secrets)

```bash
cd solution/cloud/aws
cp env.example env.local
# edit env.local:
#   AWS_ACCESS_KEY_ID=...
#   AWS_SECRET_ACCESS_KEY=...
#   AWS_REGION=us-east-2
#   SSH_CIDR=x.x.x.x/32   # or leave empty to auto-detect
```

## Fast PoC

```bash
chmod +x *.sh
./launch-ec2.sh
# wait 3–5 minutes for cloud-init
./verify-remote.sh

# manual checks
IP=$(python3 -c "import json;print(json.load(open('output/aws-outputs.json'))['public_ip'])")
curl -s "http://${IP}:35443/"
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP

# stop billing
./terminate-ec2.sh
```

## Full Image Builder on AWS

```bash
./setup-vmimport-role.sh          # once per account
./compose-on-builder.sh           # or continue-compose / reupload if interrupted
# wait until GOLD_AMI_ID is set / describe-images = available
./launch-gold-ami.sh
./verify-remote.sh
# optional reboot without sudo password:
# aws ec2 reboot-instances --instance-ids <ID>
./terminate-ec2.sh
```

Resume helpers: `continue-compose-on-builder.sh`, `reupload-ami-from-builder.sh`.  
**Azure VHD only:** `./compose-vhd-on-builder.sh` → then [`../azure/`](../azure/) + [azure runbook](../../../docs/azure-gold-vhd-poc-runbook.md).  
Pitfalls (RHSM, distro `rhel-10.x`, SG IP, sudo): see the runbook.

## Security notes

- Never commit `env.local`, `.pem`, or RHDP keys  
- SG opens **2222** + **35443** (+ temporary **22** for bootstrap) from your IP only  
- Delete the RHDP OPEN environment when finished  
