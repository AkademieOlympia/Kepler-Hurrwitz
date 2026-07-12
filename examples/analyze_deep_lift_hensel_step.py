"""Run deep-lift Hensel-step diagnostic for j = 1..6 (Governance [B])."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.deep_lift_hensel_diagnostic import (  # noqa: E402
    analyze_deep_lift_hensel_steps,
    format_hensel_report,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Deep-lift Hensel-step diagnostic for 243r+95 (Ebene A, [B])."
    )
    parser.add_argument("--j-max", type=int, default=6, help="Maximum j (default: 6).")
    args = parser.parse_args()
    rows = analyze_deep_lift_hensel_steps(args.j_max)
    print(format_hensel_report(rows))


if __name__ == "__main__":
    main()
