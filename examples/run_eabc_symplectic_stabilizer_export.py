#!/usr/bin/env python3
"""Run L(s, chi_{-3}) gap-to-[[5,1,3]] stabilizer bridge and export JSON [C]."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "exports" / "eabc_symplectic_stabilizer_bridge.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_symplectic_stabilizer_bridge import (  # noqa: E402
    FIRST_L_CHI_MINUS3_ZEROS,
    FUNDAMENTAL_FREQ_DEFAULT,
    SYMPLECTIC_BRIDGE_TAG,
    build_stabilizer_bridge_analysis,
    export_stabilizer_bridge_json,
    stabilizer_label,
)


def parse_gammas(raw: str) -> tuple[float, ...]:
    return tuple(float(part.strip()) for part in raw.split(",") if part.strip())


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC symplectic [[5,1,3]] stabilizer bridge for L-gap zeros [C]."
    )
    parser.add_argument(
        "--fundamental-freq",
        type=float,
        default=FUNDAMENTAL_FREQ_DEFAULT,
        help=f"Phase calibration frequency (default: {FUNDAMENTAL_FREQ_DEFAULT}).",
    )
    parser.add_argument(
        "--gammas",
        type=parse_gammas,
        default=None,
        help="Comma-separated gamma values (default: FIRST_L_CHI_MINUS3_ZEROS).",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=DEFAULT_OUT,
        help=f"JSON export path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    gammas = args.gammas if args.gammas is not None else FIRST_L_CHI_MINUS3_ZEROS
    analysis = build_stabilizer_bridge_analysis(
        gammas=gammas,
        fundamental_freq=args.fundamental_freq,
    )
    path = export_stabilizer_bridge_json(analysis, args.out)

    print("EABC symplectic stabilizer bridge export")
    print(f"Tag: {SYMPLECTIC_BRIDGE_TAG}")
    print(f"fundamental_freq={args.fundamental_freq}, zeros={len(gammas)}")
    print(f"gaps={analysis['gap_count']}")
    print(f"export: {path}")
    print("first records:")
    for rec in analysis["records"][:5]:
        stab = rec["stabilizer"]
        print(
            f"  gamma_n={rec['gamma_n']:.4f}  gap={rec['gap']:.4f}  "
            f"{stab['symplectic_vector']}  {stabilizer_label(stab['state_idx'])}"
        )


if __name__ == "__main__":
    main()
