"""Tests for octonionic Collatz freeze diagnostic [B]/[C]."""

from __future__ import annotations

import json
from pathlib import Path

from kepler_hurwitz.discrete_time_flow import associator, octonion_norm_sq
from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import (
    GOVERNANCE,
    OCTONIONIC_COLLATZ_FREEZE_TAG,
    WITNESS_TRIPLE,
    associator_norm_sq_on_triple,
    check_disk_axis_parity_invariant,
    check_triad_base_parity_channel_seven_invariant,
    collatz_oct_embed,
    coord_sum_parity,
    disk_axis_parity,
    e0_add_e2_parity,
    export_collatz_freeze_diagnostic_json,
    fano_line_associator_profile,
    format_freeze_summary,
    freeze_indicators,
    is_channel_seven,
    odd_core_step,
    run_collatz_freeze_diagnostic,
    scan_odd_core_invariants,
    scan_odd_stations,
    triad_base_parity,
)


def test_governance_tag():
    assert OCTONIONIC_COLLATZ_FREEZE_TAG == "[B]/[C]"
    assert GOVERNANCE["status"] == "[B]/[C]"
    assert GOVERNANCE["evidence_id"] == "E-098"
    assert "No Collatz proof" in GOVERNANCE["not_claimed"]


def test_channel_seven_detection():
    assert is_channel_seven(7)
    assert is_channel_seven(15)
    assert not is_channel_seven(3)
    assert not is_channel_seven(8)


def test_collatz_oct_embed_matches_lean_formula():
    n = 23  # 23 ≡ 7 (mod 8), channel 7
    coords = collatz_oct_embed(n)
    assert coords[0] == float(n)
    assert coords[1] == float((n % 8) // 2)
    assert coords[2] == float(n % 12)
    assert coords[7] == 1.0
    assert coords[3] == coords[4] == coords[5] == coords[6] == 0.0

    n2 = 9  # not channel 7
    coords2 = collatz_oct_embed(n2)
    assert coords2[7] == 0.0


def test_fano_witness_associator_norm_sq_is_four():
    assert associator_norm_sq_on_triple(*WITNESS_TRIPLE) == 4.0


def test_fano_lines_have_vanishing_associator():
    profile = fano_line_associator_profile()
    lines = [row for row in profile if row["is_fano_line"]]
    assert len(lines) == 7
    for row in lines:
        assert row["associator_norm_sq"] == 0.0
    witness_rows = [row for row in profile if not row["is_fano_line"]]
    assert len(witness_rows) == 1
    assert witness_rows[0]["associator_norm_sq"] == 4.0


def test_freeze_indicators_shape():
    rec = freeze_indicators(7)
    assert rec.odd
    assert rec.channel_seven
    assert rec.witness_associator_norm_sq == 4.0
    assert rec.map_status == OCTONIONIC_COLLATZ_FREEZE_TAG
    assert len(rec.coords) == 8


def test_scan_and_diagnostic_payload():
    samples = scan_odd_stations([1, 3, 5, 7, 9, 15, 21, 23])
    assert len(samples) == 8
    payload = run_collatz_freeze_diagnostic(sample_odds=[1, 3, 7, 15])
    assert payload["sample_count"] == 4
    assert payload["channel_seven_count"] == 2
    assert "does_not_close_bad_run_net_descent_witness_of_mod4_three" in payload["not_claimed"]
    summary = format_freeze_summary(payload)
    assert "octonionic_collatz_freeze" in summary
    assert "witness‖·‖²=4.0" in summary or "witness" in summary


def test_export_json(tmp_path: Path):
    out = export_collatz_freeze_diagnostic_json(
        tmp_path / "freeze.json",
        sample_odds=[1, 7, 15],
    )
    data = json.loads(out.read_text(encoding="utf-8"))
    assert data["governance"]["attempt"] == "octonionic-collatz-freeze-proof-attempt-v1"
    assert data["fano_associator_witness"]["associator_norm_sq"] == 4.0


def test_associator_matches_discrete_time_flow():
    from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import imaginary_unit

    defect = associator(imaginary_unit(2), imaginary_unit(3), imaginary_unit(4))
    assert octonion_norm_sq(defect) == 4.0


def test_odd_core_step_matches_syracuse():
    assert odd_core_step(3) == 5
    assert odd_core_step(7) == 11
    assert odd_core_step(5) == 1


def test_disk_axis_parity_invariant_under_odd_core():
    """Lean: diskAxisParity_collatzOctEmbed_oddCoreStep."""
    for n in range(1, 401, 2):
        assert disk_axis_parity(n) == 1
        assert disk_axis_parity(n) == disk_axis_parity(odd_core_step(n))
    report = check_disk_axis_parity_invariant(limit=200)
    assert report["holds"] is True
    assert report["failure_count"] == 0


def test_e0_add_e2_parity_invariant_under_odd_core():
    for n in range(1, 401, 2):
        assert e0_add_e2_parity(n) == 0
        assert e0_add_e2_parity(n) == e0_add_e2_parity(odd_core_step(n))


def test_triad_base_parity_channel_seven_invariant():
    """Lean: triadBaseParity_collatzOctEmbed_channelSeven_oddCoreStep."""
    for n in range(7, 401, 8):
        assert triad_base_parity(n) == 0
        assert triad_base_parity(n) == triad_base_parity(odd_core_step(n))
    report = check_triad_base_parity_channel_seven_invariant(limit=200)
    assert report["holds"] is True


def test_full_coord_sum_parity_is_not_invariant():
    """Kandidat 1 (volle Summe) scheitert — dokumentierte Gegenbeispiele."""
    assert coord_sum_parity(3) != coord_sum_parity(odd_core_step(3))
    assert coord_sum_parity(7) != coord_sum_parity(odd_core_step(7))


def test_scan_odd_core_invariants_payload():
    payload = scan_odd_core_invariants([1, 3, 5, 7, 9, 15, 21, 23])
    assert payload["proved_or_confirmed"]["disk_axis_parity"]["holds"] is True
    assert payload["proved_or_confirmed"]["triad_base_parity_channel_seven"]["holds"] is True
    assert payload["failed_candidates"]["full_coord_sum_parity"]["holds"] is False
    assert payload["governance"]["no_upgrade_to_BadRunNetDescent"] is True


def test_diagnostic_includes_odd_core_invariants():
    payload = run_collatz_freeze_diagnostic(sample_odds=[1, 3, 7, 15, 23])
    assert "odd_core_invariants" in payload
    assert payload["odd_core_invariants"]["proved_or_confirmed"]["disk_axis_parity"]["holds"]
    assert "disk_axis_parity_invariant_is_not_net_descent" in payload["not_claimed"]
