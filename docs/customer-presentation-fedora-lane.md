# Fedora Lane — Expansion Pack technical solution  
## Google Slides deck (TDP Part 1 structure)

**File:** [`Fedora-Lane-Expansion-Pack-Technical-Solution.pptx`](./Fedora-Lane-Expansion-Pack-Technical-Solution.pptx)  
**Spoken script:** [`presentation-script-part1-video.md`](./presentation-script-part1-video.md)  
**Duration:** ~15 minutes  

---

## Open in Google Slides

1. Upload the `.pptx` to [Google Drive](https://drive.google.com)  
2. Right-click → **Open with** → **Google Slides** → **Save as Google Slides**  
3. Share with stakeholders  

---

## Mapped to Junior Consultant deliverables

| Required segment | Time | Slides | Covered |
|---|---|---|---|
| **Opening** — why here, team, confirm challenges, objective, agenda, transition | 1–2 min | 1–4 | Yes |
| **Live walkthrough** — challenges understood, what we built in action, critical decisions | 5–10 min | 5–8 | Yes (demo on live VM during slides 7–8) |
| **Value summary** — challenges addressed + future possibilities | 2–5 min | 9–10 | Yes |
| **Closing** — core message, reiterate value, **one** concrete next step | 1–2 min | 11–13 | Yes |

### Slide list

| # | Section | Title |
|---|---|---|
| 1 | — | Title |
| 2 | Opening | Why we are here (team + objective) |
| 3 | Opening | Challenges we confirm with you |
| 4 | Opening | Agenda → transition to walkthrough |
| 5 | Walkthrough | What we implemented |
| 6 | Walkthrough | Critical decisions — and why |
| 7 | Walkthrough | Live path (end-user view) |
| 8 | Walkthrough | What we prove on the live VM |
| 9 | Value | How this addresses Fedora Lane’s challenges |
| 10 | Value | What this leaves open for the future |
| 11 | Closing | Core message |
| 12 | Closing | One concrete next step (non-prod pilot) |
| 13 | — | Thank you / Q&A |

### Repo deliverables (outside the deck)

| Requirement | Where |
|---|---|
| Git source of truth + README how to run | Root `README.md` |
| Assets (scripts, blueprints) — no credentials | `solution/` |
| Working live deployment | AWS AMI / Azure image + verify scripts |
| Solution overview (architecture ↔ challenges) | `docs/solution-overview.md` |
