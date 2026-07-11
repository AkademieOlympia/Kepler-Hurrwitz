"""Export Dumas partial-order count gaps for the first N EABC quadruplets."""

from __future__ import annotations

import argparse
import csv
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "dumas_count_gaps.csv"
DEFAULT_COUNT = 1000
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import (  # noqa: E402
    HOST_CHANNEL_ORDER,
    build_dumas_natural_fill,
    host_triple_gap_pair,
    natural_fill_index_gaps,
    verify_dumas_lemma,
)
from kepler_hurwitz.primvierling import Primvierling, generate_prime_quadruplets  # noqa: E402


@dataclass(frozen=True)
class GapRecord:
    gap_type: str
    count_index_from: int
    count_index_to: int
    p_from: int | None
    p_to: int | None
    anchor_delta: int | None
    missing_indices: str
    host: str
    gap_d1: int | None
    gap_d2: int | None
    verify_ok: bool

    def as_row(self) -> dict[str, object]:
        return {
            "gap_type": self.gap_type,
            "count_index_from": self.count_index_from,
            "count_index_to": self.count_index_to,
            "p_from": self.p_from if self.p_from is not None else "",
            "p_to": self.p_to if self.p_to is not None else "",
            "anchor_delta": self.anchor_delta if self.anchor_delta is not None else "",
            "missing_indices": self.missing_indices,
            "host": self.host,
            "gap_d1": self.gap_d1 if self.gap_d1 is not None else "",
            "gap_d2": self.gap_d2 if self.gap_d2 is not None else "",
            "verify_ok": self.verify_ok,
        }


def first_n_prime_quadruplets(n: int) -> list[Primvierling]:
    """Return the first *n* canonical prime quadruplets ``(p, p+2, p+6, p+8)``."""
    if n < 1:
        raise ValueError("n must be >= 1")

    stop = 100
    while True:
        quadruplets = generate_prime_quadruplets(2, stop)
        if len(quadruplets) >= n:
            return quadruplets[:n]
        stop *= 2


def collect_dumas_count_gaps(quadruplets: list[Primvierling]) -> list[GapRecord]:
    """Find natural-fill index gaps and anchor-enumeration gaps."""
    records: list[GapRecord] = []

    for index, v in enumerate(quadruplets, start=1):
        fill = build_dumas_natural_fill(v)
        verify_ok = verify_dumas_lemma(v)
        missing = natural_fill_index_gaps(fill)
        if missing:
            records.append(
                GapRecord(
                    gap_type="natural_fill_index",
                    count_index_from=index,
                    count_index_to=index,
                    p_from=v[0],
                    p_to=v[0],
                    anchor_delta=None,
                    missing_indices=",".join(str(i) for i in missing),
                    host="",
                    gap_d1=None,
                    gap_d2=None,
                    verify_ok=verify_ok,
                )
            )

    for index in range(1, len(quadruplets)):
        left = quadruplets[index - 1]
        right = quadruplets[index]
        p_from = left[0]
        p_to = right[0]
        delta = p_to - p_from
        if delta > 2:
            records.append(
                GapRecord(
                    gap_type="anchor_enumeration",
                    count_index_from=index,
                    count_index_to=index + 1,
                    p_from=p_from,
                    p_to=p_to,
                    anchor_delta=delta,
                    missing_indices="",
                    host="",
                    gap_d1=None,
                    gap_d2=None,
                    verify_ok=True,
                )
            )

    return records


def partial_count_summary(quadruplets: list[Primvierling]) -> dict[str, object]:
    """Summarize the partial-order count check over all quadruplets."""
    natural_fill_gaps = 0
    verify_failures = 0
    for v in quadruplets:
        fill = build_dumas_natural_fill(v)
        if natural_fill_index_gaps(fill):
            natural_fill_gaps += 1
        if not verify_dumas_lemma(v):
            verify_failures += 1

    anchor_gaps = sum(
        1
        for i in range(1, len(quadruplets))
        if quadruplets[i][0] - quadruplets[i - 1][0] > 2
    )
    return {
        "quadruplet_count": len(quadruplets),
        "natural_fill_gap_free": natural_fill_gaps == 0,
        "natural_fill_gap_quadruplets": natural_fill_gaps,
        "verify_failures": verify_failures,
        "anchor_enumeration_gaps": anchor_gaps,
        "first_anchor_p": quadruplets[0][0] if quadruplets else None,
        "last_anchor_p": quadruplets[-1][0] if quadruplets else None,
        "canonical_host_gap_pairs": {
            host.value: host_triple_gap_pair(host) for host in HOST_CHANNEL_ORDER
        },
    }


def export_dumas_count_gaps_csv(
    output_path: str | Path,
    count: int = DEFAULT_COUNT,
) -> tuple[Path, dict[str, object]]:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    quadruplets = first_n_prime_quadruplets(count)
    records = collect_dumas_count_gaps(quadruplets)
    summary = partial_count_summary(quadruplets)

    fields = [
        "gap_type",
        "count_index_from",
        "count_index_to",
        "p_from",
        "p_to",
        "anchor_delta",
        "missing_indices",
        "host",
        "gap_d1",
        "gap_d2",
        "verify_ok",
    ]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        writer.writerows(record.as_row() for record in records)

    return destination, summary


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--count",
        type=int,
        default=DEFAULT_COUNT,
        help=f"number of EABC quadruplets (default: {DEFAULT_COUNT})",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUT,
        help="CSV output path",
    )
    args = parser.parse_args()

    path, summary = export_dumas_count_gaps_csv(args.output, count=args.count)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1

    print(f"Wrote {path} ({row_count} gap rows + header)")
    print(f"Quadruplets analysed: {summary['quadruplet_count']}")
    print(f"Natural-fill 1..12 gap-free: {summary['natural_fill_gap_free']}")
    print(f"Natural-fill gap quadruplets: {summary['natural_fill_gap_quadruplets']}")
    print(f"Dumas verify failures: {summary['verify_failures']}")
    print(f"Anchor enumeration gaps: {summary['anchor_enumeration_gaps']}")
    print(f"Anchor range: {summary['first_anchor_p']} .. {summary['last_anchor_p']}")
    print(f"Canonical host gap pairs: {summary['canonical_host_gap_pairs']}")


if __name__ == "__main__":
    main()
