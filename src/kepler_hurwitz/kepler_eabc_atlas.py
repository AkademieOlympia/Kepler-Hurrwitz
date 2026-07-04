from __future__ import annotations

import json
import statistics
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Any, Mapping, Sequence

from kepler_hurwitz.kepler_time_bridge import KeplerTimeBridgeRecord

FLOQUET_TAIL_PERIOD_INTERFACE = 8
CHI_CYCLE_PERIOD = 4

ALIGNMENT_STATUS = "B descriptive statistics only"
ALIGNMENT_CLAIM = (
    "The alignment report measures whether observed delta-M tails are numerically "
    "compatible with the formal 2x4 channel lift indexing."
)
ALIGNMENT_NOT_CLAIMED = (
    "The channel lift does not generate the delta-M spectrum; delta-M values are not "
    "proven to realize the channel projection."
)

SIGNED_DUALITY_STATUS = "B descriptive statistics only"
SIGNED_DUALITY_CLAIM = (
    "The signed sheet-lift diagnostic checks whether the second Floquet sheet is "
    "numerically compatible with an orientation-reversed copy of the first sheet."
)
SIGNED_DUALITY_NOT_CLAIMED = (
    "The chi-lift does not generate the delta-M spectrum; orientation compatibility "
    "does not prove causal channel realization."
)

# Matches Lean `EABCChronology.chi`: E -> A -> C -> B -> E.
CHI_CYCLE_CHANNELS: tuple[str, ...] = ("E", "A", "C", "B")


class EABCChannel(str, Enum):
    E = "E"
    A = "A"
    C = "C"
    B = "B"


class PhiFiber(str, Enum):
    SCALE = "scale"
    ECCENTRICITY = "eccentricity"
    IN_PLANE_ROTATION = "inPlaneRotation"
    AUXILIARY = "auxiliary"
    PHASE_TIME = "phaseTime"


# Mirrors Lean `phiCoordinateFiber` in KeplerEABCAtlas.lean.
PHI_COORDINATE_FIBERS: tuple[PhiFiber, ...] = (
    PhiFiber.SCALE,
    PhiFiber.ECCENTRICITY,
    PhiFiber.ECCENTRICITY,
    PhiFiber.IN_PLANE_ROTATION,
    PhiFiber.IN_PLANE_ROTATION,
    PhiFiber.AUXILIARY,
    PhiFiber.AUXILIARY,
    PhiFiber.PHASE_TIME,
)


def floquet_step_channel(step: int) -> EABCChannel:
    """Twofold lift of the chi-cycle E -> A -> C -> B (Lean `floquetStepChannel`)."""
    if step < 0:
        raise ValueError("step must be non-negative.")
    return EABCChannel(CHI_CYCLE_CHANNELS[step % CHI_CYCLE_PERIOD])


def floquet_channel_table(*, period: int = FLOQUET_TAIL_PERIOD_INTERFACE) -> list[dict[str, int | str]]:
    if period < 1:
        raise ValueError("period must be positive.")
    return [
        {
            "step": index,
            "channel": floquet_step_channel(index).value,
            "chi_phase": index % CHI_CYCLE_PERIOD,
            "lift_sheet": index // CHI_CYCLE_PERIOD,
        }
        for index in range(period)
    ]


def annotate_delta_m_with_channels(delta_m_values: Sequence[float]) -> list[dict[str, int | float | str]]:
    """Annotate a delta-M sequence with the formal 2x4 chi-lift (no causal claim)."""
    return [
        {
            "step": index,
            "delta_m": delta_m,
            "channel": floquet_step_channel(index).value,
            "chi_phase": index % CHI_CYCLE_PERIOD,
            "lift_sheet": index // CHI_CYCLE_PERIOD,
        }
        for index, delta_m in enumerate(delta_m_values)
    ]


def annotate_kepler_time_bridge_record(record: KeplerTimeBridgeRecord) -> list[dict[str, int | float | str]]:
    """Attach formal channel labels to an E-033 bridge record's delta-M tail."""
    return annotate_delta_m_with_channels(record.raw_delta_M_series)


def _sign_pattern(values: Sequence[float], *, tol: float = 1e-12) -> dict[str, int | str]:
    signs: list[str] = []
    for value in values:
        if abs(value) <= tol:
            signs.append("0")
        elif value > 0:
            signs.append("+")
        else:
            signs.append("-")
    return {
        "signs": "".join(signs),
        "positive_count": signs.count("+"),
        "negative_count": signs.count("-"),
        "zero_count": signs.count("0"),
    }


def _channel_stats(values: Sequence[float]) -> dict[str, float | int | str]:
    if not values:
        return {
            "count": 0,
            "mean_delta_m": 0.0,
            "std_delta_m": 0.0,
            "min_delta_m": 0.0,
            "max_delta_m": 0.0,
            "sign_pattern": _sign_pattern(values),
        }
    return {
        "count": len(values),
        "mean_delta_m": sum(values) / len(values),
        "std_delta_m": statistics.pstdev(values) if len(values) > 1 else 0.0,
        "min_delta_m": min(values),
        "max_delta_m": max(values),
        "sign_pattern": _sign_pattern(values),
    }


def channel_alignment_summary(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> dict[str, dict[str, float | int | str]]:
    """Descriptive delta-M statistics grouped by formal channel label."""
    by_channel: dict[str, list[float]] = {}
    for row in annotated_rows:
        channel = str(row["channel"])
        by_channel.setdefault(channel, []).append(float(row["delta_m"]))
    return {channel: _channel_stats(values) for channel, values in sorted(by_channel.items())}


def lift_sheet_pair_differences(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> list[dict[str, int | float | str]]:
    """Compare delta-M at chi phase i on lift sheet 0 vs sheet 1 (steps i and i+4)."""
    by_step = {int(row["step"]): row for row in annotated_rows}
    pairs: list[dict[str, int | float | str]] = []
    for phase in range(CHI_CYCLE_PERIOD):
        first = by_step.get(phase)
        second = by_step.get(phase + CHI_CYCLE_PERIOD)
        if first is None or second is None:
            continue
        delta_sheet0 = float(first["delta_m"])
        delta_sheet1 = float(second["delta_m"])
        pairs.append(
            {
                "phase": phase,
                "channel": str(first["channel"]),
                "delta_m_sheet0": delta_sheet0,
                "delta_m_sheet1": delta_sheet1,
                "signed_difference": delta_sheet1 - delta_sheet0,
                "abs_difference": abs(delta_sheet1 - delta_sheet0),
            }
        )
    return pairs


def lift_sheet_signed_duality_pairs(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> list[dict[str, int | float | str | bool]]:
    """Per chi phase: test whether sheet 1 is an orientation-reversed lift of sheet 0."""
    enriched: list[dict[str, int | float | str | bool]] = []
    for pair in lift_sheet_pair_differences(annotated_rows):
        delta_sheet0 = float(pair["delta_m_sheet0"])
        delta_sheet1 = float(pair["delta_m_sheet1"])
        signed_dual_sum = delta_sheet0 + delta_sheet1
        enriched.append(
            {
                **pair,
                "signed_dual_sum": signed_dual_sum,
                "abs_dual_sum": abs(signed_dual_sum),
                "same_magnitude_difference": abs(abs(delta_sheet0) - abs(delta_sheet1)),
                "orientation_flip": delta_sheet0 * delta_sheet1 < 0,
            }
        )
    return enriched


def lift_sheet_signed_duality_summary(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> dict[str, Any]:
    """Aggregate signed dual-sheet diagnostics for one annotated delta-M tail."""
    pairs = lift_sheet_signed_duality_pairs(annotated_rows)
    if not pairs:
        return {
            "status": SIGNED_DUALITY_STATUS,
            "not_claimed": SIGNED_DUALITY_NOT_CLAIMED,
            "pairs": [],
            "max_abs_dual_sum": None,
            "mean_abs_dual_sum": None,
            "max_magnitude_difference": None,
            "all_orientation_flips": None,
        }

    abs_dual_sums = [float(pair["abs_dual_sum"]) for pair in pairs]
    magnitude_differences = [float(pair["same_magnitude_difference"]) for pair in pairs]
    orientation_flips = [bool(pair["orientation_flip"]) for pair in pairs]
    return {
        "status": SIGNED_DUALITY_STATUS,
        "not_claimed": SIGNED_DUALITY_NOT_CLAIMED,
        "pairs": pairs,
        "max_abs_dual_sum": max(abs_dual_sums),
        "mean_abs_dual_sum": sum(abs_dual_sums) / len(abs_dual_sums),
        "max_magnitude_difference": max(magnitude_differences),
        "all_orientation_flips": all(orientation_flips),
    }


def max_lift_sheet_abs_difference(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> float | None:
    """Maximum |ΔM_{i+4} − ΔM_i| across chi phases (None if no complete pairs)."""
    pairs = lift_sheet_pair_differences(annotated_rows)
    if not pairs:
        return None
    return max(float(pair["abs_difference"]) for pair in pairs)


def summarize_annotated_delta_m(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> dict[str, Any]:
    """Combined [B/C] alignment summary for one annotated delta-M tail."""
    pairs = lift_sheet_pair_differences(annotated_rows)
    signed_duality = lift_sheet_signed_duality_summary(annotated_rows)
    return {
        "status": "B/C alignment only",
        "not_claimed": (
            "Delta-M values are not proven to realize or be generated by the channel projection"
        ),
        "channel_alignment_summary": channel_alignment_summary(annotated_rows),
        "lift_sheet_pair_differences": pairs,
        "max_lift_sheet_abs_difference": max_lift_sheet_abs_difference(annotated_rows),
        "signed_sheet_lift_diagnostic": signed_duality,
        "max_abs_dual_sum": signed_duality["max_abs_dual_sum"],
        "mean_abs_dual_sum": signed_duality["mean_abs_dual_sum"],
        "max_magnitude_difference": signed_duality["max_magnitude_difference"],
        "all_orientation_flips": signed_duality["all_orientation_flips"],
    }


def build_scenario_alignment_report(
    annotated_rows: Sequence[Mapping[str, int | float | str]],
) -> dict[str, Any]:
    """Neutral compatibility statistics for one annotated delta-M tail."""
    return summarize_annotated_delta_m(annotated_rows)


@dataclass(frozen=True)
class FloquetAnnotationExport:
    status: str
    claim: str
    not_claimed: str
    alignment_status: str
    alignment_claim: str
    alignment_not_claimed: str
    cycle: tuple[str, ...]
    chi_cycle_period: int
    floquet_tail_period_interface: int
    formal_lift_table: tuple[dict[str, int | str], ...]
    scenarios: tuple[dict[str, Any], ...]

    def to_dict(self) -> dict[str, Any]:
        return {
            "status": self.status,
            "claim": self.claim,
            "not_claimed": self.not_claimed,
            "alignment_status": self.alignment_status,
            "alignment_claim": self.alignment_claim,
            "alignment_not_claimed": self.alignment_not_claimed,
            "cycle": list(self.cycle),
            "chi_cycle_period": self.chi_cycle_period,
            "floquet_tail_period_interface": self.floquet_tail_period_interface,
            "formal_lift_table": list(self.formal_lift_table),
            "scenarios": list(self.scenarios),
        }


def format_alignment_markdown_report(export: FloquetAnnotationExport) -> str:
    """Human-readable E-033 alignment summary (descriptive only)."""
    lines = [
        "# E-033 Floquet Channel Alignment Report",
        "",
        f"**Status:** {export.alignment_status}",
        "",
        export.alignment_claim,
        "",
        f"**Not claimed:** {export.alignment_not_claimed}",
        "",
        SIGNED_DUALITY_CLAIM,
        "",
        f"**Signed duality not claimed:** {SIGNED_DUALITY_NOT_CLAIMED}",
        "",
        "## Formal 2x4 lift cycle",
        "",
        " -> ".join(export.cycle),
        "",
        "## Scenario summaries",
        "",
    ]
    for scenario in export.scenarios:
        alignment = scenario["alignment_summary"]
        pairs = alignment["lift_sheet_pair_differences"]
        duality = alignment["signed_sheet_lift_diagnostic"]
        abs_differences = [float(pair["abs_difference"]) for pair in pairs]
        mean_abs_difference = (
            sum(abs_differences) / len(abs_differences) if abs_differences else None
        )
        lines.extend(
            [
                f"### {scenario['control_name']}",
                "",
                f"- status: {alignment['status']}",
                f"- not_claimed: {alignment['not_claimed']}",
                f"- M_tail_period: {scenario['M_tail_period']}",
                f"- unique_delta_M_count: {scenario['unique_delta_M_count']}",
                f"- max_lift_sheet_abs_difference: "
                f"{alignment['max_lift_sheet_abs_difference']}",
                f"- mean lift-sheet abs difference: {mean_abs_difference}",
                f"- max_abs_dual_sum: {alignment['max_abs_dual_sum']}",
                f"- mean_abs_dual_sum: {alignment['mean_abs_dual_sum']}",
                f"- max_magnitude_difference: {alignment['max_magnitude_difference']}",
                f"- all_orientation_flips: {alignment['all_orientation_flips']}",
                "",
                "#### Per-channel delta-M statistics",
                "",
                "| channel | count | mean | std | min | max | signs |",
                "|---|---:|---:|---:|---:|---:|---|",
            ]
        )
        for channel, stats in alignment["channel_alignment_summary"].items():
            sign_pattern = stats["sign_pattern"]
            lines.append(
                f"| {channel} | {stats['count']} | {stats['mean_delta_m']:.6f} | "
                f"{stats['std_delta_m']:.6f} | {stats['min_delta_m']:.6f} | "
                f"{stats['max_delta_m']:.6f} | {sign_pattern['signs']} |"
            )
        lines.extend(["", "#### Lift sheet pairs (step i vs i+4)", ""])
        lines.extend(
            [
                "| phase | channel | sheet0 | sheet1 | abs diff |",
                "|---:|---|---:|---:|---:|",
            ]
        )
        for pair in alignment["lift_sheet_pair_differences"]:
            lines.append(
                f"| {pair['phase']} | {pair['channel']} | {pair['delta_m_sheet0']:.6f} | "
                f"{pair['delta_m_sheet1']:.6f} | {pair['abs_difference']:.6f} |"
            )
        lines.extend(["", "#### Signed sheet-lift diagnostic", ""])
        lines.extend(
            [
                f"- status: {duality['status']}",
                f"- not_claimed: {duality['not_claimed']}",
                "",
                "| phase | channel | dual sum | abs dual sum | |Δ| diff | flip |",
                "|---:|---|---:|---:|---:|:---:|",
            ]
        )
        for pair in duality["pairs"]:
            flip = "yes" if pair["orientation_flip"] else "no"
            lines.append(
                f"| {pair['phase']} | {pair['channel']} | {pair['signed_dual_sum']:.6f} | "
                f"{pair['abs_dual_sum']:.6f} | {pair['same_magnitude_difference']:.6f} | "
                f"{flip} |"
            )
        lines.append("")
    return "\n".join(lines).rstrip() + "\n"


def build_floquet_annotation_export(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
) -> FloquetAnnotationExport:
    """Build a JSON-serializable [B/C] annotation report for E-033 bridge records."""
    scenarios: list[dict[str, Any]] = []
    for record in bridge_records:
        annotations = annotate_kepler_time_bridge_record(record)
        scenarios.append(
            {
                "control_name": record.control_name,
                "M_tail_period": record.diagnostics.M_tail_period,
                "unique_delta_M_count": record.diagnostics.unique_delta_M_count,
                "delta_M_spectrum": list(record.diagnostics.delta_M_spectrum),
                "annotated_delta_M": annotations,
                "alignment_summary": build_scenario_alignment_report(annotations),
            }
        )

    return FloquetAnnotationExport(
        status="B/C annotation only",
        claim="period-8 Floquet steps are annotated by the formal 2x4 chi lift",
        not_claimed="Delta-M values are not proven to realize the channel projection",
        alignment_status=ALIGNMENT_STATUS,
        alignment_claim=ALIGNMENT_CLAIM,
        alignment_not_claimed=ALIGNMENT_NOT_CLAIMED,
        cycle=tuple(floquet_step_channel(index).value for index in range(FLOQUET_TAIL_PERIOD_INTERFACE)),
        chi_cycle_period=CHI_CYCLE_PERIOD,
        floquet_tail_period_interface=FLOQUET_TAIL_PERIOD_INTERFACE,
        formal_lift_table=tuple(floquet_channel_table()),
        scenarios=tuple(scenarios),
    )


def export_floquet_annotation_json(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
    path: Path,
) -> FloquetAnnotationExport:
    export = build_floquet_annotation_export(bridge_records)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(export.to_dict(), indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return export


def export_floquet_alignment_markdown(
    bridge_records: Sequence[KeplerTimeBridgeRecord],
    path: Path,
) -> FloquetAnnotationExport:
    export = build_floquet_annotation_export(bridge_records)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(format_alignment_markdown_report(export), encoding="utf-8")
    return export
