from __future__ import annotations

from dataclasses import dataclass

from kepler_hurwitz.interference_attraktor_bridge import (
    b11_channel,
    evaluate_interference_b11_bridge,
)
from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels


@dataclass(frozen=True)
class InterferenceB11StudyResult:
    limit_m: int
    b_bound: int
    mu: float
    s: float
    is_interference_admissible: bool
    sample_count: int
    evaluated_count: int
    b11_hits: int
    b11_hit_rate: float
    violation_count: int
    violating_residues: tuple[int, ...]


def run_interference_b11_study(
    *,
    limit_m: int,
    b_bound: int,
    mu: float,
    s: float,
) -> InterferenceB11StudyResult:
    """
    Reproducible empirical check for E-003 under a fixed operational bridge:
    Interference point -> evaluated residue channels -> B11 corridor.
    """
    samples = scan_smoothness_channels(limit_m=limit_m, b=b_bound)
    stats = evaluate_interference_b11_bridge(samples, mu=mu, s=s)

    residues = [sample.next_core % 12 for sample in samples]
    violating_residues = tuple(sorted({res for res in residues if not b11_channel(res)}))
    violation_count = sum(1 for res in residues if not b11_channel(res))

    return InterferenceB11StudyResult(
        limit_m=limit_m,
        b_bound=b_bound,
        mu=mu,
        s=s,
        is_interference_admissible=stats.is_interference_admissible,
        sample_count=stats.sample_count,
        evaluated_count=stats.evaluated_count,
        b11_hits=stats.b11_hits,
        b11_hit_rate=stats.b11_hit_rate,
        violation_count=violation_count,
        violating_residues=violating_residues,
    )


def study_result_record(result: InterferenceB11StudyResult) -> dict[str, object]:
    return {
        "limit_m": result.limit_m,
        "b_bound": result.b_bound,
        "mu": result.mu,
        "s": result.s,
        "is_interference_admissible": result.is_interference_admissible,
        "sample_count": result.sample_count,
        "evaluated_count": result.evaluated_count,
        "b11_hits": result.b11_hits,
        "b11_hit_rate": result.b11_hit_rate,
        "violation_count": result.violation_count,
        "violating_residues": list(result.violating_residues),
    }
