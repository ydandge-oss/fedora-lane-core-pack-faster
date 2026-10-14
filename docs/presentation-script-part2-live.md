# 15-minute speaker script — Part 2 (Live POD)  
## RHEL Golden Image + Insights · No Ansible

**Presenter:** Yash Dandge, Junior Consultant, Red Hat  
**Audience:** Alex Lee, Casey Novak (SME personas)  
**Branch:** `rhel-image-builder-insights`  

> Speak to Alex and Casey by name. Pre-start inventory-sync. Blueprint + runbook on screen.

---

## Opening (1:30)

“Thanks for the time. We’re here because Fedora Lane’s hybrid Linux estate drifts across Virginia, Frankfurt, boutiques, and cloud — and that hurts modernization and audits.”

“I’m Yash Dandge, Junior Consultant. For this RHEL TDP pilot I built a **golden image with Image Builder** and an **Insights Day-2 path** — deliberately **without Ansible** so we can deliver consistency first.”

“Today: live walkthrough, value for your teams, one next step. Deep questions after; I’ll email anything we park within two days.”

---

## Live walkthrough (8:00)

### Architecture (45s)

“Git holds the Image Builder blueprint. We compose qcow2 or AMI. Hosts register to Insights. A Boutique Inventory Sync service shows an app on that baseline — SAP untouched.”

### Decision (45s)

“Casey, Alex — I chose **image-first** over automation-first. You get a reviewable standard now; we can add Ansible later for ongoing drift.”

### Show blueprint (2:30)

Open `fl-rhel-baseline.toml` — packages, chrony, Insights client, firewall, podman.

### Show Day-2 (2:00)

`docs/runbook-rhel-day2.md` — register, Insights, `dnf update --security`.

“That’s how we meet Critical/High within days without SSH snowflake patching.”

### Show app (2:00)

```bash
curl -s http://127.0.0.1:8080/health | jq .
curl -s http://127.0.0.1:8080/api/v1/sync/status | jq .
```

### What we didn’t do (30s)

“No SAP migration, no Ansible dependency, no claim we solved post-day-0 drift forever — that’s Phase 2.”

---

## Value summary (3:00)

| Stakeholder | Value |
|---|---|
| Casey | One RHEL standard |
| Alex | Manageable factory + patch runbook |
| Ren | Insights from day 0 |
| Cameron | Predictable OS for services |
| Anya | Real milestone |

---

## Closing (1:30)

“Core message: approved RHEL golden image plus Insights is the practical first step for Fedora Lane’s Linux consistency.”

“**One next step:** 90-minute workshop with you both to freeze v1 blueprint and schedule the first Virginia lab compose.”

“Follow-up email in two days with repo branch link and parking-lot answers. Questions?”

---

## Timing

| Segment | Target |
|---|---|
| Opening | 1:30 |
| Walkthrough | 8:00 |
| Value | 3:00 |
| Closing | 1:30 |
