"""Tests for H7Mod256 [B] separation scan (mod-128 collision pairs)."""

from __future__ import annotations

from kepler_hurwitz.h7_mod256_separation_scan import (
    DOCUMENTED_STEP6_COLLISION_PAIRS,
    export_separation_scan,
    pair_separation,
    run_separation_scan,
    step5_terminal,
    step6_image,
    step6_odd_u_odd_v_affine,
)


def test_documented_pair_is_mod128_obstruction_and_separates_at_256() -> None:
    a, b = DOCUMENTED_STEP6_COLLISION_PAIRS[0]
    assert a == 3 and b == 131
    assert a % 128 == b % 128 == 3
    rec = pair_separation(
        a, b, map_name="step6", image_fn=step6_image
    )
    assert rec.collide_mod128
    assert rec.image_a_mod128 == 19
    assert rec.image_b_mod128 == 83
    assert rec.separated_at_256
    assert rec.image_a_mod256 == 147
    assert rec.image_b_mod256 == 211
    assert rec.status == "separated_at_256"


def test_affine_odd_u_odd_v_matches_dynamic() -> None:
    for u in (3, 131, 7, 135):
        assert u % 4 == 3
        w = (u - 3) // 4
        assert step6_odd_u_odd_v_affine(w) == step6_image(u)


def test_step5_terminal_formula() -> None:
    assert step5_terminal(3) == 486 * 3 + 103
    assert step5_terminal(131) == 486 * 131 + 103


def test_run_scan_verdict_separates_at_256() -> None:
    payload = run_separation_scan(u_max=255)
    assert payload["governance"] == "[B]"
    assert payload["project"] == "H7Mod256"
    summary = payload["summary"]
    assert summary["documented_all_separated_at_256"] is True
    assert summary["step6_collision_pair_count"] >= 1
    assert summary["step6_pairs_still_collide_mod_256"] == 0
    assert summary["step7_pairs_still_collide_mod_256"] == 0
    assert summary["verdict"] == "separates_at_256"
    # Every odd residue class that has ≥2 lifts in 0..255 should split mod 256
    # for the obstructed step-6 map (otherwise Fin-128 multi-valuedness would persist).
    splitting = [
        r for r in payload["step6_residue_class_splits"] if len(r["representatives"]) > 1
    ]
    assert splitting
    assert all(r["splits_mod256"] for r in splitting)


def test_export_writes_json(tmp_path) -> None:
    path = tmp_path / "h7_mod256_separation_scan.json"
    payload = export_separation_scan(path, u_max=255)
    assert path.is_file()
    assert payload["summary"]["verdict"] == "separates_at_256"
