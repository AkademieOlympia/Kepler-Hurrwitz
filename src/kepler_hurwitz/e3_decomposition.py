"""
Canonical e³ decomposition for n = e * a.

[B] diagnostic — pure arithmetic identity n = q * e³ + r * e with
q = a // e² and r = a % e². Does not replace oddCore/Syracuse, does not
prove Collatz, and does not strengthen the Collatz conjecture.

Lemma 2 product split: when r = b * c, n = q * e³ + b * c * e.
Fine-structure / hyperfine analogy is [C] heuristic bridge only — not
physics identity, not Collatz proof, not EABC physical claim.
"""

from __future__ import annotations

from typing import Any, Literal

E3_DECOMPOSITION_TAG = "[B]"
E3_PRODUCT_ANALOGY_TAG = "[C]"

CaseType = Literal[
    "valid_product_split",
    "invalid_rest_product",
    "invalid_e",
]

__all__ = [
    "E3_DECOMPOSITION_TAG",
    "E3_PRODUCT_ANALOGY_TAG",
    "abc_split_decomposition",
    "analyze_e3_decomposition",
    "analyze_e3_with_product_split",
    "e3_decompose",
    "verify_abc_split",
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


def abc_split_decomposition(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Return the Lemma-2 split ``n = q * e³ + b * c * e`` when ``r = b * c``.

    ``e * a = q * e³ + r * e`` with ``a = q * e² + r``; if ``r = b * c`` then
    ``n = q * e³ + b * c * e``.
    """
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    e3 = e**3
    product = b * c
    split_n = q * e3 + product * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "q": q,
        "r": r,
        "n": n,
        "product": product,
        "rest_matches_product": r == product,
        "split_identity": f"n = q*e³ + b*c*e = {q}*{e3} + {b}*{c}*{e} = {split_n}",
        "split_holds": split_n == n,
        "product_below_e2": product < e * e,
    }


def verify_abc_split(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """Check ``r = b * c`` and return ``n``, ``q``, and the product-split form."""
    _validate_positive_e(e)
    q, r, n = e3_decompose(a, e)
    product = b * c
    e2 = e * e
    e3 = e**3
    rest_matches = r == product
    split_holds = n == q * e3 + product * e
    return {
        "governance": E3_DECOMPOSITION_TAG,
        "valid": rest_matches and split_holds,
        "a": a,
        "e": e,
        "b": b,
        "c": c,
        "q": q,
        "r": r,
        "n": n,
        "product": product,
        "rest_matches_product": rest_matches,
        "split_holds": split_holds,
        "product_below_e2": product < e2 if rest_matches else None,
        "split_form": f"{q}*e³ + {b}*{c}*e",
        "analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "analogy_note": (
            "Fine-structure / hyperfine perturbation analogy is [C] heuristic "
            "bridge only — not physics identity, not Collatz proof."
        ),
    }


def analyze_e3_with_product_split(a: int, e: int, b: int, c: int) -> dict[str, Any]:
    """
    Analyze Lemma-1 decomposition together with a candidate product split ``r = b * c``.
    """
    base = analyze_e3_decomposition(a, e)
    split = abc_split_decomposition(a, e, b, c)
    product = b * c

    if e <= 0:
        case_type: CaseType = "invalid_e"
    elif base["r"] != product:
        case_type = "invalid_rest_product"
    else:
        case_type = "valid_product_split"

    return {
        **base,
        "case_type": case_type,
        "b": b,
        "c": c,
        "product": product,
        "rest_matches_product": split["rest_matches_product"],
        "split_holds": split["split_holds"],
        "product_below_e2": split["product_below_e2"],
        "split_identity": split["split_identity"],
        "analogy_governance": E3_PRODUCT_ANALOGY_TAG,
        "analogy_note": (
            "Fine-structure / hyperfine perturbation analogy is [C] heuristic "
            "bridge only — not physics identity, not Collatz proof."
        ),
    }
