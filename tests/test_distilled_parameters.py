import pytest

from kepler_hurwitz.distilled_parameters import (
    channel_eccentricity,
    channel_variance,
    distill_primvierling,
    norm_product_drift,
    norm_signature_anisotropy,
    primvierling_product,
    projection_loss_from_nat,
)
from kepler_hurwitz.signatures import eabc_mass, signature_from_nat


class TestDistilledParameters:
    def test_primvierling_product_signature_is_balanced(self):
        v = (5, 7, 11, 13)
        product_signature = signature_from_nat(primvierling_product(v))
        assert product_signature.as_tuple() == (1, 1, 1, 1)
        assert eabc_mass(primvierling_product(v)) == 4
        assert channel_eccentricity(product_signature) == 0.0
        assert channel_variance(product_signature) == 0.0

    def test_projection_loss_from_axis_primes(self):
        assert projection_loss_from_nat(6) == 2
        assert projection_loss_from_nat(12) == 3
        assert projection_loss_from_nat(30) == 2

    def test_norm_product_drift_and_anisotropy_on_classic_primvierling(self):
        v = (5, 7, 11, 13)
        assert norm_product_drift(v) == -2
        assert norm_signature_anisotropy(v) == 1

    def test_distill_primvierling_records_structural_mass_four(self):
        record = distill_primvierling((5, 7, 11, 13))
        assert record.product_mass_is_four is True
        assert record.norm_mass == 2
        assert record.norm_signature == (1, 0, 1, 0)
        assert record.channel_eccentricity_product == 0.0
        assert record.channel_variance_product == 0.0

    def test_channel_eccentricity_requires_positive_mass(self):
        with pytest.raises(ValueError):
            channel_eccentricity(6)
