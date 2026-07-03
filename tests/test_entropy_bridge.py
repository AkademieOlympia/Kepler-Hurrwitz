import json
from fractions import Fraction
from math import isclose
from pathlib import Path

from kepler_hurwitz.entropy_bridge import (
    BALANCED_SPLIT,
    N6_ASSOCIATIVE_RATIO,
    N6_RATIONAL_RHO,
    algebraic_layer_metrics,
    binary_entropy_h2,
    build_entropy_bridge_report,
    export_entropy_bridge_json,
    quantize_symmetric_binary,
    quantization_gap,
    quantization_gap_from_rho_only,
    row_entropy_bits,
    dynamic_layer_metrics_from_json,
)

ROOT = Path(__file__).resolve().parents[1]
MATRIX_PATH = ROOT / "docs" / "energiedoku_exports" / "arithmetic_transition_matrix.json"


def test_qsym_projects_to_balanced_split_independent_of_rho():
    assert quantize_symmetric_binary(0.767) == (0.5, 0.5)
    assert quantize_symmetric_binary(0.1) == (0.5, 0.5)
    assert isclose(row_entropy_bits(((0.0, 0.5), (1.0, 0.5))), 1.0, abs_tol=1e-12)


def test_statement_a_algebraic_entropy_is_not_row_entropy():
    alg = algebraic_layer_metrics(N6_ASSOCIATIVE_RATIO)
    assert isclose(alg.H_alg_bits, 0.783, abs_tol=0.002)
    assert alg.H_alg_bits < 1.0


def test_statement_b_dynamic_row_entropy_is_maximal():
    payload = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
    dyn = dynamic_layer_metrics_from_json(payload)
    assert dyn.x0_from == 1.0
    assert len(dyn.P_row) == 2
    assert all(isclose(prob, 0.5, abs_tol=1e-9) for _target, prob in dyn.P_row)
    assert isclose(dyn.H_row_bits, 1.0, abs_tol=1e-12)
    assert isclose(dyn.p_dyn_max, 0.5, abs_tol=1e-12)


def test_statement_c_quantization_gap_is_not_probabilistic_mismatch():
    payload = json.loads(MATRIX_PATH.read_text(encoding="utf-8"))
    dyn = dynamic_layer_metrics_from_json(payload)
    rho = float(N6_RATIONAL_RHO)
    gap = quantization_gap(rho, p_dyn_max=dyn.p_dyn_max)
    assert isclose(gap, float(Fraction(4, 15)), abs_tol=1e-12)
    assert isclose(quantization_gap_from_rho_only(rho), float(Fraction(4, 15)), abs_tol=1e-12)


def test_h3_report_separates_three_statements():
    report = build_entropy_bridge_report(transition_matrix_path=MATRIX_PATH, associative_ratio=float(N6_RATIONAL_RHO))
    assert report.algebraic.H_alg_bits < report.dynamic.H_row_bits
    assert isclose(report.quantization.quantization_gap, float(Fraction(4, 15)), abs_tol=1e-12)
    assert report.quantization.quantization_gap_rational == "4/15"
    assert report.quantization.Q_sym == (0.5, 0.5)
    assert isclose(report.quantization.H_Q_sym_bits, 1.0, abs_tol=1e-12)


def test_export_entropy_bridge_json(tmp_path):
    report = build_entropy_bridge_report(transition_matrix_path=MATRIX_PATH, associative_ratio=N6_ASSOCIATIVE_RATIO)
    path = export_entropy_bridge_json(report, tmp_path / "entropy_bridge.json")
    payload = json.loads(path.read_text(encoding="utf-8"))
    assert payload["layer_separation"]["C_quantization_bridge"]["note"]
    assert payload["layer_separation"]["A_algebraic_density"]["H_alg_bits"] < 1.0


def test_binary_entropy_at_balanced_split_is_one():
    assert isclose(binary_entropy_h2(BALANCED_SPLIT), 1.0, abs_tol=1e-12)
