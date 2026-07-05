from __future__ import annotations

from collections import Counter
from dataclasses import dataclass
from typing import Tuple

from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12
from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.smoothness_channel_scan import prime_factors

# Lean `EABCSignature4` / `EABCSignature4.totalWeight` in KeplerHurwitz/EABCLayer.lean


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
