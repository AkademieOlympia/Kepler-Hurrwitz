#!/usr/bin/env python3
"""Run EABC energetic square-sum numeric grid and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "eabc_energy_square_sum.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_energy_square_sum import (  # noqa: E402
    ENERGY_SQUARE_SUM_TAG,
    GOVERNANCE,
    build_energy_grid,
    export_energy_square_sum_json,
    symmetric_axes_energy_template,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC energetic square-sum substitution numeric grid export [C]."
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
        (0.0, 0.0),
        (1.0, 0.0),
        (0.0, 1.0),
        (1.0, 1.0),
        (2.0, 3.0),
        (-1.5, 2.0),
    )
    grid = build_energy_grid(args.eeg, amplitudes)
    analysis = {
        "tag": ENERGY_SQUARE_SUM_TAG,
        "claim_id": GOVERNANCE["claim_id"],
        "eeg": args.eeg,
        "grid": grid,
        "symmetric_axes_template": symmetric_axes_energy_template(),
    }
    path = export_energy_square_sum_json(analysis, args.out)

    print("EABC energetic square-sum export")
    print(f"Tag: {ENERGY_SQUARE_SUM_TAG}")
    print(f"EEG={args.eeg}, grid_points={len(grid)}")
    print(f"export: {path}")
    print("sample rows:")
    for row in grid[:3]:
        print(
            f"  ax={row['ax']}, ay={row['ay']}  "
            f"a_energy={row['a_energy']:.4f}  total={row['total_energy']:.4f}"
        )


if __name__ == "__main__":
    main()
