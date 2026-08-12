"""Export Atome nuclear residual diagnostics (E-092 / ORQ-092)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_CSV = ROOT / "data" / "atome" / "toy_nuclides.csv"
DEFAULT_OUT = ROOT / "docs" / "exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.nuclear_binding_residual import (  # noqa: E402
    ATOME_TAG,
    WeizsaeckerParams,
    build_atome_analysis,
    export_atome_bundle,
    load_nuclides_csv,
    toy_nuclides,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export Atome I_EABC vs. R(A,Z) residual diagnostics (E-092)."
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=None,
        help=f"Nuclide table CSV (default: {DEFAULT_CSV} if present, else built-in toy).",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT}).",
    )
    parser.add_argument(
        "--nullmodel-trials",
        type=int,
        default=200,
        help="Permutation/shuffle trials per nullmodel mode (default: 200).",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=92,
        help="RNG seed for nullmodels (default: 92).",
    )
    args = parser.parse_args()

    csv_path = args.csv
    if csv_path is None and DEFAULT_CSV.exists():
        csv_path = DEFAULT_CSV
    nuclides = load_nuclides_csv(csv_path) if csv_path else toy_nuclides()

    analysis = build_atome_analysis(
        nuclides,
        params=WeizsaeckerParams(),
        nullmodel_trials=args.nullmodel_trials,
        seed=args.seed,
    )
    paths = export_atome_bundle(analysis, args.out_dir)

    print("Projekt Atome — Residual-Export")
    print(f"Tag: {ATOME_TAG}")
    print("Governance: I_EABC vs. R(A,Z), nicht vs. B_exp; Nullmodelle Pflicht für [B].")
    print(f"Nuklide: {analysis.nuclide_count}")
    for metric in analysis.correlations:
        print(
            f"  {metric.feature}: r={metric.pearson_r}, "
            f"rho={metric.spearman_rho}, MI={metric.mutual_information}"
        )
    print(f"Nullmodels: {len(analysis.nullmodels)} (feature × mode)")
    significant = [
        n for n in analysis.nullmodels
        if n.z_score is not None and abs(n.z_score) >= 2.0
    ]
    print(f"  |z|≥2: {len(significant)}/{len(analysis.nullmodels)}")
    print(f"Wrote {paths['summary_json']}")
    print(f"Wrote {paths['residual_csv']}")
    print(f"Wrote {paths['correlation_csv']}")
    print(f"Wrote {paths['nullmodel_csv']}")


if __name__ == "__main__":
    main()
