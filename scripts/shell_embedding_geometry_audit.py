#!/usr/bin/env python3
"""
Rigoroser Geometrie-Audit: canonical_from_qcc_bridge vs. Energiedoku (n <= 3).

Governance: Modellvalidierung only [C] — kein MetricSeparationLossExist-Claim.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.shell_embedding_geometry_audit import (  # noqa: E402
    GOVERNANCE_BOX,
    GOVERNANCE_GUARD,
    export_geometry_audit_csv,
    run_geometry_audit,
)

DEFAULT_CSV = (
    ROOT / "docs" / "energiedoku_exports" / "shell_embedding_comparison_n1_n3.csv"
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description=(
            "Geometry audit: canonical qec_bridge vs energiedoku embeddings (n<=3). "
            "Compares shape invariants up to similarity + label permutation."
        )
    )
    parser.add_argument("--n-max", type=int, default=3, help="Max renorm level (default: 3).")
    parser.add_argument(
        "--mode",
        choices=("matched_n_plus_1", "full"),
        default="matched_n_plus_1",
        help=(
            "Comparison mode: matched_n_plus_1 (fair n+1 vs n+1) or full "
            "(all points each source; may flag count mismatch)."
        ),
    )
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"Output CSV (default: {DEFAULT_CSV}).",
    )
    args = parser.parse_args()

    if args.n_max < 1 or args.n_max > 3:
        print("Error: --n-max must be in [1, 3] for this audit.", file=sys.stderr)
        sys.exit(2)

    report = run_geometry_audit(n_max=args.n_max, mode=args.mode)
    csv_path = export_geometry_audit_csv(report, args.csv)

    print("Shell embedding geometry audit (canonical vs energiedoku — [C])")
    print(GOVERNANCE_GUARD)
    print(GOVERNANCE_BOX)
    print(f"mode={args.mode}")
    print(f"Energiedoku coordinates source: {report.energiedoku_coordinates_source}")
    print()

    for row in report.rows:
        print(f"n={row['n']}:")
        print(
            f"  counts: a={row['point_count_a']}, b={row['point_count_b']}, "
            f"compatible={row['compatible']}"
        )
        print(
            f"  sep: a={row['sep_a']:.6f}, b={row['sep_b']:.6f}, "
            f"rel_diff={row['sep_rel_diff']:.6e}"
        )
        print(
            f"  invariants: dist_l2={row['distance_spectrum_l2']:.6e}, "
            f"gram_l2={row['gram_spectrum_l2']:.6e}, "
            f"radius_l2={row['radius_profile_l2']:.6e}, "
            f"procrustes={row['procrustes_rmsd']:.6e}"
        )
        print(f"  classification: {row['classification']}")
        print(f"  notes: {row['notes']}")
        print()

    print(f"Recommendation: {report.recommendation}")
    print(f"ι_n revision needed: {'yes' if report.iota_revision_needed else 'no'}")
    print(f"\nExported CSV: {csv_path} ({len(report.rows)} rows)")


if __name__ == "__main__":
    main()
