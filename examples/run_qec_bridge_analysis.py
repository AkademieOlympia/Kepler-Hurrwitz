#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    analyze_css_projection,
    build_stabilizer_structure_summary,
    export_qec_bridge_json,
    format_css_projection_summary,
    format_stabilizer_structure_summary,
)

def main() -> None:
    print("--- #Energiedoku: Fano-QEC-Brücke ---")
    summary = build_stabilizer_structure_summary()
    print(format_stabilizer_structure_summary(summary))
    css = analyze_css_projection()
    print(format_css_projection_summary(css))
    print("shell_syndrome_map:")
    for key, value in summary.shell_syndrome_map.items():
        print(f"  {key} -> {value}")

    output = export_qec_bridge_json(
        summary,
        ROOT / "docs" / "energiedoku_exports" / "qec_bridge.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
