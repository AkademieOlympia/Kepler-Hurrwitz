from __future__ import annotations

from dataclasses import dataclass
from math import isqrt, prod
from typing import Callable, Iterable, Sequence

Primvierling = tuple[int, int, int, int]
Observable = Callable[[Primvierling], object]


@dataclass(frozen=True)
class InvarianceResult:
    name: str
    is_invariant: bool
    orbit_values: tuple[object, ...]


@dataclass(frozen=True)
class PrimvierlingAnalysis:
    base: Primvierling
    orbit: tuple[Primvierling, ...]
    invariants: tuple[InvarianceResult, ...]


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n in (2, 3):
        return True
    if n % 2 == 0:
        return False
    limit = isqrt(n)
    for factor in range(3, limit + 1, 2):
        if n % factor == 0:
            return False
    return True


def is_prime_quadruplet(candidate: Sequence[int]) -> bool:
    """
    Kanonisches Primquadruplet v=(p,p+2,p+6,p+8) mit p>3 und allen vier prim.

    Entspricht Lean ``PrimeQuadruplet``; nur „vier Primzahlen“ ohne Gap-Struktur
    reicht nicht (z. B. (2,3,5,7) wird abgelehnt). [B]
    """
    if len(candidate) != 4:
        return False
    p, p2, p6, p8 = candidate
    if p <= 3:
        return False
    if (p2, p6, p8) != (p + 2, p + 6, p + 8):
        return False
    return all(is_prime(value) for value in candidate)


def build_prime_quadruplet(p: int) -> Primvierling:
    return (p, p + 2, p + 6, p + 8)


def generate_prime_quadruplets(start: int, stop: int) -> list[Primvierling]:
    """
    Finds all canonical prime quadruplets (p, p+2, p+6, p+8)
    whose first element lies in [start, stop].
    """
    if stop < start:
        raise ValueError("stop must be >= start")

    quadruplets: list[Primvierling] = []
    for p in range(max(2, start), stop + 1):
        candidate = build_prime_quadruplet(p)
        if is_prime_quadruplet(candidate):
            quadruplets.append(candidate)
    return quadruplets


def symmetry_shift_ceab(v: Primvierling) -> Primvierling:
    a, b, c, e = v
    return (c, e, a, b)


def orbit_under_ceab(v: Primvierling) -> tuple[Primvierling, ...]:
    shifted = symmetry_shift_ceab(v)
    if shifted == v:
        return (v,)
    return (v, shifted)


# Lean `shiftCEAB` / `orbitCEAB` aliases for tests and exports.
ceab_rotate = symmetry_shift_ceab
ceab_orbit = orbit_under_ceab


def component_channels(v: Primvierling) -> tuple[str, str, str, str]:
    """EABC channel labels (E/A/B/C) for quaternion components (a, b, c, e)."""
    from kepler_hurwitz.dumas_natural_fill import eabc_channel_from_mod12

    return tuple(eabc_channel_from_mod12(component).value for component in v)


def pair_gaps(v: Primvierling) -> int:
    a, b, c, e = v
    return (a - c) ** 2 + (b - e) ** 2


def quat_norm(v: Primvierling) -> int:
    return sum(x * x for x in v)


def quadruple_product(v: Primvierling) -> int:
    """Komponentenprodukt P(v)=a·b·c·e."""
    return prod(v)


def product_mass(v: Primvierling) -> int:
    """
    EABC-Masse M(P(v)) auf dem Komponentenprodukt.

    Für echte Primvierlinge p>3 strukturell M=4 (volle mod-12-Abdeckung). [B]
    """
    from kepler_hurwitz.signatures import eabc_mass

    return eabc_mass(quadruple_product(v))


def norm_mass(v: Primvierling) -> int:
    """
    EABC-Masse M(n(v)) auf der Quaternionennorm n(v)=quat_norm(v).

    Faktorisatorisch variabel; Referenz (5,7,11,13) → M=2. Kein globales Axiom. [B]
    """
    from kepler_hurwitz.signatures import eabc_mass

    return eabc_mass(quat_norm(v))


def norm_signature(v: Primvierling):
    """Kanonsiche H(n(v))=(E,A,B,C) für die Norm n(v). [B]"""
    from kepler_hurwitz.signatures import signature_from_nat

    return signature_from_nat(quat_norm(v))


def quat_reduced_norm(v: Primvierling) -> object:
    """
    Computes reduced norm in the Hamilton quaternion algebra when SageMath
    is available. Falls back to the equivalent integer expression otherwise.
    """
    a, b, c, e = v
    try:
        from sage.all import QQ, QuaternionAlgebra  # type: ignore
    except ImportError:
        return quat_norm(v)
    algebra = QuaternionAlgebra(QQ, -1, -1)
    q = algebra([a, b, c, e])
    return q.reduced_norm()


def default_observables() -> dict[str, Observable]:
    return {
        "sum": lambda t: sum(t),
        "multiset": lambda t: tuple(sorted(t)),
        "pair_gaps": pair_gaps,
        "quat_norm": quat_norm,
        "quat_reduced_norm": quat_reduced_norm,
    }


def test_invariance(v: Primvierling, observable: Observable) -> tuple[bool, tuple[object, ...]]:
    orbit = orbit_under_ceab(v)
    values = tuple(observable(state) for state in orbit)
    return all(value == values[0] for value in values), values


def analyze_primvierling(
    v: Primvierling,
    observables: dict[str, Observable] | None = None,
) -> PrimvierlingAnalysis:
    selected_observables = observables or default_observables()
    orbit = orbit_under_ceab(v)
    results = tuple(
        InvarianceResult(
            name=name,
            is_invariant=is_invariant,
            orbit_values=values,
        )
        for name, (is_invariant, values) in (
            (name, test_invariance(v, observable))
            for name, observable in selected_observables.items()
        )
    )
    return PrimvierlingAnalysis(base=v, orbit=orbit, invariants=results)


def analyze_range(
    start: int,
    stop: int,
    observables: dict[str, Observable] | None = None,
) -> list[PrimvierlingAnalysis]:
    quadruplets = generate_prime_quadruplets(start, stop)
    return [analyze_primvierling(v, observables=observables) for v in quadruplets]


def summarize_analysis(analyses: Iterable[PrimvierlingAnalysis]) -> str:
    lines = ["Primvierling-Pipeline Report"]
    for analysis in analyses:
        lines.append(f"- base={analysis.base}, orbit={analysis.orbit}")
        for invariant in analysis.invariants:
            status = "OK" if invariant.is_invariant else "BROKEN"
            lines.append(
                f"  * {invariant.name}: {status}, values={invariant.orbit_values}"
            )
    return "\n".join(lines)
