"""[B] Canonical phase & feature compression auditor.

Constructs the unique cycle phase φ and Lyapunov depth d on a finite
weakly connected functional graph, then audits whether local feature
vectors reconstruct these global observables without collisions.

Governance
----------
- Status: ``[B]`` (combinatorial graph observables; no Collatz proof)
- Requires weak connectivity (monolith topology)
- Covariance: ``φ(Tx) = φ(x) + 1 (mod L)``
- Depth: ``d(Tx) ≤ d(x)``, with strict ``d-1`` off the attractor
- Honesty: if ``L = 1``, then φ ≡ 0 and the mod-1 covariance is trivial;
  the live compression target on such monoliths is the depth ``d``
- Phase origin is gauge-dependent unless a *unique* ``canonical_key``
  anchor is provided; ambiguous minima raise ``AUDIT FAILED``
- Local freeze only after run protocol + hash + commit

Bezug: Arbeitsprogramm Phase B & C (Kollisions- und Kardinalitätsanalyse).
"""

from __future__ import annotations

import sys
from collections import defaultdict, deque
from collections.abc import Callable, Hashable, Iterable
from dataclasses import dataclass
from typing import Any, TypeVar

State = TypeVar("State", bound=Hashable)

GOVERNANCE = "[B]"

__all__ = [
    "GOVERNANCE",
    "require",
    "CyclePhaseReport",
    "construct_cycle_phase",
    "audit_target_reconstruction",
    "audit_phase_reconstruction",
]


def require(condition: bool, message: str) -> None:
    """Enforce constraints independently of Python optimization flags."""
    if not condition:
        raise RuntimeError(f"AUDIT FAILED: {message}")


@dataclass(frozen=True)
class CyclePhaseReport:
    state_count: int
    cycle_length: int
    max_depth: int
    phase_histogram: dict[int, int]
    depth_histogram: dict[int, int]

    @property
    def phase_trivial(self) -> bool:
        """True iff L=1, so φ is constantly 0 and mod-1 covariance is vacuous."""
        return self.cycle_length == 1


def construct_cycle_phase(
    states: Iterable[State],
    step: Callable[[State], State],
    canonical_key: Callable[[State], Any] | None = None,
) -> tuple[dict[State, int], dict[State, int], CyclePhaseReport]:
    """Construct canonical phase φ and depth d on a weakly connected digraph.

    Phase normalization enforces strict uniqueness on the structural anchor.
    With ``canonical_key``, the cycle is rotated so the unique minimal-key
    cycle node is the phase origin. If several cycle nodes share the
    minimum key, the construction raises ``AUDIT FAILED``.
    """
    universe = tuple(states)
    universe_set = set(universe)
    require(bool(universe), "The state space is empty.")
    require(
        len(universe) == len(universe_set),
        "The state iterable contains duplicate states.",
    )

    next_node: dict[State, State] = {}
    predecessors: dict[State, set[State]] = defaultdict(set)
    adjacency: dict[State, set[State]] = defaultdict(set)

    for x in universe:
        tx = step(x)
        require(
            tx in universe_set,
            f"Step leaves the state space: x={x!r}, T(x)={tx!r}.",
        )
        next_node[x] = tx
        predecessors[tx].add(x)
        adjacency[x].add(tx)
        adjacency[tx].add(x)

    # Verify weak connectedness via BFS.
    reached: set[State] = set()
    queue: deque[State] = deque([universe[0]])
    reached.add(universe[0])
    while queue:
        node = queue.popleft()
        for neighbor in adjacency[node]:
            if neighbor not in reached:
                reached.add(neighbor)
                queue.append(neighbor)
    require(
        reached == universe_set,
        "The function graph is not weakly connected.",
    )

    # Find the unique directed cycle (functional graph + one weak component).
    trajectory_index: dict[State, int] = {}
    trajectory: list[State] = []
    current = universe[0]
    while current not in trajectory_index:
        trajectory_index[current] = len(trajectory)
        trajectory.append(current)
        current = next_node[current]
    cycle_start = trajectory_index[current]
    cycle = list(trajectory[cycle_start:])
    cycle_length = len(cycle)
    require(cycle_length > 0, "No directed cycle was found.")

    # Ambiguity-free anchored phase normalization (otherwise gauge-dependent).
    if canonical_key is not None:
        keyed_cycle = [(canonical_key(node), node) for node in cycle]
        minimum_key = min(key for key, _ in keyed_cycle)
        anchors = [node for key, node in keyed_cycle if key == minimum_key]
        if len(anchors) != 1:
            raise RuntimeError(
                "AUDIT FAILED: Phase normalization is ambiguous: canonical_key "
                f"has {len(anchors)} minimal cycle nodes."
            )
        anchor_node = anchors[0]
        anchor_idx = cycle.index(anchor_node)
        cycle = cycle[anchor_idx:] + cycle[:anchor_idx]

    cycle_index = {node: index for index, node in enumerate(cycle)}

    # Reverse BFS from the cycle to determine depth and entry nodes.
    depth: dict[State, int] = {}
    entry: dict[State, State] = {}
    reverse_queue: deque[State] = deque()
    for node in cycle:
        depth[node] = 0
        entry[node] = node
        reverse_queue.append(node)
    while reverse_queue:
        node = reverse_queue.popleft()
        for pred in predecessors[node]:
            if pred not in depth:
                depth[pred] = depth[node] + 1
                entry[pred] = entry[node]
                reverse_queue.append(pred)
    require(
        set(depth) == universe_set,
        "Reverse traversal did not cover the full state space.",
    )

    # Canonical phase: φ(x) = cycle_index(entry(x)) - depth(x) (mod L).
    phase = {
        x: (cycle_index[entry[x]] - depth[x]) % cycle_length for x in universe
    }

    # Exhaustive covariance and Lyapunov audit.
    for x in universe:
        require(
            phase[next_node[x]] == (phase[x] + 1) % cycle_length,
            f"Cycle-phase covariance failed for x={x!r}.",
        )
        require(
            depth[next_node[x]] <= depth[x],
            f"Lyapunov depth rank failed for x={x!r}.",
        )
        if depth[x] > 0:
            require(
                depth[next_node[x]] == depth[x] - 1,
                f"Strict depth descent failed outside attractor for x={x!r}.",
            )

    phase_histogram = {
        v: sum(1 for x in universe if phase[x] == v) for v in range(cycle_length)
    }
    depth_values = sorted(set(depth.values()))
    depth_histogram = {
        v: sum(1 for x in universe if depth[x] == v) for v in depth_values
    }
    report = CyclePhaseReport(
        state_count=len(universe),
        cycle_length=cycle_length,
        max_depth=max(depth.values()),
        phase_histogram=phase_histogram,
        depth_histogram=depth_histogram,
    )
    return phase, depth, report


def audit_target_reconstruction(
    states: Iterable[State],
    canonical_target: dict[State, int],
    features: Callable[[State], Hashable],
) -> dict[str, Any]:
    """Test whether the feature vector determines the target exactly.

    Passing this audit proves reconstructibility, not by itself useful
    compression or low computational cost. On collision, stores a full
    witness pair ``(first_state, first_value, second_state, second_value)``
    together with the colliding ``feature_vector``. Success reports
    ``F=Q`` via ``minimal_for_target`` (cardinality-minimal exact encoding).
    """
    universe = tuple(states)
    universe_set = set(universe)
    require(bool(universe), "The audited state space is empty.")
    require(
        len(universe) == len(universe_set),
        "The state iterable contains duplicate states.",
    )
    require(
        set(canonical_target) == universe_set,
        "The target map does not cover exactly the audited state space.",
    )

    buckets: dict[Hashable, tuple[State, int]] = {}
    for x in universe:
        key = features(x)
        value = canonical_target[x]
        if key in buckets:
            first_state, first_value = buckets[key]
            if first_value != value:
                return {
                    "reconstructs_target": False,
                    "collision": {
                        "feature_vector": key,
                        "first_state": first_state,
                        "first_value": first_value,
                        "second_state": x,
                        "second_value": value,
                    },
                }
        else:
            buckets[key] = (x, value)

    state_count = len(universe)
    feature_count = len(buckets)
    target_count = len(set(canonical_target.values()))
    require(
        feature_count >= target_count,
        "Internal counting contradiction: fewer features than target classes.",
    )
    return {
        "reconstructs_target": True,
        "state_count": state_count,
        "distinct_feature_vectors": feature_count,
        "target_classes_count": target_count,
        "state_compression_ratio": feature_count / state_count,
        "minimal_for_target": feature_count == target_count,
    }


def audit_phase_reconstruction(
    states: Iterable[State],
    canonical_target: dict[State, int],
    features: Callable[[State], Hashable],
) -> dict[str, Any]:
    """Thin back-compat alias for :func:`audit_target_reconstruction`."""
    return audit_target_reconstruction(states, canonical_target, features)


def main(argv: list[str] | None = None) -> int:
    """Delegate to the executable audit runner (production oddCoreStep binding)."""
    from kepler_hurwitz.run_cycle_phase_audit import main as audit_main

    return audit_main(argv)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
