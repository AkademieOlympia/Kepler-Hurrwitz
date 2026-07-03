#!/usr/bin/env python3
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
sys.path.insert(0, str(SRC))

from kepler_hurwitz.discrete_time_flow import (
    associator,
    default_demo_orbit,
    evolve_right,
    hurwitz_units_240,
    rank_phase_space_regimes,
    nearest_hurwitz_unit,
    octonion_mul,
    orbit_distance,
    phi,
    phi_inv,
    simulate_physical_flow,
    project_to_hurwitz_lattice,
    validate_ranked_windows_longrun,
)


def _fmt(x: tuple[float, ...], ndigits: int = 6) -> str:
    return "(" + ", ".join(f"{v:.{ndigits}f}" for v in x) + ")"


def _print_ranked_table(title: str, rows) -> None:
    print(title)
    print(
        "rank | w_norm | w_dist | alpha | score | unique | drift | recur | period | regime"
    )
    print("-" * 96)
    for index, row in enumerate(rows, start=1):
        period = "-" if row.period is None else str(row.period)
        print(
            f"{index:4d} | {row.w_norm:6.1f} | {row.w_dist:6.2f} | {row.alpha:5.2f} | "
            f"{row.score:5.3f} | {row.unique_states:6d} | {row.max_norm_drift_sq:5.3f} | "
            f"{row.recurrence_ratio:5.3f} | {period:>6} | {row.regime}"
        )
    print()


def _print_longrun_table(title: str, rows) -> None:
    print(title)
    print(
        "steps | w_norm | w_dist | alpha | regime | tail_p | tail_u | unique | drift | var | recur"
    )
    print("-" * 104)
    for row in rows:
        tail_period = "-" if row.tail_period is None else str(row.tail_period)
        print(
            f"{row.steps:5d} | {row.w_norm:6.1f} | {row.w_dist:6.2f} | {row.alpha:5.2f} | "
            f"{row.regime:24s} | {tail_period:>6} | {row.tail_unique_states:6d} | "
            f"{row.unique_states:6d} | {row.max_norm_drift_sq:5.3f} | {row.norm_variance:5.3f} | "
            f"{row.recurrence_ratio:5.3f}"
        )
    print()


def main() -> None:
    orbit_0 = default_demo_orbit()
    x_0 = phi(orbit_0)

    p1_seed = (0.12, 0.95, 0.03, -0.08, 0.21, -0.11, 0.07, 0.02)
    p2_seed = (-0.33, 0.19, 0.88, 0.04, -0.06, 0.17, 0.05, -0.09)
    p1 = nearest_hurwitz_unit(project_to_hurwitz_lattice(p1_seed))
    p2 = nearest_hurwitz_unit(project_to_hurwitz_lattice(p2_seed))

    # Non-commutative path ordering.
    x_a = evolve_right(x_0, (p1, p2))
    x_b = evolve_right(x_0, (p2, p1))
    orbit_a = phi_inv(x_a)
    orbit_b = phi_inv(x_b)
    delta_path = orbit_distance(orbit_a, orbit_b)

    # Non-associative bracketing on three operators.
    p3_seed = (0.41, -0.27, 0.12, 0.66, -0.11, -0.2, 0.09, 0.18)
    p3 = nearest_hurwitz_unit(project_to_hurwitz_lattice(p3_seed))
    left_bracket = octonion_mul(octonion_mul(x_0, p1), octonion_mul(p2, p3))
    right_bracket = octonion_mul(x_0, octonion_mul(p1, octonion_mul(p2, p3)))
    assoc = associator(p1, p2, p3)

    print("--- #Energiedoku: Diskreter algebraischer Zeitfluss ---")
    print(f"X_0 = { _fmt(x_0) }")
    print(f"P1  = { _fmt(p1) }")
    print(f"P2  = { _fmt(p2) }")
    print(f"P3  = { _fmt(p3) }")
    print()
    print("Pfadinterferenz (Reihenfolge):")
    print(f"  Delta_orbit = {delta_path:.6f}")
    print(f"  A: a={orbit_a.a:.6f}, eps={orbit_a.epsilon:.6f}, E={orbit_a.E:.6f}")
    print(f"  B: a={orbit_b.a:.6f}, eps={orbit_b.epsilon:.6f}, E={orbit_b.E:.6f}")
    print()
    print("Klammerungsinterferenz (Nicht-Assoziativitaet):")
    print(f"  left  = {_fmt(left_bracket)}")
    print(f"  right = {_fmt(right_bracket)}")
    print(f"  operator associator [P1,P2,P3] = {_fmt(assoc)}")
    print()

    print("Physikalischer Modus (mit Gitter-/Norm-/Epsilon-Filter):")
    sim_hard = simulate_physical_flow(
        x_0,
        steps=24,
        operators=hurwitz_units_240()[:12],
        mode="cyclic",
        enforce_norm=True,
        epsilon_bound=0.999999,
        resolver_mode="hard",
    )
    sim_soft = simulate_physical_flow(
        x_0,
        steps=24,
        operators=hurwitz_units_240()[:12],
        mode="cyclic",
        enforce_norm=True,
        epsilon_bound=0.999999,
        resolver_mode="soft",
        w_dist=1.0,
        w_norm=5.0,
        alpha=10.0,
    )
    sim_soft_ring2 = simulate_physical_flow(
        x_0,
        steps=24,
        operators=hurwitz_units_240()[:12],
        mode="cyclic",
        enforce_norm=True,
        epsilon_bound=0.999999,
        resolver_mode="soft",
        w_dist=1.0,
        w_norm=5.0,
        alpha=10.0,
        use_second_ring=True,
    )
    if sim_hard.records and sim_soft.records:
        max_drift_hard = max(r.norm_drift_sq for r in sim_hard.records)
        max_drift_soft = max(r.norm_drift_sq for r in sim_soft.records)
        max_drift_soft_ring2 = sim_soft_ring2.max_norm_drift_sq()
        last_hard = sim_hard.records[-1]
        last_soft = sim_soft.records[-1]
        last_soft_ring2 = sim_soft_ring2.records[-1]
        print(f"  steps={len(sim_hard.records)}")
        print(f"  target_norm_sq={sim_hard.target_norm_sq:.6f}")
        print(f"  hard.max_norm_drift_sq={max_drift_hard:.6f}")
        print(f"  hard.final_epsilon={last_hard.epsilon:.6f}")
        print(f"  hard.final_state={_fmt(last_hard.state)}")
        print(f"  soft.max_norm_drift_sq={max_drift_soft:.6f}")
        print(f"  soft.final_epsilon={last_soft.epsilon:.6f}")
        print(f"  soft.final_state={_fmt(last_soft.state)}")
        print(f"  soft+ring2.max_norm_drift_sq={max_drift_soft_ring2:.6f}")
        print(f"  soft+ring2.unique_states={sim_soft_ring2.unique_state_count()}")
        print(f"  soft+ring2.final_state={_fmt(last_soft_ring2.state)}")
        print()

        search_steps = 16
        search_operators = hurwitz_units_240()[:8]
        search_grid = {
            "steps": search_steps,
            "operators": search_operators,
            "w_norm_values": (2.0, 5.0, 10.0, 20.0, 50.0),
            "w_dist_values": (0.25, 0.5, 1.0),
            "alpha_values": (0.1, 0.2, 0.35),
            "top_k": 10,
        }
        ranked_soft = rank_phase_space_regimes(
            x_0,
            use_second_ring=False,
            **search_grid,
        )
        ranked_ring2 = rank_phase_space_regimes(
            x_0,
            use_second_ring=True,
            **search_grid,
        )
        _print_ranked_table("V2 Stability Window Search: soft (Ring 1)", ranked_soft)
        _print_ranked_table("V2 Stability Window Search: soft + ring2", ranked_ring2)

        longrun_operators = search_operators
        longrun_validations_soft = validate_ranked_windows_longrun(
            ranked_soft,
            initial_state=x_0,
            steps_values=(200, 500),
            top_k=3,
            operators=longrun_operators,
        )
        longrun_validations_ring2 = validate_ranked_windows_longrun(
            ranked_ring2,
            initial_state=x_0,
            steps_values=(200, 500),
            top_k=3,
            operators=longrun_operators,
        )
        _print_longrun_table("V2 Long-Run Validation: Top-3 soft (Ring 1)", longrun_validations_soft)
        _print_longrun_table("V2 Long-Run Validation: Top-3 soft + ring2", longrun_validations_ring2)


if __name__ == "__main__":
    main()
