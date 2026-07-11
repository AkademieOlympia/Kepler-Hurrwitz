"""Compare greedy rising vs channel-bucket EABC partition for the first N primes."""

from __future__ import annotations

import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "eabc_partition_comparison_2000.csv"
DEFAULT_PRIME_COUNT = 2000
sys.path.insert(0, str(SRC))

from kepler_hurwitz.eabc_rising_collection import (  # noqa: E402
    partition_eabc_quadruples_by_channels,
    summarize_partition,
)

CSV_FIELDS = [
    "m",
    "K_bucket",
    "K_greedy",
    "R_bucket",
    "Coverage_bucket",
    "GreedyEfficiency",
    "GreedyLoss",
]


def export_partition_comparison_csv(
    output_path: str | Path,
    prime_count: int = DEFAULT_PRIME_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)

    quadruples, eabc_stream, remainder = partition_eabc_quadruples_by_channels(prime_count)
    stats = summarize_partition(quadruples, eabc_stream, remainder)

    row = {
        "m": stats["m"],
        "K_bucket": stats["K_bucket"],
        "K_greedy": stats["K_greedy"],
        "R_bucket": stats["R_bucket"],
        "Coverage_bucket": f"{stats['Coverage_bucket']:.6f}",
        "GreedyEfficiency": f"{stats['GreedyEfficiency']:.6f}",
        "GreedyLoss": f"{stats['GreedyLoss']:.6f}",
    }

    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        writer.writerow(row)
    return destination


def main() -> None:
    path = export_partition_comparison_csv(DEFAULT_OUT, DEFAULT_PRIME_COUNT)
    print(f"Wrote {path}")


if __name__ == "__main__":
    main()
