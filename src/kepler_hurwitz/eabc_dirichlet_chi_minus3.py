"""
Dirichlet character chi_{-3} as EABC a/bc axis conjugator — hypothesis scaffold [C].

The quadratic character chi_{-3}(n) distinguishes 6k+1 (axis a, chi=+1) from
6k-1 (axis bc, chi=-1) and vanishes on multiples of 3. Plain zeta prime sums
treat both axes symmetrically; L(s, chi_{-3}) weights contributions with the
character and acts as the mathematical conjugator between a and bc.

Governance: [A/B] for character values on residue classes; [C] for EABC
quaternion identification and resonance reading. Does not claim RH proof or that
partial sums converge to full L-function values without analytic continuation.

Sibling to ``eabc_monopole_axis_resonance`` and E-093 Black Hole register.
See ``docs/theory/eabc_dirichlet_chi_minus3_conjugator.md``.
"""

from __future__ import annotations

import math
from dataclasses import asdict, dataclass
from typing import Any, Sequence

from kepler_hurwitz.eabc_monopole_axis_resonance import compute_resonance, get_prime_axes
from kepler_hurwitz.eabc_six_state_prime_axes import get_eabc_state

DIRICHLET_CHI_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive conjugator scaffold with A/B character facts",
    "tag_interpretive": DIRICHLET_CHI_TAG,
    "not_claimed": (
        "proof of the Riemann Hypothesis; full analytic L(s, chi_{-3}) evaluation; "
        "that zeta alone splits mod-6 axes without Dirichlet weighting; "
        "discovery-taugliche resonance asymmetry without preregistration"
    ),
    "facts_ab": (
        "chi_{-3}(n)=0 iff 3|n; chi_{-3}(n)=+1 iff n≡1 (mod 3) [6k+1 odd primes → a]; "
        "chi_{-3}(n)=-1 iff n≡2 (mod 3) [6k-1 odd primes → bc]"
    ),
    "reading_c": (
        "L(s, chi_{-3}) conjugates a↔bc; unweighted zeta-style sums are axis-symmetric; "
        "chi-weighted resonance exposes a-vs-bc asymmetry"
    ),
    "sibling_register": "E-093",
    "related_modules": "eabc_monopole_axis_resonance, eabc_six_state_prime_axes",
}

__all__ = [
    "DIRICHLET_CHI_TAG",
    "GOVERNANCE",
    "AxisResonanceComparison",
    "chi_minus3",
    "compare_zeta_vs_lchi_axis_resonance",
    "compute_l_chi_partial_sum",
    "compute_l_chi_resonance_sum",
    "split_prime_contribution",
    "zeta_style_prime_sum",
]


def chi_minus3(n: int) -> int:
    """
    Quadratic Dirichlet character chi_{-3} on positive integers.

    Returns +1, -1, or 0 (multiples of 3). For odd primes p > 3:
    chi_{-3}(p) = +1 on axis a (p ≡ 1 mod 6), -1 on axis bc (p ≡ 5 mod 6).
    """
    if n <= 0:
        return 0
    r = n % 3
    if r == 0:
        return 0
    return 1 if r == 1 else -1


def split_prime_contribution(p: int, *, s_real: float = 0.5) -> dict[str, Any]:
    """
    Per-prime contribution to L(s, chi_{-3}) Euler product / partial sum [C].

  ``weight`` = chi_{-3}(p) * p^{-s_real}; ``resonance_weight`` uses cos(gamma ln p)/sqrt(p)
  when ``gamma`` is supplied via ``compare_zeta_vs_lchi_axis_resonance``.
    """
    if p < 2:
        raise ValueError("p must be >= 2")
    chi = chi_minus3(p)
    state = get_eabc_state(p) if p > 3 else "other"
    axis = state if state in {"a", "bc"} else None
    return {
        "p": p,
        "chi": chi,
        "axis": axis,
        "state": state,
        "weight": chi * (p ** (-s_real)) if chi != 0 else 0.0,
        "tag": DIRICHLET_CHI_TAG,
    }


def compute_l_chi_partial_sum(s_real: float, prime_limit: int) -> float:
    """Dirichlet-L partial sum sum_{p <= L} chi_{-3}(p) p^{-s_real} over primes."""
    if prime_limit < 2:
        return 0.0
    total = 0.0
    for p in _primes_up_to(prime_limit):
        chi = chi_minus3(p)
        if chi != 0:
            total += chi * (p ** (-s_real))
    return total


def compute_l_chi_resonance_sum(gamma: float, prime_limit: int) -> float:
    """
    Chi-weighted resonance sum along Re(s)=1/2 for EABC prime axes (p > 3):

    sum_{p>3} chi_{-3}(p) cos(gamma ln p) / sqrt(p) = psi_a - psi_bc.
    """
    if prime_limit < 2:
        return 0.0
    total = 0.0
    for p in _primes_up_to(prime_limit):
        if p <= 3:
            continue
        chi = chi_minus3(p)
        total += chi * math.cos(gamma * math.log(p)) / math.sqrt(p)
    return total


def zeta_style_prime_sum(gamma: float, prime_limit: int) -> float:
    """Unweighted zeta-style prime sum: sum_p cos(gamma ln p) / sqrt(p) (symmetric in axes)."""
    if prime_limit < 2:
        return 0.0
    total = 0.0
    for p in _primes_up_to(prime_limit):
        if p > 3:
            total += math.cos(gamma * math.log(p)) / math.sqrt(p)
    return total


@dataclass(frozen=True)
class AxisResonanceComparison:
    gamma: float
    prime_limit: int
    psi_a: float
    psi_bc: float
    zeta_symmetric_sum: float
    lchi_weighted_sum: float
    delta_unweighted: float
    asymmetry_ratio: float
    zeta_symmetry_score: float
    tag: str = DIRICHLET_CHI_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def compare_zeta_vs_lchi_axis_resonance(
    gamma: float,
    prime_limit: int,
) -> AxisResonanceComparison:
    """
    Contrast axis-symmetric zeta-style sums with chi_{-3}-weighted L-resonance.

    ``zeta_symmetric_sum`` pools all prime-axis primes without character sign;
    ``lchi_weighted_sum`` applies chi_{-3} (+1 on a, -1 on bc), equivalent to
    psi_a - psi_bc. ``asymmetry_ratio`` = |lchi| / max(|zeta_symmetric|, eps) highlights
    how character weighting breaks naive symmetry.
    """
    axis_a, axis_bc = get_prime_axes(prime_limit)
    psi_a = compute_resonance(gamma, axis_a)
    psi_bc = compute_resonance(gamma, axis_bc)
    zeta_sym = zeta_style_prime_sum(gamma, prime_limit)
    lchi = compute_l_chi_resonance_sum(gamma, prime_limit)
    delta = psi_a - psi_bc
    eps = 1e-15
    denom = max(abs(zeta_sym), eps)
    asymmetry = abs(lchi) / denom
    # Symmetry score near 1 when axis contributions balance; drops when lchi dominates.
    balance = abs(psi_a + psi_bc)
    zeta_symmetry_score = balance / max(abs(lchi), eps)
    return AxisResonanceComparison(
        gamma=float(gamma),
        prime_limit=prime_limit,
        psi_a=psi_a,
        psi_bc=psi_bc,
        zeta_symmetric_sum=zeta_sym,
        lchi_weighted_sum=lchi,
        delta_unweighted=delta,
        asymmetry_ratio=asymmetry,
        zeta_symmetry_score=zeta_symmetry_score,
    )


def compare_zeros_batch(
    gammas: Sequence[float],
    prime_limit: int,
) -> list[AxisResonanceComparison]:
    return [compare_zeta_vs_lchi_axis_resonance(g, prime_limit) for g in gammas]


def _primes_up_to(limit: int) -> list[int]:
    if limit < 2:
        return []
    sieve = bytearray(b"\x01") * (limit + 1)
    sieve[0:2] = b"\x00\x00"
    for p in range(2, int(limit**0.5) + 1):
        if sieve[p]:
            step = p
            start = p * p
            sieve[start : limit + 1 : step] = b"\x00" * ((limit - start) // step + 1)
    return [i for i in range(2, limit + 1) if sieve[i]]
