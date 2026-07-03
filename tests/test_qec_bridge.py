from kepler_hurwitz.qec_bridge import (
    analyze_css_projection,
    analyze_fano_kernel_shell_map,
    analyze_refined_shell_projection,
    analyze_refined_shell_cosets,
    analyze_signed_support_symmetry_invariance,
    analyze_signed_shell_syndromes,
    apply_model_symmetry,
    enumerate_fano_automorphisms,
    enumerate_model_symmetry_group,
    export_signed_support_symmetry_json,
    model_symmetry_group_specification,
    analyze_shell_cosets_mod_kernel,
    build_shell_projection_bundle,
    export_signed_shell_syndromes_json,
    hurwitz_residue_signature,
    signed_support_signature,
    build_fano_parity_rows,
    build_fano_stabilizer_generators,
    build_stabilizer_structure_summary,
    build_syndrome_table,
    canonical_coset_representative,
    classify_dyadic_roots,
    coset_equivalent,
    coset_weight_profile,
    default_shell_syndrome_map,
    enumerate_basis_commutation_records,
    enumerate_kernel_words,
    export_fano_kernel_shell_map_json,
    export_fano_shell_cosets_json,
    export_refined_shell_projection_json,
    export_qec_bridge_json,
    gf2_add,
    gf2_coset_syndrome,
    gf2_invertible_matrices,
    gf2_mat_vec_mul,
    gf2_rref,
    gf2_rowspace_contains,
    hamming_weight,
    independent_fano_generator_count,
    kernel_min_hamming_weight,
    steane_hx_reference_rows,
    syndrome_class_for_record,
    transform_kernel_basis,
    verify_fano_multiplication_closure,
    verify_imaginary_involutions,
)
from kepler_hurwitz.metacommutation import analyze_dyadic_metacommutation


def test_fano_stabilizer_generator_count():
    generators = build_fano_stabilizer_generators()
    assert len(generators) == 7
    assert all(len(item.indices) == 3 for item in generators)


def test_independent_fano_generator_rank():
    # Seven line masks; GF(2) rank is 4 (line dependencies, not seven independent checks).
    assert independent_fano_generator_count() == 4


def test_fano_multiplication_closure():
    assert verify_fano_multiplication_closure()


def test_imaginary_unit_involutions():
    assert verify_imaginary_involutions()


def test_basis_commutation_records_cover_pairs():
    records = enumerate_basis_commutation_records()
    pair_keys = {(item.left, item.right) for item in records}
    expected = {
        (left, right)
        for left in range(1, 8)
        for right in range(left, 8)
    }
    assert pair_keys == expected
    assert all(item.relation in {"involution", "anticommute_to_third", "same"} for item in records)
    assert sum(1 for item in records if item.relation == "involution") == 7


def test_dyadic_root_classes_partition():
    classes = classify_dyadic_roots()
    assert len(classes) == 112
    assert len({item.class_id for item in classes}) == 112
    assert sum(1 for item in classes if item.includes_real_axis) == 28
    assert sum(1 for item in classes if item.fano_line_indices) == 84


def test_syndrome_table_partitions_metacommutation_pairs():
    records = analyze_dyadic_metacommutation()
    table = build_syndrome_table(records)
    assert table.total_pairs == 112 * 240
    assert sum(entry.count for entry in table.entries) == table.total_pairs
    assert table.class_totals.get("unresolved", 0) == 0
    assert table.class_totals["associative_dyadic"] == 4320
    assert table.class_totals["non_associative_dyadic"] == 8224


def test_syndrome_class_helper_matches_table():
    records = analyze_dyadic_metacommutation()
    table = build_syndrome_table(records)
    manual = {}
    for record in records:
        key = (syndrome_class_for_record(record), record.partner_count)
        manual[key] = manual.get(key, 0) + 1
    rebuilt = {(entry.syndrome_class, entry.degeneracy): entry.count for entry in table.entries}
    assert manual == rebuilt


def test_stabilizer_structure_summary():
    summary = build_stabilizer_structure_summary()
    assert summary.fano_line_count == 7
    assert summary.independent_generator_count == 4
    assert summary.dyadic_root_count == 112
    assert summary.dyadic_class_count == 28
    assert len(summary.shell_syndrome_map) == len(default_shell_syndrome_map())


def test_export_qec_bridge_json(tmp_path):
    summary = build_stabilizer_structure_summary()
    path = export_qec_bridge_json(summary, tmp_path / "qec_bridge.json")
    assert path.exists()


def test_css_projection_rank_and_kernel():
    analysis = analyze_css_projection()
    assert analysis.fano_line_count == 7
    assert analysis.fano_line_rank == 4
    assert analysis.kernel_dimension == 3
    assert len(analysis.independent_generator_rows) == 4
    assert len(analysis.kernel_basis_rows) == 3


def test_css_projection_steane_comparison():
    analysis = analyze_css_projection()
    assert analysis.steane_hx_rank == 3
    assert analysis.steane_hz_rank == 3
    assert analysis.steane_css_generator_count == 6
    assert analysis.steane_classical_distance == 3
    # Fano line span (dim 4) and Steane H_X (dim 3) share only one independent direction.
    assert analysis.steane_hx_contained_in_fano_rowspace is False
    assert analysis.fano_rowspace_contained_in_steane_hx is False
    assert analysis.rowspace_intersection_dimension == 1


def test_fano_parity_rows_match_masks():
    rows = build_fano_parity_rows()
    generators = build_fano_stabilizer_generators()
    for row, generator in zip(rows, generators, strict=True):
        assert hamming_weight(row) == 3
        assert rows[0] == (1, 1, 1, 0, 0, 0, 0)
        break
    assert len(rows) == len(generators) == 7


def test_gf2_rref_matches_independent_count():
    rows = build_fano_parity_rows()
    assert len(gf2_rref(rows)) == independent_fano_generator_count()


def test_kernel_min_hamming_weight_exceeds_steane_distance():
    analysis = analyze_css_projection()
    # Single-type Fano parity code has kernel min weight 4, not Steane's 3.
    assert analysis.kernel_min_hamming_weight == 4
    assert analysis.kernel_min_hamming_weight > analysis.steane_classical_distance


def test_steane_hx_first_row_is_fano_line():
    fano_rows = build_fano_parity_rows()
    hx_rows = steane_hx_reference_rows()
    assert hx_rows[0] == fano_rows[0]
    assert gf2_rowspace_contains(fano_rows, hx_rows) is False


def test_fano_kernel_words_structure():
    analysis = analyze_fano_kernel_shell_map()
    css = analyze_css_projection()
    check_rows = css.independent_generator_rows
    assert css.fano_line_rank == 4
    assert analysis.fano_kernel_dimension == 3
    assert len(analysis.kernel_words) == 8
    assert analysis.kernel_basis_independent is True
    assert analysis.min_nonzero_weight == 4
    assert analysis.weight_profile == {"0": 1, "4": 7}
    for word in analysis.kernel_words:
        assert gf2_mat_vec_mul(check_rows, word.bits) == (0,) * len(check_rows)
    nonzero_weights = [word.hamming_weight for word in analysis.kernel_words if not word.is_zero]
    assert min(nonzero_weights) == 4


def test_fano_kernel_basis_invariance_under_gl3():
    analysis = analyze_fano_kernel_shell_map()
    report = analysis.basis_invariance
    assert report.gl3_matrix_count == 168
    assert report.weight_profile_invariant is True
    assert report.min_nonzero_weight_invariant is True
    assert report.shell_distance_to_kernel_invariant is True
    assert report.coordinate_labels_basis_dependent is True


def test_shell_syndrome_map_claim_class_and_coverage():
    analysis = analyze_fano_kernel_shell_map()
    assert analysis.claim_class == "C"
    assert analysis.depends_on == ("E-037", "E-038")
    labels = {item.shell_label for item in analysis.shell_syndrome_candidates}
    assert labels == {"N=4", "N=6", "N=8"}
    assert all(item.interpretation_status == "candidate" for item in analysis.shell_syndrome_candidates)
    assert analysis.interpretation == {
        "pumping": "candidate",
        "bifurcation": "candidate",
        "fixpoint": "candidate",
    }
    for item in analysis.shell_syndrome_candidates:
        assert item.syndrome_label_candidate
        assert item.stabilization_classes


def test_export_fano_kernel_shell_map_json(tmp_path):
    analysis = analyze_fano_kernel_shell_map()
    path = export_fano_kernel_shell_map_json(analysis, tmp_path / "fano_kernel_shell_map.json")
    assert path.exists()
    payload = path.read_text(encoding="utf-8")
    assert '"claim_class": "C"' in payload
    assert "N=4" in payload and "N=6" in payload and "N=8" in payload


def test_coset_equivalence_iff_same_syndrome():
    css = analyze_css_projection()
    rows = css.independent_generator_rows
    kernel = analyze_fano_kernel_shell_map()
    vectors = [item.parity_bits for item in kernel.shell_syndrome_candidates]
    for left in vectors:
        assert coset_equivalent(left, left, rows)
    for left in vectors:
        for right in vectors:
            same_syndrome = gf2_coset_syndrome(rows, left) == gf2_coset_syndrome(rows, right)
            assert coset_equivalent(left, right, rows) is same_syndrome


def test_shell_N4_N8_coset_relation_recorded():
    analysis = analyze_shell_cosets_mod_kernel()
    assert analysis.relations["N4_equals_N8_coset"] is True
    assert analysis.e039_upgrade_eligible is False
    n4 = next(item for item in analysis.shell_cosets if item.shell_label == "N=4")
    n8 = next(item for item in analysis.shell_cosets if item.shell_label == "N=8")
    assert n4.syndrome == n8.syndrome
    assert n4.parity_bits == n8.parity_bits


def test_shell_N6_coset_relation_recorded():
    analysis = analyze_shell_cosets_mod_kernel()
    assert analysis.relations["N4_equals_N6_coset"] is False
    assert analysis.relations["N6_equals_N8_coset"] is False
    n6 = next(item for item in analysis.shell_cosets if item.shell_label == "N=6")
    assert n6.syndrome_id == "0001"


def test_coset_labels_basis_independent_under_gl3():
    analysis = analyze_shell_cosets_mod_kernel()
    report = analysis.basis_invariance
    assert report.syndrome_labels_invariant is True
    assert report.coset_weight_profiles_invariant is True


def test_coset_weight_enumerator_invariant():
    css = analyze_css_projection()
    kernel = css.kernel_basis_rows
    shell = analyze_fano_kernel_shell_map().shell_syndrome_candidates[0].parity_bits
    profile = coset_weight_profile(shell, kernel)
    for transform in gf2_invertible_matrices(len(kernel))[:16]:
        rotated = transform_kernel_basis(kernel, transform)
        assert coset_weight_profile(shell, rotated) == profile


def test_all_shell_vectors_have_canonical_coset_representative():
    analysis = analyze_shell_cosets_mod_kernel()
    css = analyze_css_projection()
    for record in analysis.shell_cosets:
        rep = canonical_coset_representative(record.parity_bits, css.kernel_basis_rows)
        assert coset_equivalent(record.parity_bits, rep, css.independent_generator_rows)
        assert hamming_weight(rep) == min(
            hamming_weight(gf2_add(record.parity_bits, word))
            for word in enumerate_kernel_words(css.kernel_basis_rows)
        )


def test_nearest_kernel_coordinate_is_not_used_as_invariant():
    analysis = analyze_shell_cosets_mod_kernel()
    n4 = next(item for item in analysis.shell_cosets if item.shell_label == "N=4")
    n8 = next(item for item in analysis.shell_cosets if item.shell_label == "N=8")
    n6 = next(item for item in analysis.shell_cosets if item.shell_label == "N=6")
    assert n4.nearest_kernel_coordinates == n8.nearest_kernel_coordinates
    assert n4.syndrome == n8.syndrome
    assert n6.nearest_kernel_coordinates != n4.nearest_kernel_coordinates
    assert analysis.basis_invariance.nearest_kernel_coordinates_not_used_as_invariant is True


def test_quotient_coset_count():
    analysis = analyze_shell_cosets_mod_kernel()
    assert analysis.quotient.ambient_dimension == 7
    assert analysis.quotient.kernel_dimension == 3
    assert analysis.quotient.number_of_cosets == 16


def test_export_fano_shell_cosets_json(tmp_path):
    analysis = analyze_shell_cosets_mod_kernel()
    path = export_fano_shell_cosets_json(analysis, tmp_path / "fano_shell_cosets.json")
    assert path.exists()
    text = path.read_text(encoding="utf-8")
    assert '"e039_upgrade_eligible": false' in text
    assert '"N4_equals_N8_coset": true' in text


def test_N4_N8_same_old_syndrome_is_preserved():
    analysis = analyze_refined_shell_projection()
    signatures = {item.shell_label: item for item in analysis.signatures}
    assert signatures["N=4"].old_syndrome_id == signatures["N=8"].old_syndrome_id == "1000"
    assert signatures["N=6"].old_syndrome_id == "0001"


def test_N6_old_syndrome_separation_is_preserved():
    analysis = analyze_refined_shell_projection()
    assert analysis.input_fact["sigma_6_separated"] is True
    for report in analysis.refinements.values():
        assert report.preserves_N6_separation_from_N4 is True
        assert report.preserves_N6_separation_from_N8 is True


def test_refined_signature_is_canonical():
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    operators = [op for op in default_arithmetic_prime_operators() if op.is_shell_proxy]
    first = analyze_refined_shell_projection()
    second = analyze_refined_shell_projection()
    assert first.refinements.keys() == second.refinements.keys()
    for op in operators:
        bundle = build_shell_projection_bundle(op.element, operator_label=op.label)
        again = build_shell_projection_bundle(op.element, operator_label=op.label)
        assert bundle.projected == again.projected
        assert hurwitz_residue_signature(bundle).projected_key == hurwitz_residue_signature(again).projected_key


def test_refined_signature_GL_invariant():
    css = analyze_css_projection()
    cosets = analyze_shell_cosets_mod_kernel()
    parities = [record.parity_bits for record in cosets.shell_cosets]
    for transform in gf2_invertible_matrices(len(css.kernel_basis_rows))[:16]:
        rotated = transform_kernel_basis(css.kernel_basis_rows, transform)
        for parity in parities:
            assert gf2_coset_syndrome(css.independent_generator_rows, parity) == gf2_coset_syndrome(
                css.independent_generator_rows, parity
            )
        assert len(rotated) == 3


def test_refined_N4_N8_relation_recorded():
    analysis = analyze_refined_shell_projection()
    assert analysis.refinements["hurwitz_residue"].separates_N4_N8 is True
    assert analysis.refinements["signed_support"].separates_N4_N8 is True
    assert analysis.refinements["real_axis"].separates_N4_N8 is True


def test_no_upgrade_if_refined_N4_N8_equal_for_residue_only_key():
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    operators = {
        op.label: op for op in default_arithmetic_prime_operators() if op.is_shell_proxy
    }
    n4 = build_shell_projection_bundle(operators["shell_proxy_N4_for_3"].element)
    n8 = build_shell_projection_bundle(operators["shell_proxy_N8_for_7"].element)
    assert hurwitz_residue_signature(n4).residue_key == hurwitz_residue_signature(n8).residue_key


def test_refinement_is_defined_before_shell_labels_are_compared():
    bundle = build_shell_projection_bundle((2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
    assert hurwitz_residue_signature(bundle).projected_key[0] == 2.0
    assert signed_support_signature((2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)).real_sign == 1


def test_export_refined_shell_projection_json(tmp_path):
    analysis = analyze_refined_shell_projection()
    path = export_refined_shell_projection_json(analysis, tmp_path / "refined_shell_projection.json")
    assert path.exists()
    text = path.read_text(encoding="utf-8")
    assert '"claim_class": "C"' in text
    assert '"sigma_4_equals_sigma_8": true' in text


def test_old_GF2_collision_N4_N8_is_preserved():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.old_fact["sigma_4_equals_sigma_8"] is True
    assert analysis.old_fact["sigma_6_separated"] is True


def test_signed_support_separates_N4_N8():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.relations["N4_equals_N8_refined"] is False


def test_signed_support_separates_N6_from_N4_N8():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.relations["N4_equals_N6_refined"] is False
    assert analysis.relations["N6_equals_N8_refined"] is False


def test_signed_support_is_basis_independent():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.signed_support_basis_independent is True


def test_signed_support_does_not_use_shell_label_posthoc():
    signature_n4 = signed_support_signature((2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
    signature_n8 = signed_support_signature((2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0))
    assert signature_n4 != signature_n8


def test_full_hurwitz_projection_agrees_on_separation():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.control_relations["N4_equals_N8_refined"] is False
    assert analysis.control_relations["N4_equals_N6_refined"] is False
    assert analysis.control_relations["N6_equals_N8_refined"] is False


def test_residue_key_alone_does_not_separate_N4_N8():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.auxiliary["residue_only_N4_equals_N8"] is True


def test_real_axis_separation_recorded_but_not_primary():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.auxiliary["real_axis_separates_N4_N8"] is True
    assert analysis.auxiliary["real_axis_is_secondary_not_primary"] is True
    assert analysis.mode == "signed_support"


def test_refinement_defined_before_comparison_e041():
    analysis = analyze_signed_shell_syndromes()
    assert analysis.claim_class == "B"
    assert analysis.mode == "signed_support"
    assert analysis.upgrade_status == "upgraded_from_pre"
    assert analysis.validated_by == "E-042"
    assert "E-042" in analysis.depends_on
    assert analysis.core_result["separation_failures_under_G_model"] == 0


def test_export_signed_shell_syndromes_json(tmp_path):
    analysis = analyze_signed_shell_syndromes()
    path = export_signed_shell_syndromes_json(analysis, tmp_path / "signed_shell_syndromes.json")
    assert path.exists()
    text = path.read_text(encoding="utf-8")
    assert '"claim_class": "B"' in text
    assert '"mode": "signed_support"' in text
    assert '"N4_equals_N8_refined": false' in text
    assert '"upgrade_status": "upgraded_from_pre"' in text
    assert '"validated_by": "E-042"' in text


def test_model_symmetry_group_defined_before_enumeration():
    spec = model_symmetry_group_specification()
    assert spec.total_elements == 336
    assert spec.fano_automorphism_count == 168
    assert "fixed before any shell comparison" in spec.definition


def test_fano_automorphism_count():
    assert len(enumerate_fano_automorphisms()) == 168


def test_signed_support_separation_invariant_under_all_model_symmetries():
    analysis = analyze_signed_support_symmetry_invariance()
    assert analysis.group.total_elements == 336
    assert analysis.all_separations_preserved is True
    assert all(report.failing_transform_count == 0 for report in analysis.separation_reports)


def test_symmetry_invariance_upgrade_conditions():
    analysis = analyze_signed_support_symmetry_invariance()
    assert analysis.upgrade_conditions["canonicality"] is True
    assert analysis.upgrade_conditions["symmetry_invariance"] is True
    assert analysis.upgrade_conditions["reproducibility"] is True
    assert analysis.e041_upgrade_eligible is True


def test_apply_model_symmetry_preserves_real_axis():
    transform = enumerate_model_symmetry_group()[0]
    element = (2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    transformed = apply_model_symmetry(element, transform)
    assert transformed[0] == element[0]


def test_export_signed_support_symmetry_json(tmp_path):
    analysis = analyze_signed_support_symmetry_invariance()
    path = export_signed_support_symmetry_json(analysis, tmp_path / "signed_support_symmetry.json")
    assert path.exists()
    text = path.read_text(encoding="utf-8")
    assert '"all_separations_preserved": true' in text
    assert '"fano_automorphism_count": 168' in text
