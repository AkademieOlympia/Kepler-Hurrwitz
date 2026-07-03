#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.twin_prime_eabc_structured_controls import (
    DEFAULT_LIMIT,
    DEFAULT_SIEVE_BOUND,
    STAGE1_INTERPRETATION,
    export_structured_controls_json,
    export_structured_controls_markdown,
    run_structured_controls_experiment,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Stage-2 structured controls for twin-prime EABC analysis [B/C]."
    )
    parser.add_argument("--limit", type=int, default=DEFAULT_LIMIT)
    parser.add_argument("--sieve-bound", type=int, default=DEFAULT_SIEVE_BOUND)
    args = parser.parse_args()

    report = run_structured_controls_experiment(
        limit=args.limit,
        sieve_bound=args.sieve_bound,
    )

    export_dir = ROOT / "docs" / "energiedoku_exports"
    json_path = export_dir / "twin_prime_eabc_structured_controls.json"
    md_path = export_dir / "twin_prime_eabc_structured_controls_report.md"

    export_structured_controls_json(report, json_path)
    export_structured_controls_markdown(report, md_path)

    print("--- Twin-Prime EABC Structured Controls (Stage 2) [B/C] ---")
    print(f"status: {report.status}")
    print(f"not_claimed: {report.not_claimed}")
    print(f"primary_question: {report.primary_question}")
    print(f"stage1: {STAGE1_INTERPRETATION}")
    print(f"CE hit rate: {report.stage1_residue_summary.ce_hit_rate}")
    print(f"AB hit rate: {report.stage1_residue_summary.ab_hit_rate}")
    for item in report.orientation_features:
        print(
            f"orientation {item.stratum}: constant={item.feature_is_constant} "
            f"enrichment={item.enrichment_positive_vs_baseline}"
        )
    for item in report.right_wing_features:
        print(
            f"right_wing {item.stratum}: enrichment={item.enrichment_positive_vs_baseline} "
            f"pos/neg={item.enrichment_positive_vs_negative}"
        )
    print(f"json export: {json_path}")
    print(f"markdown report: {md_path}")


if __name__ == "__main__":
    main()
