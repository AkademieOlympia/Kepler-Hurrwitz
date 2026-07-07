"""
Cross-talk / entanglement symmetry breaking on E_bc [C].

Local Pauli tensor ops P_b ⊗ P_c (15/15) leave E_bc invariant [A/B]; the true
symmetry break is cross-field entanglement error (partial bx↔cx swap) with
ΔE = (bx²-cx²)(cy²-by²). Non-zero ΔE marks loss of orthogonal factorization
(primality coupling) [C].

Governance: [A/B] for ΔE algebra; [C] for primality-loss reading.

Sibling: phaseninvarianz_tensor_invariants.py (PI-C-07), phaseninvarianz_pauli_energy.py.
See docs/theory/phaseninvarianz_crosstalk_symmetry_break.md (PI-C-03).
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal

from kepler_hurwitz.phaseninvarianz_pauli_energy import energy_bc, expanded_bc_terms

CROSSTALK_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive cross-talk symmetry-break scaffold with A/B ΔE facts",
    "tag_interpretive": CROSSTALK_TAG,
    "facts_ab": (
        "All 15 local P_b ⊗ P_c leave E_bc = (bx^2+by^2)(cx^2+cy^2) invariant; "
        "partial cross-field swap bx↔cx yields ΔE = bx^2*cy^2 + by^2*cx^2 - cx^2*cy^2 - bx^2*by^2; "
        "factored ΔE = (bx^2 - cx^2)(cy^2 - by^2); "
        "ΔE = 0 iff bx = cx or by = cy (orthogonal coupling preserved)"
    ),
    "reading_c": (
        "non-zero cross-talk ΔE signals loss of primality / factorization on the "
        "bc bivector channel; local Pauli noise does not break E_bc — only "
        "entanglement errors between b and c fields do"
    ),
    "not_claimed": (
        "that primes physically decohere under cross-talk; "
        "QM entanglement identity on Hilbert space; "
        "proof that ΔE=0 characterizes prime pairs in number theory; "
        "replacement of [[5,1,3]] QEC grammar (E-044)"
    ),
    "sibling_register": "E-094",
    "claim_id": "PI-C-03",
    "related_scripts": (
        "crosstalk_symmetry_break.sage, phaseninvarianz_tensor_invariants.py, "
        "phaseninvarianz_pauli_energy.py"
    ),
}

SwapPair = Literal["bx_cx", "bx_cy", "by_cx", "by_cy"]

_SWAP_MAP: dict[SwapPair, tuple[str, str]] = {
    "bx_cx": ("bx", "cx"),
    "bx_cy": ("bx", "cy"),
    "by_cx": ("by", "cx"),
    "by_cy": ("by", "cy"),
}

__all__ = [
    "CROSSTALK_TAG",
    "GOVERNANCE",
    "CrosstalkReport",
    "analyze_crosstalk_swap",
    "cross_field_swap_amplitudes",
    "crosstalk_delta_e",
    "crosstalk_delta_e_expanded",
    "crosstalk_delta_e_symbolic_factors",
    "energy_bc_expanded",
    "export_crosstalk_json",
    "is_primality_preserved",
]


def energy_bc_expanded(bx: float, by: float, cx: float, cy: float) -> dict[str, float]:
    """Four cross terms of E_bc = E_b * E_c."""
    return expanded_bc_terms(bx, by, cx, cy)


def cross_field_swap_amplitudes(
    bx: float,
    by: float,
    cx: float,
    cy: float,
    swap: tuple[str, str] = ("bx", "cx"),
) -> tuple[float, float, float, float]:
    """
    Partial cross-field amplitude swap (entanglement error).

    Default swap=('bx','cx') exchanges b_x ↔ c_x, leaves by and cy fixed.
    """
    amps = {"bx": bx, "by": by, "cx": cx, "cy": cy}
    a, b = swap
    if a not in amps or b not in amps:
        raise ValueError(f"swap keys must be among bx,by,cx,cy; got {swap!r}")
    amps[a], amps[b] = amps[b], amps[a]
    return amps["bx"], amps["by"], amps["cx"], amps["cy"]


def crosstalk_delta_e_expanded(bx: float, by: float, cx: float, cy: float) -> float:
    """Expanded cross-talk energy shift: bx²cy² + by²cx² - cx²cy² - bx²by²."""
    bx2 = bx * bx
    by2 = by * by
    cx2 = cx * cx
    cy2 = cy * cy
    return bx2 * cy2 + by2 * cx2 - cx2 * cy2 - bx2 * by2


def crosstalk_delta_e(bx: float, by: float, cx: float, cy: float) -> float:
    """
    Energy difference E_bc(intact) - E_bc(after bx↔cx cross-field swap).

    Equals (bx²-cx²)(cy²-by²) algebraically.
    """
    e_intact = energy_bc(bx, by, cx, cy)
    bx2, by2, cx2, cy2 = cross_field_swap_amplitudes(bx, by, cx, cy, ("bx", "cx"))
    e_destroyed = energy_bc(bx2, by2, cx2, cy2)
    return e_intact - e_destroyed


def crosstalk_delta_e_symbolic_factors() -> str:
    """Documented factorization of ΔE."""
    return "(bx^2 - cx^2)(cy^2 - by^2)"


def is_primality_preserved(
    bx: float,
    by: float,
    cx: float,
    cy: float,
    *,
    tol: float = 1e-12,
) -> bool:
    """
    True when cross-talk ΔE ≈ 0 (orthogonal coupling bx=cx or by=cy preserved).

    Interpretive [C]: primality / factorization coupling intact.
    """
    return abs(crosstalk_delta_e(bx, by, cx, cy)) <= tol


@dataclass(frozen=True)
class CrosstalkReport:
    """Cross-field swap audit on E_bc."""

    bx: float
    by: float
    cx: float
    cy: float
    e_intact: float
    e_destroyed: float
    delta_e: float
    delta_e_expanded: float
    factored_form: str
    primality_preserved: bool
    expanded_terms_intact: dict[str, float]
    expanded_terms_destroyed: dict[str, float]
    tag: str = CROSSTALK_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def analyze_crosstalk_swap(bx: float, by: float, cx: float, cy: float) -> CrosstalkReport:
    """Full cross-talk analysis for default bx↔cx partial swap."""
    bx2, by2, cx2, cy2 = cross_field_swap_amplitudes(bx, by, cx, cy, ("bx", "cx"))
    e_intact = energy_bc(bx, by, cx, cy)
    e_destroyed = energy_bc(bx2, by2, cx2, cy2)
    delta = e_intact - e_destroyed
    return CrosstalkReport(
        bx=bx,
        by=by,
        cx=cx,
        cy=cy,
        e_intact=e_intact,
        e_destroyed=e_destroyed,
        delta_e=delta,
        delta_e_expanded=crosstalk_delta_e_expanded(bx, by, cx, cy),
        factored_form=crosstalk_delta_e_symbolic_factors(),
        primality_preserved=is_primality_preserved(bx, by, cx, cy),
        expanded_terms_intact=energy_bc_expanded(bx, by, cx, cy),
        expanded_terms_destroyed=energy_bc_expanded(bx2, by2, cx2, cy2),
    )


def export_crosstalk_json(analysis: dict[str, Any], path: Path | str) -> Path:
    """Write cross-talk analysis dict to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
