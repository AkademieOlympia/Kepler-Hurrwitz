from __future__ import annotations

from dataclasses import dataclass
from math import exp, log10, sqrt
from typing import Callable

from kepler_hurwitz.smoothness_channel_scan import SmoothnessSample


@dataclass(frozen=True)
class ChannelCount:
    channel: str
    b_smooth: int
    not_b_smooth: int
    total: int


@dataclass(frozen=True)
class ChiSquareResult:
    chi2: float
    p_value: float
    degrees_of_freedom: int
    sample_count: int
    cramers_v: float
    observed: list[ChannelCount]
    expected: dict[str, dict[str, float]]


@dataclass(frozen=True)
class ScaleStabilityPoint:
    limit_m: int
    sample_size: int
    chi2: float
    p_value: float
    cramers_v: float


@dataclass(frozen=True)
class BBoundScanResult:
    b_bound: int
    results: list[ScaleStabilityPoint]


@dataclass(frozen=True)
class BBoundTrend:
    b_bound: int
    v_start: float
    v_end: float
    v_delta: float
    v_ratio: float
    log10_p_start: float
    log10_p_end: float
    log10_p_delta: float
    stability_score: float


def channel_counts(samples: list[SmoothnessSample]) -> list[ChannelCount]:
    counts = {
        "klein": {"smooth": 0, "rough": 0},
        "mittel": {"smooth": 0, "rough": 0},
        "tief": {"smooth": 0, "rough": 0},
    }
    for sample in samples:
        bucket = counts[sample.channel]
        if sample.is_b_smooth:
            bucket["smooth"] += 1
        else:
            bucket["rough"] += 1

    return [
        ChannelCount(
            channel=channel,
            b_smooth=counts[channel]["smooth"],
            not_b_smooth=counts[channel]["rough"],
            total=counts[channel]["smooth"] + counts[channel]["rough"],
        )
        for channel in ("klein", "mittel", "tief")
    ]


def chi_square_smoothness_by_channel(samples: list[SmoothnessSample]) -> ChiSquareResult:
    observed = channel_counts(samples)
    n = sum(row.total for row in observed)
    if n == 0:
        raise ValueError("samples must not be empty")

    smooth_total = sum(row.b_smooth for row in observed)
    rough_total = sum(row.not_b_smooth for row in observed)
    if smooth_total == 0 or rough_total == 0:
        raise ValueError("both smooth and non-smooth classes must be present")

    expected: dict[str, dict[str, float]] = {}
    chi2 = 0.0
    for row in observed:
        expected_smooth = row.total * smooth_total / n
        expected_rough = row.total * rough_total / n
        expected[row.channel] = {
            "b_smooth": expected_smooth,
            "not_b_smooth": expected_rough,
        }
        chi2 += (row.b_smooth - expected_smooth) ** 2 / expected_smooth
        chi2 += (row.not_b_smooth - expected_rough) ** 2 / expected_rough

    # For a 3x2 table: dof = (3-1)*(2-1) = 2.
    dof = 2
    # For chi-square with dof=2, survival function is exp(-x/2).
    p_value = exp(-chi2 / 2)
    cramers_v = sqrt(chi2 / n)

    return ChiSquareResult(
        chi2=chi2,
        p_value=p_value,
        degrees_of_freedom=dof,
        sample_count=n,
        cramers_v=cramers_v,
        observed=observed,
        expected=expected,
    )


def chi_square_result_record(result: ChiSquareResult) -> dict[str, object]:
    return {
        "chi2": result.chi2,
        "p_value": result.p_value,
        "degrees_of_freedom": result.degrees_of_freedom,
        "sample_count": result.sample_count,
        "cramers_v": result.cramers_v,
        "observed": [
            {
                "channel": row.channel,
                "b_smooth": row.b_smooth,
                "not_b_smooth": row.not_b_smooth,
                "total": row.total,
            }
            for row in result.observed
        ],
        "expected": result.expected,
    }


def scan_scale_stability(
    *,
    b: int,
    limits: list[int],
    sample_provider: Callable[..., list[SmoothnessSample]] | None = None,
) -> list[ScaleStabilityPoint]:
    if not limits:
        raise ValueError("limits must not be empty")
    if any(limit < 1 for limit in limits):
        raise ValueError("all limits must be >= 1")

    if sample_provider is None:
        from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels

        provider = scan_smoothness_channels
    else:
        provider = sample_provider

    points: list[ScaleStabilityPoint] = []
    for limit in limits:
        samples = provider(limit_m=limit, b=b)
        result = chi_square_smoothness_by_channel(samples)
        points.append(
            ScaleStabilityPoint(
                limit_m=limit,
                sample_size=len(samples),
                chi2=result.chi2,
                p_value=result.p_value,
                cramers_v=result.cramers_v,
            )
        )
    return points


def scale_stability_records(points: list[ScaleStabilityPoint]) -> list[dict[str, object]]:
    return [
        {
            "limit_m": point.limit_m,
            "sample_size": point.sample_size,
            "chi2": point.chi2,
            "p_value": point.p_value,
            "cramers_v": point.cramers_v,
        }
        for point in points
    ]


def scan_b_bound_matrix(
    *,
    b_bounds: list[int],
    limits: list[int],
    sample_provider: Callable[..., list[SmoothnessSample]] | None = None,
) -> list[BBoundScanResult]:
    if not b_bounds:
        raise ValueError("b_bounds must not be empty")
    if any(b < 2 for b in b_bounds):
        raise ValueError("all b_bounds must be >= 2")

    return [
        BBoundScanResult(
            b_bound=b,
            results=scan_scale_stability(
                b=b,
                limits=limits,
                sample_provider=sample_provider,
            ),
        )
        for b in b_bounds
    ]


def b_bound_matrix_records(rows: list[BBoundScanResult]) -> list[dict[str, object]]:
    return [
        {
            "b_bound": row.b_bound,
            "results": scale_stability_records(row.results),
        }
        for row in rows
    ]


def b_bound_trends(rows: list[BBoundScanResult]) -> list[BBoundTrend]:
    trends: list[BBoundTrend] = []
    for row in rows:
        if len(row.results) < 2:
            raise ValueError("each b_bound row must contain at least two scale points")
        start = row.results[0]
        end = row.results[-1]
        if start.cramers_v <= 0:
            raise ValueError("v_start must be > 0 for stability ratio")
        if start.p_value <= 0 or end.p_value <= 0:
            raise ValueError("p-values must be > 0 for log10 trend")

        v_ratio = end.cramers_v / start.cramers_v
        log10_p_start = log10(start.p_value)
        log10_p_end = log10(end.p_value)
        trends.append(
            BBoundTrend(
                b_bound=row.b_bound,
                v_start=start.cramers_v,
                v_end=end.cramers_v,
                v_delta=end.cramers_v - start.cramers_v,
                v_ratio=v_ratio,
                log10_p_start=log10_p_start,
                log10_p_end=log10_p_end,
                log10_p_delta=log10_p_end - log10_p_start,
                stability_score=v_ratio * abs(log10_p_end),
            )
        )
    return trends


def b_bound_trend_records(trends: list[BBoundTrend]) -> list[dict[str, object]]:
    return [
        {
            "b_bound": trend.b_bound,
            "v_start": trend.v_start,
            "v_end": trend.v_end,
            "v_delta": trend.v_delta,
            "v_ratio": trend.v_ratio,
            "log10_p_start": trend.log10_p_start,
            "log10_p_end": trend.log10_p_end,
            "log10_p_delta": trend.log10_p_delta,
            "stability_score": trend.stability_score,
        }
        for trend in trends
    ]


def b_bound_summary(trends: list[BBoundTrend], rows: list[BBoundScanResult]) -> dict[str, int]:
    if not trends or not rows:
        raise ValueError("trends and rows must not be empty")
    most_stable = max(trends, key=lambda trend: trend.stability_score).b_bound
    max_effect = max(rows, key=lambda row: row.results[-1].cramers_v).b_bound
    return {
        "most_stable_b_bound": most_stable,
        "max_effect_size_scale_last": max_effect,
    }
