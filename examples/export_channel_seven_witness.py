"""Export channel-7 witness classification JSON."""

from __future__ import annotations

import argparse
from pathlib import Path

from kepler_hurwitz.channel_seven_witness_scan import (
    classification_markdown_table,
    export_channel_seven_classification,
    scan_channel_seven,
)

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_JSON = ROOT / "docs" / "exports" / "channel_seven_witness_classification.json"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--out", type=Path, default=DEFAULT_JSON)
    parser.add_argument("--modulus", type=int, default=128)
    parser.add_argument("--max-t-loc", type=int, default=500)
    args = parser.parse_args()
    payload = export_channel_seven_classification(
        out_path=args.out,
        modulus=args.modulus,
        max_t_loc=args.max_t_loc,
    )
    print(payload["summary"])
    print()
    print(classification_markdown_table(scan_channel_seven(modulus=args.modulus)))


if __name__ == "__main__":
    main()
