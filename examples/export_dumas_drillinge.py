"""Export Dumas Drillinge overview table as CSV."""

from __future__ import annotations

import csv
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
OUT = ROOT / "docs" / "energiedoku_exports" / "dumas_drillinge.csv"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import (
    host_component,
    host_for_quadruplet_index,
    host_triple,
    host_triple_gap_pair,
    rotor_d_artagnan,
    sorted_gap_pair,
)
from kepler_hurwitz.primvierling import Primvierling, generate_prime_quadruplets

DEFAULT_COUNT = 1000


def first_n_prime_quadruplets(n: int) -> list[Primvierling]:
    """Return the first *n* canonical prime quadruplets (p, p+2, p+6, p+8)."""
    if n < 1:
        raise ValueError("n must be >= 1")

    stop = 100
    while True:
        quadruplets = generate_prime_quadruplets(2, stop)
        if len(quadruplets) >= n:
            return quadruplets[:n]
        stop *= 2


def format_tuple(values: tuple[int, ...]) -> str:
    inner = ", ".join(str(value) for value in values)
    return f"({inner})"


def drillinge_records(quadruplets: list[Primvierling]) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for index, v in enumerate(quadruplets, start=1):
        host = host_for_quadruplet_index(index)
        triple = host_triple(host, v)
        d_artagnan = rotor_d_artagnan(host, v)
        assert d_artagnan == host_component(host, v)
        d1, d2 = sorted_gap_pair(triple)
        expected = host_triple_gap_pair(host)
        if (d1, d2) != expected:
            raise ValueError(
                f"gap mismatch at index={index}, host={host.value}, v={v}: "
                f"got ({d1}, {d2}), expected {expected}"
            )
        records.append(
            {
                "index": index,
                "host": host.value,
                "quell_v": format_tuple(v),
                "d_artagnan": d_artagnan,
                "musketiere": format_tuple(triple),
                "d1": d1,
                "d2": d2,
                "gap_pair": format_tuple((d1, d2)),
            }
        )
    return records


def export_dumas_drillinge_csv(
    output_path: str | Path,
    count: int = DEFAULT_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruplets = first_n_prime_quadruplets(count)
    records = drillinge_records(quadruplets)
    fields = [
        "index",
        "host",
        "quell_v",
        "d_artagnan",
        "musketiere",
        "d1",
        "d2",
        "gap_pair",
    ]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(records)
    return destination


def main() -> None:
    path = export_dumas_drillinge_csv(OUT)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print(f"Wrote {path} ({row_count} data rows + header)")


if __name__ == "__main__":
    main()
