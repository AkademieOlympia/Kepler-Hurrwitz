"""Demo der priorisierten EABC-/Collatz-/Primvierling-Diagnostics."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "energiedoku_exports" / "diagnostics_sample.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.diagnostics import (  # noqa: E402
    build_diagnostics_sample,
    collatz_net_descent_diagnostics,
    distill_from_nat,
    distill_primvierling,
    export_diagnostics_json,
)
from kepler_hurwitz.primvierling import generate_prime_quadruplets  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser(description="Run diagnostics demo.")
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"Optional JSON export path (default: {DEFAULT_JSON}).",
    )
    args = parser.parse_args()

    naturals = [6, 12, 30, 60, 210]
    primvierlinge = generate_prime_quadruplets(5, 101)[:5]
    collatz_cases = [(27, 3), (15, 3)]

    print("Diagnostics demo")
    print("Governance: M != Omega; Q != ||i||_inf im Allgemeinen.\n")

    print("Naturals:")
    for n in naturals:
        record = distill_from_nat(n)
        print(
            f"  n={n}: H={record.signature_norm}, M={record.mass_norm}, "
            f"S={record.channel_entropy:.3f}, rho_PG={record.prime_grid_compression:.3f}, "
            f"L_pi={record.projection_loss}"
        )

    print("\nPrimvierlinge:")
    for v in primvierlinge:
        record = distill_primvierling(v)
        print(
            f"  p={record.p}: delta_H={record.norm_signature_defect}, "
            f"H(P)={record.product_signature}, H(N)={record.norm_signature}, "
            f"L_pi={record.projection_loss}"
        )

    print("\nCollatz net descent (V2.7 diagnostics):")
    for n, t_loc in collatz_cases:
        record = collatz_net_descent_diagnostics(n, t_loc)
        print(
            f"  n={record.n}: C_bad={record.bad_run_cost}, "
            f"Delta_net={record.net_descent_margin}, eta={record.shrink_efficiency:.3f}"
        )

    payload = build_diagnostics_sample(naturals, primvierlinge, collatz_cases)
    path = export_diagnostics_json(payload, args.json)
    print(f"\nWrote {path}")


if __name__ == "__main__":
    main()
