"""
Semiprime-surgery probe for Channel-7 deep-tail class ``n ≡ 71 (mod 256)``.

Governance
----------
- Status: exploratory scaffold ``[C]`` / probe — NOT a Collatz proof.
- Reuses existing Deep-Lift / H7 diagnostics (``deep_lift_hensel_diagnostic``).
- "Surgery matrices" below are a **provisional diagnostic construction** ``[C]``:
  transfer counts on mod-1024 children of ``71 mod 256`` under odd Syracuse steps,
  plus cut-edge flags (wrap / stay-in-deep-tail). They are **not** a formal
  EABC universal-cover desingularization and do **not** close Deep-Tail entry
  or the BoolTrace → archimedean-descent arrow.
- Explicit non-claims: Semiprime24Bridge / Tensorchirurgie / Typentrennung
  ``E_Δ ≠ E_vol`` are **not** attributed to PR #8; those remain separate / open.
- Collatz? **NEIN**.

Computed vs invented
--------------------
Computed from existing defs:
  - ``deep_lift_fiber`` / ``deep_lift_constant`` / H7 witness matrix
  - affine landing ``243t + 103 ≡ 71 (mod 256)`` ⇒ ``t ≡ 160``
  - mod-1024 children of ``71 mod 256``: ``{71, 327, 583, 839}``
  - sample orbits under ``syracuse_odd_step``
Provisional ``[C]`` invention:
  - adjacency / cut surgery matrices on those four children
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

from kepler_hurwitz.deep_lift_hensel_diagnostic import (
    CONTROLLED_RESIDUES_MOD128,
    DEEP_BRANCH_MULTIPLIER,
    deep_lift_constant,
    deep_lift_fiber,
    generate_h7_witness_matrix,
    odd_core,
    syracuse_odd_step,
    v2,
)

__all__ = [
    "PROBE_TAG",
    "TARGET_RESIDUE_MOD256",
    "MOD256",
    "MOD1024",
    "CHILDREN_71_MOD1024",
    "FORMAL_CHILD_MOD1024",
    "DEEP_TAIL_MOD128",
    "solve_affine_landing_mod256",
    "mod1024_children_of_71",
    "classify_landing",
    "provisional_surgery_matrix_71",
    "run_semiprime_surgery_71_probe",
    "export_probe_json",
]

PROBE_TAG = "[C]"
TARGET_RESIDUE_MOD256 = 71
MOD256 = 256
MOD1024 = 1024
# Maximal short-affine formal child (Lean V2.17): 583 mod 1024
FORMAL_CHILD_MOD1024 = 583
# Affine parameter for j=3 landing on 71 mod 256 (Lean V2.17)
J3_LANDING_T_MOD256 = 160
# Affine parameter for formal child 583 (Lean V2.17)
J3_FORMAL_T_MOD1024 = 672
DEEP_TAIL_MOD128 = frozenset({31, 47, 63, 71, 103, 111})
CHILDREN_71_MOD1024 = (71, 327, 583, 839)


def solve_affine_landing_mod256(j: int, target: int = TARGET_RESIDUE_MOD256) -> dict[str, Any]:
    """
    Solve ``243·t + c_j ≡ target (mod 256)`` when solvable.

    Uses that ``243 ≡ -13 (mod 256)`` and ``gcd(243,256)=1``, so unique ``t``.
    """
    c_j = deep_lift_constant(j)
    # 243 inverse mod 256: 243*91 = 22113 ≡ 97? better brute force on 256
    inv = None
    for cand in range(MOD256):
        if (DEEP_BRANCH_MULTIPLIER * cand) % MOD256 == 1:
            inv = cand
            break
    assert inv is not None
    t = (inv * ((target - c_j) % MOD256)) % MOD256
    fiber = deep_lift_fiber(j, t)
    return {
        "j": j,
        "c_j": c_j,
        "target_mod256": target,
        "t_mod256": t,
        "fiber": fiber,
        "fiber_mod256": fiber % MOD256,
        "lands": fiber % MOD256 == target,
        "inverse_243_mod256": inv,
    }


def mod1024_children_of_71() -> list[int]:
    """Residues ``r`` with ``r ≡ 71 (mod 256)`` and ``0 ≤ r < 1024``."""
    return [r for r in range(MOD1024) if r % MOD256 == TARGET_RESIDUE_MOD256]


def classify_landing(n: int) -> str:
    """Bucket an odd Syracuse image for the provisional matrix."""
    r128 = n % 128
    r256 = n % MOD256
    r1024 = n % MOD1024
    if r1024 == FORMAL_CHILD_MOD1024:
        return "formal_mod1024_583"
    if r256 in (39, 79, 95):
        return "partial_formal_mod256"
    if r128 in CONTROLLED_RESIDUES_MOD128:
        return "controlled_mod128"
    if r128 in DEEP_TAIL_MOD128:
        return "deep_tail_mod128"
    if r256 == TARGET_RESIDUE_MOD256:
        return "stay_71_mod256"
    return "other"


def _odd_syracuse_exact(n: int) -> tuple[int, int, bool]:
    """Return (exact_target, valuation, left_residue_window).

    ``left_residue_window`` is a provisional wrap proxy ``[C]``: image ``≥ 1024``
    means the step left the single mod-1024 residue chart (not a Lean wrap edge).
    """
    if n % 2 == 0:
        raise ValueError("expected odd n")
    value = 3 * n + 1
    valuation = v2(value)
    exact = value >> valuation
    left_window = exact >= MOD1024
    return exact, valuation, left_window


def provisional_surgery_matrix_71(
    *,
    samples_per_child: int = 8,
    depth: int = 1,
) -> dict[str, Any]:
    """
    Provisional ``[C]`` surgery / transfer matrix on mod-1024 children of ``71``.

    Definition (probe, not theorem)
    -------------------------------
    States ``S = {71, 327, 583, 839}`` (the four lifts of ``71 mod 256`` to mod 1024).
    For each child residue ``r ∈ S`` and sample index ``k = 0..samples_per_child-1``,
    take ``n = r + 1024·k`` (odd automatically), apply ``depth`` odd Syracuse steps,
    and accumulate:
      - adjacency counts ``child → classify_landing(image)``
      - cut candidates: edges with ``wrap`` (image ≥ 1024) OR landing still in deep-tail
        without formal child ``583``

    This is **not** a Lean-certified surgery and does **not** imply net descent.
    """
    children = list(CHILDREN_71_MOD1024)
    labels = sorted(
        {
            "formal_mod1024_583",
            "partial_formal_mod256",
            "controlled_mod128",
            "deep_tail_mod128",
            "stay_71_mod256",
            "other",
            *{f"child_{c}" for c in children},
        }
    )
    # Index rows by child, columns by landing label
    matrix: dict[str, dict[str, int]] = {
        f"child_{c}": {lab: 0 for lab in labels} for c in children
    }
    cut_edges: list[dict[str, Any]] = []
    sample_rows: list[dict[str, Any]] = []

    for r in children:
        for k in range(samples_per_child):
            n = r + MOD1024 * k
            cur = n
            wrap_any = False
            path: list[int] = [n]
            for _ in range(depth):
                exact, nu, wraps = _odd_syracuse_exact(cur)
                wrap_any = wrap_any or wraps
                cur = exact
                path.append(cur)
            # Prefer residue-class column when image still a child
            if cur % MOD1024 in children and cur % MOD256 == TARGET_RESIDUE_MOD256:
                landing = f"child_{cur % MOD1024}"
            else:
                landing = classify_landing(cur)
            matrix[f"child_{r}"][landing] = matrix[f"child_{r}"].get(landing, 0) + 1
            is_cut = wrap_any or landing in {
                "deep_tail_mod128",
                "stay_71_mod256",
                *[f"child_{c}" for c in children if c != FORMAL_CHILD_MOD1024],
            }
            # Formal child self-loops / exits to formal are not cut candidates
            if landing == "formal_mod1024_583" or landing == f"child_{FORMAL_CHILD_MOD1024}":
                is_cut = False
            row = {
                "start": n,
                "start_child": r,
                "k": k,
                "depth": depth,
                "path": path,
                "image": cur,
                "image_mod1024": cur % MOD1024,
                "landing": landing,
                "wrap_any": wrap_any,
                "cut_candidate": is_cut,
                "nu2_first": v2(3 * n + 1),
            }
            sample_rows.append(row)
            if is_cut:
                cut_edges.append(
                    {
                        "source_child": r,
                        "landing": landing,
                        "start": n,
                        "image": cur,
                    }
                )

    # Dense integer matrix aligned to children × labels (for JSON consumers)
    col_order = labels
    dense = [[matrix[f"child_{c}"].get(lab, 0) for lab in col_order] for c in children]

    return {
        "definition_tag": PROBE_TAG,
        "definition": (
            "Provisional transfer counts on mod-1024 children of 71 mod 256 "
            "under odd Syracuse; cut = wrap OR non-formal deep-tail stay. "
            "Not a universal-cover surgery; not a Lean theorem."
        ),
        "states_mod1024": children,
        "column_labels": col_order,
        "dense_matrix": dense,
        "sparse_counts": matrix,
        "samples_per_child": samples_per_child,
        "depth": depth,
        "cut_edge_count": len(cut_edges),
        "cut_edges_sample": cut_edges[:32],
        "sample_rows": sample_rows,
        "formal_child": FORMAL_CHILD_MOD1024,
        "not_claimed": [
            "universal cover / desingularization",
            "DeepLiftFiber dynamic entry for full 71 mod 256",
            "BoolTrace(P)=0 ⇒ archimedean descent",
            "Collatz termination",
        ],
    }


def run_semiprime_surgery_71_probe(
    *,
    j_max: int = 5,
    samples_per_child: int = 8,
    depth: int = 1,
) -> dict[str, Any]:
    """Assemble probe payload: existing Deep-Lift facts + provisional surgery matrix."""
    landings = [solve_affine_landing_mod256(j) for j in range(1, j_max + 1)]
    j3 = next(row for row in landings if row["j"] == 3)
    children = mod1024_children_of_71()
    assert children == list(CHILDREN_71_MOD1024)

    # Spot-check Lean-aligned facts
    lean_checks = {
        "j3_c_j": deep_lift_constant(3),
        "j3_t_160_fiber_mod256": deep_lift_fiber(3, J3_LANDING_T_MOD256) % MOD256,
        "j3_t_672_fiber_mod1024": deep_lift_fiber(3, J3_FORMAL_T_MOD1024) % MOD1024,
        "expected_71": TARGET_RESIDUE_MOD256,
        "expected_583": FORMAL_CHILD_MOD1024,
        "ok": (
            deep_lift_constant(3) == 103
            and deep_lift_fiber(3, J3_LANDING_T_MOD256) % MOD256 == 71
            and deep_lift_fiber(3, J3_FORMAL_T_MOD1024) % MOD1024 == 583
            and j3["t_mod256"] == J3_LANDING_T_MOD256
        ),
    }

    # Small orbit gallery for n ≡ 71 mod 256 (diagnostic only)
    gallery: list[dict[str, Any]] = []
    for r in children:
        n = r  # k=0
        orbit = [n]
        cur = n
        for _ in range(4):
            cur = syracuse_odd_step(cur)
            orbit.append(cur)
        gallery.append(
            {
                "start": n,
                "child_mod1024": r,
                "is_formal_child": r == FORMAL_CHILD_MOD1024,
                "orbit": orbit,
                "orbit_mod256": [x % MOD256 for x in orbit],
                "orbit_mod1024": [x % MOD1024 for x in orbit],
                "landings": [classify_landing(x) for x in orbit[1:]],
                "odd_cores": [odd_core(x) if x % 2 == 0 else x for x in orbit],
            }
        )

    surgery = provisional_surgery_matrix_71(
        samples_per_child=samples_per_child,
        depth=depth,
    )

    return {
        "schema": "semiprime_surgery_71_mod256_probe/v1",
        "governance": {
            "tag": PROBE_TAG,
            "status": "exploratory_scaffold",
            "collatz": False,
            "closes_deep_tail": False,
            "closes_absorption_arrow": False,
            "pr8_disclaimer": (
                "Semiprime24Bridge / Tensorchirurgie / Typentrennung E_Δ≠E_vol "
                "are NOT content of PR #8 (energiedoku exports)."
            ),
            "stein1_stein2": "open",
            "universal_cover": "not_proved",
        },
        "target": {
            "residue_mod256": TARGET_RESIDUE_MOD256,
            "deep_tail_mod128": sorted(DEEP_TAIL_MOD128),
            "controlled_mod128": sorted(CONTROLLED_RESIDUES_MOD128),
            "mod1024_children": children,
            "formal_child_mod1024": FORMAL_CHILD_MOD1024,
        },
        "computed_from_existing": {
            "h7_witness_matrix": generate_h7_witness_matrix(j_max=min(j_max, 5)),
            "affine_landings_mod256": landings,
            "lean_aligned_checks": lean_checks,
            "orbit_gallery_k0": gallery,
        },
        "provisional_surgery_matrix_C": surgery,
        "open_reductions": {
            "stein1_deep_tail_entry": (
                "DeepLiftFiber dynamic entry / full class 71 mod 256 still open; "
                "only child 583 mod 1024 has formal LocalWitness (V2.17)."
            ),
            "stein2_absorption_arrow": (
                "BoolTrace(P)=0 ⇒ archimedean descent remains open [C]; "
                "this probe does not construct that implication."
            ),
        },
    }


def export_probe_json(
    path: str | Path = "docs/exports/semiprime_surgery_71_mod256_probe.json",
    **kwargs: Any,
) -> dict[str, Any]:
    payload = run_semiprime_surgery_71_probe(**kwargs)
    out = Path(path)
    out.parent.mkdir(parents=True, exist_ok=True)
    # Drop bulky sample_rows from export by default; keep summary counts
    export_payload = dict(payload)
    surg = dict(export_payload["provisional_surgery_matrix_C"])
    surg.pop("sample_rows", None)
    export_payload["provisional_surgery_matrix_C"] = surg
    out.write_text(json.dumps(export_payload, indent=2) + "\n", encoding="utf-8")
    return export_payload
