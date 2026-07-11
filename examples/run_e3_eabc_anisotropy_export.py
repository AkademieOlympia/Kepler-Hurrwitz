#!/usr/bin/env python3
"""Export e³ ↔ EABC anisotropy comparison diagnostics [B]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "e3_eabc_anisotropy_comparison.json"
DEFAULT_CASES = (
    (13, 5, 13, 1),  # n=65, EABC A-channel — pass
    (17, 3, 2, 4),   # n=51, no EABC channel — skip
)
sys.path.insert(0, str(SRC))

from kepler_hurwitz.e3_decomposition import (  # noqa: E402
    E3_DECOMPOSITION_TAG,
    E3_EABC_GOVERNANCE_NOTE,
    batch_e3_eabc_anisotropy_comparison,
    export_e3_eabc_anisotropy_comparison_json,
)


def _parse_case(raw: str) -> tuple[int, int, int, int]:
    parts = [int(part.strip()) for part in raw.split(",")]
    if len(parts) != 4:
        raise argparse.ArgumentTypeError(
            f"Expected four comma-separated integers (a,e,b,c), got {raw!r}"
        )
    return parts[0], parts[1], parts[2], parts[3]


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export e³ ↔ EABC anisotropy comparison diagnostics [B]."
    )
    parser.add_argument(
        "--case",
        action="append",
        dest="cases",
        type=_parse_case,
        metavar="A,E,B,C",
        help="Lemma-2 tuple (a, e, b, c) with n = e * a and r = b * c. Repeatable.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    parser.add_argument(
        "--tol",
        type=float,
        default=1e-9,
        help="Numerical tolerance for comparison pass/fail (default: 1e-9).",
    )
    args = parser.parse_args()

    cases = args.cases if args.cases else list(DEFAULT_CASES)
    payload = batch_e3_eabc_anisotropy_comparison(cases, tol=args.tol)
    path = export_e3_eabc_anisotropy_comparison_json(payload, args.out)

    print("e³ ↔ EABC anisotropy comparison export")
    print(f"Tag: {E3_DECOMPOSITION_TAG}")
    print(f"Governance: {E3_EABC_GOVERNANCE_NOTE}")
    print(f"Cases: {len(cases)}")
    for row in payload["cases"]:
        print(
            f"  n={row['n']} e={row['e']} "
            f"comparison={row['comparison']['status']}"
        )
    print(f"export: {path}")


if __name__ == "__main__":
    main()
