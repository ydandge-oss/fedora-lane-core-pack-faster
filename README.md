# Fedora Lane — Server/Cloud OS TDP  
## Junior Consultant · Expansion Pack gold image

**Branch:** `expansion-tdp-solution`  
**GitHub:** https://github.com/ydandge-oss/fedora-lane-core-pack-faster/tree/expansion-tdp-solution  

**Primary factory:** local **RHEL Image Builder** (blueprint → compose `ami` / `vhd`) on a RHEL VM — per [Red Hat docs](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description).

**Not** hosted Image Builder at console.redhat.com.

| Path | Tech | Location |
|---|---|---|
| **Primary** | RHEL Image Builder (local CLI) | [`solution/image-builder/`](./solution/image-builder/) |
| Alt A | Kickstart | [`solution/kickstart/`](./solution/kickstart/) |
| Alt B | RHEL 10 Image Mode (bootc) | [`solution/image-mode/`](./solution/image-mode/) |

Shared: verify script, AWS/Azure deploy notes, presentations.

> Private repo preferred. Add **`mflaim-eng`**. Never commit cloud/RHDP secrets.

---

## Deliverables

| Item | Path |
|---|---|
| **Image Builder PoC (primary)** | [`docs/poc-steps-image-builder.md`](./docs/poc-steps-image-builder.md) |
| PoC index | [`docs/poc-steps.md`](./docs/poc-steps.md) |
| Kickstart PoC (alt) | [`docs/poc-steps-kickstart.md`](./docs/poc-steps-kickstart.md) |
| Image Mode PoC (alt) | [`docs/poc-steps-image-mode.md`](./docs/poc-steps-image-mode.md) |
| Solution overview | [`docs/solution-overview.md`](./docs/solution-overview.md) |
| Part 1 video script | [`docs/presentation-script-part1-video.md`](./docs/presentation-script-part1-video.md) |
| Part 2 live script | [`docs/presentation-script-part2-live.md`](./docs/presentation-script-part2-live.md) |
| Verification | [`docs/verification-checklist.md`](./docs/verification-checklist.md) |
| Follow-up email | [`docs/follow-up-email.md`](./docs/follow-up-email.md) |

---

## Expansion Pack checklist

- Manual build (local Image Builder — not hosted)  
- AWS or Azure deployable (`ami` / `vhd`)  
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

# On a subscribed RHEL 10 builder VM:
cd solution/image-builder
sudo ./scripts/install-image-builder.sh
./scripts/generate-blueprint.sh
# edit fl-rhel-gold.toml — set real SSH public keys
sudo ./scripts/compose.sh ami    # or: vhd | qcow2

open docs/poc-steps-image-builder.md
```

**Demo tip:** Prove Image Builder end-to-end on RHDP cloud; mention Kickstart / Image Mode as alternate factories if asked.
