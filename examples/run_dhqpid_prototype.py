#!/usr/bin/env python3
from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dhqpid_prototype import (  # noqa: E402
    GOVERNANCE,
    export_prototype_artifacts,
    run_dhqpid_prototype,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Bounded DH search protocol for Cardoso-Machiavelo orders (E-061 / E-062)."
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=ROOT / "docs" / "theory",
        help="Directory for CSV/JSON/Markdown exports.",
    )
    args = parser.parse_args()

    payload = export_prototype_artifacts(args.out_dir)
    summary = payload["summary"]

    print(GOVERNANCE)
    print()
    for order, row in summary.items():
        print(
            f"{order}: candidates={row['candidates']} "
            f"alpha_pool={row['alpha_pool']} "
            f"EUC ok={row['euc_success']} "
            f"DH ok={row['dh_success']} "
            f"rescues={row['rescue_cases']}"
        )
    print()
    print(f"Wrote exports under {args.out_dir}")


if __name__ == "__main__":
    main()
