#!/usr/bin/env python3
"""Run EABC a-vs-bc axis resonance on Riemann zeros and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "eabc_monopole_axis_resonance.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_monopole_axis_resonance import (  # noqa: E402
    FIRST_RIEMANN_ZEROS,
    MONOPOLE_AXIS_TAG,
    build_axis_resonance_analysis,
    export_axis_resonance_json,
)


def parse_gammas(raw: str) -> tuple[float, ...]:
    return tuple(float(part.strip()) for part in raw.split(",") if part.strip())


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC Riemann-zero a-vs-bc axis resonance monopole test [C]."
    )
    parser.add_argument(
        "--prime-limit",
        type=int,
        default=10_000,
        help="Upper bound on primes for axis partial sums (default: 10000).",
    )
    parser.add_argument(
        "--zeros",
        type=parse_gammas,
        default=None,
        help="Comma-separated gamma values (default: built-in FIRST_RIEMANN_ZEROS).",
    )
    parser.add_argument(
        "--count",
        type=int,
        default=15,
        help="Number of built-in zeros to use when --zeros omitted (default: 15).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    gammas = args.zeros if args.zeros is not None else FIRST_RIEMANN_ZEROS[: args.count]
    analysis = build_axis_resonance_analysis(gammas=gammas, prime_limit=args.prime_limit)
    path = export_axis_resonance_json(analysis, args.out)

    print("EABC monopole axis resonance export")
    print(f"Tag: {MONOPOLE_AXIS_TAG}")
    print(f"prime_limit={args.prime_limit}, zeros={len(gammas)}")
    print(f"delta_sign_changes={analysis['delta_sign_changes']}")
    print(f"export: {path}")
    print("first records:")
    for rec in analysis["records"][:5]:
        print(
            f"  gamma={rec['gamma']:.6f}  delta={rec['delta']:+.6f}  "
            f"dominant={rec['dominant_axis']}"
        )


if __name__ == "__main__":
    main()
