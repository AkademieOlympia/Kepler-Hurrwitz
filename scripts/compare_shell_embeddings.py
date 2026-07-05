#!/usr/bin/env python3
"""
Vergleich canonical_from_qec_bridge vs. theorematische Energiedoku-Einbettung (n <= 3).

Governance: Diagnose only — E-077–E-079 [C], Gate INACTIVE.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.energiedoku_shell_construction import (  # noqa: E402
    coordinates_source,
)
from kepler_hurwitz.shell_embedding_comparison import (  # noqa: E402
    comparison_summary_dict,
    export_comparison_csv,
    export_full_energiedoku_csv,
    run_full_energiedoku_diagnostics,
    run_shell_embedding_comparison,
)
from kepler_hurwitz.shell_prefix_word_map import (  # noqa: E402
    export_prefix_word_map_csv,
    run_prefix_word_map,
)
from kepler_hurwitz.shell_separation_diagnostics import GOVERNANCE_GUARD  # noqa: E402

DEFAULT_CSV = ROOT / "docs" / "energiedoku_exports" / "shell_embedding_comparison_n123.csv"
DEFAULT_PREFIX_MAP_CSV = (
    ROOT / "docs" / "energiedoku_exports" / "shell_prefix_word_map_n123.csv"
)
DEFAULT_FULL_ENERGIEDOKU_CSV = (
    ROOT / "docs" / "energiedoku_exports" / "shell_energiedoku_full_n23.csv"
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Compare canonical qec_bridge vs energiedoku cardinal/lattice embeddings (n<=3)."
        )
    )
    parser.add_argument("--n-max", type=int, default=3, help="Max renorm level (default: 3).")
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"Output CSV (default: {DEFAULT_CSV}).",
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=None,
        help="Optional JSON summary export.",
    )
    parser.add_argument(
        "--full-energiedoku",
        action="store_true",
        help="Run full 4^n energiedoku diagnostics and prefix↔word mapping (n<=3).",
    )
    parser.add_argument(
        "--prefix-map-csv",
        type=Path,
        default=DEFAULT_PREFIX_MAP_CSV,
        help=f"Prefix↔word map CSV (default: {DEFAULT_PREFIX_MAP_CSV}).",
    )
    parser.add_argument(
        "--full-energiedoku-csv",
        type=Path,
        default=DEFAULT_FULL_ENERGIEDOKU_CSV,
        help=f"Full 4^n energiedoku CSV (default: {DEFAULT_FULL_ENERGIEDOKU_CSV}).",
    )
    args = parser.parse_args()

    if args.n_max < 1 or args.n_max > 3:
        print("Error: --n-max must be in [1, 3] for this comparison.", file=sys.stderr)
        sys.exit(2)

    report = run_shell_embedding_comparison(n_max=args.n_max)
    csv_path = export_comparison_csv(report, args.csv)

    print("Shell embedding comparison (canonical vs energiedoku — diagnostic [C])")
    print(GOVERNANCE_GUARD)
    print(f"Energiedoku coordinates source: {coordinates_source()}")
    print()

    for s in report.summaries:
        print(f"n={s.n}:")
        print(f"  shell counts: canonical={s.shell_count_canonical}, "
              f"energiedoku_diag={s.shell_count_energiedoku}, "
              f"energiedoku_full={s.shell_count_energiedoku_full}")
        print(f"  max_coord_diff={s.max_coordinate_diff:.6f}, "
              f"hausdorff_diag={s.hausdorff_proxy_diagnostic:.6f}, "
              f"hausdorff_full={s.hausdorff_proxy_full:.6f}")
        print(f"  sep: canonical={s.sep_canonical:.6f}, "
              f"energiedoku_diag={s.sep_energiedoku_diagnostic:.6f}, "
              f"energiedoku_full={s.sep_energiedoku_full:.6f}")
        print(f"  loss (theorematic_energiedoku_v1 eps): "
              f"canonical={s.loss_canonical_energiedoku_eps}, "
              f"energiedoku={s.loss_energiedoku_energiedoku_eps}")
        print(f"  loss (theorematic_mn_sep_v1 eps): "
              f"canonical={s.loss_canonical_mn_sep_eps}, "
              f"energiedoku={s.loss_energiedoku_mn_sep_eps}")
        print(f"  identical={s.identical_shells}, divergent={s.divergent_shell_indices}")
        print(f"  notes: {s.notes}")
        print()

    print(f"Recommendation: {report.recommendation}")
    print(f"\nExported CSV: {csv_path} ({len(report.rows)} rows)")

    if args.full_energiedoku:
        map_report = run_prefix_word_map(n_max=args.n_max)
        map_csv = export_prefix_word_map_csv(map_report, args.prefix_map_csv)
        full_report = run_full_energiedoku_diagnostics(
            levels=tuple(range(1, args.n_max + 1))
        )
        full_csv = export_full_energiedoku_csv(full_report, args.full_energiedoku_csv)

        print("\n--- Prefix ↔ EABC word mapping ---")
        print(f"Bijection status: {map_report.bijection_status}")
        print(f"Injective (index_diagnostic): {map_report.injective_index_diagnostic}")
        print(f"Injective (coordinate_nearest): {map_report.injective_coordinate_nearest}")
        for reason in map_report.bijection_reasons:
            print(f"  - {reason}")
        print(f"Mapping recommendation: {map_report.recommendation}")
        print(f"Exported prefix map CSV: {map_csv} ({len(map_report.rows)} rows)")

        print("\n--- Full 4^n energiedoku diagnostics ---")
        for row in full_report.rows:
            print(f"n={row.n} (count={row.shell_count}):")
            print(f"  sep={row.sep:.6f}, overlap(ed)={row.overlap_count_energiedoku_eps}, "
                  f"overlap(mn)={row.overlap_count_mn_sep_eps}")
            print(f"  loss (theorematic_energiedoku_v1)={row.shell_separation_loss_energiedoku}, "
                  f"loss (theorematic_mn_sep_v1)={row.shell_separation_loss_mn_sep}")
            print(f"  boundary={row.sep_equals_epsilon_boundary}, notes: {row.notes}")
        print(f"first_loss_n (energiedoku eps): {full_report.first_loss_n_energiedoku}")
        print(f"first_loss_n (mn_sep eps): {full_report.first_loss_n_mn_sep}")
        print(f"n=2 loss robust on full ShellVertex(2): {full_report.n2_loss_robust_on_full}")
        print(f"Full energiedoku recommendation: {full_report.recommendation}")
        print(f"Exported full energiedoku CSV: {full_csv} ({len(full_report.rows)} rows)")

    if args.json is not None:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(
            json.dumps(comparison_summary_dict(report), indent=2, sort_keys=True) + "\n",
            encoding="utf-8",
        )
        print(f"Exported JSON: {args.json}")


if __name__ == "__main__":
    main()
