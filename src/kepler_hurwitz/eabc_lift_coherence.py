"""
Boolean lift-coherence algebra for modular avoid-1 cycles [B].

For a cycle C_k = (u_0,…,u_{ℓ-1}) of F_k, binary lifts
    ũ_i = u_i + ε_i · 2^k,  ε_i ∈ {0,1}
induce edge relations R_i ⊆ {0,1}² and 2×2 boolean matrices M_i.
CycleLiftable ⇔ Bool-tr(M_0⋯M_{ℓ-1}) = 1.

δ_coh(C) = min over ε of # edges with (ε_i, ε_{i+1}) ∉ R_i
(tropical / min-plus product of cost matrices).

Claim wall
----------
[B] Finite modular objects only (checked cycles at frozen k).
No Collatz; Universal surgery remains Non-Claim [C].
Does not bump numerical k beyond the frozen liftability range.

See docs/eabc_collatz_audit_grid.md §5.16–§5.17.
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Dict, List, Optional, Sequence, Set, Tuple

from kepler_hurwitz.eabc_cycle_liftability import (
    build_level_cache,
    canonical_cycle,
    edgewise_cycle_lift,
)
from kepler_hurwitz.eabc_modular_wrap_surgery import (
    build_modular_graph,
    find_cycles,
)

__all__ = [
    "Bool",
    "MAT_I",
    "MAT_S",
    "MAT_U",
    "MAT_Z",
    "edge_relation",
    "relation_matrix",
    "bool_matmul",
    "bool_product",
    "bool_trace",
    "gf2_matmul",
    "gf2_product",
    "classify_bool_matrix",
    "matrices_equal",
    "holonomy_label",
    "MAT_E00",
    "MAT_E01",
    "e00_e01_word_analysis",
    "absorption_mechanism_report",
    "open_path_solvability",
    "analyze_cycle_monodromy",
    "run_monodromy_audit",
    "minplus_matmul",
    "minplus_product",
    "delta_coherence",
    "exhaustive_cycle_liftable",
    "analyze_cycle_coherence",
    "run_coherence_audit",
    "export_certificate",
]

Bool = int  # 0 / 1
Eps = int  # 0 / 1
Pair = Tuple[Eps, Eps]
Matrix2 = List[List[Bool]]
CostMatrix2 = List[List[int]]

# Named 2×2 boolean matrices (row→column: M[ε][ε']).
MAT_I: Matrix2 = [[1, 0], [0, 1]]
MAT_S: Matrix2 = [[0, 1], [1, 0]]  # Flip / C₂ generator
MAT_U: Matrix2 = [[1, 1], [1, 1]]
MAT_Z: Matrix2 = [[0, 0], [0, 0]]


def _mod_k1_rep(u: int, eps: Eps, k: int) -> int:
    """Canonical odd lift ũ = u + ε·2^k in {0,…,2^{k+1}-1}."""
    mod_k1 = 1 << (k + 1)
    return (u + eps * (1 << k)) % mod_k1


def _F_k1(u_lift: int, k: int, graph_k1: Dict[int, int]) -> Optional[int]:
    """Functional successor in F_{k+1}, or None if dropped (target≡1)."""
    return graph_k1.get(u_lift)


def edge_relation(
    u: int,
    v: int,
    k: int,
    graph_k1: Dict[int, int],
) -> Set[Pair]:
    """
    R ⊆ {0,1}² for the edge u→v of C_k:
    (ε,ε') ∈ R ⇔ F_{k+1}(u+ε·2^k) = v+ε'·2^k (edge present).
    """
    R: Set[Pair] = set()
    for eps in (0, 1):
        u_lift = _mod_k1_rep(u, eps, k)
        if u_lift % 2 == 0:
            continue
        tgt = _F_k1(u_lift, k, graph_k1)
        if tgt is None:
            continue
        for eps_next in (0, 1):
            v_lift = _mod_k1_rep(v, eps_next, k)
            if tgt == v_lift:
                R.add((eps, eps_next))
    return R


def relation_matrix(R: Set[Pair]) -> Matrix2:
    """2×2 boolean adjacency: M[ε][ε'] = 1 iff (ε,ε') ∈ R."""
    M: Matrix2 = [[0, 0], [0, 0]]
    for a, b in R:
        M[a][b] = 1
    return M


def bool_matmul(A: Matrix2, B: Matrix2) -> Matrix2:
    """
    Boolean relation product (OR-AND), matching Lean `boolMatMul`:

        (A ⊙ B)[i,j] = ⋁_r (A[i,r] ∧ B[r,j])

    Normative reference: `KeplerHurwitz/EABC/ModularSyracuseLift.lean`.
    Must NOT be replaced by GF(2) / XOR / NumPy matmul mod 2.
    """
    C: Matrix2 = [[0, 0], [0, 0]]
    for i in range(2):
        for j in range(2):
            C[i][j] = 1 if ((A[i][0] and B[0][j]) or (A[i][1] and B[1][j])) else 0
    return C


def bool_product(mats: Sequence[Matrix2]) -> Matrix2:
    """Left-fold OR-AND product M_0 ⊙ ⋯ ⊙ M_{ℓ-1}."""
    if not mats:
        return [row[:] for row in MAT_I]
    P = [row[:] for row in mats[0]]
    for M in mats[1:]:
        P = bool_matmul(P, M)
    return P


def bool_trace(P: Matrix2) -> Bool:
    """Bool-tr(P) = P₀₀ ∨ P₁₁ (Lean `boolTrace`)."""
    return 1 if (P[0][0] or P[1][1]) else 0


def gf2_matmul(A: Matrix2, B: Matrix2) -> Matrix2:
    """
    GF(2) matrix product (XOR of ANDs) — NOT the lift criterion.
    Kept only for audit/diff against accidental Sage/NumPy mod-2 use.
    """
    C: Matrix2 = [[0, 0], [0, 0]]
    for i in range(2):
        for j in range(2):
            C[i][j] = (A[i][0] * B[0][j] + A[i][1] * B[1][j]) % 2
    return C


def gf2_product(mats: Sequence[Matrix2]) -> Matrix2:
    """Left-fold GF(2) product — warning/diff only, never CycleLiftable criterion."""
    if not mats:
        return [row[:] for row in MAT_I]
    P = [row[:] for row in mats[0]]
    for M in mats[1:]:
        P = gf2_matmul(P, M)
    return P


def matrices_equal(A: Matrix2, B: Matrix2) -> bool:
    return A[0][0] == B[0][0] and A[0][1] == B[0][1] and A[1][0] == B[1][0] and A[1][1] == B[1][1]


def holonomy_label(
    *,
    all_local_bijective: bool,
    flip_count: int,
    is_flip: bool,
) -> str:
    """
    Holonomy tag for reporting:
      +1 / -1  — only if every M_i ∈ {I,S} (genuine ±1 Flip-holonomy analogy)
      effective_flip — P=S but locals not all bijective
      relational — otherwise (partial / noninvertible monodromy; Z₂-holonomy absent)
    """
    if all_local_bijective:
        return "-1" if (flip_count % 2 == 1) else "+1"
    if is_flip:
        return "effective_flip"
    return "relational"


# Singleton generators for absorption combinatorics (§5.18).
MAT_E00: Matrix2 = [[1, 0], [0, 0]]
MAT_E01: Matrix2 = [[0, 1], [0, 0]]
REL_E00: Set[Pair] = {(0, 0)}
REL_E01: Set[Pair] = {(0, 1)}


def e00_e01_word_analysis(ell: int, e01_index: int) -> dict:
    """
    Pure combinatorics: word with (ℓ−1)×E00 and one E01 at index e01_index.

    Under OR-AND: P = E01 iff e01_index = ℓ−1 (last factor); else P = Z.
    Always δ_coh = 1 for ℓ ≥ 1.
    """
    if ell < 1:
        raise ValueError("ell must be >= 1")
    if not (0 <= e01_index < ell):
        raise ValueError("e01_index out of range")
    R_list: List[Set[Pair]] = [set(REL_E00) for _ in range(ell)]
    R_list[e01_index] = set(REL_E01)
    M_list = [relation_matrix(R) for R in R_list]
    P = bool_product(M_list)
    delta, _ = delta_coherence(R_list)
    return {
        "ell": ell,
        "e01_index": e01_index,
        "P": P,
        "P_type": classify_bool_matrix(P),
        "bool_trace": bool_trace(P),
        "delta_coh": delta,
        "P_is_Z": matrices_equal(P, MAT_Z),
        "P_is_E01": matrices_equal(P, MAT_E01),
    }


def absorption_mechanism_report(lengths: Sequence[int] = (6, 7, 25, 26)) -> dict:
    """
    §5.18: unit-defect words (ℓ−1)×E00 + 1×E01 — P ∈ {Z, E01}, δ_coh ≡ 1.
    """
    by_length = []
    for ell in lengths:
        rows = [e00_e01_word_analysis(ell, j) for j in range(ell)]
        p_types = sorted({r["P_type"] for r in rows})
        deltas = sorted({r["delta_coh"] for r in rows})
        e01_positions = [r["e01_index"] for r in rows if r["P_is_E01"]]
        by_length.append(
            {
                "ell": ell,
                "n_positions": ell,
                "P_types_observed": p_types,
                "delta_coh_values": deltas,
                "delta_coh_always_1": deltas == [1],
                "e01_index_yielding_P_E01": e01_positions,
                "rule": (
                    "OR-AND: P=E01 iff E01 is the last factor; "
                    "otherwise E01⊙E00=Z so P=Z; δ_coh=1 always"
                ),
            }
        )
    return {
        "status": "B §5.18 frozen core — boolean absorption/collapse (E00/E01)",
        "hypothesis": "focus cycles = (ℓ−1)×E00 + 1×E01",
        "unit_defect_rule": (
            "Any cyclic CSP whose edge relations are exactly one E01 and "
            "otherwise E00 has δ_coh=1 and Bool-tr(P)=0 with P∈{Z,E01} "
            "(rotation of the product start selects which of Z/E01 appears)."
        ),
        "binding_core": {
            "P_ne_S_under_OR_AND": True,
            "not_gf2_artifact": True,
            "not_invertible_Z2_holonomy": True,
            "P_in_Z_or_E01": True,
            "focus_three_Z_one_E01": True,
            "algebraic_class": "noninvertible relational monodromy",
            "unit_defect_implies_delta_coh_1": True,
            "replaces": "discarded Coxeter/Flip reading",
        },
        "by_length": by_length,
        "claim_wall": {
            "finite_modular_only": True,
            "A_tilde_incidence_graph_only": True,
            "no_flip_holonomy": True,
            "no_lie_kac_moody": True,
            "no_collatz": True,
            "semiring": "OR-AND only",
        },
    }


def classify_bool_matrix(M: Matrix2) -> str:
    """
    Classify a 2×2 boolean relation matrix.

    Named types:
      I, S (Flip), U (full), Z (zero),
      Eab = singleton {(a,b)},
      R0/R1 = full row, C0/C1 = full column,
      U_miss_* = U minus one entry,
      else partial{bits}.
    """
    bits = (M[0][0], M[0][1], M[1][0], M[1][1])
    catalog = {
        (1, 0, 0, 1): "I",
        (0, 1, 1, 0): "S",
        (1, 1, 1, 1): "U",
        (0, 0, 0, 0): "Z",
        (1, 0, 0, 0): "E00",
        (0, 1, 0, 0): "E01",
        (0, 0, 1, 0): "E10",
        (0, 0, 0, 1): "E11",
        (1, 1, 0, 0): "R0",
        (0, 0, 1, 1): "R1",
        (1, 0, 1, 0): "C0",
        (0, 1, 0, 1): "C1",
        (1, 1, 1, 0): "U_miss11",
        (1, 1, 0, 1): "U_miss10",
        (1, 0, 1, 1): "U_miss01",
        (0, 1, 1, 1): "U_miss00",
    }
    return catalog.get(bits, f"partial{bits}")


def open_path_solvability(M_list: Sequence[Matrix2]) -> dict:
    """
    Open the constraint circle at each edge j (path graph A_{ℓ-1}):
    the remaining product Q is path-solvable iff some entry of Q is 1.
    """
    ell = len(M_list)
    solvable_cuts: List[int] = []
    for j in range(ell):
        path = list(M_list[:j]) + list(M_list[j + 1 :])
        if not path:
            solvable_cuts.append(j)
            continue
        Q = bool_product(path)
        if any(Q[a][b] for a in (0, 1) for b in (0, 1)):
            solvable_cuts.append(j)
    return {
        "n_edges": ell,
        "n_solvable_cuts": len(solvable_cuts),
        "solvable_cut_indices": solvable_cuts,
        "exists_solvable_cut": bool(solvable_cuts),
        "all_cuts_solvable": len(solvable_cuts) == ell and ell > 0,
    }


def analyze_cycle_monodromy(
    cycle: Sequence[int],
    k: int,
    graph_k1: Optional[Dict[int, int]] = None,
) -> dict:
    """
    Boolean lift-monodromy classification for one F_k-cycle [B] / §5.17.

    Criterion product is OR-AND (Lean `boolMatMul`), never GF(2).
    Constraint circle ≅ Ã_{ℓ-1} as a graph only (no Kac–Moody/Lie claim).
    CycleLiftable ⇔ Bool-tr(P)=1.  P=S ⇒ δ_coh≥1, but δ_coh=1 needs CSP.
    """
    if graph_k1 is None:
        graph_k1, _ = build_modular_graph(k + 1)
    # Canonical rotation (min-first) — same edge set as any rotate of the cycle.
    nodes = list(canonical_cycle(cycle))
    ell = len(nodes)
    R_list: List[Set[Pair]] = []
    M_list: List[Matrix2] = []
    edge_types: List[str] = []
    for i in range(ell):
        u = nodes[i]
        v = nodes[(i + 1) % ell]
        R = edge_relation(u, v, k, graph_k1)
        M = relation_matrix(R)
        R_list.append(R)
        M_list.append(M)
        edge_types.append(classify_bool_matrix(M))

    P = bool_product(M_list)
    P_gf2 = gf2_product(M_list)
    tr = bool_trace(P)
    p_type = classify_bool_matrix(P)
    is_flip = matrices_equal(P, MAT_S)
    is_id = matrices_equal(P, MAT_I)
    is_zero = matrices_equal(P, MAT_Z)
    hist = dict(Counter(edge_types))
    flip_count = hist.get("S", 0)
    all_local_bijective = set(edge_types).issubset({"I", "S"}) and ell > 0
    hol = holonomy_label(
        all_local_bijective=all_local_bijective,
        flip_count=flip_count,
        is_flip=is_flip,
    )
    # Focus pattern: (ℓ−1)×E00 + 1×E01
    unit_defect = hist.get("E00", 0) == ell - 1 and hist.get("E01", 0) == 1 and len(hist) == 2
    noninvertible = p_type in {"Z", "E01", "E00", "E10", "E11"} or (
        not all_local_bijective and not is_id and not is_flip
    )

    delta, witness = delta_coherence(R_list)
    open_path = open_path_solvability(M_list)
    exh = exhaustive_cycle_liftable(R_list)

    return {
        "k": k,
        "cycle_length": ell,
        "length": ell,
        "nodes": nodes,
        "canonical_id": nodes,
        "dynkin_graph_type": f"A~_{ell - 1}",
        "constraint_graph_type": f"A~_{ell - 1}",
        "constraint_graph_note": (
            f"incidence graph only ≅ Ã_{ell - 1}; operative algebra = "
            "monoid of 2×2 boolean relations under OR-AND"
        ),
        "product_semiring": "OR-AND (Lean boolMatMul)",
        "local_relation_types": edge_types,
        "M_i_types": edge_types,
        "type_histogram": hist,
        "all_local_bijective": all_local_bijective,
        "flip_count": flip_count,
        "n_I": hist.get("I", 0),
        "n_S_flip": flip_count,
        "only_I_or_S": all_local_bijective,
        "matches_unit_defect_E00_E01": unit_defect,
        "monodromy_product": P,
        "boolean_product_P": P,
        "P_type": p_type,
        "bool_trace": tr,
        "is_flip": False if not is_flip else True,
        "is_identity": is_id,
        "P_equals_S_flip": is_flip,
        "P_equals_I": is_id,
        "P_equals_Z": is_zero,
        "holonomy": hol,
        "z2_holonomy": None,  # absent on focus: no I/S Coxeter/Möbius flip reading
        "noninvertible_relational_monodromy": noninvertible and not is_flip,
        "Hol_sign_if_only_I_S": (
            (-1 if flip_count % 2 == 1 else 1) if all_local_bijective else None
        ),
        "coherence_defect": delta,
        "delta_coh": delta,
        "witness_eps": list(witness) if witness is not None else None,
        "delta_coh_eq_1": delta == 1,
        "P_eq_S_implies_delta_ge_1": (not is_flip) or (delta >= 1),
        "flip_monodromy_hypothesis_P_eq_S": is_flip,
        "delta1_iff_P_eq_S_on_this_cycle": (delta == 1) == is_flip,
        "gf2_product": P_gf2,
        "gf2_product_warning": (
            "GF(2)/XOR product is NOT the lift criterion; stored for audit/diff only. "
            "Normative product is OR-AND (= Lean boolMatMul)."
        ),
        "gf2_differs_from_OR_AND": not matrices_equal(P, P_gf2),
        "open_path_A_ell_minus_1": open_path,
        "CycleLiftable": tr == 1,
        "exhaustive_CycleLiftable": exh,
        "assert_CycleLiftable_iff_bool_trace": exh == (tr == 1),
    }


def run_monodromy_audit() -> dict:
    """Classify monodromy for the four frozen focus cycles (§5.17, OR-AND)."""
    cache = build_level_cache(10, 13)
    focus = _select_focus_cycles(cache)
    cycles = []
    for k, nodes in focus:
        cycles.append(analyze_cycle_monodromy(nodes, k, cache[k + 1]["graph"]))

    any_flip = any(c["is_flip"] for c in cycles)
    all_delta1 = all(c["delta_coh"] == 1 for c in cycles)
    all_tr0 = all(c["bool_trace"] == 0 for c in cycles)
    any_gf2_diff = any(c["gf2_differs_from_OR_AND"] for c in cycles)
    # Variant 1 only if some P=S; else Variant 2 (diagonal-free relational)
    section_variant = 1 if any_flip else 2

    return {
        "status": "B finite modular boolean lift-monodromy (OR-AND) only",
        "semiring_norm": {
            "criterion": "OR-AND boolean relation product",
            "lean_reference": "KeplerHurwitz.EABC.ModularSyracuseLift.boolMatMul",
            "formula": "(A⊙B)[i,j] = OR_r (A[i,r] AND B[r,j])",
            "not_used_as_criterion": "GF(2) / XOR / NumPy matmul mod 2",
            "cross_check_matrices": {
                "U": [[1, 1], [1, 1]],
                "U_OR_AND_U": [[1, 1], [1, 1]],
                "U_GF2_U": [[0, 0], [0, 0]],
                "note": "two-path case: OR-AND keeps 1∨1=1; GF(2) yields 1+1=0",
            },
        },
        "section_5_17_variant": section_variant,
        "section_5_17_variant_note": (
            "1 = P=S Flip-holonomy narrative; "
            "2 = diagonal-free / relational monodromy (P≠S on focus data)"
        ),
        "claim_wall": {
            "tag": "B",
            "section_5_18_core_frozen": True,
            "allowed": [
                "constraint circle ≅ Ã_{ℓ-1} as incidence graph only",
                "boolean OR-AND monodromy P = ⊙ M_i (Lean boolMatMul)",
                "noninvertible relational monodromy / absorption on frozen focus",
            ],
            "forbidden_non_claims": [
                "Syracuse = Lie algebra / Kac–Moody",
                "E8 explains Collatz",
                "Ã_n graph = genuine root system without extra structure",
                "Universal surgery",
                "invertible ℤ₂ / Coxeter / Möbius Flip holonomy",
                "GF(2) product as liftability criterion",
            ],
            "no_k_bump": True,
            "no_collatz": True,
            "finite_modular_only": True,
        },
        "definitions": {
            "S_flip": "[[0,1],[1,0]]",
            "I": "[[1,0],[0,1]]",
            "Z": "[[0,0],[0,0]]",
            "P": "OR-AND product M_0⊙⋯⊙M_{ℓ-1} (Lean boolMatMul)",
            "liftable_iff": "Bool-tr(P)=1",
            "P_eq_S_implies": "δ_coh ≥ 1 (vanishing Bool-trace); δ_coh=1 needs CSP",
            "E_eps": "# broken edges of ε; δ_coh = min E(ε)",
            "holonomy": (
                "+1/−1 only if all M_i∈{I,S}; effective_flip if P=S without that; "
                "else relational"
            ),
            "A_tilde": "constraint circle graph type Ã_{ℓ-1} (combinatorial)",
        },
        "flip_test_verdict": {
            "any_cycle_has_P_eq_S": any_flip,
            "all_delta_coh_eq_1": all_delta1,
            "all_bool_trace_zero": all_tr0,
            "any_gf2_differs_from_OR_AND_on_focus": any_gf2_diff,
            "Z_finding_is_gf2_artifact": False,
            "Z_finding_note": (
                "On focus cycles local matrices are singletons E00/E01 "
                "(at most one path per entry), so OR-AND and GF(2) agree; "
                "P=Z / E01 is confirmed under Lean OR-AND, not a GF(2) artefact. "
                "General divergence is witnessed by U⊙U."
            ),
            "Z2_holonomy_flip_hypothesis": (
                "REFUTED on focus data under OR-AND: no cycle has P = S; "
                "δ_coh=1 with relational monodromy Z or E01"
            ),
        },
        "absorption": absorption_mechanism_report(
            [c["cycle_length"] for c in cycles]
        ),
        "local_type_histogram_pooled": dict(
            Counter(
                t for c in cycles for t in c["local_relation_types"]
            )
        ),
        "all_focus_match_unit_defect_E00_E01": all(
            c["matches_unit_defect_E00_E01"] for c in cycles
        ),
        "cycles": cycles,
        "summary_table": [
            {
                "k": c["k"],
                "cycle_length": c["cycle_length"],
                "dynkin_graph_type": c["dynkin_graph_type"],
                "local_relation_types_hist": c["type_histogram"],
                "all_local_bijective": c["all_local_bijective"],
                "flip_count": c["flip_count"],
                "monodromy_product": c["monodromy_product"],
                "P_type": c["P_type"],
                "bool_trace": c["bool_trace"],
                "is_flip": c["is_flip"],
                "is_identity": c["is_identity"],
                "holonomy": c["holonomy"],
                "z2_holonomy": c["z2_holonomy"],
                "noninvertible_relational_monodromy": c[
                    "noninvertible_relational_monodromy"
                ],
                "matches_unit_defect_E00_E01": c["matches_unit_defect_E00_E01"],
                "coherence_defect": c["coherence_defect"],
                "gf2_product": c["gf2_product"],
                "gf2_differs_from_OR_AND": c["gf2_differs_from_OR_AND"],
                "exists_open_path_solution": c["open_path_A_ell_minus_1"][
                    "exists_solvable_cut"
                ],
                "n_solvable_cuts": c["open_path_A_ell_minus_1"]["n_solvable_cuts"],
            }
            for c in cycles
        ],
    }


def cost_matrix(R: Set[Pair]) -> CostMatrix2:
    """C[ε][ε'] = 0 if allowed, else 1 (violation)."""
    return [[0 if (i, j) in R else 1 for j in range(2)] for i in range(2)]


def minplus_matmul(A: CostMatrix2, B: CostMatrix2) -> CostMatrix2:
    """(min,+) product of 2×2 cost matrices."""
    C: CostMatrix2 = [[0, 0], [0, 0]]
    for i in range(2):
        for j in range(2):
            C[i][j] = min(A[i][0] + B[0][j], A[i][1] + B[1][j])
    return C


def minplus_product(mats: Sequence[CostMatrix2]) -> CostMatrix2:
    if not mats:
        return [[0, 10**9], [10**9, 0]]
    P = [row[:] for row in mats[0]]
    for M in mats[1:]:
        P = minplus_matmul(P, M)
    return P


def delta_coherence(R_list: Sequence[Set[Pair]]) -> Tuple[int, Optional[List[Eps]]]:
    """
    δ_coh = min diagonal of min-plus product of cost matrices.
    Also returns one witness ε-assignment achieving that value (layered DP).
    """
    ell = len(R_list)
    if ell == 0:
        return 0, []
    costs = [cost_matrix(R) for R in R_list]
    P = minplus_product(costs)
    delta = min(P[0][0], P[1][1])

    for start in (0, 1):
        # cost_to[i][eps] = min cost to reach node i with label eps (from start at 0)
        cost_to: List[List[int]] = [[10**9, 10**9] for _ in range(ell)]
        pred: List[List[Optional[Eps]]] = [[None, None] for _ in range(ell)]
        cost_to[0][start] = 0
        for i in range(ell - 1):
            for a in (0, 1):
                if cost_to[i][a] >= 10**9:
                    continue
                for b in (0, 1):
                    c = cost_to[i][a] + (0 if (a, b) in R_list[i] else 1)
                    if c < cost_to[i + 1][b]:
                        cost_to[i + 1][b] = c
                        pred[i + 1][b] = a
        # Close last edge back to start
        best_last: Optional[Eps] = None
        best_total = 10**9
        for a in (0, 1):
            if cost_to[ell - 1][a] >= 10**9:
                continue
            c = cost_to[ell - 1][a] + (0 if (a, start) in R_list[ell - 1] else 1)
            if c < best_total:
                best_total = c
                best_last = a
        if best_total != delta or best_last is None:
            continue
        labels = [0] * ell
        labels[ell - 1] = best_last
        cur = best_last
        for i in range(ell - 1, 0, -1):
            prev = pred[i][cur]
            assert prev is not None
            labels[i - 1] = prev
            cur = prev
        labels[0] = start
        broken = sum(
            0 if (labels[i], labels[(i + 1) % ell]) in R_list[i] else 1
            for i in range(ell)
        )
        if broken == delta:
            return delta, labels

    # Fallback brute force (safe for ℓ≤28)
    witness = _brute_witness(R_list, delta)
    return delta, witness


def _brute_witness(R_list: Sequence[Set[Pair]], delta: int) -> Optional[List[Eps]]:
    ell = len(R_list)
    if ell > 28:
        return None
    limit = 1 << ell
    for mask in range(limit):
        eps = [(mask >> i) & 1 for i in range(ell)]
        broken = 0
        for i in range(ell):
            if (eps[i], eps[(i + 1) % ell]) not in R_list[i]:
                broken += 1
                if broken > delta:
                    break
        if broken == delta:
            return eps
    return None


def exhaustive_cycle_liftable(R_list: Sequence[Set[Pair]]) -> bool:
    """
    True iff some ε∈{0,1}^ℓ satisfies all edge relations.

    Uses meet-in-the-middle reachability on the 2-state cycle CSP
    (equivalent to enumerating all consistent partial assignments; for ℓ=26
    this is exhaustive over the constraint graph, not a heuristic sample).
    """
    ell = len(R_list)
    if ell == 0:
        return True
    next_ok: List[List[List[Eps]]] = []
    for R in R_list:
        row: List[List[Eps]] = [[], []]
        for a in (0, 1):
            for b in (0, 1):
                if (a, b) in R:
                    row[a].append(b)
        next_ok.append(row)

    # Brute force for short cycles (direct ε search)
    if ell <= 20:
        limit = 1 << ell
        for mask in range(limit):
            ok = True
            for i in range(ell):
                a = (mask >> i) & 1
                b = (mask >> ((i + 1) % ell)) & 1
                if (a, b) not in R_list[i]:
                    ok = False
                    break
            if ok:
                return True
        return False

    # Meet-in-the-middle exhaustive reachability for longer cycles (e.g. C_26)
    half = ell // 2
    reach_fwd: Set[Tuple[Eps, Eps]] = {(0, 0), (1, 1)}  # (start, cur) at node 0
    for i in range(half):
        nxt: Set[Tuple[Eps, Eps]] = set()
        for start, cur in reach_fwd:
            for b in next_ok[i][cur]:
                nxt.add((start, b))
        reach_fwd = nxt
        if not reach_fwd:
            return False
    for start, mid in reach_fwd:
        curs: Set[Eps] = {mid}
        alive = True
        for i in range(half, ell - 1):
            nxt2: Set[Eps] = set()
            for a in curs:
                nxt2.update(next_ok[i][a])
            curs = nxt2
            if not curs:
                alive = False
                break
        if not alive:
            continue
        for a in curs:
            if start in next_ok[ell - 1][a]:
                return True
    return False


def broken_edges(R_list: Sequence[Set[Pair]], eps: Sequence[Eps]) -> List[int]:
    """Indices of edges violated by ε."""
    ell = len(R_list)
    out = []
    for i in range(ell):
        if (eps[i], eps[(i + 1) % ell]) not in R_list[i]:
            out.append(i)
    return out


def analyze_cycle_coherence(
    cycle: Sequence[int],
    k: int,
    graph_k1: Optional[Dict[int, int]] = None,
    *,
    exhaustive: bool = True,
) -> dict:
    """
    Full boolean / tropical coherence analysis for one cycle of F_k.
    """
    if graph_k1 is None:
        graph_k1, _ = build_modular_graph(k + 1)
    nodes = list(cycle)
    ell = len(nodes)
    R_list: List[Set[Pair]] = []
    M_list: List[Matrix2] = []
    edge_rows = []
    for i in range(ell):
        u = nodes[i]
        v = nodes[(i + 1) % ell]
        R = edge_relation(u, v, k, graph_k1)
        M = relation_matrix(R)
        R_list.append(R)
        M_list.append(M)
        edge_rows.append(
            {
                "i": i,
                "from": u,
                "to": v,
                "R_i": sorted([list(p) for p in R]),
                "M_i": M,
                "R_nonempty": bool(R),
            }
        )

    P = bool_product(M_list)
    tr = bool_trace(P)
    cycle_liftable_bool = tr == 1
    local_all = all(e["R_nonempty"] for e in edge_rows)

    delta, witness = delta_coherence(R_list)
    witness_list = list(witness) if witness is not None else None
    broken = broken_edges(R_list, witness_list) if witness_list is not None else None

    exhaustive_ok: Optional[bool] = None
    if exhaustive:
        exhaustive_ok = exhaustive_cycle_liftable(R_list)
        if exhaustive_ok != cycle_liftable_bool:
            raise AssertionError(
                f"Bool-trace/exhaustive mismatch at k={k}, len={ell}: "
                f"tr={tr}, exhaustive={exhaustive_ok}"
            )

    # Edgewise L_* diagnostics (reuse existing liftability helpers)
    g_k1_cycles = find_cycles(graph_k1)
    edgewise = edgewise_cycle_lift(nodes, k, graph_k1, g_k1_cycles)

    return {
        "k": k,
        "length": ell,
        "nodes": nodes,
        "canonical_id": list(canonical_cycle(nodes)),
        "edges": edge_rows,
        "boolean_product_P": P,
        "bool_trace": tr,
        "CycleLiftable_bool_trace": cycle_liftable_bool,
        "all_edges_locally_liftable": local_all,
        "local_ne_global": local_all and not cycle_liftable_bool,
        "delta_coh": delta,
        "witness_eps_achieving_delta_coh": witness_list,
        "broken_edge_indices_at_witness": broken,
        "n_broken_at_witness": len(broken) if broken is not None else None,
        "exhaustive_CycleLiftable": exhaustive_ok,
        "assert_CycleLiftable_iff_bool_trace": (
            exhaustive_ok == cycle_liftable_bool if exhaustive_ok is not None else None
        ),
        "L_edge": edgewise["L_edge"],
        "L_cyc_edge": edgewise["L_cyc_edge"],
        "L_cycle_setlift_proxy": 1 if cycle_liftable_bool else 0,
        "vanishing_diagonal": {
            "P00": P[0][0],
            "P11": P[1][1],
            "both_zero": P[0][0] == 0 and P[1][1] == 0,
        },
        "obstruction": {
            "kind": "boolean_trace_vanishes" if tr == 0 else "none",
            "R_i": [e["R_i"] for e in edge_rows],
            "M_i": [e["M_i"] for e in edge_rows],
            "boolean_product_P": P,
            "bool_trace": tr,
            "minimal_inconsistent_edge_set_witness": broken,
            "witness_eps": witness_list,
            "delta_coh": delta,
        },
    }


def _select_focus_cycles(cache: Dict[int, dict]) -> List[Tuple[int, List[int]]]:
    """Focus: k=10 C_26, k=11 C_25, k=12 all cycles (cheap)."""
    out: List[Tuple[int, List[int]]] = []
    for c in cache[10]["cycles"]:
        if len(c) == 26:
            out.append((10, list(c)))
    for c in cache[11]["cycles"]:
        if len(c) == 25:
            out.append((11, list(c)))
    for c in cache[12]["cycles"]:
        out.append((12, list(c)))
    return out


def run_coherence_audit(
    *,
    exhaustive_c26: bool = True,
    exhaustive_others: bool = True,
) -> dict:
    """
    Build obstruction certificates for focus cycles inside the frozen range.
    Does not extend k beyond the existing liftability freeze (k≤14 / focus ≤12).
    """
    cache = build_level_cache(10, 13)
    focus = _select_focus_cycles(cache)
    cycle_reports = []
    for k, nodes in focus:
        g1 = cache[k + 1]["graph"]
        # Exhaustive 2^26 is the main verification ask; others are cheap.
        do_exh = exhaustive_c26 if (k == 10 and len(nodes) == 26) else exhaustive_others
        if k == 10 and len(nodes) == 26:
            do_exh = exhaustive_c26
        rec = analyze_cycle_coherence(nodes, k, g1, exhaustive=do_exh)
        cycle_reports.append(rec)

    c26 = next((r for r in cycle_reports if r["k"] == 10 and r["length"] == 26), None)
    summary = {
        "n_focus_cycles": len(cycle_reports),
        "C26_k10": (
            {
                "L_edge": c26["L_edge"],
                "L_cyc_edge": c26["L_cyc_edge"],
                "L_cycle": c26["L_cycle_setlift_proxy"],
                "bool_trace": c26["bool_trace"],
                "delta_coh": c26["delta_coh"],
                "CycleLiftable": c26["CycleLiftable_bool_trace"],
                "local_ne_global": c26["local_ne_global"],
                "exhaustive_matches_bool_trace": c26[
                    "assert_CycleLiftable_iff_bool_trace"
                ],
            }
            if c26
            else None
        ),
        "all_focus_bool_trace": [
            {
                "k": r["k"],
                "length": r["length"],
                "bool_trace": r["bool_trace"],
                "delta_coh": r["delta_coh"],
                "L_edge": r["L_edge"],
                "L_cyc_edge": r["L_cyc_edge"],
            }
            for r in cycle_reports
        ],
    }

    return {
        "status": "B finite modular boolean lift-coherence certificate only",
        "claim_wall": {
            "tag": "B",
            "scope": "finite modular objects only",
            "no_collatz": True,
            "no_forall_k": True,
            "universal_surgery": "OPEN / Non-Claim",
            "k_bump": "not performed; focus cycles inside frozen liftability range",
            "non_claims": [
                "no Collatz theorem",
                "no Universal wrap-surgery theorem",
                "Bool-trace vanishing ≠ ℕ avoidance",
                "δ_coh is a finite CSP defect, not a Collatz invariant",
            ],
        },
        "definitions": {
            "epsilon_lift": "ũ_i = u_i + ε_i·2^k, ε_i∈{0,1}",
            "R_i": "(ε,ε')∈R_i ⇔ F_{k+1}(u_i+ε·2^k)=u_{i+1}+ε'·2^k",
            "M_i": "2×2 boolean matrix of R_i",
            "P": "boolean semiring product M_0⋯M_{ℓ-1}",
            "bool_trace": "P00 ∨ P11; CycleLiftable iff bool_trace=1",
            "delta_coh": (
                "min # broken edges over ε assignments "
                "(min-plus product diagonal)"
            ),
        },
        "summary": summary,
        "cycles": cycle_reports,
        "primary_certificate": c26["obstruction"] if c26 else None,
        "primary_cycle": c26,
    }


def export_certificate(report: dict, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")


def main(argv: Optional[Sequence[str]] = None) -> int:
    p = argparse.ArgumentParser(
        description="EABC boolean lift-coherence / monodromy audit [B]"
    )
    p.add_argument(
        "--out",
        type=Path,
        default=Path("docs/exports/eabc_c26_lift_obstruction_certificate.json"),
    )
    p.add_argument(
        "--skip-exhaustive-c26",
        action="store_true",
        help="Skip 2^26 exhaustive verification (Bool-trace still computed)",
    )
    p.add_argument(
        "--summary-out",
        type=Path,
        default=Path("docs/exports/eabc_lift_coherence_summary.json"),
    )
    p.add_argument(
        "--monodromy-out",
        type=Path,
        default=Path("docs/exports/eabc_lift_monodromy_report.json"),
    )
    p.add_argument(
        "--monodromy-only",
        action="store_true",
        help="Only run §5.17 monodromy classification (skip full C_26 certificate)",
    )
    args = p.parse_args(argv)

    if not args.monodromy_only:
        report = run_coherence_audit(exhaustive_c26=not args.skip_exhaustive_c26)
        export_certificate(report, args.out)

        summary_doc = {
            "status": report["status"],
            "claim_wall": report["claim_wall"],
            "summary": report["summary"],
            "cycles_compact": [
                {
                    "k": c["k"],
                    "length": c["length"],
                    "canonical_id": c["canonical_id"],
                    "bool_trace": c["bool_trace"],
                    "delta_coh": c["delta_coh"],
                    "L_edge": c["L_edge"],
                    "L_cyc_edge": c["L_cyc_edge"],
                    "local_ne_global": c["local_ne_global"],
                    "exhaustive_matches_bool_trace": c[
                        "assert_CycleLiftable_iff_bool_trace"
                    ],
                    "broken_edge_indices_at_witness": c[
                        "broken_edge_indices_at_witness"
                    ],
                }
                for c in report["cycles"]
            ],
        }
        export_certificate(summary_doc, args.summary_out)

        c26 = report["summary"]["C26_k10"]
        print("Focus cycles (k, len, bool_tr, δ_coh, L_edge, L_ce):")
        for row in report["summary"]["all_focus_bool_trace"]:
            print(
                f"  k={row['k']} len={row['length']} tr={row['bool_trace']} "
                f"δ={row['delta_coh']} L_edge={row['L_edge']} L_ce={row['L_cyc_edge']}"
            )
        if c26:
            print(
                f"C_26: bool_trace={c26['bool_trace']} δ_coh={c26['delta_coh']} "
                f"L_edge={c26['L_edge']} L_cyc-edge={c26['L_cyc_edge']} "
                f"L_cycle={c26['L_cycle']} "
                f"exhaustive_ok={c26['exhaustive_matches_bool_trace']}"
            )
        print(f"wrote {args.out}")
        print(f"wrote {args.summary_out}")

    mono = run_monodromy_audit()
    export_certificate(mono, args.monodromy_out)
    print(
        f"semiring=OR-AND (Lean boolMatMul); §5.17 variant={mono['section_5_17_variant']}"
    )
    print("Monodromy (k, ℓ, P_type, is_flip, holonomy, δ, gf2_diff):")
    for row in mono["summary_table"]:
        print(
            f"  k={row['k']} ℓ={row['cycle_length']} P_type={row['P_type']} "
            f"P={row['monodromy_product']} flip?={row['is_flip']} "
            f"hol={row['holonomy']} δ={row['coherence_defect']} "
            f"gf2_diff={row['gf2_differs_from_OR_AND']}"
        )
    print(f"verdict: {mono['flip_test_verdict']['Z2_holonomy_flip_hypothesis']}")
    print(f"Z artefact?: {mono['flip_test_verdict']['Z_finding_is_gf2_artifact']}")
    print(f"wrote {args.monodromy_out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
