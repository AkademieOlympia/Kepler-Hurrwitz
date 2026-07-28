"""
Prime-tower dictionary: Gaussian / Eisenstein / Hurwitz / octonion / Riemann.

Matches docs/eabc_prime_tower_bridge.md and Lean KeplerHurwitz/EABC/PrimeTower.lean.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from enum import Enum

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.primvierling import is_prime
from kepler_hurwitz.signatures import V4, to_v4

__all__ = [
    "GaussianBehavior",
    "EisensteinBehavior",
    "PrimeTowerProfile",
    "Q0_UNIFORM",
    "classify_prime",
    "functional_information_bits",
    "is_double_split_channel_E",
    "is_sum_of_two_squares_prime",
    "note_axis_pure_not_hurwitz_prime",
]


class GaussianBehavior(str, Enum):
    RAMIFIED = "ramified"  # p = 2
    SPLIT = "split"  # ≡ 1 mod 4
    INERT = "inert"  # ≡ 3 mod 4


class EisensteinBehavior(str, Enum):
    RAMIFIED = "ramified"  # p = 3
    SPLIT = "split"  # ≡ 1 mod 3
    INERT = "inert"  # ≡ 2 mod 3


@dataclass(frozen=True, slots=True)
class PrimeTowerProfile:
    p: int
    channel: EABCChannel | None
    v4: V4 | None
    gaussian: GaussianBehavior
    eisenstein: EisensteinBehavior
    two_squares: bool
    mod6_axis: str | None  # "a" | "bc" | None


def is_sum_of_two_squares_prime(p: int) -> bool:
    """Odd prime is sum of two squares iff ≡ 1 mod 4 (also p=2)."""
    if p == 2:
        return True
    if not is_prime(p):
        return False
    return p % 4 == 1


def _gaussian(p: int) -> GaussianBehavior:
    if p == 2:
        return GaussianBehavior.RAMIFIED
    return GaussianBehavior.SPLIT if p % 4 == 1 else GaussianBehavior.INERT


def _eisenstein(p: int) -> EisensteinBehavior:
    if p == 3:
        return EisensteinBehavior.RAMIFIED
    return EisensteinBehavior.SPLIT if p % 3 == 1 else EisensteinBehavior.INERT


def _mod6_axis(p: int) -> str | None:
    if p <= 3:
        return None
    r = p % 6
    if r == 1:
        return "a"
    if r == 5:
        return "bc"
    return None


def classify_prime(p: int) -> PrimeTowerProfile:
    if p < 2 or not is_prime(p):
        raise ValueError(f"expected prime, got {p}")
    channel = eabc_channel_from_mod12(p) if p > 3 else None
    v4 = to_v4(p) if p > 3 else None
    return PrimeTowerProfile(
        p=p,
        channel=channel,
        v4=v4,
        gaussian=_gaussian(p),
        eisenstein=_eisenstein(p),
        two_squares=is_sum_of_two_squares_prime(p),
        mod6_axis=_mod6_axis(p),
    )


def note_axis_pure_not_hurwitz_prime(p: int) -> bool:
    """axisPure has norm p² — not a Hurwitz prime (norm would need to be p)."""
    return p > 1 and is_prime(p)


def is_double_split_channel_E(p: int) -> bool:
    """True iff p lies in channel E: Gaussian∩Eisenstein split among EABC units."""
    if p <= 3 or not is_prime(p):
        return False
    return p % 12 == 1 and p % 4 == 1 and p % 3 == 1


# Default null-model prior on {E,A,B,C}: Dirichlet/residue-class equipartition.
Q0_UNIFORM: tuple[float, float, float, float] = (0.25, 0.25, 0.25, 0.25)


def functional_information_bits(fraction: float, *, q0: str = "uniform") -> float:
    """Model quantity I_{Q0}(E_x) = -log2[F(E_x)] under a documented prior.

    Under reference prior Q0 (default uniform 1/4 on {E,A,B,C}), F = Q0(E_x)
    and I_{Q0} equals D_KL(P || Q0) when P is Q0 renormalized onto E_x.
    For the audit events E∪A (F=1/2) and pure E (F=1/4) the *model values*
    are 1 bit and 2 bit respectively — not intrinsic prime information.

    Pure information arithmetic for Energiedoku bridge E-112 / ORQ-112.
    Does **not** simulate physics, thermodynamics, or EABC dynamics.
    """
    if q0 != "uniform":
        raise ValueError(
            f"unsupported q0={q0!r}; only 'uniform' (Q0=(1/4)^4) is implemented"
        )
    if not (0.0 < fraction <= 1.0):
        raise ValueError(f"fraction must lie in (0, 1], got {fraction}")
    return -math.log2(fraction)
