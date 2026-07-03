from dataclasses import dataclass
from math import isfinite


@dataclass(frozen=True)
class KeplerInvariants:
    eccentricity: float
    radius_ratio: float
    velocity_ratio: float


def radius_ratio_from_eccentricity(e: float) -> float:
    if not (0 <= e < 1):
        raise ValueError("eccentricity e must satisfy 0 <= e < 1")
    return (1 + e) / (1 - e)


def kepler_invariants(e: float) -> KeplerInvariants:
    ratio = radius_ratio_from_eccentricity(e)
    if not isfinite(ratio):
        raise ValueError("non-finite Kepler ratio")
    return KeplerInvariants(
        eccentricity=e,
        radius_ratio=ratio,
        velocity_ratio=ratio,
    )
