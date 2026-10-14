# AWS EC2 PoC (no Terraform)

Launch a real **Amazon EC2** instance with the Fedora Lane baseline via **AWS CLI**.

## Prerequisites

1. [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed  
2. Credentials configured: `aws configure` (or env vars)  
3. An **EC2 key pair** in your target region  
4. Your public IP for SSH/API security group (`x.x.x.x/32`)

```bash
brew install awscli   # macOS example
aws configure
aws sts get-caller-identity
```

## Launch

```bash
cd poc/cloud/aws
cp env.example env.local
# edit env.local: KEY_NAME, SSH_CIDR, SSH_PRIVATE_KEY, AWS_REGION

chmod +x launch-ec2.sh terminate-ec2.sh
./launch-ec2.sh
```

This will:

- Find/create a security group (ports **22** and **8080** from your IP only)  
- Launch EC2 with `user-data` = [`../cloud-init/fl-rhel-baseline.yaml`](../cloud-init/fl-rhel-baseline.yaml)  
- Write `poc/output/aws-outputs.json`  

Wait **2–3 minutes** for cloud-init, then:

```bash
curl -s http://<PUBLIC_IP>:8080/health
ssh -i ~/.ssh/your-key.pem ec2-user@<PUBLIC_IP> 'cat /etc/fl-baseline/MARKER'
```

## Verify (with Azure host if you have one)

```bash
# from repo root
./poc/cloud/scripts/write-inventory.sh
./poc/run-poc.sh --remote
```

AWS-only quick check:

```bash
IP=$(python3 -c "import json;print(json.load(open('poc/output/aws-outputs.json'))['public_ip']['value'])")
curl -s "http://${IP}:8080/health"
```

## Terminate (stop billing)

```bash
./poc/cloud/aws/terminate-ec2.sh
```

## Notes

- Default AMI lookup uses **RHEL 9** (Red Hat owner). If your account can’t see it, set `AMI_ID` in `env.local` or the script falls back to Rocky 9 for practice.  
- Terraform is **not** required for AWS on this branch. (Azure still has optional Terraform under `poc/cloud/azure/`.)  
- Never commit `env.local` or `.pem` keys.  
