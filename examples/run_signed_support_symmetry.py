#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    MODEL_SYMMETRY_GROUP_DEFINITION,
    analyze_signed_support_symmetry_invariance,
    export_signed_support_symmetry_json,
    format_signed_support_symmetry_summary,
    model_symmetry_group_specification,
)


def main() -> None:
    print("--- #Energiedoku: E-042-pre Symmetrieinvarianz signed_support ---")
    print(MODEL_SYMMETRY_GROUP_DEFINITION)
    print(model_symmetry_group_specification())
    analysis = analyze_signed_support_symmetry_invariance()
    print(format_signed_support_symmetry_summary(analysis))
    print(f"upgrade_conditions={analysis.upgrade_conditions}")

    output = export_signed_support_symmetry_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "signed_support_symmetry.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
