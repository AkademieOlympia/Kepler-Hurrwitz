#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    analyze_shell_cosets_mod_kernel,
    export_fano_shell_cosets_json,
    format_fano_shell_cosets_summary,
)


def main() -> None:
    print("--- #Energiedoku: Fano-Shell-Kosets modulo ker(R_Fano) ---")
    analysis = analyze_shell_cosets_mod_kernel()
    print(format_fano_shell_cosets_summary(analysis))
    print(f"e039_upgrade_eligible={analysis.e039_upgrade_eligible}")
    print(f"basis_invariance={analysis.basis_invariance}")
    for record in analysis.shell_cosets:
        print(
            f"  {record.shell_label}: syndrome={list(record.syndrome)}, "
            f"canonical={list(record.canonical_representative)}, "
            f"coords={record.nearest_kernel_coordinates}"
        )

    output = export_fano_shell_cosets_json(
        analysis,
        ROOT / "docs" / "energiedoku_exports" / "fano_shell_cosets.json",
    )
    print(f"export: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
