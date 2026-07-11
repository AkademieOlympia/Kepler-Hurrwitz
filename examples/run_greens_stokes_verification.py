"""Export Green–Stokes disk verification for F = (-y, x, 0)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "exports" / "greens_stokes_verification.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.greens_stokes_verification import (  # noqa: E402
    GREENS_STOKES_TAG,
    REFERENCE_FIELD,
    export_verification_json,
    verify_greens_stokes,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Verify Green and Stokes theorems on disk (F = <-y, x, 0>)."
    )
    parser.add_argument("--radius", type=float, default=1.0, help="Disk radius R (default: 1).")
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"JSON output path (default: {DEFAULT_JSON}).",
    )
    parser.add_argument("--n-samples", type=int, default=4096, help="Line integral samples.")
    args = parser.parse_args()

    result = verify_greens_stokes(args.radius, n_samples=args.n_samples)
    path = export_verification_json(result, args.json)

    print("Green–Stokes verification")
    print(f"Tag: {GREENS_STOKES_TAG}")
    print(f"Field: {REFERENCE_FIELD}")
    print(f"R = {result.radius}")
    print(f"Analytic:     {result.analytic:.12f}")
    print(f"Line integral:{result.line_integral:.12f}  (rel err {result.line_relative_error:.2e})")
    print(f"Green (2D):   {result.greens_double_integral:.12f}  (rel err {result.greens_relative_error:.2e})")
    print(f"Stokes (3D):  {result.stokes_surface_integral:.12f}  (rel err {result.stokes_relative_error:.2e})")
    print(f"Green == Stokes: {result.green_equals_stokes}")
    print(f"Wrote {path}")


if __name__ == "__main__":
    main()
