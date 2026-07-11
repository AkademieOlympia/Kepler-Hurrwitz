"""Export Black Hole GWTC vs. Legendre gap diagnostics (E-093 / ORQ-093)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_CSV = ROOT / "data" / "black_hole" / "mock_gwtc5.csv"
DEFAULT_OUT = ROOT / "docs" / "exports"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.black_hole_legendre_gwtc import (  # noqa: E402
    BLACK_HOLE_TAG,
    build_black_hole_analysis,
    export_black_hole_bundle,
    load_gwtc_catalog,
    mock_gwtc5_events,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export Black Hole Legendre-gap vs. GWTC diagnostics (E-093)."
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=None,
        help=f"GWTC-style CSV (default: {DEFAULT_CSV} if present, else built-in mock).",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output directory (default: {DEFAULT_OUT}).",
    )
    parser.add_argument("--kappa", type=float, default=1.0, help="Quantization scale (default: 1.0).")
    parser.add_argument("--tolerance", type=float, default=0.5, help="Gap hit tolerance (default: 0.5).")
    parser.add_argument(
        "--chi-p-threshold",
        type=float,
        default=0.2,
        help="1G/2G chi_p threshold (default: 0.2).",
    )
    parser.add_argument("--max-norm", type=int, default=500, help="Prime norm ceiling (default: 500).")
    parser.add_argument("--no-kappa-sweep", action="store_true", help="Skip kappa sweep export.")
    parser.add_argument("--kappa-min", type=float, default=0.1)
    parser.add_argument("--kappa-max", type=float, default=10.0)
    parser.add_argument("--kappa-step", type=float, default=0.1)
    parser.add_argument("--seed", type=int, default=42, help="Mock catalog seed (default: 42).")
    parser.add_argument(
        "--perm-iterations",
        type=int,
        default=10_000,
        help="Permutation null iterations (default: 10000).",
    )
    parser.add_argument(
        "--no-permutation-null",
        action="store_true",
        help="Skip chi_p permutation null model.",
    )
    parser.add_argument(
        "--use-monte-carlo",
        action="store_true",
        help="Use split-normal MC P_gap permutation null (replaces binary Fisher metric).",
    )
    parser.add_argument(
        "--no-monte-carlo",
        action="store_true",
        help="Force binary permutation null even if MC was requested elsewhere.",
    )
    parser.add_argument(
        "--mc-samples",
        type=int,
        default=10_000,
        help="MC draws per event for P_gap (default: 10000).",
    )
    args = parser.parse_args()

    use_mc = args.use_monte_carlo and not args.no_monte_carlo

    if args.csv and args.csv.is_file():
        events = load_gwtc_catalog(args.csv)
    elif DEFAULT_CSV.is_file():
        events = load_gwtc_catalog(DEFAULT_CSV)
    else:
        events = mock_gwtc5_events(seed=args.seed)

    analysis = build_black_hole_analysis(
        events,
        kappa=args.kappa,
        tolerance=args.tolerance,
        chi_p_threshold=args.chi_p_threshold,
        max_norm=args.max_norm,
        kappa_sweep=not args.no_kappa_sweep,
        kappa_min=args.kappa_min,
        kappa_max=args.kappa_max,
        kappa_step=args.kappa_step,
        permutation_null=not args.no_permutation_null,
        permutation_iterations=args.perm_iterations,
        permutation_seed=args.seed,
        use_monte_carlo=use_mc,
        mc_samples=args.mc_samples,
    )
    paths = export_black_hole_bundle(analysis, args.out_dir)
    t = analysis.fisher.table
    print(f"{BLACK_HOLE_TAG} E-093 Black Hole export complete.")
    print(f"  events: {len(events)}")
    print(f"  forbidden shells: {len(analysis.forbidden_m)}")
    print(f"  contingency 1G: in={t.in_forbidden_1g} out={t.out_forbidden_1g}")
    print(f"  contingency 2G: in={t.in_forbidden_2g} out={t.out_forbidden_2g}")
    print(f"  fisher p-value: {analysis.fisher.p_value:.5f}")
    if analysis.permutation_null is not None:
        pn = analysis.permutation_null
        print(
            f"  permutation null p-value: {pn.p_value:.5f} "
            f"(obs_1g_in_gap={pn.obs_1g_in_gap}, n={pn.iterations})"
        )
    if analysis.permutation_null_mc is not None:
        pm = analysis.permutation_null_mc
        print(
            f"  MC permutation p-value: {pm.p_value:.5f} "
            f"(obs_1g_expected_hits={pm.obs_1g_expected_hits:.4f}, "
            f"perm_n={pm.iterations}, mc_samples={pm.n_mc_samples})"
        )
    for name, path in paths.items():
        print(f"  {name}: {path}")


if __name__ == "__main__":
    main()
