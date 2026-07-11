#!/usr/bin/env python3
"""Run Pauli tensor invariant subspace audit and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "phaseninvarianz_tensor_invariants.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.phaseninvarianz_tensor_invariants import (  # noqa: E402
    GOVERNANCE,
    TENSOR_INVARIANT_TAG,
    build_tensor_invariant_analysis,
    export_tensor_invariants_json,
    tensor_operators,
)

DEFAULT_AMPLITUDES = {
    "bx": 1.2,
    "by": 0.7,
    "cx": 2.1,
    "cy": 0.9,
    "ax": 1.2,
    "ay": 0.7,
}


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Pauli tensor invariant subspace on bc quartic energy — export [C]."
    )
    parser.add_argument("--bx", type=float, default=DEFAULT_AMPLITUDES["bx"])
    parser.add_argument("--by", type=float, default=DEFAULT_AMPLITUDES["by"])
    parser.add_argument("--cx", type=float, default=DEFAULT_AMPLITUDES["cx"])
    parser.add_argument("--cy", type=float, default=DEFAULT_AMPLITUDES["cy"])
    parser.add_argument("--ax", type=float, default=DEFAULT_AMPLITUDES["ax"])
    parser.add_argument("--ay", type=float, default=DEFAULT_AMPLITUDES["ay"])
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    analysis = build_tensor_invariant_analysis(
        args.bx,
        args.by,
        args.cx,
        args.cy,
        ax=args.ax,
        ay=args.ay,
    )
    path = export_tensor_invariants_json(analysis, args.out)

    summary = analysis["summary"]
    print("Phaseninvarianz tensor invariant subspace export")
    print(f"Tag: {TENSOR_INVARIANT_TAG}")
    print(f"operators={summary['total_operators']}")
    print(f"bc_invariant_count={summary['bc_invariant_count']}/{summary['total_operators']}")
    print(f"all_bc_invariant={summary['all_bc_invariant']}")
    print(f"a_invariant_count={summary.get('a_invariant_count')}/{summary['total_operators']}")
    print(f"export: {path}")
    print(f"tensor_ops: {', '.join(tensor_operators())}")


if __name__ == "__main__":
    main()
