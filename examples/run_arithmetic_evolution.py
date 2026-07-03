#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.arithmetic_evolution import (
    build_transition_matrix_analysis,
    catalog_quantized_energy_levels,
    default_arithmetic_prime_operators,
    export_energy_levels_latex_table,
    export_transition_matrix_json,
    format_arithmetic_evolution_summary,
    format_compound_evolution_summary,
    format_transition_matrix_table,
    run_default_arithmetic_evolution_scenarios,
    simulate_compound_arithmetic_evolution,
)
from kepler_hurwitz.discrete_time_flow import default_demo_orbit, phi


def main() -> None:
    print("--- #Energiedoku: Arithmetische Evolution (Primelement-Operatoren) ---")
    operators = default_arithmetic_prime_operators()
    print("Operatoren:")
    for operator in operators:
        print(
            f"  {operator.label}: requested N={operator.requested_norm}, "
            f"actual N={operator.actual_norm}, shell_proxy={operator.is_shell_proxy}"
        )
    print()

    cyclic, sequential = run_default_arithmetic_evolution_scenarios(steps=24)
    print("Modus: cyclic (24 Schritte)")
    print(format_arithmetic_evolution_summary(cyclic))
    print()

    matrix = build_transition_matrix_analysis(cyclic.records)
    print("Uebergangsmatrix P(x0_to | x0_from, operator):")
    print(format_transition_matrix_table(matrix))
    export_path = export_transition_matrix_json(
        matrix,
        ROOT / "docs" / "energiedoku_exports" / "arithmetic_transition_matrix.json",
    )
    print(f"\nExport: {export_path}")
    print()

    compound = simulate_compound_arithmetic_evolution(
        phi(default_demo_orbit()),
        operators,
        prime_steps=12,
        relaxation_steps=16,
        mode="cyclic",
    )
    print("Prime + Unit-Relaxation (12 Prime-Schritte, je 16 Unit-Schritte):")
    print(format_compound_evolution_summary(compound))
    catalog = catalog_quantized_energy_levels(compound, matrix)
    tex_path = export_energy_levels_latex_table(
        catalog,
        ROOT / "docs" / "energiedoku_exports" / "arithmetic_energy_levels.tex",
    )
    print(f"\nLaTeX-Tabelle: {tex_path}")
    print()
    print("Modus: sequential (3 Schritte, je ein Proxy-Operator)")
    print(format_arithmetic_evolution_summary(sequential))


if __name__ == "__main__":
    main()
