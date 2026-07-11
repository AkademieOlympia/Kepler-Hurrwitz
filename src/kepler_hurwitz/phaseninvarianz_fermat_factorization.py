"""
Fermat factorization bridge via EABC cross-talk disturbance ΔE [C].

ΔE = (bx²-cx²)(cy²-by²) = (bx-cx)(bx+cx)(cy-by)(cy+by) — difference of squares.
Composite n on the bc-axis (n ≡ 5 mod 6) admits half-integer amplitude patterns whose
cross-talk geometry reconstructs prime factors [C].

Governance: [A/B] for Fermat / ΔE algebra; [C] for symmetry-degeneration reading.
Sibling: phaseninvarianz_crosstalk.py (PI-C-03). Claim: PI-C-04.
See docs/theory/phaseninvarianz_fermat_factorization_bridge.md.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

from kepler_hurwitz.phaseninvarianz_crosstalk import crosstalk_delta_e

FERMAT_TAG = "[C]"

GOVERNANCE: dict[str, str] = {
    "status": "C interpretive Fermat bridge with A/B ΔE / difference-of-squares facts",
    "tag_interpretive": FERMAT_TAG,
    "facts_ab": (
        "ΔE = (bx²-cx²)(cy²-by²) = (bx-cx)(bx+cx)(cy-by)(cy+by); "
        "fermat_split_difference_of_squares(x²,y²) = x²-y²; "
        "for odd factor f: bx=(f+1)/2, cx=(f-1)/2 gives bx²-cx²=f via unit Fermat split"
    ),
    "reading_c": (
        "factorization on bc-axis composites = degeneration of entangled bivector prime "
        "state under cross-talk symmetry break; amplitude quantization to integer/"
        "half-integer patterns reconstructs factors — constructive example, not a general "
        "factorization algorithm claim"
    ),
    "not_claimed": (
        "polynomial-time factorization of arbitrary integers; "
        "that all bc-axis composites admit unique amplitude geometry; "
        "number-theoretic proof of primality from ΔE=0; "
        "replacement of classical Fermat or GNFS methods"
    ),
    "sibling_register": "E-094",
    "claim_id": "PI-C-04",
    "related_scripts": (
        "fermat_factorization_via_crosstalk.sage, phaseninvarianz_crosstalk.py, "
        "eabc_six_state_prime_axes.py"
    ),
}

__all__ = [
    "FERMAT_TAG",
    "GOVERNANCE",
    "AmplitudeFactorizationResult",
    "amplitudes_from_odd_factor",
    "delta_e_factored_form",
    "export_fermat_factorization_json",
    "factorint_trial",
    "fermat_split_difference_of_squares",
    "find_amplitudes_for_factors",
    "is_on_bc_axis",
    "reconstruct_from_amplitudes",
]


def is_on_bc_axis(n: int) -> bool:
    """True iff n > 3 and n ≡ 5 (mod 6) — EABC bc bivector axis."""
    return n > 3 and n % 6 == 5


def fermat_split_difference_of_squares(x2: float, y2: float) -> float:
    """
    Numeric difference-of-squares split: (x-y)(x+y) = x² - y².

    Parameters x2, y2 are squared amplitudes (e.g. bx², cx²).
    """
    return x2 - y2


def delta_e_factored_form(
    bx: float,
    cx: float,
    by: float,
    cy: float,
) -> tuple[float, float, float, float]:
    """
    Four linear factors of ΔE = (bx²-cx²)(cy²-by²).

    Returns (bx-cx, bx+cx, cy-by, cy+by).
    """
    return (bx - cx, bx + cx, cy - by, cy + by)


def reconstruct_from_amplitudes(bx: float, cx: float, by: float, cy: float) -> float:
    """ΔE product (bx²-cx²)(cy²-by²) from amplitude geometry."""
    return fermat_split_difference_of_squares(bx * bx, cx * cx) * fermat_split_difference_of_squares(
        cy * cy, by * by
    )


def factorint_trial(n: int) -> dict[int, int]:
    """Pure-Python trial division factorization (sympy-free)."""
    if n < 2:
        raise ValueError("n must be >= 2")
    factors: dict[int, int] = {}
    m = n
    d = 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors


def amplitudes_from_odd_factor(f: int) -> tuple[float, float]:
    """
    Fermat unit split for odd f: f = (bx-cx)(bx+cx) with bx-cx=1.

    Returns (bx, cx) with bx²-cx² = f.
    """
    if f <= 0 or f % 2 == 0:
        raise ValueError(f"require positive odd factor; got {f}")
    bx = (f + 1) / 2.0
    cx = (f - 1) / 2.0
    return bx, cx


@dataclass(frozen=True)
class AmplitudeFactorizationResult:
    """Cross-talk amplitude reconstruction of a bc-axis semiprime."""

    n: int
    on_bc_axis: bool
    prime_factors: tuple[int, ...]
    bx: float | None
    cx: float | None
    by: float | None
    cy: float | None
    factor1: int | None
    factor2: int | None
    delta_e: float | None
    reconstructed_product: float | None
    success: bool
    message: str
    tag: str = FERMAT_TAG

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def find_amplitudes_for_factors(n: int) -> AmplitudeFactorizationResult:
    """
    Reconstruct semiprime factors from cross-talk ΔE amplitude geometry.

    Algorithm:
    1. Require bc-axis (n ≡ 5 mod 6, n > 3).
    2. Factor n; require exactly two distinct odd prime factors (semiprime).
    3. Map p → (bx, cx), q → (cy, by) via unit Fermat split on each factor.
    4. Verify reconstruct_from_amplitudes equals n.
    """
    if n < 2:
        return AmplitudeFactorizationResult(
            n=n,
            on_bc_axis=False,
            prime_factors=(),
            bx=None,
            cx=None,
            by=None,
            cy=None,
            factor1=None,
            factor2=None,
            delta_e=None,
            reconstructed_product=None,
            success=False,
            message="n must be >= 2",
        )

    on_axis = is_on_bc_axis(n)
    if not on_axis:
        return AmplitudeFactorizationResult(
            n=n,
            on_bc_axis=False,
            prime_factors=tuple(),
            bx=None,
            cx=None,
            by=None,
            cy=None,
            factor1=None,
            factor2=None,
            delta_e=None,
            reconstructed_product=None,
            success=False,
            message=f"n={n} not on bc-axis (require n>3 and n%6==5)",
        )

    fac = factorint_trial(n)
    distinct = [p for p, exp in sorted(fac.items()) if exp > 0]
    if len(distinct) != 2 or any(fac[p] != 1 for p in distinct):
        return AmplitudeFactorizationResult(
            n=n,
            on_bc_axis=True,
            prime_factors=tuple(distinct),
            bx=None,
            cx=None,
            by=None,
            cy=None,
            factor1=None,
            factor2=None,
            delta_e=None,
            reconstructed_product=None,
            success=False,
            message=f"n={n} on bc-axis but not a semiprime with two distinct primes",
        )

    p, q = distinct
    if p % 2 == 0 or q % 2 == 0:
        return AmplitudeFactorizationResult(
            n=n,
            on_bc_axis=True,
            prime_factors=(p, q),
            bx=None,
            cx=None,
            by=None,
            cy=None,
            factor1=p,
            factor2=q,
            delta_e=None,
            reconstructed_product=None,
            success=False,
            message="even prime factor not supported by unit Fermat split",
        )

    bx, cx = amplitudes_from_odd_factor(p)
    cy, by = amplitudes_from_odd_factor(q)
    delta = crosstalk_delta_e(bx, by, cx, cy)
    product = reconstruct_from_amplitudes(bx, cx, by, cy)
    ok = abs(product - n) < 1e-9 and abs(delta - product) < 1e-9

    return AmplitudeFactorizationResult(
        n=n,
        on_bc_axis=True,
        prime_factors=(p, q),
        bx=bx,
        cx=cx,
        by=by,
        cy=cy,
        factor1=p,
        factor2=q,
        delta_e=delta,
        reconstructed_product=product,
        success=ok,
        message=f"reconstructed {int(p)}*{int(q)}={int(product)}" if ok else "reconstruction mismatch",
    )


def export_fermat_factorization_json(analysis: dict[str, Any], path: Path | str) -> Path:
    """Write Fermat factorization analysis dict to JSON."""
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(analysis, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return out
