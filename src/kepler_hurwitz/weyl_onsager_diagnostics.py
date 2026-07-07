"""
Weyl–Onsager combined diagnostics — chiral proxy, reciprocity residual, Berry holonomy.

Governance: [C] hypothesis scaffold / [B] experimental stubs — coordinated reading
language for Weyl chiral modes and Onsager reciprocal structure on EABC channel
couplings. Not physical identification; complements weyl_commutator_diagnostics
and onsager_vortex_diagnostics.

See docs/theory/weyl_onsager_bridge_attack.md (E-087, E-088).
"""

from __future__ import annotations

import json
import math
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Sequence

from kepler_hurwitz.diagnostics import chirality_norm
from kepler_hurwitz.primvierling import Primvierling, build_prime_quadruplet, quat_norm
from kepler_hurwitz.signatures import EABCSignature4, signature_from_nat

WEYL_ONSAGER_TAG = "[C]"

__all__ = [
    "WEYL_ONSAGER_TAG",
    "WeylOnsagerAttackRecord",
    "berry_holonomy_product",
    "build_attack_record",
    "build_default_attack_records",
    "eabc_coupling_toy_from_signature",
    "chiral_components_from_eabc",
    "export_attack_records_json",
    "onsager_reciprocity_residual",
    "weyl_chirality_proxy",
]


def weyl_chirality_proxy(alpha: float, beta: float, gamma: float) -> float:
    """
    Chiral magnitude ||χ|| = sqrt(α²+β²+γ²) from oriented channel pairs.

    Governance [C]: reuses Atlas chirality_norm pattern; Weyl-semimetal reading
    language only — not a proof of chiral anomaly or Dedekind ideal chirality.
    """
    for name, value in (("alpha", alpha), ("beta", beta), ("gamma", gamma)):
        if not math.isfinite(value):
            raise ValueError(f"{name} must be finite, got {value!r}")
    return chirality_norm(alpha, beta, gamma)


def chiral_components_from_eabc(signature: EABCSignature4) -> tuple[float, float, float]:
    """
    Toy chiral components (α, β, γ) from 4D EABC channel counts.

    Governance [C]: oriented pair differences E−C, A−B, (E+A)−(B+C) as Weyl-proxy
    when full 8D Hurwitz signature is unavailable — not Dedekind chirality.
    """
    e, a, b, c = signature.as_tuple()
    return float(e - c), float(a - b), float(e + a - b - c)


def onsager_reciprocity_residual(matrix: Sequence[Sequence[float]]) -> float:
    """
    Antisymmetric residual R_rec = sum_{i<j} (L_ij - L_ji)² for Onsager reciprocity.

    Governance [C]: toy 4×4 EABC channel coupling matrix; L_ij = L_ji in equilibrium
    is Onsager's reciprocal relation — deviation measures global coupling asymmetry,
    not proof of microscopic reversibility in the arithmetic core.
    """
    rows = tuple(tuple(float(x) for x in row) for row in matrix)
    n = len(rows)
    if n == 0:
        raise ValueError("matrix must be non-empty")
    if any(len(row) != n for row in rows):
        raise ValueError("matrix must be square")
    if n != 4:
        raise ValueError("EABC coupling toy expects 4×4 matrix, got {n}×{n}")
    total = 0.0
    for i in range(n):
        for j in range(i + 1, n):
            diff = rows[i][j] - rows[j][i]
            total += diff * diff
    return total


def berry_holonomy_product(edge_phases: Sequence[float]) -> float:
    """
    Discrete Berry holonomy phase arg(∏ exp(i φ_k)) for a closed orbit.

    Returns total phase in (-π, π]. Governance [C]: holonomy scaffold for E-083;
    edge_phases are radians along consecutive orbit edges — not AB flux quanta.
    """
    if len(edge_phases) < 1:
        raise ValueError("edge_phases must contain at least one phase")
    for index, phase in enumerate(edge_phases):
        if not math.isfinite(phase):
            raise ValueError(f"edge_phases[{index}] must be finite, got {phase!r}")
    x = sum(math.cos(p) for p in edge_phases)
    y = sum(math.sin(p) for p in edge_phases)
    return math.atan2(y, x)


def eabc_coupling_toy_from_signature(
    alpha: float,
    beta: float,
    gamma: float,
    *,
    asymmetry: float = 0.0,
) -> tuple[tuple[float, ...], ...]:
    """
    Build a 4×4 channel coupling toy from chiral components (E,A,B,C hosts).

    Symmetric base L_ij = δ_ij + |χ_i|·|χ_j| with optional antisymmetric perturbation
    controlled by asymmetry (for nullmodel contrast).
    """
    channels = (abs(alpha), abs(beta), abs(gamma), abs(alpha + beta + gamma) / 3.0)
    rows: list[tuple[float, ...]] = []
    for i in range(4):
        row: list[float] = []
        for j in range(4):
            value = (1.0 if i == j else 0.0) + channels[i] * channels[j] * 0.01
            if asymmetry != 0.0 and i != j:
                value += asymmetry * (i - j) * 0.001
            row.append(value)
        rows.append(tuple(row))
    return tuple(rows)


@dataclass(frozen=True)
class WeylOnsagerAttackRecord:
    """Combined Weyl/Onsager diagnostic row for one Primvierling."""

    primvierling: Primvierling
    alpha: float
    beta: float
    gamma: float
    weyl_chirality: float
    reciprocity_residual: float
    berry_phase: float
    tag: str = WEYL_ONSAGER_TAG


def build_attack_record(
    v: Primvierling,
    *,
    edge_phases: Sequence[float] | None = None,
    asymmetry: float = 0.0,
) -> WeylOnsagerAttackRecord:
    """Build combined attack record from Primvierling Hurwitz signature."""
    signature = signature_from_nat(quat_norm(v))
    alpha, beta, gamma = chiral_components_from_eabc(signature)
    coupling = eabc_coupling_toy_from_signature(alpha, beta, gamma, asymmetry=asymmetry)
    phases = edge_phases if edge_phases is not None else (0.0, math.pi / 2, math.pi, -math.pi / 2)
    return WeylOnsagerAttackRecord(
        primvierling=v,
        alpha=alpha,
        beta=beta,
        gamma=gamma,
        weyl_chirality=weyl_chirality_proxy(alpha, beta, gamma),
        reciprocity_residual=onsager_reciprocity_residual(coupling),
        berry_phase=berry_holonomy_product(phases),
    )


def build_default_attack_records(
    primes: Sequence[int] = (11, 13, 17, 29),
) -> list[WeylOnsagerAttackRecord]:
    """Canonical attack records on reference prime quadruplets."""
    return [build_attack_record(build_prime_quadruplet(p)) for p in primes]


def export_attack_records_json(
    records: Sequence[WeylOnsagerAttackRecord],
    path: Path,
) -> Path:
    """Write attack records to JSON with governance tag."""
    payload = {
        "tag": WEYL_ONSAGER_TAG,
        "governance": "Komplettangriff = Lesesprache + Diagnostik, nicht Großsatz.",
        "records": [
            {
                **{k: v for k, v in asdict(r).items() if k != "primvierling"},
                "primvierling": list(r.primvierling),
            }
            for r in records
        ],
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    return path
