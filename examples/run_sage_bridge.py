#!/usr/bin/env python3
"""
Run the optional SageMath bridge for the Grigorian octonionic slice.

Usage:

    sage -python examples/run_sage_bridge.py

or:

    sage -python examples/run_sage_bridge.py --json

This script intentionally requires Sage only at runtime. The main
kepler_hurwitz package remains importable without SageMath.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))


def _stringify(obj: Any) -> Any:
    """
    Convert Sage objects recursively into JSON-safe strings.
    """
    if isinstance(obj, dict):
        return {str(k): _stringify(v) for k, v in obj.items()}
    if isinstance(obj, (list, tuple)):
        return [_stringify(v) for v in obj]
    if isinstance(obj, (str, int, float, bool)) or obj is None:
        return obj
    return str(obj)


def build_payload() -> dict[str, Any]:
    from kepler_hurwitz import (
        sage_export_symbolic_constraints,
        sage_interference_point_squared,
        sage_intersection_points,
        sage_resultant_mu,
        sage_resultant_Q,
        sage_verify_interference_points,
    )

    intersections = sage_intersection_points()
    interference_squared = sage_interference_point_squared()
    verification = sage_verify_interference_points()
    resultant_mu = sage_resultant_mu()
    resultant_q = sage_resultant_Q()
    symbolic_export = sage_export_symbolic_constraints()

    return {
        "description": "Symbolic SageMath constraints for the Grigorian G2 -> SU(3) octonionic slice.",
        "variables": {
            "mu": "trace-like slice coordinate",
            "Q": "slice coordinate with S = Q^2 elimination",
            "S": "Q^2, used for rational symbolic elimination",
        },
        "intersection_points": intersections,
        "interference_point_squared": interference_squared,
        "verification": verification,
        "resultant_mu": resultant_mu,
        "resultant_Q": resultant_q,
        "symbolic_constraints": symbolic_export,
    }


def print_text(payload: dict[str, Any]) -> None:
    print("# SageMath bridge: Grigorian octonionic slice")
    print()

    print("## Interference points")
    for point in payload["intersection_points"]:
        print(f"- {point}")
    print(f"- squared form (mu, S): {payload['interference_point_squared']}")
    print()

    print("## Verification")
    verification = payload["verification"]
    for key, value in verification.items():
        print(f"- {key}: {value}")
    print()

    print("## Resultant in mu")
    print(payload["resultant_mu"])
    print()

    print("## Resultant in Q")
    print(payload["resultant_Q"])
    print()

    print("## Symbolic constraints")
    constraints = payload["symbolic_constraints"]
    for key, value in constraints.items():
        print(f"- {key}: {value}")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description="Run symbolic SageMath checks for the Grigorian octonionic slice."
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Print JSON instead of human-readable text.",
    )
    parser.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Optional output path for the JSON payload.",
    )
    args = parser.parse_args(argv)

    try:
        payload = build_payload()
    except Exception as exc:
        if exc.__class__.__name__ == "SageUnavailableError":
            print(
                "SageMath is not available. Run this script with:\n\n"
                "    sage -python examples/run_sage_bridge.py",
                file=sys.stderr,
            )
            return 2
        raise

    safe_payload = _stringify(payload)

    if args.out is not None:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(
            json.dumps(safe_payload, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )

    if args.json:
        print(json.dumps(safe_payload, indent=2, ensure_ascii=False))
    else:
        print_text(safe_payload)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
