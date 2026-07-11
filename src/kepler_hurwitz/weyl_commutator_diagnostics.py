"""
Weyl-Commutator diagnostics — L/R asymmetry for Hurwitz quaternion elements.

Governance: [B] experimental — measures non-commutative defect via left vs. right
multiplication matrices. Not a Dedekind proof; complements norm_signature_defect.

See docs/theory/weyl_commutator_operator_bridge.md (ORQ-087).
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Sequence

from kepler_hurwitz.primvierling import Primvierling, symmetry_shift_ceab

WEYL_COMMUTATOR_TAG = "[B]"

__all__ = [
    "WEYL_COMMUTATOR_TAG",
    "WeylCommutatorRecord",
    "ceab_nullmodel",
    "channel_shuffle_nullmodel",
    "delta_lr_norm",
    "delta_lr_norm_from_primvierling",
    "left_right_multiplication_matrices",
    "primvierling_to_gamma",
]


def primvierling_to_gamma(v: Primvierling) -> tuple[int, int, int, int]:
    """Map Primvierling components (a,b,c,e) to quaternion coefficients (a,b,c,e)."""
    if len(v) != 4:
        raise ValueError("Primvierling must have four components")
    return tuple(int(x) for x in v)


def _quaternion_multiply(
    p: Sequence[int],
    q: Sequence[int],
) -> tuple[int, int, int, int]:
    """Hamilton product in basis (1, i, j, k) with p=(p0,p1,p2,p3)."""
    a0, a1, a2, a3 = p
    b0, b1, b2, b3 = q
    return (
        a0 * b0 - a1 * b1 - a2 * b2 - a3 * b3,
        a0 * b1 + a1 * b0 + a2 * b3 - a3 * b2,
        a0 * b2 - a1 * b3 + a2 * b0 + a3 * b1,
        a0 * b3 + a1 * b2 - a2 * b1 + a3 * b0,
    )


def left_right_multiplication_matrices(
    gamma: Sequence[int],
) -> tuple[tuple[tuple[float, ...], ...], tuple[tuple[float, ...], ...]]:
    """
    Return (L_gamma, R_gamma) as 4x4 real matrices acting on (1,i,j,k) coefficients.
    """
    if len(gamma) != 4:
        raise ValueError("gamma must have four components")
    basis = (
        (1, 0, 0, 0),
        (0, 1, 0, 0),
        (0, 0, 1, 0),
        (0, 0, 0, 1),
    )
    left_rows: list[tuple[float, ...]] = []
    right_rows: list[tuple[float, ...]] = []
    for unit in basis:
        left_product = _quaternion_multiply(gamma, unit)
        right_product = _quaternion_multiply(unit, gamma)
        left_rows.append(tuple(float(x) for x in left_product))
        right_rows.append(tuple(float(x) for x in right_product))
    return tuple(left_rows), tuple(right_rows)


def _frobenius_norm(matrix: Sequence[Sequence[float]]) -> float:
    return math.sqrt(sum(value * value for row in matrix for value in row))


def _matrix_difference(
    left: Sequence[Sequence[float]],
    right: Sequence[Sequence[float]],
) -> tuple[tuple[float, ...], ...]:
    return tuple(
        tuple(float(a) - float(b) for a, b in zip(left_row, right_row))
        for left_row, right_row in zip(left, right)
    )


def delta_lr_norm(gamma: Sequence[int]) -> float:
    """
    Frobenius norm ||L_gamma - R_gamma||_F — proxy for [gamma, ·] asymmetry.

    Operationalizes Δ_LR(γ) from ORQ-087 at the level of left vs. right regular
    representations. Reference operator H is implicit in the L/R split.
    """
    left, right = left_right_multiplication_matrices(gamma)
    diff = _matrix_difference(left, right)
    return _frobenius_norm(diff)


def delta_lr_norm_from_primvierling(v: Primvierling) -> float:
    return delta_lr_norm(primvierling_to_gamma(v))


def ceab_nullmodel(v: Primvierling) -> Primvierling:
    """CEAB rotation null model — preserves multiset, permutes axis order."""
    return symmetry_shift_ceab(v)


def channel_shuffle_nullmodel(v: Primvierling, swap: tuple[int, int] = (0, 2)) -> Primvierling:
    """Permute two component slots — destroys gap law while keeping primes."""
    a, b, c, e = v
    components = [a, b, c, e]
    i, j = swap
    components[i], components[j] = components[j], components[i]
    return tuple(components)  # type: ignore[return-value]


@dataclass(frozen=True)
class WeylCommutatorRecord:
    primvierling: Primvierling
    delta_lr: float
    ceab_delta_lr: float
    shuffle_delta_lr: float
    tag: str = WEYL_COMMUTATOR_TAG


def build_weyl_commutator_record(v: Primvierling) -> WeylCommutatorRecord:
    return WeylCommutatorRecord(
        primvierling=v,
        delta_lr=delta_lr_norm_from_primvierling(v),
        ceab_delta_lr=delta_lr_norm_from_primvierling(ceab_nullmodel(v)),
        shuffle_delta_lr=delta_lr_norm_from_primvierling(channel_shuffle_nullmodel(v)),
    )
