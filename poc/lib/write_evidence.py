#!/usr/bin/env python3
"""Write PoC evidence-report.md and evidence.json after a successful run."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: write_evidence.py <mode> [api_health_json]", file=sys.stderr)
        return 2

    mode = sys.argv[1]
    api_health = sys.argv[2] if len(sys.argv) > 2 else "{}"
    try:
        health = json.loads(api_health) if api_health else {}
    except json.JSONDecodeError:
        health = {"raw": api_health}

    root = Path(__file__).resolve().parents[2]
    poc = Path(__file__).resolve().parents[1]
    out = poc / "output"
    out.mkdir(parents=True, exist_ok=True)

    evidence = {
        "title": "Fedora Lane RHEL Golden Image — Proof of Concept Evidence",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "mode": mode,
        "branch": "rhel-image-builder-insights",
        "blueprint": str(root / "solution/image-builder/fl-rhel-baseline.toml"),
        "api_health": health,
        "challenges_addressed": [
            {
                "challenge": "Configuration drift / snowflake hosts",
                "proof": "Snowflake vs baseline profile comparison + Git-tracked blueprint",
            },
            {
                "challenge": "Unpredictable environments block modernization",
                "proof": "Boutique Inventory Sync API returned healthy status on baseline runtime",
            },
            {
                "challenge": "Security posture / audit difficulty",
                "proof": "Simulated Insights registration evidence for modeled hybrid hosts",
            },
            {
                "challenge": "CVE patching within days",
                "proof": "Day-2 runbook path (dnf security updates) documented and referenced",
            },
            {
                "challenge": "Hybrid / multi-cloud inconsistency",
                "proof": (
                    "AWS + Azure hosts verified with the same baseline marker and healthy API"
                    if mode == "remote"
                    else "Same baseline profile intended for VA, Frankfurt, boutique, AWS, and Azure; use --remote after terraform apply"
                ),
            },
        ],
        "stakeholder_value": {
            "Casey Novak": "One enforceable RHEL standard (blueprint)",
            "Alex Lee": "Predictable builds + clear Day-2 patch runbook",
            "Ren Tanaka": "Insights-from-birth story + evidence artifacts",
            "Cameron Shaw": "Portable app pattern on known OS",
            "Anya Sharma": "Small, demonstrable milestone — not a science project",
        },
        "next_step": "Freeze v1 blueprint with Casey; compose first qcow2 on a RHEL builder host for Virginia lab",
    }

    (out / "evidence.json").write_text(json.dumps(evidence, indent=2) + "\n")

    lines = [
        f"# {evidence['title']}",
        "",
        f"- **Generated:** {evidence['generated_at']}",
        f"- **Mode:** `{mode}`",
        f"- **Branch:** `{evidence['branch']}`",
        f"- **Blueprint:** `solution/image-builder/fl-rhel-baseline.toml`",
        "",
        "## API health (working deployment)",
        "",
        "```json",
        json.dumps(health, indent=2),
        "```",
        "",
        "## Challenges → proof",
        "",
        "| Challenge | Proof in this PoC |",
        "|---|---|",
    ]
    for row in evidence["challenges_addressed"]:
        lines.append(f"| {row['challenge']} | {row['proof']} |")

    lines += [
        "",
        "## Stakeholder expectations",
        "",
        "| Stakeholder | How PoC satisfies them |",
        "|---|---|",
    ]
    for who, value in evidence["stakeholder_value"].items():
        lines.append(f"| {who} | {value} |")

    lines += [
        "",
        "## Artifacts produced",
        "",
        "- `poc/output/evidence.json`",
        "- `poc/output/insights-simulated.json`",
        "- `poc/output/poc.log`",
        "- Snowflake vs baseline comparison (console + log)",
        "",
        "## Recommended next step",
        "",
        evidence["next_step"],
        "",
        "> This PoC uses a local or UBI stand-in runtime. Production-shaped proof continues with Image Builder `composer-cli` compose on a RHEL builder host.",
        "",
    ]
    (out / "evidence-report.md").write_text("\n".join(lines))
    print(f"Wrote {out / 'evidence-report.md'}")
    print(f"Wrote {out / 'evidence.json'}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
