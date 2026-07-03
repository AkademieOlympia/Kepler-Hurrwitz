from kepler_hurwitz.qec_bridge import (
    analyze_signed_stabilizer_support_profile,
    enumerate_five_qubit_code_automorphisms,
    export_signed_stabilizer_support_json,
    five_qubit_code_symmetry_specification,
    generate_five_qubit_stabilizers,
)


def test_nontrivial_stabilizer_count_is_15():
    assert len(generate_five_qubit_stabilizers()) == 15


def test_all_shell_profiles_have_length_15():
    analysis = analyze_signed_stabilizer_support_profile()
    for profile in analysis.signed_profiles.values():
        assert len(profile) == 15


def test_all_shell_profiles_have_positive_count_7():
    analysis = analyze_signed_stabilizer_support_profile()
    for profile in analysis.signed_profiles.values():
        assert sum(1 for value in profile if value == 1) == 7


def test_scalar_E044_negative_result_preserved():
    analysis = analyze_signed_stabilizer_support_profile()
    assert analysis.old_fact["scalar_ratio_degenerate"] is True
    assert analysis.old_fact["positive_count"] == 7
    assert analysis.old_fact["total_nontrivial_stabilizers"] == 15
    assert analysis.old_fact["E-044_negative_result_preserved"] is True


def test_raw_profile_relations_recorded():
    analysis = analyze_signed_stabilizer_support_profile()
    assert set(analysis.raw_relations) == {"N4_equals_N6", "N4_equals_N8", "N6_equals_N8"}
    assert analysis.raw_relations["N4_equals_N6"] is False
    assert analysis.raw_relations["N4_equals_N8"] is False
    assert analysis.raw_relations["N6_equals_N8"] is False


def test_symmetry_group_defined_before_orbit_test():
    spec = five_qubit_code_symmetry_specification()
    analysis = analyze_signed_stabilizer_support_profile()
    assert analysis.orbit_relations["symmetry_group_defined_before_comparison"] is True
    assert spec.total_elements == len(enumerate_five_qubit_code_automorphisms()) * 2
    assert "fixed before any shell profile comparison" in spec.definition


def test_canonical_orbit_representatives_exist():
    analysis = analyze_signed_stabilizer_support_profile()
    assert set(analysis.canonical_orbit_representatives) == {"N=4", "N=6", "N=8"}
    for orbit in analysis.canonical_orbit_representatives.values():
        assert len(orbit) == 15


def test_no_upgrade_if_orbit_classes_equal():
    analysis = analyze_signed_stabilizer_support_profile()
    assert analysis.orbit_relations["N4_equals_N6_orbit"] is True
    assert analysis.orbit_relations["N4_equals_N8_orbit"] is True
    assert analysis.orbit_relations["N6_equals_N8_orbit"] is True
    assert analysis.e045_upgrade_eligible is False


def test_export_signed_stabilizer_support_json(tmp_path):
    analysis = analyze_signed_stabilizer_support_profile()
    path = export_signed_stabilizer_support_json(
        analysis, tmp_path / "signed_stabilizer_support_profile.json"
    )
    text = path.read_text(encoding="utf-8")
    assert '"id": "E-045-pre"' in text
    assert '"claim_class": "C"' in text
    assert '"symmetry_group_defined_before_comparison": true' in text
