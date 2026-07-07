"""
Black Hole / GWTC Legendre mass-gap diagnostics — E-093 hypothesis scaffold [C].

Maps continuous compact-binary masses (M_sun) into discrete EABC quaternion norms via a
quantization scale kappa, classifies 1G vs. 2G candidates by effective precession spin
chi_p, and tests whether 1G systems avoid Legendre-forbidden integer mass shells more
often than 2G merger candidates (Fisher exact test or Monte Carlo P_gap permutation).

Governance: [C] — descriptive / hypothesis-generating only; no GW or EABC physics claim.
Legendre algebra [A/B] unchanged; MC error propagation is heuristic [C] only.
See docs/black_hole_hypothese.md and docs/theory/black_hole_legendre_gwtc_bridge.md (E-093).
"""

from __future__ import annotations

import csv
import json
import math
import random
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Sequence

BLACK_HOLE_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C empirical hypothesis scaffold",
    "not_claimed": (
        "EABC quaternion norms identify gravitational-wave masses; "
        "Legendre gaps prove 1G/2G formation channels; "
        "kappa optimization without preregistration constitutes discovery claim; "
        "mock GWTC-5 catalog substitutes for LIGO/Virgo inference products"
    ),
    "primary_question": (
        "Do low-precession (1G) candidates avoid Legendre-forbidden quantized masses "
        "more often than high-precession (2G) merger candidates at a preregistered kappa?"
    ),
    "inherits_from": "E-076,GodelKerr",
}

DEFAULT_CHI_P_1G_THRESHOLD = 0.2
DEFAULT_TOLERANCE = 0.5
DEFAULT_MAX_NORM = 500
DEFAULT_MC_SAMPLES = 10_000
NINETY_PCT_Z = 1.645  # 90% CI half-width for GWOSC asymmetric errors

__all__ = [
    "BLACK_HOLE_TAG",
    "DEFAULT_CHI_P_1G_THRESHOLD",
    "DEFAULT_MAX_NORM",
    "DEFAULT_MC_SAMPLES",
    "DEFAULT_TOLERANCE",
    "NINETY_PCT_Z",
    "GOVERNANCE",
    "BlackHoleAnalysis",
    "ContingencyTable",
    "FisherResult",
    "GwtcEvent",
    "KappaSweepPoint",
    "build_black_hole_analysis",
    "export_black_hole_bundle",
    "fisher_exact",
    "get_forbidden_mass_integers",
    "is_forbidden_by_legendre",
    "PermutationMcResult",
    "PermutationNullResult",
    "calculate_pgap_monte_carlo",
    "compute_pgap_table",
    "generate_split_normal_samples",
    "load_gwtc_catalog",
    "load_gwtc_csv",
    "load_official_gwtc_catalog",
    "mock_gwtc5_events",
    "permutation_null_model",
    "permutation_null_model_mc",
    "permutation_test_mc",
    "primes_up_to",
    "run_eabc_statistical_test",
    "sweep_kappa",
]


def is_forbidden_by_legendre(n: int) -> bool:
    """True iff n has the form 4^a * (8b + 7) with a, b >= 0 (three-squares obstruction)."""
    if n < 0:
        return False
    while n % 4 == 0 and n > 0:
        n //= 4
    return n % 8 == 7


def primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if sieve[i]:
            step = i
            start = i * i
            sieve[start : limit + 1 : step] = [False] * len(range(start, limit + 1, step))
    return [i for i in range(2, limit + 1) if sieve[i]]


def get_forbidden_mass_integers(max_norm: int = DEFAULT_MAX_NORM) -> list[int]:
    """
    Integer mass shells m such that some prime norm p admits s^2 = p - m^2 with
    s^2 forbidden by Legendre's three-squares criterion.
    """
    forbidden: set[int] = set()
    for p in primes_up_to(max_norm):
        root = math.isqrt(p)
        for m in range(root + 1):
            s_squared = p - m * m
            if s_squared >= 0 and is_forbidden_by_legendre(s_squared):
                forbidden.add(m)
    return sorted(forbidden)


@dataclass(frozen=True)
class GwtcEvent:
    m1_solar: float
    m2_solar: float
    chi_p: float
    event_id: str = ""
    m1_source_lower: float | None = None
    m1_source_upper: float | None = None

    @property
    def primary_mass(self) -> float:
        return max(self.m1_solar, self.m2_solar)


@dataclass(frozen=True)
class ContingencyTable:
    in_forbidden_1g: int
    out_forbidden_1g: int
    in_forbidden_2g: int
    out_forbidden_2g: int

    def as_matrix(self) -> list[list[int]]:
        return [
            [self.in_forbidden_1g, self.out_forbidden_1g],
            [self.in_forbidden_2g, self.out_forbidden_2g],
        ]


@dataclass(frozen=True)
class FisherResult:
    table: ContingencyTable
    odds_ratio: float | None
    p_value: float
    alternative: str = "less"


@dataclass(frozen=True)
class KappaSweepPoint:
    kappa: float
    p_value: float
    odds_ratio: float | None
    table: ContingencyTable


@dataclass(frozen=True)
class PermutationNullResult:
    p_value: float
    obs_1g_in_gap: int
    iterations: int
    null_mean: float
    null_std: float
    null_min: int
    null_max: int


@dataclass(frozen=True)
class PermutationMcResult:
    """Monte Carlo permutation null: metric is sum of P_gap over 1G candidates."""

    p_value: float
    obs_1g_expected_hits: float
    iterations: int
    null_mean: float
    null_std: float
    null_min: float
    null_max: float
    n_mc_samples: int
    per_event_p_gaps: tuple[float, ...] = ()


@dataclass
class BlackHoleAnalysis:
    events: list[GwtcEvent]
    forbidden_m: list[int]
    kappa: float
    tolerance: float
    chi_p_threshold: float
    fisher: FisherResult
    kappa_sweep: list[KappaSweepPoint] = field(default_factory=list)
    permutation_null: PermutationNullResult | None = None
    permutation_null_mc: PermutationMcResult | None = None
    use_monte_carlo: bool = False
    governance: dict[str, str] = field(default_factory=lambda: dict(GOVERNANCE))
    tag: str = BLACK_HOLE_TAG


def _table_probability(a11: int, row1: int, row2: int, col1: int) -> float:
    n = row1 + row2
    a12 = row1 - a11
    a21 = col1 - a11
    a22 = n - row1 - col1 + a11
    if min(a11, a12, a21, a22) < 0:
        return 0.0
    return math.comb(row1, a11) * math.comb(row2, a21) / math.comb(n, col1)


def fisher_exact(
    table: Sequence[Sequence[int]],
    *,
    alternative: str = "less",
) -> tuple[float | None, float]:
    """
    Two-sided / one-sided Fisher exact test for a 2x2 contingency table.

    alternative='less': test whether the odds ratio is less than 1 (1G avoids forbidden zone).
    """
    a, b = table[0]
    c, d = table[1]
    row1, row2 = a + b, c + d
    col1 = a + c
    n = row1 + row2
    if n == 0:
        return None, 1.0

    odds_ratio: float | None
    if b * c == 0:
        odds_ratio = None if a * d == 0 else float("inf")
    else:
        odds_ratio = (a * d) / (b * c)

    min_a = max(0, col1 - row2)
    max_a = min(row1, col1)
    support = range(min_a, max_a + 1)
    probs = {i: _table_probability(i, row1, row2, col1) for i in support}
    obs_p = probs[a]

    if alternative == "less":
        p_value = sum(p for i, p in probs.items() if i <= a)
    elif alternative == "greater":
        p_value = sum(p for i, p in probs.items() if i >= a)
    else:
        p_value = sum(p for i, p in probs.items() if probs[i] <= obs_p + 1e-15)

    return odds_ratio, min(1.0, p_value)


def _mass_in_forbidden_zone(
    mass: float,
    forbidden_m: Sequence[int],
    *,
    tolerance: float,
) -> bool:
    for m in forbidden_m:
        if abs(m - mass) <= tolerance:
            return True
    return False


def _primary_mass_uncertainty(
    event: GwtcEvent,
) -> tuple[float, float | None, float | None]:
    """
    Return (median, lower_err, upper_err) for the primary component mass.

    Uses mass_1_source_lower/upper when m1 is primary; otherwise falls back to
    a degenerate (point-mass) distribution at primary_mass.
    """
    median = event.primary_mass
    if event.m1_solar >= event.m2_solar:
        if event.m1_source_lower is not None and event.m1_source_upper is not None:
            lower_err = median - event.m1_source_lower
            upper_err = event.m1_source_upper - median
            return median, lower_err, upper_err
    return median, None, None


def generate_split_normal_samples(
    median: float,
    lower_err: float | None,
    upper_err: float | None,
    *,
    n_samples: int = DEFAULT_MC_SAMPLES,
    rng: random.Random | None = None,
) -> list[float]:
    """
    Draw split-normal samples from GWOSC median + asymmetric 90% CI half-widths.

    sigma = |err| / 1.645. Missing errors → degenerate point mass at median.
    Samples are clamped to a small positive floor (1e-6 M_sun).
    """
    if rng is None:
        rng = random.Random()
    floor = 1e-6
    if lower_err is None or upper_err is None:
        return [max(floor, median) for _ in range(n_samples)]

    sigma_l = abs(lower_err) / NINETY_PCT_Z
    sigma_u = abs(upper_err) / NINETY_PCT_Z
    if sigma_l <= 0 and sigma_u <= 0:
        return [max(floor, median) for _ in range(n_samples)]

    total = sigma_l + sigma_u
    left_weight = sigma_l / total if total > 0 else 0.5
    samples: list[float] = []
    for _ in range(n_samples):
        if rng.random() < left_weight:
            draw = median - abs(rng.gauss(0.0, max(sigma_l, 1e-12)))
        else:
            draw = median + abs(rng.gauss(0.0, max(sigma_u, 1e-12)))
        samples.append(max(floor, draw))
    return samples


def calculate_pgap_monte_carlo(
    median: float,
    lower_err: float | None,
    upper_err: float | None,
    forbidden_m: Sequence[int],
    *,
    kappa: float = 1.0,
    tau: float = DEFAULT_TOLERANCE,
    n_samples: int = DEFAULT_MC_SAMPLES,
    rng: random.Random | None = None,
) -> float:
    """
    P_gap = fraction of MC mass draws whose kappa-quantized value lies within
    tau of any forbidden Legendre integer shell.
    """
    if rng is None:
        rng = random.Random()
    if not forbidden_m or n_samples < 1:
        return 0.0
    draws = generate_split_normal_samples(
        median, lower_err, upper_err, n_samples=n_samples, rng=rng
    )
    hits = sum(
        1
        for mass in draws
        if _mass_in_forbidden_zone(mass * kappa, forbidden_m, tolerance=tau)
    )
    return hits / len(draws)


def compute_pgap_table(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    kappa: float = 1.0,
    tau: float = DEFAULT_TOLERANCE,
    n_samples: int = DEFAULT_MC_SAMPLES,
    seed: int | None = None,
) -> list[float]:
    """One P_gap score per event (split-normal MC over primary mass)."""
    base_rng = random.Random(seed)
    p_gaps: list[float] = []
    for event in events:
        median, lo_err, hi_err = _primary_mass_uncertainty(event)
        event_rng = random.Random(base_rng.randint(0, 2**31 - 1))
        p_gaps.append(
            calculate_pgap_monte_carlo(
                median,
                lo_err,
                hi_err,
                forbidden_m,
                kappa=kappa,
                tau=tau,
                n_samples=n_samples,
                rng=event_rng,
            )
        )
    return p_gaps


def sum_1g_expected_hits_mc(
    events: Sequence[GwtcEvent],
    p_gaps: Sequence[float],
    *,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> float:
    """E[hits_1G] = sum of P_gap for events with chi_p below threshold."""
    return sum(
        p for event, p in zip(events, p_gaps, strict=True) if event.chi_p < chi_p_threshold
    )


def permutation_null_model_mc(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    kappa: float = 1.0,
    tau: float = DEFAULT_TOLERANCE,
    iterations: int = 10_000,
    n_mc_samples: int = DEFAULT_MC_SAMPLES,
    seed: int = 93,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> PermutationMcResult:
    """Alias for permutation_test_mc (chi_p shuffle, sum-of-P_gap metric)."""
    return permutation_test_mc(
        events,
        forbidden_m,
        kappa=kappa,
        tau=tau,
        iterations=iterations,
        n_mc_samples=n_mc_samples,
        seed=seed,
        chi_p_threshold=chi_p_threshold,
    )


def permutation_test_mc(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    kappa: float = 1.0,
    tau: float = DEFAULT_TOLERANCE,
    iterations: int = 10_000,
    n_mc_samples: int = DEFAULT_MC_SAMPLES,
    seed: int = 93,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> PermutationMcResult:
    """
    Permutation test with continuous P_gap scores.

    Metric: E[hits_1G] = sum of P_gap for chi_p < threshold (masses fixed).
    One-sided p-value: fraction of null draws with metric <= observed (1G avoidance).
    """
    event_list = list(events)
    if not event_list or iterations < 1:
        return PermutationMcResult(
            p_value=1.0,
            obs_1g_expected_hits=0.0,
            iterations=max(iterations, 0),
            null_mean=0.0,
            null_std=0.0,
            null_min=0.0,
            null_max=0.0,
            n_mc_samples=n_mc_samples,
            per_event_p_gaps=(),
        )

    p_gaps = compute_pgap_table(
        event_list,
        forbidden_m,
        kappa=kappa,
        tau=tau,
        n_samples=n_mc_samples,
        seed=seed,
    )
    obs = sum_1g_expected_hits_mc(
        event_list, p_gaps, chi_p_threshold=chi_p_threshold
    )

    rng = random.Random(seed + 1)
    chi_values = [e.chi_p for e in event_list]
    null_scores: list[float] = []

    for _ in range(iterations):
        shuffled = chi_values[:]
        rng.shuffle(shuffled)
        null_scores.append(
            sum(
                p
                for p, chi in zip(p_gaps, shuffled, strict=True)
                if chi < chi_p_threshold
            )
        )

    extreme = sum(1 for s in null_scores if s <= obs + 1e-15)
    p_value = extreme / iterations
    n = len(null_scores)
    mean = sum(null_scores) / n
    var = sum((s - mean) ** 2 for s in null_scores) / n
    return PermutationMcResult(
        p_value=p_value,
        obs_1g_expected_hits=obs,
        iterations=iterations,
        null_mean=mean,
        null_std=math.sqrt(var),
        null_min=min(null_scores),
        null_max=max(null_scores),
        n_mc_samples=n_mc_samples,
        per_event_p_gaps=tuple(p_gaps),
    )


def count_1g_in_forbidden_gap(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    quantization_scale: float = 1.0,
    tolerance: float = DEFAULT_TOLERANCE,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> int:
    """Number of low-precession (1G) candidates whose quantized mass hits a Legendre gap."""
    count = 0
    for event in events:
        if event.chi_p >= chi_p_threshold:
            continue
        q_mass = event.primary_mass * quantization_scale
        if _mass_in_forbidden_zone(q_mass, forbidden_m, tolerance=tolerance):
            count += 1
    return count


def run_eabc_statistical_test(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    quantization_scale: float = 1.0,
    tolerance: float = DEFAULT_TOLERANCE,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
    alternative: str = "less",
) -> FisherResult:
    in_1g = out_1g = in_2g = out_2g = 0
    for event in events:
        q_mass = event.primary_mass * quantization_scale
        in_forbidden = _mass_in_forbidden_zone(q_mass, forbidden_m, tolerance=tolerance)
        is_1g = event.chi_p < chi_p_threshold
        if is_1g:
            if in_forbidden:
                in_1g += 1
            else:
                out_1g += 1
        else:
            if in_forbidden:
                in_2g += 1
            else:
                out_2g += 1

    table = ContingencyTable(in_1g, out_1g, in_2g, out_2g)
    odds_ratio, p_value = fisher_exact(table.as_matrix(), alternative=alternative)
    return FisherResult(table=table, odds_ratio=odds_ratio, p_value=p_value, alternative=alternative)


def sweep_kappa(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    kappa_min: float = 0.1,
    kappa_max: float = 10.0,
    kappa_step: float = 0.1,
    tolerance: float = DEFAULT_TOLERANCE,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> list[KappaSweepPoint]:
    points: list[KappaSweepPoint] = []
    kappa = kappa_min
    while kappa <= kappa_max + 1e-12:
        fisher = run_eabc_statistical_test(
            events,
            forbidden_m,
            quantization_scale=kappa,
            tolerance=tolerance,
            chi_p_threshold=chi_p_threshold,
        )
        points.append(
            KappaSweepPoint(
                kappa=round(kappa, 10),
                p_value=fisher.p_value,
                odds_ratio=fisher.odds_ratio,
                table=fisher.table,
            )
        )
        kappa += kappa_step
    return points


def mock_gwtc5_events(
    n_events: int = 300,
    *,
    seed: int = 42,
    mass_range: tuple[float, float] = (5.0, 100.0),
) -> list[GwtcEvent]:
    rng = random.Random(seed)
    lo, hi = mass_range
    events: list[GwtcEvent] = []
    for i in range(n_events):
        m1 = rng.uniform(lo, hi)
        m2 = rng.uniform(lo, hi)
        primary = max(m1, m2)
        chi_p = max(0.0, min(1.0, rng.gauss(primary / 150.0, 0.2)))
        events.append(
            GwtcEvent(
                m1_solar=m1,
                m2_solar=m2,
                chi_p=chi_p,
                event_id=f"mock-{i:04d}",
            )
        )
    return events


def _parse_float(value: str | None) -> float | None:
    if value is None:
        return None
    text = value.strip()
    if not text or text.lower() in {"nan", "na", "none", ""}:
        return None
    try:
        return float(text)
    except ValueError:
        return None


def _csv_rows_skip_comments(path: Path) -> tuple[list[str], list[dict[str, str]]]:
    """Read CSV rows, skipping lines that start with '#' (GWOSC metadata headers)."""
    with path.open(newline="", encoding="utf-8") as fh:
        data_lines = [line for line in fh if not line.lstrip().startswith("#")]
    if not data_lines:
        return [], []
    reader = csv.DictReader(data_lines)
    fieldnames = list(reader.fieldnames or [])
    rows = [row for row in reader if row]
    return fieldnames, rows


def _is_gwosc_format(fieldnames: Sequence[str]) -> bool:
    cols = {c.strip() for c in fieldnames if c}
    return "mass_1_source" in cols or "mass_1" in cols


def _is_legacy_mock_format(fieldnames: Sequence[str]) -> bool:
    cols = {c.strip() for c in fieldnames if c}
    return "m1_solar" in cols and "m2_solar" in cols


def load_official_gwtc_catalog(path: Path) -> list[GwtcEvent]:
    """
    Load GWOSC catalog CSV (GWTC-3/4/5 style).

    Primary columns: mass_1_source, mass_2_source, chi_p.
    Fallback for older releases: mass_1, mass_2.
    Optional uncertainty columns mass_1_source_lower/upper are stored when present.
    Rows with missing mass or chi_p are dropped.
    """
    fieldnames, rows = _csv_rows_skip_comments(path)
    if not fieldnames:
        return []

    cols = {c.strip() for c in fieldnames if c}
    m1_col = "mass_1_source" if "mass_1_source" in cols else "mass_1"
    m2_col = "mass_2_source" if "mass_2_source" in cols else "mass_2"
    if m1_col not in cols or m2_col not in cols:
        raise ValueError(
            f"GWOSC columns missing: need {m1_col!r} and {m2_col!r}; got {sorted(cols)}"
        )
    if "chi_p" not in cols:
        raise ValueError("GWOSC column 'chi_p' missing — catalog has no precession data.")

    id_col = next((c for c in ("commonName", "event_name", "name", "event_id") if c in cols), None)
    has_lo = "mass_1_source_lower" in cols
    has_hi = "mass_1_source_upper" in cols

    events: list[GwtcEvent] = []
    for row in rows:
        m1 = _parse_float(row.get(m1_col))
        m2 = _parse_float(row.get(m2_col))
        chi_p = _parse_float(row.get("chi_p"))
        if m1 is None or m2 is None or chi_p is None:
            continue
        event_id = (row.get(id_col) or "").strip() if id_col else ""
        lo = _parse_float(row.get("mass_1_source_lower")) if has_lo else None
        hi = _parse_float(row.get("mass_1_source_upper")) if has_hi else None
        events.append(
            GwtcEvent(
                m1_solar=m1,
                m2_solar=m2,
                chi_p=chi_p,
                event_id=event_id,
                m1_source_lower=lo,
                m1_source_upper=hi,
            )
        )
    return events


def load_official_gwtc_catalog_pandas(path: Path) -> list[GwtcEvent]:
    """Optional pandas-backed GWOSC loader (lazy import)."""
    import pandas as pd

    df = pd.read_csv(path, comment="#")
    cols = set(df.columns.astype(str))
    m1_col = "mass_1_source" if "mass_1_source" in cols else "mass_1"
    m2_col = "mass_2_source" if "mass_2_source" in cols else "mass_2"
    if "chi_p" not in cols:
        raise ValueError("GWOSC column 'chi_p' missing.")
    subset = [m1_col, m2_col, "chi_p"]
    id_col = next((c for c in ("commonName", "event_name", "name", "event_id") if c in cols), None)
    if id_col:
        subset.append(id_col)
    for opt in ("mass_1_source_lower", "mass_1_source_upper"):
        if opt in cols:
            subset.append(opt)
    df_clean = df.dropna(subset=[m1_col, m2_col, "chi_p"])
    events: list[GwtcEvent] = []
    for _, row in df_clean.iterrows():
        events.append(
            GwtcEvent(
                m1_solar=float(row[m1_col]),
                m2_solar=float(row[m2_col]),
                chi_p=float(row["chi_p"]),
                event_id=str(row[id_col]) if id_col else "",
                m1_source_lower=(
                    float(row["mass_1_source_lower"])
                    if "mass_1_source_lower" in cols and pd.notna(row.get("mass_1_source_lower"))
                    else None
                ),
                m1_source_upper=(
                    float(row["mass_1_source_upper"])
                    if "mass_1_source_upper" in cols and pd.notna(row.get("mass_1_source_upper"))
                    else None
                ),
            )
        )
    return events


def load_gwtc_csv(path: Path) -> list[GwtcEvent]:
    """Load legacy mock CSV: event_id, m1_solar, m2_solar, chi_p."""
    _, rows = _csv_rows_skip_comments(path)
    events: list[GwtcEvent] = []
    for row in rows:
        m1 = _parse_float(row.get("m1_solar"))
        m2 = _parse_float(row.get("m2_solar"))
        chi_p = _parse_float(row.get("chi_p"))
        if m1 is None or m2 is None or chi_p is None:
            continue
        events.append(
            GwtcEvent(
                m1_solar=m1,
                m2_solar=m2,
                chi_p=chi_p,
                event_id=row.get("event_id", "") or "",
            )
        )
    return events


def load_gwtc_catalog(path: Path, *, use_pandas: bool = False) -> list[GwtcEvent]:
    """Auto-detect GWOSC vs legacy mock CSV format."""
    fieldnames, _ = _csv_rows_skip_comments(path)
    if _is_gwosc_format(fieldnames):
        if use_pandas:
            return load_official_gwtc_catalog_pandas(path)
        return load_official_gwtc_catalog(path)
    if _is_legacy_mock_format(fieldnames):
        return load_gwtc_csv(path)
    raise ValueError(
        f"Unrecognized GWTC CSV columns {fieldnames!r}; "
        "expected GWOSC (mass_1_source/mass_1) or legacy (m1_solar)."
    )


def permutation_null_model(
    events: Sequence[GwtcEvent],
    forbidden_m: Sequence[int],
    *,
    kappa: float = 1.0,
    tau: float = DEFAULT_TOLERANCE,
    iterations: int = 10_000,
    seed: int = 93,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
) -> PermutationNullResult:
    """
    Permutation test: shuffle chi_p while fixing masses.

    Metric: count of 1G candidates (chi_p < threshold) in forbidden Legendre gaps.
    One-sided p-value: fraction of null draws with count <= observed (1G avoidance).
    """
    event_list = list(events)
    if not event_list or iterations < 1:
        return PermutationNullResult(
            p_value=1.0,
            obs_1g_in_gap=0,
            iterations=max(iterations, 0),
            null_mean=0.0,
            null_std=0.0,
            null_min=0,
            null_max=0,
        )

    obs_1g_in_gap = count_1g_in_forbidden_gap(
        event_list,
        forbidden_m,
        quantization_scale=kappa,
        tolerance=tau,
        chi_p_threshold=chi_p_threshold,
    )

    rng = random.Random(seed)
    chi_values = [e.chi_p for e in event_list]
    null_counts: list[int] = []

    for _ in range(iterations):
        shuffled = chi_values[:]
        rng.shuffle(shuffled)
        permuted = [
            GwtcEvent(
                m1_solar=e.m1_solar,
                m2_solar=e.m2_solar,
                chi_p=shuffled[i],
                event_id=e.event_id,
                m1_source_lower=e.m1_source_lower,
                m1_source_upper=e.m1_source_upper,
            )
            for i, e in enumerate(event_list)
        ]
        null_counts.append(
            count_1g_in_forbidden_gap(
                permuted,
                forbidden_m,
                quantization_scale=kappa,
                tolerance=tau,
                chi_p_threshold=chi_p_threshold,
            )
        )

    extreme = sum(1 for c in null_counts if c <= obs_1g_in_gap)
    p_value = extreme / iterations
    n = len(null_counts)
    mean = sum(null_counts) / n
    var = sum((c - mean) ** 2 for c in null_counts) / n
    return PermutationNullResult(
        p_value=p_value,
        obs_1g_in_gap=obs_1g_in_gap,
        iterations=iterations,
        null_mean=mean,
        null_std=math.sqrt(var),
        null_min=min(null_counts),
        null_max=max(null_counts),
    )


def build_black_hole_analysis(
    events: Sequence[GwtcEvent] | None = None,
    *,
    kappa: float = 1.0,
    tolerance: float = DEFAULT_TOLERANCE,
    chi_p_threshold: float = DEFAULT_CHI_P_1G_THRESHOLD,
    max_norm: int = DEFAULT_MAX_NORM,
    kappa_sweep: bool = True,
    kappa_min: float = 0.1,
    kappa_max: float = 10.0,
    kappa_step: float = 0.1,
    permutation_null: bool = True,
    permutation_iterations: int = 10_000,
    permutation_seed: int = 93,
    use_monte_carlo: bool = False,
    mc_samples: int = DEFAULT_MC_SAMPLES,
) -> BlackHoleAnalysis:
    if events is None:
        events = mock_gwtc5_events()
    forbidden = get_forbidden_mass_integers(max_norm=max_norm)
    fisher = run_eabc_statistical_test(
        events,
        forbidden,
        quantization_scale=kappa,
        tolerance=tolerance,
        chi_p_threshold=chi_p_threshold,
    )
    sweep = (
        sweep_kappa(
            events,
            forbidden,
            kappa_min=kappa_min,
            kappa_max=kappa_max,
            kappa_step=kappa_step,
            tolerance=tolerance,
            chi_p_threshold=chi_p_threshold,
        )
        if kappa_sweep
        else []
    )
    perm: PermutationNullResult | None = None
    perm_mc: PermutationMcResult | None = None
    if permutation_null:
        if use_monte_carlo:
            perm_mc = permutation_test_mc(
                events,
                forbidden,
                kappa=kappa,
                tau=tolerance,
                iterations=permutation_iterations,
                n_mc_samples=mc_samples,
                seed=permutation_seed,
                chi_p_threshold=chi_p_threshold,
            )
        else:
            perm = permutation_null_model(
                events,
                forbidden,
                kappa=kappa,
                tau=tolerance,
                iterations=permutation_iterations,
                seed=permutation_seed,
                chi_p_threshold=chi_p_threshold,
            )
    return BlackHoleAnalysis(
        events=list(events),
        forbidden_m=forbidden,
        kappa=kappa,
        tolerance=tolerance,
        chi_p_threshold=chi_p_threshold,
        fisher=fisher,
        kappa_sweep=sweep,
        permutation_null=perm,
        permutation_null_mc=perm_mc,
        use_monte_carlo=use_monte_carlo,
    )


def export_black_hole_bundle(
    analysis: BlackHoleAnalysis,
    out_dir: Path,
    *,
    prefix: str = "black_hole_gwtc",
) -> dict[str, Path]:
    out_dir.mkdir(parents=True, exist_ok=True)
    summary_path = out_dir / f"{prefix}_summary.json"
    table_path = out_dir / f"{prefix}_contingency.csv"
    sweep_path = out_dir / f"{prefix}_kappa_sweep.csv"

    best_kappa = None
    if analysis.kappa_sweep:
        best = min(analysis.kappa_sweep, key=lambda p: p.p_value)
        best_kappa = {"kappa": best.kappa, "p_value": best.p_value}

    summary = {
        "governance": analysis.tag,
        "evidence_id": "E-093",
        "orq_id": "ORQ-093",
        "n_events": len(analysis.events),
        "kappa": analysis.kappa,
        "tolerance": analysis.tolerance,
        "chi_p_threshold": analysis.chi_p_threshold,
        "forbidden_mass_count": len(analysis.forbidden_m),
        "forbidden_mass_preview": analysis.forbidden_m[:20],
        "contingency_table": analysis.fisher.table.as_matrix(),
        "fisher_p_value": analysis.fisher.p_value,
        "fisher_odds_ratio": analysis.fisher.odds_ratio,
        "permutation_null": (
            {
                "p_value": analysis.permutation_null.p_value,
                "obs_1g_in_gap": analysis.permutation_null.obs_1g_in_gap,
                "iterations": analysis.permutation_null.iterations,
                "null_mean": analysis.permutation_null.null_mean,
                "null_std": analysis.permutation_null.null_std,
                "null_min": analysis.permutation_null.null_min,
                "null_max": analysis.permutation_null.null_max,
            }
            if analysis.permutation_null is not None
            else None
        ),
        "monte_carlo": analysis.use_monte_carlo,
        "permutation_null_mc": (
            {
                "p_value": analysis.permutation_null_mc.p_value,
                "obs_1g_expected_hits": analysis.permutation_null_mc.obs_1g_expected_hits,
                "iterations": analysis.permutation_null_mc.iterations,
                "n_mc_samples": analysis.permutation_null_mc.n_mc_samples,
                "null_mean": analysis.permutation_null_mc.null_mean,
                "null_std": analysis.permutation_null_mc.null_std,
                "null_min": analysis.permutation_null_mc.null_min,
                "null_max": analysis.permutation_null_mc.null_max,
                "per_event_p_gaps": list(analysis.permutation_null_mc.per_event_p_gaps),
            }
            if analysis.permutation_null_mc is not None
            else None
        ),
        "fisher_deprecated_when_mc_active": analysis.use_monte_carlo,
        "best_kappa_scan": best_kappa,
        "governance_fields": analysis.governance,
        "interpretation_note": (
            "kappa sweep minima are exploratory until preregistered on real GWTC data; "
            "mock catalog only."
        ),
    }
    summary_path.write_text(json.dumps(summary, indent=2), encoding="utf-8")

    with table_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(["population", "in_legendre_gap", "outside_legendre_gap"])
        t = analysis.fisher.table
        writer.writerow(["1G_chi_p_lt_threshold", t.in_forbidden_1g, t.out_forbidden_1g])
        writer.writerow(["2G_chi_p_ge_threshold", t.in_forbidden_2g, t.out_forbidden_2g])

    with sweep_path.open("w", newline="", encoding="utf-8") as fh:
        writer = csv.writer(fh)
        writer.writerow(
            ["kappa", "p_value", "odds_ratio", "in_1g", "out_1g", "in_2g", "out_2g"]
        )
        for point in analysis.kappa_sweep:
            tt = point.table
            writer.writerow(
                [
                    point.kappa,
                    point.p_value,
                    point.odds_ratio,
                    tt.in_forbidden_1g,
                    tt.out_forbidden_1g,
                    tt.in_forbidden_2g,
                    tt.out_forbidden_2g,
                ]
            )

    return {
        "summary": summary_path,
        "contingency": table_path,
        "kappa_sweep": sweep_path,
    }
