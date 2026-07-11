"""Demo: Collatz-Trajektorien und Stopping Times (analytische Perspektiven)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.collatz_analytics import (  # noqa: E402
    GEOMETRIC_MEAN_HEURISTIC,
    batch_stopping_times,
    collatz_trajectory,
    inverse_predecessors,
    stopping_time,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Collatz trajectory analytics demo (Governance: Heuristik [C], kein Beweis)."
    )
    parser.add_argument(
        "--n",
        type=int,
        default=7,
        help="Startwert für Einzel-Trajektorie (default: 7).",
    )
    parser.add_argument(
        "--batch",
        type=int,
        nargs="*",
        default=[7, 15, 27, 97],
        help="Startwerte für Stopping-Time-Batch.",
    )
    args = parser.parse_args()

    traj = collatz_trajectory(args.n)
    print("Collatz analytics demo")
    print(
        "Governance: sqrt(3)/2-Heuristik und Tao 2019 sind [C]-Literatur, "
        "nicht Projektbeweis; V2.7-Kern bleibt Δ_net > 0 in Lean."
    )
    print(f"Geometric-mean heuristic (NOT proof): {GEOMETRIC_MEAN_HEURISTIC:.6f}\n")

    print(f"n={args.n}: trajectory ({len(traj) - 1} steps)")
    print("  " + " → ".join(str(v) for v in traj))
    print(f"  stopping_time = {stopping_time(args.n)}")

    leaf = traj[-2] if len(traj) > 1 else args.n
    print(f"\nInverse predecessors of penultimate value {leaf}: {inverse_predecessors(leaf)}")

    print("\nBatch stopping times:")
    for n, t in batch_stopping_times(args.batch):
        print(f"  n={n:>3}: stopping_time={t}")


if __name__ == "__main__":
    main()
