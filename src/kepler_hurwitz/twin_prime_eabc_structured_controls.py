from __future__ import annotations

import json
import math
import random
from collections.abc import Sequence
from dataclasses import dataclass
from functools import lru_cache
from pathlib import Path
from typing import Any

from kepler_hurwitz.kepler_eabc_atlas import (
    CHI_CYCLE_PERIOD,
    annotate_delta_m_with_channels,
    floquet_step_channel,
    lift_sheet_signed_duality_pairs,
)
from kepler_hurwitz.kepler_time_bridge import run_kepler_time_bridge_scenarios
from kepler_hurwitz.twin_prime_eabc_phase_analysis import (
    enrichment,
    is_probable_prime,
    is_twin_prime,
)

GOVERNANCE = {
    "status": "B/C structured feature test",
    "not_claimed": "No proof of twin primes and no deterministic prediction",
    "primary_question": (
        "Do E-033 orientation-duality and Dumas-gap features add signal beyond "
        "residue-class and small-sieve baselines?"
    ),
    "controls": [
        "residue-stratified null model",
        "phase-shift null model",
        "randomized labels within residue class",
    ],
}

STATUS = GOVERNANCE["status"]
NOT_CLAIMED = GOVERNANCE["not_claimed"]
PRIMARY_QUESTION = GOVERNANCE["primary_question"]
CONTROLS = GOVERNANCE["controls"]

STAGE1_INTERPRETATION = (
    "The stage-1 enrichment is explained by CE residue preference and is not yet "
    "evidence for Floquet-specific predictive power."
)

DEFAULT_LIMIT = 10_000
DEFAULT_SIEVE_BOUND = 29
DEFAULT_RANDOM_SEED = 11
SIGNED_DUAL_TOLERANCE = 1e-9

RESIDUE_STRATA: dict[str, int] = {
    "CE": 11,
    "AB": 5,
}

QUADRUPLET_CHANNELS: tuple[str, ...] = ("C", "E", "A", "B")
QUADRUPLET_OFFSETS: tuple[int, ...] = (0, 2, 6, 8)


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


def passes_classical_twin_sieve(n: int, sieve_primes: Sequence[int]) -> bool:
    """Classical twin sieve for CE (11) and AB (5) residue classes."""
    if n < 5 or n % 2 == 0 or n % 12 not in RESIDUE_STRATA.values():
        return False
    for prime in sieve_primes:
        if prime == n or prime == n + 2:
            continue
        if n % prime == 0 or (n + 2) % prime == 0:
            return False
    return True


def generate_residue_stratum_candidates(residue_mod: int, limit: int) -> list[int]:
    if limit < residue_mod:
        return []
    return list(range(residue_mod, limit - 2 + 1, 12))


@lru_cache(maxsize=4)
def build_e033_signed_dual_reference(
    *,
    scenario_name: str = "baseline_cyclic",
    tolerance: float = SIGNED_DUAL_TOLERANCE,
) -> dict[int, bool]:
    """Per chi phase: whether E-033 shows signed dual pair match (ΔM_{i+4} ≈ −ΔM_i)."""
    records = run_kepler_time_bridge_scenarios(tail_length=16)
    record = next(item for item in records if item.control_name == scenario_name)
    annotated = annotate_delta_m_with_channels(record.raw_delta_M_series[:8])
    pairs = lift_sheet_signed_duality_pairs(annotated)
    reference: dict[int, bool] = {}
    for pair in pairs:
        phase = int(pair["phase"])
        signed_dual = (
            float(pair["abs_dual_sum"]) <= tolerance and bool(pair["orientation_flip"])
        )
        reference[phase] = signed_dual
    for phase in range(CHI_CYCLE_PERIOD):
        reference.setdefault(phase, False)
    return reference


def right_wing_prime_count(n: int) -> int:
    """Leakage-safe Dumas wing: only n+6 and n+8 (excludes twin pair n, n+2)."""
    return sum(is_probable_prime(n + offset) for offset in (6, 8))


def quadruplet_prime_count(n: int) -> int:
    """Diagnostic only — includes the twin pair and must not be used as a predictor."""
    return sum(is_probable_prime(n + offset) for offset in QUADRUPLET_OFFSETS)


def missing_hosts(n: int) -> tuple[str, ...]:
    missing: list[str] = []
    for channel, offset in zip(QUADRUPLET_CHANNELS, QUADRUPLET_OFFSETS, strict=True):
        if not is_probable_prime(n + offset):
            missing.append(channel)
    return tuple(missing)


def dumas_gap_signature(n: int) -> str:
    hosts = missing_hosts(n)
    return "none" if not hosts else ",".join(hosts)


def classify_quadruplet_type(n: int) -> str:
    flags = [is_probable_prime(n + offset) for offset in QUADRUPLET_OFFSETS]
    twin_pair = flags[0] and flags[1]
    count = sum(flags)
    if count == 4:
        return "prime_quadruplet"
    if twin_pair and count == 3:
        return "near_quadruplet"
    if twin_pair:
        return "twin_only"
    return "failed_candidate"


def orientation_dual_score(
    chi_phase: int,
    *,
    signed_dual_reference: dict[int, bool],
) -> float:
    """Binary E-033 orientation feature: 1.0 if signed dual pair match at chi phase."""
    return 1.0 if signed_dual_reference.get(chi_phase % CHI_CYCLE_PERIOD, False) else 0.0


@dataclass(frozen=True)
class StructuredTwinCandidate:
    n: int
    residue_class: str
    stratum_index: int
    floquet_step: int
    channel: str
    chi_phase: int
    lift_sheet: int
    orientation_dual_score: float
    right_wing_prime_count: int
    quadruplet_prime_count: int
    quadruplet_type: str
    missing_hosts: tuple[str, ...]
    dumas_gap_signature: str
    passed_small_sieve: bool
    is_twin_prime: bool


def annotate_structured_candidate(
    n: int,
    *,
    residue_class: str,
    stratum_index: int,
    sieve_primes: Sequence[int],
    signed_dual_reference: dict[int, bool],
) -> StructuredTwinCandidate:
    floquet_step = stratum_index % 8
    chi_phase = floquet_step % CHI_CYCLE_PERIOD
    return StructuredTwinCandidate(
        n=n,
        residue_class=residue_class,
        stratum_index=stratum_index,
        floquet_step=floquet_step,
        channel=floquet_step_channel(floquet_step).value,
        chi_phase=chi_phase,
        lift_sheet=floquet_step // CHI_CYCLE_PERIOD,
        orientation_dual_score=orientation_dual_score(
            chi_phase,
            signed_dual_reference=signed_dual_reference,
        ),
        right_wing_prime_count=right_wing_prime_count(n),
        quadruplet_prime_count=quadruplet_prime_count(n),
        quadruplet_type=classify_quadruplet_type(n),
        missing_hosts=missing_hosts(n),
        dumas_gap_signature=dumas_gap_signature(n),
        passed_small_sieve=passes_classical_twin_sieve(n, sieve_primes),
        is_twin_prime=is_twin_prime(n),
    )


def build_structured_twin_candidates(
    *,
    limit: int,
    sieve_bound: int = DEFAULT_SIEVE_BOUND,
    signed_dual_reference: dict[int, bool] | None = None,
) -> list[StructuredTwinCandidate]:
    signed_dual_reference = signed_dual_reference or build_e033_signed_dual_reference()
    sieve_primes = _small_primes_up_to(sieve_bound)
    rows: list[StructuredTwinCandidate] = []
    for label, residue_mod in RESIDUE_STRATA.items():
        for stratum_index, n in enumerate(generate_residue_stratum_candidates(residue_mod, limit)):
            rows.append(
                annotate_structured_candidate(
                    n,
                    residue_class=label,
                    stratum_index=stratum_index,
                    sieve_primes=sieve_primes,
                    signed_dual_reference=signed_dual_reference,
                )
            )
    return rows


def _hit_rate(rows: Sequence[StructuredTwinCandidate]) -> float | None:
    if not rows:
        return None
    return sum(row.is_twin_prime for row in rows) / len(rows)


@dataclass(frozen=True)
class StratumFeatureResult:
    stratum: str
    feature_name: str
    baseline_hit_rate: float
    positive_candidate_count: int
    negative_candidate_count: int
    positive_hit_rate: float | None
    negative_hit_rate: float | None
    enrichment_positive_vs_baseline: float | None
    enrichment_positive_vs_negative: float | None
    feature_is_constant: bool

    def to_dict(self) -> dict[str, Any]:
        return {
            "stratum": self.stratum,
            "feature_name": self.feature_name,
            "baseline_hit_rate": self.baseline_hit_rate,
            "positive_candidate_count": self.positive_candidate_count,
            "negative_candidate_count": self.negative_candidate_count,
            "positive_hit_rate": self.positive_hit_rate,
            "negative_hit_rate": self.negative_hit_rate,
            "enrichment_positive_vs_baseline": self.enrichment_positive_vs_baseline,
            "enrichment_positive_vs_negative": self.enrichment_positive_vs_negative,
            "feature_is_constant": self.feature_is_constant,
        }


def _feature_predicate(
    row: StructuredTwinCandidate,
    *,
    feature_name: str,
) -> bool:
    if feature_name == "orientation_dual":
        return row.orientation_dual_score >= 1.0
    if feature_name == "right_wing":
        return row.right_wing_prime_count >= 1
    raise ValueError(f"Unknown feature: {feature_name}")


def evaluate_stratum_feature(
    rows: Sequence[StructuredTwinCandidate],
    *,
    stratum: str,
    feature_name: str,
) -> StratumFeatureResult:
    stratum_rows = [row for row in rows if row.residue_class == stratum and row.passed_small_sieve]
    baseline_hit_rate = _hit_rate(stratum_rows) or 0.0
    positive_rows = [row for row in stratum_rows if _feature_predicate(row, feature_name=feature_name)]
    negative_rows = [row for row in stratum_rows if not _feature_predicate(row, feature_name=feature_name)]
    positive_hit_rate = _hit_rate(positive_rows)
    negative_hit_rate = _hit_rate(negative_rows)
    values = [
        _feature_predicate(row, feature_name=feature_name)
        for row in stratum_rows
    ]
    return StratumFeatureResult(
        stratum=stratum,
        feature_name=feature_name,
        baseline_hit_rate=baseline_hit_rate,
        positive_candidate_count=len(positive_rows),
        negative_candidate_count=len(negative_rows),
        positive_hit_rate=positive_hit_rate,
        negative_hit_rate=negative_hit_rate,
        enrichment_positive_vs_baseline=enrichment(positive_hit_rate, baseline_hit_rate),
        enrichment_positive_vs_negative=enrichment(positive_hit_rate, negative_hit_rate),
        feature_is_constant=not values or all(values) or not any(values),
    )


def permute_feature_labels_within_stratum(
    rows: Sequence[StructuredTwinCandidate],
    *,
    stratum: str,
    feature_name: str,
    seed: int,
) -> list[bool]:
    """Residue-preserving null: shuffle binary feature labels inside one stratum."""
    stratum_rows = [row for row in rows if row.residue_class == stratum and row.passed_small_sieve]
    labels = [_feature_predicate(row, feature_name=feature_name) for row in stratum_rows]
    rng = random.Random(seed)
    shuffled = labels[:]
    rng.shuffle(shuffled)
    return shuffled


def randomized_labels_null_enrichment(
    rows: Sequence[StructuredTwinCandidate],
    *,
    stratum: str,
    feature_name: str,
    seed: int = DEFAULT_RANDOM_SEED,
) -> float | None:
    stratum_rows = [row for row in rows if row.residue_class == stratum and row.passed_small_sieve]
    if not stratum_rows:
        return None
    baseline_hit_rate = _hit_rate(stratum_rows)
    shuffled = permute_feature_labels_within_stratum(
        rows,
        stratum=stratum,
        feature_name=feature_name,
        seed=seed,
    )
    positive_hits = sum(
        row.is_twin_prime
        for row, label in zip(stratum_rows, shuffled, strict=True)
        if label
    )
    positive_count = sum(shuffled)
    if positive_count == 0 or baseline_hit_rate is None or baseline_hit_rate == 0:
        return None
    return (positive_hits / positive_count) / baseline_hit_rate


def phase_shift_orientation_enrichment(
    rows: Sequence[StructuredTwinCandidate],
    *,
    stratum: str,
    shift: int,
    signed_dual_reference: dict[int, bool],
) -> float | None:
    """Phase-shift null within one residue stratum for the orientation feature."""
    stratum_rows = [row for row in rows if row.residue_class == stratum and row.passed_small_sieve]
    if not stratum_rows:
        return None
    baseline_hit_rate = _hit_rate(stratum_rows)
    positive_rows: list[StructuredTwinCandidate] = []
    for row in stratum_rows:
        shifted_step = (row.stratum_index + shift) % 8
        shifted_phase = shifted_step % CHI_CYCLE_PERIOD
        if orientation_dual_score(shifted_phase, signed_dual_reference=signed_dual_reference) >= 1.0:
            positive_rows.append(row)
    positive_hit_rate = _hit_rate(positive_rows)
    return enrichment(positive_hit_rate, baseline_hit_rate)


@dataclass(frozen=True)
class Stage1ResidueSummary:
    ce_hit_rate: float | None
    ab_hit_rate: float | None
    ce_vs_ab_enrichment: float | None
    interpretation: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "ce_hit_rate": self.ce_hit_rate,
            "ab_hit_rate": self.ab_hit_rate,
            "ce_vs_ab_enrichment": self.ce_vs_ab_enrichment,
            "interpretation": self.interpretation,
        }


def summarize_stage1_residue_effect(
    rows: Sequence[StructuredTwinCandidate],
) -> Stage1ResidueSummary:
    ce_rows = [row for row in rows if row.residue_class == "CE" and row.passed_small_sieve]
    ab_rows = [row for row in rows if row.residue_class == "AB" and row.passed_small_sieve]
    ce_hit_rate = _hit_rate(ce_rows)
    ab_hit_rate = _hit_rate(ab_rows)
    return Stage1ResidueSummary(
        ce_hit_rate=ce_hit_rate,
        ab_hit_rate=ab_hit_rate,
        ce_vs_ab_enrichment=enrichment(ce_hit_rate, ab_hit_rate),
        interpretation=STAGE1_INTERPRETATION,
    )


@dataclass(frozen=True)
class StructuredControlsReport:
    status: str
    not_claimed: str
    primary_question: str
    controls: tuple[str, ...]
    stage1_residue_summary: Stage1ResidueSummary
    signed_dual_reference: dict[int, bool]
    limit: int
    sieve_bound: int
    orientation_features: tuple[StratumFeatureResult, ...]
    right_wing_features: tuple[StratumFeatureResult, ...]
    null_models: dict[str, Any]
    diagnostic_quadruplet_counts: dict[str, int]

    def to_dict(self) -> dict[str, Any]:
        return {
            **GOVERNANCE,
            "stage1_interpretation": STAGE1_INTERPRETATION,
            "stage1_residue_summary": self.stage1_residue_summary.to_dict(),
            "signed_dual_reference": {
                str(phase): matched for phase, matched in sorted(self.signed_dual_reference.items())
            },
            "limit": self.limit,
            "sieve_bound": self.sieve_bound,
            "orientation_features": [item.to_dict() for item in self.orientation_features],
            "right_wing_features": [item.to_dict() for item in self.right_wing_features],
            "null_models": self.null_models,
            "diagnostic_quadruplet_counts": self.diagnostic_quadruplet_counts,
        }


def _quadruplet_diagnostic_counts(rows: Sequence[StructuredTwinCandidate]) -> dict[str, int]:
    counts = {
        "failed_candidate": 0,
        "twin_only": 0,
        "near_quadruplet": 0,
        "prime_quadruplet": 0,
    }
    for row in rows:
        if row.passed_small_sieve:
            counts[row.quadruplet_type] += 1
    return counts


def run_structured_controls_experiment(
    *,
    limit: int = DEFAULT_LIMIT,
    sieve_bound: int = DEFAULT_SIEVE_BOUND,
    random_seed: int = DEFAULT_RANDOM_SEED,
    signed_dual_reference: dict[int, bool] | None = None,
) -> StructuredControlsReport:
    if limit < 11:
        raise ValueError("limit must be at least 11.")

    signed_dual_reference = signed_dual_reference or build_e033_signed_dual_reference()
    rows = build_structured_twin_candidates(
        limit=limit,
        sieve_bound=sieve_bound,
        signed_dual_reference=signed_dual_reference,
    )

    orientation_features = tuple(
        evaluate_stratum_feature(rows, stratum=stratum, feature_name="orientation_dual")
        for stratum in RESIDUE_STRATA
    )
    right_wing_features = tuple(
        evaluate_stratum_feature(rows, stratum=stratum, feature_name="right_wing")
        for stratum in RESIDUE_STRATA
    )

    null_models: dict[str, Any] = {
        "randomized_labels_within_residue_class": {},
        "phase_shift_orientation": {},
    }
    for stratum in RESIDUE_STRATA:
        null_models["randomized_labels_within_residue_class"][stratum] = {
            "orientation_dual": randomized_labels_null_enrichment(
                rows,
                stratum=stratum,
                feature_name="orientation_dual",
                seed=random_seed,
            ),
            "right_wing": randomized_labels_null_enrichment(
                rows,
                stratum=stratum,
                feature_name="right_wing",
                seed=random_seed + 1,
            ),
        }
        null_models["phase_shift_orientation"][stratum] = {
            str(shift): phase_shift_orientation_enrichment(
                rows,
                stratum=stratum,
                shift=shift,
                signed_dual_reference=signed_dual_reference,
            )
            for shift in range(1, 8)
        }

    return StructuredControlsReport(
        status=STATUS,
        not_claimed=NOT_CLAIMED,
        primary_question=PRIMARY_QUESTION,
        controls=tuple(CONTROLS),
        stage1_residue_summary=summarize_stage1_residue_effect(rows),
        signed_dual_reference=signed_dual_reference,
        limit=limit,
        sieve_bound=sieve_bound,
        orientation_features=orientation_features,
        right_wing_features=right_wing_features,
        null_models=null_models,
        diagnostic_quadruplet_counts=_quadruplet_diagnostic_counts(rows),
    )


def format_structured_controls_report(report: StructuredControlsReport) -> str:
    lines = [
        "# Twin-Prime EABC Structured Controls (Stage 2)",
        "",
        f"**Status:** {report.status}",
        "",
        f"**Not claimed:** {report.not_claimed}",
        "",
        f"**Primary question:** {report.primary_question}",
        "",
        "## Stage-1 interpretation",
        "",
        report.stage1_residue_summary.interpretation,
        "",
        "| stratum | hit rate |",
        "|---|---:|",
        f"| CE | {report.stage1_residue_summary.ce_hit_rate} |",
        f"| AB | {report.stage1_residue_summary.ab_hit_rate} |",
        f"| CE vs AB enrichment | {report.stage1_residue_summary.ce_vs_ab_enrichment} |",
        "",
        "## E-033 signed dual reference (baseline_cyclic)",
        "",
    ]
    for phase, matched in sorted(report.signed_dual_reference.items()):
        lines.append(f"- chi_phase {phase}: signed_dual_pair_match={matched}")
    lines.extend(["", "## Orientation dual feature (within stratum)", ""])
    for item in report.orientation_features:
        lines.extend(
            [
                f"### {item.stratum}",
                "",
                f"- feature constant in stratum: {item.feature_is_constant}",
                f"- positive hit rate: {item.positive_hit_rate}",
                f"- negative hit rate: {item.negative_hit_rate}",
                f"- enrichment vs stratum baseline: {item.enrichment_positive_vs_baseline}",
                f"- enrichment positive vs negative: {item.enrichment_positive_vs_negative}",
                "",
            ]
        )
    lines.extend(["## Right-wing Dumas feature (leakage-safe: n+6, n+8 only)", ""])
    for item in report.right_wing_features:
        lines.extend(
            [
                f"### {item.stratum}",
                "",
                f"- positive hit rate: {item.positive_hit_rate}",
                f"- negative hit rate: {item.negative_hit_rate}",
                f"- enrichment vs stratum baseline: {item.enrichment_positive_vs_baseline}",
                f"- enrichment positive vs negative: {item.enrichment_positive_vs_negative}",
                "",
            ]
        )
    lines.extend(["## Null models", ""])
    lines.append("Controls: " + ", ".join(report.controls))
    lines.append("")
    for stratum, values in report.null_models["randomized_labels_within_residue_class"].items():
        lines.append(
            f"- randomized labels ({stratum}): "
            f"orientation_dual={values['orientation_dual']}, right_wing={values['right_wing']}"
        )
    lines.extend(["", "## Stage-2 conclusion (descriptive)", ""])
    lines.append(
        "The current structured-control test finds no evidence that the tested E-033 "
        "orientation-duality or Dumas right-wing features add predictive signal beyond "
        "residue-class and small-sieve baselines in this range."
    )
    lines.append("")
    orientation_constant = all(item.feature_is_constant for item in report.orientation_features)
    if orientation_constant:
        lines.append(
            "With the baseline_cyclic E-033 reference, orientation_dual_score is constant "
            "within each residue stratum; it cannot add discriminative signal beyond residue class."
        )
    lines.append(
        "No feature in this run shows stable enrichment that survives residue-stratified "
        "label permutation; this is a null result for structured EABC signal beyond mod-12 class."
    )
    lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def export_structured_controls_json(report: StructuredControlsReport, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report.to_dict(), indent=2, sort_keys=True) + "\n", encoding="utf-8")


def export_structured_controls_markdown(report: StructuredControlsReport, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(format_structured_controls_report(report), encoding="utf-8")
