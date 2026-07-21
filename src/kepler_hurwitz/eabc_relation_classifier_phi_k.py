"""
Arithmetic relation classifier Φ_k(u) for modular Syracuse edges [B] / §5.22.

Stated (valuation-only) classifier from the research sketch:

    Φ_k^stated(u) = E01  if ν₂(3u+1) = 1
                  = E00  if 2 ≤ ν₂(3u+1) < k
                  = Z    if ν₂(3u+1) ≥ k

Audit finding (honest): on wrap-/loss-free edges of G_k^cut the stated map
does **not** match the edge lift-matrix — every such edge is E00 (including
ν₂=1). The wrap-aware refinement matches all F_k edges in the checked range:

    Φ_k^ref(u) = E01  if wrap ∧ ν₂=1
               = E00  if ¬wrap ∧ 1 ≤ ν₂ < k
               = Z    if ν₂ ≥ k (precision loss; usually dropped in avoid-1)

Focus cycles live in F_k (not G_k^cut); each has exactly one wrap edge (=E01)
and word ∼_cyc E00^{ℓ−1} ⊙ E01 → BoolTrace=0 (links to §5.19/§5.20 Lean under
MatchesUnitDefectPattern; no Collatz claim).

See docs/eabc_collatz_audit_grid.md §5.22.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Tuple

from kepler_hurwitz.eabc_cycle_liftability import build_level_cache, canonical_cycle
from kepler_hurwitz.eabc_lift_coherence import (
    MAT_E00,
    MAT_E01,
    MAT_Z,
    bool_product,
    bool_trace,
    classify_bool_matrix,
    edge_relation,
    matrices_equal,
    relation_matrix,
)
from kepler_hurwitz.eabc_modular_wrap_surgery import (
    Transition,
    build_modular_graph,
    cut_graph,
    find_cycles,
    odd_syracuse,
)

__all__ = [
    "phi_k_stated",
    "phi_k_refined",
    "v2_3u1",
    "edge_lift_type",
    "is_cyclic_E00_power_E01",
    "run_phi_k_audit",
    "export_report",
    "FOCUS_SPECS",
]

Matrix2 = List[List[int]]

FOCUS_SPECS: Tuple[Tuple[int, int], ...] = (
    (10, 26),
    (11, 25),
    (12, 7),
    (12, 6),
)


def v2_3u1(u: int) -> int:
    """ν₂(3u+1) for odd u."""
    _, val = odd_syracuse(u)
    return val


def phi_k_stated(u: int, k: int) -> str:
    """Valuation-only classifier from the §5.22 research sketch."""
    v = v2_3u1(u)
    if v == 1:
        return "E01"
    if 2 <= v < k:
        return "E00"
    if v >= k:
        return "Z"
    return "UNDEF"


def phi_k_refined(t: Transition, k: int) -> str:
    """
    Wrap-aware classifier matching edge_relation matrices on F_k (audited).

    E01 ↔ wrap ∧ ν₂=1; E00 ↔ ¬wrap ∧ 1≤ν₂<k; Z ↔ ν₂≥k.
    """
    v = t.valuation
    if v >= k or t.precision_loss:
        return "Z"
    if t.wraps and v == 1:
        return "E01"
    if (not t.wraps) and (1 <= v < k):
        return "E00"
    return "OTHER"


def edge_lift_type(u: int, v: int, k: int, graph_k1: Dict[int, int]) -> str:
    R = edge_relation(u, v, k, graph_k1)
    return classify_bool_matrix(relation_matrix(R))


def is_cyclic_E00_power_E01(types: Sequence[str]) -> bool:
    """True iff types is a cyclic rotation of E00^{ℓ-1} E01."""
    ell = len(types)
    if ell < 1:
        return False
    if Counter(types) != Counter({"E00": ell - 1, "E01": 1}):
        return False
    # some rotation ends with E01 and the rest E00
    for r in range(ell):
        rot = list(types[r:]) + list(types[:r])
        if rot[-1] == "E01" and all(x == "E00" for x in rot[:-1]):
            return True
    return False


def _audit_level(k: int, cache: dict) -> dict:
    graph, meta = build_modular_graph(k)
    cut, n_cut, n_wrap_cut, n_loss_cut = cut_graph(graph, meta)
    g1 = cache[k + 1]["graph"]
    cut_cycles = [list(canonical_cycle(c)) for c in find_cycles(cut)]
    f_cycles = [list(canonical_cycle(c)) for c in find_cycles(graph)]

    stated_ok = 0
    refined_ok = 0
    n_edges = 0
    cut_stated_ok = 0
    cut_refined_ok = 0
    n_cut_edges = 0
    type_hist: Counter = Counter()
    cut_type_hist: Counter = Counter()
    stated_mismatch_examples: List[dict] = []
    refined_mismatch_examples: List[dict] = []

    for u, v in graph.items():
        n_edges += 1
        actual = edge_lift_type(u, v, k, g1)
        type_hist[actual] += 1
        st = phi_k_stated(u, k)
        rf = phi_k_refined(meta[u], k)
        if st == actual:
            stated_ok += 1
        elif len(stated_mismatch_examples) < 5:
            stated_mismatch_examples.append(
                {
                    "u": u,
                    "v": v,
                    "valuation": meta[u].valuation,
                    "wraps": meta[u].wraps,
                    "precision_loss": meta[u].precision_loss,
                    "phi_stated": st,
                    "actual": actual,
                }
            )
        if rf == actual:
            refined_ok += 1
        elif len(refined_mismatch_examples) < 5:
            refined_mismatch_examples.append(
                {
                    "u": u,
                    "v": v,
                    "valuation": meta[u].valuation,
                    "wraps": meta[u].wraps,
                    "precision_loss": meta[u].precision_loss,
                    "phi_refined": rf,
                    "actual": actual,
                }
            )

    for u, v in cut.items():
        n_cut_edges += 1
        actual = edge_lift_type(u, v, k, g1)
        cut_type_hist[actual] += 1
        if phi_k_stated(u, k) == actual:
            cut_stated_ok += 1
        if phi_k_refined(meta[u], k) == actual:
            cut_refined_ok += 1

    return {
        "k": k,
        "n_F_edges": n_edges,
        "n_cut_edges": n_cut_edges,
        "n_edges_cut_away": n_cut,
        "n_wrap_cut": n_wrap_cut,
        "n_loss_cut": n_loss_cut,
        "n_F_cycles": len(f_cycles),
        "n_cut_cycles": len(cut_cycles),
        "cut_cycles": cut_cycles,
        "F_cycle_lengths": sorted(len(c) for c in f_cycles),
        "type_histogram_F": dict(type_hist),
        "type_histogram_cut": dict(cut_type_hist),
        "stated_match_F": stated_ok,
        "stated_match_rate_F": stated_ok / n_edges if n_edges else 1.0,
        "refined_match_F": refined_ok,
        "refined_match_rate_F": refined_ok / n_edges if n_edges else 1.0,
        "stated_match_cut": cut_stated_ok,
        "stated_match_rate_cut": cut_stated_ok / n_cut_edges if n_cut_edges else 1.0,
        "refined_match_cut": cut_refined_ok,
        "refined_match_rate_cut": (
            cut_refined_ok / n_cut_edges if n_cut_edges else 1.0
        ),
        "stated_mismatch_examples": stated_mismatch_examples,
        "refined_mismatch_examples": refined_mismatch_examples,
        "cut_all_E00": set(cut_type_hist) <= {"E00"} and n_cut_edges > 0,
        "note_cut_acyclic": len(cut_cycles) == 0,
    }


def _audit_focus_cycle(k: int, length: int, cache: dict) -> dict:
    cycles = cache[k]["cycles"]
    c = next(x for x in cycles if len(x) == length)
    nodes = list(canonical_cycle(c))
    g1 = cache[k + 1]["graph"]
    _, meta = build_modular_graph(k)

    edges = []
    types: List[str] = []
    stated_preds: List[str] = []
    refined_preds: List[str] = []
    stated_ok = 0
    refined_ok = 0
    n_wrap = 0
    n_loss = 0

    for i in range(len(nodes)):
        u = nodes[i]
        v = nodes[(i + 1) % len(nodes)]
        t = meta[u]
        actual = edge_lift_type(u, v, k, g1)
        st = phi_k_stated(u, k)
        rf = phi_k_refined(t, k)
        types.append(actual)
        stated_preds.append(st)
        refined_preds.append(rf)
        if st == actual:
            stated_ok += 1
        if rf == actual:
            refined_ok += 1
        if t.wraps:
            n_wrap += 1
        if t.precision_loss:
            n_loss += 1
        edges.append(
            {
                "i": i,
                "u": u,
                "v": v,
                "valuation": t.valuation,
                "wraps": t.wraps,
                "precision_loss": t.precision_loss,
                "phi_stated": st,
                "phi_refined": rf,
                "lift_matrix_type": actual,
                "stated_matches": st == actual,
                "refined_matches": rf == actual,
            }
        )

    Ms = []
    for e in edges:
        # rebuild matrices for product / BoolTrace
        R = edge_relation(e["u"], e["v"], k, g1)
        Ms.append(relation_matrix(R))
    P = bool_product(Ms)
    hist = dict(Counter(types))
    unit_defect = (
        hist.get("E00", 0) == length - 1
        and hist.get("E01", 0) == 1
        and set(hist) <= {"E00", "E01"}
    )

    return {
        "k": k,
        "ell": length,
        "nodes": nodes,
        "edges": edges,
        "type_histogram": hist,
        "phi_stated_histogram": dict(Counter(stated_preds)),
        "phi_refined_histogram": dict(Counter(refined_preds)),
        "stated_match_count": stated_ok,
        "stated_match_rate": stated_ok / length,
        "refined_match_count": refined_ok,
        "refined_match_rate": refined_ok / length,
        "n_wrap_edges": n_wrap,
        "n_loss_edges": n_loss,
        "MatchesUnitDefectPattern": unit_defect,
        "cyclic_word_E00_pow_E01": is_cyclic_E00_power_E01(types),
        "BoolTrace": bool_trace(P),
        "P_type": classify_bool_matrix(P),
        "CycleLiftable": bool_trace(P) == 1,
        "in_G_k_cut": n_wrap == 0 and n_loss == 0,
        "lean_bridge": {
            "absorption_module": "KeplerHurwitz.EABC.BooleanRelationAbsorption",
            "focus_module": "KeplerHurwitz.EABC.FocusCycleUnitDefect",
            "phi_module": "KeplerHurwitz.EABC.SyracuseRelationClassifierPhi",
            "hypothesis": "MatchesUnitDefectPattern",
            "note": (
                "Lean [A] applies to the combinatorial word pattern; "
                "modular Φ_k matrix identity on F_k is Python [B] / "
                "valuation-lift lemmas [A]."
            ),
        },
    }


def run_phi_k_audit(k_min: int = 10, k_max: int = 14) -> dict:
    if k_max < k_min:
        raise ValueError("k_max must be >= k_min")
    cache = build_level_cache(k_min, k_max + 1)

    levels = [_audit_level(k, cache) for k in range(k_min, k_max + 1)]

    focus_rows = []
    for k, ell in FOCUS_SPECS:
        if k_min <= k <= k_max:
            focus_rows.append(_audit_focus_cycle(k, ell, cache))

    # small-k sanity for tests / report
    small = []
    if k_min > 4:
        cache_small = build_level_cache(4, 9)
        for k in range(4, 9):
            small.append(_audit_level(k, cache_small))

    all_focus_refined = all(r["refined_match_rate"] == 1.0 for r in focus_rows)
    all_focus_word = all(r["cyclic_word_E00_pow_E01"] for r in focus_rows)
    all_focus_unit = all(r["MatchesUnitDefectPattern"] for r in focus_rows)
    all_cut_acyclic = all(lv["n_cut_cycles"] == 0 for lv in levels)
    all_cut_E00 = all(lv["cut_all_E00"] for lv in levels)
    all_refined_F = all(lv["refined_match_rate_F"] == 1.0 for lv in levels)
    stated_fails_on_cut = any(lv["stated_match_rate_cut"] < 1.0 for lv in levels)

    return {
        "status": "B arithmetic Φ_k relation classifier §5.22",
        "date": "2026-07-21",
        "k_range": [k_min, k_max],
        "definitions": {
            "phi_k_stated": {
                "E01": "ν₂(3u+1)=1",
                "E00": "2 ≤ ν₂(3u+1) < k",
                "Z": "ν₂(3u+1) ≥ k",
                "scope_claim": "research sketch for wrap-/loss-free G_k^cut edges",
            },
            "phi_k_refined": {
                "E01": "wrap ∧ ν₂=1",
                "E00": "¬wrap ∧ 1 ≤ ν₂ < k",
                "Z": "ν₂ ≥ k",
                "scope": "all F_k avoid-1 edges (audited)",
            },
            "matrices": {
                "E00": MAT_E00,
                "E01": MAT_E01,
                "Z": MAT_Z,
            },
        },
        "audit_finding": {
            "stated_classifier_holds_on_G_k_cut": not stated_fails_on_cut,
            "stated_fails_because": (
                "On wrap-free edges with ν₂=1 the lift matrix is E00 "
                "(only (0,0)∈R); E01 appears exactly on wrap edges with ν₂=1. "
                "G_k^cut therefore has no E01 edges in the audited range."
            ),
            "refined_classifier_holds_on_F_k": all_refined_F,
            "G_k_cut_acyclic_in_range": all_cut_acyclic,
            "G_k_cut_edges_all_E00": all_cut_E00,
            "focus_cycles_in_F_k_not_cut": True,
            "focus_refined_match": all_focus_refined,
            "focus_cyclic_word_E00_pow_E01": all_focus_word,
            "focus_MatchesUnitDefectPattern": all_focus_unit,
        },
        "levels": levels,
        "focus_cycles": focus_rows,
        "small_k_sanity_levels": small,
        "corollary": {
            "statement": (
                "Cycles with exactly one ν₂=1 wrap edge and rest wrap-free "
                "ν₂≥1 yield W ∼_cyc E00^{ℓ-1}⊙E01"
            ),
            "applies_to_focus": all_focus_word and all_focus_unit,
            "applies_to_G_k_cut_cycles": False,
            "reason_cut": (
                "G_k^cut has 0 cycles for k∈[10,14] (and all cut edges are E00); "
                "the unit-defect word requires an E01, which needs a wrap edge."
            ),
            "lean_absorption_link": (
                "Under MatchesUnitDefectPattern, BooleanRelationAbsorption / "
                "FocusCycleUnitDefect give BoolTrace=0 and non-liftability of "
                "the CSP — not a Collatz proof, not ∀k over ℕ."
            ),
        },
        "claim_wall": {
            "A": (
                "Lean SyracuseRelationClassifierPhi: Φ_k label def; "
                "lift valuation invariance v₁=v₀ when v₀<k; T-lift identity; "
                "wrap-free ε=1 miss lemmas where green"
            ),
            "B": (
                "This Python audit: refined Φ matches F_k; focus words; "
                "stated Φ fails on G_k^cut for ν₂=1"
            ),
            "C": (
                "§5.21 Drift D_m / archimedean bridge open; §5.23 cut-cycle "
                "absorption ∀k open; no Collatz"
            ),
            "NOT_collatz": True,
            "sections": {
                "5.19": "frozen [A]/[B] absorptive monoid — reuse, do not duplicate",
                "5.20": "frozen [A]/[B] unit defect — reuse FocusCycleUnitDefect",
                "5.21": "frozen [C] Open Non-Claim Boundary (Drift D_m documented)",
                "5.22": (
                    "[B] audit + partial [A] arithmetic; naive stated Φ not verified; "
                    "refined Φ verified on audited range"
                ),
                "5.23": "stub / next — stable cut-cycle classification",
            },
        },
        "matrix_equality_smoke": {
            "E00_shape": matrices_equal(MAT_E00, [[1, 0], [0, 0]]),
            "E01_shape": matrices_equal(MAT_E01, [[0, 1], [0, 0]]),
            "Z_shape": matrices_equal(MAT_Z, [[0, 0], [0, 0]]),
        },
    }


def export_report(report: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2, sort_keys=False) + "\n", encoding="utf-8")


def main(argv: Optional[Sequence[str]] = None) -> int:
    p = argparse.ArgumentParser(description="§5.22 Φ_k relation classifier audit")
    p.add_argument("--k-min", type=int, default=10)
    p.add_argument("--k-max", type=int, default=14)
    p.add_argument(
        "--out",
        type=Path,
        default=Path("docs/exports/relation_classifier_phi_k_focus_cycles_k10_14.json"),
    )
    args = p.parse_args(argv)
    report = run_phi_k_audit(args.k_min, args.k_max)
    export_report(report, args.out)
    finding = report["audit_finding"]
    print(f"Wrote {args.out}")
    print(
        f"refined_F={finding['refined_classifier_holds_on_F_k']} "
        f"stated_cut={finding['stated_classifier_holds_on_G_k_cut']} "
        f"focus_word={finding['focus_cyclic_word_E00_pow_E01']} "
        f"cut_acyclic={finding['G_k_cut_acyclic_in_range']}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
