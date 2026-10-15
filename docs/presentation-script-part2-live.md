# 15-minute script — Part 2 (Live)  
## Primary: RHEL Image Builder

**Audience:** Casey Novak / Alex Lee  

---

## Opening (1:30)

“Thanks for the time. Your Expansion Pack asks for a manual RHEL gold image for the e-commerce web fleet — not hosted Image Builder.

We used **local RHEL Image Builder**: a TOML blueprint on a builder VM, composed to **AMI** or **VHD**, then proved on RHDP cloud. I’ll walk the blueprint and show the live checks.”

---

## Walkthrough (8:00)

### Decision (45s)

“Alex, Casey — Image Builder is Red Hat’s supported compose path for cloud images. One blueprint, repeatable `ami`/`vhd`, Expansion Pack controls baked in.”

### Live primary (5:30)

Cloud VM: SSH 2222, mounts, SELinux, firewall, httpd container 35443, verify script, reboot story.  
Optional: show `image-builder list` / compose command from the builder VM recording.

### If asked about alternates (1:45)

Kickstart and Image Mode (bootc) are in the same repo as alternate factories — same checklist.

---

## Value (3:00)

Casey — standard + container via systemd  
Alex — deployable AMI/VHD from one blueprint  
Ren — SELinux, noexec tmp, minimal ports  
Cameron — predictable web baseline  
Anya — milestone now; scale by re-composing the blueprint  

---

## Closing (1:30)

“**One next step:** pilot the Image Builder gold image on non-prod web this month.

Follow-up email in two days with repo and parking-lot answers. Questions?”
