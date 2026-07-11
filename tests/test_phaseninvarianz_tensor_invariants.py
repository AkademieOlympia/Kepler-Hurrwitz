"""Tests for Pauli tensor invariant subspace on bc-axis quartic energy."""

from __future__ import annotations

from fractions import Fraction

import pytest

from kepler_hurwitz.phaseninvarianz_tensor_invariants import (
    GOVERNANCE,
    PAULI_OPS,
    TENSOR_INVARIANT_TAG,
    analyze_a_invariant_subspace,
    analyze_bc_invariant_subspace,
    apply_pauli_to_pair,
    energy_bc_from_amplitudes,
    energy_pair_from_amplitudes,
    invariant_count,
    is_bc_energy_invariant,
    single_pair_energy_invariant,
    tensor_operators,
    transform_bc_energy,
    transform_pair_energy,
)

GENERIC_BC = (Fraction("6"), Fraction("5"), Fraction("7"), Fraction("3"))


class TestTensorOperators:
    def test_fifteen_operators_generated(self) -> None:
        ops = tensor_operators()
        assert len(ops) == 15
        assert "II" not in ops
        assert set(ops) == {
            f"{b}{c}" for b in PAULI_OPS for c in PAULI_OPS if not (b == "I" and c == "I")
        }


class TestSinglePairInvariance:
    @pytest.mark.parametrize("op", PAULI_OPS)
    def test_symbolic_flag(self, op: str) -> None:
        assert single_pair_energy_invariant(op) is True

    @pytest.mark.parametrize(
        ("vx", "vy"),
        [
            (Fraction(12, 10), Fraction(7, 10)),
            (Fraction(3, 2), Fraction(-1, 4)),
            (Fraction(0), Fraction(5)),
        ],
    )
    @pytest.mark.parametrize("op", PAULI_OPS)
    def test_exact_rational_invariance(self, op: str, vx: Fraction, vy: Fraction) -> None:
        e_before = energy_pair_from_amplitudes(vx, vy)
        e_after = transform_pair_energy(op, vx, vy)
        assert e_before == e_after


class TestBcInvariance:
    def test_all_fifteen_invariant_at_generic_amplitudes(self) -> None:
        bx, by, cx, cy = (1.2, 0.7, 2.1, 0.9)
        records = analyze_bc_invariant_subspace(bx, by, cx, cy)
        assert len(records) == 15
        count = invariant_count(records)
        assert count == 15
        assert all(rec.is_invariant for rec in records)

    def test_exact_fraction_generic_bc(self) -> None:
        bx, by, cx, cy = GENERIC_BC
        records = analyze_bc_invariant_subspace(bx, by, cx, cy)
        assert invariant_count(records) == 15

    @pytest.mark.parametrize("op", tensor_operators())
    def test_symbolic_is_bc_invariant(self, op: str) -> None:
        assert is_bc_energy_invariant(op[0], op[1]) is True

    def test_z_and_x_combinations_invariant(self) -> None:
        bx, by, cx, cy = GENERIC_BC
        zx_ops = [op for op in tensor_operators() if op[0] in "IXZ" and op[1] in "IXZ"]
        assert len(zx_ops) == 8  # 3×3 minus II
        e_before = energy_bc_from_amplitudes(bx, by, cx, cy)
        for op in zx_ops:
            e_after = transform_bc_energy(op[0], op[1], bx, by, cx, cy)
            assert e_before == e_after

    def test_y_operators_invariant(self) -> None:
        bx, by, cx, cy = GENERIC_BC
        y_ops = [op for op in tensor_operators() if "Y" in op]
        assert len(y_ops) == 7
        e_before = energy_bc_from_amplitudes(bx, by, cx, cy)
        for op in y_ops:
            e_after = transform_bc_energy(op[0], op[1], bx, by, cx, cy)
            assert e_before == e_after


class TestAAxisComparison:
    def test_a_axis_same_invariant_count(self) -> None:
        ax, ay = Fraction(12, 10), Fraction(7, 10)
        records = analyze_a_invariant_subspace(ax, ay)
        assert len(records) == 15
        assert invariant_count(records) == 15


class TestApplyPauliToPair:
    def test_x_swap(self) -> None:
        out = apply_pauli_to_pair("X", 1.0, 2.0)
        assert out == {"vx": 2.0, "vy": 1.0}

    def test_y_transform(self) -> None:
        out = apply_pauli_to_pair("Y", 3.0, 4.0)
        assert out == {"vx": -4.0, "vy": 3.0}

    def test_with_amplitudes_dict(self) -> None:
        amps = {"bx": 1.0, "by": 2.0, "cx": 3.0}
        out = apply_pauli_to_pair("Z", 1.0, 2.0, amplitudes=amps, vx_key="bx", vy_key="by")
        assert out["bx"] == 1.0
        assert out["by"] == -2.0
        assert out["cx"] == 3.0


class TestGovernance:
    def test_claim_id(self) -> None:
        assert GOVERNANCE["claim_id"] == "PI-C-02"
        assert "15" in GOVERNANCE["facts_ab"] or "tensor" in GOVERNANCE["facts_ab"].lower()

    def test_tag(self) -> None:
        records = analyze_bc_invariant_subspace(1.0, 1.0, 1.0, 1.0)
        assert all(rec.tag == TENSOR_INVARIANT_TAG for rec in records)
