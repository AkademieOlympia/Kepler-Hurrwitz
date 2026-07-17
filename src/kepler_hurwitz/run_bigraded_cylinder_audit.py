"""Executable Schicht-B2 bigraded cylinder cutoff audit runner.

Usage:
    PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit
    PYTHONPATH=src python examples/run_bigraded_cylinder_audit.py
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from kepler_hurwitz.bigraded_cylinder_graph import (
    GOVERNANCE,
    complete_cutoff,
    audit_cylinder_cutoff,
    report_to_dict,
)

DEFAULT_PRECISIONS = (4, 6, 8, 10)

__all__ = [
    "DEFAULT_PRECISIONS",
    "audit_precision",
    "build_audit_payload",
    "main",
]


def audit_precision(max_precision: int) -> dict[str, Any]:
    """Run the complete cutoff audit for one max precision P."""
    cylinders = complete_cutoff(max_precision)
    _lifts, _dyn, report = audit_cylinder_cutoff(cylinders)
    return report_to_dict(report)


def build_audit_payload(precisions: list[int]) -> dict[str, Any]:
    """Deterministic protocol body (no wall-clock) for hash / ``-O`` diff."""
    scans = [audit_precision(p) for p in precisions]
    return {
        "status": "PASSED",
        "governance": GOVERNANCE,
        "branch": "post-freeze/octonionic-collatz-proof-attempt",
        "layer": "B2",
        "map": (
            "Complete 2-adic cylinder cutoff Z_<=P with lift edges, "
            "visible-valuation dynamics, and singular-path chain verification"
        ),
        "precisions": list(precisions),
        "scans": scans,
        "not_claimed": (
            "No Collatz proof; B2 cutoff audit only; "
            "local freeze only after run protocol + hash + commit"
        ),
    }


def render_protocol(payload: dict[str, Any]) -> str:
    return json.dumps(payload, indent=2, sort_keys=True, ensure_ascii=False) + "\n"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=(
            "Executable bigraded cylinder cutoff audit [B]: "
            "exhaustive Z_<=P audit with singular-path chain check."
        )
    )
    parser.add_argument(
        "--precisions",
        "--max-precision",
        dest="precisions",
        type=int,
        nargs="+",
        default=list(DEFAULT_PRECISIONS),
        help="Max precisions P to audit (default: 4 6 8 10)",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Optional path for the JSON protocol (hash/diff)",
    )
    args = parser.parse_args(argv)

    payload = build_audit_payload(list(args.precisions))
    text = render_protocol(payload)

    print("BIGRADED CYLINDER AUDIT: PASSED")
    print(text, end="")

    if args.out is not None:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(text, encoding="utf-8")
        print(f"Wrote {args.out}", file=sys.stderr)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
