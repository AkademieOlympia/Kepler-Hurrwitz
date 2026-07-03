from __future__ import annotations

from dataclasses import dataclass
from math import sqrt


@dataclass(frozen=True)
class SlicePoint:
    mu: float
    q: float


def quartic_locus_mu_s_coefficients() -> dict[tuple[int, int], int]:
    """
    Coefficients for the quartic locus in variables (mu, S), S = Q^2.

    The dictionary key is (mu_degree, s_degree).
    """
    return {
        (4, 0): 1,
        (3, 0): 6,
        (2, 1): 2,
        (2, 0): -15,
        (1, 1): 6,
        (1, 0): -56,
        (0, 2): 1,
        (0, 1): 1,
    }


def circle_locus_mu_s_coefficients() -> dict[tuple[int, int], int]:
    """
    Coefficients for the circle locus in variables (mu, S), S = Q^2.

    The dictionary key is (mu_degree, s_degree).
    """
    return {
        (2, 0): 1,
        (1, 0): 4,
        (0, 1): 1,
    }


def _evaluate_bivariate_polynomial(
    mu: float,
    s: float,
    coefficients: dict[tuple[int, int], int],
) -> float:
    value = 0.0
    for (mu_degree, s_degree), coeff in coefficients.items():
        value += float(coeff) * (mu**mu_degree) * (s**s_degree)
    return value


def quartic_locus_mu_s_residual(mu: float, s: float) -> float:
    return _evaluate_bivariate_polynomial(mu, s, quartic_locus_mu_s_coefficients())


def circle_locus_mu_s_residual(mu: float, s: float) -> float:
    return _evaluate_bivariate_polynomial(mu, s, circle_locus_mu_s_coefficients())


def resultant_mu_residual(mu: float) -> float:
    """
    Residual of the eliminated mu-resultant:
    -24*mu^2 - 60*mu.
    """
    return -24.0 * mu**2 - 60.0 * mu


def resultant_s_residual(s: float) -> float:
    """
    Residual of the eliminated S-resultant (S = Q^2):
    576*S^2 - 2160*S.
    """
    return 576.0 * s**2 - 2160.0 * s


def is_admissible_interference(mu: float, s: float, *, tol: float = 1e-9) -> bool:
    """
    Strict admissibility check in (mu, S)-space.

    A point is admissible iff both slice loci and both eliminated resultants
    vanish simultaneously.
    """
    return (
        abs(quartic_locus_mu_s_residual(mu, s)) <= tol
        and abs(circle_locus_mu_s_residual(mu, s)) <= tol
        and abs(resultant_mu_residual(mu)) <= tol
        and abs(resultant_s_residual(s)) <= tol
    )


def quartic_locus_residual(mu: float, q: float) -> float:
    """
    Residual of the Grigorian quartic in the (mu, Q)-slice:

    mu^4 + 6*mu^3 + (2Q^2 - 15)*mu^2 + (6Q^2 - 56)*mu + Q^4 + Q^2 = 0.
    """
    return quartic_locus_mu_s_residual(mu, q**2)


def circle_locus_residual(mu: float, q: float) -> float:
    """
    Residual of the Grigorian circle in the (mu, Q)-slice:

    (mu + 2)^2 + Q^2 = 4.
    """
    return circle_locus_mu_s_residual(mu, q**2)


def point_on_quartic(mu: float, q: float, *, tol: float = 1e-9) -> bool:
    return abs(quartic_locus_residual(mu, q)) <= tol


def point_on_circle(mu: float, q: float, *, tol: float = 1e-9) -> bool:
    return abs(circle_locus_residual(mu, q)) <= tol


def classify_slice_point(mu: float, q: float, *, tol: float = 1e-9) -> str:
    on_quartic = point_on_quartic(mu, q, tol=tol)
    on_circle = point_on_circle(mu, q, tol=tol)
    if on_quartic and on_circle:
        return "both"
    if on_quartic:
        return "quartic"
    if on_circle:
        return "circle"
    return "none"


def intersection_points() -> tuple[SlicePoint, SlicePoint]:
    """
    Special interference points where quartic and circle meet and
    eigenspace dimension jumps.
    """
    q0 = sqrt(15.0) / 2.0
    return (
        SlicePoint(mu=-2.5, q=q0),
        SlicePoint(mu=-2.5, q=-q0),
    )


def lambda_trace(mu: float) -> float:
    """
    Slice trace surrogate for lambda = mu + Q*u with u^2 = -1.
    We use the real-part normalization T(lambda) = mu.
    """
    return mu


def lambda_norm(mu: float, q: float) -> float:
    """
    Slice norm surrogate for lambda = mu + Q*u with u^2 = -1.
    """
    return mu**2 + q**2


def quartic_invariant_residual(trace: float, norm: float) -> float:
    """
    Grigorian quartic in trace/norm variables:
    N^2 + (3T + 1)N - 4T^2 - 28T = 0.
    """
    return norm**2 + (3.0 * trace + 1.0) * norm - 4.0 * trace**2 - 28.0 * trace


def circle_invariant_residual(trace: float, norm: float) -> float:
    """
    Grigorian circle in trace/norm variables:
    N + 2T = 0.
    """
    return norm + 2.0 * trace


def slice_constraint_record(mu: float, q: float) -> dict[str, float | str]:
    trace = lambda_trace(mu)
    norm = lambda_norm(mu, q)
    s = q**2
    return {
        "mu": mu,
        "q": q,
        "s": s,
        "trace": trace,
        "norm": norm,
        "quartic_mu_q_residual": quartic_locus_residual(mu, q),
        "circle_mu_q_residual": circle_locus_residual(mu, q),
        "quartic_mu_s_residual": quartic_locus_mu_s_residual(mu, s),
        "circle_mu_s_residual": circle_locus_mu_s_residual(mu, s),
        "resultant_mu_residual": resultant_mu_residual(mu),
        "resultant_s_residual": resultant_s_residual(s),
        "is_admissible_interference": is_admissible_interference(mu, s),
        "quartic_trace_norm_residual": quartic_invariant_residual(trace, norm),
        "circle_trace_norm_residual": circle_invariant_residual(trace, norm),
        "class": classify_slice_point(mu, q),
    }


def quaternionic_associator_vanishes() -> bool:
    """
    In H (associative), the mixed associator term vanishes identically.
    """
    return True
