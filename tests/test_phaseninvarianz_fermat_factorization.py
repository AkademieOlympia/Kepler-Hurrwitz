"""Tests for Fermat factorization bridge via cross-talk ΔE (PI-C-04)."""

from __future__ import annotations

import pytest

from kepler_hurwitz.phaseninvarianz_fermat_factorization import (
    GOVERNANCE,
    amplitudes_from_odd_factor,
    delta_e_factored_form,
    factorint_trial,
    fermat_split_difference_of_squares,
    find_amplitudes_for_factors,
    is_on_bc_axis,
    reconstruct_from_amplitudes,
)


class TestBcAxis:
  def test_35_on_bc_axis(self) -> None:
    assert is_on_bc_axis(35)

  def test_143_on_bc_axis(self) -> None:
    assert is_on_bc_axis(143)

  def test_prime_not_on_bc_axis(self) -> None:
    assert not is_on_bc_axis(7)  # a-axis prime (mod 6 = 1)
    assert is_on_bc_axis(5)  # bc-axis prime (mod 6 = 5)


class TestDeltaEIdentity:
  def test_four_linear_factors_n35(self) -> None:
    bx, cx, by, cy = 3.0, 2.0, 3.0, 4.0
    f1, f2, f3, f4 = delta_e_factored_form(bx, cx, by, cy)
    assert f1 == pytest.approx(1.0)
    assert f2 == pytest.approx(5.0)
    assert f3 == pytest.approx(1.0)
    assert f4 == pytest.approx(7.0)
    assert f1 * f2 * f3 * f4 == pytest.approx(35.0)

  def test_reconstruct_from_amplitudes_n35(self) -> None:
    assert reconstruct_from_amplitudes(3.0, 2.0, 3.0, 4.0) == pytest.approx(35.0)

  def test_fermat_split(self) -> None:
    assert fermat_split_difference_of_squares(9.0, 4.0) == pytest.approx(5.0)
    assert fermat_split_difference_of_squares(49.0, 36.0) == pytest.approx(13.0)


class TestFindAmplitudes:
  def test_n35(self) -> None:
    result = find_amplitudes_for_factors(35)
    assert result.success
    assert result.on_bc_axis
    assert result.factor1 == 5
    assert result.factor2 == 7
    assert result.bx == pytest.approx(3.0)
    assert result.cx == pytest.approx(2.0)
    assert result.cy == pytest.approx(4.0)
    assert result.by == pytest.approx(3.0)
    assert result.reconstructed_product == pytest.approx(35.0)
    assert result.delta_e == pytest.approx(35.0)

  def test_n143(self) -> None:
    result = find_amplitudes_for_factors(143)
    assert result.success
    assert result.factor1 == 11
    assert result.factor2 == 13
    assert result.bx == pytest.approx(6.0)
    assert result.cx == pytest.approx(5.0)
    assert result.cy == pytest.approx(7.0)
    assert result.by == pytest.approx(6.0)
    assert result.reconstructed_product == pytest.approx(143.0)

  def test_off_axis_fails(self) -> None:
    result = find_amplitudes_for_factors(21)
    assert not result.success
    assert not result.on_bc_axis


class TestAmplitudesFromOddFactor:
  def test_factor_5(self) -> None:
    bx, cx = amplitudes_from_odd_factor(5)
    assert bx == pytest.approx(3.0)
    assert cx == pytest.approx(2.0)
    assert bx * bx - cx * cx == pytest.approx(5.0)


class TestFactorint:
  def test_semiprime(self) -> None:
    assert factorint_trial(35) == {5: 1, 7: 1}
    assert factorint_trial(143) == {11: 1, 13: 1}


class TestGovernance:
  def test_claim_id(self) -> None:
    assert GOVERNANCE["claim_id"] == "PI-C-04"

  def test_not_general_factorization(self) -> None:
    assert "not_claimed" in GOVERNANCE
    assert "polynomial-time" in GOVERNANCE["not_claimed"]
