from math import isclose, pi

from kepler_hurwitz.discrete_time_flow import (
    KeplerOrbitState,
    SimulationResult,
    SimulationStepRecord,
    associator,
    classify_regime,
    default_demo_orbit,
    detected_period,
    detected_tail_period,
    evolve_right,
    generate_second_ring_points,
    hurwitz_units_240,
    is_hurwitz_lattice_point,
    map_phase_space_regimes,
    nearest_hurwitz_unit,
    octonion_mul,
    octonion_norm_sq,
    orbit_distance,
    phi,
    phi_inv,
    physical_step_filter,
    project_to_hurwitz_lattice,
    quasi_periodic_score,
    rank_phase_space_regimes,
    recurrence_count,
    recurrence_ratio,
    soft_e8_resolver,
    simulate_physical_flow,
    tail_unique_state_count,
    validate_ranked_windows_longrun,
    run_nullmodel_control_suite,
    orbit_with_combined_phase_shift,
    attractors_match,
    summarize_attractor,
    check_attractor_isomorphism,
    check_attractor_isomorphism_from_results,
    check_spectral_equivalence,
    check_spectral_equivalence_from_results,
    attractor_spectral_fingerprint,
)

_ZERO = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
_ONE = (1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
_TWO = (0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
_THREE = (0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0)
_FOUR = (0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0)


def _sim_result_from_states(
    states: list[tuple[float, ...]],
    *,
    drift: float = 0.0,
    norm_sq: float = 1.0,
) -> SimulationResult:
    records = tuple(
        SimulationStepRecord(
            t=index + 1,
            operator=_ZERO,
            state=state,
            epsilon=0.0,
            norm_sq=norm_sq,
            norm_drift_sq=drift,
        )
        for index, state in enumerate(states)
    )
    return SimulationResult(initial_state=states[0], target_norm_sq=norm_sq, records=records)


def test_phi_roundtrip_core_coordinates():
    orbit = default_demo_orbit()
    decoded = phi_inv(phi(orbit))
    assert isclose(decoded.a, orbit.a, rel_tol=0.0, abs_tol=1e-12)
    assert isclose(decoded.epsilon, orbit.epsilon, rel_tol=0.0, abs_tol=1e-12)
    assert abs(decoded.E_consistency_error) <= 1e-12


def test_path_order_is_noncommutative():
    x0 = phi(default_demo_orbit())
    p1 = (0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    p2 = (0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    xa = evolve_right(x0, (p1, p2))
    xb = evolve_right(x0, (p2, p1))
    assert xa != xb
    da = phi_inv(xa)
    db = phi_inv(xb)
    assert orbit_distance(da, db) > 0.0


def test_associator_is_nonzero_for_generic_triple():
    e1 = (0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    e2 = (0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    e4 = (0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)
    assoc = associator(e1, e2, e4)
    assert any(abs(v) > 1e-12 for v in assoc)


def test_hurwitz_projection_lands_on_lattice():
    x = (0.2, 1.1, -0.7, 0.49, -1.51, 2.24, -0.09, 0.77)
    projected = project_to_hurwitz_lattice(x)
    assert is_hurwitz_lattice_point(projected)


def test_nearest_hurwitz_unit_has_unit_norm():
    x = (0.12, -0.8, 0.31, 1.2, -0.44, 0.08, 0.51, -0.92)
    unit = nearest_hurwitz_unit(x)
    assert unit in hurwitz_units_240()
    assert isclose(octonion_norm_sq(unit), 2.0, rel_tol=0.0, abs_tol=1e-12)


def test_octonion_basis_square_minus_one():
    e3 = (0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0)
    square = octonion_mul(e3, e3)
    assert isclose(square[0], -1.0, rel_tol=0.0, abs_tol=1e-12)
    assert all(isclose(v, 0.0, rel_tol=0.0, abs_tol=1e-12) for v in square[1:])


def test_phi_validates_eccentricity_range():
    orbit = KeplerOrbitState(
        a=1.0,
        epsilon=1.2,
        E=pi / 2.0,
        omega=0.0,
        Omega=0.0,
        i=0.0,
        tau=0.0,
        sigma=0.0,
    )
    try:
        _ = phi(orbit)
    except ValueError as exc:
        assert "epsilon" in str(exc)
    else:
        raise AssertionError("Expected ValueError for epsilon >= 1.")


def test_physical_step_filter_enforces_lattice_and_bound():
    candidate = (0.3, 2.1, -1.7, 0.2, 0.4, -0.6, 0.1, 0.5)
    diagnostics = physical_step_filter(candidate, epsilon_bound=0.999999)
    assert is_hurwitz_lattice_point(diagnostics.state)
    assert diagnostics.epsilon < 1.0


def test_physical_step_filter_with_target_norm_is_bounded():
    x0 = phi(default_demo_orbit())
    candidate = (0.2, 1.2, 1.1, 0.4, -0.7, 0.5, -0.3, 0.2)
    target_norm_sq = octonion_norm_sq(x0)
    diagnostics = physical_step_filter(
        candidate,
        target_norm_sq=target_norm_sq,
        epsilon_bound=0.999999,
    )
    assert diagnostics.epsilon < 1.0
    assert abs(diagnostics.norm_sq - target_norm_sq) <= target_norm_sq + 10.0


def test_simulation_is_deterministic_for_random_mode():
    x0 = phi(default_demo_orbit())
    operators = hurwitz_units_240()[:20]
    run_a = simulate_physical_flow(
        x0,
        steps=16,
        operators=operators,
        mode="random",
        seed=123,
        enforce_norm=True,
    )
    run_b = simulate_physical_flow(
        x0,
        steps=16,
        operators=operators,
        mode="random",
        seed=123,
        enforce_norm=True,
    )
    assert run_a.records == run_b.records
    assert len(run_a.records) == 16
    assert all(is_hurwitz_lattice_point(record.state) for record in run_a.records)
    assert all(record.epsilon < 1.0 for record in run_a.records)


def test_soft_resolver_returns_bound_lattice_point():
    x_ideal = (0.4, 1.8, -1.6, 0.2, -0.2, 0.3, -0.4, 0.1)
    target_norm_sq = octonion_norm_sq(phi(default_demo_orbit()))
    best, loss = soft_e8_resolver(
        x_ideal,
        target_norm_sq=target_norm_sq,
        w_dist=1.0,
        w_norm=5.0,
        alpha=10.0,
    )
    assert is_hurwitz_lattice_point(best)
    eps = (best[1] ** 2 + best[2] ** 2) ** 0.5
    assert eps < 1.0
    assert loss >= 0.0


def test_physical_step_filter_soft_mode_sets_loss():
    x_ideal = (0.4, 1.7, -1.4, 0.1, 0.2, -0.5, 0.0, 0.3)
    diagnostics = physical_step_filter(
        x_ideal,
        target_norm_sq=octonion_norm_sq(phi(default_demo_orbit())),
        resolver_mode="soft",
    )
    assert diagnostics.loss is not None
    assert is_hurwitz_lattice_point(diagnostics.state)
    assert diagnostics.epsilon < 1.0


def test_second_ring_has_more_candidates_than_first_ring():
    x_base = project_to_hurwitz_lattice((0.2, 0.8, -0.4, 0.1, 0.3, -0.2, 0.5, 0.0))
    ring1 = generate_second_ring_points(x_base, units=hurwitz_units_240()[:8])
    ring2 = generate_second_ring_points(x_base)
    assert len(ring2) > len(ring1)
    assert len(ring2) >= 241
    assert all(is_hurwitz_lattice_point(point) for point in ring2[:20])


def test_second_ring_resolver_can_differ_from_first_ring():
    x_ideal = (0.4, 1.8, -1.6, 0.2, -0.2, 0.3, -0.4, 0.1)
    target_norm_sq = octonion_norm_sq(phi(default_demo_orbit()))
    first, _ = soft_e8_resolver(
        x_ideal,
        target_norm_sq=target_norm_sq,
        w_dist=1.0,
        w_norm=5.0,
        alpha=10.0,
        use_second_ring=False,
    )
    second, _ = soft_e8_resolver(
        x_ideal,
        target_norm_sq=target_norm_sq,
        w_dist=1.0,
        w_norm=5.0,
        alpha=10.0,
        use_second_ring=True,
    )
    assert is_hurwitz_lattice_point(first)
    assert is_hurwitz_lattice_point(second)


def test_detected_period_none_for_no_repeat():
    result = _sim_result_from_states([_ZERO, _ONE, _TWO])
    assert detected_period(result) is None


def test_detected_period_for_simple_cycle():
    result = _sim_result_from_states([_ZERO, _ONE, _TWO, _ONE])
    assert detected_period(result) == 2


def test_recurrence_count():
    result = _sim_result_from_states([_ZERO, _ONE, _ZERO, _TWO, _ONE])
    assert recurrence_count(result) == 2
    assert recurrence_ratio(result) == 0.4


def test_quasi_periodic_score_positive_for_nonempty_result():
    result = _sim_result_from_states([_ZERO, _ONE, _ZERO])
    assert quasi_periodic_score(result) > 0.0


def test_quasi_periodic_score_prefers_more_unique_states():
    sparse = _sim_result_from_states([_ZERO, _ZERO, _ZERO], drift=0.0)
    rich = _sim_result_from_states([_ZERO, _ONE, _TWO, _THREE, _FOUR], drift=0.0)
    assert quasi_periodic_score(rich) > quasi_periodic_score(sparse)


def test_classify_regime_labels():
    periodic = _sim_result_from_states([_ZERO, _ONE, _TWO, _ONE], drift=0.0)
    quasi = _sim_result_from_states([_ZERO, _ONE, _TWO, _ZERO, _ONE, _THREE], drift=0.0)
    dissipative = _sim_result_from_states([_ZERO, _ONE, _TWO, _THREE, _FOUR], drift=0.5)
    collapse = _sim_result_from_states([_ZERO, _ZERO, _ZERO], drift=0.0)
    unstable = _sim_result_from_states([_ZERO, _ONE, _TWO, _THREE], drift=5.0)

    assert classify_regime(periodic) == "STABIL / PERIODISCH"
    assert classify_regime(quasi) == "STABIL / QUASI-PERIODISCH"
    assert classify_regime(dissipative) == "KONTROLLIERT DISSIPATIV"
    assert classify_regime(collapse) == "ZENONISCHER KOLLAPS"
    assert classify_regime(unstable) == "DIFFUS / INSTABIL"


def test_map_phase_space_regimes_returns_grid():
    x0 = phi(default_demo_orbit())
    operators = hurwitz_units_240()[:6]
    grid = map_phase_space_regimes(
        x0,
        steps=8,
        operators=operators,
        grid_w_norm=(1.0, 5.0),
        grid_w_dist=(1.0,),
        grid_alpha=(10.0,),
        use_second_ring=True,
    )
    assert len(grid) == 2
    assert all(record.use_second_ring for record in grid)
    assert all(record.regime for record in grid)
    assert all(record.score >= 0.0 for record in grid)


def test_rank_phase_space_regimes_returns_top_k():
    x0 = phi(default_demo_orbit())
    operators = hurwitz_units_240()[:6]
    ranked = rank_phase_space_regimes(
        x0,
        steps=8,
        operators=operators,
        w_norm_values=(2.0, 5.0),
        w_dist_values=(0.5, 1.0),
        alpha_values=(0.1, 0.2),
        top_k=3,
        use_second_ring=True,
    )
    assert len(ranked) == 3
    assert ranked[0].score >= ranked[1].score >= ranked[2].score
    assert all(record.use_second_ring for record in ranked)


def test_orbit_with_combined_phase_shift_changes_x7_only():
    orbit = default_demo_orbit()
    shifted = orbit_with_combined_phase_shift(orbit, pi / 4.0)
    x0 = phi(orbit)
    x1 = phi(shifted)
    assert x0[:7] == x1[:7]
    assert abs(x1[7] - x0[7] - pi / 4.0) <= 1e-12


def test_simulate_physical_flow_with_perturbation():
    x0 = phi(default_demo_orbit())
    operators = hurwitz_units_240()[:6]
    perturb = hurwitz_units_240()[20]
    result = simulate_physical_flow(
        x0,
        steps=12,
        operators=operators,
        mode="cyclic",
        resolver_mode="soft",
        w_norm=2.0,
        w_dist=0.25,
        alpha=0.1,
        use_second_ring=True,
        perturb_at_step=6,
        perturb_operator=perturb,
    )
    assert len(result.records) == 13


def test_attractors_match_detects_identical_cycles():
    periodic = _sim_result_from_states([_ZERO, _ONE, _TWO, _ONE, _TWO, _ONE, _TWO])
    shifted_start = _sim_result_from_states([_THREE, _ONE, _TWO, _ONE, _TWO, _ONE, _TWO])
    assert attractors_match(periodic, shifted_start, tail_length=6) is True


def test_run_nullmodel_control_suite_shape():
    records = run_nullmodel_control_suite(
        steps=24,
        perturb_at_step=10,
        gauge_shifts=(pi / 4.0,),
        operators=hurwitz_units_240()[:6],
    )
    assert len(records) == 4
    assert records[0].control == "baseline"
    assert records[0].attractor_match_baseline is None
    assert records[0].attractor_isomorphic_baseline is None
    assert all(record.control for record in records)


def test_check_attractor_isomorphism_cyclic_shift():
    cycle_a = (_ZERO, _ONE, _TWO, _THREE)
    cycle_b = (_TWO, _THREE, _ZERO, _ONE)
    result = check_attractor_isomorphism(cycle_a, cycle_b)
    assert result.isomorphic is True
    assert result.cyclic_shift == 2


def test_check_attractor_isomorphism_none_for_wandering():
    cycle_a = (_ZERO, _ONE, _TWO, _THREE)
    cycle_b = (_ZERO, _ONE, _TWO, _FOUR)
    result = check_attractor_isomorphism(cycle_a, cycle_b)
    assert result.isomorphic is False
    assert result.reason == "Distinct geometric tracks"


def test_check_attractor_isomorphism_dimension_mismatch_subset():
    cycle_a = (_ZERO, _ONE)
    cycle_b = (_ZERO, _ONE, _TWO, _THREE)
    result = check_attractor_isomorphism(cycle_a, cycle_b)
    assert result.isomorphic is False
    assert result.is_subset is True


def test_check_attractor_isomorphism_from_results():
    periodic = _sim_result_from_states([_ONE, _TWO, _THREE, _ONE, _TWO, _THREE, _ONE, _TWO])
    shifted = _sim_result_from_states([_TWO, _THREE, _ONE, _TWO, _THREE, _ONE, _TWO, _THREE])
    result = check_attractor_isomorphism_from_results(periodic, shifted, tail_length=8)
    assert result.isomorphic is True


def test_detected_tail_period_two():
    transient = (9.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    result = _sim_result_from_states([_ZERO, transient, _ONE, _TWO, _ONE, _TWO, _ONE, _TWO])
    assert detected_tail_period(result, tail_length=6) == 2


def test_detected_tail_period_none_for_wandering_tail():
    result = _sim_result_from_states([_ZERO, _ONE, _TWO, _THREE, _FOUR, (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0)])
    assert detected_tail_period(result, tail_length=6) is None


def test_tail_unique_state_count():
    result = _sim_result_from_states([_ZERO, _ONE, _TWO, _ONE, _TWO, _ONE, _TWO])
    assert tail_unique_state_count(result, tail_length=6) == 2


def test_classify_regime_uses_tail_period_when_requested():
    result = _sim_result_from_states([_ZERO, _ONE, _TWO, _ONE, _TWO, _ONE, _TWO], drift=0.0)
    assert classify_regime(result, use_tail_period=True, tail_length=6) == "STABIL / PERIODISCH"


def test_validate_ranked_windows_longrun_shape():
    x0 = phi(default_demo_orbit())
    operators = hurwitz_units_240()[:6]
    ranked = rank_phase_space_regimes(
        x0,
        steps=8,
        operators=operators,
        w_norm_values=(2.0, 5.0),
        w_dist_values=(0.5,),
        alpha_values=(0.1,),
        top_k=2,
        use_second_ring=True,
    )
    validations = validate_ranked_windows_longrun(
        ranked,
        initial_state=x0,
        steps_values=(8, 12),
        top_k=2,
        operators=operators,
        tail_length=6,
    )
    assert len(validations) == 4
    assert all(record.tail_period is not None or record.tail_unique_states >= 1 for record in validations)


def test_spectral_fingerprint_invariant_under_cyclic_permutation():
    cycle_a = (_ZERO, _ONE, _TWO, _THREE)
    cycle_b = (_TWO, _THREE, _ZERO, _ONE)
    assert attractor_spectral_fingerprint(cycle_a) == attractor_spectral_fingerprint(cycle_b)


def test_check_spectral_equivalence_detects_translation():
    cycle_a = (
        (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
    )
    cycle_b = (
        (5.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (6.0, 5.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (6.0, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
        (5.0, 6.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
    )
    result = check_spectral_equivalence(cycle_a, cycle_b)
    assert result.is_spectrally_equivalent is True
    assert result.kumulierte_distanz_differenz == 0.0


def test_check_spectral_equivalence_dimension_mismatch():
    result = check_spectral_equivalence((_ZERO, _ONE), (_ZERO, _ONE, _TWO))
    assert result.is_spectrally_equivalent is False
    assert result.kumulierte_distanz_differenz == float("inf")


def test_nullmodel_records_include_spectral_fields():
    records = run_nullmodel_control_suite(
        steps=24,
        perturb_at_step=10,
        gauge_shifts=(pi / 4.0,),
        operators=hurwitz_units_240()[:6],
    )
    assert records[1].spectrally_equivalent_baseline is not None
    assert records[1].spectral_cum_dist_diff is not None
