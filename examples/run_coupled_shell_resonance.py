#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.coupled_shell_resonance import (
    analyze_coupled_shell_resonance_graph,
    export_coupled_shell_resonance_json,
    format_coupled_shell_resonance_summary,
)


def main() -> None:
    print("--- #Energiedoku: E-043-pre Coupled Shell Resonance Graph ---")
    analysis = analyze_coupled_shell_resonance_graph()
    print(format_coupled_shell_resonance_summary(analysis))
    print(f"depends_on={list(analysis.depends_on)}")
    print(f"graph_invariants={analysis.graph_invariants}")

    output = export_coupled_shell_resonance_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "coupled_shell_resonance_graph.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
