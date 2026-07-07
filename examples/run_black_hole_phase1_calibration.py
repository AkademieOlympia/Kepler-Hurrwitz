"""Export GWTC Phase-1 preregistered calibration (BH-GOV-01 / ORQ-093)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_CSV = ROOT / "data" / "black_hole" / "gwosc_gwtc3_fixture.csv"
DEFAULT_OUT = ROOT / "docs" / "exports" / "black_hole_phase1_calibration.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.black_hole_gwtc_preregistered import (  # noqa: E402
    BLACK_HOLE_TAG,
    PREREGISTRATION_PATH,
    export_phase1_json,
    load_and_filter_catalog,
    run_phase1_calibration,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="GWTC Phase-1 preregistered (kappa, tau) calibration on GWTC-3."
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"GWTC-3 GWOSC CSV (default: {DEFAULT_CSV}).",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT.parent,
        help=f"Output directory (default: {DEFAULT_OUT.parent}).",
    )
    parser.add_argument(
        "--mc-samples",
        type=int,
        default=10_000,
        help="MC draws per event for P_gap (default: 10000).",
    )
    parser.add_argument(
        "--perm-iterations",
        type=int,
        default=10_000,
        help="Permutation null iterations (default: 10000).",
    )
    parser.add_argument("--seed", type=int, default=93)
    args = parser.parse_args()

    if not args.csv.is_file():
        raise SystemExit(f"GWTC CSV not found: {args.csv}")

    filtered, all_loaded = load_and_filter_catalog(args.csv)
    data_note = ""
    if "fixture" in args.csv.name.lower() or "mock" in args.csv.name.lower():
        data_note = (
            "DEVELOPMENT ONLY: fixture/mock catalog — replace with official GWOSC GWTC-3 "
            "parameter-estimation CSV for production calibration."
        )

    result = run_phase1_calibration(
        all_loaded,
        mc_samples=args.mc_samples,
        perm_iterations=args.perm_iterations,
        seed=args.seed,
        apply_exclusion_filter=True,
    )
    out_path = args.out_dir / "black_hole_phase1_calibration.json"
    export_phase1_json(result, out_path, data_note=data_note)

    print(f"{BLACK_HOLE_TAG} Phase-1 calibration complete (BH-GOV-01).")
    print(f"  preregistration: {PREREGISTRATION_PATH}")
    print(f"  catalog: {args.csv}")
    print(f"  events loaded: {len(all_loaded)} | after M1+bounds filter: {len(filtered)}")
    print(f"  grid tests: {result.n_tests} (expect 92)")
    print(f"  kappa* = {result.best_kappa:.2f}, tau* = {result.best_tau:.2f}")
    print(f"  min p-value = {result.best_p_value:.6f}")
    print(f"  Bonferroni alpha = {result.bonferroni_alpha:.6f} (0.05/92)")
    print(f"  Bonferroni significant: {result.bonferroni_significant}")
    print("  NOTE: Phase-1 result does NOT upgrade to [B] — Phase 2 blind test required.")
    if data_note:
        print(f"  data_note: {data_note}")
    print(f"  export: {out_path}")


if __name__ == "__main__":
    main()
