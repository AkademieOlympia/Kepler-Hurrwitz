from kepler_hurwitz.metacommutation import classify_shell_operator_metacommutation
from kepler_hurwitz.qec_bridge import (
    FIVE_QUBIT_GENERATORS,
    analyze_shell_five_qubit_commutation_profile,
    commutation_signum_between_symplectic,
    dyadic_root_to_symplectic,
    generate_five_qubit_stabilizers,
    map_dyadic_to_stabilizers,
    multiply_commuting_pauli_strings,
    pauli_string_to_symplectic,
    summarize_five_qubit_stabilizer_bridge,
    symplectic_inner_product,
    verify_five_qubit_stabilizer_commutation,
)
from kepler_hurwitz.metacommutation import enumerate_dyadic_norm2_integer_roots


def test_five_qubit_generator_strings():
    assert FIVE_QUBIT_GENERATORS == ("XZZXI", "IXZZX", "XIXZZ", "ZXIXZ")


def test_five_qubit_stabilizer_count_and_commutation():
    stabilizers = generate_five_qubit_stabilizers()
    assert len(stabilizers) == 15
    assert verify_five_qubit_stabilizer_commutation()
    assert all(len(item) == 5 for item in stabilizers)


def test_generator_subset_closure():
    product = FIVE_QUBIT_GENERATORS[0]
    for generator in FIVE_QUBIT_GENERATORS[1:]:
        product = multiply_commuting_pauli_strings(product, generator)
    assert product in generate_five_qubit_stabilizers()


def test_dyadic_to_stabilizer_mapping_shape():
    roots = enumerate_dyadic_norm2_integer_roots()
    matches = map_dyadic_to_stabilizers(roots)
    assert len(matches) == 112 * 15
    assert all(match.commutation_signum in (1, -1) for match in matches)
    assert all(match.is_code_space_projector == (match.commutation_signum == 1) for match in matches)


def test_bridge_summary_counts():
    summary = summarize_five_qubit_stabilizer_bridge()
    assert summary.dyadic_root_count == 112
    assert summary.stabilizer_count == 15
    assert summary.match_count == 1680
    assert summary.commuting_matches + summary.anticommuting_matches == summary.match_count
    assert 0.0 < summary.code_space_projector_ratio < 1.0
    assert summary.unique_dyadic_symplectic_classes > 1


def test_shell_profile_covers_all_proxies_with_distinct_encodings():
    profile = analyze_shell_five_qubit_commutation_profile()
    assert set(profile) == {"N=4", "N=6", "N=8"}
    symplectic_encodings = {tuple(values["symplectic_encoding"]) for values in profile.values()}
    assert len(symplectic_encodings) == 3
    ratios = [float(values["commuting_stabilizer_ratio"]) for values in profile.values()]
    assert len(set(ratios)) == 1
    assert ratios[0] == 7 / 15

    shell_operators = [
        (2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (2.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0),
        (2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
    ]
    metacom = classify_shell_operator_metacommutation(shell_operators)
    assert metacom["shell_operator_1"]["associative_ratio"] < metacom["shell_operator_0"]["associative_ratio"]


def test_symplectic_inner_product_for_first_generator_pair():
    left = pauli_string_to_symplectic("XZZXI")
    right = pauli_string_to_symplectic("IXZZX")
    assert symplectic_inner_product(left, right) == 0
    assert commutation_signum_between_symplectic(left, right) == 1


def test_dyadic_root_symplectic_projection_is_deterministic():
    root = enumerate_dyadic_norm2_integer_roots()[0]
    assert dyadic_root_to_symplectic(root) == dyadic_root_to_symplectic(root)
