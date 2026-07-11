#!/usr/bin/env python3
"""Run EABC Weierstrass multiscale diagnostics and export report bundle."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_weierstrass_multiscale import (  # noqa: E402
    DEFAULT_SCALES,
    EABC_WEIERSTRASS_TAG,
    OPTIONAL_SCALE_10M,
    build_multiscale_analysis,
    export_multiscale_bundle,
)


def parse_scales(raw: str) -> tuple[int, ...]:
    values = tuple(int(part.strip()) for part in raw.split(",") if part.strip())
    if not values:
        raise argparse.ArgumentTypeError("at least one scale required")
    return values


def main() -> None:
    parser = argparse.ArgumentParser(
        description="EABC Weierstrass multiscale diagnostics — B(N)=ABCE−CEAB [C]."
    )
    parser.add_argument(
        "--max-n",
        type=int,
        default=1_000_000,
        help="Upper bound on base prime p (default: 1_000_000).",
    )
    parser.add_argument(
        "--scales",
        type=parse_scales,
        default=DEFAULT_SCALES,
        help=f"Comma-separated N scales (default: {','.join(str(s) for s in DEFAULT_SCALES)}).",
    )
    parser.add_argument(
        "--include-10m",
        action="store_true",
        help=f"Append {OPTIONAL_SCALE_10M:,} to scales and set max-n accordingly.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Export directory (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    scales = tuple(args.scales)
    max_n = args.max_n
    if args.include_10m:
        max_n = max(max_n, OPTIONAL_SCALE_10M)
        if OPTIONAL_SCALE_10M not in scales:
            scales = tuple(sorted(set(scales) | {OPTIONAL_SCALE_10M}))

    analysis = build_multiscale_analysis(max_n=max_n, scales=scales)
    paths = export_multiscale_bundle(analysis, args.out_dir)

    print("EABC Weierstrass multiscale export")
    print(f"Tag: {EABC_WEIERSTRASS_TAG}")
    print(f"max_n={analysis.max_n:,}, primvierlinge={len(analysis.cumulative_rows)}")
    for label, path in paths.items():
        print(f"  {label}: {path}")


if __name__ == "__main__":
    main()
