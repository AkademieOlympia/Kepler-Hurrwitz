"""Export channel-bucket EABC partition quadruples for the first N primes."""

from __future__ import annotations

import argparse
import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "eabc_partition_quadruples_2000.csv"
DEFAULT_PRIME_COUNT = 2000
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_rising_collection import (  # noqa: E402
    partition_eabc_quadruples_by_channels,
    summarize_partition,
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


def export_eabc_partition_quadruples_csv(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruples, eabc_stream, remainder = partition_eabc_quadruples_by_channels(prime_count)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for row in quadruples:
            writer.writerow(row.as_csv_row())
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--n-primes",
        "--count",
        type=int,
        default=DEFAULT_PRIME_COUNT,
        dest="n_primes",
        help=f"number of primes to scan (default: {DEFAULT_PRIME_COUNT})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUT,
        help="CSV output path",
    )
    args = parser.parse_args()

    path = export_eabc_partition_quadruples_csv(args.output, args.n_primes)
    quadruples, eabc_stream, remainder = partition_eabc_quadruples_by_channels(args.n_primes)
    stats = summarize_partition(quadruples, eabc_stream, remainder)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1

    print(f"Wrote {path} ({row_count} data rows + header)")
    print(f"EABC-class primes in scan: {stats['eabc_stream_count']}")
    print(f"Partition quadruples: {stats['quadruple_count']}")
    print(f"Used primes: {stats['used_prime_count']}, remainder: {stats['remainder_count']}")
    print(f"Coverage: {stats['coverage_ratio']:.4%}")
    print(f"Theoretical max: {stats['theoretical_max_quadruples']}")
    print(f"All EABC-complete: {stats['all_eabc_complete']}")
    if stats.get("first"):
        print(f"First row: {stats['first']}")
    elif quadruples:
        print(f"First row: {quadruples[0].as_csv_row()}")
    if quadruples:
        print(f"Last row: {quadruples[-1].as_csv_row()}")


if __name__ == "__main__":
    main()
