"""
Tao-inspired Collatz diagnostics — Syracuse orbit, valuation profiles, first passage.

Governance [B] only:
- Does NOT prove Collatz.
- Does NOT formalize Tao's proof.
- Inspired by Tao (2019), arXiv:1909.03562, for numerical experiments.
- Link to Collatz V2.7: first passage ↔ witness descent; valuation profile ↔ BadRun/2-adic.

See docs/collatz_tao_diagnostics.md and docs/collatz_v2_evidence_chain.md (V2.7).
"""

from __future__ import annotations

import csv
import json
import math
import random
import time
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Mapping, Sequence

try:
    from sage.all import Integer as _Integer  # type: ignore[import-untyped]
except ImportError:
    _Integer = int

Integer = _Integer

TAO_COLLATZ_TAG = "[B]"

KLEIN_MOD8_CLASSES: tuple[int, ...] = (1, 3, 5, 7)

TAO_FIXED_FIRST_PASSAGE_THRESHOLDS: tuple[int, ...] = (10, 100, 1000, 10_000)

__all__ = [
    "TAO_COLLATZ_TAG",
    "KLEIN_MOD8_CLASSES",
    "TAO_FIXED_FIRST_PASSAGE_THRESHOLDS",
    "FirstPassageResult",
    "TaoFirstPassageExportRow",
    "TAO_FIRST_PASSAGE_CSV_FIELDS",
    "batch_first_passage_by_mod8",
    "batch_first_passage_experiment",
    "batch_fixed_threshold_first_passage_summaries",
    "discrete_log_odd_sample",
    "export_first_passage_csv",
    "export_first_passage_summary_json",
    "first_passage_syracuse",
    "Integer",
    "active_sample_count_by_position",
    "effective_profile_steps",
    "free_geom2_distance_excluding_position_0",
    "geom2_collective_profile_distance",
    "geom2_profile_distance",
    "export_mod8_geom2_summary_json",
    "export_mod8_stratified_summary_json",
    "lag1_autocorrelation",
    "log_uniform_odd_sample",
    "log_uniform_odd_sample_mod8",
    "pair_distribution_l1_deviation",
    "positional_geom2_distances",
    "relative_net_descent_threshold",
    "syracuse",
    "syracuse_orbit_min",
    "syracuse_valuation_profile",
    "syracuse_valuation_profile_censored",
    "v2",
]


def v2(n: int | _Integer) -> int:
    """
    2-adische Valuation ``v_2(n)``: größtes ``k >= 0`` mit ``2**k | n``.

    Uses ``(n & -n).bit_length() - 1`` on native ``int`` for speed; accepts
    Sage ``Integer`` when available (coerced via ``int(n)``).
    """
    n = int(n)
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 1:
        return 0
    return (n & -n).bit_length() - 1


def syracuse(n: int) -> int:
    """
    Syracuse (odd Collatz) step: ``S(n) = (3n+1) / 2^{v_2(3n+1)}`` for odd ``n > 0``.
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 0:
        raise ValueError("n must be odd for syracuse step")
    t = 3 * n + 1
    return t >> v2(t)


def effective_profile_steps(
    n: int,
    profile_steps: int,
    *,
    steps_cap_log_n: float | None = None,
    steps_cap_coefficient: float = 0.25,
) -> int:
    """
    Optional Tao-nearer profile length: ``min(profile_steps, max(1, int(c * log(n))))``.

    When ``steps_cap_log_n`` is ``None``, returns ``profile_steps`` unchanged.
    """
    if profile_steps < 0:
        raise ValueError("profile_steps must be >= 0")
    if n < 1:
        raise ValueError("n must be >= 1")
    if steps_cap_log_n is None:
        return profile_steps
    cap = max(1, int(steps_cap_coefficient * math.log(float(n))))
    return min(profile_steps, cap)


def syracuse_valuation_profile(
    n: int, steps: int, *, censor_at_one: bool = False
) -> list[int]:
    """
    Valuation profile ``a_j = v_2(3 * Syr^{j-1}(n) + 1)`` for ``j = 1..steps``.

    When ``censor_at_one=True``, stop once the Syracuse iterate reaches the fixed
    point ``1`` — do not collect the repeated ``v_2(4)=2`` tail after absorption.

    Requires odd positive ``n`` and ``steps >= 0``.
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 0:
        raise ValueError("n must be odd for syracuse valuation profile")
    if steps < 0:
        raise ValueError("steps must be >= 0")

    profile: list[int] = []
    current = n
    for _ in range(steps):
        if censor_at_one and current == 1:
            break
        t = 3 * current + 1
        profile.append(v2(t))
        current = t >> profile[-1]
        if censor_at_one and current == 1:
            break
    return profile


def syracuse_valuation_profile_censored(n: int, steps: int) -> list[int]:
    """Censored valuation profile: stop when Syracuse orbit hits fixed point ``1``."""
    return syracuse_valuation_profile(n, steps, censor_at_one=True)


def syracuse_orbit_min(n: int, max_steps: int) -> int:
    """Minimum odd Syracuse iterate within ``max_steps`` Syracuse steps (includes start)."""
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 0:
        raise ValueError("n must be odd for syracuse orbit")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")

    minimum = n
    current = n
    for _ in range(max_steps):
        current = syracuse(current)
        if current < minimum:
            minimum = current
    return minimum


@dataclass(frozen=True)
class FirstPassageResult:
    """First passage of Syracuse orbit to ``threshold`` (``n <= threshold``)."""

    hit: bool
    time: int | None
    location: int | None


def first_passage_syracuse(
    n: int, threshold: int, max_steps: int
) -> dict[str, bool | int | None]:
    """
    First passage of odd Syracuse orbit to ``threshold``.

    Returns ``{"hit": bool, "time": int|None, "location": int|None}`` where ``time``
    counts Syracuse steps (0 = start already at/below threshold).
    """
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 0:
        raise ValueError("n must be odd for syracuse first passage")
    if threshold < 1:
        raise ValueError("threshold must be >= 1")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")

    if n <= threshold:
        return {"hit": True, "time": 0, "location": n}

    current = n
    for step in range(1, max_steps + 1):
        current = syracuse(current)
        if current <= threshold:
            return {"hit": True, "time": step, "location": current}
    return {"hit": False, "time": None, "location": None}


def _geom2_pmf(k: int) -> float:
    if k < 1:
        return 0.0
    return 0.5**k


def _profile_counts(
    profile_or_counts: Sequence[int] | Mapping[int, int],
) -> dict[int, int]:
    counts: dict[int, int] = {}
    if isinstance(profile_or_counts, Mapping):
        for key, value in profile_or_counts.items():
            if key < 1:
                raise ValueError("valuation keys must be >= 1")
            if value < 0:
                raise ValueError("counts must be >= 0")
            counts[int(key)] = int(value)
    else:
        for value in profile_or_counts:
            if value < 1:
                raise ValueError("valuation samples must be >= 1")
            counts[int(value)] = counts.get(int(value), 0) + 1
    return counts


def active_sample_count_by_position(
    profiles: Sequence[Sequence[int]],
) -> dict[str, int]:
    """
    Count profiles that still contribute a valuation at each zero-based position ``j``.

    Decreases as censored orbits absorb at Syracuse fixed point ``1``.
    """
    if not profiles:
        return {}
    profile_len = max(len(profile) for profile in profiles)
    return {
        str(j): sum(1 for profile in profiles if j < len(profile))
        for j in range(profile_len)
    }


def free_geom2_distance_excluding_position_0(
    profiles: Sequence[Sequence[int]],
    *,
    max_k: int | None = None,
) -> float:
    """
    Tail-corrected Geom(2) TV on pooled valuations at positions ``1..`` only.

    Position ``0`` is the deterministic mod-8 channel signature ``a_1 = v_2(3n+1)``
    and is excluded from this **free** metric scope.
    """
    free_samples = [
        profile[j] for profile in profiles for j in range(1, len(profile))
    ]
    if not free_samples:
        return 2.0
    if max_k is None:
        max_k = max(free_samples)
    return geom2_profile_distance(free_samples, max_k=max_k)


def geom2_collective_profile_distance(
    profiles: Sequence[Sequence[int]],
    *,
    max_k: int | None = None,
) -> float:
    """
    Tail-corrected total-variation distance between a **pooled** valuation histogram
    and ``Geom(2)`` on ``{1,2,...}``.

    Aggregates all valuation samples from multiple profiles into one empirical PMF
    before comparing to the reference — suitable for mod-8 class summaries.
    """
    counts: dict[int, int] = {}
    for profile in profiles:
        for value in profile:
            if value < 1:
                raise ValueError("valuation samples must be >= 1")
            counts[int(value)] = counts.get(int(value), 0) + 1
    if max_k is None and counts:
        max_k = max(counts)
    return geom2_profile_distance(counts, max_k=max_k)


def geom2_profile_distance(
    profile_or_counts: Sequence[int] | Mapping[int, int],
    *,
    max_k: int | None = None,
) -> float:
    """
    Tail-corrected total-variation distance between an empirical valuation histogram
    and ``Geom(2)`` on ``{1,2,...}``.

    Uses ``tail_mass = 2**(-max_k)`` and
    ``delta_total = 0.5 * (sum(distances.values()) + tail_mass)``.

    Accepts either raw valuation samples (``Sequence[int]``) or count maps keyed by ``k >= 1``.
    """
    counts = _profile_counts(profile_or_counts)
    if not counts:
        return 2.0

    if max_k is None:
        max_k = max(counts)
    if max_k < 1:
        raise ValueError("max_k must be >= 1")

    total = float(sum(counts.values()))
    distances: dict[int, float] = {}
    for k in range(1, max_k + 1):
        empirical = counts.get(k, 0) / total
        distances[k] = abs(empirical - _geom2_pmf(k))
    tail_mass = 2.0 ** (-max_k)
    return 0.5 * (sum(distances.values()) + tail_mass)


def lag1_autocorrelation(values: Sequence[int | float]) -> float | None:
    """
    Sample lag-1 Pearson autocorrelation of ``values``.

    Returns ``None`` when ``len(values) < 2`` or variance is zero.
    """
    xs = [float(v) for v in values]
    n = len(xs)
    if n < 2:
        return None
    mean = sum(xs) / n
    centered = [x - mean for x in xs]
    variance = sum(c * c for c in centered) / n
    if variance == 0.0:
        return None
    covariance = sum(centered[i] * centered[i + 1] for i in range(n - 1)) / (n - 1)
    return covariance / variance


def positional_geom2_distances(
    profiles: Sequence[Sequence[int]],
    max_k: int | None = None,
) -> dict[int, float]:
    """
    Tail-corrected Geom(2) TV distance ``Delta_j`` at each profile step index ``j``.

    Keys are zero-based step indices; only positions with at least one sample are included.
    """
    if not profiles:
        return {}
    profile_len = max(len(profile) for profile in profiles)
    if max_k is None:
        max_k = max(max(profile) if profile else 1 for profile in profiles)
    distances: dict[int, float] = {}
    for j in range(profile_len):
        column = [profile[j] for profile in profiles if j < len(profile)]
        if column:
            distances[j] = geom2_profile_distance(column, max_k=max_k)
    return distances


def pair_distribution_l1_deviation(profiles: Sequence[Sequence[int]]) -> float:
    """
    Simple pair-distribution diagnostic: L1 deviation of empirical ``(a_j, a_{j+1})``
    counts from the product of pooled marginals (independence null).

    Does **not** establish IID Geom(2); aggregated marginal scope only.
    """
    pair_counts: dict[tuple[int, int], int] = {}
    left_counts: dict[int, int] = {}
    right_counts: dict[int, int] = {}
    total_pairs = 0
    for profile in profiles:
        for left, right in zip(profile, profile[1:]):
            if left < 1 or right < 1:
                raise ValueError("valuation samples must be >= 1")
            key = (int(left), int(right))
            pair_counts[key] = pair_counts.get(key, 0) + 1
            left_counts[int(left)] = left_counts.get(int(left), 0) + 1
            right_counts[int(right)] = right_counts.get(int(right), 0) + 1
            total_pairs += 1
    if total_pairs == 0:
        return 0.0
    deviation = 0.0
    for (left, right), count in pair_counts.items():
        empirical = count / total_pairs
        independent = (
            left_counts[left] / total_pairs
        ) * (right_counts[right] / total_pairs)
        deviation += abs(empirical - independent)
    return deviation


def relative_net_descent_threshold(n: int) -> int:
    """Relative net-descent first-passage threshold ``floor(N/2)`` for odd start ``N``."""
    if n < 1:
        raise ValueError("n must be >= 1")
    return n // 2


def log_uniform_odd_sample(limit: int, *, rng: random.Random | None = None) -> int:
    """
    Draw one odd integer from ``[3, limit]`` via **continuous log-scale approximation**.

    Uses ``exp(U(log 3, log limit))`` rounded to the nearest odd integer — this is **not**
    exact discrete log density ``P(n) ∝ 1/n`` on odd integers. See ``discrete_log_odd_sample``.
    """
    if limit < 3:
        raise ValueError("limit must be >= 3 for log-uniform odd sampling")
    gen = rng or random
    log_lo = math.log(3.0)
    log_hi = math.log(float(limit))
    raw = int(round(math.exp(gen.uniform(log_lo, log_hi))))
    raw = max(3, min(raw, limit))
    if raw % 2 == 0:
        raw = raw + 1 if raw < limit else raw - 1
    if raw < 3:
        raw = 3
    return raw


def discrete_log_odd_sample(limit: int, *, rng: random.Random | None = None) -> int:
    """
    Draw one odd integer from ``[3, limit]`` with exact discrete weight proportional to ``1/n``.

    Intended for moderate ``limit`` (builds a cumulative table over odd integers).
    """
    if limit < 3:
        raise ValueError("limit must be >= 3 for discrete log odd sampling")
    gen = rng or random
    odds = list(range(3, limit + 1, 2))
    weights = [1.0 / float(n) for n in odds]
    total = sum(weights)
    target = gen.random() * total
    cumulative = 0.0
    for n, weight in zip(odds, weights):
        cumulative += weight
        if target <= cumulative:
            return n
    return odds[-1]


def log_uniform_odd_sample_mod8(
    limit: int, residue: int, *, rng: random.Random | None = None
) -> int:
    """
    Draw one odd integer ``n`` with ``n % 8 == residue`` from ``[3, limit]``.

    Uses continuous log-scale approximation on the arithmetic progression ``8k + residue``.
    """
    if limit < 3:
        raise ValueError("limit must be >= 3 for log-uniform odd sampling")
    if residue not in KLEIN_MOD8_CLASSES:
        raise ValueError("residue must be one of 1, 3, 5, 7")

    k_min = max(0, (3 - residue + 7) // 8)
    k_max = (limit - residue) // 8
    if k_min > k_max:
        raise ValueError(f"no odd n with n % 8 == {residue} in [3, {limit}]")

    n_min = 8 * k_min + residue
    n_max = 8 * k_max + residue
    gen = rng or random
    log_lo = math.log(float(n_min))
    log_hi = math.log(float(n_max))
    raw = int(round(math.exp(gen.uniform(log_lo, log_hi))))
    raw = max(n_min, min(raw, n_max))
    k = (raw - residue) // 8
    k = max(k_min, min(k, k_max))
    return 8 * k + residue


@dataclass(frozen=True)
class TaoFirstPassageExportRow:
    n: int
    hit: bool
    time: int | None
    location: int | None
    orbit_min: int
    profile_steps: int
    geom2_distance: float
    threshold: int
    max_steps: int


TAO_FIRST_PASSAGE_CSV_FIELDS: tuple[str, ...] = (
    "n",
    "hit",
    "time",
    "location",
    "orbit_min",
    "profile_steps",
    "geom2_distance",
    "threshold",
    "max_steps",
)


def _valuation_profile_metrics(
    profiles: Sequence[Sequence[int]],
) -> dict[str, object]:
    max_k = max(max(profile) if profile else 1 for profile in profiles) if profiles else 1
    geom2_distances = [
        geom2_profile_distance(profile, max_k=max_k) for profile in profiles
    ]
    lag1_values = [
        value
        for profile in profiles
        if (value := lag1_autocorrelation(profile)) is not None
    ]
    positional = positional_geom2_distances(profiles, max_k=max_k)
    delta_start = positional.get(0)
    delta_free = free_geom2_distance_excluding_position_0(profiles, max_k=max_k)
    return {
        "max_k": max_k,
        "geom2_distances": geom2_distances,
        "collective_geom2_distance": geom2_collective_profile_distance(
            profiles, max_k=max_k
        ),
        "free_geom2_distance_excluding_position_0": delta_free,
        "geom2_delta_start": delta_start,
        "geom2_delta_free": delta_free,
        "active_sample_count_by_position": active_sample_count_by_position(profiles),
        "tail_corrected_tv_mean": (
            sum(geom2_distances) / len(geom2_distances) if geom2_distances else None
        ),
        "tail_corrected_tv_min": min(geom2_distances) if geom2_distances else None,
        "tail_corrected_tv_max": max(geom2_distances) if geom2_distances else None,
        "lag1_autocorr_mean": (
            sum(lag1_values) / len(lag1_values) if lag1_values else None
        ),
        "positional_geom2": {str(j): distance for j, distance in positional.items()},
        "pair_distribution_l1_deviation": pair_distribution_l1_deviation(profiles),
    }


def _geom2_interpretation_fields() -> dict[str, object]:
    return {
        "position_0_interpretation": "deterministic mod-8 channel signature",
        "position_0_scope": (
            "deterministic mod-8 channel signature, excluded from free Geom(2) metric"
        ),
        "geom2_free_metric_scope": "positions after 0 and before hitting 1",
        "excluded_from_geom2_free_metric": [
            "position_0",
            "post_absorption_values_after_S(n)=1",
        ],
        "collective_geom2_scope_note": (
            "collective_geom2_distance pools all positions and mixes start signature, "
            "free tail, and late absorption artifacts"
        ),
    }


def _governance_summary_fields(
    *,
    first_passage_threshold: str,
) -> dict[str, str]:
    return {
        "tag": TAO_COLLATZ_TAG,
        "status": "[B] numerical diagnostic",
        "claim": (
            "Syracuse valuation and first-passage diagnostic only; no Collatz proof"
        ),
        "sampling": "continuous log-scale approximation over odd integers",
        "first_passage_threshold": first_passage_threshold,
        "geom2_metric_scope": (
            "aggregated marginal distribution only; iid independence not tested"
        ),
    }


def batch_first_passage_experiment(
    limit: int,
    threshold: int | str,
    samples: int,
    seed: int,
    *,
    max_steps: int = 10_000,
    profile_steps: int = 64,
) -> dict[str, object]:
    """
    Log-uniform odd sample experiment for Syracuse first-passage statistics.

    ``threshold`` may be a fixed integer or ``"relative"`` for net-descent
    ``floor(N/2)`` per sample.

    Returns rows plus aggregate summary suitable for JSON export.
    """
    if limit < 3:
        raise ValueError("limit must be >= 3")
    if isinstance(threshold, str):
        if threshold != "relative":
            raise ValueError('threshold must be an int >= 1 or "relative"')
    elif threshold < 1:
        raise ValueError("threshold must be >= 1")
    if samples < 1:
        raise ValueError("samples must be >= 1")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")
    if profile_steps < 0:
        raise ValueError("profile_steps must be >= 0")

    use_relative = threshold == "relative"
    rng = random.Random(seed)
    rows: list[TaoFirstPassageExportRow] = []
    hit_times: list[int] = []
    profiles: list[list[int]] = []

    for _ in range(samples):
        n = log_uniform_odd_sample(limit, rng=rng)
        sample_threshold = relative_net_descent_threshold(n) if use_relative else int(threshold)
        passage = first_passage_syracuse(n, sample_threshold, max_steps)
        profile = syracuse_valuation_profile(n, profile_steps)
        profiles.append(profile)
        row = TaoFirstPassageExportRow(
            n=n,
            hit=bool(passage["hit"]),
            time=passage["time"] if passage["time"] is None else int(passage["time"]),
            location=(
                passage["location"]
                if passage["location"] is None
                else int(passage["location"])
            ),
            orbit_min=syracuse_orbit_min(n, max_steps),
            profile_steps=profile_steps,
            geom2_distance=geom2_profile_distance(profile),
            threshold=sample_threshold,
            max_steps=max_steps,
        )
        rows.append(row)
        if row.hit and row.time is not None:
            hit_times.append(row.time)

    profile_metrics = _valuation_profile_metrics(profiles)
    geom2_distances = profile_metrics["geom2_distances"]
    assert isinstance(geom2_distances, list)

    hits = sum(1 for row in rows if row.hit)
    threshold_label = (
        "relative threshold floor(N/2), not Tao fixed-x first passage"
        if use_relative
        else f"Tao-style fixed-x first passage at x={threshold}"
    )
    summary: dict[str, object] = {
        **_governance_summary_fields(first_passage_threshold=threshold_label),
        "limit": limit,
        "threshold_mode": "relative" if use_relative else "fixed",
        "threshold": None if use_relative else threshold,
        "samples": samples,
        "seed": seed,
        "max_steps": max_steps,
        "profile_steps": profile_steps,
        "hit_rate": hits / samples,
        "hits": hits,
        "misses": samples - hits,
        "mean_passage_time": (
            sum(hit_times) / len(hit_times) if hit_times else None
        ),
        "median_passage_time": (
            sorted(hit_times)[len(hit_times) // 2] if hit_times else None
        ),
        "mean_geom2_distance": sum(geom2_distances) / len(geom2_distances),
        "min_geom2_distance": min(geom2_distances),
        "max_geom2_distance": max(geom2_distances),
        "tail_corrected_tv_mean": profile_metrics["tail_corrected_tv_mean"],
        "tail_corrected_tv_min": profile_metrics["tail_corrected_tv_min"],
        "tail_corrected_tv_max": profile_metrics["tail_corrected_tv_max"],
        "collective_geom2_distance": profile_metrics["collective_geom2_distance"],
        "lag1_autocorr_mean": profile_metrics["lag1_autocorr_mean"],
        "positional_geom2": profile_metrics["positional_geom2"],
        "pair_distribution_l1_deviation": profile_metrics["pair_distribution_l1_deviation"],
    }
    return {"rows": rows, "summary": summary, "profiles": profiles}


def batch_fixed_threshold_first_passage_summaries(
    limit: int,
    thresholds: Sequence[int],
    samples: int,
    seed: int,
    *,
    max_steps: int = 10_000,
    profile_steps: int = 64,
) -> dict[str, object]:
    """
    Fixed Tao-style first-passage summaries at several thresholds (e.g. 10, 100, 1000, 10000).

    Each entry is labeled as Tao-style fixed-x first passage — distinct from relative
    ``floor(N/2)`` net-descent diagnostics.
    """
    by_threshold: dict[str, dict[str, object]] = {}
    for index, threshold in enumerate(thresholds):
        if threshold < 1:
            raise ValueError("each threshold must be >= 1")
        experiment = batch_first_passage_experiment(
            limit,
            threshold,
            samples,
            seed + index,
            max_steps=max_steps,
            profile_steps=profile_steps,
        )
        summary = experiment["summary"]
        assert isinstance(summary, dict)
        by_threshold[str(threshold)] = {
            "threshold_type": "Tao-style fixed-x first passage",
            "threshold": threshold,
            **summary,
        }
    return {
        **_governance_summary_fields(
            first_passage_threshold=(
                "companion batch: Tao-style fixed-x thresholds "
                f"{list(thresholds)}; primary export uses relative floor(N/2)"
            )
        ),
        "limit": limit,
        "samples": samples,
        "seed": seed,
        "max_steps": max_steps,
        "profile_steps": profile_steps,
        "tao_fixed_thresholds": by_threshold,
    }


def _first_passage_class_summary(
    rows: Sequence[TaoFirstPassageExportRow],
    *,
    residue: int,
    limit: int,
    threshold: int | str,
    samples: int,
    seed: int,
    max_steps: int,
    profile_steps: int,
    profiles: Sequence[Sequence[int]] | None = None,
) -> dict[str, Any]:
    hit_times = [row.time for row in rows if row.hit and row.time is not None]
    geom2_distances = [row.geom2_distance for row in rows]
    hits = sum(1 for row in rows if row.hit)
    summary: dict[str, Any] = {
        "mod8": residue,
        "limit": limit,
        "threshold_mode": "relative" if threshold == "relative" else "fixed",
        "threshold": None if threshold == "relative" else threshold,
        "samples": samples,
        "seed": seed,
        "max_steps": max_steps,
        "profile_steps": profile_steps,
        "hit_rate": hits / samples,
        "hits": hits,
        "misses": samples - hits,
        "mean_passage_time": (
            sum(hit_times) / len(hit_times) if hit_times else None
        ),
        "median_passage_time": (
            sorted(hit_times)[len(hit_times) // 2] if hit_times else None
        ),
        "mean_geom2_distance": sum(geom2_distances) / len(geom2_distances),
        "min_geom2_distance": min(geom2_distances),
        "max_geom2_distance": max(geom2_distances),
    }
    if profiles is not None:
        metrics = _valuation_profile_metrics(profiles)
        summary["collective_geom2_distance"] = metrics["collective_geom2_distance"]
        summary["collective_valuation_samples"] = sum(len(p) for p in profiles)
        summary["free_geom2_distance_excluding_position_0"] = metrics[
            "free_geom2_distance_excluding_position_0"
        ]
        summary["geom2_delta_start"] = metrics["geom2_delta_start"]
        summary["geom2_delta_free"] = metrics["geom2_delta_free"]
        summary["active_sample_count_by_position"] = metrics[
            "active_sample_count_by_position"
        ]
        summary["tail_corrected_tv_mean"] = metrics["tail_corrected_tv_mean"]
        summary["tail_corrected_tv_min"] = metrics["tail_corrected_tv_min"]
        summary["tail_corrected_tv_max"] = metrics["tail_corrected_tv_max"]
        summary["lag1_autocorr_mean"] = metrics["lag1_autocorr_mean"]
        summary["positional_geom2"] = metrics["positional_geom2"]
        summary["pair_distribution_l1_deviation"] = metrics[
            "pair_distribution_l1_deviation"
        ]
        summary.update(_geom2_interpretation_fields())
    return summary


def batch_first_passage_by_mod8(
    limit: int,
    threshold: int | str,
    samples: int,
    seed: int,
    *,
    max_steps: int = 10_000,
    profile_steps: int = 64,
    censor_at_one: bool = True,
    steps_cap_log_n: float | None = None,
    steps_cap_coefficient: float = 0.25,
) -> dict[str, object]:
    """
    Log-uniform Syracuse first-passage experiment stratified by Klein mod-8 classes.

    ``threshold`` may be a fixed integer or ``"relative"`` for ``floor(N/2)`` per sample.

    Returns per-class summaries for residues ``1, 3, 5, 7`` plus aggregate metadata.
    """
    if limit < 3:
        raise ValueError("limit must be >= 3")
    if isinstance(threshold, str):
        if threshold != "relative":
            raise ValueError('threshold must be an int >= 1 or "relative"')
    elif threshold < 1:
        raise ValueError("threshold must be >= 1")
    if samples < 1:
        raise ValueError("samples must be >= 1")
    if max_steps < 0:
        raise ValueError("max_steps must be >= 0")
    if profile_steps < 0:
        raise ValueError("profile_steps must be >= 0")

    use_relative = threshold == "relative"
    threshold_label = (
        "relative threshold floor(N/2), not Tao fixed-x first passage"
        if use_relative
        else f"Tao-style fixed-x first passage at x={threshold}"
    )
    rng = random.Random(seed)
    by_class: dict[int, dict[str, object]] = {}
    all_rows: list[TaoFirstPassageExportRow] = []

    for residue in KLEIN_MOD8_CLASSES:
        class_rng = random.Random(rng.randint(0, 2**31 - 1))
        rows: list[TaoFirstPassageExportRow] = []
        class_profiles: list[list[int]] = []
        for _ in range(samples):
            n = log_uniform_odd_sample_mod8(limit, residue, rng=class_rng)
            sample_threshold = (
                relative_net_descent_threshold(n) if use_relative else int(threshold)
            )
            passage = first_passage_syracuse(n, sample_threshold, max_steps)
            steps = effective_profile_steps(
                n,
                profile_steps,
                steps_cap_log_n=steps_cap_log_n,
                steps_cap_coefficient=steps_cap_coefficient,
            )
            profile = syracuse_valuation_profile(
                n, steps, censor_at_one=censor_at_one
            )
            class_profiles.append(profile)
            row = TaoFirstPassageExportRow(
                n=n,
                hit=bool(passage["hit"]),
                time=passage["time"] if passage["time"] is None else int(passage["time"]),
                location=(
                    passage["location"]
                    if passage["location"] is None
                    else int(passage["location"])
                ),
                orbit_min=syracuse_orbit_min(n, max_steps),
                profile_steps=profile_steps,
                geom2_distance=geom2_profile_distance(profile),
                threshold=sample_threshold,
                max_steps=max_steps,
            )
            rows.append(row)
        all_rows.extend(rows)
        by_class[residue] = _first_passage_class_summary(
            rows,
            residue=residue,
            limit=limit,
            threshold=threshold,
            samples=samples,
            seed=seed,
            max_steps=max_steps,
            profile_steps=profile_steps,
            profiles=class_profiles,
        )

    return {
        **_governance_summary_fields(first_passage_threshold=threshold_label),
        **_geom2_interpretation_fields(),
        "limit": limit,
        "threshold_mode": "relative" if use_relative else "fixed",
        "threshold": None if use_relative else threshold,
        "samples_per_class": samples,
        "seed": seed,
        "max_steps": max_steps,
        "profile_steps": profile_steps,
        "censor_at_one": censor_at_one,
        "steps_cap_log_n": steps_cap_log_n,
        "steps_cap_coefficient": steps_cap_coefficient,
        "classes": by_class,
        "rows": all_rows,
    }


def export_first_passage_csv(
    rows: Sequence[TaoFirstPassageExportRow], path: Path
) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=TAO_FIRST_PASSAGE_CSV_FIELDS)
        writer.writeheader()
        for row in rows:
            writer.writerow(
                {
                    "n": row.n,
                    "hit": row.hit,
                    "time": "" if row.time is None else row.time,
                    "location": "" if row.location is None else row.location,
                    "orbit_min": row.orbit_min,
                    "profile_steps": row.profile_steps,
                    "geom2_distance": f"{row.geom2_distance:.6f}",
                    "threshold": row.threshold,
                    "max_steps": row.max_steps,
                }
            )
    return path


def export_first_passage_summary_json(
    summary: Mapping[str, object], path: Path, *, elapsed_seconds: float
) -> Path:
    payload = dict(summary)
    payload["elapsed_seconds"] = elapsed_seconds
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def export_mod8_stratified_summary_json(
    mod8_result: Mapping[str, object], path: Path, *, elapsed_seconds: float
) -> Path:
    """Export mod-8 stratified first-passage summary (Governance [B], no row payload)."""
    payload: dict[str, Any] = {
        "tag": mod8_result.get("tag", TAO_COLLATZ_TAG),
        "status": mod8_result.get("status", "B"),
        "claim": mod8_result.get("claim"),
        "limit": mod8_result.get("limit"),
        "threshold": mod8_result.get("threshold"),
        "samples_per_class": mod8_result.get("samples_per_class"),
        "seed": mod8_result.get("seed"),
        "max_steps": mod8_result.get("max_steps"),
        "profile_steps": mod8_result.get("profile_steps"),
        "classes": mod8_result.get("classes"),
        "elapsed_seconds": elapsed_seconds,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path


def export_mod8_geom2_summary_json(
    mod8_result: Mapping[str, object], path: Path, *, elapsed_seconds: float
) -> Path:
    """Export pooled tail-corrected Geom(2) TV distances per mod-8 class (Governance [B])."""
    classes = mod8_result.get("classes", {})
    by_mod8: dict[str, Any] = {}
    if isinstance(classes, Mapping):
        for residue, summary in classes.items():
            if isinstance(summary, Mapping):
                by_mod8[str(residue)] = {
                    "mod8": summary.get("mod8", residue),
                    "collective_geom2_distance": summary.get("collective_geom2_distance"),
                    "free_geom2_distance_excluding_position_0": summary.get(
                        "free_geom2_distance_excluding_position_0"
                    ),
                    "geom2_delta_start": summary.get("geom2_delta_start"),
                    "geom2_delta_free": summary.get("geom2_delta_free"),
                    "collective_valuation_samples": summary.get(
                        "collective_valuation_samples"
                    ),
                    "active_sample_count_by_position": summary.get(
                        "active_sample_count_by_position"
                    ),
                    "mean_geom2_distance": summary.get("mean_geom2_distance"),
                    "min_geom2_distance": summary.get("min_geom2_distance"),
                    "max_geom2_distance": summary.get("max_geom2_distance"),
                    "tail_corrected_tv_mean": summary.get("tail_corrected_tv_mean"),
                    "tail_corrected_tv_min": summary.get("tail_corrected_tv_min"),
                    "tail_corrected_tv_max": summary.get("tail_corrected_tv_max"),
                    "lag1_autocorr_mean": summary.get("lag1_autocorr_mean"),
                    "positional_geom2": summary.get("positional_geom2"),
                    "pair_distribution_l1_deviation": summary.get(
                        "pair_distribution_l1_deviation"
                    ),
                }
    payload: dict[str, Any] = {
        "tag": mod8_result.get("tag", TAO_COLLATZ_TAG),
        "status": mod8_result.get("status", "[B] numerical diagnostic"),
        "claim": mod8_result.get(
            "claim",
            "Syracuse valuation and first-passage diagnostic only; no Collatz proof",
        ),
        "sampling": mod8_result.get(
            "sampling", "continuous log-scale approximation over odd integers"
        ),
        "first_passage_threshold": mod8_result.get("first_passage_threshold"),
        "geom2_metric_scope": mod8_result.get(
            "geom2_metric_scope",
            "aggregated marginal distribution only; iid independence not tested",
        ),
        "position_0_interpretation": mod8_result.get(
            "position_0_interpretation",
            "deterministic mod-8 channel signature",
        ),
        "position_0_scope": mod8_result.get(
            "position_0_scope",
            (
                "deterministic mod-8 channel signature, "
                "excluded from free Geom(2) metric"
            ),
        ),
        "geom2_free_metric_scope": mod8_result.get(
            "geom2_free_metric_scope",
            "positions after 0 and before hitting 1",
        ),
        "excluded_from_geom2_free_metric": mod8_result.get(
            "excluded_from_geom2_free_metric",
            ["position_0", "post_absorption_values_after_S(n)=1"],
        ),
        "collective_geom2_scope_note": mod8_result.get(
            "collective_geom2_scope_note",
            (
                "collective_geom2_distance pools all positions and mixes start "
                "signature, free tail, and late absorption artifacts"
            ),
        ),
        "limit": mod8_result.get("limit"),
        "samples_per_class": mod8_result.get("samples_per_class"),
        "seed": mod8_result.get("seed"),
        "profile_steps": mod8_result.get("profile_steps"),
        "censor_at_one": mod8_result.get("censor_at_one", True),
        "steps_cap_log_n": mod8_result.get("steps_cap_log_n"),
        "steps_cap_coefficient": mod8_result.get("steps_cap_coefficient"),
        "by_mod8": by_mod8,
        "elapsed_seconds": elapsed_seconds,
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path
