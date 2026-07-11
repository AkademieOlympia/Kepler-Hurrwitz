#!/usr/bin/env python3
"""
Path B2: Unified interpretive ι_n bridge (Track A qec_bridge ↔ Track B energiedoku).

Governance: exploratory [C] — Gate INACTIVE, no commit to global bijection.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "src"))

from kepler_hurwitz.shell_separation_diagnostics import (  # noqa: E402
    GOVERNANCE_GUARD,
    SHELL_PRIME_MATCH_GATE_ACTIVE,
)
from kepler_hurwitz.unified_shell_embedding import (  # noqa: E402
    UNIFIED_BRIDGE_GATE_ELIGIBLE,
    UNIFIED_BRIDGE_STATUS,
    UnifiedEmbeddingBridge,
    export_unified_bridge_csv,
    run_unified_bridge_report,
)

DEFAULT_CSV = ROOT / "docs" / "energiedoku_exports" / "unified_embedding_bridge_n123.csv"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Path B2 unified ι_n bridge report (n<=3, exploratory)."
    )
    parser.add_argument("--n-max", type=int, default=3, help="Max renorm level (default: 3).")
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"Output CSV (default: {DEFAULT_CSV}).",
    )
    args = parser.parse_args()

    if args.n_max < 1 or args.n_max > 3:
        print("Error: --n-max must be in [1, 3] for unified bridge.", file=sys.stderr)
        sys.exit(2)

    report = run_unified_bridge_report(n_max=args.n_max)
    csv_path = export_unified_bridge_csv(report, args.csv)
    bridge = UnifiedEmbeddingBridge.default()

    print("Unified embedding bridge (Path B2 — exploratory [C])")
    print(GOVERNANCE_GUARD)
    print(f"Bridge status: {UNIFIED_BRIDGE_STATUS}")
    print(f"Gate eligible: {UNIFIED_BRIDGE_GATE_ELIGIBLE}")
    print(f"Gate active: {SHELL_PRIME_MATCH_GATE_ACTIVE}")
    print()

    for sep in report.sep_results:
        print(f"n={sep.n} separation:")
        print(f"  sep_canonical={sep.sep_canonical:.6f}")
        print(f"  sep_energiedoku_diagnostic={sep.sep_energiedoku_diagnostic:.6f}")
        print(f"  sep_energiedoku_full={sep.sep_energiedoku_full:.6f}")
        print(f"  sep_bridged={sep.sep_bridged:.6f}")
        print(f"  delta bridged vs canonical={sep.sep_delta_bridged_vs_canonical:.6f}")
        print(f"  delta bridged vs energiedoku={sep.sep_delta_bridged_vs_energiedoku:.6f}")
        print(f"  proof_status={sep.proof_status}")
        print()

    print("--- Compatibility ι_{n+1}|_{S_n} = ι_n ---")
    for compat in report.compatibility_results:
        print(
            f"n={compat.n} -> n+1={compat.n_plus_1}: "
            f"bridged_compatible={compat.bridged_compatible} "
            f"raw_canonical={compat.raw_canonical_compatible} "
            f"max_delta={compat.max_coord_delta:.2e} "
            f"[{compat.proof_status}]"
        )
        print(f"  notes: {compat.notes}")
    print()

    print(f"Bijection status: {report.bijection_status}")
    print(f"Recommendation: {report.recommendation}")
    print(f"\nExported CSV: {csv_path} ({len(report.rows)} rows)")


if __name__ == "__main__":
    main()
