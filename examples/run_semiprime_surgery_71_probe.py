#!/usr/bin/env python3
"""Run Semiprime-surgery probe for Channel-7 class ``71 mod 256``.

Governance: exploratory ``[C]`` scaffold. Does NOT close Deep-Tail, absorption
arrow, or Collatz. See ``docs/energiedoku_exports/semiprime_chirurgie_fahrplan_kanal7_2026_07_21.md``.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.semiprime_surgery_71_probe import (  # noqa: E402
    export_probe_json,
    run_semiprime_surgery_71_probe,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Semiprime surgery probe for 71 mod 256 (exploratory [C])."
    )
    parser.add_argument("--j-max", type=int, default=5)
    parser.add_argument("--samples-per-child", type=int, default=8)
    parser.add_argument("--depth", type=int, default=1)
    parser.add_argument(
        "--out",
        type=Path,
        default=ROOT / "docs/exports/semiprime_surgery_71_mod256_probe.json",
    )
    parser.add_argument(
        "--print-summary",
        action="store_true",
        help="Print a short JSON summary to stdout.",
    )
    args = parser.parse_args()

    payload = export_probe_json(
        args.out,
        j_max=args.j_max,
        samples_per_child=args.samples_per_child,
        depth=args.depth,
    )
    print(f"Wrote {args.out}")
    checks = payload["computed_from_existing"]["lean_aligned_checks"]
    surg = payload["provisional_surgery_matrix_C"]
    print(
        f"lean_checks.ok={checks['ok']}  "
        f"surgery_cut_edges={surg['cut_edge_count']}  "
        f"states={surg['states_mod1024']}"
    )
    print(
        "Non-claim: does NOT close Deep-Tail entry, BoolTrace→descent, or Collatz."
    )
    if args.print_summary:
        summary = {
            "governance": payload["governance"],
            "target": payload["target"],
            "lean_aligned_checks": checks,
            "surgery_dense_matrix": surg["dense_matrix"],
            "column_labels": surg["column_labels"],
            "open_reductions": payload["open_reductions"],
        }
        print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
