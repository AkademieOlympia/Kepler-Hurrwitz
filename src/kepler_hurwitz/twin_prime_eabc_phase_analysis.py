from __future__ import annotations

import json
import math
import random
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.kepler_eabc_atlas import floquet_step_channel

GOVERNANCE = {
    "mode": "phase_distribution_analysis",
    "status": "B descriptive phase-distribution analysis",
    "not_claimed": (
        "No proof of twin primes, no held-out confirmation of any phase rule, "
        "and no optimized selector"
    ),
    "selection_rule": (
        "No phase selection rule is used in this report; all phases are reported descriptively."
    ),
    "primary_question": (
        "Are true twin-prime hits uniformly distributed across the fixed EABC/Floquet phases "
        "among classically sieved CE candidates?"
    ),
    "exploratory_question": (
        "Do any fixed phases show enrichment worth testing in a future preregistered run?"
    ),
}

STATUS = GOVERNANCE["status"]
NOT_CLAIMED = GOVERNANCE["not_claimed"]
SELECTION_RULE = GOVERNANCE["selection_rule"]
MODE = GOVERNANCE["mode"]
PRIMARY_QUESTION = GOVERNANCE["primary_question"]
EXPLORATORY_QUESTION = GOVERNANCE["exploratory_question"]

RANDOMIZED_LABELS_SEED = 12345
UNIFORMITY_ALPHA = 0.05
MULTIPLE_TESTING_PHASE_COUNT = 8

DEFAULT_LIMIT = 1_000_000
DEFAULT_SIEVE_BOUND = 97

REPORT_HEADER_EN = (
    "# EABC/Floquet Phase Distribution for Twin-Prime Candidates\n"
    "Status: B descriptive phase-distribution analysis.\n"
    "This report describes the phase distribution of true twin-prime hits across the "
    "fixed EABC/Floquet phases among classically sieved CE candidates. It does not claim "
    "deterministic phase selection, infinitude of twin primes, or a proof of the twin-prime "
    "conjecture.\n"
    "Any best-performing phase selected after inspecting this dataset is classified as "
    "exploratory enrichment [C]. Held-out confirmation would require testing a fixed rule "
    "on a disjoint numerical range."
)

QuadrupletClass = str  # twin_only | near_quadruplet | prime_quadruplet | failed_candidate


def is_probable_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    limit = int(math.isqrt(n))
    for divisor in range(3, limit + 1, 2):
        if n % divisor == 0:
            return False
    return True


def is_twin_prime(n: int) -> bool:
    return is_probable_prime(n) and is_probable_prime(n + 2)


def _small_primes_up_to(bound: int) -> tuple[int, ...]:
    if bound < 2:
        return ()
    is_prime = [True] * (bound + 1)
    is_prime[0] = False
    if bound >= 1:
        is_prime[1] = False
    for candidate in range(2, int(math.isqrt(bound)) + 1):
        if is_prime[candidate]:
            for composite in range(candidate * candidate, bound + 1, candidate):
                is_prime[composite] = False
    return tuple(index for index, ok in enumerate(is_prime) if ok)


def passes_twin_sieve(n: int, sieve_primes: Sequence[int]) -> bool:
    """Classical sieve: n and n+2 not divisible by small primes q ≤ B."""
    if n < 11 or n % 12 != 11:
        return False
    for prime in sieve_primes:
        if prime == n or prime == n + 2:
            continue
        if n % prime == 0 or (n + 2) % prime == 0:
            return False
    return True


def classify_quadruplet_neighborhood(n: int) -> QuadrupletClass:
    """Classify (n, n+2, n+6, n+8) prime pattern for a twin candidate."""
    p0 = is_probable_prime(n)
    p2 = is_probable_prime(n + 2)
    p6 = is_probable_prime(n + 6)
    p8 = is_probable_prime(n + 8)
    count = sum((p0, p2, p6, p8))
    if p0 and p2 and p6 and p8:
        return "prime_quadruplet"
    if p0 and p2 and count == 3:
        return "near_quadruplet"
    if p0 and p2:
        return "twin_only"
    return "failed_candidate"


def generate_ce_twin_candidates(limit: int) -> list[int]:
    """All twin candidates with n ≡ 11 (mod 12) up to limit."""
    if limit < 11:
        return []
    return list(range(11, limit - 2 + 1, 12))


@dataclass(frozen=True)
class TwinPrimeCandidate:
    n: int
    candidate_index: int
    floquet_step: int
    channel: str
    chi_phase: int
    sheet: int
    passed_small_sieve: bool
    is_twin_prime: bool
    quadruplet_type: str


def annotate_twin_candidate(
    n: int,
    candidate_index: int,
    sieve_primes: Sequence[int],
) -> TwinPrimeCandidate:
    floquet_step = candidate_index % 8
    channel = floquet_step_channel(floquet_step).value
    return TwinPrimeCandidate(
        n=n,
        candidate_index=candidate_index,
        floquet_step=floquet_step,
        channel=channel,
        chi_phase=floquet_step % 4,
        sheet=floquet_step // 4,
        passed_small_sieve=passes_twin_sieve(n, sieve_primes),
        is_twin_prime=is_twin_prime(n),
        quadruplet_type=classify_quadruplet_neighborhood(n),
    )


def hit_rate(
    rows: Sequence[TwinPrimeCandidate],
    predicate: Callable[[TwinPrimeCandidate], bool],
) -> float | None:
    selected = [row for row in rows if predicate(row)]
    if not selected:
        return None
    return sum(row.is_twin_prime for row in selected) / len(selected)


def enrichment(scored_rate: float | None, baseline_rate: float | None) -> float | None:
    if scored_rate is None or baseline_rate is None or baseline_rate == 0:
        return None
    return scored_rate / baseline_rate


@dataclass(frozen=True)
class RateSummary:
    candidate_count: int
    hit_count: int
    hit_rate: float

    def to_dict(self) -> dict[str, Any]:
        return {
            "candidate_count": self.candidate_count,
            "hit_count": self.hit_count,
            "hit_rate": self.hit_rate,
        }


@dataclass(frozen=True)
class GroupRate:
    label: str
    candidate_count: int
    hit_count: int
    hit_rate: float
    enrichment: float | None

    def to_dict(self) -> dict[str, Any]:
        return {
            "label": self.label,
            "candidate_count": self.candidate_count,
            "hit_count": self.hit_count,
            "hit_rate": self.hit_rate,
            "enrichment": self.enrichment,
        }


@dataclass(frozen=True)
class UniformDistributionTest:
    chi2: float
    p_value: float
    degrees_of_freedom: int
    total_hits: int
    expected_hits_per_phase: float
    rejects_uniformity: bool
    evidence_tag: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "chi2": self.chi2,
            "p_value": self.p_value,
            "degrees_of_freedom": self.degrees_of_freedom,
            "total_hits": self.total_hits,
            "expected_hits_per_phase": self.expected_hits_per_phase,
            "rejects_uniformity": self.rejects_uniformity,
            "evidence_tag": self.evidence_tag,
        }


@dataclass(frozen=True)
class ExploratoryBestPhase:
    floquet_step: str
    channel: str
    candidate_count: int
    hit_count: int
    hit_rate: float
    enrichment: float | None
    caveat: str
    evidence_tag: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "floquet_step": self.floquet_step,
            "channel": self.channel,
            "candidate_count": self.candidate_count,
            "hit_count": self.hit_count,
            "hit_rate": self.hit_rate,
            "enrichment": self.enrichment,
            "caveat": self.caveat,
            "evidence_tag": self.evidence_tag,
        }


def _rate_summary(rows: Sequence[TwinPrimeCandidate]) -> RateSummary:
    hits = sum(row.is_twin_prime for row in rows)
    count = len(rows)
    rate = hits / count if count else 0.0
    return RateSummary(candidate_count=count, hit_count=hits, hit_rate=rate)


def _group_rates(
    rows: Sequence[TwinPrimeCandidate],
    *,
    label_fn: Callable[[TwinPrimeCandidate], str],
    baseline_rate: float | None,
) -> tuple[GroupRate, ...]:
    buckets: dict[str, list[TwinPrimeCandidate]] = {}
    for row in rows:
        buckets.setdefault(label_fn(row), []).append(row)

    groups: list[GroupRate] = []
    for label in sorted(buckets, key=_sort_group_label):
        members = buckets[label]
        summary = _rate_summary(members)
        groups.append(
            GroupRate(
                label=label,
                candidate_count=summary.candidate_count,
                hit_count=summary.hit_count,
                hit_rate=summary.hit_rate,
                enrichment=enrichment(summary.hit_rate, baseline_rate),
            )
        )
    return tuple(groups)


def _sort_group_label(label: str) -> tuple[int, str]:
    if label.isdigit():
        return (0, f"{int(label):04d}")
    return (1, label)


def _floquet_groups(
    sieved_rows: Sequence[TwinPrimeCandidate],
    baseline_rate: float | None,
) -> dict[str, tuple[GroupRate, ...]]:
    return {
        "by_step": _group_rates(sieved_rows, label_fn=lambda r: str(r.floquet_step), baseline_rate=baseline_rate),
        "by_channel": _group_rates(sieved_rows, label_fn=lambda r: r.channel, baseline_rate=baseline_rate),
        "by_chi_phase": _group_rates(sieved_rows, label_fn=lambda r: str(r.chi_phase), baseline_rate=baseline_rate),
        "by_sheet": _group_rates(sieved_rows, label_fn=lambda r: str(r.sheet), baseline_rate=baseline_rate),
    }


def randomized_channel_sequence(seed: int = RANDOMIZED_LABELS_SEED) -> tuple[str, ...]:
    """Permuted 8-step channel labels (E,A,C,B cycle); numbers unchanged."""
    base = tuple(floquet_step_channel(step).value for step in range(8))
    labels = list(base)
    random.Random(seed).shuffle(labels)
    return tuple(labels)


def _shifted_step(candidate_index: int, shift: int) -> int:
    return (candidate_index + shift) % 8


def _phase_shift_groups(
    sieved_rows: Sequence[TwinPrimeCandidate],
    *,
    shift: int,
    baseline_rate: float | None,
) -> tuple[GroupRate, ...]:
    def label_fn(row: TwinPrimeCandidate) -> str:
        return str(_shifted_step(row.candidate_index, shift))

    return _group_rates(sieved_rows, label_fn=label_fn, baseline_rate=baseline_rate)


def phase_shift_summary(
    rows: Sequence[TwinPrimeCandidate],
    shift: int,
    *,
    baseline_rate: float | None = None,
) -> dict[str, Any]:
    """Summarize hit rates by shifted floquet step; candidate count is unchanged."""
    sieved_rows = [row for row in rows if row.passed_small_sieve]
    if baseline_rate is None:
        baseline_rate = _rate_summary(sieved_rows).hit_rate if sieved_rows else None
    groups = _phase_shift_groups(sieved_rows, shift=shift, baseline_rate=baseline_rate)
    enrichments = [group.enrichment for group in groups if group.enrichment is not None]
    max_enrichment = max(enrichments) if enrichments else None
    return {
        "shift": shift,
        "candidate_count": len(sieved_rows),
        "by_step": [group.to_dict() for group in groups],
        "max_hit_rate_spread": _max_hit_rate_spread(groups),
        "max_enrichment": max_enrichment,
    }


def _randomized_label_groups(
    sieved_rows: Sequence[TwinPrimeCandidate],
    *,
    permuted_channels: Sequence[str],
    baseline_rate: float | None,
) -> tuple[GroupRate, ...]:
    def label_fn(row: TwinPrimeCandidate) -> str:
        return permuted_channels[row.floquet_step]

    return _group_rates(sieved_rows, label_fn=label_fn, baseline_rate=baseline_rate)


def _quadruplet_neighborhood(rows: Sequence[TwinPrimeCandidate]) -> dict[str, int]:
    counts = {
        "failed_candidate": 0,
        "twin_only": 0,
        "near_quadruplet": 0,
        "prime_quadruplet": 0,
    }
    for row in rows:
        counts[row.quadruplet_type] += 1
    return counts


def _max_hit_rate_spread(groups: tuple[GroupRate, ...]) -> float:
    if len(groups) < 2:
        return 0.0
    rates = [group.hit_rate for group in groups]
    return max(rates) - min(rates)


def _chi2_upper_tail_p_value(chi2: float, dof: int) -> float:
    """Wilson-Hilferty normal approximation for the chi-square upper tail."""
    if chi2 <= 0 or dof <= 0:
        return 1.0
    z = (chi2 / dof) ** (1 / 3) - (1 - 2 / (9 * dof))
    z /= math.sqrt(2 / (9 * dof))
    return 0.5 * math.erfc(z / math.sqrt(2))


def uniform_distribution_test(by_step: Sequence[GroupRate]) -> UniformDistributionTest:
    """Goodness-of-fit test: are twin hits uniform across floquet_step 0..7?"""
    observed = [group.hit_count for group in by_step]
    total_hits = sum(observed)
    phase_count = len(observed)
    if phase_count == 0 or total_hits == 0:
        return UniformDistributionTest(
            chi2=0.0,
            p_value=1.0,
            degrees_of_freedom=0,
            total_hits=total_hits,
            expected_hits_per_phase=0.0,
            rejects_uniformity=False,
            evidence_tag="[B]",
        )

    expected = total_hits / phase_count
    chi2 = sum((count - expected) ** 2 / expected for count in observed)
    dof = phase_count - 1
    p_value = _chi2_upper_tail_p_value(chi2, dof)
    return UniformDistributionTest(
        chi2=chi2,
        p_value=p_value,
        degrees_of_freedom=dof,
        total_hits=total_hits,
        expected_hits_per_phase=expected,
        rejects_uniformity=p_value < UNIFORMITY_ALPHA,
        evidence_tag="[B]",
    )


def exploratory_best_phase(
    by_step: Sequence[GroupRate],
    *,
    baseline_rate: float,
) -> ExploratoryBestPhase:
    """Post-hoc best floquet step by enrichment vs sieved baseline."""
    if not by_step:
        return ExploratoryBestPhase(
            floquet_step="",
            channel="",
            candidate_count=0,
            hit_count=0,
            hit_rate=0.0,
            enrichment=None,
            caveat=(
                f"Post-hoc scan across {MULTIPLE_TESTING_PHASE_COUNT} fixed phases; "
                "not preregistered; multiple-testing correction not applied."
            ),
            evidence_tag="[C]",
        )

    best = max(
        by_step,
        key=lambda group: group.enrichment if group.enrichment is not None else float("-inf"),
    )
    step = int(best.label)
    return ExploratoryBestPhase(
        floquet_step=best.label,
        channel=floquet_step_channel(step).value,
        candidate_count=best.candidate_count,
        hit_count=best.hit_count,
        hit_rate=best.hit_rate,
        enrichment=best.enrichment,
        caveat=(
            f"Post-hoc scan across {MULTIPLE_TESTING_PHASE_COUNT} fixed floquet phases; "
            "not preregistered; Bonferroni or other multiple-testing correction not applied."
        ),
        evidence_tag="[C]",
    )


@dataclass(frozen=True)
class TwinPrimePhaseAnalysisReport:
    status: str
    not_claimed: str
    mode: str
    primary_question: str
    exploratory_question: str
    limit: int
    sieve_bound: int
    baseline: RateSummary
    small_sieve: RateSummary
    primary_analysis: UniformDistributionTest
    primary_phase_table: tuple[GroupRate, ...]
    exploratory_analysis: ExploratoryBestPhase
    floquet_groups: dict[str, tuple[GroupRate, ...]]
    null_models: dict[str, Any]
    quadruplet_neighborhood: dict[str, int]
    primary_evidence: str
    exploratory_evidence: str

    def to_minimal_dict(self) -> dict[str, Any]:
        by_floquet_step = [
            {
                "phase": int(group.label),
                "count": group.candidate_count,
                "hits": group.hit_count,
                "hit_rate": group.hit_rate,
            }
            for group in self.primary_phase_table
        ]
        by_channel = [
            {
                "channel": group.label,
                "count": group.candidate_count,
                "hits": group.hit_count,
                "hit_rate": group.hit_rate,
            }
            for group in self.floquet_groups["by_channel"]
        ]
        phase_shifts = [
            {
                "shift": entry["shift"],
                "max_enrichment": entry["max_enrichment"],
            }
            for entry in self.null_models["phase_shifts"]
        ]
        exploratory = self.exploratory_analysis
        hit_rates = [group.hit_rate for group in self.primary_phase_table]
        enrichments = [
            group.enrichment
            for group in self.primary_phase_table
            if group.enrichment is not None
        ]
        return {
            **GOVERNANCE,
            "limit": self.limit,
            "sieve_bound": self.sieve_bound,
            "candidate_count": self.baseline.candidate_count,
            "sieved_candidate_count": self.small_sieve.candidate_count,
            "twin_hit_count": self.small_sieve.hit_count,
            "overall_hit_rate": self.small_sieve.hit_rate,
            "by_floquet_step": by_floquet_step,
            "by_channel": by_channel,
            "phase_shifts": phase_shifts,
            "uniformity_diagnostic": {
                "status": "B descriptive only",
                "max_hit_rate": max(hit_rates) if hit_rates else None,
                "min_hit_rate": min(hit_rates) if hit_rates else None,
                "spread": _max_hit_rate_spread(self.primary_phase_table),
                "max_enrichment_vs_overall": max(enrichments) if enrichments else None,
            },
            "exploratory_best_phase": {
                "status": "C exploratory only",
                "warning": (
                    "Selected after inspecting the same dataset; "
                    "not a confirmatory phase-selection rule."
                ),
                "phase": int(exploratory.floquet_step) if exploratory.floquet_step else None,
                "enrichment": exploratory.enrichment,
            },
            "primary_analysis": self.primary_analysis.to_dict(),
        }


def build_twin_prime_candidates(
    *,
    limit: int = DEFAULT_LIMIT,
    sieve_bound: int = DEFAULT_SIEVE_BOUND,
) -> list[TwinPrimeCandidate]:
    sieve_primes = _small_primes_up_to(sieve_bound)
    return [
        annotate_twin_candidate(n, candidate_index, sieve_primes)
        for candidate_index, n in enumerate(generate_ce_twin_candidates(limit))
    ]


def run_twin_prime_phase_analysis(
    *,
    limit: int = DEFAULT_LIMIT,
    sieve_bound: int = DEFAULT_SIEVE_BOUND,
) -> TwinPrimePhaseAnalysisReport:
    if limit < 11:
        raise ValueError("limit must be at least 11.")

    rows = build_twin_prime_candidates(limit=limit, sieve_bound=sieve_bound)
    baseline = _rate_summary(rows)
    sieved_rows = [row for row in rows if row.passed_small_sieve]
    small_sieve = _rate_summary(sieved_rows)

    floquet_groups = _floquet_groups(sieved_rows, baseline_rate=small_sieve.hit_rate)
    by_step = floquet_groups["by_step"]

    primary_analysis = uniform_distribution_test(by_step)
    exploratory_analysis = exploratory_best_phase(by_step, baseline_rate=small_sieve.hit_rate)

    phase_shifts: list[dict[str, Any]] = []
    for shift in range(1, 8):
        phase_shifts.append(phase_shift_summary(rows, shift, baseline_rate=small_sieve.hit_rate))

    permuted = randomized_channel_sequence(RANDOMIZED_LABELS_SEED)
    randomized_by_channel = _randomized_label_groups(
        sieved_rows,
        permuted_channels=permuted,
        baseline_rate=small_sieve.hit_rate,
    )
    randomized_by_step = _group_rates(
        sieved_rows,
        label_fn=lambda row: permuted[row.floquet_step],
        baseline_rate=small_sieve.hit_rate,
    )

    null_models = {
        "phase_shifts": phase_shifts,
        "randomized_labels": {
            "seed": RANDOMIZED_LABELS_SEED,
            "permuted_channel_sequence": list(permuted),
            "by_channel": [group.to_dict() for group in randomized_by_channel],
            "by_step": [group.to_dict() for group in randomized_by_step],
            "max_hit_rate_spread": _max_hit_rate_spread(randomized_by_channel),
        },
    }

    quadruplet_neighborhood = _quadruplet_neighborhood(sieved_rows)

    return TwinPrimePhaseAnalysisReport(
        status=STATUS,
        not_claimed=NOT_CLAIMED,
        mode=MODE,
        primary_question=PRIMARY_QUESTION,
        exploratory_question=EXPLORATORY_QUESTION,
        limit=limit,
        sieve_bound=sieve_bound,
        baseline=baseline,
        small_sieve=small_sieve,
        primary_analysis=primary_analysis,
        primary_phase_table=by_step,
        exploratory_analysis=exploratory_analysis,
        floquet_groups=floquet_groups,
        null_models=null_models,
        quadruplet_neighborhood=quadruplet_neighborhood,
        primary_evidence=primary_analysis.evidence_tag,
        exploratory_evidence=exploratory_analysis.evidence_tag,
    )


def export_twin_prime_phase_analysis_json(report: TwinPrimePhaseAnalysisReport, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(
        json.dumps(report.to_minimal_dict(), indent=2, sort_keys=True) + "\n",
        encoding="utf-8",
    )


def format_twin_prime_phase_analysis_report(report: TwinPrimePhaseAnalysisReport) -> str:
    uniform = report.primary_analysis
    exploratory = report.exploratory_analysis

    lines = [
        REPORT_HEADER_EN,
        "",
        "## Evidence classification",
        "",
        "| Section | Status |",
        "|---|---|",
        "| Overall distribution 8 phases | [B] |",
        "| Best phase same dataset | [C] exploratory |",
        "| Fixed rule disjoint range | future confirmatory |",
        "",
        "## Experiment configuration",
        "",
        f"- limit: {report.limit}",
        f"- sieve_bound: {report.sieve_bound}",
        f"- channel sequence: E,A,C,B,E,A,C,B (via floquet_step_channel)",
        f"- uniformity alpha: {UNIFORMITY_ALPHA}",
        "",
        "## Cohort summary",
        "",
        "| cohort | candidates | twin hits | hit rate | enrichment vs baseline |",
        "|---|---:|---:|---:|---:|",
        f"| all CE candidates | {report.baseline.candidate_count} | {report.baseline.hit_count} | "
        f"{report.baseline.hit_rate:.6f} | 1.000000 |",
        f"| small sieve (passed) | {report.small_sieve.candidate_count} | {report.small_sieve.hit_count} | "
        f"{report.small_sieve.hit_rate:.6f} | "
        f"{enrichment(report.small_sieve.hit_rate, report.baseline.hit_rate)} |",
        "",
        f"## Overall distribution across 8 phases {report.primary_evidence}",
        "",
        "Descriptive distribution of true twin-prime hits across fixed floquet_step 0..7 "
        "among classically sieved CE candidates, with a chi-square goodness-of-fit test "
        "for uniformity across the eight phases.",
        "",
        f"- chi²: {uniform.chi2:.6f}",
        f"- degrees of freedom: {uniform.degrees_of_freedom}",
        f"- p-value: {uniform.p_value:.6f}",
        f"- total twin hits (sieved): {uniform.total_hits}",
        f"- expected hits per phase (uniform null): {uniform.expected_hits_per_phase:.3f}",
        f"- rejects uniformity (α={UNIFORMITY_ALPHA}): {uniform.rejects_uniformity}",
        "",
        "### Uniformity diagnostic (descriptive)",
        "",
        f"- max hit rate across phases: {max(group.hit_rate for group in report.primary_phase_table):.6f}",
        f"- min hit rate across phases: {min(group.hit_rate for group in report.primary_phase_table):.6f}",
        f"- spread (max − min): {_max_hit_rate_spread(report.primary_phase_table):.6f}",
        (
            "- max enrichment vs overall: "
            f"{max((group.enrichment for group in report.primary_phase_table if group.enrichment is not None), default=0.0):.6f}"
        ),
        "",
        f"Selection rule: {SELECTION_RULE}",
        "",
        "| floquet_step | channel | candidates | twin hits | hit rate | share of hits |",
        "|---:|---|---:|---:|---:|---:|",
    ]

    total_hits = uniform.total_hits or 1
    for group in report.primary_phase_table:
        step = int(group.label)
        channel = floquet_step_channel(step).value
        share = group.hit_count / total_hits
        lines.append(
            f"| {group.label} | {channel} | {group.candidate_count} | {group.hit_count} | "
            f"{group.hit_rate:.6f} | {share:.4f} |"
        )

    enrich_text = (
        f"{exploratory.enrichment:.6f}" if exploratory.enrichment is not None else "null"
    )
    lines.extend(
        [
            "",
            f"## Exploratory enrichment on same dataset {report.exploratory_evidence}",
            "",
            "Post-hoc identification of the floquet phase with highest exploratory "
            "enrichment relative to the sieved baseline hit rate. **Exploratory enrichment "
            "only** — not a preregistered or held-out confirmation rule.",
            "",
            f"**Caveat:** {exploratory.caveat}",
            "",
            "| floquet_step | channel | candidates | twin hits | hit rate | enrichment vs sieve |",
            "|---:|---|---:|---:|---:|---:|",
            (
                f"| {exploratory.floquet_step} | {exploratory.channel} | "
                f"{exploratory.candidate_count} | {exploratory.hit_count} | "
                f"{exploratory.hit_rate:.6f} | {enrich_text} |"
            ),
            "",
            "## Held-out confirmation on disjoint range (future)",
            "",
            "Held-out confirmation would require preregistering a fixed floquet phase (or rule) "
            "and testing it on a numerical range disjoint from this dataset. No such "
            "confirmatory test has been run here.",
            "",
            "## Quadruplet neighborhood (sieved candidates)",
            "",
        ]
    )
    for label, count in report.quadruplet_neighborhood.items():
        lines.append(f"- {label}: {count}")
    lines.append("")
    return "\n".join(lines)


def export_twin_prime_phase_analysis_markdown(report: TwinPrimePhaseAnalysisReport, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(format_twin_prime_phase_analysis_report(report), encoding="utf-8")
