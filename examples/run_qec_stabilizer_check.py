#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.qec_bridge import (
    export_five_qubit_stabilizer_bridge_json,
    format_five_qubit_stabilizer_bridge_summary,
    generate_five_qubit_stabilizers,
    map_dyadic_to_stabilizers,
    summarize_five_qubit_stabilizer_bridge,
    verify_five_qubit_stabilizer_commutation,
)


def main() -> None:
    print("--- #Energiedoku: [[5,1,3]] Stabilisator-Brücke (E-044) ---")
    stabilizers = generate_five_qubit_stabilizers()
    print(f"generators=4, stabilizers={len(stabilizers)}, all_commute={verify_five_qubit_stabilizer_commutation()}")

    matches = map_dyadic_to_stabilizers()
    summary = summarize_five_qubit_stabilizer_bridge(matches)
    print(format_five_qubit_stabilizer_bridge_summary(summary))

    print("\nShell-Proxy [[5,1,3]]-Kommutationsprofil:")
    for label, values in sorted(summary.shell_commutation_profile.items()):
        print(
            f"  {label}: nearest={values['nearest_dyadic_root']}, "
            f"symplectic={values['symplectic_encoding']}, "
            f"commuting_ratio={float(values['commuting_stabilizer_ratio']):.3f}, "
            f"mean_signum={float(values['mean_commutation_signum']):.3f}"
        )
    print(
        "\nHinweis [C]: Unter der kanonischen 5-Qubit-Symplektik bleibt die "
        "Kommutationsquote fuer N=4/6/8 entartet; die Trennung liegt in E-037 "
        "(associative_ratio), nicht in dieser Projektion."
    )

    output = export_five_qubit_stabilizer_bridge_json(
        summary,
        ROOT / "docs" / "energiedoku_exports" / "five_qubit_stabilizer_bridge.json",
        sample_matches=matches,
    )
    print(f"\nExport: {output.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
