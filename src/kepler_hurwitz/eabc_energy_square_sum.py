"""
EABC energetic square-sum substitution — axis energy as a_x^2 + a_y^2 [C].

Paradigm shift: imaginary quaternion basis axes (a, b, c, ab, ac, bc) are read as
energy-density metrics from two orthogonal amplitude degrees of freedom, not as
fundamental scalars or vectors.

Governance: [A/B] for quadratic positive definiteness and EEG linear scaling;
[C] for harmonic-oscillator / energy-density reading.
Does not claim QM energy identity; does not replace quaternion multiplication
in the [A] layer.

Sibling: E-093, eabc_six_state_prime_axes.py (BH-C-07).
See docs/theory/eabc_energy_square_sum_substitution.md (BH-C-11).
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

ENERGY_SQUARE_SUM_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive energy-density scaffold with A/B quadratic facts",
    "tag_interpretive": ENERGY_SQUARE_SUM_TAG,
    "facts_ab": (
        "a_energy = ax^2 + ay^2 >= 0 for real amplitudes; "
        "e_i = ax^2, e_j = ay^2 orthogonal decomposition; "
        "total = EEG * (ax^2 + ay^2) expands linearly in squared basis elements"
    ),
    "reading_c": (
        "harmonic-oscillator analogy: two orthogonal DOF per axis; "
        "return to scalar space via |q|^2-style squaring; "
        "symmetric treatment of b, c, ab, ac, bc axes"
    ),
    "not_claimed": (
        "QM Hamiltonian or EEG signal identity; "
        "replacement of quaternion multiplication in [A] layer; "
        "physical units or calibrated EEG without preregistration; "
        "that primes on axis a carry measurable energy density; "
        "meson / composite-particle analogy as particle-physics proof"
    ),
    "dual_axis_reading_c": (
        "a-axis: vector energy E_a = ax^2 + ay^2 (quadratic, 2 coupled modes); "
        "bc-axis: bivector E_bc = E_b * E_c with E_b = bx^2+by^2, E_c = cx^2+cy^2 "
        "(quartic, 4 cross terms); gap asymmetry 2-factor vs 4-factor coupling"
    ),
    "sibling_register": "E-093",
    "claim_id": "BH-C-11",
    "related_scripts": (
        "eabc_energy_square_sum.sage, eabc_dual_axis_energy_asymmetry.sage, "
        "eabc_six_state_prime_axes.py, eabc_dirichlet_chi_minus3.py"
    ),
}

__all__ = [
    "ENERGY_SQUARE_SUM_TAG",
    "GOVERNANCE",
    "AxisEnergyState",
    "BivectorEnergyState",
    "axis_a_energy",
    "axis_bc_energy",
    "axis_energy_from_amplitudes",
    "bivector_energy_from_amplitudes",
    "build_dual_axis_comparison",
    "build_energy_grid",
    "compare_dual_axis_scaling",
    "dual_axis_totals_with_eeg",
    "expanded_bc_terms",
    "expanded_energy_terms",
    "export_energy_square_sum_json",
    "symmetric_axes_energy_template",
    "total_energy_with_eeg",
]


@dataclass(frozen=True)
class AxisEnergyState:
    """Energetic state of one imaginary EABC axis from two orthogonal amplitudes."""

    axis_name: str
    ax: float | None
    ay: float | None
    e_i: float
    e_j: float
    a_energy: float


def axis_energy_from_amplitudes(
    ax: float,
    ay: float,
    *,
    axis_name: str = "a",
) -> AxisEnergyState:
    """Compute e_i = ax^2, e_j = ay^2, a_energy = e_i + e_j for real amplitudes."""
    e_i = ax * ax
    e_j = ay * ay
    return AxisEnergyState(
        axis_name=axis_name,
        ax=ax,
        ay=ay,
        e_i=e_i,
        e_j=e_j,
        a_energy=e_i + e_j,
    )


def axis_a_energy(ax: float, ay: float) -> float:
    """Vector energy on prime axis a: E_a = ax^2 + ay^2."""
    return ax * ax + ay * ay


def axis_bc_energy(bx: float, by: float, cx: float, cy: float) -> float:
    """Bivector energy on conjugate bc-axis: E_bc = E_b * E_c."""
    e_b = bx * bx + by * by
    e_c = cx * cx + cy * cy
    return e_b * e_c


def expanded_bc_terms(bx: float, by: float, cx: float, cy: float) -> dict[str, float]:
    """
    Four cross terms of the quartic bc bivector product E_b * E_c.

    Returns keys ``bx^2*cx^2``, ``bx^2*cy^2``, ``by^2*cx^2``, ``by^2*cy^2``.
    """
    bx2 = bx * bx
    by2 = by * by
    cx2 = cx * cx
    cy2 = cy * cy
    return {
        "bx^2*cx^2": bx2 * cx2,
        "bx^2*cy^2": bx2 * cy2,
        "by^2*cx^2": by2 * cx2,
        "by^2*cy^2": by2 * cy2,
    }


@dataclass(frozen=True)
class BivectorEnergyState:
    """Energetic state of conjugate bc-axis from b and c amplitude pairs."""

    bx: float
    by: float
    cx: float
    cy: float
    e_b: float
    e_c: float
    bc_energy: float
    cross_terms: dict[str, float]


def bivector_energy_from_amplitudes(
    bx: float,
    by: float,
    cx: float,
    cy: float,
) -> BivectorEnergyState:
    """Compute E_b, E_c, E_bc = E_b * E_c and expanded quartic cross terms."""
    e_b = bx * bx + by * by
    e_c = cx * cx + cy * cy
    terms = expanded_bc_terms(bx, by, cx, cy)
    return BivectorEnergyState(
        bx=bx,
        by=by,
        cx=cx,
        cy=cy,
        e_b=e_b,
        e_c=e_c,
        bc_energy=e_b * e_c,
        cross_terms=terms,
    )


def compare_dual_axis_scaling(
    ax: float,
    ay: float,
    bx: float,
    by: float,
    cx: float,
    cy: float,
) -> dict[str, float]:
    """
    Compare quadratic a-axis vs quartic bc-axis energy and their ratio.

    When all amplitudes equal u: E_a = 2u^2, E_bc = 4u^4, ratio = 2u^2.
    """
    e_a = axis_a_energy(ax, ay)
    state_bc = bivector_energy_from_amplitudes(bx, by, cx, cy)
    e_bc = state_bc.bc_energy
    ratio = e_bc / e_a if e_a != 0.0 else float("inf")
    amplitudes_equal = ax == ay == bx == by == cx == cy
    return {
        "e_a": e_a,
        "e_b": state_bc.e_b,
        "e_c": state_bc.e_c,
        "e_bc": e_bc,
        "ratio_e_bc_over_e_a": ratio,
        "scaling_degree_a": 2.0,
        "scaling_degree_bc": 4.0,
        "amplitudes_equal": float(amplitudes_equal),
    }


def dual_axis_totals_with_eeg(eeg: float, e_a: float, e_bc: float) -> dict[str, float]:
    """Return total_E_a = EEG * E_a and total_E_bc = EEG * E_bc."""
    return {
        "total_E_a": eeg * e_a,
        "total_E_bc": eeg * e_bc,
    }


def total_energy_with_eeg(eeg: float, axis_energy: float) -> float:
    """Total energy E_total = EEG * axis_energy (numeric)."""
    return eeg * axis_energy


def expanded_energy_terms(eeg: float, ax: float, ay: float) -> dict[str, float]:
    """
    Expanded EEG-scaled energy terms.

    Returns keys ``eeg*ax^2`` and ``eeg*ay^2`` with numeric values.
    """
    return {
        "eeg*ax^2": eeg * ax * ax,
        "eeg*ay^2": eeg * ay * ay,
    }


def symmetric_axes_energy_template() -> dict[str, dict[str, str]]:
    """
    Document symmetric square-sum pattern for all six imaginary basis states [C].

    Each axis carries two orthogonal amplitude DOF and energy = amp_x^2 + amp_y^2.
    """
    axes = ("a", "b", "c", "ab", "ac", "bc")
    template: dict[str, dict[str, str]] = {}
    for axis in axes:
        x_label = f"{axis}_x" if len(axis) == 1 else f"{axis[0]}x"
        y_label = f"{axis}_y" if len(axis) == 1 else f"{axis[1]}y"
        template[axis] = {
            "amplitudes": f"{x_label}, {y_label}",
            "e_i": f"{x_label}^2",
            "e_j": f"{y_label}^2",
            "energy": f"{x_label}^2 + {y_label}^2",
            "tag": ENERGY_SQUARE_SUM_TAG,
        }
    return template


def build_energy_grid(
    eeg: float,
    amplitudes: tuple[tuple[float, float], ...],
    *,
    axis_name: str = "a",
) -> list[dict[str, Any]]:
    """Build numeric grid of axis energy states scaled by EEG."""
    rows: list[dict[str, Any]] = []
    for ax, ay in amplitudes:
        state = axis_energy_from_amplitudes(ax, ay, axis_name=axis_name)
        terms = expanded_energy_terms(eeg, ax, ay)
        rows.append(
            {
                "axis_name": state.axis_name,
                "ax": state.ax,
                "ay": state.ay,
                "e_i": state.e_i,
                "e_j": state.e_j,
                "a_energy": state.a_energy,
                "eeg": eeg,
                "total_energy": total_energy_with_eeg(eeg, state.a_energy),
                "expanded_terms": terms,
                "tag": ENERGY_SQUARE_SUM_TAG,
            }
        )
    return rows


def build_dual_axis_comparison(
    eeg: float,
    amplitudes: tuple[tuple[float, float, float, float, float, float], ...],
) -> list[dict[str, Any]]:
    """Build numeric grid comparing a-axis vector vs bc-axis bivector energy."""
    rows: list[dict[str, Any]] = []
    for ax, ay, bx, by, cx, cy in amplitudes:
        comparison = compare_dual_axis_scaling(ax, ay, bx, by, cx, cy)
        totals = dual_axis_totals_with_eeg(eeg, comparison["e_a"], comparison["e_bc"])
        state_bc = bivector_energy_from_amplitudes(bx, by, cx, cy)
        rows.append(
            {
                "ax": ax,
                "ay": ay,
                "bx": bx,
                "by": by,
                "cx": cx,
                "cy": cy,
                "e_a": comparison["e_a"],
                "e_bc": comparison["e_bc"],
                "ratio_e_bc_over_e_a": comparison["ratio_e_bc_over_e_a"],
                "expanded_bc_terms": state_bc.cross_terms,
                "eeg": eeg,
                **totals,
                "tag": ENERGY_SQUARE_SUM_TAG,
            }
        )
    return rows


def export_energy_square_sum_json(
    analysis: dict[str, Any],
    path: Path | str,
) -> Path:
    """Write energy square-sum analysis dict to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
