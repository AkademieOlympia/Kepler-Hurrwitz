#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.twin_prime_eabc_scale_sweep import (
    DEFAULT_LIMITS,
    DEFAULT_SIEVE_BOUNDS,
    OPTIONAL_LIMIT_10M,
    REPORT_HEADER,
    export_scale_sweep_json,
    export_scale_sweep_markdown,
    run_scale_sweep,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Scale sweep for structured twin-prime EABC controls [B]."
    )
    parser.add_argument(
        "--include-10m",
        action="store_true",
        help="Include optional n <= 10^7 long-run limit.",
    )
    parser.add_argument(
        "--quick",
        action="store_true",
        help="Run only limit=10_000 with sieve_bound=97 (smoke test).",
    )
    args = parser.parse_args()

    if args.quick:
        limits = [10_000]
        sieve_bounds = [97]
    else:
        limits = list(DEFAULT_LIMITS)
        sieve_bounds = list(DEFAULT_SIEVE_BOUNDS)
        if args.include_10m:
            limits.append(OPTIONAL_LIMIT_10M)

    result = run_scale_sweep(limits=limits, sieve_bounds=sieve_bounds)

    export_dir = ROOT / "docs" / "energiedoku_exports"
    json_path = export_dir / "twin_prime_eabc_scale_sweep.json"
    md_path = export_dir / "twin_prime_eabc_scale_sweep_report.md"

    export_scale_sweep_json(result, json_path)
    export_scale_sweep_markdown(result, md_path)

    print("--- Twin-Prime EABC Scale Sweep [B] ---")
    print(REPORT_HEADER)
    print(f"status: {result['status']}")
    print(f"limits: {result['tested_limits']}")
    print(f"sieve_bounds: {result['tested_sieve_bounds']}")
    print(f"conclusion: {result['conclusion']}")
    print(f"stage2_signal_summary: {result['stage2_signal_summary']}")
    print(f"json export: {json_path}")
    print(f"markdown report: {md_path}")


if __name__ == "__main__":
    main()
