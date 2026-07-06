"""
Canonical e³ decomposition for n = e * a.

[B] diagnostic — pure arithmetic identity n = q * e³ + r * e with
q = a // e² and r = a % e². Does not replace oddCore/Syracuse, does not
prove Collatz, and does not strengthen the Collatz conjecture.
"""

from __future__ import annotations

from typing import Any

E3_DECOMPOSITION_TAG = "[B]"

__all__ = [
    "E3_DECOMPOSITION_TAG",
    "analyze_e3_decomposition",
    "e3_decompose",
    "verify_e3_identity",
]


def _validate_positive_e(e: int) -> None:
    if e <= 0:
        raise ValueError("e must be positive")


def e3_decompose(a: int, e: int) -> tuple[int, int, int]:
    """
    Return ``(q, r, n)`` for the canonical e³ decomposition of ``n = e * a``.

    ``q = a // e²``, ``r = a % e²``, and ``n = q * e³ + r * e``.
    """
    _validate_positive_e(e)
    e2 = e * e
    q = a // e2
    r = a % e2
    n = e * a
    return q, r, n


def verify_e3_identity(a: int, e: int) -> bool:
    """Check whether ``e * a == q * e³ + r * e`` for the canonical ``(q, r)``."""
    q, r, n = e3_decompose(a, e)
    return n == q * (e**3) + r * e


def analyze_e3_decomposition(a: int, e: int) -> dict[str, Any]:
    """
    Analyze the e³ decomposition of ``n = e * a``.

    Returns quotient ``q``, remainder ``r``, product ``n``, and identity check.
    """
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    e2 = e * e
    e3 = e**3
    reconstructed = q * e3 + r * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "a": a,
        "e": e,
        "e2": e2,
        "e3": e3,
        "q": q,
        "r": r,
        "n": n,
        "identity": f"n = q*e³ + r*e = {q}*{e3} + {r}*{e} = {reconstructed}",
        "identity_holds": reconstructed == n,
        "q_is_zero": q == 0,
        "r_below_e2": 0 <= r < e2,
    }
