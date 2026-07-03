from __future__ import annotations

from dataclasses import dataclass
from math import log, pi, sin

from kepler_hurwitz.discrete_time_flow import (
    KeplerOrbitState,
    Octonion,
    SimulationResult,
    default_demo_orbit,
    hurwitz_units_240,
    orbit_with_combined_phase_shift,
    phi,
    phi_inv,
    simulate_physical_flow,
    wrap_angle,
)


@dataclass(frozen=True)
class KeplerAnomalySnapshot:
    a: float
    epsilon: float
    E: float
    M: float
    consistency_error: float


@dataclass(frozen=True)
class KeplerTimeDiagnostics:
    unique_delta_M_count: int
    delta_M_variance: float
    M_tail_period: int | None
    kepler_consistency_max_error: float
    delta_M_spectrum: tuple[float, ...]


@dataclass(frozen=True)
class KeplerTimeBridgeRecord:
    control_name: str
    diagnostics: KeplerTimeDiagnostics
    raw_M_series: tuple[float, ...]
    raw_delta_M_series: tuple[float, ...]
    raw_log_scale_series: tuple[float, ...]


def mean_anomaly(E: float, epsilon: float) -> float:
    return wrap_angle(E - epsilon * sin(E))


def calculate_kepler_anomalies(state: Octonion, *, a_0: float = 1.0) -> KeplerAnomalySnapshot:
    decoded = phi_inv(state, a_0=a_0)
    M = mean_anomaly(decoded.E, decoded.epsilon)
    return KeplerAnomalySnapshot(
        a=decoded.a,
        epsilon=decoded.epsilon,
        E=decoded.E,
        M=M,
        consistency_error=decoded.E_consistency_error,
    )


def _detected_float_tail_period(values: tuple[float, ...], *, tol: float = 1e-4) -> int | None:
    if len(values) < 4:
        return None
    max_period = len(values) // 2
    for period in range(1, max_period + 1):
        periodic = True
        for index in range(period, len(values)):
            if abs(values[index] - values[index - period]) > tol:
                periodic = False
                break
        if periodic:
            return period
    return None


def analyze_kepler_time_ladder(
    simulation_result: SimulationResult,
    *,
    tail_length: int = 64,
    delta_round_digits: int = 5,
    a_0: float = 1.0,
) -> KeplerTimeDiagnostics:
    records = simulation_result.records
    if not records:
        return KeplerTimeDiagnostics(
            unique_delta_M_count=0,
            delta_M_variance=0.0,
            M_tail_period=None,
            kepler_consistency_max_error=0.0,
            delta_M_spectrum=(),
        )

    effective_tail_length = min(tail_length, len(records))
    tail_records = records[-effective_tail_length:]
    anomalies = [calculate_kepler_anomalies(record.state, a_0=a_0) for record in tail_records]
    m_series = tuple(snapshot.M for snapshot in anomalies)
    errors = [snapshot.consistency_error for snapshot in anomalies]

    delta_m_series: list[float] = []
    for index in range(len(m_series) - 1):
        delta_m_series.append(wrap_angle(m_series[index + 1] - m_series[index]))

    rounded_deltas = tuple(round(value, delta_round_digits) for value in delta_m_series)
    spectrum = tuple(sorted(set(rounded_deltas)))

    if delta_m_series:
        mean_delta = sum(delta_m_series) / len(delta_m_series)
        variance = sum((value - mean_delta) ** 2 for value in delta_m_series) / len(delta_m_series)
    else:
        variance = 0.0

    m_period = _detected_float_tail_period(m_series)

    return KeplerTimeDiagnostics(
        unique_delta_M_count=len(spectrum),
        delta_M_variance=variance,
        M_tail_period=m_period,
        kepler_consistency_max_error=max(errors) if errors else 0.0,
        delta_M_spectrum=spectrum,
    )


def build_kepler_time_bridge_record(
    control_name: str,
    simulation_result: SimulationResult,
    *,
    tail_length: int = 64,
    a_0: float = 1.0,
) -> KeplerTimeBridgeRecord:
    records = simulation_result.records
    effective_tail_length = min(tail_length, len(records)) if records else 0
    tail_records = records[-effective_tail_length:] if records else []

    anomalies = [calculate_kepler_anomalies(record.state, a_0=a_0) for record in tail_records]
    m_series = tuple(snapshot.M for snapshot in anomalies)
    log_scale_series = tuple(log(snapshot.a / a_0) for snapshot in anomalies)
    delta_m_series: list[float] = []
    for index in range(len(m_series) - 1):
        delta_m_series.append(wrap_angle(m_series[index + 1] - m_series[index]))

    diagnostics = analyze_kepler_time_ladder(
        simulation_result,
        tail_length=tail_length,
        a_0=a_0,
    )
    return KeplerTimeBridgeRecord(
        control_name=control_name,
        diagnostics=diagnostics,
        raw_M_series=m_series,
        raw_delta_M_series=tuple(delta_m_series),
        raw_log_scale_series=log_scale_series,
    )


def run_kepler_time_bridge_scenarios(
    *,
    orbit: KeplerOrbitState | None = None,
    steps: int = 500,
    operators: tuple[Octonion, ...] | None = None,
    w_norm: float = 2.0,
    w_dist: float = 0.25,
    alpha: float = 0.1,
    use_second_ring: bool = True,
    perturb_at_step: int = 100,
    random_seed: int = 11,
    tail_length: int = 64,
    a_0: float = 1.0,
) -> tuple[KeplerTimeBridgeRecord, ...]:
    orbit = orbit or default_demo_orbit()
    initial_state = phi(orbit, a_0=a_0)
    if operators is None:
        operators = tuple(hurwitz_units_240()[:8])

    operator_set = set(operators)
    perturb_operator = hurwitz_units_240()[0]
    for unit in hurwitz_units_240():
        if unit not in operator_set:
            perturb_operator = unit
            break

    flow_kwargs = {
        "steps": steps,
        "operators": operators,
        "enforce_norm": True,
        "epsilon_bound": 0.999999,
        "resolver_mode": "soft",
        "w_dist": w_dist,
        "w_norm": w_norm,
        "alpha": alpha,
        "use_second_ring": use_second_ring,
    }

    baseline = simulate_physical_flow(initial_state, mode="cyclic", seed=random_seed, **flow_kwargs)
    random_result = simulate_physical_flow(
        initial_state,
        mode="random",
        seed=random_seed,
        **flow_kwargs,
    )
    gauge_pi4 = simulate_physical_flow(
        phi(orbit_with_combined_phase_shift(orbit, pi / 4.0), a_0=a_0),
        mode="cyclic",
        seed=random_seed,
        **flow_kwargs,
    )
    gauge_pi2 = simulate_physical_flow(
        phi(orbit_with_combined_phase_shift(orbit, pi / 2.0), a_0=a_0),
        mode="cyclic",
        seed=random_seed,
        **flow_kwargs,
    )
    perturbation = simulate_physical_flow(
        initial_state,
        mode="cyclic",
        seed=random_seed,
        perturb_at_step=perturb_at_step,
        perturb_operator=perturb_operator,
        **flow_kwargs,
    )

    return (
        build_kepler_time_bridge_record("baseline_cyclic", baseline, tail_length=tail_length, a_0=a_0),
        build_kepler_time_bridge_record("random_chain", random_result, tail_length=tail_length, a_0=a_0),
        build_kepler_time_bridge_record("gauge_pi_over_4", gauge_pi4, tail_length=tail_length, a_0=a_0),
        build_kepler_time_bridge_record("gauge_pi_over_2", gauge_pi2, tail_length=tail_length, a_0=a_0),
        build_kepler_time_bridge_record("perturbation_at_100", perturbation, tail_length=tail_length, a_0=a_0),
    )
