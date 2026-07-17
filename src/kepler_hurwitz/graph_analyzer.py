"""[B] Topologischer Funktionsgraph-Scanner (Phase A/B).

Kartografiert die nackte Graphentopologie einer deterministischen Abbildung
auf einem endlichen Zustandsraum und auditiert Kandidaten-Observablen auf
exakte Invarianz vs. zyklische Kovarianz über induzierte Quotientendynamik.

Governance
----------
- Status: ``[B]`` (kombinatorische Graphenklassifikation; kein Collatz-Beweis)
- Keine geometrischen Schranken und keine Fano-/Charakterstrukturen a priori
- Schwach zusammenhängend ⇒ keine nichtkonstante Invariante ``J ∘ T = J``
- Suchziel bei Komponentenzahl 1: Kovarianz ``J(Tx) = σ(J(x))`` mit ``σ ≠ id``

Bezug: Arbeitsprogramm Phase A/B (Freeze-Kandidat, Odd-Core-Funktionsgraph).
"""

from __future__ import annotations

from collections import defaultdict, deque
from collections.abc import Callable, Hashable, Iterable, Mapping
from typing import TypeVar

State = TypeVar("State", bound=Hashable)
Value = TypeVar("Value", bound=Hashable)

GOVERNANCE = "[B]"

__all__ = [
    "GOVERNANCE",
    "require",
    "classify_function_graph",
    "analyze_quotient_dynamics",
]


def require(condition: bool, message: str) -> None:
    """Enforce architectural constraints independently of optimization flags."""
    if not condition:
        raise RuntimeError(f"AUDIT FAILED: {message}")


def classify_function_graph(
    states: Iterable[State],
    step: Callable[[State], State],
) -> dict[str, object]:
    """Phase A: exhaustively map the deterministic function graph.

    Returns weak-component counts, attractor cycles, and basin sizes.
    Every weakly connected component of a functional graph (out-degree 1)
    contains exactly one directed cycle; the remaining nodes form its basin.
    """
    universe = tuple(states)
    universe_set = set(universe)
    require(len(universe) == len(universe_set), "Zustandsraum enthält Duplikate.")

    next_node: dict[State, State] = {}
    adj: dict[State, set[State]] = defaultdict(set)

    for x in universe:
        tx = step(x)
        require(
            tx in universe_set,
            f"Abbildung verlässt den Zustandsraum: x={x!r}, T(x)={tx!r}.",
        )
        next_node[x] = tx
        adj[x].add(tx)
        adj[tx].add(x)

    visited: set[State] = set()
    components: list[list[State]] = []

    for node in universe:
        if node in visited:
            continue
        comp: list[State] = []
        queue: deque[State] = deque([node])
        visited.add(node)
        while queue:
            curr = queue.popleft()
            comp.append(curr)
            for nxt in adj[curr]:
                if nxt not in visited:
                    visited.add(nxt)
                    queue.append(nxt)
        components.append(comp)

    attractor_cycles: list[list[State]] = []
    basin_sizes: list[int] = []

    for comp in components:
        path_visited: set[State] = set()
        curr = comp[0]
        while curr not in path_visited:
            path_visited.add(curr)
            curr = next_node[curr]

        cycle: list[State] = [curr]
        loop_runner = next_node[curr]
        while loop_runner != curr:
            cycle.append(loop_runner)
            loop_runner = next_node[loop_runner]

        # Rotate to a stable representative for reproducible exports.
        rotate_at = min(range(len(cycle)), key=lambda i: repr(cycle[i]))
        cycle = cycle[rotate_at:] + cycle[:rotate_at]
        attractor_cycles.append(cycle)
        basin_sizes.append(len(comp))

    weak_components_count = len(components)
    return {
        "weak_components_count": weak_components_count,
        "attraktor_cycles_count": len(attractor_cycles),
        "attractor_cycles_count": len(attractor_cycles),
        "attractor_cycles": tuple(tuple(c) for c in attractor_cycles),
        "basin_sizes": tuple(basin_sizes),
        "nonconstant_invariant_possible": weak_components_count > 1,
        "governance": GOVERNANCE,
    }


def analyze_quotient_dynamics(
    states: Iterable[State],
    step: Callable[[State], State],
    observable: Callable[[State], Value],
) -> dict[str, object]:
    """Phase B: audit a candidate observable for invariance or covariance.

    Classification:
    - ``exact_invariant``: induced map is the identity on value classes
    - ``cyclic_covariance``: closed single-valued quotient map, not identity
    - ``no_closed_quotient``: some value class has multiple image values
    """
    transitions: dict[Value, set[Value]] = defaultdict(set)
    universe = tuple(states)
    for x in universe:
        val_x = observable(x)
        val_tx = observable(step(x))
        transitions[val_x].add(val_tx)

    ambiguous: dict[Value, set[Value]] = {
        value: targets
        for value, targets in transitions.items()
        if len(targets) != 1
    }
    if ambiguous:
        return {
            "type": "no_closed_quotient",
            "ambiguous_entries": {k: sorted(v, key=repr) for k, v in ambiguous.items()},
            "governance": GOVERNANCE,
        }

    induced_map: Mapping[Value, Value] = {
        val: next(iter(targets)) for val, targets in transitions.items()
    }
    is_identity = all(val == target for val, target in induced_map.items())
    if is_identity:
        return {
            "type": "exact_invariant",
            "induced_map": dict(induced_map),
            "governance": GOVERNANCE,
        }
    return {
        "type": "cyclic_covariance",
        "induced_map": dict(induced_map),
        "governance": GOVERNANCE,
    }
