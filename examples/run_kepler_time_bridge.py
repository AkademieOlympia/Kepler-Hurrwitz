#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios
from kepler_hurwitz.time_bridge_plots import export_spectral_histogram


def _print_record(record) -> None:
    diag = record.diagnostics
    m_period = "-" if diag.M_tail_period is None else str(diag.M_tail_period)
    spectrum = ", ".join(f"{value:.5f}" for value in diag.delta_M_spectrum[:12])
    if len(diag.delta_M_spectrum) > 12:
        spectrum += ", ..."
    print(
        f"{record.control_name:22s} | unique_dM={diag.unique_delta_M_count:3d} | "
        f"var={diag.delta_M_variance:8.5f} | M_period={m_period:>3} | "
        f"max_kepler_err={diag.kepler_consistency_max_error:.6f}"
    )
    print(f"  delta_M spectrum: [{spectrum}]")


def main() -> None:
    print("--- #Energiedoku: Kepler-Zeit-Leiter ---")
    print("control                | unique_dM | var      | M_period | max_kepler_err")
    print("-" * 88)

    records = run_kepler_time_bridge_scenarios(
        steps=500,
        tail_length=64,
    )
    for record in records:
        _print_record(record)
        print()

    baseline = records[0].diagnostics
    pi2 = records[3].diagnostics
    perturb = records[4].diagnostics
    print("Interpretation:")
    print(
        f"- Baseline: {baseline.unique_delta_M_count} diskrete Sprungwerte "
        f"(Erwartung: endliches Linienspektrum im Attraktor)"
    )
    print(
        f"- pi/2 vs Baseline: Spektren "
        f"{'distinkt' if pi2.delta_M_spectrum != baseline.delta_M_spectrum else 'identisch'}"
    )
    print(
        f"- Stoerung vs Baseline: Spektren "
        f"{'distinkt' if perturb.delta_M_spectrum != baseline.delta_M_spectrum else 'identisch'}, "
        f"unique_dM={perturb.unique_delta_M_count}"
    )

    export_spectral_histogram(records, ROOT / "docs" / "plots")


if __name__ == "__main__":
    main()
