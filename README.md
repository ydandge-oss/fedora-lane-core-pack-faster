# Fedora Lane — Junior Consultant Deliverables  
## FASTER Core Pack (CY26/27)

**Role:** Junior Consultant  
**Customer:** Fedora Lane (fictional)  
**Source:** *Fedora Lane Core Pack for Solution Architects and Consultants*  
**Git hosting:** GitHub (practice substitute for Consulting GitLab)

> Fictional FASTER practice content. For internal learning only. Do not distribute as official Red Hat collateral.

This repository is **Core Pack only**. It does **not** include any TDP Expansion Pack (for example OpenShift Bare Metal). The Core Pack defines the customer, challenges, stakeholders, and the junior consultant deliverable shape. When your Expansion Pack arrives for a specific TDP, fold that TDP’s build requirements into `solution/` and refresh the walkthrough sections.

---

## Junior Consultant deliverables (from the Core Pack)

| # | Deliverable | Location |
|---|---|---|
| 1 | **Technical solution** — Git repo + README + deploy assets + working demo | this repo (`solution/`) |
| 2 | **Project documentation** — solution overview tied to Fedora Lane challenges | [docs/solution-overview.md](./docs/solution-overview.md) |
| 3 | **15-minute presentation** — opening, live walkthrough, value summary, closing | [docs/presentation-script-part1-video.md](./docs/presentation-script-part1-video.md) · [docs/presentation-script-part2-live.md](./docs/presentation-script-part2-live.md) |
| 4 | **Follow-up email** — within 2 days after the live call | [docs/follow-up-email.md](./docs/follow-up-email.md) |

Process reminder:

- **Part 1:** record practice presentation + submit deliverables  
- **Part 2:** live POD presentation; SMEs play **Casey Novak** and **Alex Lee**  
- Submit **individually** even if you collaborated  

---

## What this practice solution demonstrates (Core Pack challenges)

Fedora Lane’s Core Pack pain is hybrid/multi-cloud complexity without unified management → **configuration drift**, **automation friction**, blocked **e-commerce modernization**, weak **portability**, **COTS constraints**, and **security/audit** toil.

This repo implements a **Platform Consistency Pilot** you can run locally:

1. **Ansible** inventories + playbooks that model NA DC / EMEA DC / boutique / cloud Linux hosts and apply a consistent baseline (Casey + Alex).  
2. A **Boutique Inventory Sync** sample service (named in the Core Pack) you can run with Docker Compose to show a repeatable, portable modern app path (Cameron) with a clear security story (Ren).

When a TDP Expansion Pack is released, replace or extend `solution/` with that TDP’s required Red Hat technology while keeping the customer narrative here.

---

## Quick start — working demo (local)

### Prerequisites

- Python 3.11+  
- `pip install -r solution/requirements.txt` (Ansible)  
- Optional: Docker + Docker Compose for the inventory-sync API (local `uvicorn` also works)  

### 1. Ansible baseline (config-as-code)

```bash
cd solution/ansible
python3 -m venv .venv && source .venv/bin/activate
pip install -r ../requirements.txt

# Dry-run against the local demo inventory (no real Fedora Lane servers)
ansible-inventory -i inventory/hosts.yml --graph
ansible-playbook -i inventory/hosts.yml playbooks/site.yml --check
```

### 2. Boutique Inventory Sync API

```bash
cd solution/inventory-sync
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
export SYNC_API_TOKEN=demo-not-a-real-secret
uvicorn app.main:app --host 127.0.0.1 --port 8080
# other terminal:
curl -s http://127.0.0.1:8080/health | jq .
curl -s http://127.0.0.1:8080/api/v1/sync/status | jq .
```

Or with Docker: `docker compose up --build -d` from `solution/inventory-sync/`.

---

## Folder map

```
README.md
DELIVERABLES-CHECKLIST.md
docs/
  customer-brief-fedora-lane.md
  challenges-and-stakeholders.md
  solution-overview.md
  presentation-script-part1-video.md   ← rehearse / record this
  presentation-script-part2-live.md    ← live POD call
  presentation-slides.md
  follow-up-email.md
  success-criteria.md
  sme-qa-prep.md
solution/
  README.md
  requirements.txt
  ansible/          ← inventories + playbooks
  inventory-sync/   ← sample microservice + Compose
```

---

## How presentations work

| Part | Script | Audience |
|---|---|---|
| Part 1 — recorded practice | [presentation-script-part1-video.md](./docs/presentation-script-part1-video.md) | You + AI feedback / manager / FASTER team |
| Part 2 — live POD | [presentation-script-part2-live.md](./docs/presentation-script-part2-live.md) | SMEs as Casey Novak & Alex Lee |

Both scripts are **15 minutes** and follow Core Pack structure: Opening → Walkthrough → Value summary → Closing.
