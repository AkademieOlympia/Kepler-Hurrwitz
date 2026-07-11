import pytest

from kepler_hurwitz.twin_prime_eabc_phase_analysis import (
    DEFAULT_LIMIT,
    DEFAULT_SIEVE_BOUND,
    GOVERNANCE,
    MODE,
    NOT_CLAIMED,
    PRIMARY_QUESTION,
    RANDOMIZED_LABELS_SEED,
    STATUS,
    annotate_twin_candidate,
    build_twin_prime_candidates,
    classify_quadruplet_neighborhood,
    enrichment,
    generate_ce_twin_candidates,
    hit_rate,
    is_twin_prime,
    passes_twin_sieve,
    phase_shift_summary,
    randomized_channel_sequence,
    run_twin_prime_phase_analysis,
)


def test_generate_ce_twin_candidates_are_below_limit_and_ce():
    rows = generate_ce_twin_candidates(1_000_000)
    assert all(n < 1_000_000 for n in rows)
    assert all(n % 12 == 11 for n in rows)
    assert all((n + 2) % 12 == 1 for n in rows)


def test_candidate_annotation_uses_index_not_n_value():
    sieve_primes = [2, 3, 5, 7]
    row = annotate_twin_candidate(47, candidate_index=3, sieve_primes=sieve_primes)
    assert row.floquet_step == 3
    assert row.floquet_step != 47 % 8
    assert row.channel == "B"
    assert row.n == 47
    assert row.candidate_index == 3

    row2 = annotate_twin_candidate(131, candidate_index=10, sieve_primes=sieve_primes)
    assert row2.floquet_step == 10 % 8
    assert row2.floquet_step != 131 % 8


def test_phase_shift_preserves_candidate_count():
    rows = build_twin_prime_candidates(limit=500, sieve_bound=29)
    sieved_count = sum(1 for row in rows if row.passed_small_sieve)
    for shift in range(8):
        summary = phase_shift_summary(rows, shift)
        assert summary["candidate_count"] == sieved_count


def test_is_twin_prime_examples():
    assert is_twin_prime(3)
    assert is_twin_prime(11)
    assert is_twin_prime(17)
    assert not is_twin_prime(4)
    assert not is_twin_prime(8)


def test_passes_twin_sieve():
    sieve_primes = [2, 3, 5, 7, 11, 13]
    assert passes_twin_sieve(11, sieve_primes)
    assert not passes_twin_sieve(143, sieve_primes)


def test_classify_quadruplet_neighborhood_examples():
    assert classify_quadruplet_neighborhood(197) == "twin_only"
    assert classify_quadruplet_neighborhood(4) == "failed_candidate"


def test_hit_rate_and_enrichment():
    rows = build_twin_prime_candidates(limit=500, sieve_bound=29)
    baseline_rate = hit_rate(rows, lambda row: True)
    sieved_rate = hit_rate(rows, lambda row: row.passed_small_sieve)
    assert baseline_rate is not None
    assert sieved_rate is not None
    assert enrichment(sieved_rate, baseline_rate) is not None
    assert enrichment(0.0, 0.0) is None


def test_randomized_channel_sequence_is_permutation():
    permuted = randomized_channel_sequence(RANDOMIZED_LABELS_SEED)
    assert len(permuted) == 8
    assert len(set(permuted)) == 4


def test_phase_distribution_experiment_runs_small_range():
    report = run_twin_prime_phase_analysis(limit=500, sieve_bound=29)
    assert report.status == STATUS
    assert report.not_claimed == NOT_CLAIMED
    assert report.mode == MODE
    assert report.primary_question == PRIMARY_QUESTION
    assert report.primary_evidence == "[B]"
    assert report.exploratory_evidence == "[C]"
    assert report.baseline.candidate_count >= report.small_sieve.candidate_count
    assert 0.0 <= report.small_sieve.hit_rate <= 1.0
    assert len(report.primary_phase_table) == 8
    assert report.primary_analysis.degrees_of_freedom == 7
    assert set(report.floquet_groups.keys()) == {
        "by_step",
        "by_channel",
        "by_chi_phase",
        "by_sheet",
    }
    assert len(report.null_models["phase_shifts"]) == 7


def test_quadruplet_neighborhood_present():
    report = run_twin_prime_phase_analysis(limit=1000, sieve_bound=29)
    assert set(report.quadruplet_neighborhood.keys()) == {
        "twin_only",
        "near_quadruplet",
        "prime_quadruplet",
        "failed_candidate",
    }


def test_default_experiment_params():
    assert DEFAULT_LIMIT == 1_000_000
    assert DEFAULT_SIEVE_BOUND == 97


def test_phase_analysis_invalid_limit():
    with pytest.raises(ValueError):
        run_twin_prime_phase_analysis(limit=10)


def test_governance_constants():
    assert GOVERNANCE["mode"] == "phase_distribution_analysis"
    assert GOVERNANCE["status"] == "B descriptive phase-distribution analysis"
    assert GOVERNANCE["not_claimed"] == NOT_CLAIMED
    assert GOVERNANCE["primary_question"] == PRIMARY_QUESTION


def test_minimal_json_export_fields():
    report = run_twin_prime_phase_analysis(limit=500, sieve_bound=29)
    payload = report.to_minimal_dict()
    assert payload["mode"] == MODE
    assert payload["status"] == STATUS
    assert "limit" in payload
    assert "sieve_bound" in payload
    assert "candidate_count" in payload
    assert "sieved_candidate_count" in payload
    assert "twin_hit_count" in payload
    assert "overall_hit_rate" in payload
    assert len(payload["by_floquet_step"]) == 8
    assert all("phase" in row and "count" in row and "hits" in row for row in payload["by_floquet_step"])
    assert len(payload["by_channel"]) == 4
    assert len(payload["phase_shifts"]) == 7
    assert all("max_enrichment" in entry for entry in payload["phase_shifts"])
    assert payload["selection_rule"] == GOVERNANCE["selection_rule"]
    assert payload["uniformity_diagnostic"]["status"] == "B descriptive only"
    assert "max_hit_rate" in payload["uniformity_diagnostic"]
    assert "min_hit_rate" in payload["uniformity_diagnostic"]
    assert "spread" in payload["uniformity_diagnostic"]
    assert "max_enrichment_vs_overall" in payload["uniformity_diagnostic"]
    assert payload["exploratory_best_phase"]["status"] == "C exploratory only"
    assert "warning" in payload["exploratory_best_phase"]
    assert "phase" in payload["exploratory_best_phase"]
    assert "enrichment" in payload["exploratory_best_phase"]
