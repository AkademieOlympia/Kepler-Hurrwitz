from __future__ import annotations

import json
from collections import Counter, defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, Sequence

from kepler_hurwitz.discrete_time_flow import (
    KeplerOrbitState,
    Octonion,
    PhysicalStepDiagnostics,
    SimulationResult,
    default_demo_orbit,
    hurwitz_units_240,
    is_hurwitz_lattice_point,
    octonion_mul,
    octonion_norm_sq,
    phi,
    phi_inv,
    physical_step_filter,
    project_to_hurwitz_lattice,
    simulate_physical_flow,
    tail_unique_state_count,
)

DEFAULT_TARGET_PRIME_NORMS: tuple[int, ...] = (3, 5, 7)
DEFAULT_LOG_SCALE_SHELLS: tuple[float, ...] = (-1.0, -0.5, 0.0, 0.5, 1.0)
MAX_LOG_SCALE_ABS: float = 4.0

# Verifizierte Hurwitz-Operatoren auf dem E8-Gitter (N(P) in {4,6,8}).
# Auf der ganzzahligen Hurwitz-Oktonion-Sphäre existieren die ungeraden
# Primnormen 3, 5, 7 nicht; die nächsten erreichbaren Schalen dienen als
# arithmetische Proxies fuer die angefragten Primzielnormen.
_SHELL_OPERATORS_BY_REQUESTED_NORM: dict[int, tuple[Octonion, int, str]] = {
    3: ((2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), 4, "shell_proxy_N4_for_3"),
    5: ((2.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0), 6, "shell_proxy_N6_for_5"),
    7: ((2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0), 8, "shell_proxy_N8_for_7"),
}


@dataclass(frozen=True)
class ArithmeticPrimeOperator:
    requested_norm: int
    actual_norm: int
    element: Octonion
    label: str
    is_shell_proxy: bool


@dataclass(frozen=True)
class PrimeTransitionRecord:
    step: int
    operator: ArithmeticPrimeOperator
    state_before: Octonion
    state_after: Octonion
    semi_major_before: float
    semi_major_after: float
    log_scale_before: float
    log_scale_after: float
    delta_log_scale: float
    norm_sq_before: float
    norm_sq_after: float
    epsilon_before: float
    epsilon_after: float


@dataclass(frozen=True)
class ScaleJumpDiagnostics:
    unique_delta_x0_count: int
    delta_x0_spectrum: tuple[float, ...]
    unique_x0_count: int
    x0_spectrum: tuple[float, ...]
    transition_pair_count: int


@dataclass(frozen=True)
class ArithmeticEvolutionResult:
    initial_state: Octonion
    operators: tuple[ArithmeticPrimeOperator, ...]
    records: tuple[PrimeTransitionRecord, ...]
    diagnostics: ScaleJumpDiagnostics


@dataclass(frozen=True)
class TransitionMatrixEntry:
    operator_label: str
    requested_norm: int
    actual_norm: int
    x0_from: float
    x0_to: float
    count: int
    row_probability: float


@dataclass(frozen=True)
class TransitionMatrixAnalysis:
    entries: tuple[TransitionMatrixEntry, ...]
    x0_states: tuple[float, ...]
    operator_labels: tuple[str, ...]
    total_transitions: int
    max_row_entropy: float
    min_row_entropy: float


@dataclass(frozen=True)
class RelaxationDiagnostics:
    tail_x0_period: int | None
    tail_unique_x0_count: int
    tail_unique_state_count: int
    x0_series: tuple[float, ...]


@dataclass(frozen=True)
class CompoundEvolutionRecord:
    prime_step: int
    operator: ArithmeticPrimeOperator
    x0_after_prime: float
    relaxation: RelaxationDiagnostics
    returns_to_periodic_x0: bool


@dataclass(frozen=True)
class CompoundEvolutionResult:
    prime_evolution: ArithmeticEvolutionResult
    relaxation_records: tuple[CompoundEvolutionRecord, ...]
    cascade_x0_spectrum: tuple[float, ...]


@dataclass(frozen=True)
class QuantizedEnergyLevel:
    x0: float
    semi_major_a: float
    tail_period: int | None
    tail_unique_x0: int | None
    prime_visits: int
    fixpoint_operators: tuple[str, ...]
    pump_targets: tuple[str, ...]
    bifurcation_operators: tuple[str, ...]
    stabilization_class: str


@dataclass(frozen=True)
class QuantizedEnergyLevelCatalog:
    a_0: float
    levels: tuple[QuantizedEnergyLevel, ...]
    periodic_recovery_ratio: float
    cascade_levels: int


def log_scale_from_state(state: Octonion, *, a_0: float = 1.0) -> float:
    _ = a_0
    return float(state[0])


def quantize_log_scale_to_shell(
    x0: float,
    *,
    shells: Sequence[float] = DEFAULT_LOG_SCALE_SHELLS,
) -> float:
    return min(shells, key=lambda shell: abs(shell - x0))


def stabilize_arithmetic_state(
    state: Octonion,
    *,
    shells: Sequence[float] = DEFAULT_LOG_SCALE_SHELLS,
    max_abs_x0: float = MAX_LOG_SCALE_ABS,
) -> Octonion:
    clamped_x0 = max(-max_abs_x0, min(max_abs_x0, state[0]))
    shell_x0 = quantize_log_scale_to_shell(clamped_x0, shells=shells)
    return project_to_hurwitz_lattice((shell_x0, *state[1:]))


def semi_major_from_state(state: Octonion, *, a_0: float = 1.0) -> float:
    return phi_inv(state, a_0=a_0).a


def epsilon_from_state(state: Octonion, *, a_0: float = 1.0) -> float:
    return phi_inv(state, a_0=a_0).epsilon


def default_arithmetic_prime_operators(
    *,
    target_norms: Sequence[int] = DEFAULT_TARGET_PRIME_NORMS,
) -> tuple[ArithmeticPrimeOperator, ...]:
    operators: list[ArithmeticPrimeOperator] = []
    for requested_norm in target_norms:
        if requested_norm not in _SHELL_OPERATORS_BY_REQUESTED_NORM:
            raise ValueError(f"No shell operator configured for requested norm {requested_norm}.")
        element, actual_norm, label = _SHELL_OPERATORS_BY_REQUESTED_NORM[requested_norm]
        if not is_hurwitz_lattice_point(element):
            raise RuntimeError(f"Configured operator for norm {requested_norm} is not on the Hurwitz lattice.")
        if abs(octonion_norm_sq(element) - float(actual_norm)) > 1e-9:
            raise RuntimeError(
                f"Configured operator for norm {requested_norm} has unexpected squared norm "
                f"{octonion_norm_sq(element)} != {actual_norm}."
            )
        operators.append(
            ArithmeticPrimeOperator(
                requested_norm=requested_norm,
                actual_norm=actual_norm,
                element=element,
                label=label,
                is_shell_proxy=True,
            )
        )
    return tuple(operators)


def apply_prime_transition(
    state: Octonion,
    operator: ArithmeticPrimeOperator,
    *,
    a_0: float = 1.0,
    epsilon_bound: float = 0.999999,
    resolver_mode: Literal["hard", "soft"] = "soft",
    w_dist: float = 0.25,
    w_norm: float = 2.0,
    alpha: float = 0.1,
    use_second_ring: bool = True,
) -> tuple[Octonion, PhysicalStepDiagnostics]:
    candidate = octonion_mul(state, operator.element)
    diagnostics = physical_step_filter(
        candidate,
        target_norm_sq=None,
        epsilon_bound=epsilon_bound,
        resolver_mode=resolver_mode,
        w_dist=w_dist,
        w_norm=w_norm,
        alpha=alpha,
        use_second_ring=use_second_ring,
    )
    stabilized = stabilize_arithmetic_state(diagnostics.state)
    return stabilized, diagnostics


def simulate_arithmetic_evolution(
    initial_state: Octonion,
    operators: Sequence[ArithmeticPrimeOperator],
    *,
    steps: int,
    mode: Literal["cyclic", "sequential"] = "cyclic",
    a_0: float = 1.0,
    epsilon_bound: float = 0.999999,
    resolver_mode: Literal["hard", "soft"] = "soft",
    w_dist: float = 0.25,
    w_norm: float = 2.0,
    alpha: float = 0.1,
    use_second_ring: bool = True,
    round_digits: int = 6,
) -> ArithmeticEvolutionResult:
    if steps < 0:
        raise ValueError("steps must be nonnegative.")
    if not operators:
        raise ValueError("operators must not be empty.")

    operator_tuple = tuple(operators)
    state = stabilize_arithmetic_state(initial_state)
    records: list[PrimeTransitionRecord] = []

    for step in range(1, steps + 1):
        if mode == "sequential":
            operator = operator_tuple[min(step - 1, len(operator_tuple) - 1)]
        else:
            operator = operator_tuple[(step - 1) % len(operator_tuple)]

        before = state
        a_before = semi_major_from_state(before, a_0=a_0)
        x0_before = before[0]
        eps_before = epsilon_from_state(before, a_0=a_0)
        norm_before = octonion_norm_sq(before)

        state, _ = apply_prime_transition(
            before,
            operator,
            a_0=a_0,
            epsilon_bound=epsilon_bound,
            resolver_mode=resolver_mode,
            w_dist=w_dist,
            w_norm=w_norm,
            alpha=alpha,
            use_second_ring=use_second_ring,
        )

        a_after = semi_major_from_state(state, a_0=a_0)
        x0_after = state[0]
        eps_after = epsilon_from_state(state, a_0=a_0)
        norm_after = octonion_norm_sq(state)

        records.append(
            PrimeTransitionRecord(
                step=step,
                operator=operator,
                state_before=before,
                state_after=state,
                semi_major_before=a_before,
                semi_major_after=a_after,
                log_scale_before=x0_before,
                log_scale_after=x0_after,
                delta_log_scale=x0_after - x0_before,
                norm_sq_before=norm_before,
                norm_sq_after=norm_after,
                epsilon_before=eps_before,
                epsilon_after=eps_after,
            )
        )

    diagnostics = analyze_scale_jump_spectrum(records, round_digits=round_digits)
    return ArithmeticEvolutionResult(
        initial_state=initial_state,
        operators=operator_tuple,
        records=tuple(records),
        diagnostics=diagnostics,
    )


def analyze_scale_jump_spectrum(
    records: Sequence[PrimeTransitionRecord],
    *,
    round_digits: int = 6,
) -> ScaleJumpDiagnostics:
    if not records:
        return ScaleJumpDiagnostics(
            unique_delta_x0_count=0,
            delta_x0_spectrum=(),
            unique_x0_count=0,
            x0_spectrum=(),
            transition_pair_count=0,
        )

    rounded_deltas = tuple(
        sorted(set(round(record.delta_log_scale, round_digits) for record in records))
    )
    rounded_x0 = tuple(
        sorted(
            set(
                round(value, round_digits)
                for record in records
                for value in (record.log_scale_before, record.log_scale_after)
            )
        )
    )
    pairs = {
        (
            round(record.log_scale_before, round_digits),
            round(record.log_scale_after, round_digits),
        )
        for record in records
    }
    return ScaleJumpDiagnostics(
        unique_delta_x0_count=len(rounded_deltas),
        delta_x0_spectrum=rounded_deltas,
        unique_x0_count=len(rounded_x0),
        x0_spectrum=rounded_x0,
        transition_pair_count=len(pairs),
    )


def run_default_arithmetic_evolution_scenarios(
    *,
    orbit: KeplerOrbitState | None = None,
    steps: int = 24,
    a_0: float = 1.0,
) -> tuple[ArithmeticEvolutionResult, ArithmeticEvolutionResult]:
    orbit = orbit or default_demo_orbit()
    initial_state = phi(orbit, a_0=a_0)
    operators = default_arithmetic_prime_operators()
    cyclic = simulate_arithmetic_evolution(
        initial_state,
        operators,
        steps=steps,
        mode="cyclic",
        a_0=a_0,
    )
    sequential = simulate_arithmetic_evolution(
        initial_state,
        operators,
        steps=min(steps, len(operators)),
        mode="sequential",
        a_0=a_0,
    )
    return cyclic, sequential


def format_arithmetic_evolution_summary(result: ArithmeticEvolutionResult) -> str:
    diag = result.diagnostics
    delta_text = ", ".join(f"{value:.6f}" for value in diag.delta_x0_spectrum[:12])
    x0_text = ", ".join(f"{value:.6f}" for value in diag.x0_spectrum[:12])
    lines = [
        "operator               | req_N | act_N | proxy | delta_x0 spectrum",
        "-" * 72,
    ]
    for operator in result.operators:
        proxy = "yes" if operator.is_shell_proxy else "no"
        lines.append(
            f"{operator.label:22s} | {operator.requested_norm:5d} | "
            f"{operator.actual_norm:5d} | {proxy:5s} |"
        )
    lines.extend(
        [
            "",
            f"unique_delta_x0={diag.unique_delta_x0_count}, "
            f"unique_x0={diag.unique_x0_count}, "
            f"transition_pairs={diag.transition_pair_count}",
            f"delta_x0 spectrum: [{delta_text}]",
            f"x0 spectrum: [{x0_text}]",
        ]
    )
    return "\n".join(lines)


def _round_x0(value: float, *, round_digits: int) -> float:
    return round(value, round_digits)


def build_transition_matrix_analysis(
    records: Sequence[PrimeTransitionRecord],
    *,
    round_digits: int = 6,
) -> TransitionMatrixAnalysis:
    if not records:
        return TransitionMatrixAnalysis(
            entries=(),
            x0_states=(),
            operator_labels=(),
            total_transitions=0,
            max_row_entropy=0.0,
            min_row_entropy=0.0,
        )

    grouped: Counter[tuple[str, int, int, float, float]] = Counter()
    for record in records:
        key = (
            record.operator.label,
            record.operator.requested_norm,
            record.operator.actual_norm,
            _round_x0(record.log_scale_before, round_digits=round_digits),
            _round_x0(record.log_scale_after, round_digits=round_digits),
        )
        grouped[key] += 1

    row_totals: Counter[tuple[str, float]] = Counter()
    for (label, _req, _act, x0_from, _x0_to), count in grouped.items():
        row_totals[(label, x0_from)] += count

    entries: list[TransitionMatrixEntry] = []
    row_entropies: list[float] = []
    for (label, req, act, x0_from, x0_to), count in sorted(grouped.items()):
        row_total = row_totals[(label, x0_from)]
        probability = count / row_total if row_total else 0.0
        entries.append(
            TransitionMatrixEntry(
                operator_label=label,
                requested_norm=req,
                actual_norm=act,
                x0_from=x0_from,
                x0_to=x0_to,
                count=count,
                row_probability=probability,
            )
        )

    entropy_by_row: dict[tuple[str, float], float] = defaultdict(float)
    for entry in entries:
        if entry.row_probability <= 0.0:
            continue
        key = (entry.operator_label, entry.x0_from)
        entropy_by_row[key] -= entry.row_probability * _safe_log2(entry.row_probability)

    entropies = list(entropy_by_row.values())
    x0_states = tuple(
        sorted(
            {
                value
                for entry in entries
                for value in (entry.x0_from, entry.x0_to)
            }
        )
    )
    operator_labels = tuple(dict.fromkeys(entry.operator_label for entry in entries))
    return TransitionMatrixAnalysis(
        entries=tuple(entries),
        x0_states=x0_states,
        operator_labels=operator_labels,
        total_transitions=len(records),
        max_row_entropy=max(entropies) if entropies else 0.0,
        min_row_entropy=min(entropies) if entropies else 0.0,
    )


def _safe_log2(value: float) -> float:
    import math

    return math.log2(value)


def format_transition_matrix_table(analysis: TransitionMatrixAnalysis) -> str:
    lines = [
        "operator               | x0_from   | x0_to     | count | P(to|from,op)",
        "-" * 72,
    ]
    for entry in analysis.entries:
        lines.append(
            f"{entry.operator_label:22s} | {entry.x0_from:9.5f} | {entry.x0_to:9.5f} | "
            f"{entry.count:5d} | {entry.row_probability:13.6f}"
        )
    lines.extend(
        [
            "",
            f"total_transitions={analysis.total_transitions}, "
            f"x0_states={len(analysis.x0_states)}, "
            f"row_entropy=[{analysis.min_row_entropy:.4f}, {analysis.max_row_entropy:.4f}]",
        ]
    )
    return "\n".join(lines)


def export_transition_matrix_json(
    analysis: TransitionMatrixAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "total_transitions": analysis.total_transitions,
        "x0_states": list(analysis.x0_states),
        "operator_labels": list(analysis.operator_labels),
        "max_row_entropy": analysis.max_row_entropy,
        "min_row_entropy": analysis.min_row_entropy,
        "entries": [
            {
                "operator_label": entry.operator_label,
                "requested_norm": entry.requested_norm,
                "actual_norm": entry.actual_norm,
                "x0_from": entry.x0_from,
                "x0_to": entry.x0_to,
                "count": entry.count,
                "row_probability": entry.row_probability,
            }
            for entry in analysis.entries
        ],
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def _x0_series_from_simulation(result: SimulationResult) -> tuple[float, ...]:
    return tuple(record.state[0] for record in result.records)


def _detected_x0_tail_period(
    x0_series: Sequence[float],
    *,
    tail_length: int = 16,
    tol: float = 1e-4,
) -> int | None:
    if len(x0_series) < 4:
        return None
    effective_tail = min(tail_length, len(x0_series))
    tail = x0_series[-effective_tail:]
    max_period = len(tail) // 2
    for period in range(1, max_period + 1):
        periodic = True
        for index in range(period, len(tail)):
            if abs(tail[index] - tail[index - period]) > tol:
                periodic = False
                break
        if periodic:
            return period
    return None


def relax_with_unit_flow(
    state: Octonion,
    *,
    steps: int,
    operators: Sequence[Octonion] | None = None,
    tail_length: int = 16,
    seed: int = 11,
) -> tuple[Octonion, RelaxationDiagnostics]:
    if steps <= 0:
        x0 = state[0]
        return state, RelaxationDiagnostics(
            tail_x0_period=None,
            tail_unique_x0_count=1,
            tail_unique_state_count=1,
            x0_series=(x0,),
        )

    flow = simulate_physical_flow(
        state,
        steps=steps,
        operators=operators or hurwitz_units_240()[:8],
        mode="cyclic",
        seed=seed,
        enforce_norm=False,
        resolver_mode="soft",
        w_dist=0.25,
        w_norm=2.0,
        alpha=0.1,
        use_second_ring=True,
    )
    x0_series = _x0_series_from_simulation(flow)
    effective_tail = min(tail_length, len(x0_series))
    tail = x0_series[-effective_tail:]
    return flow.records[-1].state, RelaxationDiagnostics(
        tail_x0_period=_detected_x0_tail_period(x0_series, tail_length=effective_tail),
        tail_unique_x0_count=len(set(round(value, 6) for value in tail)),
        tail_unique_state_count=tail_unique_state_count(flow, tail_length=effective_tail),
        x0_series=x0_series,
    )


def simulate_compound_arithmetic_evolution(
    initial_state: Octonion,
    operators: Sequence[ArithmeticPrimeOperator],
    *,
    prime_steps: int,
    relaxation_steps: int = 16,
    mode: Literal["cyclic", "sequential"] = "cyclic",
    a_0: float = 1.0,
) -> CompoundEvolutionResult:
    prime_evolution = simulate_arithmetic_evolution(
        initial_state,
        operators,
        steps=prime_steps,
        mode=mode,
        a_0=a_0,
    )
    relaxation_records: list[CompoundEvolutionRecord] = []
    cascade_x0: list[float] = []

    for record in prime_evolution.records:
        _, relaxation = relax_with_unit_flow(
            record.state_after,
            steps=relaxation_steps,
        )
        returns = relaxation.tail_x0_period is not None and relaxation.tail_unique_x0_count <= 3
        relaxation_records.append(
            CompoundEvolutionRecord(
                prime_step=record.step,
                operator=record.operator,
                x0_after_prime=record.log_scale_after,
                relaxation=relaxation,
                returns_to_periodic_x0=returns,
            )
        )
        cascade_x0.append(record.log_scale_after)
        cascade_x0.extend(relaxation.x0_series)

    return CompoundEvolutionResult(
        prime_evolution=prime_evolution,
        relaxation_records=tuple(relaxation_records),
        cascade_x0_spectrum=tuple(sorted(set(round(value, 6) for value in cascade_x0))),
    )


def format_compound_evolution_summary(result: CompoundEvolutionResult) -> str:
    lines = [
        "prime_step | operator               | x0_after | x0_period | unique_x0 | periodic",
        "-" * 78,
    ]
    periodic_count = 0
    for record in result.relaxation_records:
        period = "-" if record.relaxation.tail_x0_period is None else str(record.relaxation.tail_x0_period)
        periodic = "yes" if record.returns_to_periodic_x0 else "no"
        if record.returns_to_periodic_x0:
            periodic_count += 1
        lines.append(
            f"{record.prime_step:9d} | {record.operator.label:22s} | "
            f"{record.x0_after_prime:8.5f} | {period:>9} | "
            f"{record.relaxation.tail_unique_x0_count:9d} | {periodic:8s}"
        )
    lines.extend(
        [
            "",
            f"periodic_recovery={periodic_count}/{len(result.relaxation_records)}, "
            f"cascade_x0_states={len(result.cascade_x0_spectrum)}",
            f"cascade_x0 spectrum: [{', '.join(f'{v:.5f}' for v in result.cascade_x0_spectrum[:12])}]",
        ]
    )
    return "\n".join(lines)


def catalog_quantized_energy_levels(
    compound_result: CompoundEvolutionResult,
    matrix_analysis: TransitionMatrixAnalysis,
    *,
    a_0: float = 1.0,
    round_digits: int = 6,
) -> QuantizedEnergyLevelCatalog:
    import math

    visits: Counter[float] = Counter()
    tail_periods: dict[float, set[int | None]] = defaultdict(set)
    tail_unique: dict[float, set[int]] = defaultdict(set)
    for record in compound_result.relaxation_records:
        key = _round_x0(record.x0_after_prime, round_digits=round_digits)
        visits[key] += 1
        tail_periods[key].add(record.relaxation.tail_x0_period)
        tail_unique[key].add(record.relaxation.tail_unique_x0_count)

    rows_by_from: dict[tuple[str, float], list[TransitionMatrixEntry]] = defaultdict(list)
    for entry in matrix_analysis.entries:
        rows_by_from[(entry.operator_label, entry.x0_from)].append(entry)

    levels: list[QuantizedEnergyLevel] = []
    for x0 in compound_result.cascade_x0_spectrum:
        fixpoints: list[str] = []
        pumps: list[str] = []
        bifurcations: list[str] = []
        for (label, x0_from), entries in rows_by_from.items():
            if x0_from != x0:
                continue
            if len(entries) == 1 and entries[0].x0_to == x0_from:
                fixpoints.append(f"$N={entries[0].actual_norm}$")
            elif len(entries) == 1 and entries[0].row_probability == 1.0:
                pumps.append(f"$N={entries[0].actual_norm}\\!:\\,{x0_from}\\to{entries[0].x0_to}$")
            elif len(entries) >= 2 and max(entry.row_probability for entry in entries) == 0.5:
                bifurcations.append(f"$N={entries[0].actual_norm}$")

        periods = tail_periods.get(x0, set())
        period_value = next((p for p in sorted(periods) if p is not None), None)
        unique_values = tail_unique.get(x0, set())
        unique_value = max(unique_values) if unique_values else None

        if fixpoints and not pumps and not bifurcations:
            stabilization = "Fixpunkt"
        elif bifurcations:
            stabilization = "Bifurkation"
        elif pumps:
            stabilization = "Pumpen"
        elif x0 == 0.0:
            stabilization = "Ground shell"
        else:
            stabilization = "Transitiv"

        levels.append(
            QuantizedEnergyLevel(
                x0=x0,
                semi_major_a=a_0 * math.exp(x0),
                tail_period=period_value,
                tail_unique_x0=unique_value,
                prime_visits=visits.get(x0, 0),
                fixpoint_operators=tuple(fixpoints),
                pump_targets=tuple(pumps),
                bifurcation_operators=tuple(bifurcations),
                stabilization_class=stabilization,
            )
        )

    periodic_count = sum(
        1 for record in compound_result.relaxation_records if record.returns_to_periodic_x0
    )
    total = len(compound_result.relaxation_records) or 1
    return QuantizedEnergyLevelCatalog(
        a_0=a_0,
        levels=tuple(levels),
        periodic_recovery_ratio=periodic_count / total,
        cascade_levels=len(compound_result.cascade_x0_spectrum),
    )


def render_energy_levels_latex_table(catalog: QuantizedEnergyLevelCatalog) -> str:
    def _cell(values: tuple[str, ...]) -> str:
        if not values:
            return "---"
        return ", ".join(values)

    lines = [
        "% Auto-generated by kepler_hurwitz.arithmetic_evolution (E-036)",
        "% Evidence: docs/energiedoku_exports/arithmetic_transition_matrix.json",
        "\\begin{table}[htbp]",
        "\\centering",
        f"\\caption{{Sechs quantisierte Energieschalen ($a_0={catalog.a_0}$, "
        f"periodic recovery={catalog.periodic_recovery_ratio * 100:.0f}\\%, E-036).}}",
        "\\label{tab:quantized-energy-levels}",
        "\\begin{tabular}{r r r c c l}",
        "\\toprule",
        "$x_0=\\log(a/a_0)$ & $a/a_0$ & Tail-$T$ & $|x_0|_{\\mathrm{tail}}$ & Klasse & Stabilisierung \\\\",
        "\\midrule",
    ]
    for level in catalog.levels:
        period = "-" if level.tail_period is None else str(level.tail_period)
        unique = "-" if level.tail_unique_x0 is None else str(level.tail_unique_x0)
        stabil = _cell(level.fixpoint_operators + level.pump_targets + level.bifurcation_operators)
        lines.append(
            f"${level.x0:.1f}$ & ${level.semi_major_a:.5f}$ & {period} & {unique} & "
            f"{level.stabilization_class} & {stabil} \\\\"
        )
    lines.extend(
        [
            "\\bottomrule",
            "\\end{tabular}",
            "\\end{table}",
        ]
    )
    return "\n".join(lines)


def export_energy_levels_latex_table(
    catalog: QuantizedEnergyLevelCatalog,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text(render_energy_levels_latex_table(catalog), encoding="utf-8")
    return destination
