# 15-minute script — Part 1 (Video / RHSH recording)  
## Server/Cloud OS TDP · Junior Consultant · Gold Image

**Presenter:** Yash Dandge  
**Submit:** RHSH recording + GitHub link + docs — select **Server/Cloud OS TDP**

> Pre-record checklist: cloud VM up; SSH key ready; `curl :35443` works; verify script copied to VM.

---

## Opening (1:30)

“This is my Part 1 for the Fedora Lane Server/Cloud OS Expansion Pack.  
Fedora Lane runs about **1,600 servers** — 900 on-prem, 600 in AWS/Azure, 100 in boutiques — on Rocky, Ubuntu, CentOS Stream, and Amazon Linux. That inconsistency breaks patching, hides admin changes, and leaves ops struggling with containers.

I’m Yash Dandge, Junior Consultant. I built a **manual RHEL gold image** for their e-commerce web fleet — Kickstart-based, not hosted Image Builder — and deployed it to the cloud.

Today: walk through the image live, then map value to their three challenges.”

---

## Live walkthrough (8:00)

### 1. Challenges → approach (1:00)

“One RHEL gold image: separate log/home/tmp volumes, SELinux enforcing, SSH 2222, httpd **container** on 35443, firewall locked down, admins in `fladmins` with passworded sudo.”

### 2. Show repo / Kickstart (1:30)

Open GitHub `expansion-tdp-solution` → `solution/kickstart/fl-rhel-gold.ks`.

“Partitions under 5 GiB each for `/var/log`, `/home`, `/tmp`, `/var/tmp` with **noexec** on tmp paths. Security settings match the Expansion Pack checklist.”

### 3. SSH into cloud VM (2:00)

```bash
ssh -i ~/.ssh/fl-gold-admin -p 2222 fladmin1@<CLOUD_IP>
getenforce
findmnt /var/log /home /tmp /var/tmp
ss -ltn | grep -E '2222|35443'
```

**Tell → show → tell:** hardened, consistent host — not a boutique snowflake.

### 4. Containerized httpd (2:00)

```bash
podman ps
systemctl status fl-httpd --no-pager || true
curl -s http://127.0.0.1:35443/ | head
```

From laptop browser: `http://<CLOUD_IP>:35443/`

“Ops manage this with systemd — not a fragile multi-line podman command from a developer.”

### 5. Verify script / reboot story (1:30)

```bash
sudo bash verify-gold-image.sh
# mention: survived reboot in PoC; services enabled at boot
```

---

## Value summary (3:00)

| Challenge | Value shown |
|---|---|
| Inconsistency / failed patches | One RHEL standard for web tier |
| Untraceable changes | Key-only SSH, no root, sudo always prompts |
| Container gap | httpd as systemd-managed container |

“Future: Session Recording and Web Console for deeper audit; OpenSCAP CIS stretch; second cloud image.”

---

## Closing (1:30)

“Core message: Fedora Lane’s web fleet needs a **manual RHEL gold image** that is secure, partitioned, and container-ready — proven on cloud.

**One next step:** pilot this AMI/image on non-prod e-commerce web nodes with Casey and Alex.

Repo and docs are in the submission form. Thank you.”

---

## Timing

| Segment | Target |
|---|---|
| Opening | 1:30 |
| Walkthrough | 8:00 |
| Value | 3:00 |
| Closing | 1:30 |
