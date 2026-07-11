"""
Channel-7 local witness classification (n % 8 = 7).

Governance [B]: numerical t_loc search only — no formal proof claims.
Uses canonical V2.7/V2.8 witness semantics via diagnostics_export helpers.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal

from kepler_hurwitz.diagnostics import collatz_iterate, steps_until_mod4_eq_one
from kepler_hurwitz.diagnostics_export import first_positive_net_descent_t_loc

DepthLabel = Literal[
    "closed_short",
    "closed_medium",
    "closed_deep",
    "numerical_only",
    "open",
    "formal",
]

StatusLabel = Literal[
    "formally_closed",
    "numerically_supported",
    "open",
    "deep_tail",
]

CHANNEL_SEVEN_MODULUS = 128
FORMAL_RESIDUES_MOD32: frozenset[int] = frozenset({23})
CHANNEL_THREE_FROZEN_COVERAGE = "13/16"
CHANNEL_THREE_DEEP_TAIL = (27, 91, 123)


def _depth_label(t_loc: int | None, *, formal: bool) -> DepthLabel:
    if formal and t_loc is not None:
        if t_loc <= 10:
            return "closed_short"
        if t_loc <= 32:
            return "closed_medium"
        return "closed_deep"
    if t_loc is None:
        return "open"
    if t_loc <= 10:
        return "closed_short"
    if t_loc <= 32:
        return "closed_medium"
    return "closed_deep"


def _status_label(
    *,
    formal: bool,
    t_loc: int | None,
    deep_tail: bool,
) -> StatusLabel:
    if formal:
        return "formally_closed"
    if deep_tail:
        return "deep_tail"
    if t_loc is not None:
        return "numerically_supported"
    return "open"


def _target_channel(n: int) -> int:
    """Next odd mod-8 class after one Syracuse step from channel-7 start."""
    t_odd = collatz_iterate(n, 2)
    return t_odd % 8


def _mod32_class(residue: int) -> int:
    return residue % 32


def _mod64_class(residue: int) -> int:
    return residue % 64


@dataclass(frozen=True)
class WitnessClassRecord:
    modulus: int
    residue: int
    representative: int
    t_loc: int | None
    t_good: int | None
    target_channel: int
    depth_label: DepthLabel
    status: StatusLabel
    formally_closed: bool
    lift_stage: str
    notes: str = ""

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def channel_seven_residues(modulus: int = CHANNEL_SEVEN_MODULUS) -> list[int]:
    return [r for r in range(modulus) if r % 8 == 7]


def scan_channel_seven_class(
    residue: int,
    *,
    modulus: int = CHANNEL_SEVEN_MODULUS,
    max_t_loc: int = 500,
    min_n: int = 2,
) -> WitnessClassRecord:
    if residue % 8 != 7:
        raise ValueError(f"residue {residue} is not channel 7 (n % 8 = 7)")
    representative = residue if residue >= min_n else residue + modulus
    formal = _mod32_class(residue) in FORMAL_RESIDUES_MOD32
    t_good, _m_good = steps_until_mod4_eq_one(representative)
    t_loc = 4 if formal else first_positive_net_descent_t_loc(
        representative, max_t_loc=max_t_loc
    )
    depth = _depth_label(t_loc, formal=formal)
    deep_tail = (not formal) and depth == "closed_deep" and t_loc is not None and t_loc > 32
    status = _status_label(formal=formal, t_loc=t_loc, deep_tail=deep_tail)
    lift_stage = "mod32" if formal else (
        "mod64" if _mod64_class(residue) != residue else "mod128"
    )
    notes = ""
    if formal:
        notes = "Lean [A]: bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two"
    elif t_loc is None:
        notes = f"no witness within max_t_loc={max_t_loc}"
    return WitnessClassRecord(
        modulus=modulus,
        residue=residue,
        representative=representative,
        t_loc=t_loc,
        t_good=t_good,
        target_channel=_target_channel(representative),
        depth_label=depth,
        status=status,
        formally_closed=formal,
        lift_stage=lift_stage,
        notes=notes,
    )


def scan_channel_seven(
    *,
    modulus: int = CHANNEL_SEVEN_MODULUS,
    max_t_loc: int = 500,
) -> list[WitnessClassRecord]:
    return [
        scan_channel_seven_class(r, modulus=modulus, max_t_loc=max_t_loc)
        for r in channel_seven_residues(modulus)
    ]


def summarize_channel_seven(records: list[WitnessClassRecord]) -> dict[str, Any]:
    total = len(records)
    formal = sum(1 for r in records if r.formally_closed)
    numerical = sum(
        1 for r in records
        if r.status == "numerically_supported" and not r.formally_closed
    )
    open_count = sum(1 for r in records if r.status == "open")
    deep_tail = sum(1 for r in records if r.status == "deep_tail")
    formal_t_locs = [r.t_loc for r in records if r.formally_closed and r.t_loc is not None]
    numerical_t_locs = [
        r.t_loc for r in records
        if r.t_loc is not None and not r.formally_closed
    ]
    closed_short = [r.residue for r in records if r.depth_label == "closed_short"]
    closed_medium = [r.residue for r in records if r.depth_label == "closed_medium"]
    closed_deep = [r.residue for r in records if r.depth_label == "closed_deep"]
    return {
        "channel": 7,
        "modulus": records[0].modulus if records else CHANNEL_SEVEN_MODULUS,
        "total_classes": total,
        "formally_closed_classes": formal,
        "numerically_supported_classes": numerical,
        "open_classes": open_count,
        "deep_tail_classes": deep_tail,
        "coverage_fraction": formal / total if total else 0.0,
        "numerical_coverage_fraction": (formal + numerical) / total if total else 0.0,
        "maximum_formal_t_loc": max(formal_t_locs) if formal_t_locs else None,
        "maximum_numerical_t_loc": max(numerical_t_locs) if numerical_t_locs else None,
        "closed_short_residues": closed_short,
        "closed_medium_residues": closed_medium,
        "closed_deep_residues": closed_deep,
        "open_residues": [r.residue for r in records if r.status == "open"],
        "deep_tail_residues": [r.residue for r in records if r.status == "deep_tail"],
        "channel_three_frozen_coverage": CHANNEL_THREE_FROZEN_COVERAGE,
        "channel_three_deep_tail_mod128": list(CHANNEL_THREE_DEEP_TAIL),
        "governance": "[B] numerical scan — not formal proof",
    }


def export_channel_seven_classification(
    *,
    out_path: Path,
    modulus: int = CHANNEL_SEVEN_MODULUS,
    max_t_loc: int = 500,
) -> dict[str, Any]:
    records = scan_channel_seven(modulus=modulus, max_t_loc=max_t_loc)
    payload = {
        "summary": summarize_channel_seven(records),
        "classes": [r.as_dict() for r in records],
    }
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
    return payload


def classification_markdown_table(records: list[WitnessClassRecord]) -> str:
    header = "| modulus | residue | representative | t_loc | target_channel | status | depth |"
    sep = "|---:|---:|---:|---:|---:|---|---|"
    rows = []
    for r in records:
        t_loc = "" if r.t_loc is None else str(r.t_loc)
        rows.append(
            f"| {r.modulus} | {r.residue} | {r.representative} | {t_loc} "
            f"| {r.target_channel} | {r.status} | {r.depth_label} |"
        )
    return "\n".join([header, sep, *rows])
