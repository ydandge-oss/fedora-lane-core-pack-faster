# Deploy / prove gold image on AWS (Blank OPEN)

## Goal

Run Expansion Pack checks on a real **EC2** VM: SSH **2222**, httpd **35443**, SELinux, `fladmins`, firewall.

## Fast path (cloud-init PoC)

Use the scripts under [`aws/`](./aws/) — no pre-built AMI required:

1. Order **AWS Blank OPEN** at https://demo.redhat.com  
2. Copy Access Key / Secret / region into `aws/env.local` (from `env.example`)  
3. Launch + verify:

```bash
cd solution/cloud/aws
cp env.example env.local   # fill RHDP keys
./launch-ec2.sh
./verify-remote.sh
./terminate-ec2.sh         # when done
```

Full details: [`aws/README.md`](./aws/README.md)

## Full path (Image Builder AMI)

1. Compose with local Image Builder (`docs/poc-steps-image-builder.md`) **or** run `./compose-on-builder.sh` on a builder EC2  
2. Import / register AMI as `fl-rhel-gold`  
3. Launch with SG inbound TCP **2222** + **35443** from your IP `/32`  
4. Connect and prove:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@<PUBLIC_IP>
curl -s http://127.0.0.1:35443/
sudo bash verify-gold-image.sh
sudo reboot
```

## Launch gold AMI **without** scripts (CLI + Console)

If the gold AMI already exists and you do not want `./launch-gold-ami.sh`, use raw AWS CLI or the EC2 console.

Full copy-paste: [`aws/README.md`](./aws/README.md) section **Launch from gold AMI without project scripts**, and [`docs/launch-gold-image-cli-and-console.md`](../../docs/launch-gold-image-cli-and-console.md).

Quick AMI id lookup:

```bash
AMI_ID=$(aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold Name=state,Values=available \
  --query 'sort_by(Images,&CreationDate)[-1].ImageId' --output text)
```

**Never** commit AWS keys or RHDP passwords.
