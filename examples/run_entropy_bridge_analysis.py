#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.entropy_bridge import build_entropy_bridge_report, export_entropy_bridge_json, format_entropy_bridge_table


def main() -> None:
    report = build_entropy_bridge_report()
    print(format_entropy_bridge_table(report))
    export_path = export_entropy_bridge_json(
        report,
        ROOT / "docs" / "energiedoku_exports" / "entropy_bridge.json",
    )
    print(f"\nExport: {export_path}")


if __name__ == "__main__":
    main()
