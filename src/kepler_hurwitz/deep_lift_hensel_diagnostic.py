"""
Deep-lift Hensel-step diagnostic for Channel-7 linear branch ``243r + 95``.

Governance [B] only:
- Does NOT prove Collatz.
- Ebene A: eindeutiger 2-adischer Lift der linearen Kongruenz (nicht dynamischer Deszent).
- ``2-adische Struktur ≠ dynamischer Deszent``.

Matches Lean generator in ``ChannelSevenDeepLiftV214.lean``:
``ρ_{j+1} = ρ_j`` if ``243·ρ_j + 95 ≡ 0 (mod 2^{j+1})``, else ``ρ_{j+1} = ρ_j + 2^j``.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Sequence

try:
    from sage.all import Integer as _Integer  # type: ignore[import-untyped]
except ImportError:
    _Integer = int

Integer = _Integer

DEEP_LIFT_TAG = "[B]"
DEEP_BRANCH_MULTIPLIER = 243
DEEP_BRANCH_CONSTANT = 95

__all__ = [
    "DEEP_LIFT_TAG",
    "DEEP_BRANCH_MULTIPLIER",
    "DEEP_BRANCH_CONSTANT",
    "DeepLiftStepRow",
    "deep_branch_poly",
    "deep_lift_modulus",
    "deep_lift_residue",
    "deep_lift_constant",
    "analyze_deep_lift_hensel_steps",
    "format_hensel_report",
    "Integer",
    "v2",
]


def v2(n: int | _Integer) -> int:
    """2-adische Valuation ``v_2(n)`` for positive ``n``."""
    n = int(n)
    if n <= 0:
        raise ValueError("n must be positive")
    if n % 2 == 1:
        return 0
    return (n & -n).bit_length() - 1


def deep_branch_poly(r: int | _Integer) -> int:
    return int(DEEP_BRANCH_MULTIPLIER * int(r) + DEEP_BRANCH_CONSTANT)


def deep_lift_modulus(j: int) -> int:
    return 1 << j


def deep_lift_residue(j: int) -> int:
    """Lean-aligned generator: ``deepLiftResidue j``."""
    if j <= 0:
        return 0
    rho = deep_lift_residue(j - 1)
    m = deep_lift_modulus(j - 1)
    core = deep_branch_poly(rho)
    if core % (2 * m) == 0:
        return rho
    return rho + m


def deep_lift_constant(j: int) -> int:
    rho = deep_lift_residue(j)
    return deep_branch_poly(rho) // deep_lift_modulus(j)


@dataclass(frozen=True)
class DeepLiftStepRow:
    j: int
    rho_old: int
    rho_new: int
    lift_bit: int
    core_old: int
    core_new: int
    nu2_old: int
    nu2_new: int
    delta_quotient: int
    c_j: int


def analyze_deep_lift_hensel_steps(j_max: int = 6) -> list[DeepLiftStepRow]:
    """
    For ``j = 1..j_max``, record one Hensel/lift step.

    Index convention (Lean-aligned, 0-based ``j`` in generator):
    - at printed level ``j``, old residue is ``ρ_{j-1}``, new is ``ρ_j``
    - increment is ``b · 2^{j-1}`` with ``b ∈ {0,1}`` (user/Sage 1-based formula)
    - ``delta = (core_new - core_old) / 2^{j-1}``
    """
    if j_max < 1:
        return []

    rows: list[DeepLiftStepRow] = []
    for j in range(1, j_max + 1):
        rho_old = deep_lift_residue(j - 1)
        rho_new = deep_lift_residue(j)
        m_prev = deep_lift_modulus(j - 1)
        core_old = deep_branch_poly(rho_old)
        core_new = deep_branch_poly(rho_new)
        lift_bit = (rho_new - rho_old) // m_prev if m_prev else 0
        delta_quotient = (core_new - core_old) // m_prev if m_prev else 0
        rows.append(
            DeepLiftStepRow(
                j=j,
                rho_old=rho_old,
                rho_new=rho_new,
                lift_bit=lift_bit,
                core_old=core_old,
                core_new=core_new,
                nu2_old=v2(core_old),
                nu2_new=v2(core_new),
                delta_quotient=delta_quotient,
                c_j=deep_lift_constant(j),
            )
        )
    return rows


def format_hensel_report(rows: Sequence[DeepLiftStepRow]) -> str:
    lines = [
        "Deep-lift Hensel-step diagnostic (Channel-7, 243r + 95)",
        f"Governance: {DEEP_LIFT_TAG} — Ebene A algebra only; NOT Collatz proof.",
        "Box: 2-adische Struktur ≠ dynamischer Deszent",
        "",
        "j  rho_old  rho_new  b  nu2(core_old)  nu2(core_new)  delta  c_j",
    ]
    for row in rows:
        lines.append(
            f"{row.j:>1}  {row.rho_old:>7}  {row.rho_new:>7}  {row.lift_bit}  "
            f"{row.nu2_old:>14}  {row.nu2_new:>14}  {row.delta_quotient:>5}  {row.c_j:>5}"
        )
    return "\n".join(lines)
