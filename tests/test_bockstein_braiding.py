"""Tests fuer den [B] Bockstein-Braiding-Toy-Layer.

Hauptclaim: phase(W_N) in mu_N (phase^N ≈ 1). Numerische W^N=I-Checks sind
nur Skalar-Folgechecks fuer zentral-skalar W_N, kein allgemeiner Operator-Claim.
"""
import numpy as np
import pytest

from kepler_hurwitz.bockstein_braiding import (
    GroupRingVerification,
    HeisenbergVerification,
    VariableFluxDemo,
    a_pq_default,
    effective_flux_mod_n,
    grid_holonomy_mod_n,
    heisenberg_matrices,
    is_central_scalar,
    k_plaquette,
    k_plaquette_variable,
    lattice_2d_demo,
    lattice_2d_variable_demo,
    matrices_allclose,
    staircase_holonomy_mod_n,
    torus_pow,
    verify_group_ring,
    verify_heisenberg,
    w_n_matrix,
    w_n_torus,
)


NS = (2, 3, 4, 5)
ALPHAS = (2, 3)


def _phase_power_n_is_one(phase: complex, n: int, tol: float = 1e-10) -> bool:
    """Defensiver Check: phase(W_N) in mu_N, d.h. phase^N ≈ 1."""
    return abs(phase**n - 1.0) < tol


@pytest.mark.parametrize("n", NS)
def test_group_ring_w_n_is_trivial(n):
    result = verify_group_ring(n, alphas=ALPHAS)
    assert isinstance(result, GroupRingVerification)
    assert result.w_is_one
    assert result.w_power_n_is_one
    assert all(ok for _, ok in result.linearity)


@pytest.mark.parametrize("n", NS)
def test_heisenberg_w_n_phase_quantization(n):
    """phase(W_N) in mu_N (phase^N ≈ 1) plus Linearitaet; nicht Operator-Claim W^N=I."""
    result = verify_heisenberg(n, flux=1, alphas=ALPHAS)
    assert isinstance(result, HeisenbergVerification)
    assert result.plaquette_commutator_ok
    assert result.w_central
    assert result.w_phase is not None
    assert result.phase_power_n_is_one
    assert _phase_power_n_is_one(result.w_phase, n)
    assert result.w_power_n_is_one  # numerischer Skalar-Folgecheck
    assert all(ok for _, ok in result.linearity)


@pytest.mark.parametrize("n", NS)
def test_heisenberg_w_phase_on_unit_circle(n):
    result = verify_heisenberg(n, flux=1, alphas=ALPHAS)
    assert result.w_phase is not None
    assert abs(abs(result.w_phase) - 1.0) < 1e-10


@pytest.mark.parametrize("n", NS)
def test_w_n_matrix_phase_power_n(n):
    """Direktcheck: phase(W_N)^N ≈ 1 fuer zentral-skalar W_N (nicht allgemeiner Operator-Claim)."""
    x, y, _, _, identity = heisenberg_matrices(n, flux=1)
    w = w_n_matrix(x, y, n)
    central, phase = is_central_scalar(w, identity)
    assert central and phase is not None
    assert _phase_power_n_is_one(phase, n)
    assert matrices_allclose(np.linalg.matrix_power(w, n), identity)


@pytest.mark.parametrize("n", NS)
def test_linearity_w_n_x_alpha_y(n):
    x, y, _, _, _ = heisenberg_matrices(n, flux=1)
    w_base = w_n_matrix(x, y, n)
    for alpha in ALPHAS:
        if alpha >= n:
            continue
        x_alpha = np.linalg.matrix_power(x, alpha)
        w_alpha = w_n_matrix(x_alpha, y, n)
        w_pow = np.linalg.matrix_power(w_base, alpha)
        assert matrices_allclose(w_alpha, w_pow)


def test_torus_w_n_commutative():
    for n in NS:
        w = w_n_torus((1, 0), (0, 1), n)
        assert w == (0, 0)
        assert torus_pow(w, n, n) == (0, 0)


@pytest.mark.parametrize("n,a", [(3, 1), (3, 2), (4, 1), (4, 2), (5, 1), (5, 2)])
def test_lattice_2d_demo(n, a):
    if a >= n:
        pytest.skip("a >= n")
    result = lattice_2d_demo(n, a=a)
    assert result.phase_power_n_is_one
    assert result.w_power_n_is_one
    assert result.linearity_flux
    assert result.k_sum_mod_n == 0


def test_k_plaquette_homogeneous():
    n = 5
    a = 2
    assert k_plaquette(1, 2, a, n) == (a * 3) % n
    assert k_plaquette(3, 4, a, n) == k_plaquette(4, 3, a, n)


def test_plaquette_commutator_phase():
    n = 4
    flux = 1
    x, y, zeta, twist, identity = heisenberg_matrices(n, flux=flux)
    comm = x @ y @ np.linalg.inv(x) @ np.linalg.inv(y)
    expected = (twist.conjugate()) * identity
    assert matrices_allclose(comm, expected)
    central, phase = is_central_scalar(comm, identity)
    assert central
    assert abs(phase - zeta ** (-flux)) < 1e-10


@pytest.mark.parametrize("n,a", [(3, 1), (4, 1), (4, 2), (5, 1), (5, 2)])
def test_variable_flux_homogeneous_int_matches_lattice(n, a):
    if a >= n:
        pytest.skip("a >= n")
    demo = lattice_2d_variable_demo(n, a_spec=a)
    assert isinstance(demo, VariableFluxDemo)
    assert demo.staircase_holonomy_mod_n == 0
    assert demo.grid_holonomy_mod_n == 0
    assert demo.effective_flux == a
    assert demo.phase_power_n_is_one
    assert demo.w_power_n_is_one
    assert demo.linearity_flux


@pytest.mark.parametrize("n", (3, 4, 5, 7))
def test_variable_flux_default_a_pq(n):
    demo = lattice_2d_variable_demo(n, a_spec=lambda p, q, n=n: a_pq_default(p, q, n))
    assert demo.phase_power_n_is_one
    assert demo.w_power_n_is_one
    assert demo.linearity_flux
    assert demo.grid_holonomy_mod_n == 0


def test_variable_flux_staircase_vs_grid_n4():
    """Hsin-Chen-Muster: Treppe kann mod N nontrivial sein, Gitter-Summe verschwindet."""
    n = 4
    demo = lattice_2d_variable_demo(n, a_spec=lambda p, q: a_pq_default(p, q, n))
    assert demo.staircase_holonomy_mod_n == 2
    assert demo.grid_holonomy_mod_n == 0
    assert demo.effective_flux == 2


@pytest.mark.parametrize(
    "a_fn",
    [
        lambda p, q: (p + 2 * q) % 5,
        lambda p, q: (3 * p + q) % 5,
        lambda p, q: (p * q + 1) % 5,
    ],
)
def test_variable_flux_callable_n5(a_fn):
    n = 5
    demo = lattice_2d_variable_demo(n, a_spec=a_fn)
    assert demo.phase_power_n_is_one
    assert demo.w_power_n_is_one
    assert demo.linearity_flux
    assert demo.staircase_holonomy_mod_n == staircase_holonomy_mod_n(a_fn, n)
    assert demo.grid_holonomy_mod_n == grid_holonomy_mod_n(a_fn, n)
    assert demo.effective_flux == effective_flux_mod_n(a_fn, n)


def test_k_plaquette_variable_callable():
    n = 5
    fn = lambda p, q: (p + 2 * q) % n
    assert k_plaquette_variable(1, 2, fn, n) == 5 % n
    assert k_plaquette_variable(1, 2, 2, n) == k_plaquette(1, 2, 2, n)
