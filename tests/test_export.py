import json
from pathlib import Path

from kepler_hurwitz.export import (
    cyclic_word_class_records,
    export_cyclic_word_classes_csv,
    export_cyclic_word_classes_json,
    export_octonionic_slice_csv,
    export_octonionic_slice_json,
    export_primvierling_analysis_csv,
    export_primvierling_analysis_json,
    export_smoothness_channels_csv,
    export_smoothness_channels_json,
    export_smoothness_b_bound_matrix_json,
    export_smoothness_b_bound_summary_json,
    export_smoothness_scale_stability_json,
    export_smoothness_significance_json,
    octonionic_slice_records,
    primvierling_analysis_records,
    smoothness_channel_records,
    smoothness_channel_summary_records,
)
from kepler_hurwitz.primvierling import analyze_range
from kepler_hurwitz.smoothness_channel_scan import scan_smoothness_channels


def test_primvierling_analysis_records_not_empty():
    analyses = analyze_range(3, 50)
    records = primvierling_analysis_records(analyses)
    assert len(records) > 0
    assert "invariant_name" in records[0]


def test_export_primvierling_json(tmp_path):
    analyses = analyze_range(3, 50)
    output = tmp_path / "primvierling.json"
    export_primvierling_analysis_json(analyses, output)
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert "analyses" in payload
    assert len(payload["analyses"]) > 0


def test_export_primvierling_csv(tmp_path):
    analyses = analyze_range(3, 50)
    output = tmp_path / "primvierling.csv"
    export_primvierling_analysis_csv(analyses, output)
    content = output.read_text(encoding="utf-8")
    assert "invariant_name" in content
    assert "quat_reduced_norm" in content


def test_cyclic_word_class_records_grouping():
    records = cyclic_word_class_records(["1011", "0111", "0011", "1100"])
    by_canonical = {record["canonical"]: record for record in records}
    assert by_canonical["0111"]["size"] == 2
    assert by_canonical["0011"]["size"] == 2


def test_export_cyclic_word_json_and_csv(tmp_path):
    words = ["1011", "0111", "0011", "1100"]
    json_output = tmp_path / "cyclic_words.json"
    csv_output = tmp_path / "cyclic_words.csv"

    export_cyclic_word_classes_json(words, json_output)
    export_cyclic_word_classes_csv(words, csv_output)

    payload = json.loads(json_output.read_text(encoding="utf-8"))
    csv_content = csv_output.read_text(encoding="utf-8")

    assert "classes" in payload
    assert "canonical,size,members" in csv_content


def test_smoothness_channel_records_and_summary():
    samples = scan_smoothness_channels(limit_m=31, b=5)
    records = smoothness_channel_records(samples)
    summary = smoothness_channel_summary_records(samples)
    assert len(records) == len(samples)
    assert all("channel" in row for row in records)
    assert [row["channel"] for row in summary] == ["klein", "mittel", "tief"]


def test_export_smoothness_json_and_csv(tmp_path):
    samples = scan_smoothness_channels(limit_m=31, b=5)
    json_output = tmp_path / "smoothness_channels.json"
    csv_output = tmp_path / "smoothness_channels.csv"

    export_smoothness_channels_json(samples, json_output, limit_m=31, b=5)
    export_smoothness_channels_csv(samples, csv_output, limit_m=31, b=5)

    payload = json.loads(json_output.read_text(encoding="utf-8"))
    csv_content = csv_output.read_text(encoding="utf-8")

    assert payload["metadata"]["limit_m"] == 31
    assert payload["metadata"]["b"] == 5
    assert len(payload["summary"]) == 3
    assert "channel,total,b_smooth,ratio,limit_m,b" in csv_content


def test_export_smoothness_significance_json(tmp_path):
    samples = scan_smoothness_channels(limit_m=199, b=5)
    output = tmp_path / "smoothness_significance.json"
    export_smoothness_significance_json(samples, output, limit_m=199, b=5)
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["metadata"]["test_name"] == "chi_square_independence"
    assert payload["result"]["degrees_of_freedom"] == 2
    assert payload["result"]["chi2"] >= 0
    assert 0 <= payload["result"]["p_value"] <= 1


def test_export_smoothness_scale_stability_json(tmp_path):
    output = tmp_path / "smoothness_scale_stability.json"
    export_smoothness_scale_stability_json(output, b=5, limits=[999, 1999])
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert payload["b_bound"] == 5
    assert len(payload["scales"]) == 2
    assert payload["scales"][0]["limit_m"] == 999


def test_export_smoothness_b_bound_matrix_json(tmp_path):
    output = tmp_path / "smoothness_b_bound_matrix.json"
    export_smoothness_b_bound_matrix_json(
        output,
        b_bounds=[3, 5],
        limits=[999, 1999],
    )
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert len(payload["scans"]) == 2
    assert payload["scans"][0]["b_bound"] == 3
    assert payload["scans"][0]["results"][0]["limit_m"] == 999


def test_export_smoothness_b_bound_summary_json(tmp_path):
    output = tmp_path / "smoothness_b_bound_summary.json"
    export_smoothness_b_bound_summary_json(
        output,
        b_bounds=[3, 5],
        limits=[999, 1999],
    )
    payload = json.loads(output.read_text(encoding="utf-8"))
    assert len(payload["trends"]) == 2
    assert "most_stable_b_bound" in payload["summary"]
    assert "stability_score" in payload["trends"][0]


def test_octonionic_slice_records_and_exports(tmp_path):
    mu_values = [-2.5, -2.0]
    q_values = [0.0, (15**0.5) / 2.0]
    records = octonionic_slice_records(mu_values, q_values)
    assert len(records) == 4
    assert all("class" in row for row in records)

    json_output = tmp_path / "octonionic_slice_constraints.json"
    csv_output = tmp_path / "octonionic_slice_constraints.csv"
    export_octonionic_slice_json(
        json_output,
        mu_values=mu_values,
        q_values=q_values,
    )
    export_octonionic_slice_csv(
        csv_output,
        mu_values=mu_values,
        q_values=q_values,
    )

    payload = json.loads(json_output.read_text(encoding="utf-8"))
    csv_content = csv_output.read_text(encoding="utf-8")

    assert payload["metadata"]["grid_size"] == 4
    assert payload["assumptions"]["quaternionic_associator_vanishes"] is True
    assert len(payload["interference_points"]) == 2
    assert "quartic_mu_q_residual" in csv_content


def test_sage_symbolic_constraints_schema_exists_and_is_marked_schema_only():
    schema_path = Path("docs/energiedoku_exports/sage_symbolic_constraints.schema.json")
    payload = json.loads(schema_path.read_text(encoding="utf-8"))
    assert payload["status"] == "schema_only_not_computed"
    assert payload["symbolic_constraints"]["ring"] == "QQ[mu, S]"
    assert payload["variables"]["S"].startswith("Q^2")
