"""Export Tao-inspired Syracuse first-passage diagnostics (Governance [B])."""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_CSV = ROOT / "docs" / "exports" / "tao_collatz_first_passage_upto_1000000.csv"
DEFAULT_SUMMARY = (
    ROOT / "docs" / "exports" / "tao_collatz_first_passage_upto_1000000.summary.json"
)
DEFAULT_MOD8_SUMMARY = (
    ROOT / "docs" / "exports" / "tao_collatz_mod8_stratified.summary.json"
)
DEFAULT_GEOM2_MOD8_SUMMARY = (
    ROOT / "docs" / "exports" / "tao_collatz_geom2_by_mod8.summary.json"
)
sys.path.insert(0, str(SRC))

from kepler_hurwitz.tao_collatz_diagnostics import (  # noqa: E402
    KLEIN_MOD8_CLASSES,
    TAO_COLLATZ_TAG,
    TAO_FIXED_FIRST_PASSAGE_THRESHOLDS,
    batch_first_passage_by_mod8,
    batch_first_passage_experiment,
    batch_fixed_threshold_first_passage_summaries,
    export_first_passage_csv,
    export_first_passage_summary_json,
    export_mod8_geom2_summary_json,
    export_mod8_stratified_summary_json,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export Tao-inspired Collatz first-passage diagnostics [B]."
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=1_000_000,
        help=(
            "Upper bound for log-scale odd sampling (default 1_000_000). "
            "Use e.g. 2**64 for a slow full-range run; not required in CI."
        ),
    )
    parser.add_argument(
        "--fixed-threshold-samples",
        type=int,
        default=2_000,
        help="Samples per Tao-style fixed-x threshold companion batch.",
    )
    parser.add_argument("--samples", type=int, default=8_000)
    parser.add_argument(
        "--mod8-samples",
        type=int,
        default=2_000,
        help="Samples per Klein mod-8 class for stratified export.",
    )
    parser.add_argument("--seed", type=int, default=20260706)
    parser.add_argument("--max-steps", type=int, default=10_000)
    parser.add_argument("--profile-steps", type=int, default=64)
    parser.add_argument(
        "--steps-cap-log-n",
        type=float,
        default=None,
        help=(
            "If set (e.g. 1.0), cap profile steps per sample at "
            "max(1, int(coefficient * log(n)))."
        ),
    )
    parser.add_argument(
        "--steps-cap-coefficient",
        type=float,
        default=0.25,
        help="Coefficient c in min(profile_steps, max(1, int(c * log(n)))).",
    )
    parser.add_argument(
        "--no-censor-at-one",
        action="store_true",
        help="Disable censoring valuation profiles at Syracuse fixed point 1.",
    )
    parser.add_argument("--csv", type=Path, default=DEFAULT_CSV)
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY)
    parser.add_argument("--mod8-summary", type=Path, default=DEFAULT_MOD8_SUMMARY)
    parser.add_argument(
        "--geom2-mod8-summary",
        type=Path,
        default=DEFAULT_GEOM2_MOD8_SUMMARY,
    )
    parser.add_argument(
        "--skip-mod8",
        action="store_true",
        help="Skip mod-8 stratified and collective Geom(2) exports.",
    )
    args = parser.parse_args()

    started = time.perf_counter()
    experiment = batch_first_passage_experiment(
        args.limit,
        "relative",
        args.samples,
        args.seed,
        max_steps=args.max_steps,
        profile_steps=args.profile_steps,
    )
    rows = experiment["rows"]
    summary = dict(experiment["summary"])
    assert isinstance(summary, dict)

    fixed_started = time.perf_counter()
    fixed_summaries = batch_fixed_threshold_first_passage_summaries(
        args.limit,
        TAO_FIXED_FIRST_PASSAGE_THRESHOLDS,
        args.fixed_threshold_samples,
        args.seed,
        max_steps=args.max_steps,
        profile_steps=args.profile_steps,
    )
    summary["tao_fixed_thresholds"] = fixed_summaries["tao_fixed_thresholds"]
    summary["tao_fixed_threshold_note"] = (
        "Companion Tao-style fixed-x first passage at "
        f"{list(TAO_FIXED_FIRST_PASSAGE_THRESHOLDS)}; "
        "primary CSV/summary uses relative floor(N/2) net-descent threshold per row."
    )
    fixed_elapsed = time.perf_counter() - fixed_started
    elapsed = time.perf_counter() - started

    csv_path = export_first_passage_csv(rows, args.csv)
    summary_path = export_first_passage_summary_json(
        summary, args.summary, elapsed_seconds=elapsed + fixed_elapsed
    )

    print("Tao-inspired Collatz first-passage export")
    print(f"Tag: {TAO_COLLATZ_TAG}")
    print(
        "Governance: numerical Syracuse diagnostic inspired by Tao (2019); "
        "does NOT prove Collatz or formalize Tao's proof."
    )
    print(f"Limit: {args.limit}")
    print(f"Primary threshold: relative floor(N/2) net-descent diagnostic")
    print(f"Samples: {summary['samples']}")
    print(f"Hit rate (relative): {summary['hit_rate']:.4f}")
    print(f"Mean passage time (relative): {summary['mean_passage_time']}")
    print(f"Tail-corrected TV mean: {summary['tail_corrected_tv_mean']:.6f}")
    print(f"Lag-1 autocorr mean: {summary['lag1_autocorr_mean']}")
    print(f"Pair distribution L1 deviation: {summary['pair_distribution_l1_deviation']:.6f}")
    print("Tao-style fixed-x companion thresholds:")
    tao_fixed = summary["tao_fixed_thresholds"]
    assert isinstance(tao_fixed, dict)
    for key in map(str, TAO_FIXED_FIRST_PASSAGE_THRESHOLDS):
        entry = tao_fixed[key]
        assert isinstance(entry, dict)
        print(
            f"  x={key}: hit_rate={entry['hit_rate']:.4f}, "
            f"tail_corrected_tv_mean={entry['tail_corrected_tv_mean']:.6f}"
        )
    print(f"Elapsed (batch): {elapsed + fixed_elapsed:.3f}s")
    print(f"Wrote {csv_path}")
    print(f"Wrote {summary_path}")

    if not args.skip_mod8:
        mod8_started = time.perf_counter()
        mod8_result = batch_first_passage_by_mod8(
            args.limit,
            "relative",
            args.mod8_samples,
            args.seed,
            max_steps=args.max_steps,
            profile_steps=args.profile_steps,
            censor_at_one=not args.no_censor_at_one,
            steps_cap_log_n=args.steps_cap_log_n,
            steps_cap_coefficient=args.steps_cap_coefficient,
        )
        mod8_elapsed = time.perf_counter() - mod8_started
        mod8_summary_path = export_mod8_stratified_summary_json(
            mod8_result, args.mod8_summary, elapsed_seconds=mod8_elapsed
        )
        geom2_summary_path = export_mod8_geom2_summary_json(
            mod8_result, args.geom2_mod8_summary, elapsed_seconds=mod8_elapsed
        )

        print()
        print("Mod-8 stratified first-passage export (relative floor(N/2))")
        classes = mod8_result["classes"]
        for residue in KLEIN_MOD8_CLASSES:
            class_summary = classes[residue]
            print(
                f"  mod8={residue}: hit_rate={class_summary['hit_rate']:.4f}, "
                f"collective_geom2={class_summary['collective_geom2_distance']:.6f}, "
                f"free_geom2={class_summary['free_geom2_distance_excluding_position_0']:.6f}, "
                f"delta_start={class_summary['geom2_delta_start']:.6f}"
            )
        print(f"Elapsed (mod8): {mod8_elapsed:.3f}s")
        print(f"Wrote {mod8_summary_path}")
        print(f"Wrote {geom2_summary_path}")


if __name__ == "__main__":
    main()
