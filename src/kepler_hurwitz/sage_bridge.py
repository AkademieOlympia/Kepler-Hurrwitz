from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from kepler_hurwitz.octonionic_slice import (
    circle_locus_mu_s_coefficients,
    quartic_locus_mu_s_coefficients,
)


class SageUnavailableError(RuntimeError):
    """Raised when SageMath is required but unavailable."""


def _sage() -> Any:
    try:
        import sage.all as sage  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise SageUnavailableError(
            "SageMath is required for kepler_hurwitz.sage_bridge. "
            "Run with `sage -python ...`."
        ) from exc
    return sage


@dataclass(frozen=True)
class SageSlicePolynomials:
    """
    Symbolic slice constraints in QQ[mu, S], with S = Q^2.
    """

    ring: Any
    mu: Any
    S: Any
    quartic: Any
    circle: Any


def _poly_from_coefficients(ring: Any, mu: Any, s: Any, coefficients: dict[tuple[int, int], int]) -> Any:
    polynomial = ring.zero()
    for (mu_degree, s_degree), coeff in sorted(coefficients.items(), reverse=True):
        polynomial += ring(coeff) * (mu**mu_degree) * (s**s_degree)
    return polynomial


def sage_loci_polynomials() -> SageSlicePolynomials:
    """
    Build symbolic Grigorian loci in QQ[mu, S], S = Q^2.
    """
    sage = _sage()
    ring = sage.PolynomialRing(sage.QQ, names=("mu", "S"))
    mu, s = ring.gens()
    quartic = _poly_from_coefficients(ring, mu, s, quartic_locus_mu_s_coefficients())
    circle = _poly_from_coefficients(ring, mu, s, circle_locus_mu_s_coefficients())
    return SageSlicePolynomials(
        ring=ring,
        mu=mu,
        S=s,
        quartic=quartic,
        circle=circle,
    )


def sage_interference_point_squared() -> tuple[Any, Any]:
    """
    Interference point in QQ-coordinates for (mu, S=Q^2):
    mu = -5/2, S = 15/4.
    """
    sage = _sage()
    return (-sage.QQ(5) / sage.QQ(2), sage.QQ(15) / sage.QQ(4))


def sage_intersection_points() -> tuple[tuple[Any, Any], tuple[Any, Any]]:
    """
    Geometric intersections in (mu, Q), represented in QQbar.
    """
    sage = _sage()
    q_abs = sage.sqrt(sage.QQ(15)) / sage.QQ(2)
    mu = -sage.QQ(5) / sage.QQ(2)
    return ((mu, q_abs), (mu, -q_abs))


def sage_verify_interference_points() -> dict[str, Any]:
    """
    Symbolically verify that (mu=-5/2, S=15/4) lies on both loci.
    """
    polys = sage_loci_polynomials()
    mu0, s0 = sage_interference_point_squared()
    quartic_residual = polys.quartic(mu0, s0)
    circle_residual = polys.circle(mu0, s0)
    return {
        "mu": mu0,
        "S": s0,
        "quartic_residual": quartic_residual,
        "circle_residual": circle_residual,
        "on_quartic": quartic_residual == 0,
        "on_circle": circle_residual == 0,
        "on_both": quartic_residual == 0 and circle_residual == 0,
    }


def sage_resultant_mu() -> Any:
    """
    Eliminate S from (quartic, circle); returns polynomial in mu.
    """
    polys = sage_loci_polynomials()
    return polys.quartic.resultant(polys.circle, polys.S)


def sage_resultant_Q() -> Any:
    """
    Eliminate mu and lift the S-resultant via S = Q^2 to QQ[Q].
    """
    sage = _sage()
    polys = sage_loci_polynomials()
    resultant_s = polys.quartic.resultant(polys.circle, polys.mu)
    ring_q = sage.PolynomialRing(sage.QQ, names=("Q",))
    q = ring_q.gen()
    lifted = resultant_s.subs({polys.S: q**2})
    return ring_q(lifted)


def sage_export_symbolic_constraints() -> dict[str, str]:
    """
    JSON-friendly snapshot of symbolic constraints and resultants.
    """
    polys = sage_loci_polynomials()
    return {
        "ring": str(polys.ring),
        "variables": "mu,S",
        "substitution": "S=Q^2",
        "quartic": str(polys.quartic),
        "circle": str(polys.circle),
        "resultant_mu": str(sage_resultant_mu()),
        "resultant_Q": str(sage_resultant_Q()),
    }
