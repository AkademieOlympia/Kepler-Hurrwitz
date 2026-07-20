from dataclasses import dataclass
from math import isfinite


@dataclass(frozen=True)
class KeplerInvariants:
    """Kepler invariants from eccentricity ``e_kep`` (not normal-form E-factor ``e``)."""

    eccentricity: float  # e_kep
    radius_ratio: float
    velocity_ratio: float


def radius_ratio_from_eccentricity(e_kep: float) -> float:
    """R_v = (1+e_kep)/(1-e_kep); ``e_kep`` is Kepler eccentricity, not E-factor ``e``."""
    if not (0 <= e_kep < 1):
        raise ValueError("eccentricity e_kep must satisfy 0 <= e_kep < 1")
    return (1 + e_kep) / (1 - e_kep)


def kepler_invariants(e_kep: float) -> KeplerInvariants:
    """Build invariants from Kepler eccentricity ``e_kep`` (Lean ``projectToKepler``.e)."""
    ratio = radius_ratio_from_eccentricity(e_kep)
    if not isfinite(ratio):
        raise ValueError("non-finite Kepler ratio")
    return KeplerInvariants(
        eccentricity=e_kep,
        radius_ratio=ratio,
        velocity_ratio=ratio,
    )
