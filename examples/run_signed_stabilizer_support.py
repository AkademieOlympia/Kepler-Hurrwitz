#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    FIVE_QUBIT_CODE_SYMMETRY_DEFINITION,
    analyze_signed_stabilizer_support_profile,
    export_signed_stabilizer_support_json,
    format_signed_stabilizer_support_summary,
    five_qubit_code_symmetry_specification,
)


def main() -> None:
    print("--- #Energiedoku: E-045-pre Signed Stabilizer Support Profile ---")
    print(FIVE_QUBIT_CODE_SYMMETRY_DEFINITION)
    print(five_qubit_code_symmetry_specification())
    analysis = analyze_signed_stabilizer_support_profile()
    print(format_signed_stabilizer_support_summary(analysis))
    print(f"old_fact={analysis.old_fact}")
    print(f"raw_relations={analysis.raw_relations}")
    print(f"orbit_relations={analysis.orbit_relations}")

    output = export_signed_stabilizer_support_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "signed_stabilizer_support_profile.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
