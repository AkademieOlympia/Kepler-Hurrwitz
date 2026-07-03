#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    analyze_refined_shell_projection,
    export_refined_shell_projection_json,
    format_refined_shell_projection_summary,
)


def main() -> None:
    print("--- #Energiedoku: E-040-pre verfeinerte Shell-Projektion ---")
    analysis = analyze_refined_shell_projection()
    print(format_refined_shell_projection_summary(analysis))
    print(f"input_fact={analysis.input_fact}")
    for mode, report in analysis.refinements.items():
        print(
            f"  {mode}: separates_N4_N8={report.separates_N4_N8}, "
            f"upgrade_eligible={report.upgrade_eligible}, keys={report.signature_keys_by_shell}"
        )

    output = export_refined_shell_projection_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "refined_shell_projection.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
