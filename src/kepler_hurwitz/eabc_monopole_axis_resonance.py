"""
EABC Riemann-zero / a-vs-bc axis resonance monopole test — hypothesis scaffold [C].

For imaginary parts gamma_n of zeta zeros, compare prime-axis resonance:

    psi_a(gamma)  = sum_{p in a}  cos(gamma ln p) / sqrt(p)
    psi_bc(gamma) = sum_{p in bc} cos(gamma ln p) / sqrt(p)
    delta         = psi_a - psi_bc

Primes p > 3 occupy only the conjugate dual pair (a, bc) from mod-6 EABC states;
see ``eabc_six_state_prime_axes``.

A mathematically clean split of zeta information along mod-6 axes may require the
Dirichlet L-function L(s, chi_{-3}) as conjugator — this module uses the
interpretive [C] cosine partial sums only.

Governance: [C] interpretive; does not claim RH proof, perfect monopole quantization,
or that zeta splits mod 6 without Dirichlet L. Numerical delta alternation is
exploratory only — not discovery-tauglich without preregistration.

Sibling to E-093 (Black Hole) and ``monopole_gap_test.sage``; see
``docs/theory/eabc_riemann_axis_monopole.md``.
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Sequence

from kepler_hurwitz.eabc_six_state_prime_axes import (
    SIX_STATE_TAG,
    get_eabc_state,
    primes_up_to,
)

MONOPOLE_AXIS_TAG = "[C]"

# First 15 known imaginary parts of non-trivial zeta zeros (Odlyzko tables).
FIRST_RIEMANN_ZEROS: tuple[float, ...] = (
    14.134725141734693,
    21.022039638771554,
    25.010857580145688,
    30.424876125859513,
    32.93506158773919,
    37.58617815882567,
    40.918719012147495,
    43.327073280914996,
    48.00515088116716,
    49.7738324776723,
    52.97032147771446,
    56.446247697063394,
    59.34704400260235,
    60.83177852460981,
    65.11254404808161,
)

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive resonance scaffold with B residue-axis facts",
    "tag_interpretive": MONOPOLE_AXIS_TAG,
    "not_claimed": (
        "proof of the Riemann Hypothesis; perfect monopole quantization of zeros; "
        "that zeta splits mod 6 without Dirichlet L(s, chi_{-3}); "
        "discovery-taugliche delta alternation without preregistration"
    ),
    "mathematical_note": (
        "Clean axis split may require L(s, chi_{-3}) as conjugator; "
        "cosine partial sums here are exploratory [C] only"
    ),
    "sibling_register": "E-093",
    "related_scripts": "monopole_gap_test.sage, eabc_monopole_axis_resonance.sage",
}

__all__ = [
    "FIRST_RIEMANN_ZEROS",
    "GOVERNANCE",
    "MONOPOLE_AXIS_TAG",
    "AxisResonanceRecord",
    "analyze_zero_axis_resonance",
    "build_axis_resonance_analysis",
    "compute_resonance",
    "count_delta_sign_changes",
    "dominant_axis",
    "export_axis_resonance_json",
    "get_prime_axes",
]


@dataclass(frozen=True)
class AxisResonanceRecord:
    gamma: float
    res_a: float
    res_bc: float
    delta: float
    dominant_axis: str
    tag: str = MONOPOLE_AXIS_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def get_prime_axes(limit: int) -> tuple[list[int], list[int]]:
    """Return (axis_a, axis_bc) prime lists with p > 3 up to ``limit``."""
    if limit < 2:
        return [], []
    axis_a: list[int] = []
    axis_bc: list[int] = []
    for p in primes_up_to(limit):
        if p <= 3:
            continue
        state = get_eabc_state(p)
        if state == "a":
            axis_a.append(p)
        elif state == "bc":
            axis_bc.append(p)
    return axis_a, axis_bc


def compute_resonance(gamma: float, prime_list: Sequence[int]) -> float:
    """Cosine partial sum sum_p cos(gamma ln p) / sqrt(p)."""
    total = 0.0
    for p in prime_list:
        total += math.cos(gamma * math.log(p)) / math.sqrt(p)
    return total


def dominant_axis(delta: float) -> str:
    if delta > 0:
        return "a"
    if delta < 0:
        return "bc"
    return "tie"


def analyze_zero_axis_resonance(
    gammas: Sequence[float],
    prime_limit: int,
) -> list[AxisResonanceRecord]:
    """Resonance records for each gamma with axis split up to ``prime_limit``."""
    axis_a, axis_bc = get_prime_axes(prime_limit)
    records: list[AxisResonanceRecord] = []
    for gamma in gammas:
        res_a = compute_resonance(gamma, axis_a)
        res_bc = compute_resonance(gamma, axis_bc)
        delta = res_a - res_bc
        records.append(
            AxisResonanceRecord(
                gamma=float(gamma),
                res_a=res_a,
                res_bc=res_bc,
                delta=delta,
                dominant_axis=dominant_axis(delta),
            )
        )
    return records


def count_delta_sign_changes(records: Sequence[AxisResonanceRecord]) -> int:
    """Count sign changes of delta across consecutive records (ties break streaks)."""
    changes = 0
    prev_sign: int | None = None
    for rec in records:
        if rec.delta == 0:
            prev_sign = None
            continue
        sign = 1 if rec.delta > 0 else -1
        if prev_sign is not None and sign != prev_sign:
            changes += 1
        prev_sign = sign
    return changes


def build_axis_resonance_analysis(
    *,
    gammas: Sequence[float] | None = None,
    prime_limit: int = 10_000,
) -> dict[str, Any]:
    """Bundle records with governance metadata for export."""
    zeros = tuple(gammas) if gammas is not None else FIRST_RIEMANN_ZEROS
    records = analyze_zero_axis_resonance(zeros, prime_limit)
    axis_a, axis_bc = get_prime_axes(prime_limit)
    return {
        "governance": MONOPOLE_AXIS_TAG,
        "governance_detail": GOVERNANCE,
        "prime_limit": prime_limit,
        "axis_a_count": len(axis_a),
        "axis_bc_count": len(axis_bc),
        "zero_count": len(records),
        "delta_sign_changes": count_delta_sign_changes(records),
        "records": [r.as_dict() for r in records],
    }


def export_axis_resonance_json(
    analysis: dict[str, Any],
    path: Path,
) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path
