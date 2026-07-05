"""Demo der destillierten EABC-/Primvierling-Parameter."""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "energiedoku_exports" / "distilled_parameters_sample.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.distilled_parameters import (  # noqa: E402
    build_distilled_parameters_sample,
    distill_from_nat,
    distill_primvierling,
    export_distilled_parameters_json,
)
from kepler_hurwitz.primvierling import generate_prime_quadruplets  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Run distilled parameter demo.")
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"Optional JSON export path (default: {DEFAULT_JSON}).",
    )
    args = parser.parse_args()

    naturals = [6, 12, 30, 60, 210]
    primvierlinge = generate_prime_quadruplets(5, 101)[:5]

    print("Distilled parameters demo")
    print("Governance: Parameter destillieren ja; Identifikation behaupten nein.\n")

    print("Naturals:")
    for n in naturals:
        record = distill_from_nat(n)
        print(
            f"  n={n}: H={record.signature_norm}, M={record.mass_norm}, "
            f"e={record.channel_eccentricity:.3f}, L_pi={record.projection_loss}"
        )

    print("\nPrimvierlinge:")
    for v in primvierlinge:
        record = distill_primvierling(v)
        print(
            f"  p={record.p}: P={record.product}, N={record.norm}, "
            f"D_NP={record.norm_product_drift}, A_N={record.norm_signature_anisotropy}, "
            f"H(N)={record.norm_signature}"
        )

    payload = build_distilled_parameters_sample(naturals, primvierlinge)
    path = export_distilled_parameters_json(payload, args.json)
    print(f"\nWrote {path}")


if __name__ == "__main__":
    main()
