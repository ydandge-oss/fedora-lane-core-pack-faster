# 15-minute script — Part 2 (Live POD)  
## Server/Cloud OS TDP · Junior Consultant

**Audience:** SMEs as Casey Novak / Alex Lee  
**Demo env:** VM from your gold image on AWS or Azure Blank OPEN  

> Extend RHDP lifetime before the call. Have parking-lot notes ready.

---

## Opening (1:30)

“Thanks for the time. We’re here because Fedora Lane’s Linux estate — roughly **1,600 servers** across DCs, boutiques, AWS, and Azure — is inconsistent, hard to patch, and opaque when admins make out-of-band changes. Containers are also stacking risk onto Casey’s team.

I’m Yash Dandge, Junior Consultant. I’ve built and deployed a **manual RHEL gold image** for the e-commerce web tier per your Expansion Pack specs.

I’ll walk it live on cloud, then summarize value and one next step.”

---

## Live walkthrough (8:00)

### Architecture (45s)

“Kickstart gold image → imported to cloud → VM with SSH 2222, containerized httpd 35443, SELinux enforcing, separate volumes, tight firewall.”

### Decision (45s)

“Alex, Casey — we avoided hosted Image Builder per your pack. Manual Kickstart gives you a reviewable, repeatable factory you control.”

### Prove consistency (2:30)

```bash
ssh -p 2222 fladmin1@<CLOUD_IP>
getenforce
findmnt /tmp   # show noexec
cat /etc/fl-gold/MARKER
```

### Prove security (2:00)

```bash
grep -R Port /etc/ssh/sshd_config.d
sudo firewall-cmd --list-ports
# root SSH / password auth disabled — show config snippets
```

### Prove containers for ops (2:00)

```bash
podman ps
curl -s http://127.0.0.1:35443/
```

Browser from your machine to `:35443`.

“Same workload pattern Cameron’s team ships — operable for Linux admins via systemd.”

---

## Value summary (3:00)

| Stakeholder | Value |
|---|---|
| Casey | Standard RHEL web image; container as a service |
| Alex | Proven Day-0 image; cloud-deployed; reboot-safe |
| Ren | SELinux, noexec tmp, minimal ports, key-only SSH |
| Cameron | Path to run containerized web frontends consistently |
| Anya | Real milestone toward fewer vulnerable weeks after CVEs |

---

## Closing (1:30)

“Gold image is how we stop the OS lottery on the web fleet.

**One next step:** 2-day pilot — bake passwords/keys for your IdP, import AMI into non-prod, patch-drill one CVE against this baseline.

I’ll email within two days with the repo, verification results, and parking-lot answers. Questions?”

---

## Live tips

- If RHDP sleeps, have screenshots of verify output as backup — then narrate recovery.  
- Don’t live-edit sudoers on the call.  
- Park deep OpenSCAP questions for email unless stretch is ready.  
