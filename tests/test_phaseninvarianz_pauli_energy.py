"""Tests for Pauli phase invariance on EABC energy terms."""

from __future__ import annotations

import pytest

from kepler_hurwitz.phaseninvarianz_pauli_energy import (
    GOVERNANCE,
    PHASENINVARIANZ_TAG,
    apply_pauli_x_to_a,
    apply_pauli_z_to_a,
    apply_tensor_x_error_bc,
    energy_a,
    energy_bc,
    is_tensor_x_bc_invariant,
    pauli_invariance_report,
)


class TestEnergyA:
    @pytest.mark.parametrize(
        ("ax", "ay"),
        [
            (1.0, 0.0),
            (0.0, 2.0),
            (3.0, 4.0),
            (-2.0, 1.5),
            (0.1, -0.1),
        ],
    )
    def test_z_invariant(self, ax: float, ay: float) -> None:
        ax_z, ay_z = apply_pauli_z_to_a(ax, ay)
        assert energy_a(ax, ay) == pytest.approx(energy_a(ax_z, ay_z))

    @pytest.mark.parametrize(
        ("ax", "ay"),
        [
            (1.0, 0.0),
            (0.0, 2.0),
            (3.0, 4.0),
            (-2.0, 1.5),
        ],
    )
    def test_x_invariant(self, ax: float, ay: float) -> None:
        ax_x, ay_x = apply_pauli_x_to_a(ax, ay)
        assert energy_a(ax, ay) == pytest.approx(energy_a(ax_x, ay_x))


class TestEnergyBc:
    def test_tensor_x_changes_generic_case(self) -> None:
        bx, by, cx, cy = 3.0, 1.0, 2.0, 4.0
        bx2, by2, cx2, cy2 = apply_tensor_x_error_bc(bx, by, cx, cy)
        assert energy_bc(bx, by, cx, cy) != pytest.approx(energy_bc(bx2, by2, cx2, cy2))

    def test_tensor_x_symmetric_special_case(self) -> None:
        bx, by, cx, cy = 1.0, 1.0, 1.0, 1.0
        bx2, by2, cx2, cy2 = apply_tensor_x_error_bc(bx, by, cx, cy)
        assert energy_bc(bx, by, cx, cy) == pytest.approx(energy_bc(bx2, by2, cx2, cy2))
        assert is_tensor_x_bc_invariant(bx, by, cx, cy)

    def test_invariant_when_bx_equals_cx(self) -> None:
        bx, by, cx, cy = 2.0, 3.0, 2.0, 5.0
        assert is_tensor_x_bc_invariant(bx, by, cx, cy)


class TestPauliInvarianceReport:
    def test_report_flags(self) -> None:
        report = pauli_invariance_report(
            {"ax": 1.0, "ay": 2.0, "bx": 3.0, "by": 1.0, "cx": 2.0, "cy": 4.0}
        )
        assert report["invariant_under_z"] is True
        assert report["invariant_under_x"] is True
        assert report["invariant_under_tensor_x"] is False
        assert report["tag"] == PHASENINVARIANZ_TAG
        assert set(report["bc_cross_terms_before"]) == {
            "bx^2*cx^2",
            "bx^2*cy^2",
            "by^2*cx^2",
            "by^2*cy^2",
        }

    def test_report_symmetric_bc_case(self) -> None:
        report = pauli_invariance_report(
            {"ax": 1.0, "ay": 1.0, "bx": 2.0, "by": 2.0, "cx": 2.0, "cy": 2.0}
        )
        assert report["invariant_under_tensor_x"] is True
        assert report["symmetric_tensor_x_special_case"] is True


class TestGovernance:
    def test_claim_id(self) -> None:
        assert GOVERNANCE["claim_id"] == "PI-C-01"
        assert "QEC" in GOVERNANCE["reading_c"] or "qec" in GOVERNANCE["reading_c"].lower()
