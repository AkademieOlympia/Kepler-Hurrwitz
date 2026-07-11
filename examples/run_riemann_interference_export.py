#!/usr/bin/env python3
"""Export Riemann zero interference phase-collapse and fractional comparison [B]/[C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.riemann_interference_diagnostics import (  # noqa: E402
    GOVERNANCE,
    RIEMANN_INTERFERENCE_TAG,
    export_fractional_comparison_bundle,
    export_phase_collapse_bundle,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export Riemann zero interference phase-collapse visualization (E-095 / ORQ-095)."
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT}).",
    )
    parser.add_argument(
        "--num-zeros",
        type=int,
        default=150,
        help="Number of zeta zeros in the wave sum (default: 150).",
    )
    parser.add_argument(
        "--skip-fractional",
        action="store_true",
        help="Skip fractional alpha=0 vs 0.5 comparison export.",
    )
    args = parser.parse_args()

    paths = export_phase_collapse_bundle(args.out_dir, num_zeros=args.num_zeros)
    print("Riemann interference phase-collapse export")
    print(f"Tag: {RIEMANN_INTERFERENCE_TAG} plot {GOVERNANCE['plot_tag']}")
    print(f"num_zeros={args.num_zeros}")
    for name, path in paths.items():
        print(f"  {name}: {path}")

    if not args.skip_fractional:
        frac_paths = export_fractional_comparison_bundle(args.out_dir, num_zeros=args.num_zeros)
        print("\nFractional-weighted interference comparison export")
        print(f"Tag: [C] kernel, plot {GOVERNANCE['plot_tag']}")
        for name, path in frac_paths.items():
            print(f"  {name}: {path}")


if __name__ == "__main__":
    main()
