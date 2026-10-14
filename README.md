# Fedora Lane — Server/Cloud OS TDP  
## Junior Consultant · Dual gold-image solution

**Branch:** `expansion-tdp-solution`  
**GitHub:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

Two **manual** factories (no hosted Image Builder):

| Path | Tech | Location |
|---|---|---|
| **A** | Kickstart gold image | [`solution/kickstart/`](./solution/kickstart/) |
| **B** | RHEL 10 Image Mode (bootc) | [`solution/image-mode/`](./solution/image-mode/) |

Shared: httpd container assets, verify script, AWS/Azure deploy notes, presentations.

> Private repo preferred. Add **`mflaim-eng`**. Never commit cloud/RHDP secrets.

---

## Deliverables

| Item | Path |
|---|---|
| PoC index (both paths) | [`docs/poc-steps.md`](./docs/poc-steps.md) |
| Kickstart PoC | [`docs/poc-steps-kickstart.md`](./docs/poc-steps-kickstart.md) |
| Image Mode PoC | [`docs/poc-steps-image-mode.md`](./docs/poc-steps-image-mode.md) |
| Compare paths | [`docs/kickstart-vs-image-mode.md`](./docs/kickstart-vs-image-mode.md) |
| Solution overview | [`docs/solution-overview.md`](./docs/solution-overview.md) |
| Part 1 video script | [`docs/presentation-script-part1-video.md`](./docs/presentation-script-part1-video.md) |
| Part 2 live script | [`docs/presentation-script-part2-live.md`](./docs/presentation-script-part2-live.md) |
| Verification | [`docs/verification-checklist.md`](./docs/verification-checklist.md) |
| Follow-up email | [`docs/follow-up-email.md`](./docs/follow-up-email.md) |

---

## Expansion Pack checklist (both paths target)

- Manual build (not hosted Image Builder)  
- AWS or Azure deployable  
- httpd + index.html **in a container** on **35443**  
- Separate `/var/log`, `/home`, `/tmp`, `/var/tmp` (&lt; 5 GiB); `/tmp` **noexec**  
- SELinux enforcing; SSH **2222**; key-only; no root SSH  
- `fladmins` + sudo always prompts  
- Firewall: only SSH + httpd ports  
- Survive reboot  

---

## Quick start

```bash
git checkout expansion-tdp-solution

# Path A
open docs/poc-steps-kickstart.md

# Path B
open docs/poc-steps-image-mode.md
# cd solution/image-mode && ./scripts/build-bootc.sh
```

**Demo tip:** Fully prove **one** path on RHDP cloud; use the other as the scale / alternative factory story (Kickstart = first standard; Image Mode = 1,600-server Day-2).
