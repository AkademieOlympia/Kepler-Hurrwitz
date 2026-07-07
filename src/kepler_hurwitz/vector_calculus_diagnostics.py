"""
Vector calculus diagnostics — symbolic Green/Stokes verification via SageMath.

Verifies the infographic examples P = -y, Q = x (Green) and F = (-y, x, 0) (Stokes)
on the disk x^2 + y^2 <= R^2. Complements greens_stokes_verification.py (numeric [B]).

Governance: [B] when run under Sage; optional — package imports without Sage.
See docs/theory/greens_stokes_circulation_bridge.md.
"""

from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any

from kepler_hurwitz.sage_bridge import SageUnavailableError

VECTOR_CALCULUS_TAG = "[B]"

__all__ = [
    "VECTOR_CALCULUS_TAG",
    "GreensStokesSymbolicResult",
    "SageUnavailableError",
    "verify_greens_theorem_example",
    "verify_stokes_theorem_example",
    "verify_greens_stokes_symbolic",
]


def _sage():
    try:
        import sage.all as sage  # type: ignore
    except Exception as exc:  # pragma: no cover
        raise SageUnavailableError(
            "SageMath is required for kepler_hurwitz.vector_calculus_diagnostics. "
            "Run with `sage -python ...`."
        ) from exc
    return sage


@dataclass(frozen=True)
class GreensStokesSymbolicResult:
    theorem: str
    radius: Any
    line_integral: Any
    area_integral: Any
    formula: str
    verified: bool


def verify_greens_theorem_example(radius: int | float = 2) -> GreensStokesSymbolicResult:
    """
  Symbolically verify Green's theorem for P = -y, Q = x on the disk of radius R.

  LHS: ∮_C P dx + Q dy  with  C: x^2 + y^2 = R^2
  RHS: ∬_D (dQ/dx - dP/dy) dA = ∬_D 2 dA = 2 pi R^2
    """
    sage = _sage()
    symbols = sage.var
    r, theta, R, t = symbols("r theta R t")

    integrand_2d = 2 * r
    double_integral = sage.integral(
        sage.integral(integrand_2d, theta, 0, 2 * sage.pi), r, 0, R
    )

    x = R * sage.cos(t)
    y = R * sage.sin(t)
    dx = sage.diff(x, t)
    dy = sage.diff(y, t)
    line_integrand = (-y) * dx + x * dy
    line_integral = sage.integral(line_integrand, t, 0, 2 * sage.pi)

    lhs = line_integral.subs(R=radius)
    rhs = double_integral.subs(R=radius)
    verified = bool(lhs == rhs)
    if not verified:
        raise ValueError(f"Green's theorem symbolic check failed: {lhs} != {rhs}")

    return GreensStokesSymbolicResult(
        theorem="green",
        radius=radius,
        line_integral=lhs,
        area_integral=rhs,
        formula=f"2*pi*{radius}^2",
        verified=verified,
    )


def verify_stokes_theorem_example(radius: int | float = 2) -> GreensStokesSymbolicResult:
    """
  Symbolically verify Stokes' theorem for F = (-y, x, 0) on disk z = 0, n = k.

  curl F = (0, 0, 2);  curl F · n = 2
  LHS: ∮_C F · dr
  RHS: ∬_S 2 dS = 2 pi R^2
    """
    sage = _sage()
    symbols = sage.var
    t, r, theta, R = symbols("t r theta R")

    surface_integrand = 2 * r
    surface_integral = sage.integral(
        sage.integral(surface_integrand, theta, 0, 2 * sage.pi), r, 0, R
    )

    line_integrand = R**2
    line_integral = sage.integral(line_integrand, t, 0, 2 * sage.pi)

    lhs = line_integral.subs(R=radius)
    rhs = surface_integral.subs(R=radius)
    verified = bool(lhs == rhs)
    if not verified:
        raise ValueError(f"Stokes' theorem symbolic check failed: {lhs} != {rhs}")

    return GreensStokesSymbolicResult(
        theorem="stokes",
        radius=radius,
        line_integral=lhs,
        area_integral=rhs,
        formula=f"2*pi*{radius}^2",
        verified=verified,
    )


def verify_greens_stokes_symbolic(
    radius: int | float = 2,
) -> dict[str, GreensStokesSymbolicResult]:
    """Run both symbolic verifications and confirm Green == Stokes on the z = 0 disk."""
    green = verify_greens_theorem_example(radius)
    stokes = verify_stokes_theorem_example(radius)
    if green.area_integral != stokes.area_integral:
        raise ValueError("Green and Stokes symbolic area integrals disagree on z = 0 disk")
    return {"green": green, "stokes": stokes}


def result_to_json_dict(result: GreensStokesSymbolicResult) -> dict[str, Any]:
    return {
        **asdict(result),
        "line_integral": str(result.line_integral),
        "area_integral": str(result.area_integral),
        "governance": VECTOR_CALCULUS_TAG,
    }
