#!/usr/bin/env python3
"""Print snowflake vs baseline comparison for the Fedora Lane PoC."""

from __future__ import annotations

import sys
from pathlib import Path


def load_env(path: Path) -> dict[str, str]:
    data: dict[str, str] = {}
    for line in path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        data[key.strip()] = value.strip()
    return data


def main() -> int:
    root = Path(__file__).resolve().parents[1]
    profiles = root / "profiles"
    snowflakes = [
        load_env(profiles / "snowflake-paris.env"),
        load_env(profiles / "snowflake-aws.env"),
    ]
    baseline = load_env(profiles / "baseline-rhel.env")

    keys = [
        "FL_SITE",
        "FL_OS",
        "FL_NTP",
        "FL_FIREWALL",
        "FL_INSIGHTS",
        "FL_ADMIN_USER",
        "FL_APP_RUNTIME",
    ]

    print("=" * 72)
    print("Fedora Lane PoC — Snowflake TODAY vs RHEL baseline TARGET")
    print("=" * 72)
    print(f"{'Field':<16} {'Paris boutique':<28} {'AWS cloud':<28} {'Baseline RHEL'}")
    print("-" * 72)
    for key in keys:
        print(
            f"{key:<16} {snowflakes[0].get(key, ''):<28} "
            f"{snowflakes[1].get(key, ''):<28} {baseline.get(key, '')}"
        )
    print("-" * 72)
    print("Challenge proven: without a golden image, every site invents its own OS story.")
    print("Solution: Image Builder blueprint → one RHEL baseline for all host classes.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
