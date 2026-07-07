#!/usr/bin/env python3
"""Run EABC dual-axis vector vs bivector energy comparison and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "eabc_dual_axis_energy_asymmetry.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_energy_square_sum import (  # noqa: E402
    ENERGY_SQUARE_SUM_TAG,
    GOVERNANCE,
    build_dual_axis_comparison,
    compare_dual_axis_scaling,
    export_energy_square_sum_json,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC dual-axis a vs bc energy asymmetry export [C]."
    )
    parser.add_argument(
        "--eeg",
        type=float,
        default=1.0,
        help="EEG scaling factor (default: 1.0).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    amplitudes = (
        (1.0, 1.0, 1.0, 1.0, 1.0, 1.0),
        (2.0, 2.0, 2.0, 2.0, 2.0, 2.0),
        (1.0, 0.0, 1.0, 0.0, 1.0, 0.0),
        (3.0, 4.0, 1.0, 2.0, 2.0, 1.0),
    )
    grid = build_dual_axis_comparison(args.eeg, amplitudes)
    unit = compare_dual_axis_scaling(1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
    analysis = {
        "tag": ENERGY_SQUARE_SUM_TAG,
        "claim_id": GOVERNANCE["claim_id"],
        "eeg": args.eeg,
        "equal_unit_amplitudes": unit,
        "grid": grid,
    }
    path = export_energy_square_sum_json(analysis, args.out)

    print("EABC dual-axis energy asymmetry export")
    print(f"Tag: {ENERGY_SQUARE_SUM_TAG}")
    print(
        f"equal amplitudes u=1: E_a={unit['e_a']}, E_bc={unit['e_bc']}, "
        f"ratio={unit['ratio_e_bc_over_e_a']}"
    )
    print(f"export: {path}")


if __name__ == "__main__":
    main()
