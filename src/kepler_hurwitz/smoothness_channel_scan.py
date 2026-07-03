from __future__ import annotations

from dataclasses import dataclass


def e_schalen_sprung(m: int) -> int:
    if m <= 0 or m % 2 == 0:
        raise ValueError("m must be a positive odd integer")
    n = 3 * m + 1
    power = 0
    while n % 2 == 0:
        power += 1
        n //= 2
    return power


def odd_core(n: int) -> int:
    if n <= 0:
        raise ValueError("n must be positive")
    while n % 2 == 0:
        n //= 2
    return n


def next_odd_core_after_kick(m: int) -> int:
    if m <= 0 or m % 2 == 0:
        raise ValueError("m must be a positive odd integer")
    return odd_core(3 * m + 1)


def prime_factors(n: int) -> list[int]:
    if n < 2:
        return []
    factors: list[int] = []
    while n % 2 == 0:
        factors.append(2)
        n //= 2
    p = 3
    while p * p <= n:
        while n % p == 0:
            factors.append(p)
            n //= p
        p += 2
    if n > 1:
        factors.append(n)
    return factors


def is_b_smooth(n: int, b: int) -> bool:
    if b < 2:
        raise ValueError("b must be >= 2")
    if n <= 1:
        return True
    return max(prime_factors(n)) <= b


def channel_label(delta_e: int) -> str:
    if delta_e == 1:
        return "klein"
    if delta_e == 2:
        return "mittel"
    return "tief"


@dataclass(frozen=True)
class SmoothnessSample:
    m: int
    mod8: int
    delta_e: int
    channel: str
    next_core: int
    b: int
    is_b_smooth: bool


def scan_smoothness_channels(limit_m: int, b: int) -> list[SmoothnessSample]:
    if limit_m < 1:
        raise ValueError("limit_m must be >= 1")
    samples: list[SmoothnessSample] = []
    for m in range(1, limit_m + 1, 2):
        delta = e_schalen_sprung(m)
        next_core = next_odd_core_after_kick(m)
        samples.append(
            SmoothnessSample(
                m=m,
                mod8=m % 8,
                delta_e=delta,
                channel=channel_label(delta),
                next_core=next_core,
                b=b,
                is_b_smooth=is_b_smooth(next_core, b),
            )
        )
    return samples


def summarize_scan(samples: list[SmoothnessSample]) -> dict[str, dict[str, int]]:
    summary: dict[str, dict[str, int]] = {
        "klein": {"total": 0, "b_smooth": 0},
        "mittel": {"total": 0, "b_smooth": 0},
        "tief": {"total": 0, "b_smooth": 0},
    }
    for sample in samples:
        bucket = summary[sample.channel]
        bucket["total"] += 1
        if sample.is_b_smooth:
            bucket["b_smooth"] += 1
    return summary
