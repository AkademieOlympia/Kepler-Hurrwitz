"""Tests for canonical e³ decomposition diagnostic."""

from __future__ import annotations

import pytest

from kepler_hurwitz.e3_decomposition import (
    E3_DECOMPOSITION_TAG,
    E3_PRODUCT_ANALOGY_TAG,
    EABC_GEOM_DIAGONAL,
    abc_split_decomposition,
    analyze_e3_commutative_multiplet,
    analyze_e3_decomposition,
    analyze_e3_with_product_split,
    commutation_check,
    compare_e3_eabc_anisotropy,
    e3_decompose,
    e3_spectral_diagnostic,
    eabc_channel_weight_from_factor,
    eabc_defect_tensor,
    eabc_retract_defect,
    eabc_tensor_spectral_summary,
    symmetric_operators,
    verify_abc_split,
    verify_e3_identity,
)


class TestE3Decompose:
    @pytest.mark.parametrize(
        ("a", "e", "expected"),
        [
            (17, 3, (1, 8, 51)),
            (13, 5, (0, 13, 65)),
        ],
    )
    def test_examples(self, a: int, e: int, expected: tuple[int, int, int]) -> None:
        assert e3_decompose(a, e) == expected
        assert verify_e3_identity(a, e)

    def test_e_equals_one(self) -> None:
        a = 7
        q, r, n = e3_decompose(a, 1)
        assert (q, r, n) == (7, 0, 7)
        assert verify_e3_identity(a, 1)

    def test_a_below_e_squared(self) -> None:
        a = 8
        e = 3
        q, r, n = e3_decompose(a, e)
        assert q == 0
        assert r == a
        assert n == e * a
        assert verify_e3_identity(a, e)

    def test_nonpositive_e_raises(self) -> None:
        with pytest.raises(ValueError, match="e must be positive"):
            e3_decompose(10, 0)
        with pytest.raises(ValueError, match="e must be positive"):
            analyze_e3_decomposition(10, -2)


class TestAnalyzeE3Decomposition:
    def test_governance_tag(self) -> None:
        result = analyze_e3_decomposition(17, 3)
        assert result["governance"] == E3_DECOMPOSITION_TAG
        assert E3_DECOMPOSITION_TAG == "[B]"

    def test_canonical_example(self) -> None:
        result = analyze_e3_decomposition(17, 3)
        assert result["q"] == 1
        assert result["r"] == 8
        assert result["n"] == 51
        assert result["identity_holds"] is True
        assert result["r_below_e2"] is True
        assert "1*27 + 8*3" in result["identity"]

    def test_zero_quotient_when_a_below_e2(self) -> None:
        result = analyze_e3_decomposition(13, 5)
        assert result["q"] == 0
        assert result["q_is_zero"] is True
        assert result["identity_holds"] is True


class TestAbcProductSplit:
    @pytest.mark.parametrize(
        ("a", "e", "b", "c"),
        [
            (17, 3, 2, 4),
            (17, 3, 1, 8),
            (17, 3, 8, 1),
        ],
    )
    def test_valid_split_examples(self, a: int, e: int, b: int, c: int) -> None:
        q, r, n = e3_decompose(a, e)
        assert r == b * c
        result = verify_abc_split(a, e, b, c)
        assert result["valid"] is True
        assert result["q"] == q
        assert result["n"] == n
        assert result["rest_matches_product"] is True
        assert result["split_holds"] is True
        assert result["product_below_e2"] is True

    def test_abc_split_decomposition_identity(self) -> None:
        result = abc_split_decomposition(17, 3, 2, 4)
        assert result["rest_matches_product"] is True
        assert result["split_holds"] is True
        assert result["n"] == 51
        assert result["q"] == 1
        assert result["product"] == 8
        assert "1*27 + 2*4*3" in result["split_identity"]

    def test_product_bound_below_e_squared(self) -> None:
        a, e = 17, 3
        e2 = e * e
        for b, c in ((2, 4), (1, 8)):
            result = verify_abc_split(a, e, b, c)
            assert result["product"] < e2
            assert result["product_below_e2"] is True

    def test_invalid_when_rest_not_product(self) -> None:
        result = verify_abc_split(17, 3, 3, 3)
        assert result["valid"] is False
        assert result["rest_matches_product"] is False
        assert result["split_holds"] is False
        assert result["product_below_e2"] is None

    def test_analyze_with_product_split_valid(self) -> None:
        result = analyze_e3_with_product_split(17, 3, 2, 4)
        assert result["case_type"] == "valid_product_split"
        assert result["split_holds"] is True
        assert result["analogy_governance"] == E3_PRODUCT_ANALOGY_TAG
        assert result["analogy_governance"] == "[C]"

    def test_analyze_with_product_split_invalid(self) -> None:
        result = analyze_e3_with_product_split(17, 3, 5, 5)
        assert result["case_type"] == "invalid_rest_product"
        assert result["rest_matches_product"] is False
        assert result["split_holds"] is False

    def test_governance_tags(self) -> None:
        result = verify_abc_split(17, 3, 2, 4)
        assert result["governance"] == E3_DECOMPOSITION_TAG
        assert result["analogy_governance"] == "[C]"


class TestCommutativeMultiplet:
    def test_commutation_check_always_commutes_for_ints(self) -> None:
        result = commutation_check(2, 4)
        assert result["commutes"] is True
        assert result["commutator"] == 0

    def test_symmetric_operators_example(self) -> None:
        assert symmetric_operators(2, 4) == (3, 1)
        assert 2 * 4 == 3 * 3 - 1 * 1

    def test_symmetric_operators_parity_raises(self) -> None:
        with pytest.raises(ValueError, match="equal parity"):
            symmetric_operators(2, 3)

    def test_commutative_multiplet_valid(self) -> None:
        result = analyze_e3_commutative_multiplet(17, 3, 2, 4)
        assert result["case_type"] == "valid_commutative_multiplet"
        assert result["s_plus"] == 3
        assert result["s_minus"] == 1
        assert result["s_plus_sq"] == 9
        assert result["s_minus_sq"] == 1
        assert result["multiplet_holds"] is True
        assert result["n"] == 51
        assert result["zeeman_analogy_governance"] == "[C]"

    def test_commutative_multiplet_invalid_product(self) -> None:
        result = analyze_e3_commutative_multiplet(17, 3, 3, 3)
        assert result["case_type"] == "invalid_rest_product"
        assert result["multiplet_holds"] is False


class TestE3SpectralDiagnostic:
    def test_governance_tag(self) -> None:
        result = e3_spectral_diagnostic(17, 3, 2, 4)
        assert result["governance"] == E3_DECOMPOSITION_TAG
        assert result["governance"] == "[B]"

    def test_canonical_example_n51(self) -> None:
        result = e3_spectral_diagnostic(17, 3, 2, 4)
        assert result["n"] == 51
        assert result["q"] == 1
        assert result["coefficients_odd_e"] == {"e^3": 1, "e^1": 8}
        assert result["gram_eigenvalues"] == [0.0, 0.0, 66.0]
        assert result["anisotropy_gap"] == 66.0
        assert result["split_valid"] is True
        assert result["rest_matches_product"] is True

    def test_alternate_factorization_same_spectrum(self) -> None:
        result = e3_spectral_diagnostic(17, 3, 1, 8)
        assert result["coefficients_odd_e"] == {"e^3": 1, "e^1": 8}
        assert result["anisotropy_gap"] == 66.0
        assert result["split_valid"] is True

    def test_invalid_split_still_reports_spectrum(self) -> None:
        result = e3_spectral_diagnostic(17, 3, 3, 3)
        assert result["split_valid"] is False
        assert result["rest_matches_product"] is False
        assert result["coefficients_odd_e"] == {"e^3": 1, "e^1": 9}
        assert result["anisotropy_gap"] == 83.0

    def test_zero_quotient_rank_one_gap(self) -> None:
        result = e3_spectral_diagnostic(13, 5, 13, 1)
        assert result["q"] == 0
        assert result["n"] == 65
        assert result["coefficients_odd_e"] == {"e^3": 0, "e^1": 13}
        assert result["anisotropy_gap"] == 170.0
        assert result["split_valid"] is True

    def test_nonpositive_e_raises(self) -> None:
        with pytest.raises(ValueError, match="e must be positive"):
            e3_spectral_diagnostic(17, 0, 2, 4)


class TestE3EabcAnisotropyComparison:
    def test_governance_tag(self) -> None:
        result = compare_e3_eabc_anisotropy(13, 5, 13, 1)
        assert result["governance"] == E3_DECOMPOSITION_TAG

    def test_n65_eabc_channel_passes(self) -> None:
        """n=65=5*13, e=5 (A-channel, w_p=5) — documented zero-quotient example."""
        result = compare_e3_eabc_anisotropy(13, 5, 13, 1)
        assert result["n"] == 65
        assert result["eabc"]["defect_weight_w_p"] == 5
        assert result["eabc"]["expected_anisotropy"] == 5.0
        assert result["e3"]["lambda_min"] == EABC_GEOM_DIAGONAL
        assert result["e3"]["lambda_max"] == EABC_GEOM_DIAGONAL + 5.0
        assert result["e3"]["anisotropy"] == 5.0
        assert result["eabc"]["after_retraction"]["anisotropy"] == 0.0
        assert result["comparison"]["status"] == "pass"
        assert result["comparison"]["abs_error"] == 0.0

    def test_n60_alternate_split_passes(self) -> None:
        """n=60=5*12 with r=12=3*4 — both pipelines at fixed n."""
        result = compare_e3_eabc_anisotropy(12, 5, 3, 4)
        assert result["n"] == 60
        assert result["eabc"]["expected_anisotropy"] == 5.0
        assert result["comparison"]["status"] == "pass"

    def test_n51_no_eabc_channel_skips(self) -> None:
        """n=51=3*17: e=3 has no EABC weight — bridge not applicable."""
        result = compare_e3_eabc_anisotropy(17, 3, 2, 4)
        assert result["n"] == 51
        assert result["eabc"]["applicable"] is False
        assert result["comparison"]["status"] == "skip"

    def test_raw_gram_differs_from_bridged_anisotropy(self) -> None:
        result = compare_e3_eabc_anisotropy(13, 5, 13, 1)
        assert result["e3"]["anisotropy_gap"] == 170.0
        assert result["e3"]["anisotropy"] == 5.0

    def test_tensor_matrix_check_matches_closed_form(self) -> None:
        result = compare_e3_eabc_anisotropy(13, 5, 13, 1)
        check = result["e3"]["tensor_matrix_check"]
        assert check["anisotropy"] == pytest.approx(5.0)
        assert check["defect_rank"] == 1
        retract = result["eabc"]["after_retraction"]["tensor_matrix_check"]
        assert retract["anisotropy"] == pytest.approx(0.0)
        assert retract["defect_rank"] == 0

    def test_eabc_channel_weight_mapping(self) -> None:
        assert eabc_channel_weight_from_factor(5) == 5
        assert eabc_channel_weight_from_factor(7) == 7
        assert eabc_channel_weight_from_factor(3) is None

    def test_retraction_returns_isotropic_core(self) -> None:
        direction = (0.0, 0.0, 1.0)
        retracted = eabc_retract_defect(5.0, direction)
        summary = eabc_tensor_spectral_summary(retracted, defect_rank=0)
        assert summary["anisotropy"] == 0.0
        assert summary["lambda_min"] == EABC_GEOM_DIAGONAL
