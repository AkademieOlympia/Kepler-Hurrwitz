from math import isclose

from kepler_hurwitz.arithmetic_evolution import (
    analyze_scale_jump_spectrum,
    apply_prime_transition,
    build_transition_matrix_analysis,
    catalog_quantized_energy_levels,
    export_energy_levels_latex_table,
    render_energy_levels_latex_table,
    default_arithmetic_prime_operators,
    run_default_arithmetic_evolution_scenarios,
    simulate_arithmetic_evolution,
    simulate_compound_arithmetic_evolution,
)
from kepler_hurwitz.discrete_time_flow import default_demo_orbit, is_hurwitz_lattice_point, octonion_norm_sq, phi


def test_default_arithmetic_prime_operators_are_hurwitz_shell_proxies():
    operators = default_arithmetic_prime_operators()
    assert len(operators) == 3
    assert all(operator.is_shell_proxy for operator in operators)
    for operator in operators:
        assert is_hurwitz_lattice_point(operator.element)
        assert isclose(octonion_norm_sq(operator.element), float(operator.actual_norm), rel_tol=0.0, abs_tol=1e-9)


def test_apply_prime_transition_changes_log_scale():
    initial_state = phi(default_demo_orbit())
    operator = default_arithmetic_prime_operators()[0]
    after, _ = apply_prime_transition(initial_state, operator)
    assert after != initial_state
    assert after[0] != initial_state[0]


def test_simulate_arithmetic_evolution_reports_scale_jumps():
    initial_state = phi(default_demo_orbit())
    result = simulate_arithmetic_evolution(
        initial_state,
        default_arithmetic_prime_operators(),
        steps=12,
        mode="cyclic",
    )
    assert len(result.records) == 12
    assert result.diagnostics.unique_delta_x0_count >= 1
    assert result.diagnostics.unique_x0_count >= 2


def test_analyze_scale_jump_spectrum_on_records():
    cyclic, _ = run_default_arithmetic_evolution_scenarios(steps=8)
    diagnostics = analyze_scale_jump_spectrum(cyclic.records)
    assert diagnostics.transition_pair_count >= 1
    assert diagnostics.delta_x0_spectrum


def test_build_transition_matrix_analysis_row_probabilities_sum_to_one():
    cyclic, _ = run_default_arithmetic_evolution_scenarios(steps=12)
    analysis = build_transition_matrix_analysis(cyclic.records)
    assert analysis.total_transitions == 12
    row_sums: dict[tuple[str, float], float] = {}
    for entry in analysis.entries:
        key = (entry.operator_label, entry.x0_from)
        row_sums[key] = row_sums.get(key, 0.0) + entry.row_probability
    for total in row_sums.values():
        assert abs(total - 1.0) < 1e-9


def test_simulate_compound_arithmetic_evolution_runs():
    initial_state = phi(default_demo_orbit())
    result = simulate_compound_arithmetic_evolution(
        initial_state,
        default_arithmetic_prime_operators(),
        prime_steps=6,
        relaxation_steps=8,
    )
    assert len(result.relaxation_records) == 6
    assert result.cascade_x0_spectrum


def test_export_energy_levels_latex_table(tmp_path):
    cyclic, _ = run_default_arithmetic_evolution_scenarios(steps=12)
    compound = simulate_compound_arithmetic_evolution(
        phi(default_demo_orbit()),
        default_arithmetic_prime_operators(),
        prime_steps=12,
        relaxation_steps=8,
    )
    catalog = catalog_quantized_energy_levels(
        compound,
        build_transition_matrix_analysis(cyclic.records),
    )
    tex_path = export_energy_levels_latex_table(catalog, tmp_path / "levels.tex")
    text = tex_path.read_text(encoding="utf-8")
    assert "\\begin{table}" in text
    assert len(catalog.levels) == 6
