# Fedora Lane — Junior Consultant Deliverables  
## FASTER Core Pack (CY26/27) · **Branch: RHEL Image Builder + Insights**

**Role:** Junior Consultant  
**Customer:** Fedora Lane (fictional)  
**TDP focus on this branch:** **Red Hat Enterprise Linux** (no Ansible required)  
**Git hosting:** GitHub — https://github.com/ydandge-oss/fedora-lane-core-pack-faster  

> Fictional FASTER practice content. For internal learning only.  
> Branch `main` keeps the earlier Ansible-oriented pilot. **This branch** is the RHEL golden-image path.

---

## Junior Consultant deliverables (Core Pack)

| # | Deliverable | Location |
|---|---|---|
| 1 | Technical solution | `solution/` — Image Builder blueprint, Kickstart, inventory-sync on RHEL |
| 2 | Solution overview | [docs/solution-overview.md](./docs/solution-overview.md) |
| 3 | 15-min Part 1 (video) | [docs/presentation-script-part1-video.md](./docs/presentation-script-part1-video.md) |
| 4 | 15-min Part 2 (live) | [docs/presentation-script-part2-live.md](./docs/presentation-script-part2-live.md) |
| 5 | Follow-up email | [docs/follow-up-email.md](./docs/follow-up-email.md) |

Supporting: [docs/runbook-rhel-day2.md](./docs/runbook-rhel-day2.md) · [docs/sme-qa-prep.md](./docs/sme-qa-prep.md)

---

## Solution in one sentence

Give Fedora Lane an **approved RHEL golden image** (Image Builder) plus **Insights-backed Day-2 patching** so DC, boutique, and cloud Linux hosts start consistent and stay patchable — without Ansible.

---

## Proof of Concept (run this for demos)

```bash
chmod +x poc/run-poc.sh solution/scripts/*.sh
./poc/run-poc.sh
# Opens/writes: poc/output/evidence-report.md
# API stays on http://127.0.0.1:8080 — stop with: ./poc/run-poc.sh --cleanup
```

Full PoC guide: [poc/README.md](./poc/README.md)

Optional UBI container mode (needs Podman machine): `./poc/run-poc.sh --container`

Image Builder compose (real RHEL builder): [solution/image-builder/README.md](./solution/image-builder/README.md).

---

## Branch map

| Branch | Story |
|---|---|
| `main` | Ansible inventory + baseline pilot (optional later) |
| `rhel-image-builder-insights` (**this**) | RHEL golden image + Insights + app on RHEL — **no Ansible** |

```bash
git fetch origin
git checkout rhel-image-builder-insights
```
