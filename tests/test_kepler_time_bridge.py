from math import isclose

from kepler_hurwitz.discrete_time_flow import (
    default_demo_orbit,
    hurwitz_units_240,
    phi,
    simulate_physical_flow,
)
from kepler_hurwitz.kepler_time_bridge import (
    analyze_kepler_time_ladder,
    build_kepler_time_bridge_record,
    calculate_kepler_anomalies,
    mean_anomaly,
    run_kepler_time_bridge_scenarios,
)


def test_mean_anomaly_at_zero():
    assert isclose(mean_anomaly(0.0, 0.0), 0.0, abs_tol=1e-12)


def test_calculate_kepler_anomalies_roundtrip():
    orbit = default_demo_orbit()
    snapshot = calculate_kepler_anomalies(phi(orbit))
    assert isclose(snapshot.epsilon, orbit.epsilon, rel_tol=0.0, abs_tol=1e-12)
    assert snapshot.consistency_error <= 1e-12


def test_analyze_kepler_time_ladder_on_periodic_simulation():
    x0 = phi(default_demo_orbit())
    result = simulate_physical_flow(
        x0,
        steps=32,
        operators=hurwitz_units_240()[:8],
        mode="cyclic",
        resolver_mode="soft",
        w_norm=2.0,
        w_dist=0.25,
        alpha=0.1,
        use_second_ring=True,
    )
    diagnostics = analyze_kepler_time_ladder(result, tail_length=32)
    assert diagnostics.unique_delta_M_count >= 1
    assert diagnostics.kepler_consistency_max_error >= 0.0


def test_build_kepler_time_bridge_record_shape():
    x0 = phi(default_demo_orbit())
    result = simulate_physical_flow(
        x0,
        steps=16,
        operators=hurwitz_units_240()[:6],
        mode="cyclic",
        resolver_mode="soft",
        use_second_ring=True,
    )
    record = build_kepler_time_bridge_record("test", result, tail_length=16)
    assert record.control_name == "test"
    assert len(record.raw_M_series) == 16
    assert len(record.raw_delta_M_series) == 15
    assert len(record.raw_log_scale_series) == 16


def test_run_kepler_time_bridge_scenarios_returns_five_records():
    records = run_kepler_time_bridge_scenarios(
        steps=24,
        perturb_at_step=10,
        tail_length=16,
    )
    assert len(records) == 5
    assert records[0].control_name == "baseline_cyclic"
