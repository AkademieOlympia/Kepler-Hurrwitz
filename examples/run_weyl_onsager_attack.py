"""Export Weyl–Onsager Komplettangriff diagnostics as JSON."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_JSON = ROOT / "docs" / "energiedoku_exports" / "weyl_onsager_attack.json"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.weyl_onsager_diagnostics import (  # noqa: E402
    WEYL_ONSAGER_TAG,
    build_default_attack_records,
    export_attack_records_json,
)


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export Weyl–Onsager Komplettangriff diagnostics (E-087/E-088)."
    )
    parser.add_argument(
        "--json",
        type=Path,
        default=DEFAULT_JSON,
        help=f"JSON output path (default: {DEFAULT_JSON}).",
    )
    args = parser.parse_args()

    records = build_default_attack_records()
    path = export_attack_records_json(records, args.json)

    print("Weyl–Onsager Komplettangriff export")
    print(f"Tag: {WEYL_ONSAGER_TAG}")
    print("Governance: Komplettangriff = Lesesprache + Diagnostik, nicht Großsatz.")
    print(f"Records: {len(records)}")
    print(f"Wrote {path}")


if __name__ == "__main__":
    main()
