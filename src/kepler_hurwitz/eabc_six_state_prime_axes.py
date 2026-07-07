"""
EABC six-state / mod-6 prime-axis diagnostics — hypothesis scaffold [C].

Maps naturals to six imaginary quaternion basis labels {a, b, c, ab, ac, bc}
via residue mod 6; primes p > 3 occupy only the conjugate dual pair (a, bc).
Gap transitions among consecutive primes are classified as same-axis or
conjugate-flip rotations in interpretive [C] language.

Governance: [A/B] for mod-6 residue facts; [C] for quaternion conjugation reading.
Does not replace mod-12 EABC channel partition in signatures.py — see
docs/theory/eabc_six_state_prime_axes.md.
Sibling note to E-093 (Black Hole); no new E-ID required.
"""

from __future__ import annotations

from typing import Any

SIX_STATE_TAG = "[C]"

SIX_STATES: tuple[str, ...] = ("a", "b", "c", "ab", "ac", "bc")

MOD6_TO_STATE: dict[int, str] = {
    0: "c",
    1: "a",
    2: "ac",
    3: "ab",
    4: "b",
    5: "bc",
}

PRIME_AXIS_STATES: frozenset[str] = frozenset({"a", "bc"})
BLOCKED_STATES: frozenset[str] = frozenset({"b", "c", "ab", "ac"})

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive scaffold with A/B residue facts",
    "tag_interpretive": SIX_STATE_TAG,
    "not_claimed": (
        "formal quaternion proof of twin-prime, cousin-prime, or sexy-prime conjectures; "
        "replacement of mod-12 E/A/B/C channel partition in signatures.py; "
        "identification of gap-as-rotation with physical spin or GWTC chi_p stratification"
    ),
    "facts_ab": (
        "p > 3 is prime iff p ≡ ±1 (mod 6); mod-6 residue table maps 1→a, 5→bc; "
        "residues 0,2,3,4 are blocked for odd primes > 3"
    ),
    "reading_c": (
        "conjugate axis a↔bc; gap d≡0 (mod 6) same axis; d≡2,4 (mod 6) conjugate flip"
    ),
    "sibling_register": "E-093",
    "mod12_relationship": (
        "mod-6 six-state projection is coarser than mod-12 channel map "
        "(1→E, 5→A, 7→B, 11→C in signatures.eabc_channel_from_mod12)"
    ),
}

__all__ = [
    "BLOCKED_STATES",
    "GOVERNANCE",
    "MOD6_TO_STATE",
    "PRIME_AXIS_STATES",
    "SIX_STATE_TAG",
    "SIX_STATES",
    "analyze_prime_transitions",
    "classify_gap_mod6",
    "get_eabc_state",
    "is_prime_axis_state",
    "is_prime_carrying",
    "prime_gap_transition",
    "primes_up_to",
]


def get_eabc_state(n: int) -> str:
    """Map a natural number to its six-state EABC label via n mod 6."""
    if n < 1:
        raise ValueError("n must be >= 1")
    return MOD6_TO_STATE[n % 6]


def is_prime_axis_state(state: str) -> bool:
    return state in PRIME_AXIS_STATES


def is_prime_carrying(n: int) -> bool:
    """True iff n > 3 and n mod 6 is in {1, 5} (necessary for odd primes > 3)."""
    if n <= 3:
        return False
    return n % 6 in (1, 5)


def classify_gap_mod6(gap: int) -> str:
    """
    Classify prime-gap rotation on the a↔bc axis [C].

    Returns ``same_axis`` (d ≡ 0 mod 6), ``conjugate_flip`` (d ≡ 2,4 mod 6),
    or ``other`` for gaps that do not fall on the even mod-6 ladder.
    """
    if gap < 0:
        raise ValueError("gap must be >= 0")
    residue = gap % 6
    if residue == 0:
        return "same_axis"
    if residue in (2, 4):
        return "conjugate_flip"
    return "other"


def prime_gap_transition(p1: int, p2: int) -> dict[str, Any]:
    """Describe a prime pair transition: gap, states, axis_flip [C]."""
    if p2 <= p1:
        raise ValueError("require p2 > p1")
    gap = p2 - p1
    state1 = get_eabc_state(p1)
    state2 = get_eabc_state(p2)
    gap_class = classify_gap_mod6(gap)
    axis_flip = gap_class == "conjugate_flip" and (
        state1 in PRIME_AXIS_STATES and state2 in PRIME_AXIS_STATES
    )
    return {
        "p1": p1,
        "p2": p2,
        "gap": gap,
        "state1": state1,
        "state2": state2,
        "gap_class": gap_class,
        "axis_flip": axis_flip,
        "tag": SIX_STATE_TAG,
    }


def primes_up_to(limit: int) -> list[int]:
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


def analyze_prime_transitions(limit: int) -> list[dict[str, Any]]:
    """List consecutive prime transitions up to ``limit`` with gap classification."""
    if limit < 2:
        return []
    primes = primes_up_to(limit)
    return [prime_gap_transition(p1, p2) for p1, p2 in zip(primes, primes[1:])]
