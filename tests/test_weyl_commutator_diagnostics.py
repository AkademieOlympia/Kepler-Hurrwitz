import math

import pytest

from kepler_hurwitz.primvierling import build_prime_quadruplet
from kepler_hurwitz.weyl_commutator_diagnostics import (
    WEYL_COMMUTATOR_TAG,
    ceab_nullmodel,
    channel_shuffle_nullmodel,
    delta_lr_norm,
    delta_lr_norm_from_primvierling,
    build_weyl_commutator_record,
)


class TestWeylCommutatorDiagnostics:
    def test_tag_is_b(self):
        assert WEYL_COMMUTATOR_TAG == "[B]"

    def test_commutative_element_has_zero_defect(self):
        assert delta_lr_norm((2, 0, 0, 0)) == pytest.approx(0.0)

    def test_noncommutative_element_positive_defect(self):
        assert delta_lr_norm((0, 1, 0, 0)) > 0

    def test_primvierling_reference(self):
        v = build_prime_quadruplet(11)
        value = delta_lr_norm_from_primvierling(v)
        assert value > 0
        assert math.isfinite(value)

    def test_ceab_nullmodel_changes_components(self):
        v = build_prime_quadruplet(11)
        assert ceab_nullmodel(v) != v

    def test_channel_shuffle_breaks_gap(self):
        v = build_prime_quadruplet(11)
        shuffled = channel_shuffle_nullmodel(v)
        assert shuffled != v

    def test_record_includes_nullmodels(self):
        v = build_prime_quadruplet(11)
        record = build_weyl_commutator_record(v)
        assert record.delta_lr > 0
        assert record.ceab_delta_lr > 0
        assert record.shuffle_delta_lr > 0

    def test_rejects_wrong_length(self):
        with pytest.raises(ValueError):
            delta_lr_norm((1, 2, 3))
