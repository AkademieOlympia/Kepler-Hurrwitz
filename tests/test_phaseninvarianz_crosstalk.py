"""Tests for cross-talk / entanglement symmetry breaking on E_bc."""

from __future__ import annotations

import pytest

from kepler_hurwitz.phaseninvarianz_crosstalk import (
    CROSSTALK_TAG,
    GOVERNANCE,
    analyze_crosstalk_swap,
    cross_field_swap_amplitudes,
    crosstalk_delta_e,
    crosstalk_delta_e_expanded,
    crosstalk_delta_e_symbolic_factors,
    is_primality_preserved,
)
from kepler_hurwitz.phaseninvarianz_pauli_energy import energy_bc
from kepler_hurwitz.phaseninvarianz_tensor_invariants import (
    analyze_bc_invariant_subspace,
    invariant_count,
    tensor_operators,
    transform_bc_energy,
)

BX, BY, CX, CY = 1.0, 0.7, 2.0, 0.9


class TestDeltaEAlgebra:
    def test_expanded_matches_factored(self) -> None:
        bx2 = BX * BX
        by2 = BY * BY
        cx2 = CX * CX
        cy2 = CY * CY
        factored = (bx2 - cx2) * (cy2 - by2)
        assert crosstalk_delta_e_expanded(BX, BY, CX, CY) == pytest.approx(factored)
        assert crosstalk_delta_e(BX, BY, CX, CY) == pytest.approx(factored)

    def test_delta_via_energy_difference(self) -> None:
        bx2, by2, cx2, cy2 = cross_field_swap_amplitudes(BX, BY, CX, CY)
        e_intact = energy_bc(BX, BY, CX, CY)
        e_destroyed = energy_bc(bx2, by2, cx2, cy2)
        assert crosstalk_delta_e(BX, BY, CX, CY) == pytest.approx(e_intact - e_destroyed)

    def test_symbolic_factor_string(self) -> None:
        assert crosstalk_delta_e_symbolic_factors() == "(bx^2 - cx^2)(cy^2 - by^2)"


class TestOrthogonalPreservation:
    def test_delta_zero_when_bx_equals_cx(self) -> None:
        assert crosstalk_delta_e(2.0, 3.0, 2.0, 5.0) == pytest.approx(0.0)
        assert is_primality_preserved(2.0, 3.0, 2.0, 5.0)

    def test_delta_zero_when_by_equals_cy(self) -> None:
        assert crosstalk_delta_e(1.0, 2.0, 3.0, 2.0) == pytest.approx(0.0)
        assert is_primality_preserved(1.0, 2.0, 3.0, 2.0)

    def test_generic_point_nonzero(self) -> None:
        delta = crosstalk_delta_e(BX, BY, CX, CY)
        assert delta != pytest.approx(0.0)
        assert not is_primality_preserved(BX, BY, CX, CY)


class TestCrosstalkReport:
    def test_analyze_report_fields(self) -> None:
        report = analyze_crosstalk_swap(BX, BY, CX, CY)
        assert report.delta_e == pytest.approx(-0.96)
        assert report.factored_form == "(bx^2 - cx^2)(cy^2 - by^2)"
        assert report.primality_preserved is False
        assert report.tag == CROSSTALK_TAG
        assert len(report.expanded_terms_intact) == 4


class TestLocalPauli15Invariant:
    def test_fifteen_ops_count(self) -> None:
        assert len(tensor_operators()) == 15

    @pytest.mark.parametrize(
        ("bx", "by", "cx", "cy"),
        [
            (1.0, 0.7, 2.0, 0.9),
            (3.0, 1.0, 2.0, 4.0),
            (-1.0, 2.0, 0.5, 3.0),
        ],
    )
    def test_all_15_local_ops_invariant(
        self, bx: float, by: float, cx: float, cy: float
    ) -> None:
        e_before = energy_bc(bx, by, cx, cy)
        for op in tensor_operators():
            op_b, op_c = op[0], op[1]
            e_after = transform_bc_energy(op_b, op_c, bx, by, cx, cy)
            assert float(e_after) == pytest.approx(e_before)

    def test_audit_all_15_flag(self) -> None:
        records = analyze_bc_invariant_subspace(BX, BY, CX, CY)
        assert len(records) == 15
        assert invariant_count(records) == 15
        assert all(rec.is_invariant for rec in records)


class TestGovernance:
    def test_claim_id(self) -> None:
        assert GOVERNANCE["claim_id"] == "PI-C-03"
        assert "primality" in GOVERNANCE["reading_c"].lower()
