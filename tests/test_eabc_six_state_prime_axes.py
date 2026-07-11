"""Tests for EABC six-state / mod-6 prime-axis diagnostics."""

from __future__ import annotations

import pytest

from kepler_hurwitz.eabc_six_state_prime_axes import (
    GOVERNANCE,
    MOD6_TO_STATE,
    PRIME_AXIS_STATES,
    SIX_STATE_TAG,
    analyze_prime_transitions,
    classify_gap_mod6,
    get_eabc_state,
    is_prime_axis_state,
    is_prime_carrying,
    prime_gap_transition,
)


class TestMod6Mapping:
    @pytest.mark.parametrize(
        ("n", "expected"),
        [
            (6, "c"),
            (7, "a"),
            (8, "ac"),
            (9, "ab"),
            (10, "b"),
            (11, "bc"),
            (13, "a"),
        ],
    )
    def test_known_residues(self, n: int, expected: str) -> None:
        assert get_eabc_state(n) == expected
        assert get_eabc_state(n) == MOD6_TO_STATE[n % 6]

    def test_rejects_non_positive(self) -> None:
        with pytest.raises(ValueError):
            get_eabc_state(0)


class TestPrimeAxis:
    @pytest.mark.parametrize("p", [5, 7, 11, 13, 17, 19])
    def test_primes_gt3_on_a_or_bc_only(self, p: int) -> None:
        state = get_eabc_state(p)
        assert state in PRIME_AXIS_STATES
        assert is_prime_axis_state(state)
        assert is_prime_carrying(p)

    @pytest.mark.parametrize("n", [4, 6, 8, 9, 10, 12, 14, 15])
    def test_blocked_residues_not_prime_carrying(self, n: int) -> None:
        assert not is_prime_carrying(n)


class TestGapTransitions:
    def test_twin_5_7_bc_to_a(self) -> None:
        t = prime_gap_transition(5, 7)
        assert t["gap"] == 2
        assert t["state1"] == "bc"
        assert t["state2"] == "a"
        assert t["gap_class"] == "conjugate_flip"
        assert t["axis_flip"] is True

    def test_cousin_7_11_a_to_bc(self) -> None:
        t = prime_gap_transition(7, 11)
        assert t["gap"] == 4
        assert t["state1"] == "a"
        assert t["state2"] == "bc"
        assert t["gap_class"] == "conjugate_flip"
        assert t["axis_flip"] is True

    def test_sexy_5_11_same_state_class(self) -> None:
        t = prime_gap_transition(5, 11)
        assert t["gap"] == 6
        assert t["state1"] == "bc"
        assert t["state2"] == "bc"
        assert t["gap_class"] == "same_axis"
        assert t["axis_flip"] is False

    def test_sexy_7_13_same_axis(self) -> None:
        t = prime_gap_transition(7, 13)
        assert t["gap"] == 6
        assert t["state1"] == "a"
        assert t["state2"] == "a"
        assert classify_gap_mod6(6) == "same_axis"


class TestAnalyze:
    def test_analyze_includes_twin(self) -> None:
        rows = analyze_prime_transitions(20)
        twin = next(r for r in rows if r["p1"] == 5 and r["p2"] == 7)
        assert twin["axis_flip"] is True


class TestGovernance:
    def test_tag_and_not_claimed(self) -> None:
        assert SIX_STATE_TAG == "[C]"
        assert "twin-prime" in GOVERNANCE["not_claimed"]
        assert "mod-12" in GOVERNANCE["mod12_relationship"]
