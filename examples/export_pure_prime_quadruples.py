"""Export the first pure prime quadruples (canonical prime quadruplets) as CSV.

Definition (repo-conform, see docs/pure_prime_quadruple_dedekind_interpretation.md):
  A *pure prime quadruple* is a canonical prime quadruplet v = (p, p+2, p+6, p+8)
  with p > 3 and all four components prime (`is_prime_quadruplet` / Lean `PrimeQuadruplet`).

  Unlike axis-aligned pure prime EABC quaternions (single p with M(p)=1), all four
  quaternion axes carry genuine primes. EABC mass on the norm height n = quat_norm(v)
  uses signature_from_nat / eabc_mass; the component product P(v)=a*b*c*e typically
  has M(P(v))=4 with full channel coverage H=(1,1,1,1).
"""

from __future__ import annotations

import argparse
import csv
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "pure_prime_quadruples.csv"
DEFAULT_COUNT = 50
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12  # noqa: E402
from kepler_hurwitz.primvierling import (  # noqa: E402
    Primvierling,
    generate_prime_quadruplets,
    is_prime_quadruplet,
    pair_gaps,
    quat_norm,
)
from kepler_hurwitz.signatures import eabc_mass, signature_from_nat  # noqa: E402

CSV_FIELDS = [
    "rank",
    "p",
    "quat_a",
    "quat_b",
    "quat_c",
    "quat_e",
    "quat_norm",
    "n",
    "E",
    "A",
    "B",
    "C",
    "M",
    "partition",
    "product_n",
    "product_E",
    "product_A",
    "product_B",
    "product_C",
    "product_M",
    "product_partition",
    "channel_a",
    "channel_b",
    "channel_c",
    "channel_e",
    "pair_gaps",
]


@dataclass(frozen=True)
class PurePrimeQuadrupleRecord:
    rank: int
    p: int
    quat_a: int
    quat_b: int
    quat_c: int
    quat_e: int
    quat_norm: int
    n: int
    E: int
    A: int
    B: int
    C: int
    M: int
    partition: str
    product_n: int
    product_E: int
    product_A: int
    product_B: int
    product_C: int
    product_M: int
    product_partition: str
    channel_a: str
    channel_b: str
    channel_c: str
    channel_e: str
    pair_gaps: int

    def as_csv_row(self) -> dict[str, object]:
        return {
            "rank": self.rank,
            "p": self.p,
            "quat_a": self.quat_a,
            "quat_b": self.quat_b,
            "quat_c": self.quat_c,
            "quat_e": self.quat_e,
            "quat_norm": self.quat_norm,
            "n": self.n,
            "E": self.E,
            "A": self.A,
            "B": self.B,
            "C": self.C,
            "M": self.M,
            "partition": self.partition,
            "product_n": self.product_n,
            "product_E": self.product_E,
            "product_A": self.product_A,
            "product_B": self.product_B,
            "product_C": self.product_C,
            "product_M": self.product_M,
            "product_partition": self.product_partition,
            "channel_a": self.channel_a,
            "channel_b": self.channel_b,
            "channel_c": self.channel_c,
            "channel_e": self.channel_e,
            "pair_gaps": self.pair_gaps,
        }


def is_pure_prime_quadruple(v: Primvierling) -> bool:
    """Return True for canonical prime quadruplets with anchor p > 3."""
    a, _, _, _ = v
    return a > 3 and is_prime_quadruplet(v)


def first_pure_prime_quadruples(count: int) -> list[PurePrimeQuadrupleRecord]:
    if count < 1:
        raise ValueError("count must be >= 1")

    stop = 100
    selected: list[Primvierling] = []
    seen: set[Primvierling] = set()
    while len(selected) < count:
        for candidate in generate_prime_quadruplets(2, stop):
            if is_pure_prime_quadruple(candidate) and candidate not in seen:
                seen.add(candidate)
                selected.append(candidate)
                if len(selected) >= count:
                    break
        if len(selected) < count:
            stop *= 2

    records: list[PurePrimeQuadrupleRecord] = []
    for index, (a, b, c, e) in enumerate(selected[:count], start=1):
        norm = quat_norm((a, b, c, e))
        sig_norm = signature_from_nat(norm)
        product = a * b * c * e
        sig_prod = signature_from_nat(product)
        records.append(
            PurePrimeQuadrupleRecord(
                rank=index,
                p=a,
                quat_a=a,
                quat_b=b,
                quat_c=c,
                quat_e=e,
                quat_norm=norm,
                n=norm,
                E=sig_norm.E,
                A=sig_norm.A,
                B=sig_norm.B,
                C=sig_norm.C,
                M=eabc_mass(norm),
                partition=",".join(str(value) for value in sig_norm.sorted_counts()),
                product_n=product,
                product_E=sig_prod.E,
                product_A=sig_prod.A,
                product_B=sig_prod.B,
                product_C=sig_prod.C,
                product_M=eabc_mass(product),
                product_partition=",".join(str(value) for value in sig_prod.sorted_counts()),
                channel_a=eabc_channel_from_mod12(a).value,
                channel_b=eabc_channel_from_mod12(b).value,
                channel_c=eabc_channel_from_mod12(c).value,
                channel_e=eabc_channel_from_mod12(e).value,
                pair_gaps=pair_gaps((a, b, c, e)),
            )
        )
    return records


def export_pure_prime_quadruples_csv(
    output_path: str | Path,
    count: int = DEFAULT_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    records = first_pure_prime_quadruples(count)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for record in records:
            writer.writerow(record.as_csv_row())
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export pure prime quadruples (p, p+2, p+6, p+8) as CSV."
    )
    parser.add_argument(
        "--count",
        type=int,
        default=DEFAULT_COUNT,
        help=f"Number of rows to export (default: {DEFAULT_COUNT}).",
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=DEFAULT_OUT,
        help=f"Output CSV path (default: {DEFAULT_OUT}).",
    )
    args = parser.parse_args()

    path = export_pure_prime_quadruples_csv(args.output, args.count)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print(f"Wrote {path} ({row_count} data rows + header)")
    records = first_pure_prime_quadruples(min(3, args.count))
    if records:
        sample = records[0]
        print(
            f"First row: rank={sample.rank}, v=({sample.quat_a},{sample.quat_b},"
            f"{sample.quat_c},{sample.quat_e}), M(norm)={sample.M}, "
            f"M(product)={sample.product_M}"
        )


if __name__ == "__main__":
    main()
