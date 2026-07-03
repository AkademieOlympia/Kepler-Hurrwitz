from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Literal, Sequence

from kepler_hurwitz.arithmetic_evolution import (
    ArithmeticPrimeOperator,
    TransitionMatrixAnalysis,
    TransitionMatrixEntry,
    apply_prime_transition,
    build_transition_matrix_analysis,
    default_arithmetic_prime_operators,
    run_default_arithmetic_evolution_scenarios,
    stabilize_arithmetic_state,
)
from kepler_hurwitz.discrete_time_flow import Octonion, default_demo_orbit, phi

E043_DEFENSIVE_SCOPE = (
    "No astrophysical identification; finite coupled-shell dynamics only."
)

SHELL_OPERATOR_KEYS: tuple[str, ...] = ("N4", "N6", "N8")
COUPLED_OPERATOR_KEYS: tuple[str, ...] = ("N4_N6", "N4_N8", "N6_N8", "N4_N6_N8")

X0_RESONANCE_LEVELS: tuple[float, ...] = (-2.0, -1.0, 0.0, 0.5, 1.0, 2.0)

_OPERATOR_KEY_TO_NORM: dict[str, int] = {"N4": 4, "N6": 6, "N8": 8}

_COUPLED_KEY_TO_SEQUENCE: dict[str, tuple[str, ...]] = {
    "N4_N6": ("N4", "N6"),
    "N4_N8": ("N4", "N8"),
    "N6_N8": ("N6", "N8"),
    "N4_N6_N8": ("N4", "N6", "N8"),
}


@dataclass(frozen=True)
class CoupledShellResonanceAnalysis:
    claim_class: Literal["C"]
    upgrade_status: Literal["pre"]
    depends_on: tuple[str, ...]
    operators: tuple[str, ...]
    x0_levels: tuple[float, ...]
    single_operator_profiles: dict[str, object]
    coupled_operator_profiles: dict[str, object]
    graph_invariants: dict[str, object]
    defensive_scope: str
    methodological_note: str


def _operators_by_key() -> dict[str, ArithmeticPrimeOperator]:
    by_norm = {operator.actual_norm: operator for operator in default_arithmetic_prime_operators()}
    return {key: by_norm[_OPERATOR_KEY_TO_NORM[key]] for key in SHELL_OPERATOR_KEYS}


def _template_state() -> Octonion:
    return stabilize_arithmetic_state(phi(default_demo_orbit()))


def _state_at_x0(x0: float, *, template: Octonion) -> Octonion:
    return stabilize_arithmetic_state((x0, *template[1:]))


def _round_x0(value: float, *, round_digits: int = 6) -> float:
    return round(value, round_digits)


def _apply_operator_sequence(
    state: Octonion,
    operator_keys: Sequence[str],
    *,
    operators_by_key: dict[str, ArithmeticPrimeOperator],
) -> float:
    current = state
    for key in operator_keys:
        current, _ = apply_prime_transition(current, operators_by_key[key])
    return _round_x0(current[0])


def _classify_row(
    entries: Sequence[TransitionMatrixEntry],
    *,
    x0_from: float,
) -> str:
    if not entries:
        return "unvisited"
    if len(entries) == 1 and entries[0].x0_to == x0_from:
        return "fixpoint"
    if len(entries) == 1 and entries[0].row_probability == 1.0:
        return "pump"
    if len(entries) >= 2 and max(entry.row_probability for entry in entries) == 0.5:
        return "bifurcation"
    if len({entry.x0_to for entry in entries}) > 1:
        return "bifurcation"
    return "transitive"


def _build_single_operator_profile(
    operator_key: str,
    operator: ArithmeticPrimeOperator,
    matrix: TransitionMatrixAnalysis,
    *,
    round_digits: int = 6,
) -> dict[str, object]:
    rows: dict[float, list[dict[str, object]]] = {}
    classifications: dict[str, str] = {}
    for x0 in X0_RESONANCE_LEVELS:
        row_entries = [
            {
                "x0_from": entry.x0_from,
                "x0_to": entry.x0_to,
                "probability": entry.row_probability,
                "count": entry.count,
            }
            for entry in matrix.entries
            if entry.operator_label == operator.label
            and _round_x0(entry.x0_from, round_digits=round_digits) == x0
        ]
        rows[x0] = row_entries
        typed = [
            entry
            for entry in matrix.entries
            if entry.operator_label == operator.label
            and _round_x0(entry.x0_from, round_digits=round_digits) == x0
        ]
        classifications[str(x0)] = _classify_row(typed, x0_from=x0)

    return {
        "operator_key": operator_key,
        "operator_label": operator.label,
        "actual_norm": operator.actual_norm,
        "transitions_by_x0": {str(x0): rows[x0] for x0 in X0_RESONANCE_LEVELS},
        "x0_classifications": classifications,
    }


def _build_coupled_operator_profile(
    coupled_key: str,
    operator_keys: Sequence[str],
    *,
    operators_by_key: dict[str, ArithmeticPrimeOperator],
    template: Octonion,
    round_digits: int = 6,
) -> dict[str, object]:
    deterministic_edges: dict[str, str] = {}
    for x0 in X0_RESONANCE_LEVELS:
        start = _state_at_x0(x0, template=template)
        end_x0 = _apply_operator_sequence(
            start,
            operator_keys,
            operators_by_key=operators_by_key,
        )
        deterministic_edges[str(x0)] = str(end_x0)

    invariants = _graph_invariants_from_successors(deterministic_edges)
    return {
        "coupled_key": coupled_key,
        "operator_sequence": list(operator_keys),
        "deterministic_edges": deterministic_edges,
        "graph_invariants": invariants,
    }


def _graph_invariants_from_successors(successors: dict[str, str]) -> dict[str, object]:
    fixed_points = sorted(node for node, target in successors.items() if node == target)
    pump_paths = sorted(
        f"{node}->{target}"
        for node, target in successors.items()
        if float(target) > float(node)
    )
    bifurcation_nodes: list[str] = []
    cycles: list[str] = []

    visited: set[str] = set()
    for start in successors:
        if start in visited:
            continue
        path: list[str] = []
        index_by_node: dict[str, int] = {}
        current: str | None = start
        while current is not None and current not in index_by_node:
            index_by_node[current] = len(path)
            path.append(current)
            visited.add(current)
            next_node = successors.get(current)
            if next_node is None:
                break
            if next_node == current:
                break
            current = next_node
        if current is not None and current in index_by_node:
            cycle_nodes = path[index_by_node[current] :]
            if len(cycle_nodes) >= 2:
                cycles.append("->".join(cycle_nodes + [cycle_nodes[0]]))

    return {
        "fixed_points": fixed_points,
        "cycles": cycles,
        "bifurcation_nodes": bifurcation_nodes,
        "pump_paths": pump_paths,
    }


def _aggregate_graph_invariants(
    coupled_profiles: dict[str, object],
) -> dict[str, object]:
    aggregate: dict[str, list[str]] = {
        "fixed_points": [],
        "cycles": [],
        "bifurcation_nodes": [],
        "pump_paths": [],
    }
    for profile in coupled_profiles.values():
        invariants = profile["graph_invariants"]  # type: ignore[index]
        for key in aggregate:
            aggregate[key].extend(invariants[key])  # type: ignore[index]
    return {key: sorted(set(values)) for key, values in aggregate.items()}


def _dominant_successors_from_profile(profile: dict[str, object]) -> dict[str, str]:
    successors: dict[str, str] = {}
    transitions = profile["transitions_by_x0"]  # type: ignore[index]
    for x0 in X0_RESONANCE_LEVELS:
        rows = transitions[str(x0)]
        if not rows:
            successors[str(x0)] = str(x0)
            continue
        dominant = max(rows, key=lambda row: row["probability"])  # type: ignore[index]
        successors[str(x0)] = str(dominant["x0_to"])
    return successors


def analyze_coupled_shell_resonance_graph(
    *,
    evolution_steps: int = 24,
    round_digits: int = 6,
) -> CoupledShellResonanceAnalysis:
    """E-043-pre: gekoppelte Shell-Proxy-Operatoren als endlicher Resonanzgraph auf x0-Niveaus."""
    cyclic, _ = run_default_arithmetic_evolution_scenarios(steps=evolution_steps)
    matrix = build_transition_matrix_analysis(cyclic.records, round_digits=round_digits)
    operators_by_key = _operators_by_key()
    template = _template_state()

    single_profiles = {
        key: _build_single_operator_profile(key, operators_by_key[key], matrix, round_digits=round_digits)
        for key in SHELL_OPERATOR_KEYS
    }
    coupled_profiles = {
        coupled_key: _build_coupled_operator_profile(
            coupled_key,
            _COUPLED_KEY_TO_SEQUENCE[coupled_key],
            operators_by_key=operators_by_key,
            template=template,
            round_digits=round_digits,
        )
        for coupled_key in COUPLED_OPERATOR_KEYS
    }

    bifurcation_nodes = sorted(
        {
            f"{profile['operator_key']}@{x0}"
            for profile in single_profiles.values()
            for x0, classification in profile["x0_classifications"].items()  # type: ignore[union-attr]
            if classification == "bifurcation"
        }
    )

    graph_invariants = _aggregate_graph_invariants(coupled_profiles)
    graph_invariants["single_operator_bifurcation_nodes"] = bifurcation_nodes
    graph_invariants["single_operator_fixed_points"] = sorted(
        {
            f"{profile['operator_key']}@{node}"
            for profile in single_profiles.values()
            for node in _graph_invariants_from_successors(_dominant_successors_from_profile(profile))[
                "fixed_points"
            ]
        }
    )
    graph_invariants["single_operator_pump_paths"] = sorted(
        {
            f"{profile['operator_key']}:{path}"
            for profile in single_profiles.values()
            for path in _graph_invariants_from_successors(_dominant_successors_from_profile(profile))[
                "pump_paths"
            ]
        }
    )

    return CoupledShellResonanceAnalysis(
        claim_class="C",
        upgrade_status="pre",
        depends_on=("E-036", "E-037", "E-041", "S8"),
        operators=SHELL_OPERATOR_KEYS,
        x0_levels=X0_RESONANCE_LEVELS,
        single_operator_profiles=single_profiles,
        coupled_operator_profiles=coupled_profiles,
        graph_invariants=graph_invariants,
        defensive_scope=E043_DEFENSIVE_SCOPE,
        methodological_note=(
            "Keil A-pre: finite coupled-shell dynamics on validated N=4,6,8 proxies. "
            "Single operators from E-036 transition matrix; pairwise and triple couplings "
            "as deterministic resonance graphs on six x0 levels. No N-body or gravity claim."
        ),
    )


def export_coupled_shell_resonance_json(
    analysis: CoupledShellResonanceAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "upgrade_status": analysis.upgrade_status,
        "depends_on": list(analysis.depends_on),
        "operators": list(analysis.operators),
        "x0_levels": list(analysis.x0_levels),
        "single_operator_profiles": analysis.single_operator_profiles,
        "coupled_operator_profiles": analysis.coupled_operator_profiles,
        "graph_invariants": analysis.graph_invariants,
        "defensive_scope": analysis.defensive_scope,
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_coupled_shell_resonance_summary(analysis: CoupledShellResonanceAnalysis) -> str:
    inv = analysis.graph_invariants
    coupled = ", ".join(
        f"{key}:fp={len(profile['graph_invariants']['fixed_points'])}"  # type: ignore[index]
        for key, profile in analysis.coupled_operator_profiles.items()
    )
    return (
        f"claim_class={analysis.claim_class}, operators={list(analysis.operators)}, "
        f"x0_levels={len(analysis.x0_levels)}, coupled=[{coupled}], "
        f"bifurcation_nodes={len(inv.get('single_operator_bifurcation_nodes', []))}"
    )
