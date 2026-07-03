from kepler_hurwitz.coupled_shell_resonance import (
    COUPLED_OPERATOR_KEYS,
    SHELL_OPERATOR_KEYS,
    X0_RESONANCE_LEVELS,
    analyze_coupled_shell_resonance_graph,
    export_coupled_shell_resonance_json,
)


def test_coupled_shell_resonance_claim_metadata():
    analysis = analyze_coupled_shell_resonance_graph()
    assert analysis.claim_class == "C"
    assert analysis.upgrade_status == "pre"
    assert analysis.depends_on == ("E-036", "E-037", "E-041", "S8")
    assert "No astrophysical identification" in analysis.defensive_scope


def test_coupled_shell_resonance_operator_keys():
    analysis = analyze_coupled_shell_resonance_graph()
    assert list(analysis.operators) == list(SHELL_OPERATOR_KEYS)
    assert len(analysis.x0_levels) == len(X0_RESONANCE_LEVELS)
    assert set(analysis.coupled_operator_profiles) == set(COUPLED_OPERATOR_KEYS)


def test_single_operator_n6_bifurcation_nodes():
    analysis = analyze_coupled_shell_resonance_graph()
    nodes = analysis.graph_invariants["single_operator_bifurcation_nodes"]
    assert any(str(node).startswith("N6@") for node in nodes)


def test_coupled_profiles_have_graph_invariants():
    analysis = analyze_coupled_shell_resonance_graph()
    for profile in analysis.coupled_operator_profiles.values():
        invariants = profile["graph_invariants"]
        assert "fixed_points" in invariants
        assert "cycles" in invariants
        assert "pump_paths" in invariants
        assert len(profile["deterministic_edges"]) == len(X0_RESONANCE_LEVELS)


def test_export_coupled_shell_resonance_json(tmp_path):
    analysis = analyze_coupled_shell_resonance_graph()
    path = export_coupled_shell_resonance_json(analysis, tmp_path / "coupled_shell_resonance_graph.json")
    text = path.read_text(encoding="utf-8")
    assert '"claim_class": "C"' in text
    assert '"upgrade_status": "pre"' in text
    assert '"N4_N6_N8"' in text
    assert '"defensive_scope"' in text
