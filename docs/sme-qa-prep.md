# SME Q&A — Casey / Alex (Server/Cloud OS)

### Why not hosted Image Builder?
Expansion Pack requires a **manual** gold image. We use **local** RHEL Image Builder on a builder VM (`image-builder` CLI + blueprint TOML) — not console.redhat.com hosted builds.

### Why Image Builder (not Kickstart / bootc)?
Matches Red Hat’s [composing a customized RHEL system image](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/composing_a_customized_rhel_system_image/image-builder-description) procedure and produces cloud-native `ami`/`vhd` directly. Kickstart and Image Mode remain in the repo as alternate factories with the same Expansion Pack controls.

### Why will this fix the 600 failed patches story?
One OS major/minor + one agent/tooling baseline on the web tier removes “wrong libraries / missing agent / custom kernels” variance for that fleet segment.

### How does this stop undocumented SSH changes?
It doesn’t replace process alone — but key-only SSH, no root, passworded sudo, and a known baseline shrink the blast radius. Next: Session Recording + Web Console.

### Why httpd in a container?
Expansion Pack asked for it if possible, and it lets ops use **systemd** instead of copying fragile `podman run` lines (Challenge 3).

### Why non-standard ports?
Required by pack; also reduces internet noise on 22/80.

### Can boutiques use this image?
Web-tier gold image first; boutique Closet images can fork the same blueprint with smaller disk profiles later.

### Day-2 patching?
Re-compose the blueprint when CVEs land; rolling replace web nodes. Insights optional next phase.
