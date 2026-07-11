"""Tests for Weyl–Onsager combined attack diagnostics (E-087 / E-088)."""

import math

import pytest

from kepler_hurwitz.primvierling import build_prime_quadruplet
from kepler_hurwitz.weyl_onsager_diagnostics import (
    WEYL_ONSAGER_TAG,
    berry_holonomy_product,
    build_attack_record,
    build_default_attack_records,
    eabc_coupling_toy_from_signature,
    onsager_reciprocity_residual,
    weyl_chirality_proxy,
)


class TestWeylChiralityProxy:
    def test_tag_is_c(self):
        assert WEYL_ONSAGER_TAG == "[C]"

    def test_zero_for_balanced_channels(self):
        assert weyl_chirality_proxy(0.0, 0.0, 0.0) == pytest.approx(0.0)

    def test_matches_euclidean_norm(self):
        assert weyl_chirality_proxy(3.0, 4.0, 0.0) == pytest.approx(5.0)

    def test_rejects_non_finite(self):
        with pytest.raises(ValueError):
            weyl_chirality_proxy(float("nan"), 0.0, 0.0)


class TestOnsagerReciprocityResidual:
    def test_symmetric_matrix_zero_residual(self):
        matrix = (
            (1.0, 0.2, 0.1, 0.0),
            (0.2, 1.0, 0.3, 0.1),
            (0.1, 0.3, 1.0, 0.2),
            (0.0, 0.1, 0.2, 1.0),
        )
        assert onsager_reciprocity_residual(matrix) == pytest.approx(0.0)

    def test_asymmetric_matrix_positive_residual(self):
        matrix = (
            (1.0, 0.5, 0.0, 0.0),
            (0.1, 1.0, 0.0, 0.0),
            (0.0, 0.0, 1.0, 0.0),
            (0.0, 0.0, 0.0, 1.0),
        )
        assert onsager_reciprocity_residual(matrix) > 0.0

    def test_rejects_non_square(self):
        with pytest.raises(ValueError):
            onsager_reciprocity_residual(((1.0, 2.0),))


class TestBerryHolonomyProduct:
    def test_closed_zero_phase_loop(self):
        assert berry_holonomy_product((0.0, 0.0, 0.0, 0.0)) == pytest.approx(0.0)

    def test_half_turn_phase(self):
        assert berry_holonomy_product((math.pi,)) == pytest.approx(math.pi)

    def test_rejects_empty(self):
        with pytest.raises(ValueError):
            berry_holonomy_product(())


class TestCombinedAttackRecord:
    def test_build_attack_record_finite(self):
        v = build_prime_quadruplet(11)
        record = build_attack_record(v)
        assert record.weyl_chirality >= 0.0
        assert record.reciprocity_residual >= 0.0
        assert math.isfinite(record.berry_phase)

    def test_asymmetry_increases_reciprocity_residual(self):
        v = build_prime_quadruplet(11)
        symmetric = build_attack_record(v, asymmetry=0.0)
        asymmetric = build_attack_record(v, asymmetry=1.0)
        assert asymmetric.reciprocity_residual > symmetric.reciprocity_residual

    def test_default_records_cover_primes(self):
        records = build_default_attack_records()
        assert len(records) == 4
        assert all(r.weyl_chirality >= 0.0 for r in records)

    def test_coupling_toy_is_4x4(self):
        matrix = eabc_coupling_toy_from_signature(1.0, 2.0, 3.0)
        assert len(matrix) == 4
        assert all(len(row) == 4 for row in matrix)
