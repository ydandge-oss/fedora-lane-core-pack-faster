# Fedora Lane — Expansion Pack technical solution  
## Google Slides deck (TDP Part 1 structure)

**File:** [`Fedora-Lane-Expansion-Pack-Technical-Solution.pptx`](./Fedora-Lane-Expansion-Pack-Technical-Solution.pptx)  
**Spoken script:** [`presentation-script-part1-video.md`](./presentation-script-part1-video.md)  
**How to build:** [`how-to-build-and-run.md`](./how-to-build-and-run.md)  
**Duration:** ~15 minutes  

---

## Open in Google Slides

1. Upload the `.pptx` to [Google Drive](https://drive.google.com)  
2. Right-click → **Open with** → **Google Slides** → **Save as Google Slides**  

---

## Slide list (14)

| # | Section | Title |
|---|---|---|
| 1 | — | Title |
| 2 | Opening | Why we are here |
| 3 | Opening | Challenges we confirm |
| 4 | Opening | Agenda |
| 5 | Walkthrough | What we implemented |
| 6 | Walkthrough | **Solution architecture** (TOML → Builder → .raw → AMI → VMs) |
| 7 | Walkthrough | **Build steps** (what we run) |
| 8 | Walkthrough | Critical decisions — and why |
| 9 | Walkthrough | What we prove on the live VM |
| 10 | Value | Challenges addressed |
| 11 | Value | Future possibilities |
| 12 | Closing | Core message |
| 13 | Closing | One concrete next step |
| 14 | — | Thank you / Q&A |

### Slide 6 — architecture flow (like reference)

```text
TOML (rhel-10.x) → Local Image Builder → Gold disk (.raw)
        → AWS AMI (+ Azure VHD) → Web nodes (identical launches)
```

**On every VM:** SSH :2222 · httpd Podman :35443 · SELinux · firewall · `/tmp` noexec  

### Slide 7 — build steps

1. Blueprint in Git  
2. Builder + `rhc connect`  
3. Compose → `.raw`  
4. Upload + `vmimport` → AMI  
5. Launch EC2  
6. Prove (SSH + curl + verify)  
