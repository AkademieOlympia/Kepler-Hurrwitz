"""Tests for H7Mod256 [B] single-valuedness scan (Fin-256 edge candidacy)."""

from __future__ import annotations

from kepler_hurwitz.h7_mod256_separation_scan import step6_image, step6_odd_u_odd_v_affine
from kepler_hurwitz.h7_mod256_single_valued_scan import (
    export_single_valued_scan,
    odd_u_odd_v_residues,
    run_single_valued_scan,
)


def test_documented_multi_valued_witness_3_vs_259() -> None:
    assert 3 % 256 == 259 % 256 == 3
    assert 3 % 4 == 259 % 4 == 3
    assert step6_image(3) == step6_odd_u_odd_v_affine(0)
    assert step6_image(259) == step6_odd_u_odd_v_affine(64)
    assert step6_image(3) % 256 == 147
    assert step6_image(259) % 256 == 19
    assert step6_image(3) % 256 != step6_image(259) % 256


def test_all_odd_v_residues_multi_valued_mod256() -> None:
    payload = run_single_valued_scan(k_max=3)
    summary = payload["summary"]["step6_odd_u_odd_v_fin256"]
    assert summary["residue_count"] == len(odd_u_odd_v_residues(256))
    assert summary["single_valued_count"] == 0
    assert summary["multi_valued_count"] == 64
    assert payload["summary"]["verdict"] == "multi_valued_need_512"
    assert payload["summary"]["fin256_edge_allowed"] is False
    assert payload["summary"]["h7_state_graph256_scaffold_allowed"] is False


def test_domain512_image256_single_valued_for_odd_v_shell() -> None:
    payload = run_single_valued_scan(k_max=3)
    esc = payload["summary"]["step6_odd_u_odd_v_domain512_image256"]
    assert esc["multi_valued_count"] == 0
    assert esc["single_valued_count"] == 128
    # Same-bits Fin512→Fin512 still fails.
    fin512 = payload["summary"]["step6_odd_u_odd_v_fin512"]
    assert fin512["multi_valued_count"] == 128


def test_export_writes_json(tmp_path) -> None:
    path = tmp_path / "h7_mod256_single_valued_scan.json"
    payload = export_single_valued_scan(path, k_max=2)
    assert path.is_file()
    assert payload["summary"]["verdict"] == "multi_valued_need_512"
