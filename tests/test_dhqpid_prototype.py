from fractions import Fraction as F
from pathlib import Path

from kepler_hurwitz.dhqpid_prototype import (
    GOVERNANCE,
    H17_ORDER,
    H713_ORDER,
    build_alpha_pool,
    export_prototype_artifacts,
    from_coeffs,
    generate_candidates,
    is_in_order,
    run_order_prototype,
    search_witness,
    build_beta_pool,
)


def test_order_membership_for_basis_elements():
    assert is_in_order(H17_ORDER, from_coeffs(H17_ORDER, (1, 0, 0, 0)))
    assert is_in_order(H713_ORDER, from_coeffs(H713_ORDER, (1, 0, 0, 0)))


def test_alpha_pool_sizes_match_bounded_cardoso_window():
    assert len(build_alpha_pool(H17_ORDER)) == 620
    assert len(build_alpha_pool(H713_ORDER)) == 424


def test_h17_user_dh_witness_example():
    rho = from_coeffs(H17_ORDER, (0, -1, -1, -1)).scale(F(1, 2))
    alpha = from_coeffs(H17_ORDER, (-1, -1, 0, 0))
    beta = from_coeffs(H17_ORDER, (-1, 0, 0, 1))
    assert (alpha * rho - beta).norm_sq() == F(1, 2)


def test_prototype_summary_has_dh_success():
    h17_summary, _ = run_order_prototype(H17_ORDER)
    h713_summary, _ = run_order_prototype(H713_ORDER)
    assert h17_summary.dh_success == h17_summary.candidates
    assert h713_summary.dh_success == h713_summary.candidates
    assert h17_summary.alpha_pool == 620
    assert h713_summary.alpha_pool == 424


def test_governance_string_mentions_no_eabc_claim():
    assert "EABC" in GOVERNANCE
    assert "Does not prove" in GOVERNANCE


def test_export_writes_artifacts(tmp_path: Path):
    export_prototype_artifacts(tmp_path)
    for name in (
        "dhqpid_prototype_summary.csv",
        "dhqpid_prototype_H17.csv",
        "dhqpid_prototype_H713.csv",
        "dhqpid_prototype_report.md",
        "dhqpid_prototype.json",
    ):
        assert (tmp_path / name).is_file()


def test_rescue_candidates_have_dh_witness_when_euc_fails():
    betas = build_beta_pool(H17_ORDER)
    alphas = build_alpha_pool(H17_ORDER)
    for candidate in generate_candidates(H17_ORDER):
        result = search_witness(H17_ORDER, candidate, betas, alphas)
        if result.rescue:
            assert not result.euc_success
            assert result.dh_success
            assert result.best_dh_norm < 1
