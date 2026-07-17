"""Reproducibility tests for the Hc numerical stability freeze."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np
import pytest

from kepler_hurwitz.hc_spectral_freeze import (
    REPORT_PATH,
    SPEC_PATH,
    THRESHOLD_GAP,
    get_stability_bracket,
    load_operators,
    load_spec,
    require_exact_controls,
    run_freeze,
    bamberg_mode,
)

ROOT = Path(__file__).resolve().parents[1]


def test_hard_controls_pass():
    require_exact_controls()


def test_channel_bracket_near_three_quarters():
    """N_II_channel mimics V ⇒ fail near ε=1; contiguous pass ends near 0.75."""
    spec = load_spec()
    ops = load_operators(spec)
    u = bamberg_mode(spec)
    bracket = get_stability_bracket(
        ops["L_C4"], ops["V"], ops["N_II_channel"], u
    )
    # |2 - (3-ε)| >= 1/4  ⇒  |ε-1| >= 1/4  ⇒  ε <= 3/4  (from zero)
    assert 0.74 <= bracket.estimate <= 0.76
    assert bracket.lower_pass <= bracket.estimate
    assert bracket.upper_fail is not None
    assert bracket.lower_pass < bracket.upper_fail
    assert bracket.upper_fail - bracket.lower_pass < 1e-3


def test_edge_and_diag_certified_to_search_high():
    spec = load_spec()
    ops = load_operators(spec)
    u = bamberg_mode(spec)
    for key in ("N_II_edge", "N_II_diag"):
        bracket = get_stability_bracket(ops["L_C4"], ops["V"], ops[key], u)
        assert bracket.certified_to_search_high
        assert bracket.estimate == pytest.approx(2.0)
        assert bracket.upper_fail is None


def test_run_freeze_limiting_is_channel():
    report = run_freeze()
    assert report["freeze_status"] == "passed"
    assert report["limiting_noise_class"] == "N_II_channel"
    assert report["epsilon_star_sym"] == pytest.approx(
        report["epsilon_star"]["N_II_channel"]["positive"]["estimate"]
    )
    assert 0.74 <= report["epsilon_star_sym"] <= 0.76
    assert report["threshold_gap"] == str(THRESHOLD_GAP)


def test_archived_report_matches_live_freeze_if_present():
    """Wenn der Report archiviert ist: Status und Limiting-Klasse konsistent."""
    if not REPORT_PATH.is_file():
        pytest.skip("report not archived yet")
    archived = json.loads(REPORT_PATH.read_text(encoding="utf-8"))
    live = run_freeze()
    assert archived["freeze_status"] == live["freeze_status"]
    assert archived["limiting_noise_class"] == live["limiting_noise_class"]
    assert archived["epsilon_star_sym"] == pytest.approx(live["epsilon_star_sym"], rel=0, abs=1e-5)


def test_spec_points_to_specs_report():
    spec = json.loads(SPEC_PATH.read_text(encoding="utf-8"))
    assert spec["numerical_freeze"]["report"].endswith("hc_numerical_freeze_report.json")
    assert "specs/" in spec["numerical_freeze"]["report"] or Path(
        spec["numerical_freeze"]["report"]
    ).name == "hc_numerical_freeze_report.json"
