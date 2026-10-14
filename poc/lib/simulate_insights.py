#!/usr/bin/env python3
"""Simulate Insights registration evidence for demo (no real RH account required)."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    out = Path(__file__).resolve().parents[1] / "output"
    out.mkdir(parents=True, exist_ok=True)

    report = {
        "simulated": True,
        "product": "Red Hat Insights (simulated for FASTER PoC)",
        "registered_at": datetime.now(timezone.utc).isoformat(),
        "baseline_image": "fl-rhel-baseline",
        "hosts": [
            {"name": "virginia-rhel-01", "site": "virginia", "status": "registered", "critical_cves": 0},
            {"name": "frankfurt-rhel-01", "site": "frankfurt", "status": "registered", "critical_cves": 0},
            {"name": "paris-boutique-01", "site": "paris", "status": "registered", "critical_cves": 1},
            {"name": "aws-ecom-linux-01", "site": "aws-us-east-1", "status": "registered", "critical_cves": 0},
        ],
        "policy": "Critical/High CVEs patched within days (Core Pack)",
        "next_action": "Schedule dnf update --security for paris-boutique-01 in maintenance window",
        "note": "Replace with real insights-client --register on Image Builder–built hosts in lab.",
    }

    path = out / "insights-simulated.json"
    path.write_text(json.dumps(report, indent=2) + "\n")
    print(json.dumps(report, indent=2))
    print(f"\nWrote {path}", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
