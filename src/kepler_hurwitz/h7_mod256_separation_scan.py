"""
H7Mod256 separation scan — do mod-128 collision pairs already split mod 256?

Governance [B] diagnostic only:
- Does NOT prove Lean soundness of a Fin-256 state graph.
- Separate project from the sealed H7 mod-128 graph
  (``H7StateGraph.lean`` / ``notes/h7_mod128_state_graph.md``).
- No global Collatz claim.

Background (sealed mod-128 obstruction):
``h7_step6_odd_u_branch_precision_obstruction`` — ``u = 3`` vs ``u = 131``
both ≡ 3 (mod 128) and odd, but
``syracuseOddStep(step5Terminal u)`` residues differ mod 128
(19 vs 83). Map: ``step5Terminal u = 486u + 103``, then one Syracuse-odd step.
"""

from __future__ import annotations

import json
from collections import defaultdict
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal

from kepler_hurwitz.deep_lift_hensel_diagnostic import syracuse_odd_step

GOVERNANCE_TAG = "[B]"
PROJECT = "H7Mod256"
MOD128 = 128
MOD256 = 256
MOD512 = 512

# Documented Lean counterexample pair (H7StateGraph.lean).
DOCUMENTED_STEP6_COLLISION_PAIRS: tuple[tuple[int, int], ...] = ((3, 131),)

SeparationStatus = Literal[
    "separated_at_256",
    "still_collide_mod_256",
    "need_higher_2adic",
]


@dataclass(frozen=True)
class PairSeparationRecord:
    u_a: int
    u_b: int
    u_mod128: int
    map_name: str
    image_a: int
    image_b: int
    image_a_mod128: int
    image_b_mod128: int
    image_a_mod256: int
    image_b_mod256: int
    image_a_mod512: int
    image_b_mod512: int
    collide_mod128: bool
    separated_at_256: bool
    still_collide_mod_256: bool
    separated_at_512: bool
    status: SeparationStatus


@dataclass(frozen=True)
class ResidueClassSplitRecord:
    u_mod128: int
    map_name: str
    representatives: list[int]
    images_mod256: list[int]
    unique_images_mod256: list[int]
    splits_mod256: bool
    unique_images_mod512: list[int]
    splits_mod512: bool


def step5_terminal(u: int) -> int:
    """Lean ``ChannelSeven71Step6BranchingV215.step5Terminal``: ``486u + 103``."""
    return 486 * u + 103


def step6_terminal_even_u(v: int) -> int:
    """Lean ``ChannelSeven71Step7BranchingV215.step6Terminal``: ``1458v + 155``."""
    return 1458 * v + 155


def step6_image(u: int) -> int:
    """One Syracuse-odd step from ``step5Terminal u`` (the obstructed map)."""
    return syracuse_odd_step(step5_terminal(u))


def step7_image(v: int) -> int:
    """One Syracuse-odd step from even-``u`` step-6 terminal ``1458v + 155``."""
    return syracuse_odd_step(step6_terminal_even_u(v))


def step6_odd_u_odd_v_affine(w: int) -> int:
    """Lean ``step6_odd_u_odd_v_terminal``: ``S⁶ = 1458w + 1171`` for ``u = 4w + 3``."""
    return 1458 * w + 1171


def _status(*, separated_at_256: bool, still_collide_mod_256: bool, separated_at_512: bool) -> SeparationStatus:
    if separated_at_256:
        return "separated_at_256"
    if still_collide_mod_256 and not separated_at_512:
        return "need_higher_2adic"
    if still_collide_mod_256:
        return "need_higher_2adic"
    return "still_collide_mod_256"


def pair_separation(
    u_a: int,
    u_b: int,
    *,
    map_name: str,
    image_fn,
) -> PairSeparationRecord:
    img_a = image_fn(u_a)
    img_b = image_fn(u_b)
    a128, b128 = img_a % MOD128, img_b % MOD128
    a256, b256 = img_a % MOD256, img_b % MOD256
    a512, b512 = img_a % MOD512, img_b % MOD512
    sep256 = a256 != b256
    coll256 = a256 == b256
    sep512 = a512 != b512
    # Obstruction-style: same u mod 128, different image mod 128 (Fin-128 multi-valued).
    is_obstruction_style = (u_a % MOD128 == u_b % MOD128) and (a128 != b128)
    status = _status(
        separated_at_256=sep256,
        still_collide_mod_256=coll256,
        separated_at_512=sep512,
    )
    return PairSeparationRecord(
        u_a=u_a,
        u_b=u_b,
        u_mod128=u_a % MOD128,
        map_name=map_name,
        image_a=img_a,
        image_b=img_b,
        image_a_mod128=a128,
        image_b_mod128=b128,
        image_a_mod256=a256,
        image_b_mod256=b256,
        image_a_mod512=a512,
        image_b_mod512=b512,
        collide_mod128=is_obstruction_style,
        separated_at_256=sep256,
        still_collide_mod_256=coll256,
        separated_at_512=sep512,
        status=status,
    )


def odd_u_mod128_collision_pairs(
    *,
    u_max: int = 255,
) -> list[tuple[int, int]]:
    """All unordered pairs of odd ``u ≤ u_max`` with ``u_a ≡ u_b (mod 128)``, ``u_a < u_b``."""
    buckets: dict[int, list[int]] = defaultdict(list)
    for u in range(u_max + 1):
        if u % 2 == 1:
            buckets[u % MOD128].append(u)
    pairs: list[tuple[int, int]] = []
    for reps in buckets.values():
        for i, a in enumerate(reps):
            for b in reps[i + 1 :]:
                pairs.append((a, b))
    return pairs


def scan_documented_pairs() -> list[PairSeparationRecord]:
    return [
        pair_separation(a, b, map_name="step6_syracuse_odd_from_step5Terminal", image_fn=step6_image)
        for a, b in DOCUMENTED_STEP6_COLLISION_PAIRS
    ]


def scan_step6_collision_pairs(*, u_max: int = 255) -> list[PairSeparationRecord]:
    """Pairs that collide mod 128 on input and diverge mod 128 on step-6 image."""
    out: list[PairSeparationRecord] = []
    for a, b in odd_u_mod128_collision_pairs(u_max=u_max):
        rec = pair_separation(
            a, b, map_name="step6_syracuse_odd_from_step5Terminal", image_fn=step6_image
        )
        if rec.collide_mod128:
            out.append(rec)
    return out


def scan_step7_collision_pairs(*, v_max: int = 255) -> list[PairSeparationRecord]:
    """Analogous scan for step-7 map on odd ``v`` (even-``u`` step-6 family)."""
    out: list[PairSeparationRecord] = []
    for a, b in odd_u_mod128_collision_pairs(u_max=v_max):
        rec = pair_separation(
            a, b, map_name="step7_syracuse_odd_from_step6Terminal", image_fn=step7_image
        )
        if rec.collide_mod128:
            out.append(rec)
    return out


def scan_residue_class_splits(
    *,
    image_fn,
    map_name: str,
    u_max: int = 255,
) -> list[ResidueClassSplitRecord]:
    """
    Among odd ``u ∈ 0..u_max``, group by ``u % 128`` and check whether step images
    form a single residue mod 256 (and mod 512).
    """
    groups: dict[int, list[int]] = defaultdict(list)
    for u in range(u_max + 1):
        if u % 2 == 1:
            groups[u % MOD128].append(u)

    rows: list[ResidueClassSplitRecord] = []
    for r in sorted(groups):
        reps = groups[r]
        images = [image_fn(u) for u in reps]
        imgs256 = sorted({img % MOD256 for img in images})
        imgs512 = sorted({img % MOD512 for img in images})
        rows.append(
            ResidueClassSplitRecord(
                u_mod128=r,
                map_name=map_name,
                representatives=reps,
                images_mod256=[img % MOD256 for img in images],
                unique_images_mod256=imgs256,
                splits_mod256=len(imgs256) > 1,
                unique_images_mod512=imgs512,
                splits_mod512=len(imgs512) > 1,
            )
        )
    return rows


def _verdict(step6_pairs: list[PairSeparationRecord], step7_pairs: list[PairSeparationRecord]) -> str:
    all_pairs = step6_pairs + step7_pairs
    if not all_pairs:
        return "no_mod128_image_collisions_found"
    statuses = {p.status for p in all_pairs}
    if statuses == {"separated_at_256"}:
        return "separates_at_256"
    if "need_higher_2adic" in statuses or "still_collide_mod_256" in statuses:
        if "separated_at_256" in statuses:
            return "mixed"
        return "needs_512"
    return "mixed"


def run_separation_scan(*, u_max: int = 255) -> dict[str, Any]:
    documented = scan_documented_pairs()
    step6_pairs = scan_step6_collision_pairs(u_max=u_max)
    step7_pairs = scan_step7_collision_pairs(v_max=u_max)
    step6_splits = scan_residue_class_splits(
        image_fn=step6_image,
        map_name="step6_syracuse_odd_from_step5Terminal",
        u_max=u_max,
    )
    step7_splits = scan_residue_class_splits(
        image_fn=step7_image,
        map_name="step7_syracuse_odd_from_step6Terminal",
        u_max=u_max,
    )

    # Affine cross-check for documented family u = 4w+3.
    affine_check = []
    for a, b in DOCUMENTED_STEP6_COLLISION_PAIRS:
        assert a % 4 == 3 and b % 4 == 3
        wa, wb = (a - 3) // 4, (b - 3) // 4
        affine_a = step6_odd_u_odd_v_affine(wa)
        affine_b = step6_odd_u_odd_v_affine(wb)
        dyn_a, dyn_b = step6_image(a), step6_image(b)
        affine_check.append(
            {
                "u_a": a,
                "u_b": b,
                "w_a": wa,
                "w_b": wb,
                "affine_match": affine_a == dyn_a and affine_b == dyn_b,
                "affine_a_mod256": affine_a % MOD256,
                "affine_b_mod256": affine_b % MOD256,
                "delta_mod256": (affine_b - affine_a) % MOD256,
            }
        )

    verdict = _verdict(step6_pairs, step7_pairs)
    step6_split_count = sum(1 for r in step6_splits if r.splits_mod256)
    step7_split_count = sum(1 for r in step7_splits if r.splits_mod256)

    return {
        "governance": GOVERNANCE_TAG,
        "project": PROJECT,
        "scope": (
            "Diagnostic: whether mod-128 collision pairs for H7 step-6/7 odd branches "
            "already separate at 8 bits (mod 256). Not a Fin-256 graph proof."
        ),
        "sealed_mod128_pointer": {
            "lean": "KeplerHurwitz/Collatz/H7StateGraph.lean",
            "theorem": "h7_step6_odd_u_branch_precision_obstruction",
            "edge_families": [
                "H7EdgeFamily.step6OddUBranchObstruction",
                "H7EdgeFamily.step7BranchObstruction",
            ],
            "notes": "notes/h7_mod128_state_graph.md",
            "map": "syracuseOddStep(step5Terminal u) with step5Terminal u = 486u+103",
            "documented_pair": {"u_a": 3, "u_b": 131, "images_mod128": [19, 83]},
        },
        "u_max": u_max,
        "documented_pairs": [asdict(r) for r in documented],
        "step6_mod128_image_collision_pairs": [asdict(r) for r in step6_pairs],
        "step7_mod128_image_collision_pairs": [asdict(r) for r in step7_pairs],
        "step6_residue_class_splits": [asdict(r) for r in step6_splits],
        "step7_residue_class_splits": [asdict(r) for r in step7_splits],
        "affine_family_check_u_eq_4w_plus_3": affine_check,
        "summary": {
            "documented_all_separated_at_256": all(r.separated_at_256 for r in documented),
            "step6_collision_pair_count": len(step6_pairs),
            "step6_pairs_separated_at_256": sum(1 for r in step6_pairs if r.separated_at_256),
            "step6_pairs_still_collide_mod_256": sum(
                1 for r in step6_pairs if r.still_collide_mod_256
            ),
            "step7_collision_pair_count": len(step7_pairs),
            "step7_pairs_separated_at_256": sum(1 for r in step7_pairs if r.separated_at_256),
            "step7_pairs_still_collide_mod_256": sum(
                1 for r in step7_pairs if r.still_collide_mod_256
            ),
            "step6_odd_residue_classes_that_split_mod256": step6_split_count,
            "step7_odd_residue_classes_that_split_mod256": step7_split_count,
            "verdict": verdict,
        },
        "recommended_next_step": (
            "If verdict is separates_at_256: prove Lean lemmas for documented pairs "
            "(and odd-u-odd-v family) with distinct images mod 256; then consider a "
            "future Fin-256 H7StateGraph256. Do NOT build that graph in this milestone."
            if verdict == "separates_at_256"
            else (
                "Escalate diagnostic to mod 512; do NOT force a Fin-256 graph."
                if verdict == "needs_512"
                else "Mixed: document which families separate at 256 vs need 512; "
                "Lean only the separating family; escalate the rest."
            )
        ),
    }


def export_separation_scan(
    path: str | Path | None = None,
    *,
    u_max: int = 255,
) -> dict[str, Any]:
    payload = run_separation_scan(u_max=u_max)
    if path is not None:
        out = Path(path)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(payload, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    return payload


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    out = root / "docs" / "exports" / "h7_mod256_separation_scan.json"
    payload = export_separation_scan(out)
    summary = payload["summary"]
    print(f"Wrote {out}")
    print(f"governance={payload['governance']} verdict={summary['verdict']}")
    print(
        f"step6 pairs: {summary['step6_collision_pair_count']} "
        f"(sep256={summary['step6_pairs_separated_at_256']}, "
        f"coll256={summary['step6_pairs_still_collide_mod_256']})"
    )
    print(
        f"step7 pairs: {summary['step7_collision_pair_count']} "
        f"(sep256={summary['step7_pairs_separated_at_256']}, "
        f"coll256={summary['step7_pairs_still_collide_mod_256']})"
    )


if __name__ == "__main__":
    main()
