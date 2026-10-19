# Fedora Lane — Expansion Pack technical solution  
## Google Slides deck

**File to upload:** [`Fedora-Lane-Expansion-Pack-Technical-Solution.pptx`](./Fedora-Lane-Expansion-Pack-Technical-Solution.pptx)  
**Audience:** Alex Lee, Casey Novak, Ren Tanaka, Cameron Shaw, Anya Sharma  
**Duration:** ~15 minutes  
**Spoken script:** [`presentation-script-part1-video.md`](./presentation-script-part1-video.md)  
**Git:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

---

## Open in Google Slides (recommended)

1. Go to [Google Drive](https://drive.google.com) → **New** → **File upload**  
2. Upload `docs/Fedora-Lane-Expansion-Pack-Technical-Solution.pptx`  
3. Right-click the file → **Open with** → **Google Slides**  
4. **File → Save as Google Slides** (so it becomes a native Slides file you can share)  
5. Share with stakeholders (Viewer or Commenter)

Or: [slides.google.com](https://slides.google.com) → **Blank presentation** → **File → Import slides** → upload the `.pptx`.

---

## Slide list (13)

| # | Title | Talking point |
|---|---|---|
| 1 | Title | Fedora Lane Expansion Pack — RHEL gold image (local Image Builder); AWS + Azure |
| 2 | Agenda | Challenges → solution → path → controls → ops → scale → next |
| 3 | Challenges | Inconsistent estate · risky change · container skills gap |
| 4 | Solution | Blueprint in Git → compose AMI/VHD → launch identical gold VMs |
| 5 | Architecture | Controls → blueprint → Image Builder → AMI + VHD → gold VM |
| 6 | Path to VM | Blueprint → compose → register → launch → firstboot → verify |
| 7 | Controls | Partitions · noexec · SELinux · SSH 2222 · httpd:35443 · fladmins |
| 8 | Console / CLI | AWS (us-east-2 + User data) · Azure (managed image + NSG) |
| 9 | Evidence | Live verify + reboot proven on AWS and Azure |
| 10 | Scale | Freeze image · launch waves · replace · recompose for Day-2 |
| 11 | Value | Map each challenge → deliverable |
| 12 | Next phase | Non-prod pilot ask · optional OpenSCAP / Kickstart / Image Mode |
| 13 | Close | Repo link · Q&A |

---

## Speaker cue cards (short)

**Slide 4–5:** One gold recipe in Git; local Image Builder (not hosted console); dual-cloud outputs.

**Slide 6–8:** SG/NSG *opens* 2222/35443; firstboot/User data *starts* httpd — both required.

**Slide 10:** Do not compose 1,600 times — freeze once, replace in waves.

**Slide 12 ask:** Approve non-prod pilot using the gold image as the web OS standard.
