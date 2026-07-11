"""
Pauli tensor eigenstate / invariant subspace analysis on bc-axis quartic energy [C].

Apply all 15 non-trivial tensor products P_b ⊗ P_c to E_bc = (bx²+by²)(cx²+cy²),
where each single-qubit Pauli acts on an amplitude pair (vx, vy). Because
E_pair = vx²+vy² is invariant under I, X, Y, Z individually, the full quartic
product E_bc is invariant under all 15 operators [A/B].

This is distinct from the *partial cross-field* tensor-X error (bx ↔ cx) in
phaseninvarianz_pauli_energy.py, which generally breaks E_bc.

Governance: [A/B] for per-pair squaring invariance; [C] for eigenstate S(E)=E reading.
Does not claim QM Hilbert-space identity or that primes are QEC-stabilized.

Sibling: E-094, phaseninvarianz_pauli_energy.py (PI-C-01),
eabc_energy_square_sum.py (BH-C-11).
See docs/theory/phaseninvarianz_tensor_invariant_subspace.md (PI-C-02).
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from fractions import Fraction
from pathlib import Path
from typing import Any, Mapping, Sequence, TypeAlias

TENSOR_INVARIANT_TAG = "[C]"

PAULI_OPS: tuple[str, ...] = ("I", "X", "Y", "Z")

Numeric: TypeAlias = float | Fraction | int

GOVERNANCE: dict[str, str] = {
    "status": "A/B per-pair Pauli invariance on quartic bc energy; C eigenstate reading",
    "tag_interpretive": TENSOR_INVARIANT_TAG,
    "facts_ab": (
        "E_pair = vx^2 + vy^2 invariant under Pauli I, X (swap), Z (vy -> -vy), "
        "Y (vx -> -vy, vy -> vx); therefore E_bc = E_b * E_c invariant under all "
        "15 non-trivial tensor products P_b ⊗ P_c on separate b and c pairs"
    ),
    "reading_c": (
        "bc quartic energy spans the full 15-dimensional Pauli tensor invariant "
        "subspace; eigenstate condition S(E_bc)=E_bc is algebraic squaring, not a "
        "QEC miracle; cross-field partial tensor-X errors remain vulnerable (PI-C-01)"
    ),
    "not_claimed": (
        "QM Pauli operator identity on a 2-qubit Hilbert space; "
        "that primes are physically QEC-stabilized; "
        "that full 15/15 invariance replaces need for [[5,1,3]] on conjugate channels; "
        "confusion with partial bx<->cx swap error"
    ),
    "sibling_register": "E-094",
    "claim_id": "PI-C-02",
    "related_scripts": (
        "pauli_tensor_invariant_subspace.sage, phaseninvarianz_pauli_energy.py, "
        "eabc_energy_square_sum.py"
    ),
}

__all__ = [
    "PAULI_OPS",
    "TENSOR_INVARIANT_TAG",
    "GOVERNANCE",
    "TensorInvariantRecord",
    "analyze_a_invariant_subspace",
    "analyze_bc_invariant_subspace",
    "apply_pauli_to_pair",
    "build_tensor_invariant_analysis",
    "energy_bc_from_amplitudes",
    "energy_pair_from_amplitudes",
    "export_tensor_invariants_json",
    "invariant_count",
    "is_bc_energy_invariant",
    "single_pair_energy_invariant",
    "tensor_operators",
    "transform_bc_energy",
    "transform_pair_energy",
]


def tensor_operators() -> list[str]:
    """All 15 non-trivial tensor Pauli strings P_b ⊗ P_c (exclude II)."""
    return [
        f"{op_b}{op_c}"
        for op_b in PAULI_OPS
        for op_c in PAULI_OPS
        if not (op_b == "I" and op_c == "I")
    ]


def _to_fraction(value: Numeric) -> Fraction:
    if isinstance(value, Fraction):
        return value
    if isinstance(value, int):
        return Fraction(value)
    return Fraction(str(value))


def apply_pauli_to_pair(
    op: str,
    vx: Numeric,
    vy: Numeric,
    amplitudes: Mapping[str, Numeric] | None = None,
    *,
    vx_key: str = "vx",
    vy_key: str = "vy",
) -> dict[str, Numeric]:
    """
    Apply single-qubit Pauli on amplitude pair (vx, vy).

    Convention: X swaps vx↔vy; Z flips vy→-vy; Y maps (vx,vy)→(-vy,vx).
    Returns a dict with transformed vx, vy. If ``amplitudes`` is given, copies
    other keys unchanged and updates vx_key / vy_key.
    """
    if op == "I":
        new_vx, new_vy = vx, vy
    elif op == "X":
        new_vx, new_vy = vy, vx
    elif op == "Z":
        new_vx, new_vy = vx, -vy
    elif op == "Y":
        new_vx, new_vy = -vy, vx
    else:
        raise ValueError(f"Unknown Pauli op: {op!r}; expected one of {PAULI_OPS}")

    if amplitudes is None:
        return {vx_key: new_vx, vy_key: new_vy}

    out = dict(amplitudes)
    out[vx_key] = new_vx
    out[vy_key] = new_vy
    return out


def energy_pair_from_amplitudes(vx: Numeric, vy: Numeric) -> Numeric:
    """Quadratic pair energy E = vx² + vy²."""
    return vx * vx + vy * vy


def energy_bc_from_amplitudes(bx: Numeric, by: Numeric, cx: Numeric, cy: Numeric) -> Numeric:
    """Quartic bc energy E_bc = (bx²+by²)(cx²+cy²)."""
    e_b = energy_pair_from_amplitudes(bx, by)
    e_c = energy_pair_from_amplitudes(cx, cy)
    return e_b * e_c


def transform_pair_energy(op: str, vx: Numeric, vy: Numeric) -> Numeric:
    """Apply Pauli op to pair and return E_pair after transformation."""
    transformed = apply_pauli_to_pair(op, vx, vy)
    return energy_pair_from_amplitudes(transformed["vx"], transformed["vy"])


def transform_bc_energy(
    op_b: str,
    op_c: str,
    bx: Numeric,
    by: Numeric,
    cx: Numeric,
    cy: Numeric,
) -> Numeric:
    """Apply P_b ⊗ P_c to bc amplitudes and return E_bc."""
    b_t = apply_pauli_to_pair(op_b, bx, by, vx_key="bx", vy_key="by")
    c_t = apply_pauli_to_pair(op_c, cx, cy, vx_key="cx", vy_key="cy")
    return energy_bc_from_amplitudes(b_t["bx"], b_t["by"], c_t["cx"], c_t["cy"])


def single_pair_energy_invariant(op: str) -> bool:
    """
    True when E_pair = vx²+vy² is invariant under Pauli ``op``.

    Algebraically all four Pauli ops preserve the quadratic sum [A/B].
    """
    return op in PAULI_OPS


def is_bc_energy_invariant(op_b: str, op_c: str) -> bool:
    """
    True when E_bc is invariant under tensor product P_b ⊗ P_c on separate pairs.

    Equivalent to per-pair invariance of E_b and E_c.
    """
    return single_pair_energy_invariant(op_b) and single_pair_energy_invariant(op_c)


@dataclass(frozen=True)
class TensorInvariantRecord:
    """One tensor-operator audit on bc (or a) quartic/quadratic energy."""

    op: str
    op_b: str
    op_c: str
    is_invariant: bool
    e_before: float
    e_after: float
    tag: str = TENSOR_INVARIANT_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def _exact_equal(before: Numeric, after: Numeric) -> bool:
    return _to_fraction(before) == _to_fraction(after)


def analyze_bc_invariant_subspace(
    bx: Numeric,
    by: Numeric,
    cx: Numeric,
    cy: Numeric,
) -> list[TensorInvariantRecord]:
    """Audit all 15 tensor operators on bc quartic energy at given amplitudes."""
    e_before = energy_bc_from_amplitudes(bx, by, cx, cy)
    records: list[TensorInvariantRecord] = []
    for op in tensor_operators():
        op_b, op_c = op[0], op[1]
        e_after = transform_bc_energy(op_b, op_c, bx, by, cx, cy)
        records.append(
            TensorInvariantRecord(
                op=op,
                op_b=op_b,
                op_c=op_c,
                is_invariant=_exact_equal(e_before, e_after),
                e_before=float(e_before),
                e_after=float(e_after),
            )
        )
    return records


def analyze_a_invariant_subspace(ax: Numeric, ay: Numeric) -> list[TensorInvariantRecord]:
    """
    Same 15-operator audit on a-axis quadratic energy.

    Only op_b acts on (ax, ay); tensor label retained for cross-channel comparison.
    """
    e_before = energy_pair_from_amplitudes(ax, ay)
    records: list[TensorInvariantRecord] = []
    for op in tensor_operators():
        op_b, op_c = op[0], op[1]
        a_t = apply_pauli_to_pair(op_b, ax, ay, vx_key="ax", vy_key="ay")
        e_after = energy_pair_from_amplitudes(a_t["ax"], a_t["ay"])
        records.append(
            TensorInvariantRecord(
                op=op,
                op_b=op_b,
                op_c=op_c,
                is_invariant=_exact_equal(e_before, e_after),
                e_before=float(e_before),
                e_after=float(e_after),
            )
        )
    return records


def invariant_count(records: Sequence[TensorInvariantRecord]) -> int:
    """Count records flagged invariant."""
    return sum(1 for rec in records if rec.is_invariant)


def build_tensor_invariant_analysis(
    bx: float,
    by: float,
    cx: float,
    cy: float,
    *,
    ax: float | None = None,
    ay: float | None = None,
) -> dict[str, Any]:
    """Build exportable analysis dict for bc (and optional a-axis) tensor invariants."""
    bc_records = analyze_bc_invariant_subspace(bx, by, cx, cy)
    bc_count = invariant_count(bc_records)
    total_ops = len(tensor_operators())

    analysis: dict[str, Any] = {
        "tag": TENSOR_INVARIANT_TAG,
        "claim_id": GOVERNANCE["claim_id"],
        "evidence_id": "E-094",
        "orq_id": "ORQ-094",
        "governance": GOVERNANCE,
        "amplitudes": {"bx": bx, "by": by, "cx": cx, "cy": cy},
        "bc_records": [rec.as_dict() for rec in bc_records],
        "summary": {
            "total_operators": total_ops,
            "bc_invariant_count": bc_count,
            "all_bc_invariant": bc_count == total_ops,
            "algebraic_expectation": "15/15 under per-pair Pauli on b and c",
        },
        "symbolic_invariants": {
            op: is_bc_energy_invariant(op[0], op[1]) for op in tensor_operators()
        },
    }

    if ax is not None and ay is not None:
        a_records = analyze_a_invariant_subspace(ax, ay)
        a_count = invariant_count(a_records)
        analysis["amplitudes"]["ax"] = ax
        analysis["amplitudes"]["ay"] = ay
        analysis["a_records"] = [rec.as_dict() for rec in a_records]
        analysis["summary"]["a_invariant_count"] = a_count
        analysis["summary"]["all_a_invariant"] = a_count == total_ops

    return analysis


def export_tensor_invariants_json(analysis: dict[str, Any], path: Path | str) -> Path:
    """Write tensor invariant analysis dict to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
