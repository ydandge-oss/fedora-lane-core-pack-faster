# AWS PoC — Expansion Pack gold image (RHDP Blank OPEN)

Prove Fedora Lane Expansion Pack controls on a real **EC2** instance.

Gold VMs use **SSH port 2222** and **httpd port 35443** (not port 22).

---

## Two paths

| Path | What you get |
|---|---|
| **A. Scripts (easiest)** | `./compose-on-builder.sh` → `./launch-gold-ami.sh` → gold AMI → PoC VM |
| **B. Plain AWS CLI / Console** | Same result, step-by-step commands below |

**Full runbook:** [`docs/aws-gold-ami-poc-runbook.md`](../../../docs/aws-gold-ami-poc-runbook.md)  
**Where / when / why:** [`docs/where-when-why-commands.md`](../../../docs/where-when-why-commands.md)

---

## Prerequisites

1. Order **AWS Blank OPEN** at [demo.redhat.com](https://demo.redhat.com)  
2. Copy **Access Key**, **Secret**, and region (usually `us-east-2`)  
3. Have AWS CLI (repo copy: `.tools/aws-cli/aws`)

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster
export PATH="$PWD/.tools/aws-cli:$PATH"
aws --version
```

---

## Configure (do not commit secrets)

```bash
cd solution/cloud/aws
cp env.example env.local
```

Edit `env.local` and set:

```text
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-2
```

Check login works:

```bash
aws sts get-caller-identity
```

---

## Path A — Create gold AMI + launch PoC (scripts)

**Detailed step-by-step:** [`docs/aws-gold-ami-poc-runbook.md`](../../../docs/aws-gold-ami-poc-runbook.md)

### Create the gold AMI (do in order)

```bash
chmod +x *.sh
```

**1. IAM role** (once) — lets AWS turn uploaded disk into AMI:

```bash
./setup-vmimport-role.sh
```

**2. Launch builder + compose** (takes 1–2 hours first time):

```bash
./compose-on-builder.sh
```

Save the builder IP it prints:

```bash
BUILDER_IP=1.2.3.4
```

**3. Subscribe the builder** (Image Builder needs RHSM):

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@$BUILDER_IP
sudo rhc connect
exit
```

**4. If compose stopped, continue:**

```bash
./continue-compose-on-builder.sh $BUILDER_IP
```

**5. If `.raw` exists but AMI missing, re-upload only:**

```bash
./reupload-ami-from-builder.sh $BUILDER_IP
```

**6. Confirm AMI is available:**

```bash
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold \
  --output table
```

```bash
cat output/gold-ami.json
```

You want **State = available** and an id like `ami-07cb8e42f8e34bc14`.

### Launch PoC from that AMI

```bash
./launch-gold-ami.sh
```

Wait 4–5 minutes, then:

```bash
./verify-remote.sh
```

```bash
cat output/aws-outputs.json
```

```bash
POC_IP=5.6.7.8
curl -s http://$POC_IP:35443/
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$POC_IP
```

Optional dummy app:

```bash
cd ../../demo-app
./deploy-to-vm.sh $POC_IP
cd ../aws
```

### Cleanup

```bash
./terminate-ec2.sh
cat output/builder-outputs.json
aws ec2 terminate-instances --instance-ids i-BUILDER_ID
```

---

## Path B — Plain AWS CLI (no project launch script)

Use this when the gold AMI **already exists**.  
Do one small step at a time. Copy each result into the next command.

Set region:

```bash
export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION=us-east-2
```

### Step 1 — Find the gold AMI

```bash
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold Name=state,Values=available \
  --output table
```

Copy the **ImageId** (looks like `ami-07cb8e42f8e34bc14`).

```bash
AMI_ID=ami-07cb8e42f8e34bc14
echo $AMI_ID
```

### Step 2 — Find default VPC

```bash
aws ec2 describe-vpcs \
  --filters Name=isDefault,Values=true \
  --output table
```

```bash
VPC_ID=vpc-xxxxxxxx
echo $VPC_ID
```

### Step 3 — Find a subnet in that VPC

```bash
aws ec2 describe-subnets \
  --filters Name=vpc-id,Values=$VPC_ID \
  --output table
```

```bash
SUBNET_ID=subnet-xxxxxxxx
echo $SUBNET_ID
```

### Step 4 — Security group (SSH 2222 + httpd 35443)

List existing:

```bash
aws ec2 describe-security-groups \
  --filters Name=group-name,Values=fl-gold-sg Name=vpc-id,Values=$VPC_ID \
  --output table
```

If none, create one:

```bash
aws ec2 create-security-group \
  --group-name fl-gold-sg \
  --description "Fedora Lane gold SSH 2222 + httpd 35443" \
  --vpc-id $VPC_ID \
  --output table
```

```bash
SG_ID=sg-xxxxxxxx
echo $SG_ID
```

Allow your IP (replace with your public IP `/32`):

```bash
MYIP=1.2.3.4/32

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 2222 \
  --cidr $MYIP

aws ec2 authorize-security-group-ingress \
  --group-id $SG_ID \
  --protocol tcp \
  --port 35443 \
  --cidr $MYIP
```

(Ignore errors if the rules already exist.)

### Step 5 — Launch the instance

Key pair name in AWS (file on Mac is still `~/.ssh/fl-gold-poc.pem`):

```bash
KEY_NAME=fl-gold-poc
```

Launch:

```bash
aws ec2 run-instances \
  --image-id $AMI_ID \
  --instance-type t3.medium \
  --key-name $KEY_NAME \
  --security-group-ids $SG_ID \
  --subnet-id $SUBNET_ID \
  --associate-public-ip-address \
  --output table
```

Copy the **InstanceId**:

```bash
INSTANCE_ID=i-xxxxxxxx
```

Wait until running:

```bash
aws ec2 wait instance-running --instance-ids $INSTANCE_ID
```

### Step 6 — Get public IP

```bash
aws ec2 describe-instances \
  --instance-ids $INSTANCE_ID \
  --output table
```

```bash
PUBLIC_IP=1.2.3.4
echo $PUBLIC_IP
```

### Step 7 — Connect and test (wait ~4–5 min first)

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$PUBLIC_IP
```

Inside the VM:

```bash
getenforce
findmnt /var/log
findmnt /home
findmnt /tmp
findmnt /var/tmp
ss -tln | grep 2222
ss -tln | grep 35443
curl -s http://127.0.0.1:35443/ | head
exit
```

From your Mac:

```bash
curl -s http://$PUBLIC_IP:35443/
```

### Optional — User data (console / CLI) so httpd starts

If httpd is missing after a console launch, add this **User data** at launch:

```yaml
#cloud-config
runcmd:
  - [rm, -f, /var/lib/fl-gold-firstboot-done]
  - [/bin/bash, /etc/fl-gold/bin/fl-gold-firstboot.sh]
```

---

## Path B — AWS Console (click path)

1. Region **US East (Ohio) / us-east-2**  
2. **EC2 → AMIs → Owned by me → fl-rhel-gold → Launch instance from AMI**  
3. Type: **t3.medium**  
4. Key pair: any (SSH still uses `~/.ssh/fl-gold-poc.pem` as `fladmin1`)  
5. Security group: allow **TCP 2222** and **TCP 35443** from **My IP**  
6. Storage: at least **40 GiB**  
7. **Advanced → User data** — paste the YAML above  
8. Launch → wait 4–5 minutes  
9. SSH and curl as in Step 7  

---

## Fast PoC (stock RHEL — not a gold AMI)

Only if you want a quick cloud-init demo without Image Builder:

```bash
./launch-ec2.sh
# wait 3–5 minutes
./verify-remote.sh
./terminate-ec2.sh
```

This does **not** give Image Builder partitions. For Expansion Pack gold, use Path A.

---

## Security notes

- Never commit `env.local`, `.pem`, or RHDP keys  
- Open **2222** and **35443** only from your IP  
- Delete the RHDP OPEN environment when finished  
