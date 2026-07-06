"""Tests for scripts/onsager_vortex_export.py (ORQ-089 / E-089)."""

from __future__ import annotations

import csv
import importlib.util
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = ROOT / "scripts"


def _load_export_module():
    path = SCRIPTS / "onsager_vortex_export.py"
    spec = importlib.util.spec_from_file_location("onsager_vortex_export", path)
    assert spec and spec.loader
    module = importlib.util.module_from_spec(spec)
    sys.modules["onsager_vortex_export"] = module
    spec.loader.exec_module(module)
    return module


export = _load_export_module()


def test_prime_quadruplets_upto_contains_reference_quadruplet():
    quadruplets = list(export.prime_quadruplets_upto(20))
    assert (11, 13, 17, 19) in quadruplets


def test_normalize_record_reference_quadruplet():
    record = export.normalize_record((11, 13, 17, 19))
    assert record["vortex_winding"] == 1
    assert record["trivial_winding"] == 0
    assert record["phase_closure_ok"] is True
    assert record["ceab_closure_ok"] is True
    assert record["encircles_defect"] is True
    assert record["pop_threshold_steps"] == 4
    assert record["rotor_steps"] == 4
    assert record["rotor_gap_cycle"] == "(2,4);(4,2);(6,2);(2,6)"
    assert record["status"] == "B"


def test_export_records_writes_csv(tmp_path: Path):
    output_path = tmp_path / "onsager_vortex_export.csv"
    summary_path = tmp_path / "onsager_vortex_export.summary.json"
    count = export.export_records(
        limit=100,
        output_path=output_path,
        summary_path=summary_path,
    )
    assert count >= 1
    assert output_path.exists()
    text = output_path.read_text(encoding="utf-8")
    assert "p,p_plus_2,p_plus_6,p_plus_8" in text
    assert "11,13,17,19" in text

    with output_path.open(encoding="utf-8", newline="") as handle:
        rows = list(csv.DictReader(handle))
    assert rows[0]["status"] == "B"
    assert rows[0]["vortex_winding"] == "1"
    assert rows[0]["trivial_winding"] == "0"

    summary = json.loads(summary_path.read_text(encoding="utf-8"))
    assert summary["status"] == "B"
    assert summary["claim"] == "combinatorial circulation diagnostic only"
    assert summary["records"] == count
    assert summary["all_vortex_winding_one"] is True
    assert summary["all_trivial_winding_zero"] is True


def test_prime_quadruplets_upto_matches_sieve_at_scale():
    limit = 10_000
    upto = list(export.prime_quadruplets_upto(limit))
    from kepler_hurwitz.onsager_vortex_diagnostics import generate_prime_quadruplets_sieve

    sieve = generate_prime_quadruplets_sieve(3, limit - 8)
    assert upto == sieve
