"""Run symbolic Green/Stokes verification under SageMath."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "exports" / "greens_stokes_symbolic.json"
sys.path.insert(0, str(SRC))


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Symbolic Green/Stokes verification (SageMath required)."
    )
    parser.add_argument("--radius", type=float, default=3.0, help="Disk radius R.")
    parser.add_argument("--json", type=Path, default=None, help="Optional JSON output path.")
    args = parser.parse_args()

    try:
        from kepler_hurwitz.vector_calculus_diagnostics import (  # noqa: E402
            VECTOR_CALCULUS_TAG,
            result_to_json_dict,
            verify_greens_stokes_symbolic,
        )
    except Exception as exc:
        if exc.__class__.__name__ == "SageUnavailableError":
            print(
                "SageMath required. Run:\n\n    sage -python examples/run_vector_calculus_verification.py",
                file=sys.stderr,
            )
            return 2
        raise

    results = verify_greens_stokes_symbolic(args.radius)
    green = results["green"]
    stokes = results["stokes"]

    print("Vector calculus symbolic verification")
    print(f"Tag: {VECTOR_CALCULUS_TAG}")
    print(f"R = {args.radius}")
    print(f"Green:  line {green.line_integral} == area {green.area_integral}")
    print(f"Stokes: line {stokes.line_integral} == area {stokes.area_integral}")

    out = args.json or DEFAULT_JSON
    payload = {
        "governance": VECTOR_CALCULUS_TAG,
        "radius": args.radius,
        "green": result_to_json_dict(green),
        "stokes": result_to_json_dict(stokes),
        "unified_stokes_form": "int_{d Omega} omega = int_Omega d omega",
        "not_claimed": [
            "Symbolic disk example proves EABC channel coupling",
            "Green/Stokes identifies E-090 e3 multiplet structure",
        ],
    }
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    print(f"Wrote {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
