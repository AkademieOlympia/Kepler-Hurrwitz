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


def test_generate_h7_witness_matrix_j1_to_j5() -> None:
    from kepler_hurwitz.deep_lift_hensel_diagnostic import (
        CONTROLLED_RESIDUES_MOD128,
        deep_lift_affine_target_parameter,
        deep_lift_constant,
        generate_h7_witness_matrix,
    )

    matrix = generate_h7_witness_matrix(5)
    assert len(matrix) == 5

    lean_c_j = {1: 169, 2: 206, 3: 103, 4: 173, 5: 208}
    for row in matrix:
        j = int(row["j"])
        assert row["c_j"] == lean_c_j[j]
        residues = row["residues"]
        assert set(residues.keys()) == CONTROLLED_RESIDUES_MOD128
        for a, entry in residues.items():
            assert entry["fiber_mod128"] == a
            assert entry["t_param"] == deep_lift_affine_target_parameter(j, a)
            assert entry["c_j"] == deep_lift_constant(j)


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


def test_scan_step7_kick_on_nu1_terminal_branches() -> None:
    from kepler_hurwitz.deep_lift_hensel_diagnostic import (
        scan_step7_kick_on_nu1_terminal,
    )

    result = scan_step7_kick_on_nu1_terminal(v_max=40)
    assert result["all_terminal_ok"] is True
    assert result["all_nu2_ok"] is True

    rows = {row["v"]: row for row in result["rows"]}
    # v = 0 (even): nu2 = 1, terminal 4374*0 + 233
    assert rows[0]["nu2_kick"] == 1
    assert rows[0]["step7"] == 233
    # v = 3 (= 4*0 + 3): nu2 = 2, terminal 4374*0 + 3397
    assert rows[3]["nu2_kick"] == 2
    assert rows[3]["step7"] == 3397
    # v = 1 (= 4*0 + 1): nu2 >= 3, terminal oddCore(605) = 605
    assert rows[1]["nu2_kick"] >= 3
    assert rows[1]["step7"] == odd_core(2187 * 0 + 605)
    # v = 5 (= 4*1 + 1), w = 1 odd: nu2 >= 3 (not necessarily exactly 3)
    assert rows[5]["nu2_kick"] >= 3
    assert rows[5]["step7"] == odd_core(2187 * 1 + 605)

    histogram = result["terminal_mod128_histogram"]
    assert sum(histogram.values()) == result["total_rows"]
    # Even-v terminals 4374s + 233 ≡ 22s + 105 (mod 128)
    assert rows[0]["step7_mod128"] == 105
    assert rows[2]["step7_mod128"] == (22 * 1 + 105) % 128
    # Odd-v/odd-s terminals 4374w + 3397 ≡ 22w + 69 (mod 128)
    assert rows[3]["step7_mod128"] == 69
    assert rows[7]["step7_mod128"] == (22 * 1 + 69) % 128
