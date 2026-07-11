"""Tests for channel-7 witness classification scan."""

from __future__ import annotations

from kepler_hurwitz.channel_seven_witness_scan import (
    channel_seven_residues,
    scan_channel_seven,
    summarize_channel_seven,
)


def test_channel_seven_mod128_has_sixteen_classes() -> None:
    assert len(channel_seven_residues(128)) == 16


def test_channel_seven_formal_residue_mod32() -> None:
    records = scan_channel_seven(modulus=128)
    formal = [r for r in records if r.formally_closed]
    assert {r.residue for r in formal} == {23, 55, 87, 119}
    assert all(r.t_loc == 4 for r in formal)


def test_channel_three_frozen_in_summary() -> None:
    summary = summarize_channel_seven(scan_channel_seven())
    assert summary["channel_three_frozen_coverage"] == "28/32"
    assert summary["channel_three_deep_tail_mod128"] == [27, 91, 123]
    assert summary["channel_three_deep_tail_mod256"] == [27, 91, 155, 251]
    assert summary["formal_coverage_fraction"] == 0.25
    assert summary["formal_or_non_deep_fraction"] == 0.625
    assert summary["numerical_witness_found_fraction"] == 1.0
    assert summary["deep_tail_fraction"] == 0.375
    assert summary["formally_closed_classes"] == 4
