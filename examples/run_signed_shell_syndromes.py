#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    analyze_signed_shell_syndromes,
    export_signed_shell_syndromes_json,
    format_signed_shell_syndromes_summary,
)


def main() -> None:
    print("--- #Energiedoku: E-041 [B] signierte Shell-Syndrome ---")
    analysis = analyze_signed_shell_syndromes()
    print(format_signed_shell_syndromes_summary(analysis))
    print(f"old_fact={analysis.old_fact}")
    print(f"auxiliary={analysis.auxiliary}")

    output = export_signed_shell_syndromes_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "signed_shell_syndromes.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
