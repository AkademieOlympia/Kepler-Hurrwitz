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
    collatz_oct_embed,
    export_collatz_freeze_diagnostic_json,
    fano_line_associator_profile,
    format_freeze_summary,
    freeze_indicators,
    is_channel_seven,
    run_collatz_freeze_diagnostic,
    scan_odd_stations,
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
