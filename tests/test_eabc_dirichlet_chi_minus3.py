"""Tests for Dirichlet chi_{-3} EABC axis conjugator scaffold [C]."""

from __future__ import annotations

import pytest

from kepler_hurwitz.eabc_dirichlet_chi_minus3 import (
    DIRICHLET_CHI_TAG,
    GOVERNANCE,
    chi_minus3,
    compare_zeta_vs_lchi_axis_resonance,
    compute_l_chi_partial_sum,
    compute_l_chi_resonance_sum,
    split_prime_contribution,
)
from kepler_hurwitz.eabc_monopole_axis_resonance import FIRST_RIEMANN_ZEROS


class TestChiMinus3:
    @pytest.mark.parametrize(
        ("n", "expected"),
        [
            (1, 1),
            (2, -1),
            (3, 0),
            (6, 0),
            (7, 1),
            (11, -1),
            (13, 1),
        ],
    )
    def test_character_values(self, n: int, expected: int) -> None:
        assert chi_minus3(n) == expected

    def test_non_positive_zero(self) -> None:
        assert chi_minus3(0) == 0
        assert chi_minus3(-5) == 0


class TestSplitPrimeContribution:
    def test_axis_a_prime(self) -> None:
        row = split_prime_contribution(7, s_real=1.0)
        assert row["chi"] == 1
        assert row["axis"] == "a"
        assert row["weight"] == pytest.approx(7 ** (-1.0))

    def test_axis_bc_prime(self) -> None:
        row = split_prime_contribution(11, s_real=1.0)
        assert row["chi"] == -1
        assert row["axis"] == "bc"
        assert row["weight"] == pytest.approx(-(11 ** (-1.0)))

    def test_multiple_of_three(self) -> None:
        row = split_prime_contribution(3, s_real=1.0)
        assert row["chi"] == 0
        assert row["weight"] == 0.0


class TestLChiPartialSum:
    def test_finite_positive_s(self) -> None:
        val = compute_l_chi_partial_sum(2.0, prime_limit=100)
        assert val == pytest.approx(val)
        assert abs(val) < 1.0

    def test_resonance_matches_delta(self) -> None:
        gamma = FIRST_RIEMANN_ZEROS[0]
        limit = 2_000
        cmp = compare_zeta_vs_lchi_axis_resonance(gamma, limit)
        lchi = compute_l_chi_resonance_sum(gamma, limit)
        assert cmp.lchi_weighted_sum == pytest.approx(lchi)
        assert cmp.delta_unweighted == pytest.approx(cmp.psi_a - cmp.psi_bc)
        assert cmp.lchi_weighted_sum == pytest.approx(cmp.delta_unweighted, rel=1e-12)


class TestZetaVsLChiComparison:
    def test_comparison_fields(self) -> None:
        cmp = compare_zeta_vs_lchi_axis_resonance(FIRST_RIEMANN_ZEROS[0], 1_000)
        assert cmp.tag == DIRICHLET_CHI_TAG
        assert cmp.asymmetry_ratio >= 0.0
        assert cmp.zeta_symmetry_score >= 0.0

    def test_governance_declares_c(self) -> None:
        assert GOVERNANCE["tag_interpretive"] == DIRICHLET_CHI_TAG
        assert "not_claimed" in GOVERNANCE
