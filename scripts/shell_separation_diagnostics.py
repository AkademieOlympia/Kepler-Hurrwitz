#!/usr/bin/env python3
"""
Shell-Separationsdiagnostik — reproduzierbarer CSV-Export (E-077 / E-078 / E-079).

Governance: Diagnose only — keine Beweisclaims. Siehe
docs/reports/shell_separation_diagnostics_protocol.md
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.shell_construction import (  # noqa: E402
    CANONICAL_EPSILON_RULE_NAME,
    CANONICAL_NOT_IMPLEMENTED_MESSAGE,
    EPSILON_RULE_NAMES,
    get_construction,
    get_epsilon_rule,
    shell_series_from_construction,
)
from kepler_hurwitz.shell_detector_controls import (  # noqa: E402
    export_detector_controls_csv,
    run_detector_controls,
)
from kepler_hurwitz.shell_separation_diagnostics import (  # noqa: E402
    GOVERNANCE_GUARD,
    export_box_dimension_csv,
    export_shell_separation_csv,
    export_shell_separation_json,
    run_shell_separation_diagnostics,
)

DEFAULT_CONTROLS_CSV = ROOT / "docs" / "energiedoku_exports" / "shell_detector_controls.csv"
DEFAULT_DIAG_CSV = ROOT / "docs" / "energiedoku_exports" / "shell_separation_diagnostics.csv"
DEFAULT_DIM_CSV = ROOT / "docs" / "energiedoku_exports" / "shell_box_dimension_estimates.csv"
DEFAULT_JSON = ROOT / "docs" / "energiedoku_exports" / "shell_separation_diagnostics_sample.json"
EPS_GRID = (0.5, 0.25, 0.125, 0.0625, 0.03125)


def _n_levels_for_construction(construction_name: str, *, n_max: int) -> tuple[int, ...]:
    if construction_name == "toy":
        return (1, 2, 3)
    if construction_name == "canonical":
        from kepler_hurwitz.canonical_shell_vertices import max_renorm_level

        cap = min(n_max, max_renorm_level()) if n_max > 0 else max_renorm_level()
        return tuple(range(1, cap + 1))
    return tuple(range(1, n_max + 1))


def _run_controls(args: argparse.Namespace) -> None:
    rows = run_detector_controls(
        epsilon=args.control_epsilon,
        n_shells=args.control_n_shells,
        points_per_shell=args.control_points_per_shell,
    )
    csv_path = export_detector_controls_csv(rows, args.controls_csv)

    deterministic = [r for r in rows if r["control_name"] != "random_null"]
    random_rows = [r for r in rows if r["control_name"] == "random_null"]
    all_passed = all(r["passed"] for r in deterministic)
    random_loss_rate = (
        sum(1 for r in random_rows if r["shell_separation_loss"]) / len(random_rows)
        if random_rows
        else 0.0
    )

    print("Shell detector validation controls (diagnostic layer [C])")
    print(GOVERNANCE_GUARD)
    print()
    for row in rows:
        status = "PASS" if row["passed"] else "FAIL"
        seed_part = f", seed={row['seed']}" if row["seed"] != "" else ""
        print(
            f"  [{status}] {row['control_name']}{seed_part}: "
            f"sep={row['sep']:.6f}, overlap={row['overlap_count']}, "
            f"loss={row['shell_separation_loss']}"
        )
    print()
    print(f"deterministic_controls_passed={'yes' if all_passed else 'no'}")
    print(f"random_loss_rate={random_loss_rate:.2f} ({len(random_rows)} seeds)")
    print(f"\nExported controls CSV: {csv_path} ({len(rows)} rows)")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Run shell separation diagnostics and export CSV/JSON."
    )
    parser.add_argument(
        "--controls",
        action="store_true",
        help="Run detector validation controls (null/stress) and export CSV.",
    )
    parser.add_argument(
        "--controls-csv",
        type=Path,
        default=DEFAULT_CONTROLS_CSV,
        help=f"Detector controls CSV (default: {DEFAULT_CONTROLS_CSV}).",
    )
    parser.add_argument(
        "--control-epsilon",
        type=float,
        default=1.0,
        help="Epsilon threshold for control suite (default: 1.0).",
    )
    parser.add_argument(
        "--control-n-shells",
        type=int,
        default=4,
        help="Number of shells per control case (default: 4).",
    )
    parser.add_argument(
        "--control-points-per-shell",
        type=int,
        default=5,
        help="Points per shell for random null control (default: 5).",
    )
    parser.add_argument(
        "--diagnostics-csv",
        type=Path,
        default=DEFAULT_DIAG_CSV,
        help=f"Shell diagnostics CSV (default: {DEFAULT_DIAG_CSV}).",
    )
    parser.add_argument(
        "--dimension-csv",
        type=Path,
        default=DEFAULT_DIM_CSV,
        help=f"Box dimension CSV (default: {DEFAULT_DIM_CSV}).",
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"Optional JSON sample export (default: {DEFAULT_JSON}).",
    )
    parser.add_argument(
        "--construction",
        choices=("toy", "synthetic", "combined", "canonical"),
        default="combined",
        help="Shell construction layer (default: combined for backward compatibility).",
    )
    parser.add_argument(
        "--source",
        choices=("toy", "synthetic", "combined"),
        default=None,
        help="Deprecated alias for --construction (toy/synthetic/combined only).",
    )
    parser.add_argument("--n-max", type=int, default=5)
    parser.add_argument("--first-loss-level", type=int, default=4)
    parser.add_argument(
        "--epsilon-rule",
        choices=sorted(EPSILON_RULE_NAMES),
        default=CANONICAL_EPSILON_RULE_NAME,
        help=(
            "Threshold rule epsilon_n (default: provisional_inverse_n = 1/n; "
            "theorematic_energiedoku_v1: Energiedoku §8 for n in {1,2,3}; "
            "theorematic_mn_sep_v1: [C] epsilon_n = 4^{-n} from M_n^sep = 4^n)."
        ),
    )
    args = parser.parse_args()

    if args.controls:
        _run_controls(args)
        return

    construction_name = args.source if args.source is not None else args.construction

    if args.source is not None and args.construction != "combined":
        print(
            "Warning: both --source and --construction given; --source takes precedence "
            "for toy/synthetic/combined.",
            file=sys.stderr,
        )

    try:
        construction = get_construction(
            construction_name,
            dim=3,
            n_max=args.n_max,
            first_loss_level=args.first_loss_level,
        )
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(2)

    if construction_name == "canonical":
        try:
            construction.shells_at(1)
        except NotImplementedError as exc:
            print("Canonical shell construction unavailable.", file=sys.stderr)
            print(str(exc) or CANONICAL_NOT_IMPLEMENTED_MESSAGE, file=sys.stderr)
            sys.exit(1)

    n_levels = _n_levels_for_construction(construction_name, n_max=args.n_max)
    shell_series = shell_series_from_construction(construction, n_levels)
    try:
        epsilon_fn, epsilon_rule_name = get_epsilon_rule(args.epsilon_rule)
    except ValueError as exc:
        print(f"Error: {exc}", file=sys.stderr)
        sys.exit(2)

    report = run_shell_separation_diagnostics(
        shell_series,
        epsilon_fn=epsilon_fn,
        eps_grid=EPS_GRID,
        data_source=construction.construction_name(),
        metric_name=construction.metric_name(),
        epsilon_rule_name=epsilon_rule_name,
    )

    diag_csv = export_shell_separation_csv(
        report,
        args.diagnostics_csv,
        epsilon_fn=epsilon_fn,
    )

    cloud: list[tuple[float, ...]] = []
    for entry in shell_series.values():
        centroids = entry.get("centroids")
        if centroids:
            cloud.extend(centroids)

    dim_csv = export_box_dimension_csv(
        tuple(cloud),
        EPS_GRID,
        args.dimension_csv,
        data_source=construction.construction_name(),
        dim_estimate=report.box_dimension,
    )

    json_path = export_shell_separation_json(report, args.json)

    print("Shell separation diagnostics (E-077 / E-078 / E-079 — diagnostic layer [C])")
    print(GOVERNANCE_GUARD)
    print(f"construction={construction_name}")
    print(f"metric={report.metric_name}, epsilon_rule={report.epsilon_rule_name}")
    print()

    for n in sorted(report.sep_series):
        flag = "LOSS" if report.loss_flags[n] else "ok"
        print(
            f"  n={n}: sep={report.sep_series[n]:.4f}, "
            f"overlap_count={report.overlap_count_series.get(n, 0)}, "
            f"embed_q={report.embedding_quality_series.get(n)}, {flag}"
        )

    print(f"\nfirst_loss_n={report.first_loss_n}")
    print(f"dim_B_estimate={report.box_dimension}")
    print(f"\nExported diagnostics CSV: {diag_csv} ({len(report.sep_series)} rows)")
    print(f"Exported dimension CSV:   {dim_csv}")
    print(f"Exported JSON sample:       {json_path}")


if __name__ == "__main__":
    main()
