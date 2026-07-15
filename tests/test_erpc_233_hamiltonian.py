"""Unit tests für [A/B] ERPC 2+3+3-Hamiltonoperator (ohne kwant-Pflicht)."""

import numpy as np

from kepler_hurwitz.erpc_233_hamiltonian import (
    CHARGE_AUDIT_ALLOWED_ATOL,
    CHARGE_AUDIT_SCENARIOS,
    CHARGE_AUDIT_VIOLATION_RTOL,
    DIM_B,
    DIM_C,
    DIM_EA,
    NORB,
    ERPC233Params,
    IntChargeConfig,
    audit_charge_commutator,
    audit_hermiticity,
    audit_projectors,
    build_d_int,
    build_finite_hamiltonian,
    build_internal_gauge_matrix,
    is_block_diagonal,
    off_diagonal_coupling_allowed,
    onsite_block,
    random_d_int_blocks,
    run_standard_charge_audits,
    sector_projectors,
    sector_weights,
)


def test_sector_dimensions():
    assert DIM_EA + DIM_B + DIM_C == NORB == 8


def test_projector_identities():
    audit = audit_projectors()
    assert audit["passed"]
    assert audit["sum_defect_fro"] <= 1e-14
    assert audit["max_orth_defect_fro"] <= 1e-14


def test_hermiticity_all_coupling_classes():
    for cc in ("none", "ea_b_only", "ea_c_only", "ea_bc_symmetric"):
        for g in (0.0, 0.25, 0.5):
            params = ERPC233Params(delta=0.25).with_coupling_class(cc, g)
            audit = audit_hermiticity(params)
            assert audit["passed"], cc


def test_block_diagonal_null_model():
    params = ERPC233Params().with_coupling_class("none", 0.0)
    assert is_block_diagonal(params)
    h = build_finite_hamiltonian(params)
    # Off-Diagonal zwischen EA- und B-Block an derselben Site
    assert np.allclose(h[0:2, 2:5], 0.0)
    assert np.allclose(h[2:5, 5:8], 0.0)


def test_coupling_activates_offdiagonal():
    params = ERPC233Params(g_eb=0.25, g_ec=0.0, g_bc=0.0)
    block = onsite_block(0, params)
    assert np.linalg.norm(block[0:2, 2:5]) > 0


def test_sector_weights_sum_to_one():
    psi = np.random.default_rng(0).standard_normal(NORB) + 1j * np.random.default_rng(1).standard_normal(NORB)
    w = sector_weights(psi)
    assert abs(sum(w.values()) - 1.0) < 1e-12
    assert set(w.keys()) == {"EA", "B", "C"}


def test_chi_eleven_modulation_changes_ea_block():
    p0 = ERPC233Params(delta=0.9)
    blocks = [onsite_block(x, p0) for x in range(12)]
    # Nicht-triviale χ₁₁-Sites sollten EA-Diagonalen unterscheiden
    ea_diags = [np.diag(b[0:2, 0:2]) for b in blocks]
    assert len({tuple(np.round(d, 8)) for d in ea_diags}) > 1


def test_finite_hamiltonian_dimension():
    params = ERPC233Params(L=36)
    h = build_finite_hamiltonian(params)
    assert h.shape == (288, 288)


def test_projectors_are_hermitian():
    for p in sector_projectors().values():
        assert np.allclose(p, p.conj().T)


def test_off_diagonal_coupling_allowed_matches_lean_rules():
    q = IntChargeConfig(1, 1, -2)
    assert off_diagonal_coupling_allowed(q, "EA", "EA")
    assert off_diagonal_coupling_allowed(q, "B", "EA")
    assert not off_diagonal_coupling_allowed(q, "C", "EA")
    assert not off_diagonal_coupling_allowed(q, "B", "C")


def test_build_d_int_is_hermitian():
    rng = np.random.default_rng(0)
    blocks = random_d_int_blocks(IntChargeConfig.neutral(), rng)
    d_int = build_d_int(**blocks)
    assert d_int.shape == (NORB, NORB)
    assert np.linalg.norm(d_int - d_int.conj().T, ord="fro") <= 1e-12


def test_neutral_gauge_matrix_is_identity():
    g = build_internal_gauge_matrix(0.7, IntChargeConfig.neutral())
    assert np.allclose(g, np.eye(NORB))


def test_charge_audit_neutral_scenario():
    metrics = audit_charge_commutator(IntChargeConfig.neutral(), seed=42)
    assert metrics["allowed_passed"]
    assert metrics["max_comm_allowed"] <= CHARGE_AUDIT_ALLOWED_ATOL
    assert metrics["violation_passed"] is None


def test_charge_audit_partial_and_full_scenarios():
    for q in (IntChargeConfig(1, 1, -2), IntChargeConfig(1, 2, 3)):
        metrics = audit_charge_commutator(q, seed=7)
        assert metrics["allowed_passed"]
        assert metrics["max_comm_allowed"] <= CHARGE_AUDIT_ALLOWED_ATOL
        assert metrics["violation_passed"]
        assert metrics["max_comm_violating"] > CHARGE_AUDIT_VIOLATION_RTOL


def test_standard_charge_audits_all_pass():
    results = run_standard_charge_audits(seed=0)
    assert len(results) == len(CHARGE_AUDIT_SCENARIOS)
    assert all(r.allowed_passed for r in results)
    assert results[0].violation_passed is None
    assert all(r.violation_passed for r in results[1:])
