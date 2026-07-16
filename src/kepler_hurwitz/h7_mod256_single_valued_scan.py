"""
H7Mod256 single-valuedness scan — does the odd-u step-6 map descend to Fin 256?

Governance [B] diagnostic only:
- Separate from sealed H7 mod-128 graph and from the separation milestone
  (``h7_mod256_separation_scan.py`` / ``H7Mod256Separation.lean``).
- Separation of mod-128 collisions at 256 is necessary but **not** sufficient
  for a well-defined ``Fin 256 → Fin 256`` edge.
- No global Collatz claim.

Claim under test (odd-u / odd-v family ``u ≡ 3 (mod 4)``):
if ``u₁ ≡ u₂ (mod 256)``, then
``syracuseOddStep(step5Terminal u₁) ≡ syracuseOddStep(step5Terminal u₂) (mod 256)``.

Equivalently: for each residue ``r`` in the admissible class, all lifts
``u = r + 256k`` in a scan window share one image mod 256.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any, Literal

from kepler_hurwitz.h7_mod256_separation_scan import (
    MOD256,
    MOD512,
    step6_image,
    step6_odd_u_odd_v_affine,
    step7_image,
)

GOVERNANCE_TAG = "[B]"
PROJECT = "H7Mod256"

SingleValuedVerdict = Literal[
    "single_valued_at_256",
    "multi_valued_need_512",
    "mixed",
]


@dataclass(frozen=True)
class ResidueSingleValuedRecord:
    residue_mod: int
    modulus: int
    map_name: str
    family: str
    representatives: list[int]
    images_mod_codomain: list[int]
    unique_images: list[int]
    single_valued: bool
    multi_valued: bool


@dataclass(frozen=True)
class MultiValuedWitness:
    map_name: str
    family: str
    u_a: int
    u_b: int
    residue_mod: int
    modulus: int
    image_a: int
    image_b: int
    image_a_mod: int
    image_b_mod: int
    codomain_modulus: int


def _lifts(residue: int, *, modulus: int, k_max: int) -> list[int]:
    return [residue + modulus * k for k in range(k_max + 1)]


def scan_residue_single_valuedness(
    *,
    image_fn,
    map_name: str,
    family: str,
    residues: list[int],
    domain_modulus: int,
    codomain_modulus: int,
    k_max: int = 7,
) -> list[ResidueSingleValuedRecord]:
    """
    For each residue in ``residues``, check whether all lifts
    ``r + domain_modulus·k`` (k = 0..k_max) share one image mod ``codomain_modulus``.
    """
    rows: list[ResidueSingleValuedRecord] = []
    for r in residues:
        reps = _lifts(r, modulus=domain_modulus, k_max=k_max)
        images = [image_fn(u) for u in reps]
        imgs = [img % codomain_modulus for img in images]
        unique = sorted(set(imgs))
        rows.append(
            ResidueSingleValuedRecord(
                residue_mod=r,
                modulus=domain_modulus,
                map_name=map_name,
                family=family,
                representatives=reps,
                images_mod_codomain=imgs,
                unique_images=unique,
                single_valued=len(unique) == 1,
                multi_valued=len(unique) > 1,
            )
        )
    return rows


def odd_u_odd_v_residues(modulus: int) -> list[int]:
    """Admissible shell ``u ≡ 3 (mod 4)`` inside ``0 .. modulus-1``."""
    return [r for r in range(modulus) if r % 4 == 3]


def odd_residues(modulus: int) -> list[int]:
    return list(range(1, modulus, 2))


def find_multi_valued_witnesses(
    rows: list[ResidueSingleValuedRecord],
    *,
    image_fn,
    codomain_modulus: int,
    limit: int = 8,
) -> list[MultiValuedWitness]:
    out: list[MultiValuedWitness] = []
    for row in rows:
        if not row.multi_valued:
            continue
        # Pick first two lifts with distinct images mod codomain.
        by_img: dict[int, int] = {}
        pair: tuple[int, int] | None = None
        for u in row.representatives:
            img = image_fn(u) % codomain_modulus
            if img in by_img and by_img[img] != u:
                continue
            for prev_img, prev_u in by_img.items():
                if prev_img != img:
                    pair = (prev_u, u)
                    break
            by_img[img] = u
            if pair is not None:
                break
        if pair is None:
            continue
        a, b = pair
        ia, ib = image_fn(a), image_fn(b)
        out.append(
            MultiValuedWitness(
                map_name=row.map_name,
                family=row.family,
                u_a=a,
                u_b=b,
                residue_mod=row.residue_mod,
                modulus=row.modulus,
                image_a=ia,
                image_b=ib,
                image_a_mod=ia % codomain_modulus,
                image_b_mod=ib % codomain_modulus,
                codomain_modulus=codomain_modulus,
            )
        )
        if len(out) >= limit:
            break
    return out


def affine_coeff_diagnostic() -> dict[str, Any]:
    """
    Why Fin(2^n)→Fin(2^n) fails for ``S⁶ = 1458w + 1171``:
    ``v₂(1458) = 1``, and ``u ≡ u' (mod 2^n)`` with ``u = 4w+3`` forces
    ``Δw`` multiple of ``2^{n-2}``, so image shift has 2-valuation ``n-1 < n``.
    """
    coeff = 1458
    rows = []
    for n in range(3, 12):
        delta_w = 1 << (n - 2)
        delta_img = (coeff * delta_w) % (1 << n)
        rows.append(
            {
                "n": n,
                "domain_modulus": 1 << n,
                "delta_w_for_delta_u_eq_modulus": delta_w,
                "delta_image_mod_2n": delta_img,
                "zero_mod_2n": delta_img == 0,
            }
        )
    # Domain 2^{n+1} → codomain 2^n: Δw = 2^{n-1}, valuation 1+(n-1)=n.
    lift_rows = []
    for n in range(3, 12):
        delta_w = 1 << (n - 1)
        delta_img = (coeff * delta_w) % (1 << n)
        lift_rows.append(
            {
                "codomain_bits": n,
                "domain_modulus": 1 << (n + 1),
                "codomain_modulus": 1 << n,
                "delta_w": delta_w,
                "delta_image_mod_codomain": delta_img,
                "zero_mod_codomain": delta_img == 0,
            }
        )
    return {
        "affine": "1458*w + 1171",
        "coeff": coeff,
        "v2_coeff": 1,
        "same_bits_fin_to_fin": rows,
        "domain_one_bit_higher_image_mod_2n": lift_rows,
        "documented_witness": {
            "u_a": 3,
            "u_b": 259,
            "both_mod256": 3,
            "images_mod256": [
                step6_odd_u_odd_v_affine(0) % MOD256,
                step6_odd_u_odd_v_affine(64) % MOD256,
            ],
            "note": "259 = 3+256; w lifts 0 → 64; Δimage ≡ 128 (mod 256)",
        },
    }


def _summary_counts(rows: list[ResidueSingleValuedRecord]) -> dict[str, int]:
    return {
        "residue_count": len(rows),
        "single_valued_count": sum(1 for r in rows if r.single_valued),
        "multi_valued_count": sum(1 for r in rows if r.multi_valued),
    }


def _verdict_from_counts(*, multi: int, single: int) -> SingleValuedVerdict:
    if multi == 0 and single > 0:
        return "single_valued_at_256"
    if single == 0 and multi > 0:
        return "multi_valued_need_512"
    return "mixed"


def run_single_valued_scan(*, k_max: int = 7) -> dict[str, Any]:
    family_odd_v = "odd_u_odd_v_u_eq_4w_plus_3"
    map6 = "step6_syracuse_odd_from_step5Terminal"
    map7 = "step7_syracuse_odd_from_step6Terminal"

    step6_odd_v_mod256 = scan_residue_single_valuedness(
        image_fn=step6_image,
        map_name=map6,
        family=family_odd_v,
        residues=odd_u_odd_v_residues(MOD256),
        domain_modulus=MOD256,
        codomain_modulus=MOD256,
        k_max=k_max,
    )
    step6_all_odd_mod256 = scan_residue_single_valuedness(
        image_fn=step6_image,
        map_name=map6,
        family="all_odd_u",
        residues=odd_residues(MOD256),
        domain_modulus=MOD256,
        codomain_modulus=MOD256,
        k_max=k_max,
    )
    step7_all_odd_mod256 = scan_residue_single_valuedness(
        image_fn=step7_image,
        map_name=map7,
        family="all_odd_v_even_u_step6_family",
        residues=odd_residues(MOD256),
        domain_modulus=MOD256,
        codomain_modulus=MOD256,
        k_max=k_max,
    )

    # Escalation diagnostics (not a Fin-512 graph claim).
    step6_odd_v_dom512_img256 = scan_residue_single_valuedness(
        image_fn=step6_image,
        map_name=map6,
        family=family_odd_v,
        residues=odd_u_odd_v_residues(MOD512),
        domain_modulus=MOD512,
        codomain_modulus=MOD256,
        k_max=k_max,
    )
    step6_odd_v_fin512 = scan_residue_single_valuedness(
        image_fn=step6_image,
        map_name=map6,
        family=family_odd_v,
        residues=odd_u_odd_v_residues(MOD512),
        domain_modulus=MOD512,
        codomain_modulus=MOD512,
        k_max=k_max,
    )

    witnesses = find_multi_valued_witnesses(
        step6_odd_v_mod256,
        image_fn=step6_image,
        codomain_modulus=MOD256,
        limit=8,
    )
    # Prefer documented 3 vs 259 if present.
    documented = MultiValuedWitness(
        map_name=map6,
        family=family_odd_v,
        u_a=3,
        u_b=259,
        residue_mod=3,
        modulus=MOD256,
        image_a=step6_image(3),
        image_b=step6_image(259),
        image_a_mod=step6_image(3) % MOD256,
        image_b_mod=step6_image(259) % MOD256,
        codomain_modulus=MOD256,
    )

    c_odd_v = _summary_counts(step6_odd_v_mod256)
    c_all = _summary_counts(step6_all_odd_mod256)
    c_step7 = _summary_counts(step7_all_odd_mod256)
    c_dom512 = _summary_counts(step6_odd_v_dom512_img256)
    c_fin512 = _summary_counts(step6_odd_v_fin512)

    verdict = _verdict_from_counts(
        multi=c_odd_v["multi_valued_count"],
        single=c_odd_v["single_valued_count"],
    )

    return {
        "governance": GOVERNANCE_TAG,
        "project": PROJECT,
        "scope": (
            "Diagnostic: whether odd-u step-6 (and related) maps are single-valued "
            "as Fin-256→Fin-256 on admissible residue classes. Not a state-graph proof."
        ),
        "claim_under_test": {
            "family": family_odd_v,
            "statement": (
                "u1 ≡ u2 (mod 256) and u ≡ 3 (mod 4) imply "
                "syracuseOddStep(step5Terminal u1) ≡ "
                "syracuseOddStep(step5Terminal u2) (mod 256)"
            ),
            "affine": "1458*((u-3)/4) + 1171",
        },
        "k_max": k_max,
        "affine_2adic_diagnostic": affine_coeff_diagnostic(),
        "step6_odd_u_odd_v_fin256": [asdict(r) for r in step6_odd_v_mod256],
        "step6_all_odd_u_fin256": [asdict(r) for r in step6_all_odd_mod256],
        "step7_all_odd_v_fin256": [asdict(r) for r in step7_all_odd_mod256],
        "escalation": {
            "step6_odd_u_odd_v_domain512_image256": [asdict(r) for r in step6_odd_v_dom512_img256],
            "step6_odd_u_odd_v_fin512": [asdict(r) for r in step6_odd_v_fin512],
        },
        "multi_valued_witnesses": [asdict(documented)]
        + [asdict(w) for w in witnesses if not (w.u_a == 3 and w.u_b == 259)],
        "summary": {
            "step6_odd_u_odd_v_fin256": c_odd_v,
            "step6_all_odd_u_fin256": c_all,
            "step7_all_odd_v_fin256": c_step7,
            "step6_odd_u_odd_v_domain512_image256": c_dom512,
            "step6_odd_u_odd_v_fin512": c_fin512,
            "documented_witness_images_mod256": [
                documented.image_a_mod,
                documented.image_b_mod,
            ],
            "verdict": verdict,
            "fin256_edge_allowed": verdict == "single_valued_at_256",
            "h7_state_graph256_scaffold_allowed": False,
        },
        "recommended_next_step": (
            "Do NOT introduce a Fin-256→Fin-256 odd-u edge. Prove the multi-valued "
            "collision in Lean (e.g. u=3 vs u=259). Optionally investigate a "
            "domain-mod-512 / image-mod-256 edge (empirically single-valued for the "
            "affine odd-v shell) — still not Fin-512→Fin-512, and not a full graph."
            if verdict == "multi_valued_need_512"
            else (
                "If single-valued: prove Lean well-definedness and scaffold "
                "H7StateGraph256 for that family only."
                if verdict == "single_valued_at_256"
                else "Mixed: Lean only single-valued families; escalate multi-valued ones."
            )
        ),
    }


def export_single_valued_scan(
    path: str | Path | None = None,
    *,
    k_max: int = 7,
) -> dict[str, Any]:
    payload = run_single_valued_scan(k_max=k_max)
    if path is not None:
        out = Path(path)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(json.dumps(payload, indent=2, sort_keys=False) + "\n", encoding="utf-8")
    return payload


def main() -> None:
    root = Path(__file__).resolve().parents[2]
    out = root / "docs" / "exports" / "h7_mod256_single_valued_scan.json"
    payload = export_single_valued_scan(out)
    summary = payload["summary"]
    print(f"Wrote {out}")
    print(f"governance={payload['governance']} verdict={summary['verdict']}")
    ov = summary["step6_odd_u_odd_v_fin256"]
    print(
        f"odd-u/odd-v Fin256: single={ov['single_valued_count']} "
        f"multi={ov['multi_valued_count']}"
    )
    print(
        f"documented witness images mod256: {summary['documented_witness_images_mod256']}"
    )
    esc = summary["step6_odd_u_odd_v_domain512_image256"]
    print(
        f"escalation domain512→img256: single={esc['single_valued_count']} "
        f"multi={esc['multi_valued_count']}"
    )


if __name__ == "__main__":
    main()
