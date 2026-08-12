"""Regression tests for Primvierling C4 rotation / Δθ (Ebene E)."""

from __future__ import annotations

from kepler_hurwitz.primvierling import generate_prime_quadruplets
from kepler_hurwitz.primvierling_c4_rotation import (
    SUCCESSIVE_GAPS,
    TYPE_WORD_P_EQ_5,
    TYPE_WORD_P_EQ_11,
    WORD_P_EQ_5,
    WORD_P_EQ_11,
    channel_kind,
    delta_theta,
    phi_theta,
    residue_word,
    successive_delta_theta,
    type_word,
    verify_quadruplet_c4,
)


class TestDeltaThetaUnit:
    def test_unit_step_on_s(self):
        assert delta_theta(11, 1) == 1
        assert delta_theta(1, 5) == 1
        assert delta_theta(5, 7) == 1
        assert delta_theta(7, 11) == 1

    def test_full_turn(self):
        assert (delta_theta(11, 1) + delta_theta(1, 5) + delta_theta(5, 7) + delta_theta(7, 11)) % 4 == 0


class TestPhiThetaTypes:
    def test_phi_theta_values(self):
        assert phi_theta(0) == "inert"
        assert phi_theta(3) == "inert"
        assert phi_theta(1) == "zerfallend"
        assert phi_theta(2) == "zerfallend"

    def test_type_words_algebraically_complementary(self):
        # Position-wise: each type of one channel is replaced by the other type.
        for a, b in zip(TYPE_WORD_P_EQ_11, TYPE_WORD_P_EQ_5, strict=True):
            assert {a, b} == {"inert", "zerfallend"}


class TestWitnessWords:
    def test_q5_exception_word(self):
        v = (5, 7, 11, 13)
        assert channel_kind(v) == "exception_q5"
        assert residue_word(v) == WORD_P_EQ_5
        assert successive_delta_theta(v) == (1, 1, 1)
        assert type_word(v) == TYPE_WORD_P_EQ_5
        report = verify_quadruplet_c4(v)
        assert report["ok"] is True

    def test_p_eq_5_witness(self):
        # (101, 103, 107, 109): 101 ≡ 5 (mod 12)
        v = (101, 103, 107, 109)
        assert channel_kind(v) == "p_eq_5"
        assert residue_word(v) == WORD_P_EQ_5
        assert successive_delta_theta(v) == (1, 1, 1)
        assert type_word(v) == TYPE_WORD_P_EQ_5

    def test_p_eq_11_witness(self):
        # (191, 193, 197, 199): 191 ≡ 11 (mod 12)
        v = (191, 193, 197, 199)
        assert channel_kind(v) == "p_eq_11"
        assert residue_word(v) == WORD_P_EQ_11
        assert successive_delta_theta(v) == (1, 1, 1)
        assert type_word(v) == TYPE_WORD_P_EQ_11


class TestRegressionScan:
    def test_congruence_regression_to_1e6(self):
        """
        Enumeration is an implementation regression test (Ebene E), not a proof
        of the congruence theorem (Ebene B).
        """
        # p + 8 <= 10^6  ⇒  p <= 999992
        quads = generate_prime_quadruplets(5, 999_992)
        assert len(quads) == 166

        n_q5 = 0
        n_5 = 0
        n_11 = 0
        errors = 0
        for v in quads:
            report = verify_quadruplet_c4(v)
            if not report["ok"]:
                errors += 1
                continue
            kind = report["kind"]
            if kind == "exception_q5":
                n_q5 += 1
            elif kind == "p_eq_5":
                n_5 += 1
            elif kind == "p_eq_11":
                n_11 += 1

        assert errors == 0
        assert n_q5 == 1
        assert n_5 == 83
        assert n_11 == 82
        assert n_q5 + n_5 + n_11 == 166
        assert all(
            tuple(v[i + 1] - v[i] for i in range(3)) == SUCCESSIVE_GAPS for v in quads
        )
