from __future__ import annotations

import math
from collections import Counter
from dataclasses import dataclass
from enum import Enum
from typing import Tuple

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.smoothness_channel_scan import prime_factors

# Lean `EABCSignature4` / `EABCSignature4.totalWeight` in KeplerHurwitz/EABCLayer.lean
# Lean normal form: KeplerHurwitz/EABC/NormalForm.lean · docs/eabc_normal_form.md
# Nomenklatur: normal-form factor `e` (mod-12 E) ≠ Kepler eccentricity `e_kep`
# (Lean `eccentricity` / `projectToKepler`); see docs/eabc_normal_form.md §7.


@dataclass(frozen=True)
class EABCSignature4:
    """Additive EABC channel counts H(n) = (E, A, B, C)."""

    E: int
    A: int
    B: int
    C: int

    def total_weight(self) -> int:
        return self.E + self.A + self.B + self.C

    def as_tuple(self) -> tuple[int, int, int, int]:
        return (self.E, self.A, self.B, self.C)

    def channels(self) -> tuple[int, int, int, int]:
        return self.as_tuple()

    def sorted_counts(self) -> tuple[int, int, int, int]:
        """Non-increasing channel multiset (Phase-4 partition typing)."""
        return tuple(sorted(self.as_tuple(), reverse=True))

    def max_channel(self) -> int:
        return max(self.as_tuple())

    def min_channel(self) -> int:
        return min(self.as_tuple())

    def spread(self) -> int:
        return self.max_channel() - self.min_channel()


def signature_from_nat(n: int) -> EABCSignature4:
    """
    Build H(n) by counting EABC-class prime divisors with multiplicity.

    Convention: skip p in {2, 3}; map p > 3 via mod-12 residues 1/5/7/11 → E/A/B/C.
    See ``docs/eabc_mass_convention.md``.
    """
    if n < 1:
        raise ValueError("n must be >= 1")

    counts = {channel: 0 for channel in EABCChannel}
    for prime in prime_factors(n):
        if prime <= 3:
            continue
        channel = eabc_channel_from_mod12(prime)
        counts[channel] += 1

    return EABCSignature4(
        E=counts[EABCChannel.E],
        A=counts[EABCChannel.A],
        B=counts[EABCChannel.B],
        C=counts[EABCChannel.C],
    )


def eabc_mass(n: int) -> int:
    """Kanonische EABC-Masse M(n) := totalWeight(H(n))."""
    return signature_from_nat(n).total_weight()


def channel_mass(signature: EABCSignature4) -> int:
    return signature.total_weight()


class ResidualShape(str, Enum):
    """Spoken EABC residual normal-form labels (mod-12 channel E)."""

    REINE_E = "reineE"
    PRIM_TIMES_E = "primTimesE"
    SEMIPRIM_TIMES_E = "semiprimTimesE"
    HIGHER = "higher"


class SemiprimKind(str, Enum):
    """Fine types inside semiprimTimesE (Lean `SemiprimKind`)."""

    SQUARE = "square"
    SAME_CHANNEL = "sameChannel"
    DISTINCT_CHANNEL = "distinctChannel"


@dataclass(frozen=True, slots=True)
class EABCNormalForm:
    """Canonical writing n = 2^α · 3^β · r · e (see docs/eabc_normal_form.md)."""

    n: int
    alpha: int
    beta: int
    core: int
    residual: int
    e_factor: int
    shape: ResidualShape
    signature: EABCSignature4

    @property
    def mass(self) -> int:
        return self.signature.total_weight()

    @property
    def residual_omega(self) -> int:
        return len(prime_factors(self.residual)) if self.residual > 1 else 0

    @property
    def is_reduced(self) -> bool:
        return self.shape is not ResidualShape.HIGHER


def axis_split(n: int) -> tuple[int, int, int]:
    """Return (α, β, κ) with n = 2^α · 3^β · κ and gcd(κ, 6) = 1."""
    if n < 1:
        raise ValueError("n must be >= 1")
    alpha = 0
    core = n
    while core % 2 == 0:
        core //= 2
        alpha += 1
    beta = 0
    while core % 3 == 0:
        core //= 3
        beta += 1
    return alpha, beta, core


def _split_core_residual_e(core: int) -> tuple[int, int]:
    """Split κ into residual r (A/B/C) and E-factor e (channel E)."""
    if core < 1:
        raise ValueError("core must be >= 1")
    residual = 1
    e_factor = 1
    for prime, exp in Counter(prime_factors(core)).items():
        channel = eabc_channel_from_mod12(prime)
        piece = prime**exp
        if channel is EABCChannel.E:
            e_factor *= piece
        else:
            residual *= piece
    return residual, e_factor


def classify_residual(residual: int) -> ResidualShape:
    """Classify residual r by Ω(r) (with multiplicity)."""
    if residual < 0:
        raise ValueError("residual must be >= 0")
    if residual == 1:
        return ResidualShape.REINE_E
    if residual == 0:
        return ResidualShape.HIGHER
    omega = len(prime_factors(residual))
    if omega == 1:
        return ResidualShape.PRIM_TIMES_E
    if omega == 2:
        return ResidualShape.SEMIPRIM_TIMES_E
    return ResidualShape.HIGHER


def eabc_normal_form(n: int) -> EABCNormalForm:
    """Canonical EABC normal form n = 2^α 3^β r e."""
    alpha, beta, core = axis_split(n)
    residual, e_factor = _split_core_residual_e(core)
    return EABCNormalForm(
        n=n,
        alpha=alpha,
        beta=beta,
        core=core,
        residual=residual,
        e_factor=e_factor,
        shape=classify_residual(residual),
        signature=signature_from_nat(n),
    )


class V4(str, Enum):
    """Klein four-group labels for (ℤ/12ℤ)× — Lean `KeplerHurwitz.EABC.V4`."""

    E = "E"
    A = "A"
    B = "B"
    C = "C"


_V4_MUL: dict[tuple[V4, V4], V4] = {
    (V4.E, V4.E): V4.E,
    (V4.E, V4.A): V4.A,
    (V4.E, V4.B): V4.B,
    (V4.E, V4.C): V4.C,
    (V4.A, V4.E): V4.A,
    (V4.A, V4.A): V4.E,
    (V4.A, V4.B): V4.C,
    (V4.A, V4.C): V4.B,
    (V4.B, V4.E): V4.B,
    (V4.B, V4.A): V4.C,
    (V4.B, V4.B): V4.E,
    (V4.B, V4.C): V4.A,
    (V4.C, V4.E): V4.C,
    (V4.C, V4.A): V4.B,
    (V4.C, V4.B): V4.A,
    (V4.C, V4.C): V4.E,
}


def v4_mul(x: V4, y: V4) -> V4:
    """Channel product in V₄."""
    return _V4_MUL[(x, y)]


def to_v4(n: int) -> V4:
    """Project n (coprime to 6) onto V₄ via n mod 12."""
    if n < 1:
        raise ValueError("n must be >= 1")
    if math.gcd(n, 6) != 1:
        raise ValueError("n must be coprime to 6")
    r = n % 12
    if r == 1:
        return V4.E
    if r == 5:
        return V4.A
    if r == 7:
        return V4.B
    if r == 11:
        return V4.C
    raise ValueError(f"unexpected residue {r} for unit mod 12")


def channel_cos(x: V4, y: V4) -> float:
    """
    Triad cosine dictionary on residual channels {A,B,C} (Lean `channelCos`).

    Distinct residual channels sit at 120° → cos = -1/2.
    Same channel → +1.  E is neutral (cos = +1).
    Not the Hamilton {i,j,k} inner product (there cos = 0).
    """
    if x is V4.E or y is V4.E:
        return 1.0
    if x is y:
        return 1.0
    return -0.5


def classify_semiprim_residual(residual: int) -> SemiprimKind | None:
    """Classify Ω(r)=2 residuals; return None if not semiprime-shaped."""
    if residual < 1 or prime_omega(residual) != 2:
        return None
    factors = prime_factors(residual)
    p, q = factors[0], factors[1]
    if p == q:
        return SemiprimKind.SQUARE
    if to_v4(p) == to_v4(q):
        return SemiprimKind.SAME_CHANNEL
    return SemiprimKind.DISTINCT_CHANNEL


def residual_channel_factors(residual: int) -> list[V4]:
    """Prime channel labels of a residual (with multiplicity), empty for r=1."""
    if residual < 1:
        raise ValueError("residual must be >= 1")
    if residual == 1:
        return []
    return [to_v4(p) for p in prime_factors(residual)]


def v4_xor_fold(channels: list[V4]) -> V4:
    """XOR-fold / V₄ product of channel labels (Lean `v4XorFold`)."""
    acc = V4.E
    for ch in channels:
        acc = v4_mul(acc, ch)
    return acc


@dataclass(frozen=True, slots=True)
class HigherReading:
    """
    Structured view of a `higher` residual (Ω ≥ 3) — Lean `HigherReading`.

    Deliberately not a SemiprimKind: class = XOR of prime channels in V₄.
    """

    omega: int
    channels: tuple[V4, ...]
    xor_class: V4


def classify_higher_residual(residual: int) -> HigherReading | None:
    """Return HigherReading iff Ω(r) ≥ 3; else None."""
    if residual < 1:
        raise ValueError("residual must be >= 1")
    omega = prime_omega(residual)
    if omega < 3:
        return None
    channels = tuple(residual_channel_factors(residual))
    return HigherReading(
        omega=omega,
        channels=channels,
        xor_class=v4_xor_fold(list(channels)),
    )


def normal_form_v4(n: int) -> V4:
    """V₄ class of the EABC core; equals to_v4(residual) (E-factor neutral)."""
    nf = eabc_normal_form(n)
    return to_v4(nf.residual)


def prime_factorization_with_multiplicity(n: int) -> list[tuple[int, int]]:
    if n < 1:
        raise ValueError("n must be >= 1")
    if n == 1:
        return []
    return list(Counter(prime_factors(n)).items())


def prime_omega(n: int) -> int:
    """Totale Primfaktorzahl Omega(n) mit Multiplizitaet."""
    if n < 1:
        raise ValueError("n must be >= 1")
    return len(prime_factors(n))


@dataclass(frozen=True)
class HurwitzSignature8D:
    e_plus: int
    e_minus: int
    a_plus: int
    a_minus: int
    b_plus: int
    b_minus: int
    c_plus: int
    c_minus: int

    def total_weight(self) -> int:
        return sum(self.as_tuple())

    def as_tuple(self) -> Tuple[int, ...]:
        return (
            self.e_plus,
            self.e_minus,
            self.a_plus,
            self.a_minus,
            self.b_plus,
            self.b_minus,
            self.c_plus,
            self.c_minus,
        )

    def orientation_balance(self) -> int:
        plus = self.e_plus + self.a_plus + self.b_plus + self.c_plus
        minus = self.e_minus + self.a_minus + self.b_minus + self.c_minus
        return plus - minus
