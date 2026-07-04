from __future__ import annotations

import json
from collections.abc import Sequence
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.twin_prime_eabc_structured_controls import (
    DEFAULT_RANDOM_SEED,
    RESIDUE_STRATA,
    STAGE1_INTERPRETATION,
    StructuredTwinCandidate,
    build_e033_signed_dual_reference,
    build_structured_twin_candidates,
    evaluate_stratum_feature,
    randomized_labels_null_enrichment,
    summarize_stage1_residue_effect,
)

GOVERNANCE = {
    "status": "B scale robustness check",
    "not_claimed": (
        "No proof of twin primes, no deterministic prediction, and no optimized predictor."
    ),
    "primary_question": (
        "Does the negative structured-control result remain stable across larger limits "
        "and sieve bounds?"
    ),
    "inherits_from": "E-051 structured controls for twin-prime EABC analysis",
    "tested_limits": [10_000, 100_000, 1_000_000],
    "tested_sieve_bounds": [97, 997],
}

STATUS = GOVERNANCE["status"]
NOT_CLAIMED = GOVERNANCE["not_claimed"]
PRIMARY_QUESTION = GOVERNANCE["primary_question"]
INHERITS_FROM = GOVERNANCE["inherits_from"]

DEFAULT_LIMITS: tuple[int, ...] = (10_000, 100_000, 1_000_000)
DEFAULT_SIEVE_BOUNDS: tuple[int, ...] = (97, 997)
OPTIONAL_LIMIT_10M = 10_000_000

REPORT_HEADER = (
    "This scale sweep tests whether the negative E-051 structured-control result "
    "remains stable across larger numerical ranges and sieve bounds. It does not "
    "introduce new features and does not claim predictive power."
)

SCALE_SWEEP_CORE_SENTENCE = (
    "The scale sweep confirms that the negative E-051 structured-control result is "
    "robust across the tested limits and sieve bounds. Isolated positive deviations "
    "are not scale-stable under the preregistered decision rule."
)

DECISION_RULE = (
    "A feature is considered scale-stable only if its observed enrichment exceeds "
    "the residue-stratified null enrichment at all tested limits for the same "
    "sieve_bound, with the same direction of effect."
)

HELD_OUT_CAUTION = (
    "This sweep is descriptive and does not establish predictive power. Any candidate "
    "rule suggested by the sweep must be tested on a disjoint held-out range."
)
WARNING = HELD_OUT_CAUTION

FEATURE_KEYS = (
    "orientation_dual",
    "right_wing_ge_1",
    "right_wing_eq_2",
)

FEATURE_TO_PREDICATE_NAME = {
    "orientation_dual": "orientation_dual",
    "right_wing_ge_1": "right_wing",
    "right_wing_eq_2": "right_wing_eq_2",
}


def build_scale_sweep_grid(
    *,
    limits: Sequence[int] | None = None,
    sieve_bounds: Sequence[int] | None = None,
) -> list[tuple[int, int]]:
    limits = tuple(limits or DEFAULT_LIMITS)
    sieve_bounds = tuple(sieve_bounds or DEFAULT_SIEVE_BOUNDS)
    return [(limit, sieve_bound) for limit in limits for sieve_bound in sieve_bounds]


def _feature_delta_vs_null(
    rows: list[StructuredTwinCandidate],
    *,
    feature_name: str,
    random_seed: int,
) -> float | None:
    """Pooled mean of (observed enrichment − null enrichment) across CE/AB strata."""
    deltas: list[float] = []
    for stratum in RESIDUE_STRATA:
        result = evaluate_stratum_feature(rows, stratum=stratum, feature_name=feature_name)
        null_enrichment = randomized_labels_null_enrichment(
            rows,
            stratum=stratum,
            feature_name=feature_name,
            seed=random_seed,
        )
        observed = result.enrichment_positive_vs_baseline
        if observed is None or null_enrichment is None:
            continue
        deltas.append(observed - null_enrichment)
    if not deltas:
        return None
    return sum(deltas) / len(deltas)


def _row_conclusion(
    *,
    orientation_dual_delta_vs_null: float | None,
    right_wing_ge_1_delta_vs_null: float | None,
    right_wing_eq_2_delta_vs_null: float | None,
) -> str:
    deltas = (
        orientation_dual_delta_vs_null,
        right_wing_ge_1_delta_vs_null,
        right_wing_eq_2_delta_vs_null,
    )
    if all(delta is None for delta in deltas):
        return "No evaluable feature deltas at this scale."
    if all(delta is None or delta <= 0.0 for delta in deltas):
        return (
            "No feature delta exceeds the residue-stratified null at this limit and sieve bound."
        )
    return "At least one feature delta exceeds null; inspect per-feature values before any follow-up."


@dataclass(frozen=True)
class ScaleSweepRow:
    limit: int
    sieve_bound: int
    candidate_count: int
    sieved_candidate_count: int
    baseline_hit_rate: float | None
    ce_hit_rate: float | None
    ab_hit_rate: float | None
    ce_ab_lift: float | None
    orientation_dual_delta_vs_null: float | None
    right_wing_ge_1_delta_vs_null: float | None
    right_wing_eq_2_delta_vs_null: float | None
    conclusion: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "limit": self.limit,
            "sieve_bound": self.sieve_bound,
            "candidate_count": self.candidate_count,
            "sieved_candidate_count": self.sieved_candidate_count,
            "baseline_hit_rate": self.baseline_hit_rate,
            "ce_hit_rate": self.ce_hit_rate,
            "ab_hit_rate": self.ab_hit_rate,
            "ce_ab_lift": self.ce_ab_lift,
            "orientation_dual_delta_vs_null": self.orientation_dual_delta_vs_null,
            "right_wing_ge_1_delta_vs_null": self.right_wing_ge_1_delta_vs_null,
            "right_wing_eq_2_delta_vs_null": self.right_wing_eq_2_delta_vs_null,
            "conclusion": self.conclusion,
        }


def _baseline_hit_rate(rows: list[StructuredTwinCandidate]) -> float | None:
    sieved = [row for row in rows if row.passed_small_sieve]
    if not sieved:
        return None
    return sum(row.is_twin_prime for row in sieved) / len(sieved)


def run_single_sweep_cell(
    *,
    limit: int,
    sieve_bound: int,
    signed_dual_reference: dict[int, bool],
    random_seed: int = DEFAULT_RANDOM_SEED,
) -> ScaleSweepRow:
    rows = build_structured_twin_candidates(
        limit=limit,
        sieve_bound=sieve_bound,
        signed_dual_reference=signed_dual_reference,
    )
    stage1 = summarize_stage1_residue_effect(rows)
    orientation_delta = _feature_delta_vs_null(
        rows,
        feature_name="orientation_dual",
        random_seed=random_seed,
    )
    right_wing_ge_1_delta = _feature_delta_vs_null(
        rows,
        feature_name="right_wing",
        random_seed=random_seed + 1,
    )
    right_wing_eq_2_delta = _feature_delta_vs_null(
        rows,
        feature_name="right_wing_eq_2",
        random_seed=random_seed + 2,
    )
    return ScaleSweepRow(
        limit=limit,
        sieve_bound=sieve_bound,
        candidate_count=len(rows),
        sieved_candidate_count=sum(row.passed_small_sieve for row in rows),
        baseline_hit_rate=_baseline_hit_rate(rows),
        ce_hit_rate=stage1.ce_hit_rate,
        ab_hit_rate=stage1.ab_hit_rate,
        ce_ab_lift=stage1.ce_vs_ab_enrichment,
        orientation_dual_delta_vs_null=orientation_delta,
        right_wing_ge_1_delta_vs_null=right_wing_ge_1_delta,
        right_wing_eq_2_delta_vs_null=right_wing_eq_2_delta,
        conclusion=_row_conclusion(
            orientation_dual_delta_vs_null=orientation_delta,
            right_wing_ge_1_delta_vs_null=right_wing_ge_1_delta,
            right_wing_eq_2_delta_vs_null=right_wing_eq_2_delta,
        ),
    )


def _feature_scale_stable(
    sweep_rows: tuple[ScaleSweepRow, ...],
    *,
    sieve_bounds: Sequence[int],
    sieve_bound: int,
    delta_attr: str,
) -> bool:
    rows_for_bound = [row for row in sweep_rows if row.sieve_bound == sieve_bound]
    if not rows_for_bound:
        return False
    for row in rows_for_bound:
        delta = getattr(row, delta_attr)
        if delta is None or delta <= 0.0:
            return False
    return True


def _summarize_feature(
    rows: tuple[ScaleSweepRow, ...],
    *,
    sieve_bounds: Sequence[int],
    delta_attr: str,
) -> str:
    stable_bounds = [
        sieve_bound
        for sieve_bound in sieve_bounds
        if _feature_scale_stable(
            rows,
            sieve_bounds=sieve_bounds,
            sieve_bound=sieve_bound,
            delta_attr=delta_attr,
        )
    ]
    if stable_bounds:
        return f"scale-stable above null for sieve_bounds={stable_bounds}"
    deltas = [getattr(row, delta_attr) for row in rows]
    formatted = ", ".join(f"{delta:.4f}" if delta is not None else "null" for delta in deltas)
    return f"not scale-stable; deltas={formatted}"


def run_scale_sweep(
    *,
    limits: Sequence[int] | None = None,
    sieve_bounds: Sequence[int] | None = None,
    random_seed: int = DEFAULT_RANDOM_SEED,
    signed_dual_reference: dict[int, bool] | None = None,
) -> dict[str, Any]:
    limits_tuple = tuple(limits or DEFAULT_LIMITS)
    sieve_bounds_tuple = tuple(sieve_bounds or DEFAULT_SIEVE_BOUNDS)
    if any(limit < 11 for limit in limits_tuple):
        raise ValueError("All limits must be at least 11.")

    signed_dual_reference = signed_dual_reference or build_e033_signed_dual_reference()
    sweep_rows: list[ScaleSweepRow] = []
    for limit, sieve_bound in build_scale_sweep_grid(
        limits=limits_tuple,
        sieve_bounds=sieve_bounds_tuple,
    ):
        sweep_rows.append(
            run_single_sweep_cell(
                limit=limit,
                sieve_bound=sieve_bound,
                signed_dual_reference=signed_dual_reference,
                random_seed=random_seed,
            )
        )

    rows_tuple = tuple(sweep_rows)
    stage2_signal_summary = {
        "orientation_dual": _summarize_feature(
            rows_tuple,
            sieve_bounds=sieve_bounds_tuple,
            delta_attr="orientation_dual_delta_vs_null",
        ),
        "right_wing_prime_count_ge_1": _summarize_feature(
            rows_tuple,
            sieve_bounds=sieve_bounds_tuple,
            delta_attr="right_wing_ge_1_delta_vs_null",
        ),
        "right_wing_prime_count_eq_2": _summarize_feature(
            rows_tuple,
            sieve_bounds=sieve_bounds_tuple,
            delta_attr="right_wing_eq_2_delta_vs_null",
        ),
    }

    any_stable = any(
        summary.startswith("scale-stable above null")
        for summary in stage2_signal_summary.values()
    )
    if any_stable:
        overall = (
            "At least one feature appears scale-stable under the pre-registered rule; "
            "held-out confirmation on a disjoint range would still be required."
        )
    else:
        overall = (
            "The negative E-051 structured-control result remains stable across tested "
            "limits and sieve bounds: no feature consistently exceeds residue-stratified "
            "null enrichment."
        )

    return {
        **GOVERNANCE,
        "tested_limits": list(limits_tuple),
        "tested_sieve_bounds": list(sieve_bounds_tuple),
        "stage1_interpretation": STAGE1_INTERPRETATION,
        "decision_rule": DECISION_RULE,
        "warning": WARNING,
        "sweep_rows": [row.to_dict() for row in sweep_rows],
        "stage2_signal_summary": stage2_signal_summary,
        "conclusion": overall,
    }


def format_scale_sweep_report(result: dict[str, Any]) -> str:
    lines = [
        "# Twin-Prime EABC Scale Sweep (E-051 Robustness)",
        "",
        REPORT_HEADER,
        "",
        SCALE_SWEEP_CORE_SENTENCE,
        "",
        f"**Status:** {result['status']}",
        "",
        f"**Not claimed:** {result['not_claimed']}",
        "",
        f"**Primary question:** {result['primary_question']}",
        "",
        f"**Inherits from:** {result['inherits_from']}",
        "",
        f"**Decision rule:** {result['decision_rule']}",
        "",
        f"**Warning:** {result['warning']}",
        "",
        "## Sweep grid",
        "",
        f"- tested_limits: {result['tested_limits']}",
        f"- tested_sieve_bounds: {result['tested_sieve_bounds']}",
        "",
        "## Stage-1 interpretation (inherited)",
        "",
        result["stage1_interpretation"],
        "",
        "## Sweep rows",
        "",
        "| limit | B | candidates | sieved | baseline | CE | AB | CE/AB | orient Δnull | wing≥1 Δnull | wing=2 Δnull |",
        "|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|",
    ]
    for row in result["sweep_rows"]:
        baseline = row["baseline_hit_rate"]
        ce = row["ce_hit_rate"]
        ab = row["ab_hit_rate"]
        lift = row["ce_ab_lift"]
        lines.append(
            f"| {row['limit']} | {row['sieve_bound']} | {row['candidate_count']} | "
            f"{row['sieved_candidate_count']} | "
            f"{baseline:.6f} | {ce:.6f} | {ab:.6f} | {lift:.6f} | "
            f"{row['orientation_dual_delta_vs_null']} | {row['right_wing_ge_1_delta_vs_null']} | "
            f"{row['right_wing_eq_2_delta_vs_null']} |"
            if all(value is not None for value in (baseline, ce, ab, lift))
            else (
                f"| {row['limit']} | {row['sieve_bound']} | {row['candidate_count']} | "
                f"{row['sieved_candidate_count']} | {baseline} | {ce} | {ab} | {lift} | "
                f"{row['orientation_dual_delta_vs_null']} | {row['right_wing_ge_1_delta_vs_null']} | "
                f"{row['right_wing_eq_2_delta_vs_null']} |"
            )
        )
    lines.extend(
        [
            "",
            "## Stage-2 signal summary",
            "",
        ]
    )
    for feature, summary in result["stage2_signal_summary"].items():
        lines.append(f"- **{feature}:** {summary}")
    lines.extend(["", "## Overall conclusion", "", result["conclusion"], ""])
    return "\n".join(lines)


def export_scale_sweep_json(result: dict[str, Any], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def export_scale_sweep_markdown(result: dict[str, Any], path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(format_scale_sweep_report(result), encoding="utf-8")
