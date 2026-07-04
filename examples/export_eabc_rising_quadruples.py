"""Export greedy rising EABC quadruples for the first N primes."""

from __future__ import annotations

import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "eabc_rising_quadruples_2000.csv"
DEFAULT_PRIME_COUNT = 2000
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_rising_collection import (  # noqa: E402
    collect_eabc_rising_quadruples,
    summarize_quadruples,
)

CSV_FIELDS = [
    "index",
    "p1",
    "p2",
    "p3",
    "p4",
    "channels",
    "span",
    "gaps",
    "canonical",
]


def export_eabc_rising_quadruples_csv(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruples, _eabc_stream = collect_eabc_rising_quadruples(prime_count)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for row in quadruples:
            writer.writerow(row.as_csv_row())
    return destination


def main() -> None:
    path = export_eabc_rising_quadruples_csv(DEFAULT_OUT, DEFAULT_PRIME_COUNT)
    quadruples, eabc_stream = collect_eabc_rising_quadruples(DEFAULT_PRIME_COUNT)
    stats = summarize_quadruples(quadruples)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print(f"Wrote {path} ({row_count} data rows + header)")
    print(f"EABC-class primes in scan: {len(eabc_stream)}")
    print(f"Quadruples found: {stats['count']}")
    print(f"Canonical: {stats['canonical_count']}, non-canonical: {stats['noncanonical_count']}")
    print(f"All EABC-complete: {stats['all_eabc_complete']}")
    if stats["first"]:
        print(f"First row: {stats['first']}")
    if stats["last"]:
        print(f"Last row: {stats['last']}")


if __name__ == "__main__":
    main()
