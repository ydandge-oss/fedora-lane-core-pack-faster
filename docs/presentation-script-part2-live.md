# 15-minute script — Part 2 (Live)  
## Dual path: Kickstart + Image Mode

**Audience:** Casey Novak / Alex Lee  

---

## Opening (1:30)

“Thanks for the time. Your Expansion Pack asks for a manual RHEL gold image for the e-commerce web fleet — not hosted Image Builder.

We built **two** factories: **Kickstart** for a classic, checklist-solid image, and **RHEL 10 Image Mode** for the path to run that standard toward **1,600 servers**. I’ll prove one live on cloud.”

---

## Walkthrough (8:00)

### Decision (45s)

“Alex, Casey — Kickstart gets you a trusted AMI/VHD quickly. Image Mode uses bootc so Day-2 looks like container operations, which also helps the container skills gap.”

### Live primary (5:30)

Cloud VM: SSH 2222, mounts, SELinux, firewall, httpd container 35443, verify script, reboot story.

### Show other path (1:45)

Git walk of the non-primary factory. Same Expansion Pack controls.

---

## Value (3:00)

Casey — standard + container via systemd  
Alex — two deployable factories, cloud-proven  
Ren — SELinux, noexec tmp, minimal ports  
Cameron — predictable web baseline  
Anya — milestone now; scale path with Image Mode  

---

## Closing (1:30)

“**One next step:** pick Path A or B for non-prod web pilot this month; keep the other as the strategic factory.

Follow-up email in two days with repo and parking-lot answers. Questions?”
