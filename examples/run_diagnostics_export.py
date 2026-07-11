"""Export Top-8 Atlas-Parameter als CSV (Diagnose-/Export-Schicht)."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_CSV = ROOT / "docs" / "energiedoku_exports" / "diagnostics_parameter_atlas.csv"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.diagnostics_export import (  # noqa: E402
    GOVERNANCE_NOTE,
    build_default_atlas_export_rows,
    export_atlas_parameters_csv,
)


def main() -> None:
    parser = argparse.ArgumentParser(description="Export diagnostics parameter atlas CSV.")
    parser.add_argument(
        "--csv",
        type=Path,
        default=DEFAULT_CSV,
        help=f"CSV output path (default: {DEFAULT_CSV}).",
    )
    args = parser.parse_args()

    rows = build_default_atlas_export_rows()
    path = export_atlas_parameters_csv(rows, args.csv)

    print("Diagnostics parameter atlas export")
    print(GOVERNANCE_NOTE)
    print(f"Rows: {len(rows)}")
    print(f"Wrote {path}")


if __name__ == "__main__":
    main()
