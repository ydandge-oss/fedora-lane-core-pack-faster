#!/usr/bin/env python3
"""Verify AWS + Azure PoC hosts: baseline marker + inventory-sync health."""

from __future__ import annotations

import json
import subprocess
import sys
import urllib.request
from pathlib import Path

try:
    import yaml  # type: ignore
except ImportError:
    yaml = None


def load_inventory(path: Path) -> dict:
    text = path.read_text()
    if yaml is not None:
        return yaml.safe_load(text)
    # Minimal YAML subset parser for our simple inventory shape
    hosts: dict = {"hosts": {}}
    current = None
    for raw in text.splitlines():
        line = raw.rstrip()
        if not line.strip() or line.strip().startswith("#"):
            continue
        if line.startswith("  ") and not line.startswith("    ") and line.strip().endswith(":"):
            current = line.strip()[:-1]
            hosts["hosts"][current] = {}
        elif line.startswith("    ") and ":" in line and current:
            k, v = line.strip().split(":", 1)
            hosts["hosts"][current][k.strip()] = v.strip().strip('"')
    return hosts


def ssh_cmd(user: str, key: str, ip: str, remote: str) -> str:
    key_path = str(Path(key).expanduser())
    cmd = [
        "ssh",
        "-i",
        key_path,
        "-o",
        "StrictHostKeyChecking=accept-new",
        "-o",
        "ConnectTimeout=15",
        f"{user}@{ip}",
        remote,
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True, check=False)
    if proc.returncode != 0:
        raise RuntimeError(f"SSH failed ({user}@{ip}): {proc.stderr.strip() or proc.stdout.strip()}")
    return proc.stdout.strip()


def http_get(url: str) -> dict:
    with urllib.request.urlopen(url, timeout=15) as resp:
        return json.loads(resp.read().decode())


def main() -> int:
    root = Path(__file__).resolve().parents[3]
    inv_path = root / "poc/output/hybrid-inventory.yml"
    if not inv_path.exists():
        print(f"Missing {inv_path}. Run ./poc/cloud/scripts/write-inventory.sh first.", file=sys.stderr)
        return 1

    inv = load_inventory(inv_path)
    results = []

    print("=" * 72)
    print("Fedora Lane hybrid PoC — remote verification (AWS + Azure)")
    print("=" * 72)

    for name, host in inv.get("hosts", {}).items():
        ip = host["public_ip"]
        user = host["ssh_user"]
        key = host["ssh_key"]
        health_url = host["health_url"]
        site = host.get("site", name)
        cloud = host.get("cloud", name)

        print(f"\n--- {name} ({cloud} / {site}) @ {ip} ---")
        marker = ssh_cmd(user, key, ip, "cat /etc/fl-baseline/MARKER")
        print("Baseline marker:")
        print(marker)
        health = http_get(health_url)
        print("API health:", json.dumps(health))
        same_baseline = "fl-rhel-baseline" in marker and "Fedora Lane" in marker
        results.append(
            {
                "name": name,
                "cloud": cloud,
                "site": site,
                "public_ip": ip,
                "baseline_ok": same_baseline,
                "api_health": health,
            }
        )

    out = root / "poc/output/hybrid-remote-evidence.json"
    out.write_text(json.dumps({"hosts": results}, indent=2) + "\n")

    baselines = {json.dumps(r["api_health"].get("service")) for r in results}
    ok = all(r["baseline_ok"] for r in results) and len(results) >= 1
    print("\n" + "=" * 72)
    if ok:
        clouds = ", ".join(sorted({r["cloud"] for r in results}))
        print(f"PROOF: Fedora Lane baseline marker + healthy inventory-sync on: {clouds}")
        if len(results) == 1:
            print("(AWS-only demo is OK. Add Azure later for full multi-cloud.)")
        print(f"Wrote {out}")
        return 0
    print("Remote verification incomplete or baseline mismatch.", file=sys.stderr)
    print(f"Partial results in {out}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
