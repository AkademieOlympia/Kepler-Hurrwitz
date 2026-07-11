"""
Pauli phase invariance on quadratic/quartic EABC energy terms [C].

Pauli Z (phase flip ax -> -ax) and X (bit flip ax <-> ay) leave the quadratic
a-axis energy E_a = ax^2 + ay^2 invariant [A/B]. A partial tensor X error on the
bc bivector (bx <-> cx swap) restructures quartic cross terms and is generally
not invariant — bivector channel needs full QEC protection [C].

Governance: [A/B] for squaring invariance facts; [C] for QEC-protects-primes reading.

Sibling: E-094, eabc_energy_square_sum.py (BH-C-11), qec_bridge.py (E-044),
eabc_symplectic_stabilizer_bridge.py (BH-C-09), eabc_six_state_prime_axes.py (BH-C-07).
See docs/theory/phaseninvarianz_pauli_energy_bridge.md (PI-C-01..).
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Mapping

PHASENINVARIANZ_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive Pauli-QEC protection scaffold with A/B invariance facts",
    "tag_interpretive": PHASENINVARIANZ_TAG,
    "facts_ab": (
        "E_a = ax^2 + ay^2 invariant under Pauli Z (ax -> -ax) and Pauli X (ax <-> ay); "
        "E_bc = (bx^2+by^2)(cx^2+cy^2) generally not invariant under partial tensor X (bx <-> cx)"
    ),
    "reading_c": (
        "6k+1 prime axis a enjoys phase/bit-flip protection on quadratic energy; "
        "bc bivector quartic channel is vulnerable to partial Pauli errors and "
        "requires full [[5,1,3]] QEC grammar (E-044, BH-C-09)"
    ),
    "not_claimed": (
        "that primes are physically QEC-stabilized; "
        "QM Pauli operator identity on Hilbert space; "
        "proof that L(s,chi_{-3}) implements five-qubit code; "
        "that phase invariance alone explains twin-prime structure"
    ),
    "sibling_register": "E-094",
    "claim_id": "PI-C-01",
    "related_scripts": (
        "pauli_energy_invariance.sage, eabc_energy_square_sum.py, "
        "five_qubit_bridge.sage, qec_bridge.py"
    ),
}

__all__ = [
    "PHASENINVARIANZ_TAG",
    "GOVERNANCE",
    "AmplitudeState",
    "PauliInvarianceReport",
    "apply_pauli_x_to_a",
    "apply_pauli_z_to_a",
    "apply_tensor_x_error_bc",
    "energy_a",
    "energy_bc",
    "expanded_bc_terms",
    "export_pauli_invariance_json",
    "is_tensor_x_bc_invariant",
    "pauli_invariance_report",
]


@dataclass(frozen=True)
class AmplitudeState:
    """Six amplitude DOF for a-axis vector and bc-axis bivector energies."""

    ax: float
    ay: float
    bx: float
    by: float
    cx: float
    cy: float

    @classmethod
    def from_mapping(cls, amplitudes: Mapping[str, float]) -> AmplitudeState:
        return cls(
            ax=float(amplitudes["ax"]),
            ay=float(amplitudes["ay"]),
            bx=float(amplitudes["bx"]),
            by=float(amplitudes["by"]),
            cx=float(amplitudes["cx"]),
            cy=float(amplitudes["cy"]),
        )


def energy_a(ax: float, ay: float) -> float:
    """Quadratic energy on prime axis a: E_a = ax^2 + ay^2."""
    return ax * ax + ay * ay


def energy_bc(bx: float, by: float, cx: float, cy: float) -> float:
    """Quartic bivector energy on bc-axis: E_bc = (bx^2+by^2)(cx^2+cy^2)."""
    e_b = bx * bx + by * by
    e_c = cx * cx + cy * cy
    return e_b * e_c


def expanded_bc_terms(bx: float, by: float, cx: float, cy: float) -> dict[str, float]:
    """Four cross terms of E_b * E_c."""
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


def apply_pauli_z_to_a(ax: float, ay: float) -> tuple[float, float]:
    """Pauli Z on a-axis: phase flip ax -> -ax, ay unchanged."""
    return (-ax, ay)


def apply_pauli_x_to_a(ax: float, ay: float) -> tuple[float, float]:
    """Pauli X on a-axis: bit flip ax <-> ay."""
    return (ay, ax)


def apply_tensor_x_error_bc(
    bx: float,
    by: float,
    cx: float,
    cy: float,
) -> tuple[float, float, float, float]:
    """Partial tensor X error: swap bx <-> cx, leave by and cy."""
    return (cx, by, bx, cy)


def is_tensor_x_bc_invariant(bx: float, by: float, cx: float, cy: float) -> bool:
    """
    True when E_bc is unchanged under partial bx <-> cx swap.

    Algebraically: (by^2 - cy^2)(cx^2 - bx^2) = 0.
    """
    e_before = energy_bc(bx, by, cx, cy)
    bx2, by2, cx2, cy2 = apply_tensor_x_error_bc(bx, by, cx, cy)
    e_after = energy_bc(bx2, by2, cx2, cy2)
    return e_before == e_after


@dataclass(frozen=True)
class PauliInvarianceReport:
    """Numeric Pauli invariance audit for one amplitude state."""

    ax: float
    ay: float
    bx: float
    by: float
    cx: float
    cy: float
    e_a_before: float
    e_a_after_z: float
    e_a_after_x: float
    e_bc_before: float
    e_bc_after_tensor_x: float
    invariant_under_z: bool
    invariant_under_x: bool
    invariant_under_tensor_x: bool
    symmetric_tensor_x_special_case: bool
    bc_cross_terms_before: dict[str, float]
    bc_cross_terms_after_tensor_x: dict[str, float]
    tag: str = PHASENINVARIANZ_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def pauli_invariance_report(amplitudes: Mapping[str, float]) -> dict[str, Any]:
    """
    Build invariance report for a-axis Pauli Z/X and bc partial tensor X error.

    ``amplitudes`` must provide keys ax, ay, bx, by, cx, cy.
  """
    state = AmplitudeState.from_mapping(amplitudes)
    ax, ay = state.ax, state.ay
    bx, by, cx, cy = state.bx, state.by, state.cx, state.cy

    e_a_before = energy_a(ax, ay)

    ax_z, ay_z = apply_pauli_z_to_a(ax, ay)
    e_a_after_z = energy_a(ax_z, ay_z)

    ax_x, ay_x = apply_pauli_x_to_a(ax, ay)
    e_a_after_x = energy_a(ax_x, ay_x)

    e_bc_before = energy_bc(bx, by, cx, cy)
    bx_err, by_err, cx_err, cy_err = apply_tensor_x_error_bc(bx, by, cx, cy)
    e_bc_after_tensor_x = energy_bc(bx_err, by_err, cx_err, cy_err)

    symmetric = is_tensor_x_bc_invariant(bx, by, cx, cy)

    report = PauliInvarianceReport(
        ax=ax,
        ay=ay,
        bx=bx,
        by=by,
        cx=cx,
        cy=cy,
        e_a_before=e_a_before,
        e_a_after_z=e_a_after_z,
        e_a_after_x=e_a_after_x,
        e_bc_before=e_bc_before,
        e_bc_after_tensor_x=e_bc_after_tensor_x,
        invariant_under_z=e_a_before == e_a_after_z,
        invariant_under_x=e_a_before == e_a_after_x,
        invariant_under_tensor_x=e_bc_before == e_bc_after_tensor_x,
        symmetric_tensor_x_special_case=symmetric,
        bc_cross_terms_before=expanded_bc_terms(bx, by, cx, cy),
        bc_cross_terms_after_tensor_x=expanded_bc_terms(bx_err, by_err, cx_err, cy_err),
    )
    return report.as_dict()


def export_pauli_invariance_json(
    analysis: dict[str, Any],
    path: Path | str,
) -> Path:
    """Write Pauli invariance analysis dict to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
