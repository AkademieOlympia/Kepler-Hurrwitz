"""
Diagnostics Parameter-Atlas — reine Mess- und Diagnoseebene.

Governance: Parameter destillieren ja; Identifikation behaupten nein.
Kein neuer Beweiskern — nur Projektionsverluste, Defekte, Kosten, Balance, Chiralitaet.

Top-8 Primaer-API (reine Hilfsfunktionen):
  1. net_descent_margin
  2. bad_run_cost
  3. shrink_efficiency
  4. channel_entropy
  5. prime_grid_compression
  6. norm_signature_defect
  7. projection_loss
  8. chirality_norm

Siehe docs/diagnostics_parameter_atlas.md.
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from math import prod
from pathlib import Path
from typing import Any

from kepler_hurwitz.primvierling import Primvierling, quat_norm
from kepler_hurwitz.signatures import (
    EABCSignature4,
    HurwitzSignature8D,
    channel_mass,
    eabc_mass,
    prime_factorization_with_multiplicity,
    prime_omega,
    signature_from_nat,
)

PrimvierlingComponents = tuple[int, int, int, int]

CHIRALITY_NORM_TAG = "[C]"

# Canonical Top-8 measurement helpers (Parameter-Atlas primary API).
ATLAS_PRIMARY_FUNCTIONS: tuple[str, ...] = (
    "net_descent_margin",
    "bad_run_cost",
    "shrink_efficiency",
    "channel_entropy",
    "prime_grid_compression",
    "norm_signature_defect",
    "projection_loss",
    "chirality_norm",
)

__all__ = [
    *ATLAS_PRIMARY_FUNCTIONS,
    "ATLAS_PRIMARY_FUNCTIONS",
    "CHIRALITY_NORM_TAG",
    "CollatzNetDescentDiagnostics",
    "DistilledInvariants",
    "PrimvierlingDistilled",
    "bad_run_cost_from_n",
    "build_diagnostics_sample",
    "channel_entropy_from_value",
    "chirality_norm_from_hurwitz",
    "collatz_net_descent_diagnostics",
    "collatz_iterate",
    "collatz_step",
    "distill_from_nat",
    "distill_primvierling",
    "export_diagnostics_json",
    "net_descent_margin_from_collatz",
    "norm_signature_defect_from_primvierling",
    "prime_grid_compression_from_nat",
    "projection_loss_from_nat",
    "shrink_efficiency_from_collatz",
    "steps_until_mod4_eq_one",
]


@dataclass(frozen=True)
class DistilledInvariants:
    norm: int
    mass_norm: int
    signature_norm: tuple[int, int, int, int]
    mass_product: int | None
    signature_product: tuple[int, int, int, int] | None
    channel_eccentricity: float
    channel_variance: float
    norm_product_drift: int | None
    projection_loss: int
    max_channel: int
    min_channel: int
    channel_defect: int
    channel_entropy: float
    prime_grid_compression: float
    prime_grid_infinity_ratio: float | None

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class PrimvierlingDistilled:
    p: int
    quadruple: PrimvierlingComponents
    gamma_components: PrimvierlingComponents
    product: int
    norm: int
    product_mass_is_four: bool
    norm_mass: int
    norm_signature: tuple[int, int, int, int]
    product_signature: tuple[int, int, int, int]
    channel_eccentricity_product: float
    channel_variance_product: float
    norm_product_drift: int
    projection_loss: int
    norm_signature_anisotropy: int
    norm_signature_defect: int
    channel_eccentricity_norm: float
    channel_variance_norm: float
    channel_entropy_product: float
    channel_entropy_norm: float

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class CollatzNetDescentDiagnostics:
    n: int
    t_good: int
    m_good: int
    bad_run_cost: int
    t_loc: int
    net_descent_margin: int
    shrink_efficiency: float

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def collatz_step(n: int) -> int:
    """Standard Collatz-Schritt (Lean: collatzStep)."""
    if n < 1:
        raise ValueError("n must be >= 1")
    return n // 2 if n % 2 == 0 else 3 * n + 1


def collatz_iterate(n: int, steps: int) -> int:
    if steps < 0:
        raise ValueError("steps must be >= 0")
    current = n
    for _ in range(steps):
        current = collatz_step(current)
    return current


def steps_until_mod4_eq_one(n: int, *, max_steps: int = 10_000) -> tuple[int, int]:
    """
    V2.6-Good-Branch-Eintritt: (t_good, m_good) mit m_good % 4 == 1.

    Liefert die kleinste t_good >= 0 und m_good = collatzStep^[t_good](n).
    """
    if n < 1:
        raise ValueError("n must be >= 1")
    current = n
    for t_good in range(max_steps + 1):
        if current % 4 == 1:
            return t_good, current
        current = collatz_step(current)
    raise ValueError(f"mod 4 = 1 not reached within {max_steps} steps for n={n}")


def bad_run_cost(t_good: int) -> int:
    """C_bad = t_good — Schritte bis mod 4 = 1 (Atlas-Primärsignatur)."""
    if t_good < 0:
        raise ValueError("t_good must be >= 0")
    return t_good


def bad_run_cost_from_n(n: int) -> int:
    """C_bad aus n berechnen — Schritte bis mod 4 = 1."""
    computed_t_good, _ = steps_until_mod4_eq_one(n)
    return computed_t_good


def net_descent_margin(n: int, descended_value: int) -> int:
    """Δ_net = n - descended_value (Atlas-Primärsignatur)."""
    if n < 0 or descended_value < 0:
        raise ValueError("n and descended_value must be >= 0")
    return n - descended_value


def net_descent_margin_from_collatz(n: int, t_loc: int, m_good: int) -> int:
    """Δ_net = n - collatzStep^[t_loc](m_good)."""
    if t_loc < 0:
        raise ValueError("t_loc must be >= 0")
    return n - collatz_iterate(m_good, t_loc)


def shrink_efficiency(net_margin: int, bad_run_cost_value: int) -> float:
    """η = Δ_net / (C_bad + 1) (Atlas-Primärsignatur)."""
    if bad_run_cost_value < 0:
        raise ValueError("bad_run_cost must be >= 0")
    return net_margin / (bad_run_cost_value + 1)


def shrink_efficiency_from_collatz(n: int, t_good: int, t_loc: int, m_good: int) -> float:
    """η aus voller Collatz-Kette."""
    delta = net_descent_margin_from_collatz(n, t_loc, m_good)
    return delta / (t_good + 1)


def collatz_net_descent_diagnostics(
    n: int,
    t_loc: int,
    *,
    t_good: int | None = None,
    m_good: int | None = None,
) -> CollatzNetDescentDiagnostics:
    if t_good is None or m_good is None:
        computed_t_good, computed_m_good = steps_until_mod4_eq_one(n)
        t_good = computed_t_good if t_good is None else t_good
        m_good = computed_m_good if m_good is None else m_good
    c_bad = bad_run_cost(t_good)
    delta = net_descent_margin_from_collatz(n, t_loc, m_good)
    return CollatzNetDescentDiagnostics(
        n=n,
        t_good=t_good,
        m_good=m_good,
        bad_run_cost=c_bad,
        t_loc=t_loc,
        net_descent_margin=delta,
        shrink_efficiency=shrink_efficiency(delta, c_bad),
    )


def _signature_or_nat(value: int | EABCSignature4) -> EABCSignature4:
    if isinstance(value, EABCSignature4):
        return value
    return signature_from_nat(value)


def channel_entropy(signature: PrimvierlingComponents) -> float:
    """Kanalentropie -Σ p_c log p_c fuer E,A,B,C mit p_c = X/M; c=0 ueberspringen."""
    if len(signature) != 4:
        raise ValueError("signature must have four channels")
    if any(channel < 0 for channel in signature):
        raise ValueError("all channels must be >= 0")
    mass = sum(signature)
    if mass <= 0:
        return 0.0
    entropy = 0.0
    for channel in signature:
        if channel > 0:
            probability = channel / mass
            entropy -= probability * math.log(probability)
    return entropy


def channel_entropy_from_value(value: int | EABCSignature4) -> float:
    """Kanalentropie aus nat oder EABCSignature4."""
    return channel_entropy(_signature_or_nat(value).as_tuple())


def prime_grid_compression(eabc_mass_value: int, omega: int) -> float:
    """ρ_PG = M / Ω — EABC-Kompression gegen Prime Grid ℓ¹-Norm (Atlas-Primärsignatur)."""
    if eabc_mass_value < 0 or omega <= 0:
        raise ValueError("eabc_mass must be >= 0 and omega must be > 0")
    return eabc_mass_value / omega


def prime_grid_compression_from_nat(n: int) -> float:
    """ρ_PG aus n berechnen."""
    if n < 1:
        raise ValueError("n must be >= 1")
    computed_omega = prime_omega(n)
    if computed_omega == 0:
        return 0.0
    return eabc_mass(n) / computed_omega


def prime_grid_max_channel(n: int) -> int:
    """Q(n) = max{E,A,B,C}."""
    return signature_from_nat(n).max_channel()


def prime_exponent_infinity_norm(n: int) -> int:
    """||i_n||_∞ = max_p i_p aus der Primzerlegung."""
    if n < 2:
        return 0
    return max(exponent for _, exponent in prime_factorization_with_multiplicity(n))


def prime_grid_infinity_ratio(n: int) -> float | None:
    """R_∞(n) = Q(n) / ||i_n||_∞ — optional, nur wenn max-Exponent > 0."""
    inf_norm = prime_exponent_infinity_norm(n)
    if inf_norm == 0:
        return None
    return prime_grid_max_channel(n) / inf_norm


def channel_eccentricity(value: int | EABCSignature4) -> float:
    """e_EABC = (max H - min H) / M fuer M > 0."""
    signature = _signature_or_nat(value)
    mass = channel_mass(signature)
    if mass <= 0:
        raise ValueError("channel mass M must be > 0")
    return signature.spread() / mass


def channel_variance(value: int | EABCSignature4) -> float:
    """sigma^2_EABC = (1/4) sum (X - M/4)^2."""
    signature = _signature_or_nat(value)
    mean = channel_mass(signature) / 4
    return sum((channel - mean) ** 2 for channel in signature.channels()) / 4


def projection_loss(omega_norm: int, eabc_mass_norm: int) -> int:
    """L_π = Ω - M — Faktoren ausserhalb der EABC-Kanaele (Atlas-Primärsignatur)."""
    if omega_norm < 0 or eabc_mass_norm < 0 or omega_norm < eabc_mass_norm:
        raise ValueError("require omega_norm >= eabc_mass_norm >= 0")
    return omega_norm - eabc_mass_norm


def projection_loss_from_nat(n: int) -> int:
    """L_π aus n berechnen."""
    if n < 1:
        raise ValueError("value must be >= 1")
    return prime_omega(n) - eabc_mass(n)


def primvierling_gamma_v(v: Primvierling) -> PrimvierlingComponents:
    """gamma_v = p + (p+2)i + (p+6)j + (p+8)k als Komponententupel."""
    if len(v) != 4:
        raise ValueError("primvierling must have four components")
    return tuple(v)


def primvierling_product(v: Primvierling) -> int:
    return prod(v)


def norm_signature_defect(
    product_signature: PrimvierlingComponents,
    norm_signature: PrimvierlingComponents,
) -> int:
    """δ_H = ||H(N(γ_v)) - H(P(v))||_1 — L1-Abstand (Atlas-Primärsignatur)."""
    if len(product_signature) != 4 or len(norm_signature) != 4:
        raise ValueError("signatures must have four channels each")
    if any(channel < 0 for channel in product_signature + norm_signature):
        raise ValueError("all channels must be >= 0")
    return sum(
        abs(norm_channel - product_channel)
        for norm_channel, product_channel in zip(norm_signature, product_signature, strict=True)
    )


def norm_signature_defect_from_primvierling(v: Primvierling) -> int:
    """δ_H aus Primvierling v=(p,p+2,p+6,p+8) berechnen."""
    product_signature = signature_from_nat(primvierling_product(v))
    norm_signature = signature_from_nat(quat_norm(v))
    return norm_signature_defect(product_signature.as_tuple(), norm_signature.as_tuple())


def norm_product_drift(v: Primvierling) -> int:
    """D_NP(v) = M(N(gamma_v)) - M(P(v)); strukturell M(P(v)) = 4."""
    return eabc_mass(quat_norm(v)) - eabc_mass(primvierling_product(v))


def norm_signature_anisotropy(v: Primvierling) -> int:
    """A_N(v) = max H(N(gamma_v)) - min H(N(gamma_v))."""
    signature = signature_from_nat(quat_norm(v))
    return signature.spread()


def chirality_norm_from_hurwitz(signature: HurwitzSignature8D) -> float:
    """
    ||χ|| = sqrt(α²+β²+γ²) aus orientierten Kanalpaaren (E,A,B +/-).

    Governance: arithmetischer 8D→3D-Chiralitaetsvektor; keine dedekindische
    Idealchiralitaet — siehe CHIRALITY_NORM_TAG.
    """
    alpha = signature.e_plus - signature.e_minus
    beta = signature.a_plus - signature.a_minus
    gamma = signature.b_plus - signature.b_minus
    return math.sqrt(alpha * alpha + beta * beta + gamma * gamma)


def chirality_norm(alpha: float, beta: float, gamma: float) -> float:
    """||χ|| = sqrt(α²+β²+γ²) aus orientierten Kanalpaaren (Atlas-Primärsignatur)."""
    return math.sqrt(alpha * alpha + beta * beta + gamma * gamma)


def distill_from_nat(n: int) -> DistilledInvariants:
    signature = signature_from_nat(n)
    mass = channel_mass(signature)
    if mass > 0:
        eccentricity = channel_eccentricity(signature)
        variance = channel_variance(signature)
        entropy = channel_entropy_from_value(signature)
    else:
        eccentricity = 0.0
        variance = 0.0
        entropy = 0.0
    return DistilledInvariants(
        norm=n,
        mass_norm=mass,
        signature_norm=signature.as_tuple(),
        mass_product=None,
        signature_product=None,
        channel_eccentricity=eccentricity,
        channel_variance=variance,
        norm_product_drift=None,
        projection_loss=projection_loss_from_nat(n),
        max_channel=signature.max_channel(),
        min_channel=signature.min_channel(),
        channel_defect=signature.spread(),
        channel_entropy=entropy,
        prime_grid_compression=prime_grid_compression_from_nat(n),
        prime_grid_infinity_ratio=prime_grid_infinity_ratio(n),
    )


def distill_primvierling(v: Primvierling) -> PrimvierlingDistilled:
    if len(v) != 4:
        raise ValueError("primvierling must have four components")
    product = primvierling_product(v)
    norm = quat_norm(v)
    signature_product = signature_from_nat(product)
    signature_norm = signature_from_nat(norm)
    product_mass = channel_mass(signature_product)
    return PrimvierlingDistilled(
        p=v[0],
        quadruple=primvierling_gamma_v(v),
        gamma_components=primvierling_gamma_v(v),
        product=product,
        norm=norm,
        product_mass_is_four=product_mass == 4,
        norm_mass=channel_mass(signature_norm),
        norm_signature=signature_norm.as_tuple(),
        product_signature=signature_product.as_tuple(),
        channel_eccentricity_product=channel_eccentricity(signature_product),
        channel_variance_product=channel_variance(signature_product),
        norm_product_drift=norm_product_drift(v),
        projection_loss=projection_loss_from_nat(norm),
        norm_signature_anisotropy=norm_signature_anisotropy(v),
        norm_signature_defect=norm_signature_defect_from_primvierling(v),
        channel_eccentricity_norm=channel_eccentricity(signature_norm),
        channel_variance_norm=channel_variance(signature_norm),
        channel_entropy_product=channel_entropy_from_value(signature_product),
        channel_entropy_norm=channel_entropy_from_value(signature_norm),
    )


def export_diagnostics_json(payload: dict[str, Any], path: str | Path) -> Path:
    destination = Path(path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return destination


def build_diagnostics_sample(
    naturals: list[int],
    primvierlinge: list[Primvierling],
    collatz_cases: list[tuple[int, int]] | None = None,
) -> dict[str, Any]:
    collatz_payload: list[dict[str, Any]] = []
    for entry in collatz_cases or []:
        n, t_loc = entry
        collatz_payload.append(collatz_net_descent_diagnostics(n, t_loc).as_dict())
    return {
        "governance": (
            "Parameter destillieren ja; Identifikation behaupten nein. "
            "M != Omega, Q != ||i||_inf im Allgemeinen."
        ),
        "priority_parameters": [
            "net_descent_margin",
            "bad_run_cost",
            "shrink_efficiency",
            "channel_entropy",
            "prime_grid_compression",
            "norm_signature_defect",
            "projection_loss",
            "chirality_norm",
        ],
        "naturals": [distill_from_nat(n).as_dict() for n in naturals],
        "primvierlinge": [distill_primvierling(v).as_dict() for v in primvierlinge],
        "collatz": collatz_payload,
    }


# Backward-compatible aliases
export_distilled_parameters_json = export_diagnostics_json
build_distilled_parameters_sample = build_diagnostics_sample
