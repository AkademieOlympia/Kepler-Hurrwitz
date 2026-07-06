"""Tests for canonical e³ decomposition diagnostic."""

from __future__ import annotations

import pytest

from kepler_hurwitz.e3_decomposition import (
    E3_DECOMPOSITION_TAG,
    analyze_e3_decomposition,
    e3_decompose,
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
