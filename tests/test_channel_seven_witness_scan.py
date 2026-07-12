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
    assert {r.residue for r in formal} == {7, 15, 23, 55, 87, 119}
    t_locs = {r.residue: r.t_loc for r in formal}
    assert t_locs[23] == t_locs[55] == t_locs[87] == t_locs[119] == 4
    assert t_locs[7] == 7
    assert t_locs[15] == 5


def test_channel_seven_partial_formal_mod256() -> None:
    records = scan_channel_seven(modulus=128)
    r79 = next(r for r in records if r.residue == 79)
    assert r79.t_loc == 7
    assert r79.t_good == 6
    assert not r79.formally_closed
    assert "mod256_seventy_nine" in r79.notes
    r95 = next(r for r in records if r.residue == 95)
    assert r95.t_loc == 5
    assert r95.t_good == 8
    assert not r95.formally_closed
    assert "mod256_ninety_five" in r95.notes
    r39 = next(r for r in records if r.residue == 39)
    assert r39.t_loc == 9
    assert r39.t_good == 4
    assert not r39.formally_closed
    assert "mod256_thirty_nine" in r39.notes
    summary = summarize_channel_seven(records)
    assert summary["formal_mod256_residues"] == [39, 79, 95]
    assert summary["partial_formal_mod128_residues"] == [39, 79, 95]


def test_channel_three_frozen_in_summary() -> None:
    summary = summarize_channel_seven(scan_channel_seven())
    assert summary["channel_three_frozen_coverage"] == "28/32"
    assert summary["channel_three_deep_tail_mod128"] == [27, 91, 123]
    assert summary["channel_three_deep_tail_mod256"] == [27, 91, 155, 251]
    assert summary["formal_coverage_fraction"] == 0.375
    assert summary["formal_or_non_deep_fraction"] == 0.625
    assert summary["numerical_witness_found_fraction"] == 1.0
    assert summary["deep_tail_fraction"] == 0.375
    assert summary["formally_closed_classes"] == 6
