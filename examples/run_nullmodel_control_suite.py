#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.discrete_time_flow import (
    default_demo_orbit,
    hurwitz_units_240,
    phi,
    run_nullmodel_control_suite,
)


def _fmt_match(value: bool | None) -> str:
    if value is None:
        return "-"
    return "yes" if value else "no"


def _fmt_diff(value: float | None) -> str:
    if value is None:
        return "-"
    if value == float("inf"):
        return "inf"
    return f"{value:.6f}"


def _print_nullmodel_table(title: str, rows) -> None:
    print(title)
    print(
        "control | label | tail_p | tail_u | match | iso | spec_equiv | cum_dist_diff | iso_reason"
    )
    print("-" * 120)
    for row in rows:
        tail_period = "-" if row.tail_period is None else str(row.tail_period)
        iso_reason = row.isomorphism_reason or "-"
        print(
            f"{row.control:11s} | {row.label:24s} | {tail_period:>6} | {row.tail_unique_states:6d} | "
            f"{_fmt_match(row.attractor_match_baseline):>5} | "
            f"{_fmt_match(row.attractor_isomorphic_baseline):>3} | "
            f"{_fmt_match(row.spectrally_equivalent_baseline):>10} | "
            f"{_fmt_diff(row.spectral_cum_dist_diff):>13} | {iso_reason}"
        )
    print()


def main() -> None:
    orbit = default_demo_orbit()
    x0 = phi(orbit)
    operators = hurwitz_units_240()[:8]

    print("--- #Energiedoku: Nullmodell-Kontrollsuite ---")
    print(f"X_0 = {tuple(round(v, 6) for v in x0)}")
    print(f"Operator pool size = {len(operators)}")
    print()

    records = run_nullmodel_control_suite(
        orbit=orbit,
        steps=500,
        operators=operators,
        w_norm=2.0,
        w_dist=0.25,
        alpha=0.1,
        use_second_ring=True,
        perturb_at_step=100,
        random_seed=11,
    )
    _print_nullmodel_table("Spektraler Fingerabdruck vs. Baseline", records)

    baseline = records[0]
    print("Interpretationshinweise:")
    print(
        f"- Baseline tail_period={baseline.tail_period}, tail_unique={baseline.tail_unique_states}"
    )
    for row in records[1:]:
        if row.control == "operator_chain":
            print(
                f"- Zufallskette: spec_equiv={row.spectrally_equivalent_baseline}, "
                f"cum_dist_diff={_fmt_diff(row.spectral_cum_dist_diff)}"
            )
        elif row.control == "gauge_phase":
            if row.spectrally_equivalent_baseline and not row.attractor_match_baseline:
                note = "Kristall-Translation (spektral identisch, Punktverschiebung)"
            elif row.spectrally_equivalent_baseline:
                note = "spektral und punktweise identisch"
            else:
                note = "intrinsisch verschiedene Metrik"
            print(
                f"- {row.label}: spec_equiv={row.spectrally_equivalent_baseline}, "
                f"cum_dist_diff={_fmt_diff(row.spectral_cum_dist_diff)} -> {note}"
            )
        elif row.control == "perturbation":
            print(
                f"- Stoerung @100: spec_equiv={row.spectrally_equivalent_baseline}, "
                f"cum_dist_diff={_fmt_diff(row.spectral_cum_dist_diff)}, "
                f"subset={row.is_subset_of_baseline}"
            )


if __name__ == "__main__":
    main()
