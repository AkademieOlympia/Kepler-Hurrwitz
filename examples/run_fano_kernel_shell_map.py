#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    analyze_fano_kernel_shell_map,
    export_fano_kernel_shell_map_json,
    format_fano_kernel_shell_map_summary,
)


def main() -> None:
    print("--- #Energiedoku: E-039-pre Fano-Kernfreiheiten ↔ Schalenkarte ---")
    analysis = analyze_fano_kernel_shell_map()
    print(format_fano_kernel_shell_map_summary(analysis))
    print(f"claim_class={analysis.claim_class}, depends_on={list(analysis.depends_on)}")
    print(f"weight_profile={analysis.weight_profile}")
    print(f"basis_invariance={analysis.basis_invariance}")
    for candidate in analysis.shell_syndrome_candidates:
        print(
            f"  {candidate.shell_label}: classes={candidate.stabilization_classes}, "
            f"syndrome={candidate.syndrome_label_candidate}, "
            f"distance={candidate.distance_to_kernel}, coords={candidate.nearest_kernel_coordinates}"
        )

    output = export_fano_kernel_shell_map_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "fano_kernel_shell_map.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
