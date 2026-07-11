"""E-077 Shell-Separationsdiagnostik — synthetischer Demo-Export."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "energiedoku_exports" / "shell_separation_diagnostics_sample.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.shell_separation_diagnostics import (  # noqa: E402
    build_synthetic_shell_series,
    export_shell_separation_json,
    run_shell_separation_diagnostics,
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run shell separation diagnostics demo.")
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"JSON export path (default: {DEFAULT_JSON}).",
    )
    parser.add_argument("--n-max", type=int, default=5)
    parser.add_argument("--first-loss-level", type=int, default=4)
    args = parser.parse_args()

    series_2d = build_synthetic_shell_series(
        dim=2,
        n_max=args.n_max,
        first_loss_level=args.first_loss_level,
    )
    series_3d = build_synthetic_shell_series(
        dim=3,
        n_max=args.n_max,
        first_loss_level=args.first_loss_level,
    )

    report_2d = run_shell_separation_diagnostics(series_2d, epsilon_fn=lambda n: 1.0 / n)
    report_3d = run_shell_separation_diagnostics(series_3d, epsilon_fn=lambda n: 1.0 / n)

    print("Shell separation diagnostics (E-077 / E-078 / E-079 — diagnostic layer [C])")
    print("Governance: diagnostic only — does NOT prove MetricSeparationLossExists.\n")

    print("2D synthetic series:")
    for n, s in sorted(report_2d.sep_series.items()):
        flag = "LOSS" if report_2d.loss_flags[n] else "ok"
        overlap = report_2d.overlap_series.get(n, 0.0)
        print(f"  n={n}: sep={s:.4f}, overlap={overlap:.4f}, {flag}")
    print(f"  first_loss_n={report_2d.first_loss_n}, dim_B≈{report_2d.box_dimension}\n")

    print("3D synthetic series:")
    for n, s in sorted(report_3d.sep_series.items()):
        flag = "LOSS" if report_3d.loss_flags[n] else "ok"
        print(f"  n={n}: sep={s:.4f}, {flag}")
    print(f"  first_loss_n={report_3d.first_loss_n}, dim_B≈{report_3d.box_dimension}\n")

    out = export_shell_separation_json(report_2d, args.json)
    print(f"Exported: {out}")


if __name__ == "__main__":
    main()
