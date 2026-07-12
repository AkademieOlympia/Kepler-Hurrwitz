"""Tests for deep-lift Hensel-step diagnostic (Ebene A, [B])."""

from __future__ import annotations

from kepler_hurwitz.deep_lift_hensel_diagnostic import (
    analyze_deep_lift_hensel_steps,
    deep_branch_poly,
    deep_lift_constant,
    deep_lift_modulus,
    deep_lift_residue,
    format_padic_bridge_report,
    odd_core,
    verify_padic_bridge_and_offsets,
    v2,
)


def test_deep_lift_residue_matches_decide_samples() -> None:
    assert deep_lift_residue(1) == 1
    assert deep_lift_residue(2) == 3
    assert deep_lift_residue(3) == 3
    assert deep_lift_residue(4) == 11
    assert deep_lift_residue(5) == 27
    assert deep_lift_constant(1) == 169
    assert deep_lift_constant(5) == 208


def test_residue_satisfies_congruence_up_to_six() -> None:
    for j in range(1, 7):
        rho = deep_lift_residue(j)
        assert deep_branch_poly(rho) % deep_lift_modulus(j) == 0


def test_hensel_steps_j1_to_j6() -> None:
    rows = analyze_deep_lift_hensel_steps(6)
    assert len(rows) == 6
    assert rows[0].lift_bit in (0, 1)
    assert rows[4].rho_new == 27
    assert rows[5].c_j == deep_lift_constant(6)
    # Plateau ρ_5 = … = ρ_9 = 27; ν_2(243·27 + 95) = 9 ≠ 5
    assert deep_lift_residue(5) == 27
    assert deep_lift_residue(9) == 27
    from kepler_hurwitz.deep_lift_hensel_diagnostic import v2

    assert v2(deep_branch_poly(27)) == 9


def test_verify_padic_bridge_and_offsets() -> None:
    result = verify_padic_bridge_and_offsets()
    assert result["all_ok"] is True
    terminal = {row["s"]: row for row in result["terminal_checks"]}
    assert terminal[0]["r"] == 1
    assert terminal[0]["v2_m"] == 1
    assert terminal[0]["odd_core_m"] == odd_core(deep_branch_poly(1))
    assert terminal[1]["r"] == 3
    assert terminal[1]["v2_m"] == 3
    assert terminal[1]["odd_core_m"] == deep_lift_constant(3)
    report = format_padic_bridge_report(result)
    assert "ALL OK: True" in report


def test_odd_core_matches_v2_quotient() -> None:
    for r in (1, 3, 11, 59):
        m = deep_branch_poly(r)
        assert odd_core(m) == m >> v2(m)


def test_scan_deep_lift_fiber_dynamics_j3_t_zero() -> None:
    from kepler_hurwitz.deep_lift_hensel_diagnostic import (
        deep_lift_fiber,
        scan_deep_lift_fiber_dynamics,
        syracuse_odd_step,
    )

    assert deep_lift_fiber(3, 0) == 103
    assert syracuse_odd_step(103) == odd_core(3 * 103 + 1)
    result = scan_deep_lift_fiber_dynamics(j_max=3, t_max=4, depth=2)
    assert result["total_rows"] == 13
    j3_t0 = next(row for row in result["rows"] if row["j"] == 3 and row["t"] == 0)
    assert j3_t0["start"] == 103


def test_scan_j3_step6_kick_nu2_by_u_parity() -> None:
    from kepler_hurwitz.deep_lift_hensel_diagnostic import scan_j3_step6_kick

    result = scan_j3_step6_kick(u_max=8)
    assert result["nu2_eq1_on_even_u"] == 5
    assert result["nu2_ge2_on_odd_u"] == 4
    u0 = next(row for row in result["rows"] if row["u"] == 0)
    assert u0["step6"] == 155
    assert u0["nu2_kick"] == 1
