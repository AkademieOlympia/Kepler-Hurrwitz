from kepler_hurwitz.interference_attraktor_bridge import (
    allowed_b11_residues,
    b11_channel,
    evaluate_interference_b11_bridge,
)
from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels


def test_b11_channel_definition():
    assert b11_channel(1) is True
    assert b11_channel(11) is True
    assert b11_channel(0) is False
    assert b11_channel(12) is False
    assert b11_channel(10) is False


def test_allowed_b11_residues():
    assert allowed_b11_residues() == (1, 3, 5, 7, 9, 11)


def test_bridge_blocks_when_interference_not_admissible():
    samples = scan_smoothness_channels(limit_m=31, b=11)
    stats = evaluate_interference_b11_bridge(samples, mu=-2.0, s=4.0)
    assert stats.is_interference_admissible is False
    assert stats.evaluated_count == 0
    assert stats.b11_hits == 0
    assert stats.b11_hit_rate == 0.0


def test_bridge_evaluates_when_interference_is_admissible():
    samples = scan_smoothness_channels(limit_m=31, b=11)
    stats = evaluate_interference_b11_bridge(samples, mu=-2.5, s=15.0 / 4.0)
    assert stats.is_interference_admissible is True
    assert stats.evaluated_count == len(samples)
    assert 0.0 <= stats.b11_hit_rate <= 1.0
