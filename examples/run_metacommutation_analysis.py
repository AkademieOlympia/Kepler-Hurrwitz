#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators
from kepler_hurwitz.discrete_time_flow import hurwitz_units_240
from kepler_hurwitz.metacommutation import (
    analyze_dyadic_metacommutation,
    classify_shell_operator_metacommutation,
    enumerate_dyadic_norm2_integer_roots,
    export_metacommutation_json,
    format_metacommutation_summary,
    summarize_metacommutation,
)


def main() -> None:
    print("--- #Energiedoku: Dyadische Metakommutation (Norm 2) ---")
    roots = enumerate_dyadic_norm2_integer_roots()
    units = hurwitz_units_240()
    print(f"dyadic integer roots: {len(roots)}")
    print(f"hurwitz units: {len(units)}")
    print()

    records = analyze_dyadic_metacommutation(dyadic_roots=roots, units=units)
    summary = summarize_metacommutation(records, dyadic_root_count=len(roots), unit_count=len(units))
    print(format_metacommutation_summary(summary))
    print()

    shell_ops = tuple(operator.element for operator in default_arithmetic_prime_operators())
    shell_report = classify_shell_operator_metacommutation(shell_ops, records=records)
    print("Shell-Proxy Metakommutations-Profil:")
    for name, metrics in shell_report.items():
        print(
            f"  {name}: associative_ratio={metrics['associative_ratio']:.3f}, "
            f"dyadic_partner_ratio={metrics['dyadic_partner_ratio']:.3f}, "
            f"fixed_partner_ratio={metrics['fixed_partner_ratio']:.3f}, "
            f"mean_partner_count={metrics['mean_partner_count']:.2f}"
        )

    export_path = export_metacommutation_json(
        records,
        summary,
        ROOT / "docs" / "energiedoku_exports" / "dyadic_metacommutation.json",
    )
    print(f"\nExport: {export_path}")


if __name__ == "__main__":
    main()
