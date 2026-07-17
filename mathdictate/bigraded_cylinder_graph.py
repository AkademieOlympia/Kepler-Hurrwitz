"""[B] Exhaustiver 2-adischer Cutoff- und Singularpfad-Auditor.

Schicht B1/B2: vollständiger Zylinder-Cutoff Z_<=P mit
exakten kombinatorischen Sollwerten und Singularpfad-Kettenverifikation.

Governance
----------
- Status: ``[B]`` (diagnostischer Cutoff-Audit; kein Collatz-Beweis)
- ``require`` ist unabhängig von ``python -O`` (kein ``assert``)
- Lokaler Freeze erst nach Laufprotokoll + Hash + Commit
"""

from __future__ import annotations

from collections import defaultdict
from collections.abc import Iterable
from dataclasses import dataclass
from typing import Any

GOVERNANCE = "[B]"

__all__ = [
    "GOVERNANCE",
    "Cylinder",
    "LiftEdge",
    "DynamicsEdge",
    "CylinderCutoffReport",
    "require",
    "compute_visible_valuation",
    "complete_cutoff",
    "audit_cylinder_cutoff",
]


@dataclass(frozen=True)
class Cylinder:
    """Formal 2-adic cylinder encoding explicit available bit precision."""

    residue: int
    precision: int


@dataclass(frozen=True)
class LiftEdge:
    source: Cylinder
    target: Cylinder
    is_boundary: bool


@dataclass(frozen=True)
class DynamicsEdge:
    source: Cylinder
    target: Cylinder
    valuation: int


@dataclass(frozen=True)
class CylinderCutoffReport:
    max_precision: int
    state_count: int
    expected_states: int
    internal_lift_edges: int
    boundary_lift_edges: int
    expected_internal_lifts: int
    expected_boundary_lifts: int
    internal_dynamics_edges: int
    singular_split_verified_count: int
    singular_path_prefix: tuple[Cylinder, ...]
    lift_required_by_precision: dict[int, int]
    dynamics_precision_drop_histogram: dict[int, int]


def require(condition: bool, message: str) -> None:
    """Enforce architectural constraints independently of Python optimization flags."""
    if not condition:
        raise RuntimeError(f"GOVERNANCE VIOLATION: {message}")


def compute_visible_valuation(residue: int, precision: int) -> int:
    """Derive j_p(r) honestly from the 2-adic cylinder data."""
    value = 3 * residue + 1
    valuation = 0
    while valuation < precision and value % 2 == 0:
        value //= 2
        valuation += 1
    return valuation


def complete_cutoff(max_precision: int) -> tuple[Cylinder, ...]:
    """Build the complete cylinder universe Z_<=P."""
    require(max_precision >= 1, f"max_precision must be >= 1, got {max_precision}.")
    return tuple(
        Cylinder(residue=r, precision=p)
        for p in range(1, max_precision + 1)
        for r in range(1, 1 << p, 2)
    )


def audit_cylinder_cutoff(
    cylinders: Iterable[Cylinder],
) -> tuple[tuple[LiftEdge, ...], tuple[DynamicsEdge, ...], CylinderCutoffReport]:
    """
    Schicht B1 & B2: Exhaustively audit the canonical 2-adic cylinder cutoff Z_<=P.

    Enforces exact combinatorial constraints and serializes the singular thread.
    """
    universe = tuple(cylinders)
    universe_set = set(universe)

    if not universe:
        raise RuntimeError("AUDIT FAILED: The audited cylinder space is empty.")
    if len(universe) != len(universe_set):
        raise RuntimeError("AUDIT FAILED: The cylinder iterable contains duplicate states.")

    # 1. Maximale Präzision und Cutoff-Vollständigkeit
    max_p = max(c.precision for c in universe)

    expected_set = {
        Cylinder(r, p)
        for p in range(1, max_p + 1)
        for r in range(1, 1 << p, 2)
    }

    require(
        universe_set == expected_set,
        f"AUDIT FAILED: Universe is not the complete cylinder cutoff Z_<={max_p}.",
    )

    lift_edges: list[LiftEdge] = []
    dynamics_edges: list[DynamicsEdge] = []

    singular_split_verified_count = 0
    lift_required_by_precision: dict[int, int] = defaultdict(int)
    dynamics_drop_hist: dict[int, int] = defaultdict(int)
    singular_nodes_by_p: dict[int, Cylinder] = {}

    for c in universe:
        j = compute_visible_valuation(c.residue, c.precision)
        require(1 <= j <= c.precision, f"Visible valuation out of range at {c!r}: j={j}.")

        # 2. Dynamikkanten (Bestimmtheitsverlust p -> p-j)
        if j < c.precision:
            next_p = c.precision - j
            next_r = ((3 * c.residue + 1) // (1 << j)) % (1 << next_p)
            target_cylinder = Cylinder(residue=next_r, precision=next_p)

            require(
                target_cylinder in universe_set,
                f"AUDIT FAILED: Dynamics target missing from complete cutoff: "
                f"{c!r} -> {target_cylinder!r}.",
            )

            dynamics_edges.append(
                DynamicsEdge(source=c, target=target_cylinder, valuation=j)
            )
            dynamics_drop_hist[j] += 1
        else:
            # j == p: Dynamics blocked (Pol-Kandidat auf Ebene p)
            lift_required_by_precision[c.precision] += 1
            singular_nodes_by_p[c.precision] = c

            # Singular-Lift-Split-Lemma
            c_lift1 = Cylinder(residue=c.residue, precision=c.precision + 1)
            c_lift2 = Cylinder(
                residue=c.residue + (1 << c.precision),
                precision=c.precision + 1,
            )

            j_lift1 = compute_visible_valuation(c_lift1.residue, c_lift1.precision)
            j_lift2 = compute_visible_valuation(c_lift2.residue, c_lift2.precision)

            require(
                {j_lift1, j_lift2} == {c.precision, c.precision + 1},
                f"Unexpected singular-cylinder lift split at {c!r}.",
            )
            singular_split_verified_count += 1

        # 3. Liftkanten (Informationsgewinn p -> p+1)
        expected_boundary = c.precision == max_p
        for lift_r in (c.residue, c.residue + (1 << c.precision)):
            target_lift = Cylinder(residue=lift_r, precision=c.precision + 1)
            is_boundary_lift = target_lift not in universe_set

            require(
                is_boundary_lift == expected_boundary,
                f"Unexpected lift-boundary classification at {c!r} -> {target_lift!r}.",
            )
            lift_edges.append(
                LiftEdge(source=c, target=target_lift, is_boundary=is_boundary_lift)
            )

    # 4. Kettenglieder-Verifikation des Singularpfades
    for p in range(1, max_p):
        current = singular_nodes_by_p[p]
        expected_next = singular_nodes_by_p[p + 1]
        lift_a = Cylinder(current.residue, p + 1)
        lift_b = Cylinder(current.residue + (1 << p), p + 1)
        singular_lifts = [
            lift
            for lift in (lift_a, lift_b)
            if compute_visible_valuation(lift.residue, lift.precision) == p + 1
        ]
        require(
            singular_lifts == [expected_next],
            f"AUDIT FAILED: Singular path connection failed between levels {p} and {p + 1}.",
        )

    # 5. Exakte globale Sollzählungen
    expected_states = (1 << max_p) - 1
    expected_internal_lifts = (1 << max_p) - 2
    expected_boundary_lifts = 1 << max_p

    for p in range(1, max_p + 1):
        require(
            lift_required_by_precision[p] == 1,
            f"Singular node counting violation on precision level {p}: "
            f"got {lift_required_by_precision[p]}.",
        )

    internal_lifts = sum(1 for e in lift_edges if not e.is_boundary)
    boundary_lifts = sum(1 for e in lift_edges if e.is_boundary)

    require(len(universe) == expected_states, "State count mismatch.")
    require(internal_lifts == expected_internal_lifts, "Internal lift count mismatch.")
    require(boundary_lifts == expected_boundary_lifts, "Boundary lift count mismatch.")

    singular_path_prefix = tuple(singular_nodes_by_p[p] for p in range(1, max_p + 1))

    report = CylinderCutoffReport(
        max_precision=max_p,
        state_count=len(universe),
        expected_states=expected_states,
        internal_lift_edges=internal_lifts,
        boundary_lift_edges=boundary_lifts,
        expected_internal_lifts=expected_internal_lifts,
        expected_boundary_lifts=expected_boundary_lifts,
        internal_dynamics_edges=len(dynamics_edges),
        singular_split_verified_count=singular_split_verified_count,
        singular_path_prefix=singular_path_prefix,
        lift_required_by_precision=dict(lift_required_by_precision),
        dynamics_precision_drop_histogram=dict(dynamics_drop_hist),
    )
    return tuple(lift_edges), tuple(dynamics_edges), report


def report_to_dict(report: CylinderCutoffReport) -> dict[str, Any]:
    """Serialize report with cylinders as {residue, precision}."""
    return {
        "max_precision": report.max_precision,
        "state_count": report.state_count,
        "expected_states": report.expected_states,
        "internal_lift_edges": report.internal_lift_edges,
        "boundary_lift_edges": report.boundary_lift_edges,
        "expected_internal_lifts": report.expected_internal_lifts,
        "expected_boundary_lifts": report.expected_boundary_lifts,
        "internal_dynamics_edges": report.internal_dynamics_edges,
        "singular_split_verified_count": report.singular_split_verified_count,
        "singular_path_prefix": [
            {"residue": c.residue, "precision": c.precision}
            for c in report.singular_path_prefix
        ],
        "lift_required_by_precision": {
            str(k): v for k, v in sorted(report.lift_required_by_precision.items())
        },
        "dynamics_precision_drop_histogram": {
            str(k): v
            for k, v in sorted(report.dynamics_precision_drop_histogram.items())
        },
    }
