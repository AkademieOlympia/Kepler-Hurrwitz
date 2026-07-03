import pytest

from kepler_hurwitz.kepler import kepler_invariants, radius_ratio_from_eccentricity
from kepler_hurwitz.signatures import HurwitzSignature8D


def test_kepler_ratio_circle():
    assert radius_ratio_from_eccentricity(0.0) == 1.0


def test_kepler_ratio_half():
    assert radius_ratio_from_eccentricity(0.5) == 3.0


def test_signature_total():
    h = HurwitzSignature8D(1, 0, 1, 0, 1, 0, 1, 0)
    assert h.total_weight() == 4
    assert h.orientation_balance() == 4


def test_kepler_ratio_rejects_parabolic_boundary():
    with pytest.raises(ValueError):
        radius_ratio_from_eccentricity(1.0)


def test_kepler_invariants_match_velocity_ratio():
    inv = kepler_invariants(2 / 3)
    assert inv.radius_ratio == inv.velocity_ratio
