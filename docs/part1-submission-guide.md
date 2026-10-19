# Part 1 practice submission — Server/Cloud OS TDP

Use this when the RHSH practice activity and Google form are open.

**Due (unless FASTER says otherwise):** EMEA / APAC **Oct 19**; Americas was Oct 13. Confirm your calendar invite titled *Server/Cloud OS TDP Practice Activity Part 1*.

---

## What to submit on the Google form

Select topic: **Server/Cloud OS TDP**

| Field | What to paste |
|---|---|
| RHSH recording link | From the RHSH activity (follow their “retrieve link” instructions) |
| Git repository | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution |
| README / how to run | Same URL (root `README.md`) |
| Solution overview | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/solution-overview.md |
| Azure runbook (proven) | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/azure-gold-vhd-poc-runbook.md |
| AWS runbook (proven) | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/aws-gold-ami-poc-runbook.md |
| Verification checklist | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/verification-checklist.md |
| Presentation script | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/presentation-script-part1-video.md |
| Demo commands (compose → VM) | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/demo-commands-gold-image.md |
| Where / when / why commands | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/where-when-why-commands.md |
| Customer presentation (paste into Google Docs) | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/customer-presentation-fedora-lane.md |
| Slide outline | https://github.com/ydandge-oss/fedora-lane-core-pack-faster/blob/expansion-tdp-solution/docs/presentation-slides.md |

If your cohort also requires **Consulting GitLab (FASTER sub-group):** mirror or push the same `expansion-tdp-solution` branch there and submit **that** URL as the source of truth if the form asks for GitLab specifically.

---

## Before you record

1. Rehearse with [`presentation-script-part1-video.md`](./presentation-script-part1-video.md) (~15 min).  
2. Have a **live PoC VM** (Azure or AWS) or a recent verify terminal capture ready.  
3. Open GitHub README + blueprint in the browser.  
4. Confirm no secrets on screen (`env.local`, keys, passwords).  

---

## After submit

- Manager gets the form response automatically — expect feedback.  
- Share with your mentor if you want a second pass.  
- Part 2 live: use [`presentation-script-part2-live.md`](./presentation-script-part2-live.md); keep a fresh OPEN env for the call.  

---

## Deliverable coverage (self-check)

| Requirement | Status |
|---|---|
| Git repo + thorough README | Done (`README.md`) |
| Scripts / assets, no secrets | Done (`solution/…`, gitignored `env.local`) |
| Working deployment | Proven AWS AMI + Azure VHD |
| Solution overview (Markdown) | `docs/solution-overview.md` |
| 15-min presentation structure | `docs/presentation-script-part1-video.md` |
| Dual cloud (stretch) | Both proven |
