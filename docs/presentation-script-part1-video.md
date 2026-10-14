# 15-minute speaker script — Part 1 (Recorded video)  
## RHEL Golden Image + Insights · No Ansible

**Presenter:** Yash Dandge, Junior Consultant, Red Hat  
**Branch:** `rhel-image-builder-insights`  
**Timebox:** 15 minutes  

> Tip: Have the blueprint open in an editor, Day-2 runbook ready, and inventory-sync running locally (`uvicorn`) before you hit record.

---

## Opening (1:30)

**Why we’re here**  
“This is my Part 1 practice for Fedora Lane. They asked Red Hat to help with hybrid complexity: drifted Linux across data centers, boutiques, and cloud, which blocks modernization and makes PCI/GDPR/CCPA evidence hard.”

**Intro**  
“I’m Yash Dandge, Junior Consultant. My TDP focus is **RHEL**. I’m not using Ansible in this pilot — the solution is a **golden image plus Insights**.”

**Confirm the problem**  
“Virginia and Frankfurt on VMware, boutique closets, AWS and Azure Linux — without one standard OS build, Casey can’t enforce baselines, Alex’s team fires tickets, and Ren can’t see posture cleanly.”

**Objective + agenda**  
“I’ll show the Image Builder blueprint, the Day-2 patch story, and a sample Boutique Inventory Sync API on that RHEL pattern. Walkthrough, value, one next step.”

---

## Live walkthrough (8:00)

### 1. Approach (1:00)

“Day-0 consistency from **Image Builder**. Day-2 from **Insights** and security updates. Sample app from the Core Pack — inventory sync between SAP and PoS — runs on that RHEL baseline.”

### 2. Show blueprint (2:30)

Open `solution/image-builder/fl-rhel-baseline.toml`.

**Tell → show → tell**  
- **Tell:** “This is the approved birth certificate for a Fedora Lane RHEL host.”  
- **Show:** packages (chrony, firewalld, insights-client, cockpit, podman), NTP, sshd/firewall ports.  
- **Tell:** “Casey gets one standard; boutiques and cloud stop starting as snowflakes.”

Optional: `./solution/scripts/validate-blueprint.sh`

### 3. Image Builder compose story (1:30)

Walk `solution/image-builder/README.md` commands (or run compose if you have a builder).

“Output can be qcow2 for VMware labs or AMI for AWS — same blueprint, hybrid-ready.”

### 4. Day-2 / Insights (1:30)

Open `docs/runbook-rhel-day2.md`.

“Register with subscription-manager, `insights-client --register`, then `dnf update --security` for Critical/High within days — Core Pack policy. No Ansible required for this path.”

### 5. Sample app (1:30)

```bash
curl -s http://127.0.0.1:8080/health | jq .
curl -s http://127.0.0.1:8080/api/v1/sync/status | jq .
```

“Boutique Inventory Sync pattern — SAP stays; we prove a modern service on standard RHEL.”

---

## Value summary (3:00)

| Stakeholder | Value |
|---|---|
| **Casey** | Enforceable RHEL standard via image |
| **Alex** | Predictable builds; clear patch runbook |
| **Ren** | Insights on every new host; faster audit evidence |
| **Cameron** | Known OS under services |
| **Anya** | Small, real milestone — not a platform science project |

**Future:** “When we’re ready, Ansible or system roles can fight drift *after* day 0. Image first keeps the door open.”

---

## Closing (1:30)

**Core message**  
“Fedora Lane’s Linux estate needs one RHEL golden image and Insights-backed lifecycle — consistency without waiting on automation coding.”

**One next step**  
“Workshop with Casey to freeze the v1 blueprint package set and build the first qcow2 for Virginia lab.”

**Close**  
“That’s Part 1 — feedback welcome. Thank you.”

---

## Timing

| Segment | Target |
|---|---|
| Opening | 1:30 |
| Walkthrough | 8:00 |
| Value | 3:00 |
| Closing | 1:30 |
