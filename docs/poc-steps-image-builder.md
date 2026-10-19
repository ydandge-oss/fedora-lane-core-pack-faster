# PoC steps — Path Primary: RHEL Image Builder (local)

Follow the Red Hat procedure for composing a customized RHEL system image with **local** Image Builder on a RHEL VM.

**AWS end-to-end runbook (proven):** [aws-gold-ami-poc-runbook.md](./aws-gold-ami-poc-runbook.md)

Upstream: [RHEL image builder description](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description)

**Not** hosted Image Builder at console.redhat.com.

---

## Prerequisites

- Subscribed **RHEL 10** builder VM (RHDP / lab) with enough disk (~40+ GiB free)
- SSH key pair for `fladmin1` / `fladmin2`
- RHDP **AWS Blank OPEN** or **Azure Blank OPEN** for deploy
- This repo cloned onto the builder VM

---

## Phase 1 — Install Image Builder

On the builder VM:

```bash
cd solution/image-builder
sudo ./scripts/install-image-builder.sh
# equivalent:
#   sudo dnf install -y image-builder osbuild osbuild-depsolve-dnf
#   image-builder list
```

---

## Phase 2 — Prepare the blueprint

```bash
./scripts/generate-blueprint.sh
```

Edit `fl-rhel-gold.toml`:

1. Replace every `AAAREPLACE_WITH_REAL_PUBLIC_KEY` with your real `ssh-ed25519` / `ssh-rsa` public key.
2. (Recommended for sudo demo) Add password hashes:

```bash
openssl passwd -6 'YourDemoPassword'
# then in the [[customizations.user]] blocks:
# password = "$6$...."
```

Blueprint covers Expansion Pack controls: LVM mounts, `fladmins`, firewall 2222/35443, SSH hardening, firstboot (SELinux ports, `/tmp` noexec, httpd container).

---

## Phase 3 — Compose

```bash
# AWS
sudo ./scripts/compose.sh ami

# Azure
sudo ./scripts/compose.sh vhd

# Local / libvirt smoke test
sudo ./scripts/compose.sh qcow2
```

Or call the CLI directly (per Red Hat docs):

```bash
sudo image-builder build ami --blueprint ./fl-rhel-gold.toml --distro rhel-10
sudo image-builder build vhd --blueprint ./fl-rhel-gold.toml --distro rhel-10
```

Optional AMI auto-upload (credentials + writable bucket required):

```bash
export AWS_REGION=us-east-1 AWS_BUCKET=your-bucket AWS_AMI_NAME=fl-rhel-gold
sudo -E ./scripts/compose.sh ami
```

Compose can take a long time. Keep the builder VM running until the artifact appears.

---

## Phase 4 — Deploy to cloud

| Target | Guide |
|---|---|
| AWS (fast PoC scripts) | [`solution/cloud/aws/README.md`](../solution/cloud/aws/README.md) |
| AWS | [`solution/cloud/aws-deploy.md`](../solution/cloud/aws-deploy.md) |
| Azure | [`solution/cloud/azure-deploy.md`](../solution/cloud/azure-deploy.md) |

**AWS without a pre-built AMI:** order RHDP **AWS Blank OPEN**, fill `solution/cloud/aws/env.local`, run `./launch-ec2.sh` then `./verify-remote.sh`.

Security group / NSG: inbound **TCP 2222** and **TCP 35443** from your IP only.

```bash
ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<PUBLIC_IP>
```

---

## Phase 5 — Prove Expansion Pack checklist

On the cloud VM (first boot runs `fl-gold-firstboot.service` — wait ~1–2 minutes for httpd container):

```bash
curl -s http://127.0.0.1:35443/
findmnt /var/log /home /tmp /var/tmp
getenforce
ss -tlnp | grep -E '2222|35443'
sudo firewall-cmd --list-all
sudo bash /path/to/repo/solution/scripts/verify-gold-image.sh
sudo reboot
# re-check curl + verify after reboot
```

---

## Phase 6 — Clean up

Shut down / delete the RHDP OPEN environment. Never commit cloud credentials or password hashes to Git.
