"""
Modular wrap / precision-loss surgery on the functional avoid-1 graph F_k [B].

F_k = π_k ∘ T ∘ s_k on odd residues mod 2^k (one out-edge; drop target ≡1).
Surgery cuts S_k = E_wrap ∪ E_loss and recomputes cycles / ρ.

Claim wall
----------
[B] Finite-k Python verification for k ∈ [2, 12] (optional cheap extension).
    Phrase: "verified for k∈[2,12]". Universal ∀k≥2 surgery is OPEN / Non-Claim.
[A] Distinct from Lean CollatzDigraph relational half-steps mod 16.
Non-claims: no Collatz; no infinite ℕ avoidance; no Ricci-as-math;
cutting wrap edges ≠ proof of absence of ℕ cycles.

See docs/eabc_collatz_audit_grid.md §5.14.
"""

from __future__ import annotations

import argparse
import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Dict, List, Optional, Sequence

import numpy as np

__all__ = [
    "Transition",
    "odd_syracuse",
    "build_modular_graph",
    "find_cycles",
    "spectral_radius_functional",
    "run_audit",
    "export_report",
]


@dataclass(frozen=True, slots=True)
class Transition:
    source: int
    exact_target: int
    modular_target: int
    valuation: int
    wraps: bool
    precision_loss: bool


def odd_syracuse(n: int) -> tuple[int, int]:
    """Accelerated odd Syracuse: (3n+1)/2^{ν₂(3n+1)} and the valuation."""
    if n % 2 == 0:
        raise ValueError("odd_syracuse expects an odd integer")
    value = 3 * n + 1
    valuation = 0
    while value % 2 == 0:
        value //= 2
        valuation += 1
    return value, valuation


def build_modular_graph(k: int) -> tuple[Dict[int, int], Dict[int, Transition]]:
    """
    Functional avoid-1 digraph on odd residues mod 2^k.

    Edge u → (T(u) mod 2^k) iff target ≠ 1 and target is odd (always for T).
    """
    if k < 1:
        raise ValueError("k must be >= 1")
    modulus = 1 << k
    nodes = set(range(1, modulus, 2))
    graph: Dict[int, int] = {}
    metadata: Dict[int, Transition] = {}
    for u in sorted(nodes):
        exact_target, valuation = odd_syracuse(u)
        modular_target = exact_target % modulus
        t = Transition(
            source=u,
            exact_target=exact_target,
            modular_target=modular_target,
            valuation=valuation,
            wraps=exact_target >= modulus,
            precision_loss=valuation >= k,
        )
        metadata[u] = t
        if modular_target != 1 and modular_target in nodes:
            graph[u] = modular_target
    return graph, metadata


def find_cycles(graph: Dict[int, int]) -> List[List[int]]:
    """Enumerate directed cycles in a functional digraph (out-degree ≤ 1)."""
    globally_seen: set[int] = set()
    cycles: List[List[int]] = []
    for start in graph:
        if start in globally_seen:
            continue
        path: List[int] = []
        position: Dict[int, int] = {}
        current: Optional[int] = start
        while (
            current is not None
            and current in graph
            and current not in globally_seen
            and current not in position
        ):
            position[current] = len(path)
            path.append(current)
            current = graph[current]
        if current is not None and current in position:
            cycles.append(path[position[current] :])
        globally_seen.update(path)
    return cycles


def cut_graph(
    graph: Dict[int, int], metadata: Dict[int, Transition]
) -> tuple[Dict[int, int], int, int, int]:
    """Remove edges with wraps OR precision_loss. Returns cut graph and cut counts."""
    cut: Dict[int, int] = {}
    n_wrap = 0
    n_loss = 0
    n_cut = 0
    for u, v in graph.items():
        t = metadata[u]
        if t.wraps or t.precision_loss:
            n_cut += 1
            if t.wraps:
                n_wrap += 1
            if t.precision_loss:
                n_loss += 1
            continue
        cut[u] = v
    return cut, n_cut, n_wrap, n_loss


def spectral_radius_functional(graph: Dict[int, int], nodes: Sequence[int]) -> float:
    """ρ of 0-1 adjacency on ``nodes`` (functional: ρ ∈ {0,1} up to float noise)."""
    index = {u: i for i, u in enumerate(nodes)}
    n = len(nodes)
    if n == 0:
        return 0.0
    A = np.zeros((n, n), dtype=float)
    for u, v in graph.items():
        if u in index and v in index:
            A[index[u], index[v]] = 1.0
    if not np.any(A):
        return 0.0
    ev = np.linalg.eigvals(A)
    return float(np.max(np.abs(ev)))


def _same_cycle_directed(a: Sequence[int], b: Sequence[int]) -> bool:
    if len(a) != len(b) or not a:
        return False
    aa = list(a)
    bb = list(b)
    for i in range(len(bb)):
        if aa == bb[i:] + bb[:i]:
            return True
    return False


def edge_lift_check(u: int, v: int, k: int) -> dict:
    """
    Projective lift of edge u→v under π_{k+1,k}.

    Odd lifts of u mod 2^{k+1}: u and u+2^k. Edge lifts if some lift û has
    F_{k+1}(û) ≡ v (mod 2^k) and the modular edge exists in G_{k+1}.
    """
    modulus_k = 1 << k
    modulus_k1 = 1 << (k + 1)
    lifts = [u % modulus_k1, (u + modulus_k) % modulus_k1]
    # keep odd (both are odd when u odd)
    lifts = [x for x in lifts if x % 2 == 1]
    g1, meta1 = build_modular_graph(k + 1)
    lift_results = []
    any_compatible = False
    for û in lifts:
        exact, val = odd_syracuse(û)
        mod_tgt = exact % modulus_k1
        compatible_mod_k = (mod_tgt % modulus_k) == (v % modulus_k)
        edge_in_g1 = g1.get(û) == mod_tgt and mod_tgt != 1
        if compatible_mod_k and edge_in_g1:
            any_compatible = True
        lift_results.append(
            {
                "lift": û,
                "exact_target": exact,
                "modular_target_k1": mod_tgt,
                "reduced_mod_k": mod_tgt % modulus_k,
                "compatible_mod_k": compatible_mod_k,
                "edge_in_G_k1": edge_in_g1,
                "wraps_k1": exact >= modulus_k1,
                "precision_loss_k1": val >= k + 1,
            }
        )
    return {
        "source": u,
        "target": v,
        "any_compatible_lift": any_compatible,
        "lifts": lift_results,
    }


def cycle_projective_lift(cycle: Sequence[int], k: int) -> dict:
    """Does some cycle at k+1 reduce (mod 2^k) to this cycle?"""
    g1, _ = build_modular_graph(k + 1)
    cycles1 = find_cycles(g1)
    modulus_k = 1 << k
    matches: List[List[int]] = []
    for c1 in cycles1:
        reduced = [x % modulus_k for x in c1]
        # collapse consecutive duplicates from non-injective projection
        collapsed: List[int] = []
        for x in reduced:
            if not collapsed or collapsed[-1] != x:
                collapsed.append(x)
        if collapsed and collapsed[0] == collapsed[-1]:
            collapsed = collapsed[:-1]
        if _same_cycle_directed(collapsed, cycle) or _same_cycle_directed(reduced, cycle):
            matches.append(list(c1))
    # ℕ-orbit on canonical reps: every edge exact (no wrap)
    _, meta = build_modular_graph(k)
    wraps_on_cycle = []
    loss_on_cycle = []
    exact_nat = True
    for i, u in enumerate(cycle):
        v = cycle[(i + 1) % len(cycle)]
        t = meta[u]
        if t.wraps:
            wraps_on_cycle.append({"from": u, "to": v, "exact": t.exact_target})
            exact_nat = False
        if t.precision_loss:
            loss_on_cycle.append({"from": u, "to": v, "valuation": t.valuation})
            exact_nat = False
        if t.modular_target != v:
            exact_nat = False
        if t.exact_target != v:
            # modular cycle edge is not the exact integer Syracuse image
            exact_nat = False
    return {
        "lifts_projectively_to_k1_cycle": bool(matches),
        "matching_k1_cycles": matches,
        "is_exact_N_orbit_on_canonical_reps": exact_nat,
        "wrap_edges_on_cycle": wraps_on_cycle,
        "precision_loss_edges_on_cycle": loss_on_cycle,
        "edge_lifts": [
            edge_lift_check(cycle[i], cycle[(i + 1) % len(cycle)], k) for i in range(len(cycle))
        ],
    }


def relational_self_loop_note(k: int) -> dict:
    """Lean-aligned relational ascent has a self-loop at 2^k−1; surgery here does not cut it."""
    residue = (1 << k) - 1
    exact, val = odd_syracuse(residue)
    return {
        "k": k,
        "self_loop_residue": residue,
        "exact_T": exact,
        "T_mod": exact % (1 << k),
        "valuation": val,
        "note": (
            "Relational Lean CollatzDigraph ascent digraph retains a self-loop at 2^k-1; "
            "functional avoid-1 surgery does not remove that relational residue loop."
        ),
    }


def _cycle_edge_report(cycle: Sequence[int], metadata: Dict[int, Transition]) -> list[dict]:
    edges = []
    for i, u in enumerate(cycle):
        v = cycle[(i + 1) % len(cycle)]
        t = metadata[u]
        edges.append(
            {
                "from": u,
                "to": v,
                "exact_target": t.exact_target,
                "modular_target": t.modular_target,
                "valuation": t.valuation,
                "wraps": t.wraps,
                "precision_loss": t.precision_loss,
            }
        )
    return edges


def audit_level(k: int) -> dict:
    nodes = list(range(1, 1 << k, 2))
    graph, meta = build_modular_graph(k)
    cycles = find_cycles(graph)
    rho_cycle = 1 if cycles else 0
    rho_spec = spectral_radius_functional(graph, nodes)

    cycle_reports = []
    for c in cycles:
        edges = _cycle_edge_report(c, meta)
        n_wrap = sum(1 for e in edges if e["wraps"])
        n_loss = sum(1 for e in edges if e["precision_loss"])
        lift = cycle_projective_lift(c, k)
        cycle_reports.append(
            {
                "length": len(c),
                "nodes": list(c),
                "edges": edges,
                "n_wrap_edges": n_wrap,
                "n_precision_loss_edges": n_loss,
                "has_wrap": n_wrap > 0,
                "has_precision_loss": n_loss > 0,
                "liftability": lift,
            }
        )

    cut, n_cut, n_wrap_cut, n_loss_cut = cut_graph(graph, meta)
    cut_cycles = find_cycles(cut)
    rho_cut_cycle = 1 if cut_cycles else 0
    rho_cut_spec = spectral_radius_functional(cut, nodes)

    wrap_on_cycles = sum(cr["n_wrap_edges"] for cr in cycle_reports)

    return {
        "k": k,
        "mod": 1 << k,
        "n_vertices": len(nodes),
        "n_edges": len(graph),
        "rho": rho_cycle,
        "rho_spectral": rho_spec,
        "n_cycles": len(cycles),
        "cycle_lengths": [len(c) for c in cycles],
        "wrap_edges_on_cycles": wrap_on_cycles,
        "cycles": cycle_reports,
        "surgery": {
            "n_edges_cut": n_cut,
            "n_edges_cut_wrap": n_wrap_cut,
            "n_edges_cut_precision_loss": n_loss_cut,
            "n_edges_remaining": len(cut),
            "rho_cut": rho_cut_cycle,
            "rho_cut_spectral": rho_cut_spec,
            "n_cycles_cut": len(cut_cycles),
            "cycle_lengths_cut": [len(c) for c in cut_cycles],
            "rho_cut_is_zero": rho_cut_cycle == 0,
        },
        "relational_lean_contrast": relational_self_loop_note(k),
    }


def run_audit(k_min: int = 2, k_max: int = 12) -> dict:
    levels = [audit_level(k) for k in range(k_min, k_max + 1)]
    surgery_all_zero = all(L["surgery"]["rho_cut_is_zero"] for L in levels)
    cycles_with_wrap = []
    for L in levels:
        for c in L["cycles"]:
            cycles_with_wrap.append(
                {
                    "k": L["k"],
                    "length": c["length"],
                    "has_wrap": c["has_wrap"],
                    "has_precision_loss": c["has_precision_loss"],
                    "lifts_projectively": c["liftability"]["lifts_projectively_to_k1_cycle"],
                    "is_exact_N_orbit": c["liftability"]["is_exact_N_orbit_on_canonical_reps"],
                    "wrap_edges": c["liftability"]["wrap_edges_on_cycle"],
                }
            )

    # Verify user table claims for k=10,11,12
    by_k = {L["k"]: L for L in levels}
    user_table_checks = {}
    if 10 in by_k:
        L = by_k[10]
        wrap_edges = []
        for c in L["cycles"]:
            for e in c["edges"]:
                if e["wraps"]:
                    wrap_edges.append((e["from"], e["to"], e["exact_target"]))
        user_table_checks["k10"] = {
            "claimed": {"rho": 1, "n_cycles": 1, "lengths": [26], "wrap": "719→55"},
            "observed": {
                "rho": L["rho"],
                "n_cycles": L["n_cycles"],
                "lengths": L["cycle_lengths"],
                "wrap_edges": wrap_edges,
            },
            "matches": (
                L["rho"] == 1
                and L["n_cycles"] == 1
                and L["cycle_lengths"] == [26]
                and any(a == 719 and b == 55 for a, b, _ in wrap_edges)
            ),
        }
    if 11 in by_k:
        L = by_k[11]
        wrap_edges = []
        for c in L["cycles"]:
            for e in c["edges"]:
                if e["wraps"]:
                    wrap_edges.append((e["from"], e["to"], e["exact_target"]))
        user_table_checks["k11"] = {
            "claimed": {"rho": 1, "n_cycles": 1, "lengths": [26], "wrap": "1743→1079"},
            "observed": {
                "rho": L["rho"],
                "n_cycles": L["n_cycles"],
                "lengths": L["cycle_lengths"],
                "wrap_edges": wrap_edges,
            },
            "matches": (
                L["rho"] == 1
                and L["n_cycles"] == 1
                and L["cycle_lengths"] == [26]
                and any(a == 1743 and b == 1079 for a, b, _ in wrap_edges)
            ),
        }
    if 12 in by_k:
        L = by_k[12]
        wrap_edges = []
        for c in L["cycles"]:
            for e in c["edges"]:
                if e["wraps"]:
                    wrap_edges.append((e["from"], e["to"], e["exact_target"]))
        user_table_checks["k12"] = {
            "claimed": {"rho": 1, "n_cycles": 2, "lengths": [26, 12], "wrap_count": 2},
            "observed": {
                "rho": L["rho"],
                "n_cycles": L["n_cycles"],
                "lengths": L["cycle_lengths"],
                "wrap_edges": wrap_edges,
                "wrap_edges_on_cycles": L["wrap_edges_on_cycles"],
            },
            "matches": (
                L["rho"] == 1
                and L["n_cycles"] == 2
                and sorted(L["cycle_lengths"]) == [12, 26]
                and L["wrap_edges_on_cycles"] >= 2
                and any(a == 1743 and b == 1079 for a, b, _ in wrap_edges)
            ),
        }

    primary_max = min(k_max, 12)
    surgery_primary = all(
        L["surgery"]["rho_cut_is_zero"] for L in levels if 2 <= L["k"] <= primary_max
    )

    return {
        "status": "B finite-k modular wrap/surgery diagnostic only",
        "claim_wall": {
            "tag": "B",
            "final_system": {
                "A": (
                    "Lean CollatzDigraph: genuine ascent-only cycles in {3,7,11,15} "
                    "excluded; residue self-loop 15→15 / u=2^k−1 separated "
                    "(not an N fixed point). See docs/eabc_collatz_audit_grid.md §5.12/§5.14."
                ),
                "B": (
                    "Python finite-k wrap surgery: F_k=π_k∘T∘s_k (avoid-1); "
                    "G_k^cut = G_k \\ (E_wrap ∪ E_loss); A_k^cut nilpotent / ρ=0 "
                    "for k∈[2,12]; cycles only k=10 C_26 (719↦1079≡55), "
                    "k=11 C_25 (1619↦2429≡381), k=12 lengths 7,6."
                ),
                "C": (
                    "OPEN: ∀k≥2 G_k^cut acyclic; no projective universal claim; "
                    "no Ricci metaphor; no Lean theorem for universal surgery."
                ),
            },
            "verified_range_primary": "k∈[2,12]",
            "verified_range_extended": f"k∈[{k_min},{k_max}]",
            "surgery_rho_cut_zero_primary": surgery_primary,
            "surgery_rho_cut_zero_extended": surgery_all_zero,
            "A_cut_nilpotent_primary": surgery_primary,
            "universal_surgery_forall_k": "OPEN / Non-Claim — not proven here",
            "non_claims": [
                "no Collatz theorem",
                "no infinite N avoidance",
                "no Ricci / Perelman metaphor as mathematics",
                "cutting wrap edges does not prove absence of N cycles",
                "not Lean CollatzDigraph [A] (relational half-steps; 15→15 residue loop exists)",
                "do not write unqualified 'ascent-only cycles formally excluded' without 15-loop nuance",
                "rho(A_cut)=0 / nilpotency verified only on the finite range above, not ∀k≥2",
                "no Lean theorem for universal surgery",
            ],
            "distinction": (
                "This audits the functional graph F_k=π_k∘T∘s_k (avoid-1). "
                "Lean CollatzDigraph is relational multi-valued half-steps on ascent classes; "
                "surgery does not remove the relational 15→15 / 2^k−1 self-loop."
            ),
        },
        "user_table_note": (
            "Claimed preview table: k=10 C_26 with wrap 719→55 CONFIRMED; "
            "k=11 claimed C_26 / 1743→1079 REJECTED (observed C_25 wrap 1619→381; "
            "1743 wraps to 567 and only feeds into the cycle); "
            "k=12 claimed [26,12] REJECTED (observed [7,6] with wraps 3563→1249, 3311→871). "
            "Cheap extension: k=13,14 again acyclic (ρ=0) before surgery."
        ),
        "definitions": {
            "F_k": "π_k ∘ T ∘ s_k on odd residues; one out-edge; drop target≡1",
            "wraps": "exact_target = T(u) >= 2^k",
            "precision_loss": "ν₂(3u+1) >= k (successor depends on lift)",
            "S_k": "E_wrap ∪ E_loss",
            "rho": "1 iff directed cycle exists (functional digraph ⇒ ρ∈{0,1})",
            "surgery": "remove edges in S_k; recompute cycles / ρ",
        },
        "k_min": k_min,
        "k_max": k_max,
        "summary_table": [
            {
                "k": L["k"],
                "rho": L["rho"],
                "n_cycles": L["n_cycles"],
                "cycle_lengths": L["cycle_lengths"],
                "wrap_edges_on_cycles": L["wrap_edges_on_cycles"],
                "n_edges_cut": L["surgery"]["n_edges_cut"],
                "rho_cut": L["surgery"]["rho_cut"],
            }
            for L in levels
        ],
        "user_table_verification": user_table_checks,
        "surgery_rho_cut_zero_on_range": surgery_all_zero,
        "cycle_liftability_summary": cycles_with_wrap,
        "levels": levels,
    }


def export_report(report: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def main(argv: Optional[Sequence[str]] = None) -> int:
    p = argparse.ArgumentParser(description="EABC modular wrap surgery audit [B]")
    p.add_argument("--k-min", type=int, default=2)
    p.add_argument("--k-max", type=int, default=12)
    p.add_argument(
        "--out",
        type=Path,
        default=Path("docs/exports/eabc_modular_wrap_surgery_report.json"),
    )
    args = p.parse_args(argv)
    report = run_audit(args.k_min, args.k_max)
    export_report(report, args.out)

    print(
        f"{'Stufe k':<8} | {'rho':<5} | {'#Zyklen':<8} | {'Längen':<16} | "
        f"{'Wrap@C':<8} | {'#cut':<6} | {'rho_cut':<7}"
    )
    print("-" * 78)
    for row in report["summary_table"]:
        print(
            f"k = {row['k']:<4} | {row['rho']:<5} | {row['n_cycles']:<8} | "
            f"{str(row['cycle_lengths']):<16} | {row['wrap_edges_on_cycles']:<8} | "
            f"{row['n_edges_cut']:<6} | {row['rho_cut']:<7}"
        )
    print()
    print(f"surgery ρ_cut=0 on range: {report['surgery_rho_cut_zero_on_range']}")
    print(f"user_table_verification: {json.dumps(report['user_table_verification'], indent=2)}")
    print(f"wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
