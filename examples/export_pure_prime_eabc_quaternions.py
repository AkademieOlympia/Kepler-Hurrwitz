"""Export the first pure prime EABC quaternions with mass entry as CSV.

Definition (repo-conform, see docs/eabc_mass_convention.md and tests/test_signatures.py):
  A *pure prime EABC quaternion* is a rational prime p > 3 whose canonical signature
  H(p) = (E, A, B, C) from signature_from_nat activates exactly one EABC channel with
  weight 1, so M(p) = eabc_mass(p) = 1 (Arbeitsprogramm Phase 4, k=1 partition).

  Equivalently: p is an EABC-class prime (p mod 12 in {1, 5, 7, 11}), excluding the
  axis primes 2 and 3. Composites such as 2*p with M(p)=1 are excluded by the
  "rein prim" (prime norm) condition.

  Quaternion embedding: axis-aligned Primvierling (a, b, c, e) with the prime on the
  channel-aligned component (A=a, B=b, C=c, E=e), squared norm p^2.
"""

from __future__ import annotations

import argparse
import csv
import sys
from dataclasses import dataclass
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
DEFAULT_OUT = ROOT / "docs" / "energiedoku_exports" / "pure_prime_eabc_quaternions.csv"
DEFAULT_COUNT = 100
sys.path.insert(0, str(SRC))

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12  # noqa: E402
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel  # noqa: E402
from kepler_hurwitz.primvierling import is_prime  # noqa: E402
from kepler_hurwitz.signatures import eabc_mass, signature_from_nat  # noqa: E402

CSV_FIELDS = [
    "rank",
    "n",
    "E",
    "A",
    "B",
    "C",
    "M",
    "eabc_channel",
    "mod12",
    "partition",
    "quat_a",
    "quat_b",
    "quat_c",
    "quat_e",
    "quat_norm",
]


@dataclass(frozen=True)
class PurePrimeEABCRecord:
    rank: int
    n: int
    E: int
    A: int
    B: int
    C: int
    M: int
    eabc_channel: str
    mod12: int
    partition: str
    quat_a: int
    quat_b: int
    quat_c: int
    quat_e: int
    quat_norm: int

    def as_csv_row(self) -> dict[str, object]:
        return {
            "rank": self.rank,
            "n": self.n,
            "E": self.E,
            "A": self.A,
            "B": self.B,
            "C": self.C,
            "M": self.M,
            "eabc_channel": self.eabc_channel,
            "mod12": self.mod12,
            "partition": self.partition,
            "quat_a": self.quat_a,
            "quat_b": self.quat_b,
            "quat_c": self.quat_c,
            "quat_e": self.quat_e,
            "quat_norm": self.quat_norm,
        }


def is_pure_prime_eabc_quaternion(n: int) -> bool:
    """Return True when n is a prime p > 3 with M(n) = 1."""
    return n > 3 and is_prime(n) and eabc_mass(n) == 1


def axis_aligned_quaternion(p: int, channel: EABCChannel) -> tuple[int, int, int, int]:
    """Embed prime p on the channel axis in Primvierling coordinates (a, b, c, e)."""
    components = {EABCChannel.A: 0, EABCChannel.B: 0, EABCChannel.C: 0, EABCChannel.E: 0}
    components[channel] = p
    return (
        components[EABCChannel.A],
        components[EABCChannel.B],
        components[EABCChannel.C],
        components[EABCChannel.E],
    )


def first_pure_prime_eabc_quaternions(count: int) -> list[PurePrimeEABCRecord]:
    if count < 1:
        raise ValueError("count must be >= 1")

    records: list[PurePrimeEABCRecord] = []
    candidate = 5
    while len(records) < count:
        if is_pure_prime_eabc_quaternion(candidate):
            sig = signature_from_nat(candidate)
            channel = eabc_channel_from_mod12(candidate)
            partition = ",".join(str(value) for value in sig.sorted_counts())
            quat_a, quat_b, quat_c, quat_e = axis_aligned_quaternion(candidate, channel)
            records.append(
                PurePrimeEABCRecord(
                    rank=len(records) + 1,
                    n=candidate,
                    E=sig.E,
                    A=sig.A,
                    B=sig.B,
                    C=sig.C,
                    M=eabc_mass(candidate),
                    eabc_channel=channel.value,
                    mod12=candidate % 12,
                    partition=partition,
                    quat_a=quat_a,
                    quat_b=quat_b,
                    quat_c=quat_c,
                    quat_e=quat_e,
                    quat_norm=quat_a**2 + quat_b**2 + quat_c**2 + quat_e**2,
                )
            )
        candidate += 1
    return records


def export_pure_prime_eabc_quaternions_csv(
    output_path: str | Path,
    count: int = DEFAULT_COUNT,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    records = first_pure_prime_eabc_quaternions(count)
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=CSV_FIELDS)
        writer.writeheader()
        for record in records:
            writer.writerow(record.as_csv_row())
    return destination


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Export pure prime EABC quaternions (p > 3, M(p)=1) as CSV."
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

    path = export_pure_prime_eabc_quaternions_csv(args.output, args.count)
    with path.open(encoding="utf-8") as handle:
        row_count = sum(1 for _ in handle) - 1
    print(f"Wrote {path} ({row_count} data rows + header)")
    records = first_pure_prime_eabc_quaternions(min(5, args.count))
    if records:
        sample = records[0]
        print(
            f"First row: rank={sample.rank}, n={sample.n}, "
            f"H=({sample.E},{sample.A},{sample.B},{sample.C}), "
            f"M={sample.M}, channel={sample.eabc_channel}"
        )


if __name__ == "__main__":
    main()
