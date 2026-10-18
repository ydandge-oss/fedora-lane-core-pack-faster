# Runbook — Local Image Builder gold AMI + AWS PoC

**Status:** Proven on RHDP AWS Blank OPEN (Expansion Pack path).  
**Branch:** `expansion-tdp-solution`  
**Where you run commands:** Mac Terminal (unless noted).

Upstream: [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

---

## What we built

| Artifact | Meaning |
|---|---|
| Blueprint | `solution/image-builder/fl-rhel-gold.toml` — Expansion Pack recipe |
| Firstboot | `solution/image-builder/files/fl-gold-firstboot.sh` — SELinux ports, `/tmp` noexec, httpd |
| Gold AMI | Example: `ami-07cb8e42f8e34bc14` (`fl-rhel-gold`) registered in RHDP AWS |
| PoC VM | EC2 launched **from that AMI**, verified + rebooted |

**Not** hosted Image Builder at console.redhat.com.

---

## Architecture (what runs where)

```text
Mac Terminal
  │  AWS CLI scripts (solution/cloud/aws/)
  │
  ├─► Builder EC2 (RHEL Marketplace)
  │     install image-builder
  │     compose ami (+ optional vhd)
  │     upload → register AMI  (needs IAM role vmimport)
  │
  └─► PoC EC2 (from gold AMI)
        SSH 2222 / fladmin1
        verify-remote.sh
        optional: aws ec2 reboot-instances
```

---

## Prerequisites

1. RHDP **AWS Blank OPEN** — Access Key, Secret, region (often `us-east-2`)  
2. Mac repo checkout + vendored CLI: `.tools/aws-cli/aws`  
3. `solution/cloud/aws/env.local` (from `env.example`) — **never commit**  
4. SSH key pair (script can create `fl-gold-poc`)

```bash
cd /Users/ydandge/Documents/fedora-lane-core-pack-faster/solution/cloud/aws
export PATH="/Users/ydandge/Documents/fedora-lane-core-pack-faster/.tools/aws-cli:$PATH"
cp -n env.example env.local   # then fill AWS keys
aws sts get-caller-identity
```

---

## Phase A — Create the gold AMI (Image Builder)

### A1. Launch builder + compose (or continue on existing builder)

First time:

```bash
./compose-on-builder.sh
```

If SSH to builder was stuck earlier / compose interrupted:

```bash
./setup-vmimport-role.sh          # required once per AWS account
./continue-compose-on-builder.sh <BUILDER_PUBLIC_IP>
```

If compose already produced a `.raw` but AMI registration failed:

```bash
./setup-vmimport-role.sh
./reupload-ami-from-builder.sh <BUILDER_PUBLIC_IP>
```

### A2. Builder must be subscribed (RHSM)

AWS Marketplace RHEL uses RHUI for `dnf`, but **Image Builder needs RHSM**:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@<BUILDER_IP>
sudo rhc connect    # Red Hat login
exit
```

Then re-run `continue-compose-on-builder.sh`.

### A3. Distro name must be versioned

Use `rhel-10.0` / `rhel-10.1` / `rhel-10.2` — **not** bare `rhel-10`.  
`compose.sh` auto-detects; confirm with:

```bash
ssh -i ~/.ssh/fl-gold-poc.pem ec2-user@<BUILDER_IP> \
  "sudo image-builder list | grep -E '^rhel-10' | grep 'arch:x86_64' | grep ami"
```

### A4. Success criteria for compose

```bash
aws ec2 describe-images --owners self \
  --filters Name=name,Values=fl-rhel-gold \
  --query 'Images[].{Id:ImageId,State:State}' --output table
```

Expect `State = available` (example: `ami-07cb8e42f8e34bc14`).  
Also written to `output/gold-ami.json` and `GOLD_AMI_ID` in `env.local`.

**Time:** often 1–2 hours for first compose; reupload of existing `.raw` is faster.

---

## Phase B — PoC from the gold AMI

```bash
./launch-gold-ami.sh
# wait 4–5 minutes for boot
./verify-remote.sh
```

`launch-gold-ami.sh` injects (via cloud-init user-data):

- Fixed firstboot script (httpd path)  
- Optional PoC NOPASSWD for automation (`99-fl-poc-nopasswd`)  
- Password unlock attempt for `fladmin1` / `fladmin2`  

`verify-remote.sh` checks:

| Check | How |
|---|---|
| SELinux enforcing | `getenforce` |
| Separate mounts | `findmnt` on `/var/log` `/home` `/tmp` `/var/tmp` |
| `/tmp` noexec | mount options |
| SSH 2222 | listening + login as `fladmin1` |
| Root / password SSH rejected | behavioral probes from Mac |
| Gold marker | `/etc/fl-gold/MARKER` |
| `fladmins` / `fladmin1` | `getent` / `id` |
| httpd :35443 | container + `curl` from VM and laptop |

If system firstboot httpd failed historically, verify starts a **rootless** podman httpd on 35443 so the PoC still proves the port/content.

### Manual spot checks

```bash
IP=$(python3 -c "import json;print(json.load(open('output/aws-outputs.json'))['public_ip'])")
curl -s "http://${IP}:35443/"
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP
```

### Survive reboot (optional)

Do **not** rely on `sudo reboot` if no password works — use AWS:

```bash
IID=$(python3 -c "import json;print(json.load(open('output/aws-outputs.json'))['instance_id'])")
aws ec2 reboot-instances --instance-ids "$IID"
# wait 2–3 minutes
curl -s "http://${IP}:35443/" || ./verify-remote.sh
ssh -i ~/.ssh/fl-gold-poc.pem -p 2222 fladmin1@$IP 'getenforce; findmnt /tmp; ss -tln | grep -E "2222|35443"'
```

---

## Phase C — Cleanup

```bash
./terminate-ec2.sh
# Terminate builder if still running (ID in output/builder-outputs.json)
aws ec2 terminate-instances --instance-ids <BUILDER_INSTANCE_ID>
```

Delete the RHDP AWS Blank OPEN environment in the browser.

---

## Scripts reference (`solution/cloud/aws/`)

| Script | Purpose |
|---|---|
| `compose-on-builder.sh` | New builder + compose AMI/VHD |
| `continue-compose-on-builder.sh` | Resume compose on existing builder IP |
| `setup-vmimport-role.sh` | Create IAM `vmimport` (required for AMI register) |
| `reupload-ami-from-builder.sh` | Re-register AMI from existing `.raw` |
| `launch-gold-ami.sh` | Launch PoC EC2 from `GOLD_AMI_ID` |
| `verify-remote.sh` | Expansion Pack checks from Mac |
| `terminate-ec2.sh` | Terminate PoC instance |
| `launch-ec2.sh` | **Fast path only** — stock AMI + cloud-init (not gold AMI) |

Blueprint / compose: `solution/image-builder/`.

---

## Pitfalls we hit (and fixes)

| Symptom | Cause | Fix |
|---|---|---|
| SSH wait forever to builder | SG had old public IP | Re-authorize current `/32`; `lib.sh` now refreshes SG |
| `cannot find image for distro:"rhel-10"` | Need `rhel-10.x` | Auto-detect in `compose.sh` |
| `no valid subscriptions` / `rhsm: true` | Marketplace RHUI ≠ RHSM | `sudo rhc connect` on builder |
| `failed to get shared config profile, default` | No AWS profile under `sudo` | Write `/root/.aws/credentials` before compose |
| `vmimport ... does not exist` | Missing IAM role | `./setup-vmimport-role.sh` |
| rsync Permission denied on `.raw` | Root-owned compose output | Don’t `--delete` huge artifacts; use reupload |
| firstboot `Permission denied` on index.html | Fragile `cat >` path | Fixed firstboot uses `mkdir` + `tee` |
| `sudo` password never works on PoC | Key-only users / `!` in password | PoC NOPASSWD drop-in + alphanumeric password; or rootless httpd |
| Verify waited on port 22 | Gold AMI only listens 2222 | `verify-remote.sh` waits on 2222 only |

---

## Expansion Pack checklist (proven)

- [x] Manual gold image via **local** Image Builder  
- [x] Deployable on AWS (**AMI**)  
- [x] Separate `/var/log`, `/home`, `/tmp`, `/var/tmp`  
- [x] `/tmp` **noexec**  
- [x] SELinux **enforcing**  
- [x] SSH **2222**, key-only, no root  
- [x] httpd **container** on **35443**  
- [x] `fladmins` + admin users  
- [x] Survives **reboot** (AWS reboot + re-verify)  
- [x] Azure **VHD** PoC — [azure-gold-vhd-poc-runbook.md](./azure-gold-vhd-poc-runbook.md) (proven)  

---

## Related docs

- [poc-steps-image-builder.md](./poc-steps-image-builder.md) — blueprint-focused PoC  
- [poc-gold-image-then-aws.md](./poc-gold-image-then-aws.md) — short compose → launch flow  
- [solution/cloud/aws/README.md](../solution/cloud/aws/README.md) — script index  
- [verification-checklist.md](./verification-checklist.md) — presentation checklist  
