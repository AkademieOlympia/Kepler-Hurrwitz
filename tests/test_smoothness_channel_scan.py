import pytest

from kepler_hurwitz.smoothness_channel_scan import (
    channel_label,
    e_schalen_sprung,
    is_b_smooth,
    next_odd_core_after_kick,
    scan_smoothness_channels,
    summarize_scan,
)


def test_e_schalen_sprung_mod8_channels():
    assert e_schalen_sprung(3) == 1
    assert e_schalen_sprung(7) == 1
    assert e_schalen_sprung(1) == 2
    assert e_schalen_sprung(5) >= 3


def test_e_schalen_sprung_rejects_even_and_non_positive():
    with pytest.raises(ValueError):
        e_schalen_sprung(0)
    with pytest.raises(ValueError):
        e_schalen_sprung(4)


def test_next_odd_core_after_kick_basic_values():
    assert next_odd_core_after_kick(1) == 1
    assert next_odd_core_after_kick(3) == 5
    assert next_odd_core_after_kick(5) == 1


def test_is_b_smooth():
    assert is_b_smooth(45, 5) is True
    assert is_b_smooth(77, 5) is False


def test_channel_label():
    assert channel_label(1) == "klein"
    assert channel_label(2) == "mittel"
    assert channel_label(3) == "tief"


def test_scan_and_summary():
    samples = scan_smoothness_channels(limit_m=15, b=5)
    assert len(samples) == 8
    summary = summarize_scan(samples)
    assert summary["klein"]["total"] > 0
    assert summary["mittel"]["total"] > 0
    assert summary["tief"]["total"] > 0
