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

---

## Launch from gold AMI **without** project scripts

Use this when the gold AMI already exists and the customer prefers raw **AWS CLI** or the **EC2 console**.  
Gold VMs use **SSH 2222** and **httpd 35443** (not port 22).

Shared reference: [`docs/launch-gold-image-cli-and-console.md`](../../../docs/launch-gold-image-cli-and-console.md)

### AWS CLI (resolve AMI id + launch)

```bash
export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION="$AWS_REGION"

# Gold AMI id (like Azure: az image show …)
AMI_ID=$(aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold Name=state,Values=available \
  --query 'sort_by(Images,&CreationDate)[-1].ImageId' \
  --output text)
echo "AMI_ID=$AMI_ID"

KEY_NAME=fl-gold-poc                    # existing EC2 key pair name
INSTANCE_TYPE=t3.medium

VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true \
  --query 'Vpcs[0].VpcId' --output text)
SUBNET_ID=$(aws ec2 describe-subnets --filters Name=vpc-id,Values="$VPC_ID" \
  --query 'Subnets[0].SubnetId' --output text)

SG_NAME=fl-gold-sg
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values="$SG_NAME" Name=vpc-id,Values="$VPC_ID" \
  --query 'SecurityGroups[0].GroupId' --output text)
if [[ -z "$SG_ID" || "$SG_ID" == "None" ]]; then
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Fedora Lane gold SSH 2222 + httpd 35443" \
    --vpc-id "$VPC_ID" --query GroupId --output text)
fi

MYIP=$(curl -4 -fsS ifconfig.me)/32
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 2222 --cidr "$MYIP" 2>/dev/null || true
aws ec2 authorize-security-group-ingress --group-id "$SG_ID" \
  --protocol tcp --port 35443 --cidr "$MYIP" 2>/dev/null || true

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SG_ID" \
  --subnet-id "$SUBNET_ID" \
  --associate-public-ip-address \
  --block-device-mappings '[{"DeviceName":"/dev/sda1","Ebs":{"VolumeSize":40,"VolumeType":"gp3","DeleteOnTermination":true}}]' \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=fl-rhel-gold-vm}]' \
  --query 'Instances[0].InstanceId' --output text)

aws ec2 wait instance-running --instance-ids "$INSTANCE_ID"
PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "PUBLIC_IP=$PUBLIC_IP"

# After ~3–5 minutes:
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$PUBLIC_IP
curl -s "http://${PUBLIC_IP}:35443/"
```

### AWS Console

1. Region **US East (Ohio) `us-east-2`**.  
2. **EC2** → **AMIs** (Owned by me) → select **fl-rhel-gold** → **Launch instance from AMI**.  
3. Instance type **`t3.medium`** (preferred; `t2` shows 2/2 status checks, `t3` shows 3/3 — both OK).  
4. Key pair: any (login as `fladmin1` still uses the key baked into the AMI, e.g. `~/.ssh/fl-gold-poc.pem`).  
5. Network: public IP enabled; security group with **TCP 2222** + **TCP 35443** from **My IP** (reuse `fl-rhel-gold-poc-sg` if present). Do **not** rely on port 22.  
6. Storage ≥ 40 GiB.  
7. **Advanced details → User data** (required for httpd on console launches) — paste:

```yaml
#cloud-config
runcmd:
  - [rm, -f, /var/lib/fl-gold-firstboot-done]
  - [/bin/bash, /etc/fl-gold/bin/fl-gold-firstboot.sh]
```

Leave “User data already base64 encoded” unchecked.  
This runs gold-image firstboot so **Podman httpd starts on 35443**. Without it, SSH/mounts work but httpd often does not.

8. **Launch** → wait ~4–5 minutes (status OK + firstboot/podman).  
9. Connect / verify:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<Public-IP>
getenforce
for m in /var/log /home /tmp /var/tmp; do findmnt "$m"; done
findmnt -n -o OPTIONS /tmp | grep noexec
ss -tln | grep -E '2222|35443'
curl -s http://127.0.0.1:35443/ | head
curl -s http://<Public-IP>:35443/
```

---

## Security notes

- Never commit `env.local`, `.pem`, or RHDP keys  
- SG opens **2222** + **35443** (+ temporary **22** for bootstrap) from your IP only  
- Delete the RHDP OPEN environment when finished  
