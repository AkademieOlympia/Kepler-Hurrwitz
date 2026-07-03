from __future__ import annotations

from dataclasses import dataclass

from kepler_hurwitz.octonionic_slice import is_admissible_interference
from kepler_hurwitz.smoothness_channel_scan import SmoothnessSample


def b11_channel(r: int) -> bool:
    return 0 <= r <= 11 and r % 2 == 1


def allowed_b11_residues() -> tuple[int, ...]:
    return (1, 3, 5, 7, 9, 11)


@dataclass(frozen=True)
class InterferenceBridgeStats:
    mu: float
    s: float
    is_interference_admissible: bool
    sample_count: int
    evaluated_count: int
    b11_hits: int
    b11_hit_rate: float
    residue_histogram: dict[int, int]


def evaluate_interference_b11_bridge(
    samples: list[SmoothnessSample],
    *,
    mu: float,
    s: float,
) -> InterferenceBridgeStats:
    """
    Empirical bridge check:
    Interference admissibility gates whether residue channels are evaluated.
    The residue channel is taken as `next_core mod 12`.
    """
    admissible = is_admissible_interference(mu, s)
    if not admissible:
        return InterferenceBridgeStats(
            mu=mu,
            s=s,
            is_interference_admissible=False,
            sample_count=len(samples),
            evaluated_count=0,
            b11_hits=0,
            b11_hit_rate=0.0,
            residue_histogram={},
        )

    residues = [sample.next_core % 12 for sample in samples]
    histogram: dict[int, int] = {}
    for residue in residues:
        histogram[residue] = histogram.get(residue, 0) + 1
    hits = sum(1 for residue in residues if b11_channel(residue))
    evaluated_count = len(residues)
    hit_rate = 0.0 if evaluated_count == 0 else hits / evaluated_count
    return InterferenceBridgeStats(
        mu=mu,
        s=s,
        is_interference_admissible=True,
        sample_count=len(samples),
        evaluated_count=evaluated_count,
        b11_hits=hits,
        b11_hit_rate=hit_rate,
        residue_histogram=histogram,
    )
