"""Tests for EABC dual-axis vector vs bivector energy asymmetry (a vs bc)."""

from __future__ import annotations

import pytest

from kepler_hurwitz.eabc_energy_square_sum import (
    GOVERNANCE,
    axis_a_energy,
    axis_bc_energy,
    bivector_energy_from_amplitudes,
    compare_dual_axis_scaling,
    dual_axis_totals_with_eeg,
    expanded_bc_terms,
)


class TestAxisAEnergy:
    def test_quadratic_sum(self) -> None:
        assert axis_a_energy(3.0, 4.0) == pytest.approx(25.0)

    @pytest.mark.parametrize(
        ("ax", "ay"),
        [(1.0, 1.0), (2.0, 0.0), (-1.5, 2.0)],
    )
    def test_equals_ax_squared_plus_ay_squared(self, ax: float, ay: float) -> None:
        assert axis_a_energy(ax, ay) == pytest.approx(ax * ax + ay * ay)


class TestAxisBcEnergy:
    def test_expands_to_four_cross_terms(self) -> None:
        bx, by, cx, cy = 1.0, 2.0, 3.0, 4.0
        terms = expanded_bc_terms(bx, by, cx, cy)
        assert set(terms) == {
            "bx^2*cx^2",
            "bx^2*cy^2",
            "by^2*cx^2",
            "by^2*cy^2",
        }
        assert sum(terms.values()) == pytest.approx(axis_bc_energy(bx, by, cx, cy))

    def test_bivector_state_matches_product(self) -> None:
        state = bivector_energy_from_amplitudes(1.0, 1.0, 1.0, 1.0)
        assert state.e_b == pytest.approx(2.0)
        assert state.e_c == pytest.approx(2.0)
        assert state.bc_energy == pytest.approx(4.0)
        assert sum(state.cross_terms.values()) == pytest.approx(state.bc_energy)


class TestEqualUnitAmplitudes:
    def test_e_a_is_two_e_bc_is_four(self) -> None:
        cmp = compare_dual_axis_scaling(1.0, 1.0, 1.0, 1.0, 1.0, 1.0)
        assert cmp["e_a"] == pytest.approx(2.0)
        assert cmp["e_bc"] == pytest.approx(4.0)
        assert cmp["ratio_e_bc_over_e_a"] == pytest.approx(2.0)
        assert cmp["amplitudes_equal"] == pytest.approx(1.0)


class TestQuarticScaling:
    def test_double_bc_amplitudes_scales_by_sixteen(self) -> None:
        base = axis_bc_energy(1.0, 1.0, 1.0, 1.0)
        scaled = axis_bc_energy(2.0, 2.0, 2.0, 2.0)
        assert scaled == pytest.approx(16.0 * base)

    def test_a_axis_scales_quadratically(self) -> None:
        base = axis_a_energy(1.0, 1.0)
        scaled = axis_a_energy(2.0, 2.0)
        assert scaled == pytest.approx(4.0 * base)


class TestDualAxisEeg:
    def test_totals(self) -> None:
        totals = dual_axis_totals_with_eeg(3.0, 2.0, 4.0)
        assert totals["total_E_a"] == pytest.approx(6.0)
        assert totals["total_E_bc"] == pytest.approx(12.0)


class TestGovernance:
    def test_meson_analogy_not_claimed(self) -> None:
        assert "meson" in GOVERNANCE["not_claimed"].lower()
        assert GOVERNANCE["claim_id"] == "BH-C-11"
