"""Tests for EABC energetic square-sum substitution."""

from __future__ import annotations

import pytest

from kepler_hurwitz.eabc_energy_square_sum import (
    ENERGY_SQUARE_SUM_TAG,
    GOVERNANCE,
    axis_energy_from_amplitudes,
    expanded_energy_terms,
    symmetric_axes_energy_template,
    total_energy_with_eeg,
)


class TestAxisEnergy:
    @pytest.mark.parametrize(
        ("ax", "ay"),
        [
            (1.0, 0.0),
            (0.0, 2.0),
            (3.0, 4.0),
            (-2.0, 1.5),
            (0.1, 0.1),
        ],
    )
    def test_a_energy_positive_for_real_amplitudes(self, ax: float, ay: float) -> None:
        state = axis_energy_from_amplitudes(ax, ay)
        assert state.a_energy == ax * ax + ay * ay
        assert state.a_energy >= 0.0
        assert state.e_i == ax * ax
        assert state.e_j == ay * ay

    def test_zero_amplitudes_give_zero_energy(self) -> None:
        state = axis_energy_from_amplitudes(0.0, 0.0)
        assert state.e_i == 0.0
        assert state.e_j == 0.0
        assert state.a_energy == 0.0
        assert total_energy_with_eeg(1.0, state.a_energy) == 0.0


class TestEegScaling:
    def test_total_expands_correctly(self) -> None:
        ax, ay, eeg = 2.0, 3.0, 5.0
        state = axis_energy_from_amplitudes(ax, ay)
        expected = eeg * (ax * ax + ay * ay)
        assert total_energy_with_eeg(eeg, state.a_energy) == pytest.approx(expected)

    def test_expanded_terms_match_total(self) -> None:
        ax, ay, eeg = 1.5, 2.5, 3.0
        terms = expanded_energy_terms(eeg, ax, ay)
        assert set(terms) == {"eeg*ax^2", "eeg*ay^2"}
        assert terms["eeg*ax^2"] == pytest.approx(eeg * ax * ax)
        assert terms["eeg*ay^2"] == pytest.approx(eeg * ay * ay)
        total = terms["eeg*ax^2"] + terms["eeg*ay^2"]
        state = axis_energy_from_amplitudes(ax, ay)
        assert total == pytest.approx(total_energy_with_eeg(eeg, state.a_energy))


class TestSymmetricTemplate:
    def test_all_six_axes_present(self) -> None:
        template = symmetric_axes_energy_template()
        assert set(template) == {"a", "b", "c", "ab", "ac", "bc"}
        for axis, spec in template.items():
            assert "energy" in spec
            assert spec["tag"] == ENERGY_SQUARE_SUM_TAG
            assert "^2" in spec["energy"]


class TestGovernance:
    def test_claim_id(self) -> None:
        assert GOVERNANCE["claim_id"] == "BH-C-11"
        assert "QM" in GOVERNANCE["not_claimed"] or "Hamiltonian" in GOVERNANCE["not_claimed"]
