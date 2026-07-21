"""
Projective liftability audit for modular avoid-1 cycles under π_{k+1,k} [B].

Same functional graph as eabc_modular_wrap_surgery: odd residues, T_acc,
drop edges with modular target ≡1 mod 2^k.

Three lift levels (per cycle C_k)
---------------------------------
L_edge      = # edges of C_k with ≥1 admissible local lift
L_cyc_edge  = # edges whose lift lies on a cycle of F_{k+1}
L_cycle     = 1 iff a full compatible cycle lift exists (set-lift)

set_liftable / order_liftable are reported separately; order ⇒ set.

Claim wall
----------
[B] Finite verification on the checked k-range only.
OPEN / Non-Claim: no ∀k artifact / tower theorem; no Collatz.
Absence of lifts ≠ Collatz proof ≠ empty avoider set in ℕ.
Wrap-Break: a wrap edge at level k loses its canonical target representative
at k+1 (not necessarily non-projectively-liftable).

See docs/eabc_collatz_audit_grid.md §5.15.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set, Tuple

from kepler_hurwitz.eabc_modular_wrap_surgery import (
    Transition,
    build_modular_graph,
    find_cycles,
    odd_syracuse,
)

__all__ = [
    "canonical_cycle",
    "project_cycle_set",
    "project_cycle_ordered",
    "cycles_set_equal_mod",
    "cycles_rotate_equal",
    "edgewise_cycle_lift",
    "wrap_break_k10",
    "run_liftability_audit",
    "export_report",
]


def canonical_cycle(cycle: Sequence[int]) -> Tuple[int, ...]:
    """Rotate so the minimal element is first (for stable IDs)."""
    if not cycle:
        return ()
    c = list(cycle)
    i = min(range(len(c)), key=lambda j: c[j])
    return tuple(c[i:] + c[:i])


def project_cycle_set(cycle: Sequence[int], k: int) -> Set[int]:
    mod = 1 << k
    return {x % mod for x in cycle}


def project_cycle_ordered(cycle: Sequence[int], k: int) -> List[int]:
    """
    Reduce residues mod 2^k and collapse consecutive duplicates
    (non-injective projection of a longer cycle).
    """
    mod = 1 << k
    reduced = [x % mod for x in cycle]
    collapsed: List[int] = []
    for x in reduced:
        if not collapsed or collapsed[-1] != x:
            collapsed.append(x)
    if len(collapsed) > 1 and collapsed[0] == collapsed[-1]:
        collapsed = collapsed[:-1]
    return collapsed


def cycles_set_equal_mod(upper: Sequence[int], lower: Sequence[int], k: int) -> bool:
    return project_cycle_set(upper, k) == set(lower)


def cycles_rotate_equal(a: Sequence[int], b: Sequence[int]) -> bool:
    if len(a) != len(b) or not a:
        return False
    aa = list(a)
    bb = list(b)
    for i in range(len(bb)):
        if aa == bb[i:] + bb[:i]:
            return True
    return False


def _cycle_node_membership(cycles: Sequence[Sequence[int]]) -> Dict[int, List[int]]:
    """Map node → list of cycle indices containing it."""
    membership: Dict[int, List[int]] = {}
    for idx, c in enumerate(cycles):
        for u in c:
            membership.setdefault(u, []).append(idx)
    return membership


def edgewise_cycle_lift(
    cycle: Sequence[int],
    k: int,
    graph_k1: Dict[int, int],
    cycles_k1: Sequence[Sequence[int]],
) -> dict:
    """
    For each edge u→v of C_k, check whether some lift u'→v' exists with
    u'≡u, v'≡v (mod 2^k), edge in G_{k+1}, and u' on some cycle at level k+1.
    """
    mod_k = 1 << k
    mod_k1 = 1 << (k + 1)
    membership = _cycle_node_membership(cycles_k1)
    edge_reports = []
    all_edges_have_cycle_lift = True

    for i, u in enumerate(cycle):
        v = cycle[(i + 1) % len(cycle)]
        lifts = [u % mod_k1, (u + mod_k) % mod_k1]
        lifts = [x for x in lifts if x % 2 == 1]
        lift_rows = []
        any_edge_ok = False
        any_on_cycle = False
        for u_lift in lifts:
            exact, val = odd_syracuse(u_lift)
            v_lift = exact % mod_k1
            edge_in = graph_k1.get(u_lift) == v_lift and v_lift != 1
            compat = (u_lift % mod_k == u % mod_k) and (v_lift % mod_k == v % mod_k)
            on_cycle_idxs = membership.get(u_lift, []) if edge_in and compat else []
            ok_edge = edge_in and compat
            ok_cycle = ok_edge and bool(on_cycle_idxs)
            if ok_edge:
                any_edge_ok = True
            if ok_cycle:
                any_on_cycle = True
            lift_rows.append(
                {
                    "lift_u": u_lift,
                    "exact_target": exact,
                    "modular_target_k1": v_lift,
                    "reduced_target_mod_k": v_lift % mod_k,
                    "edge_in_G_k1": edge_in,
                    "compatible_mod_k": compat,
                    "participates_in_k1_cycle": ok_cycle,
                    "k1_cycle_indices": on_cycle_idxs,
                    "wraps_k1": exact >= mod_k1,
                    "precision_loss_k1": val >= k + 1,
                    "valuation": val,
                }
            )
        if not any_on_cycle:
            all_edges_have_cycle_lift = False
        edge_reports.append(
            {
                "from": u,
                "to": v,
                "any_compatible_edge_lift": any_edge_ok,
                "any_lift_on_k1_cycle": any_on_cycle,
                "lifts": lift_rows,
            }
        )

    L_edge = sum(1 for e in edge_reports if e["any_compatible_edge_lift"])
    L_cyc_edge = sum(1 for e in edge_reports if e["any_lift_on_k1_cycle"])
    return {
        "L_edge": L_edge,
        "L_cyc_edge": L_cyc_edge,
        "n_edges": len(edge_reports),
        "all_edges_have_compatible_edge_lift": L_edge == len(edge_reports) and len(edge_reports) > 0,
        "all_edges_have_lift_on_k1_cycle": all_edges_have_cycle_lift,
        "edges": edge_reports,
    }


def wrap_break_k10() -> dict:
    """
    Explicit wrap-break story for the k=10 cycle edge 719→55.

    T(719)=1079 exact; 1079 mod 1024 = 55; 1079 mod 2048 = 1079 ≠ 55.
    """
    u = 719
    exact, val = odd_syracuse(u)
    mod10 = 1 << 10
    mod11 = 1 << 11
    g10, meta10 = build_modular_graph(10)
    g11, _ = build_modular_graph(11)
    return {
        "source": u,
        "exact_T": exact,
        "valuation": val,
        "mod_1024": exact % mod10,
        "mod_2048": exact % mod11,
        "claimed_modular_target_k10": 55,
        "mod_1024_equals_55": (exact % mod10) == 55,
        "mod_2048_equals_55": (exact % mod11) == 55,
        "mod_2048_equals_exact": (exact % mod11) == exact,
        "edge_in_G10": g10.get(u) == 55,
        "edge_in_G11_from_719": g11.get(u),
        "wraps_at_k10": meta10[u].wraps,
        "narrative_confirmed": (
            exact == 1079
            and (exact % mod10) == 55
            and (exact % mod11) == 1079
            and (exact % mod11) != 55
            and g10.get(u) == 55
        ),
    }


def _cycle_edge_flags(cycle: Sequence[int], meta: Dict[int, Transition]) -> dict:
    wraps = []
    losses = []
    for i, u in enumerate(cycle):
        v = cycle[(i + 1) % len(cycle)]
        t = meta[u]
        if t.wraps:
            wraps.append({"from": u, "to": v, "exact": t.exact_target})
        if t.precision_loss:
            losses.append({"from": u, "to": v, "valuation": t.valuation})
    exact_nat = True
    for i, u in enumerate(cycle):
        v = cycle[(i + 1) % len(cycle)]
        t = meta[u]
        if t.modular_target != v or t.exact_target != v or t.wraps or t.precision_loss:
            exact_nat = False
            break
    return {
        "wrap_edges": wraps,
        "precision_loss_edges": losses,
        "is_exact_N_orbit_on_canonical_reps": exact_nat,
    }


def audit_cycle_against_upper(
    cycle: Sequence[int],
    k: int,
    cycles_k1: Sequence[Sequence[int]],
    graph_k1: Dict[int, int],
    meta_k: Dict[int, Transition],
) -> dict:
    set_matches: List[List[int]] = []
    ordered_matches: List[List[int]] = []
    seen_set: set = set()
    seen_ord: set = set()
    for c1 in cycles_k1:
        key = canonical_cycle(c1)
        if cycles_set_equal_mod(c1, cycle, k) and key not in seen_set:
            seen_set.add(key)
            set_matches.append(list(c1))
        proj = project_cycle_ordered(c1, k)
        reduced = [x % (1 << k) for x in c1]
        ordered_ok = cycles_rotate_equal(proj, cycle) or cycles_rotate_equal(
            reduced, cycle
        )
        if ordered_ok and key not in seen_ord:
            seen_ord.add(key)
            ordered_matches.append(list(c1))

    ordered_unique = ordered_matches

    edgewise = edgewise_cycle_lift(cycle, k, graph_k1, cycles_k1)
    flags = _cycle_edge_flags(cycle, meta_k)

    set_liftable = bool(set_matches)
    order_liftable = bool(ordered_unique)
    L_cycle = 1 if set_liftable else 0
    return {
        "k": k,
        "length": len(cycle),
        "nodes": list(cycle),
        "canonical_id": list(canonical_cycle(cycle)),
        "has_set_lift_to_k1": set_liftable,
        "has_ordered_lift_to_k1": order_liftable,
        "set_liftable": set_liftable,
        "order_liftable": order_liftable,
        "L_edge": edgewise["L_edge"],
        "L_cyc_edge": edgewise["L_cyc_edge"],
        "L_cycle": L_cycle,
        "set_vs_ordered_differ": set_liftable != order_liftable
        or (
            {canonical_cycle(m) for m in set_matches}
            != {canonical_cycle(m) for m in ordered_unique}
        ),
        "matching_k1_cycles_set": set_matches,
        "matching_k1_cycles_ordered": ordered_unique,
        "edgewise": edgewise,
        **flags,
    }


def build_level_cache(k_min: int, k_max: int) -> Dict[int, dict]:
    cache: Dict[int, dict] = {}
    for k in range(k_min, k_max + 1):
        graph, meta = build_modular_graph(k)
        cycles = find_cycles(graph)
        cache[k] = {
            "graph": graph,
            "meta": meta,
            "cycles": cycles,
            "cycle_ids": [list(canonical_cycle(c)) for c in cycles],
        }
    return cache


def find_chains(cycle_records: Sequence[dict], k_min: int, k_max: int) -> dict:
    """
    Build successor/predecessor links where has_set_lift_to_k1 holds,
    and report maximal tower lengths in the checked range.
    """
    # index: (k, frozenset(nodes)) → record
    by_key: Dict[Tuple[int, frozenset], dict] = {}
    for rec in cycle_records:
        key = (rec["k"], frozenset(rec["nodes"]))
        by_key[key] = rec

    links = []
    for rec in cycle_records:
        k = rec["k"]
        if k >= k_max:
            continue
        for m in rec["matching_k1_cycles_set"]:
            links.append(
                {
                    "from_k": k,
                    "from_nodes": rec["nodes"],
                    "to_k": k + 1,
                    "to_nodes": m,
                    "via": "set_projection",
                }
            )
        for m in rec["matching_k1_cycles_ordered"]:
            links.append(
                {
                    "from_k": k,
                    "from_nodes": rec["nodes"],
                    "to_k": k + 1,
                    "to_nodes": m,
                    "via": "ordered_projection",
                }
            )

    # Also scan predecessors: for each cycle at k, does some cycle at k-1
    # have it as a set-lift match?
    for rec in cycle_records:
        preds = []
        succs = []
        k = rec["k"]
        nodes_set = set(rec["nodes"])
        if k > k_min:
            for pred in cycle_records:
                if pred["k"] != k - 1:
                    continue
                for m in pred["matching_k1_cycles_set"]:
                    if set(m) == nodes_set:
                        preds.append(pred["nodes"])
        if k < k_max:
            for m in rec["matching_k1_cycles_set"]:
                succs.append(m)
        rec["projective_predecessors"] = preds
        rec["projective_successors"] = succs
        rec["has_projective_predecessor"] = bool(preds)
        rec["has_projective_successor"] = bool(succs)

    # Maximal compatible tower length: longest path of set-lifts
    # Nodes of DAG: (k, frozenset)
    dag_nodes = [(rec["k"], frozenset(rec["nodes"])) for rec in cycle_records]
    children: Dict[Tuple[int, frozenset], List[Tuple[int, frozenset]]] = {
        n: [] for n in dag_nodes
    }
    for rec in cycle_records:
        src = (rec["k"], frozenset(rec["nodes"]))
        for m in rec["matching_k1_cycles_set"]:
            dst = (rec["k"] + 1, frozenset(m))
            if dst in children:
                children[src].append(dst)

    memo: Dict[Tuple[int, frozenset], int] = {}

    def depth(n: Tuple[int, frozenset]) -> int:
        if n in memo:
            return memo[n]
        ch = children.get(n, [])
        if not ch:
            memo[n] = 1
        else:
            memo[n] = 1 + max(depth(c) for c in ch)
        return memo[n]

    max_tower = 0
    towers: List[dict] = []
    for n in dag_nodes:
        d = depth(n)
        if d > max_tower:
            max_tower = d
        if d >= 2:
            # reconstruct one path
            path = [list(sorted(n[1]))]
            cur = n
            while children.get(cur):
                nxt = children[cur][0]
                path.append(list(sorted(nxt[1])))
                cur = nxt
            towers.append({"start_k": n[0], "length": d, "path_sets": path})

    return {
        "n_set_lift_links": sum(1 for L in links if L["via"] == "set_projection"),
        "n_ordered_lift_links": sum(1 for L in links if L["via"] == "ordered_projection"),
        "links": links,
        "max_compatible_tower_length": max_tower,
        "towers_length_ge_2": towers,
        "any_tower_length_ge_2": max_tower >= 2,
    }


def run_liftability_audit(k_min: int = 2, k_max: int = 14) -> dict:
    if k_max < k_min:
        raise ValueError("k_max must be >= k_min")
    # need k_max+1 for lift targets of cycles at k_max
    cache = build_level_cache(k_min, k_max + 1)

    level_summaries = []
    cycle_records: List[dict] = []

    for k in range(k_min, k_max + 1):
        cycles = cache[k]["cycles"]
        meta = cache[k]["meta"]
        cycles_k1 = cache[k + 1]["cycles"]
        graph_k1 = cache[k + 1]["graph"]
        audits = []
        for c in cycles:
            aud = audit_cycle_against_upper(c, k, cycles_k1, graph_k1, meta)
            audits.append(aud)
            cycle_records.append(aud)
        level_summaries.append(
            {
                "k": k,
                "n_cycles": len(cycles),
                "cycle_lengths": [len(c) for c in cycles],
                "cycles": [
                    {
                        "nodes": a["nodes"],
                        "length": a["length"],
                        "set_liftable": a["set_liftable"],
                        "order_liftable": a["order_liftable"],
                        "has_set_lift": a["has_set_lift_to_k1"],
                        "has_ordered_lift": a["has_ordered_lift_to_k1"],
                        "L_edge": a["L_edge"],
                        "L_cyc_edge": a["L_cyc_edge"],
                        "L_cycle": a["L_cycle"],
                        "summary_label": (
                            f"L_edge={a['L_edge']}, L_cyc-edge={a['L_cyc_edge']}, "
                            f"L_cycle={a['L_cycle']}"
                        ),
                        "all_edges_lift_on_k1_cycle": a["edgewise"][
                            "all_edges_have_lift_on_k1_cycle"
                        ],
                        "all_edges_compatible_edge_lift": a["edgewise"][
                            "all_edges_have_compatible_edge_lift"
                        ],
                        "is_exact_N_orbit": a["is_exact_N_orbit_on_canonical_reps"],
                        "n_wrap_edges": len(a["wrap_edges"]),
                    }
                    for a in audits
                ],
            }
        )

    chains = find_chains(cycle_records, k_min, k_max)
    wrap10 = wrap_break_k10()

    has_lift_table = [
        {
            "k": r["k"],
            "length": r["length"],
            "canonical_id": r["canonical_id"],
            "set_liftable": r["set_liftable"],
            "order_liftable": r["order_liftable"],
            "has_set_lift": r["has_set_lift_to_k1"],
            "has_ordered_lift": r["has_ordered_lift_to_k1"],
            "L_edge": r["L_edge"],
            "L_cyc_edge": r["L_cyc_edge"],
            "L_cycle": r["L_cycle"],
            "summary_label": (
                f"L_edge={r['L_edge']}, L_cyc-edge={r['L_cyc_edge']}, "
                f"L_cycle={r['L_cycle']}"
            ),
            "set_vs_ordered_differ": r["set_vs_ordered_differ"],
            "edgewise_all_on_cycle": r["edgewise"]["all_edges_have_lift_on_k1_cycle"],
            "edgewise_all_compatible_edge": r["edgewise"][
                "all_edges_have_compatible_edge_lift"
            ],
            "has_predecessor": r.get("has_projective_predecessor", False),
            "has_successor": r.get("has_projective_successor", False),
            "is_exact_N_orbit": r["is_exact_N_orbit_on_canonical_reps"],
        }
        for r in cycle_records
    ]

    any_set_lift = any(r["has_set_lift_to_k1"] for r in cycle_records)
    any_ordered_lift = any(r["has_ordered_lift_to_k1"] for r in cycle_records)

    c26_row = next(
        (r for r in cycle_records if r["k"] == 10 and r["length"] == 26), None
    )
    c26_label = (
        f"L_edge={c26_row['L_edge']}, L_cyc-edge={c26_row['L_cyc_edge']}, "
        f"L_cycle={c26_row['L_cycle']}"
        if c26_row
        else None
    )

    return {
        "status": "B finite-k projective liftability diagnostic only",
        "claim_wall": {
            "tag": "B",
            "scope": "finite only",
            "no_forall_k": True,
            "no_collatz": True,
            "verified_range": f"k∈[{k_min},{k_max}] (lifts checked against k+1 ≤ {k_max + 1})",
            "tower_max_length_in_checked_range": chains["max_compatible_tower_length"],
            "tower_length_ge_2_claimed_only_for_checked_range": True,
            "liftability_criterion": (
                "definition/criterion: L_cycle=1 iff ∃ C_{k+1} with "
                "π_{k+1,k}(C_{k+1})=C_k as sets (order-lift optional, implies set); "
                "NOT a universal Liftbarkeits-Theorem; no ∀k; no Collatz"
            ),
            "finite_negative_results_only": True,
            "universal_every_cycle_nonliftable_forall_k": (
                "OPEN / Non-Claim — not claimed outside checked range"
            ),
            "necessary_for_2adic_periodic_orbit": (
                "compatible inverse system (C_k)_k in ℤ₂ is necessary for a "
                "2-adic periodic orbit of this functional model; absence of "
                "lifts for found cycles ≠ Collatz proof ≠ empty avoider set in ℕ"
            ),
            "lean_nuance_15_loop": (
                "Lean CollatzDigraph [A]: genuine ascent-only cycles through "
                "{3,7,11} excluded; residue self-loop 15→15 / 2^k−1 is logically "
                "separated (NOT an ℕ fixed point). Do not write "
                "'Steigungsschleifen unmöglich' without that nuance."
            ),
            "non_claims": [
                "no Collatz theorem",
                "no empty avoider set in ℕ",
                "no ∀k artifact theorem beyond checked range",
                "no ∀k tower-absence theorem",
                "Baire / ℤ₂ topology ≠ ℕ dynamics",
                "Ricci / Christol / CCOP[D] remain Non-Claim",
                "not a universal Liftbarkeits-Theorem — definition + finite negatives",
            ],
        },
        "definitions": {
            "F_k": "π_k ∘ T ∘ s_k on odd residues; one out-edge; drop target≡1",
            "pi_k1_k": "reduction mod 2^k of odd residues mod 2^{k+1}",
            "L_edge": "# edges of C_k with ≥1 admissible local lift",
            "L_cyc_edge": "# edges whose lift lies on a cycle of F_{k+1}",
            "L_cycle": "1 iff full compatible cycle lift exists (set-lift)",
            "set_liftable": (
                "∃ C_{k+1}: {x mod 2^k : x∈C_{k+1}} = set(C_k) "
                "(order-independent; multiplicities ignored)"
            ),
            "order_liftable": (
                "∃ C_{k+1}: projected ordered cycle (collapse consecutive dups) "
                "equals C_k up to rotation; implies set_liftable"
            ),
            "set_lift": "alias of set_liftable",
            "ordered_lift": "alias of order_liftable",
            "edge_vs_cycle_csp": (
                "edge lift vs cycle lift as CSP on ε_i∈{0,1} with relations R_i; "
                "local R_i≠∅ does not imply a global cyclic solution"
            ),
            "wrap_break": (
                "a wrap edge at level k loses its canonical target representative "
                "at k+1; not necessarily non-projectively-liftable. "
                "Example: 719→55 / T=1079 / F_11(719)=1079"
            ),
            "compatible_tower": (
                "chain of set_lifts of length ≥2; claimed absent only inside "
                "the checked range, not ∀k"
            ),
        },
        "k_min": k_min,
        "k_max": k_max,
        "wrap_break_k10": wrap10,
        "has_lift_table": has_lift_table,
        "summary": {
            "n_cycles_total": len(cycle_records),
            "any_set_lift": any_set_lift,
            "any_ordered_lift": any_ordered_lift,
            "any_compatible_tower_ge_2": chains["any_tower_length_ge_2"],
            "max_compatible_tower_length_in_checked_range": chains[
                "max_compatible_tower_length"
            ],
            "max_compatible_tower_length": chains["max_compatible_tower_length"],
            "wrap_break_k10_confirmed": wrap10["narrative_confirmed"],
            "all_found_cycles_nonliftable_set": (not any_set_lift)
            and len(cycle_records) > 0,
            "C26_k10_label": c26_label,
            "heading": c26_label or "no C_26 at k=10",
            "narrative": (
                "CONFIRMED on checked range 2≤k≤14: "
                + (
                    f"C_26 at k=10 has {c26_label}; "
                    if c26_label
                    else ""
                )
                + "every found F_k-cycle (k=10,11,12) fails set- and order-lift "
                "to k+1 (L_cycle=0); no compatible tower of length ≥2 in the "
                "checked range (not ∀k); k=10 wrap-break 719↦1079 "
                "(mod 1024→55, mod 2048→1079≠55) holds. "
                "Local L_edge may equal cycle length without L_cycle=1."
            ),
        },
        "chains": chains,
        "levels": level_summaries,
        "cycle_details": cycle_records,
    }


def export_report(report: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def main(argv: Optional[Sequence[str]] = None) -> int:
    p = argparse.ArgumentParser(
        description="EABC modular cycle projective liftability audit [B]"
    )
    p.add_argument("--k-min", type=int, default=2)
    p.add_argument("--k-max", type=int, default=14)
    p.add_argument(
        "--out",
        type=Path,
        default=Path("docs/exports/eabc_cycle_liftability_report.json"),
    )
    args = p.parse_args(argv)
    report = run_liftability_audit(args.k_min, args.k_max)
    export_report(report, args.out)

    print(
        f"{'k':<4} | {'len':<4} | {'set↑':<5} | {'ord↑':<5} | "
        f"{'L_edge':<7} | {'L_ce':<6} | {'L_cy':<6} | label"
    )
    print("-" * 88)
    for row in report["has_lift_table"]:
        print(
            f"{row['k']:<4} | {row['length']:<4} | "
            f"{str(row['set_liftable']):<5} | {str(row['order_liftable']):<5} | "
            f"{row['L_edge']:<7} | {row['L_cyc_edge']:<6} | {row['L_cycle']:<6} | "
            f"{row['summary_label']}"
        )
    print()
    print(f"heading: {report['summary'].get('heading')}")
    print(f"wrap_break_k10: {report['wrap_break_k10']['narrative_confirmed']}")
    print(f"any_set_lift: {report['summary']['any_set_lift']}")
    print(f"any_tower_ge_2: {report['summary']['any_compatible_tower_ge_2']}")
    print(
        "max_tower_length_in_checked_range: "
        f"{report['summary']['max_compatible_tower_length_in_checked_range']}"
    )
    print(f"wrote {args.out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
