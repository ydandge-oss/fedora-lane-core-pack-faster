# SME Q&A — Casey / Alex (Server/Cloud OS)

### Why not hosted Image Builder?
Expansion Pack requires a **manual** gold image. We use Kickstart and/or **local** Image Mode (`bootc` + local `bootc-image-builder`) — not console.redhat.com hosted builds.

### Kickstart or Image Mode?
Kickstart = fastest checklist-native gold image. Image Mode = better Day-2 for ~1,600 hosts. Same security controls; pick one to prove live, keep both in Git.

### Why will this fix the 600 failed patches story?
One OS major/minor + one agent/tooling baseline on the web tier removes “wrong libraries / missing agent / custom kernels” variance for that fleet segment.

### How does this stop undocumented SSH changes?
It doesn’t replace process alone — but key-only SSH, no root, passworded sudo, and a known baseline shrink the blast radius. Next: Session Recording + Web Console.

### Why httpd in a container?
Expansion Pack asked for it if possible, and it lets ops use **systemd** instead of copying fragile `podman run` lines (Challenge 3).

### Why non-standard ports?
Required by pack; also reduces internet noise on 22/80.

### Can boutiques use this image?
Web-tier gold image first; boutique Closet images can fork the same Kickstart with smaller disk profiles later.

### Day-2 patching?
Rebuild gold image when CVEs land; rolling replace web nodes. Insights optional next phase.
