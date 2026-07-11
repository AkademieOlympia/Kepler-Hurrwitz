"""
Green and Stokes theorem numerical verification — rotation field on a disk.

Verifies the canonical example F = (-y, x, 0) on the disk x^2 + y^2 <= R^2
in the plane z = 0. Both sides equal 2*pi*R^2.

Governance: [B] — reproducible analysis reference for ORQ-089 circulation language.
See docs/theory/greens_stokes_circulation_bridge.md.
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path

GREENS_STOKES_TAG = "[B]"

REFERENCE_FIELD = "F = <-y, x, 0>"
REFERENCE_CURL_Z = 2.0

__all__ = [
    "GREENS_STOKES_TAG",
    "REFERENCE_CURL_Z",
    "REFERENCE_FIELD",
    "GreensStokesVerification",
    "analytic_value",
    "curl_z_rotation_field",
    "greens_scalar_curl",
    "line_integral_rotation_field",
    "greens_double_integral",
    "stokes_surface_integral",
    "verify_greens_stokes",
    "export_verification_json",
]


@dataclass(frozen=True)
class GreensStokesVerification:
    governance: str
    radius: float
    n_samples: int
    analytic: float
    line_integral: float
    greens_double_integral: float
    stokes_surface_integral: float
    greens_scalar_curl: float
    curl_z: float
    line_relative_error: float
    greens_relative_error: float
    stokes_relative_error: float
    green_equals_stokes: bool


def analytic_value(radius: float) -> float:
    """Exact circulation / flux for F = (-y, x, 0) on disk of radius R."""
    if radius <= 0:
        raise ValueError("radius must be positive")
    return 2.0 * math.pi * radius * radius


def greens_scalar_curl() -> float:
    """dQ/dx - dP/dy for P = -y, Q = x."""
    return 2.0


def curl_z_rotation_field() -> float:
    """z-component of curl F for F = (-y, x, 0)."""
    return 2.0


def line_integral_rotation_field(radius: float, *, n_samples: int = 4096) -> float:
    """
    Parametric line integral ∮_C -y dx + x dy on circle x^2 + y^2 = R^2.

    Midpoint rule on t in [0, 2π]; integrand simplifies to R^2 dt (exact for uniform grid).
    """
    if radius <= 0:
        raise ValueError("radius must be positive")
    if n_samples < 1:
        raise ValueError("n_samples must be >= 1")

    dt = (2.0 * math.pi) / n_samples
    total = 0.0
    for k in range(n_samples):
        t = (k + 0.5) * dt
        x = radius * math.cos(t)
        y = radius * math.sin(t)
        dx_dt = -radius * math.sin(t)
        dy_dt = radius * math.cos(t)
        integrand = (-y) * dx_dt + x * dy_dt
        total += integrand
    return total * dt


def greens_double_integral(radius: float, *, n_radial: int = 256, n_angular: int = 256) -> float:
    """
    ∬_D (dQ/dx - dP/dy) dA = ∬_D 2 dA over disk of radius R (polar quadrature).
    """
    if radius <= 0:
        raise ValueError("radius must be positive")
    if n_radial < 1 or n_angular < 4:
        raise ValueError("n_radial >= 1 and n_angular >= 4 required")

    scalar_curl = greens_scalar_curl()
    dr = radius / n_radial
    dtheta = (2.0 * math.pi) / n_angular
    total = 0.0
    for i in range(n_radial):
        r_inner = i * dr
        r_outer = (i + 1) * dr
        r_mid = 0.5 * (r_inner + r_outer)
        for j in range(n_angular):
            total += scalar_curl * r_mid * dr * dtheta
    return total


def stokes_surface_integral(radius: float, *, n_radial: int = 256, n_angular: int = 256) -> float:
    """
    ∬_S (curl F · n̂) dS for upward normal on disk z = 0; equals Green for this field.
    """
    if radius <= 0:
        raise ValueError("radius must be positive")
    curl_dot_n = curl_z_rotation_field()
    return greens_double_integral(radius, n_radial=n_radial, n_angular=n_angular) * (
        curl_dot_n / greens_scalar_curl()
    )


def _relative_error(observed: float, expected: float) -> float:
    if expected == 0:
        return abs(observed)
    return abs(observed - expected) / abs(expected)


def verify_greens_stokes(
    radius: float = 1.0,
    *,
    n_samples: int = 4096,
    n_radial: int = 256,
    n_angular: int = 256,
    tolerance: float = 1e-6,
) -> GreensStokesVerification:
    exact = analytic_value(radius)
    line = line_integral_rotation_field(radius, n_samples=n_samples)
    green = greens_double_integral(radius, n_radial=n_radial, n_angular=n_angular)
    stokes = stokes_surface_integral(radius, n_radial=n_radial, n_angular=n_angular)
    line_err = _relative_error(line, exact)
    green_err = _relative_error(green, exact)
    stokes_err = _relative_error(stokes, exact)
    return GreensStokesVerification(
        governance=GREENS_STOKES_TAG,
        radius=radius,
        n_samples=n_samples,
        analytic=exact,
        line_integral=line,
        greens_double_integral=green,
        stokes_surface_integral=stokes,
        greens_scalar_curl=greens_scalar_curl(),
        curl_z=curl_z_rotation_field(),
        line_relative_error=line_err,
        greens_relative_error=green_err,
        stokes_relative_error=stokes_err,
        green_equals_stokes=abs(green - stokes) <= tolerance * max(1.0, abs(green)),
    )


def export_verification_json(
    result: GreensStokesVerification,
    path: Path,
) -> Path:
    path.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        **asdict(result),
        "field": REFERENCE_FIELD,
        "not_claimed": [
            "Green/Stokes proves EABC vortex circulation",
            "Numerical disk example identifies Dumas Gap-Rotor loops",
        ],
    }
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path
