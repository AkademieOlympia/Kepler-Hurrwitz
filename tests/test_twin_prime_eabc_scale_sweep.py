import json

import pytest

from kepler_hurwitz.twin_prime_eabc_scale_sweep import (
    DEFAULT_LIMITS,
    DEFAULT_SIEVE_BOUNDS,
    GOVERNANCE,
    OPTIONAL_LIMIT_10M,
    build_scale_sweep_grid,
    export_scale_sweep_json,
    run_scale_sweep,
)

MOCK_SIGNED_DUAL_REFERENCE = {0: True, 1: True, 2: True, 3: True}


def test_scale_grid_contains_expected_pairs():
    grid = build_scale_sweep_grid(
        limits=[10_000, 100_000],
        sieve_bounds=[97, 997],
    )
    assert len(grid) == 4
    assert (10_000, 97) in grid
    assert (100_000, 997) in grid


def test_scale_sweep_result_has_governance_fields():
    result = run_scale_sweep(
        limits=[10_000],
        sieve_bounds=[97],
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    assert result["status"] == "B scale robustness check"
    assert "not_claimed" in result
    assert result["inherits_from"] == GOVERNANCE["inherits_from"]
    assert result["primary_question"] == GOVERNANCE["primary_question"]
    assert result["decision_rule"]
    assert result["warning"]


def test_scale_sweep_rows_have_required_metrics():
    result = run_scale_sweep(
        limits=[10_000],
        sieve_bounds=[97],
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    row = result["sweep_rows"][0]
    for key in [
        "limit",
        "sieve_bound",
        "candidate_count",
        "sieved_candidate_count",
        "baseline_hit_rate",
        "ce_hit_rate",
        "ab_hit_rate",
        "ce_ab_lift",
        "orientation_dual_delta_vs_null",
        "right_wing_ge_1_delta_vs_null",
        "right_wing_eq_2_delta_vs_null",
        "conclusion",
    ]:
        assert key in row


def test_default_parameters_match_spec():
    assert list(DEFAULT_LIMITS) == [10_000, 100_000, 1_000_000]
    assert list(DEFAULT_SIEVE_BOUNDS) == [97, 997]
    grid = build_scale_sweep_grid()
    assert len(grid) == 6
    assert all(limit != OPTIONAL_LIMIT_10M for limit, _ in grid)


def test_standard_run_excludes_10m_limit():
    assert OPTIONAL_LIMIT_10M not in DEFAULT_LIMITS
    grid = build_scale_sweep_grid()
    assert all(limit != OPTIONAL_LIMIT_10M for limit, _ in grid)
    assert len(grid) == len(DEFAULT_LIMITS) * len(DEFAULT_SIEVE_BOUNDS)


def test_json_export_has_stable_top_level_keys(tmp_path):
    result = run_scale_sweep(
        limits=[10_000],
        sieve_bounds=[97],
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    path = tmp_path / "scale_sweep.json"
    export_scale_sweep_json(result, path)
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert set(payload.keys()) >= {
        "status",
        "not_claimed",
        "primary_question",
        "inherits_from",
        "decision_rule",
        "warning",
        "tested_limits",
        "tested_sieve_bounds",
        "sweep_rows",
        "stage2_signal_summary",
        "conclusion",
    }


def test_scale_sweep_invalid_limit():
    with pytest.raises(ValueError):
        run_scale_sweep(limits=[10], sieve_bounds=[97])
