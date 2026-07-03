import pytest

from kepler_hurwitz.arithmetic_evolution import DEFAULT_TARGET_PRIME_NORMS, default_arithmetic_prime_operators
from kepler_hurwitz.hurwitz_lattice_sieve import (
    DEFAULT_CUBE_RADIUS,
    MAX_NORM_SQ_IN_CUBE,
    REQUESTED_ODD_PRIME_NORMS,
    SHELL_PROXY_NORMS,
    _is_prime,
    collect_hurwitz_norm_sq_in_cube,
    exists_hurwitz_norm_sq_in_cube,
    odd_prime_norms_in_hurwitz_cube,
)


@pytest.mark.slow
def test_no_odd_prime_norms_on_hurwitz_cube():
    """
    Manuscript claim: in [-5,5]^8 the Hurwitz skeleton carries no odd prime squared norms.

    This is stronger than the Jacobi/Z^8 representability question: Hurwitz points require
    either an even integer coordinate sum or a half-integer coset with even parity.
    """
    odd_primes = odd_prime_norms_in_hurwitz_cube(is_prime=_is_prime)
    assert odd_primes == (), f"unexpected odd prime norms on Hurwitz cube: {odd_primes}"


@pytest.mark.slow
def test_requested_target_norms_absent_shell_proxies_present():
    """Cross-check arithmetic_evolution.py shell-proxy wiring against the lattice sieve."""
    for requested in DEFAULT_TARGET_PRIME_NORMS:
        assert requested in REQUESTED_ODD_PRIME_NORMS
        assert not exists_hurwitz_norm_sq_in_cube(requested, radius=DEFAULT_CUBE_RADIUS)

    for operator in default_arithmetic_prime_operators():
        assert operator.actual_norm in SHELL_PROXY_NORMS
        assert exists_hurwitz_norm_sq_in_cube(operator.actual_norm, radius=DEFAULT_CUBE_RADIUS)


def test_half_integer_branch_carries_only_even_norms():
    from kepler_hurwitz.hurwitz_lattice_sieve import collect_half_integer_hurwitz_norm_sq_in_cube

    half_norms = collect_half_integer_hurwitz_norm_sq_in_cube()
    assert half_norms, "expected a non-empty half-integer norm spectrum"
    assert all(norm % 2 == 0 for norm in half_norms)


@pytest.mark.slow
def test_hurwitz_norm_spectrum_within_cube_cap():
    int_norms = collect_hurwitz_norm_sq_in_cube()
    assert int_norms, "expected a non-empty Hurwitz norm spectrum"
    assert max(int_norms) <= MAX_NORM_SQ_IN_CUBE
    assert 2 in int_norms
    assert 4 in int_norms


def test_naive_z8_odd_primes_are_not_the_hurwitz_claim():
    """
    Guardrail: full Z^8 would realize many odd primes (Jacobi); the manuscript claim is
    Hurwitz-specific and therefore does NOT assert computed_norms == all odd primes.
    """
    assert _is_prime(3)
    assert exists_hurwitz_norm_sq_in_cube(3, radius=DEFAULT_CUBE_RADIUS) is False


def test_sage_is_prime_agrees_on_cube_spectrum():
    sage = pytest.importorskip("sage.all")
    odd_primes = odd_prime_norms_in_hurwitz_cube(is_prime=sage.is_prime)
    assert odd_primes == ()
