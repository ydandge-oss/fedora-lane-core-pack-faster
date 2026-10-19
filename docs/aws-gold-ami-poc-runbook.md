# Runbook — Create gold AMI + AWS PoC

**Status:** Proven on RHDP AWS Blank OPEN  
**Branch:** `expansion-tdp-solution`  
**Where:** Mac Terminal (unless a step says “on the builder”)

**Not** hosted Image Builder at console.redhat.com — we use **local** Image Builder on a builder EC2.

Upstream: [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

---

## Big picture (what happens)

```text
1. Blueprint in Git          (recipe)
2. Builder EC2               (RHEL VM with Image Builder)
3. Compose                   (builds a .raw disk file)
4. Upload to S3 + vmimport   (registers AMI in AWS)
5. Gold AMI ready            (e.g. ami-07cb8e42f8e34bc14)
6. Launch PoC from AMI       (verify Expansion Pack)
```

| Artifact | Meaning |
|---|---|
| Blueprint | `solution/image-builder/fl-rhel-gold.toml` |
| Firstboot | `solution/image-builder/files/fl-gold-firstboot.sh` |
| On builder | Large `.raw` disk file |
| In AWS | AMI named `fl-rhel-gold` |

**Time:** first compose often **1–2 hours**. Keep the Mac awake.

---

## Before you start

### Step 0 — Open the right folder

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster
export PATH="$PWD/.tools/aws-cli:$PATH"
cd solution/cloud/aws
chmod +x *.sh
```

### Step 1 — Put AWS keys in env.local

```bash
cp -n env.example env.local
```

Edit `env.local`:

```text
AWS_ACCESS_KEY_ID=...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=us-east-2
```

Check AWS works:

```bash
aws sts get-caller-identity
```

You should see your account id. **Never commit** `env.local`.

---

## Phase A — Create the gold AMI

### Step 2 — Create the vmimport IAM role (once per account)

AWS needs this role to turn the uploaded disk into an AMI.

```bash
./setup-vmimport-role.sh
```

Expect: role `vmimport` created or updated.

### Step 3 — Launch builder + start compose

```bash
./compose-on-builder.sh
```

What this script does for you:

1. Creates an S3 bucket (if needed)  
2. Launches a large RHEL **builder** EC2  
3. Copies `solution/image-builder/` to the builder  
4. Installs Image Builder  
5. Runs compose type **ami**  
6. Uploads the disk and registers AMI `fl-rhel-gold`  

When it prints the builder IP, save it:

```bash
BUILDER_IP=1.2.3.4
echo $BUILDER_IP
```

(Also written under `output/builder-outputs.json`.)

### Step 4 — Subscribe the builder (required)

Marketplace RHEL can use `dnf`, but **Image Builder needs RHSM**.

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@$BUILDER_IP
```

On the builder:

```bash
sudo rhc connect
```

Log in with your Red Hat account, then:

```bash
exit
```

### Step 5 — If compose stopped or failed, continue

```bash
./continue-compose-on-builder.sh $BUILDER_IP
```

### Step 6 — Optional checks on the builder

SSH again:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@$BUILDER_IP
```

See if Image Builder knows AMI types:

```bash
sudo image-builder list | grep rhel-10 | grep x86_64 | grep ami
```

(Use `rhel-10.0` / `rhel-10.1` / `rhel-10.2` — **not** bare `rhel-10`. Our script auto-picks.)

See if a `.raw` disk was produced:

```bash
sudo find /home/ec2-user /var/tmp /tmp -name '*.raw' -size +1G 2>/dev/null
exit
```

### Step 7 — If `.raw` exists but AMI is missing, re-upload only

Faster than a full rebuild:

```bash
./setup-vmimport-role.sh
./reupload-ami-from-builder.sh $BUILDER_IP
```

This uploads the `.raw` to S3 and registers the AMI again.

### Step 8 — Confirm the gold AMI exists

```bash
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold \
  --output table
```

You want:

- **Name:** `fl-rhel-gold`  
- **State:** `available`  
- **ImageId:** something like `ami-07cb8e42f8e34bc14`  

Also check local files:

```bash
cat output/gold-ami.json
grep GOLD_AMI_ID env.local
```

Save the id:

```bash
AMI_ID=ami-07cb8e42f8e34bc14
echo $AMI_ID
```

**Gold AMI create is done.** Next is launch a PoC VM from it.

---

## Phase B — Launch PoC from the gold AMI

### Step 9 — Launch

```bash
./launch-gold-ami.sh
```

Wait **4–5 minutes** (boot + firstboot + podman).

### Step 10 — Verify

```bash
./verify-remote.sh
```

### Step 11 — Manual checks

```bash
cat output/aws-outputs.json
```

Replace with your PoC IP:

```bash
POC_IP=5.6.7.8

curl -s http://$POC_IP:35443/

ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$POC_IP
```

Inside the PoC VM:

```bash
getenforce
findmnt /var/log
findmnt /home
findmnt /tmp
findmnt /var/tmp
findmnt -n -o OPTIONS /tmp
ss -tln | grep 2222
ss -tln | grep 35443
curl -s http://127.0.0.1:35443/ | head
exit
```

### Step 12 — Optional: dummy boutique app

```bash
cd ../../demo-app
./deploy-to-vm.sh $POC_IP
cd ../aws
```

### Step 13 — Optional: reboot test

```bash
cat output/aws-outputs.json
```

```bash
INSTANCE_ID=i-xxxxxxxx
aws ec2 reboot-instances --instance-ids $INSTANCE_ID
```

Wait 2–3 minutes, then:

```bash
./verify-remote.sh
```

---

## Phase C — Cleanup

```bash
./terminate-ec2.sh
```

Terminate the builder too:

```bash
cat output/builder-outputs.json
```

```bash
BUILDER_ID=i-xxxxxxxx
aws ec2 terminate-instances --instance-ids $BUILDER_ID
```

Delete the RHDP AWS Blank OPEN environment in the browser when finished.

---

## Scripts cheat sheet

| Script | When to use |
|---|---|
| `setup-vmimport-role.sh` | Once per AWS account, before AMI register |
| `compose-on-builder.sh` | First time: new builder + full compose |
| `continue-compose-on-builder.sh` | Resume after SSH/RHSM interrupt |
| `reupload-ami-from-builder.sh` | `.raw` exists; AMI register failed |
| `launch-gold-ami.sh` | Start PoC from gold AMI |
| `verify-remote.sh` | Expansion Pack checks |
| `terminate-ec2.sh` | Stop PoC billing |
| `launch-ec2.sh` | Fast demo only — **not** a gold AMI |

---

## Common problems

| What you see | Fix |
|---|---|
| SSH to builder hangs | Your IP changed — SG must allow your current `/32` |
| `cannot find image for distro:"rhel-10"` | Need `rhel-10.x` (script auto-detects) |
| `no valid subscriptions` | On builder: `sudo rhc connect` |
| `vmimport ... does not exist` | Run `./setup-vmimport-role.sh` |
| AMI not in console | Wrong region — use **us-east-2** |
| Can’t SSH PoC on port 22 | Use port **2222** and user **fladmin1** |

---

## Expansion Pack checklist (proven)

- [x] Local Image Builder gold image  
- [x] AWS AMI deployable  
- [x] Separate `/var/log`, `/home`, `/tmp`, `/var/tmp`  
- [x] `/tmp` noexec · SELinux enforcing  
- [x] SSH 2222 · httpd container 35443 · fladmins  
- [x] Survives reboot  
- [x] Azure VHD — see [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md)  

---

## Related

- Simple AWS launch steps: [`solution/cloud/aws/README.md`](../solution/cloud/aws/README.md)  
- Where / when / why: [`where-when-why-commands.md`](./where-when-why-commands.md)  
- Verify checklist: [`verification-checklist.md`](./verification-checklist.md)  
