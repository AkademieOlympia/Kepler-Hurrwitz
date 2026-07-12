"""
Deep-lift Hensel-step diagnostic for Channel-7 linear branch ``243r + 95``.

Governance [B] only:
- Does NOT prove Collatz.
- Ebene A: eindeutiger 2-adischer Lift der linearen Kongruenz (nicht dynamischer Deszent).
- ``2-adische Struktur ≠ dynamischer Deszent``.

Matches Lean generator in ``ChannelSevenDeepLiftV214.lean``:
``ρ_{j+1} = ρ_j + b·2^j`` with ``b = q_j mod 2`` and ``q_j = (243·ρ_j + 95) / 2^j``
(``b = 0`` when ``q_j`` even, ``b = 1`` when odd — since ``243 ≡ 1 (mod 2)``).

Governance: ``2^j ∣ 243·ρ_j + 95`` is the generator invariant — **not** ``ν_2 = j``.
Plateaus occur (e.g. ``ρ_5 = … = ρ_9 = 27`` with ``ν_2(243·27 + 95) = 9``).
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
MOD128 = 128
INV243_MOD128 = 59
CONTROLLED_RESIDUES_MOD128 = frozenset({39, 79, 95, 103})

__all__ = [
    "DEEP_LIFT_TAG",
    "DEEP_BRANCH_MULTIPLIER",
    "DEEP_BRANCH_CONSTANT",
    "MOD128",
    "INV243_MOD128",
    "CONTROLLED_RESIDUES_MOD128",
    "DeepLiftStepRow",
    "deep_branch_poly",
    "deep_lift_modulus",
    "deep_lift_residue",
    "deep_lift_constant",
    "deep_lift_affine_target_parameter",
    "generate_h7_witness_matrix",
    "odd_core",
    "verify_padic_bridge_and_offsets",
    "format_padic_bridge_report",
    "analyze_deep_lift_hensel_steps",
    "format_hensel_report",
    "syracuse_odd_step",
    "deep_lift_fiber",
    "scan_deep_lift_fiber_dynamics",
    "scan_j3_step6_kick",
    "export_deep_lift_fiber_dynamics_json",
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
    q = deep_branch_poly(rho) // m
    if q % 2 == 0:
        return rho
    return rho + m


def deep_lift_constant(j: int) -> int:
    rho = deep_lift_residue(j)
    return deep_branch_poly(rho) // deep_lift_modulus(j)


def odd_core(n: int) -> int:
    """Lean-aligned ``oddCore n = n / 2^v2(n)`` for positive ``n``."""
    if n <= 0:
        raise ValueError("n must be positive")
    return n >> v2(n)


def verify_padic_bridge_and_offsets(
    *,
    test_values: Sequence[int] | None = None,
    j_max: int = 6,
) -> dict[str, object]:
    """
    Verify padicVal bridge, kick offset, affine quotient, and oddCore terminal layer.

    Layers (governance):
    1. Modular sieve: ``2^j | m ↔ r % 2^j = ρ_j`` (via generator residues)
    2. Valuation scale: ``2^j | m ↔ j ≤ v2(m)``
    3. Terminal oddCore only under exact valuation
    """
    if test_values is None:
        test_values = [338, 6656, 14432, 824, 1696, 8, 24, 96]

    padic_bridge: list[dict[str, object]] = []
    for m in test_values:
        if m <= 0:
            continue
        vm = v2(m)
        for j in range(0, min(vm + 3, 12)):
            mod = deep_lift_modulus(j)
            lhs = m % mod == 0
            rhs = j <= vm
            padic_bridge.append(
                {
                    "m": m,
                    "j": j,
                    "v2_m": vm,
                    "2^j|m": lhs,
                    "j<=v2(m)": rhs,
                    "ok": lhs == rhs,
                }
            )

    kick_offset: list[dict[str, object]] = []
    for m in test_values:
        if m <= 0:
            continue
        kick_offset.append(
            {
                "m": m,
                "v2_m": v2(m),
                "v2_8m": v2(8 * m),
                "expected": 3 + v2(m),
                "ok": v2(8 * m) == 3 + v2(m),
            }
        )

    affine_checks: list[dict[str, object]] = []
    for j in range(1, j_max + 1):
        rho = deep_lift_residue(j)
        c_j = deep_lift_constant(j)
        for t in (0, 1, 2, 5):
            r = rho + deep_lift_modulus(j) * t
            m = deep_branch_poly(r)
            quotient = DEEP_BRANCH_MULTIPLIER * t + c_j
            expected = deep_lift_modulus(j) * quotient
            affine_checks.append(
                {
                    "j": j,
                    "t": t,
                    "r": r,
                    "m": m,
                    "quotient": quotient,
                    "affine_ok": m == expected,
                }
            )

    # Exact-valuation spot checks: s=0 (r=1, v2=1), s=1 (r=3, v2=3)
    terminal_samples = (
        {"s": 0, "j": 1, "r": 1, "t": 0, "expected_v2": 1},
        {"s": 1, "j": 3, "r": 3, "t": 0, "expected_v2": 3},
    )
    terminal_checks: list[dict[str, object]] = []
    for sample in terminal_samples:
        j = int(sample["j"])
        r = int(sample["r"])
        t = int(sample["t"])
        rho = deep_lift_residue(j)
        m = deep_branch_poly(r)
        vm = v2(m)
        quotient = DEEP_BRANCH_MULTIPLIER * t + deep_lift_constant(j)
        exact_val = vm == sample["expected_v2"]
        odd_core_ok = (not exact_val) or (odd_core(m) == quotient)
        next_lift_fails = r % deep_lift_modulus(j + 1) != deep_lift_residue(j + 1)
        terminal_checks.append(
            {
                **sample,
                "rho_j": rho,
                "m": m,
                "v2_m": vm,
                "quotient": quotient,
                "quotient_odd": quotient % 2 == 1,
                "exact_val": exact_val,
                "odd_core_m": odd_core(m),
                "odd_core_ok": odd_core_ok,
                "next_lift_fails": next_lift_fails,
                "residue_ok": r % deep_lift_modulus(j) == rho,
            }
        )

    all_padic_ok = all(bool(row["ok"]) for row in padic_bridge)
    all_kick_ok = all(bool(row["ok"]) for row in kick_offset)
    all_affine_ok = all(bool(row["affine_ok"]) for row in affine_checks)
    all_terminal_ok = all(
        bool(row["exact_val"])
        and bool(row["odd_core_ok"])
        and bool(row["next_lift_fails"])
        and bool(row["residue_ok"])
        for row in terminal_checks
    )

    return {
        "padic_bridge": padic_bridge,
        "kick_offset": kick_offset,
        "affine_checks": affine_checks,
        "terminal_checks": terminal_checks,
        "all_ok": all_padic_ok and all_kick_ok and all_affine_ok and all_terminal_ok,
    }


def format_padic_bridge_report(result: dict[str, object]) -> str:
    lines = [
        "Deep-lift padicVal bridge + terminal oddCore diagnostic",
        f"Governance: {DEEP_LIFT_TAG} — Ebene A only; oddCore under exact val.",
        "",
        f"padic bridge rows: {len(result['padic_bridge'])}  "
        f"kick offset rows: {len(result['kick_offset'])}  "
        f"affine rows: {len(result['affine_checks'])}  "
        f"terminal rows: {len(result['terminal_checks'])}",
        f"ALL OK: {result['all_ok']}",
        "",
        "Terminal samples (exact val → oddCore = 243t + c_j):",
    ]
    for row in result["terminal_checks"]:
        lines.append(
            f"  s={row['s']} j={row['j']} r={row['r']} v2={row['v2_m']} "
            f"oddCore={row['odd_core_m']} quotient={row['quotient']} "
            f"next_lift_fails={row['next_lift_fails']} ok={row['odd_core_ok']}"
        )
    return "\n".join(lines)


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
    - increment is ``b · 2^{j-1}`` with ``b = q_{j-1} mod 2`` and ``q_{j-1} = (243·ρ_{j-1}+95)/2^{j-1}``
    - ``b = 0`` when ``q`` even, ``b = 1`` when ``q`` odd (not reversed)
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


def syracuse_odd_step(n: int) -> int:
    """Normalized odd Syracuse step aligned with Lean ``oddCoreStep``."""
    if n <= 0:
        raise ValueError("n must be positive")
    return odd_core(3 * n + 1)


def deep_lift_fiber(j: int, t: int) -> int:
    """Affine terminal family ``243t + c_j`` (V2.15 Ebene B)."""
    return DEEP_BRANCH_MULTIPLIER * t + deep_lift_constant(j)


def deep_lift_affine_target_parameter(j: int, a: int) -> int:
    """H7-A target parameter ``t ≡ 59(a - c_j) mod 128`` (Lean-aligned)."""
    c_j = deep_lift_constant(j)
    return (INV243_MOD128 * (a - c_j)) % MOD128


def generate_h7_witness_matrix(j_max: int = 5) -> list[dict[str, object]]:
    """
    H7-A witness matrix for controlled residues ``{39, 79, 95, 103}``.

    Uses the real V2.14 generator for ``c_j`` — no dummy ``ρ_j``.
    Cross-checks ``243·t + c_j ≡ a (mod 128)`` for each controlled target ``a``.
    """
    if j_max < 1:
        return []

    matrix: list[dict[str, object]] = []
    for j in range(1, j_max + 1):
        c_j = deep_lift_constant(j)
        residues: dict[int, dict[str, int]] = {}
        for a in sorted(CONTROLLED_RESIDUES_MOD128):
            t_param = deep_lift_affine_target_parameter(j, a)
            fiber_mod128 = (DEEP_BRANCH_MULTIPLIER * t_param + c_j) % MOD128
            if fiber_mod128 != a:
                raise ValueError(
                    f"H7 witness mismatch at j={j}, a={a}: "
                    f"t={t_param}, fiber={fiber_mod128}"
                )
            residues[a] = {
                "t_param": t_param,
                "c_j": c_j,
                "fiber_mod128": fiber_mod128,
            }
        matrix.append({"j": j, "c_j": c_j, "residues": residues})
    return matrix


def scan_j3_step6_kick(
    u_max: int = 20,
) -> dict[str, object]:
    """
    `[B]` Step-6 kick on shell ``j=3`` with ``t=2u`` (even-t side condition).

    Classifies ``ν₂(3m+1)`` for ``m = 486u + 103`` by parity of ``u``.
    """
    closed_mod128 = CONTROLLED_RESIDUES_MOD128
    rows: list[dict[str, object]] = []
    for u in range(0, u_max + 1):
        t = 2 * u
        m = deep_lift_fiber(3, t)
        kick = 3 * m + 1
        nu = v2(kick)
        step = syracuse_odd_step(m)
        rows.append(
            {
                "u": u,
                "t": t,
                "m": m,
                "nu2_kick": nu,
                "u_parity": "even" if u % 2 == 0 else "odd",
                "step6": step,
                "step6_mod128": step % 128,
                "hits_closed_mod128": step % 128 in closed_mod128,
            }
        )
    nu1_even_u = sum(1 for row in rows if row["u_parity"] == "even" and row["nu2_kick"] == 1)
    nu_ge2_odd_u = sum(
        1 for row in rows if row["u_parity"] == "odd" and row["nu2_kick"] >= 2
    )
    return {
        "u_max": u_max,
        "rows": rows,
        "nu2_eq1_on_even_u": nu1_even_u,
        "nu2_ge2_on_odd_u": nu_ge2_odd_u,
        "total_rows": len(rows),
    }


def scan_deep_lift_fiber_dynamics(
    *,
    j_max: int = 5,
    t_max: int = 20,
    depth: int = 3,
) -> dict[str, object]:
    """
    `[B]` Scan ``S^d`` on deep-lift fibers ``243t + c_j`` for small ``t``.

    Governance: diagnostic only — does NOT prove Collatz or net descent.
    """
    rows: list[dict[str, object]] = []
    closed_mod128 = CONTROLLED_RESIDUES_MOD128
    for j in range(1, j_max + 1):
        c_j = deep_lift_constant(j)
        for t in range(0, t_max + 1):
            if j == 3 and t % 2 == 1:
                continue
            n = deep_lift_fiber(j, t)
            orbit = [n]
            cur = n
            for _ in range(depth):
                cur = syracuse_odd_step(cur)
                orbit.append(cur)
            rows.append(
                {
                    "j": j,
                    "t": t,
                    "c_j": c_j,
                    "start": n,
                    "orbit": orbit,
                    "mod128": [x % 128 for x in orbit],
                    "hits_closed_mod128": any(x % 128 in closed_mod128 for x in orbit[1:]),
                }
            )
    hits = sum(1 for row in rows if row["hits_closed_mod128"])
    return {
        "j_max": j_max,
        "t_max": t_max,
        "depth": depth,
        "rows": rows,
        "hits_closed_mod128": hits,
        "total_rows": len(rows),
    }


def export_deep_lift_fiber_dynamics_json(
    path: str = "docs/exports/deep_lift_fiber_dynamics_v215.json",
    **kwargs: object,
) -> dict[str, object]:
    """Export scan results for V2.15 Level-B diagnostics."""
    import json
    from pathlib import Path

    result = scan_deep_lift_fiber_dynamics(**kwargs)  # type: ignore[arg-type]
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    return result
