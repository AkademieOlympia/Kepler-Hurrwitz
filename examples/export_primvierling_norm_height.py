"""Export Primvierling norm-height data as CSV."""

from __future__ import annotations

import csv
import sys
from math import isqrt
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "docs" / "energiedoku_exports" / "primvierling_norm_height.csv"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import build_dumas_natural_fill
from kepler_hurwitz.primvierling import generate_prime_quadruplets, pair_gaps, quat_norm

DEFAULT_COUNT = 50


def first_n_prime_quadruplets(n: int) -> list[tuple[int, int, int, int]]:
    """Return the first *n* canonical prime quadruplets (p, p+2, p+6, p+8)."""
    if n < 1:
        raise ValueError("n must be >= 1")

    stop = 100
    while True:
        quadruplets = generate_prime_quadruplets(2, stop)
        if len(quadruplets) >= n:
            return quadruplets[:n]
        stop *= 2


def norm_height_records(quadruplets: list[tuple[int, int, int, int]]) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for index, (a, b, c, e) in enumerate(quadruplets, start=1):
        norm = quat_norm((a, b, c, e))
        fill = build_dumas_natural_fill((a, b, c, e))
        records.append(
            {
                "index": index,
                "p": a,
                "A": a,
                "B": b,
                "C": c,
                "E": e,
                "norm_height": norm,
                "sqrt_norm": isqrt(norm),
                "pair_gaps": pair_gaps((a, b, c, e)),
                "host_E": fill.host_components["E"],
                "host_A": fill.host_components["A"],
                "host_B": fill.host_components["B"],
                "host_C": fill.host_components["C"],
                "triple_slot_primes": ",".join(str(slot.prime) for slot in fill.triple_slots),
            }
        )
    return records


def export_primvierling_norm_height_csv(
    output_path: str | Path,
    count: int = DEFAULT_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruplets = first_n_prime_quadruplets(count)
    records = norm_height_records(quadruplets)
    fields = [
        "index",
        "p",
        "A",
        "B",
        "C",
        "E",
        "norm_height",
        "sqrt_norm",
        "pair_gaps",
        "host_E",
        "host_A",
        "host_B",
        "host_C",
        "triple_slot_primes",
    ]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(records)
    return destination


def main() -> None:
    path = export_primvierling_norm_height_csv(OUT)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print(f"Wrote {path} ({row_count} data rows + header)")


if __name__ == "__main__":
    main()
