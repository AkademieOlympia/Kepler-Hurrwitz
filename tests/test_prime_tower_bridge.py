"""Tests for the Gaussian / Eisenstein / Hurwitz prime-tower dictionary."""

from __future__ import annotations

import pytest

from kepler_hurwitz.kepler_eabc_atlas import EABCChannel
from kepler_hurwitz.prime_tower_bridge import (
    Q0_UNIFORM,
    EisensteinBehavior,
    GaussianBehavior,
    classify_prime,
    functional_information_bits,
    is_double_split_channel_E,
    is_sum_of_two_squares_prime,
    note_axis_pure_not_hurwitz_prime,
)
from kepler_hurwitz.signatures import V4


class TestGaussianTwoSquares:
    def test_ea_split(self):
        for p in (5, 13, 17, 29, 37):
            prof = classify_prime(p)
            assert prof.gaussian is GaussianBehavior.SPLIT
            assert prof.two_squares
            assert is_sum_of_two_squares_prime(p)

    def test_bc_inert(self):
        for p in (7, 11, 19, 23):
            prof = classify_prime(p)
            assert prof.gaussian is GaussianBehavior.INERT
            assert not prof.two_squares

    def test_channel_table(self):
        assert classify_prime(13).channel is EABCChannel.E
        assert classify_prime(5).channel is EABCChannel.A
        assert classify_prime(7).channel is EABCChannel.B
        assert classify_prime(11).channel is EABCChannel.C
        assert classify_prime(5).v4 is V4.A


class TestEisenstein:
    def test_a_axis_split(self):
        # p ≡ 1 mod 6 ⇒ ≡ 1 mod 3
        prof = classify_prime(13)
        assert prof.mod6_axis == "a"
        assert prof.eisenstein is EisensteinBehavior.SPLIT

    def test_bc_axis_inert(self):
        prof = classify_prime(5)
        assert prof.mod6_axis == "bc"
        assert prof.eisenstein is EisensteinBehavior.INERT


class TestHurwitzDictionary:
    def test_axis_pure_not_hurwitz(self):
        assert note_axis_pure_not_hurwitz_prime(5)
        # Norm of axisPure is 25 ≠ prime


class TestDoubleSplit:
    def test_only_E(self):
        assert is_double_split_channel_E(13)
        assert is_double_split_channel_E(37)
        assert not is_double_split_channel_E(5)  # A: Gaussian only
        assert not is_double_split_channel_E(7)  # B: Eisenstein only
        assert not is_double_split_channel_E(11)  # C: neither


class TestFunctionalInformationBits:
    """E-112: I_{Q0} = -log2(F) under documented prior — no physical simulation."""

    def test_q0_uniform_constant(self):
        assert Q0_UNIFORM == (0.25, 0.25, 0.25, 0.25)

    def test_ea_half_is_one_bit(self):
        assert functional_information_bits(0.5) == 1.0
        assert functional_information_bits(0.5, q0="uniform") == 1.0

    def test_pure_class_quarter_is_two_bits(self):
        assert functional_information_bits(0.25) == 2.0

    def test_rejects_unsupported_prior(self):
        with pytest.raises(ValueError, match="unsupported q0"):
            functional_information_bits(0.5, q0="chebotarev")

    def test_rejects_non_positive(self):
        with pytest.raises(ValueError):
            functional_information_bits(0.0)
        with pytest.raises(ValueError):
            functional_information_bits(-0.1)

    def test_rejects_above_one(self):
        with pytest.raises(ValueError):
            functional_information_bits(1.1)
