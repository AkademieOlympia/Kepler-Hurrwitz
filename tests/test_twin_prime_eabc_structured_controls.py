import pytest

from kepler_hurwitz.twin_prime_eabc_structured_controls import (
    GOVERNANCE,
    STAGE1_INTERPRETATION,
    annotate_structured_candidate,
    build_structured_twin_candidates,
    dumas_gap_signature,
    evaluate_stratum_feature,
    export_structured_controls_json,
    missing_hosts,
    orientation_dual_score,
    passes_classical_twin_sieve,
    right_wing_prime_count,
    run_structured_controls_experiment,
    summarize_stage1_residue_effect,
)

MOCK_SIGNED_DUAL_REFERENCE = {0: True, 1: True, 2: True, 3: True}


def test_passes_classical_twin_sieve_accepts_ce_and_ab():
    sieve = [2, 3, 5, 7, 11, 13]
    assert passes_classical_twin_sieve(11, sieve)
    assert passes_classical_twin_sieve(5, sieve)
    assert not passes_classical_twin_sieve(7, sieve)


def test_right_wing_excludes_twin_pair():
    assert right_wing_prime_count(11) == 2


def test_quadruplet_diagnostics_for_eleven():
    assert missing_hosts(11) == ()
    assert dumas_gap_signature(11) == "none"


def test_orientation_dual_reference_baseline_all_true():
    rows = build_structured_twin_candidates(
        limit=500,
        sieve_bound=29,
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    assert all(row.orientation_dual_score == 1.0 for row in rows)


def test_structured_candidate_uses_stratum_index_not_n():
    reference = {0: True, 1: True, 2: True, 3: True}
    row = annotate_structured_candidate(
        47,
        residue_class="CE",
        stratum_index=3,
        sieve_primes=[2, 3, 5, 7],
        signed_dual_reference=reference,
    )
    assert row.floquet_step == 3
    assert row.floquet_step != 47 % 8
    assert row.orientation_dual_score == 1.0


def test_orientation_dual_score_binary():
    reference = {0: True, 1: False, 2: True, 3: False}
    assert orientation_dual_score(0, signed_dual_reference=reference) == 1.0
    assert orientation_dual_score(1, signed_dual_reference=reference) == 0.0


def test_evaluate_stratum_feature_detects_constant_feature():
    rows = build_structured_twin_candidates(
        limit=500,
        sieve_bound=29,
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    result = evaluate_stratum_feature(rows, stratum="CE", feature_name="orientation_dual")
    assert result.feature_is_constant is True


def test_stage1_interpretation_present():
    rows = build_structured_twin_candidates(
        limit=500,
        sieve_bound=29,
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    summary = summarize_stage1_residue_effect(rows)
    assert summary.interpretation == STAGE1_INTERPRETATION


def test_structured_controls_experiment_runs():
    report = run_structured_controls_experiment(
        limit=1000,
        sieve_bound=29,
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    assert report.status == GOVERNANCE["status"]
    assert report.not_claimed == GOVERNANCE["not_claimed"]
    assert report.primary_question == GOVERNANCE["primary_question"]
    assert len(report.orientation_features) == 2
    assert len(report.right_wing_features) == 2
    assert STAGE1_INTERPRETATION in report.to_dict()["stage1_interpretation"]


def test_export_json(tmp_path):
    report = run_structured_controls_experiment(
        limit=500,
        sieve_bound=29,
        signed_dual_reference=MOCK_SIGNED_DUAL_REFERENCE,
    )
    path = tmp_path / "structured_controls.json"
    export_structured_controls_json(report, path)
    assert path.exists()
    assert "randomized_labels_within_residue_class" in path.read_text()


def test_invalid_limit():
    with pytest.raises(ValueError):
        run_structured_controls_experiment(limit=10)
