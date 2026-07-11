"""Tests for EABC symplectic [[5,1,3]] stabilizer L-gap bridge [C]."""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from kepler_hurwitz.eabc_symplectic_stabilizer_bridge import (
    FIRST_L_CHI_MINUS3_ZEROS,
    FUNDAMENTAL_FREQ_DEFAULT,
    GOVERNANCE,
    SYMPLECTIC_BRIDGE_TAG,
    analyze_stabilizer_bridge,
    build_stabilizer_bridge_analysis,
    export_stabilizer_bridge_json,
    gap_to_symplectic_stabilizer,
    stabilizer_histogram,
    stabilizer_label,
    symplectic_vector_valid,
)


class TestGapToSymplectic:
    def test_state_idx_in_range(self) -> None:
        for gap in (0.1, 1.0, 3.208, 4.4557, 100.0):
            rec = gap_to_symplectic_stabilizer(gap)
            assert 1 <= rec.state_idx <= 15

    def test_symplectic_vector_format(self) -> None:
        rec = gap_to_symplectic_stabilizer(3.2095)
        assert symplectic_vector_valid(rec.symplectic_vector)
        assert rec.symplectic_vector == f"({rec.x_bits} | {rec.z_bits})"
        assert len(rec.x_bits) == 2
        assert len(rec.z_bits) == 2
        assert all(c in "01" for c in rec.x_bits + rec.z_bits)

    def test_known_gap_mapping(self) -> None:
        # gap = 11.2492 - 8.0397 = 3.2095 -> phase ~ 0 -> S_1
        rec = gap_to_symplectic_stabilizer(3.2095)
        assert rec.state_idx == 1
        assert rec.symplectic_vector == "(00 | 01)"

    def test_pauli_stabilizer_nonempty(self) -> None:
        rec = gap_to_symplectic_stabilizer(1.5)
        assert len(rec.pauli_stabilizer) == 5
        assert all(c in "IXYZ" for c in rec.pauli_stabilizer)


class TestBridge:
    def test_runs_on_fallback_zeros(self) -> None:
        rows = analyze_stabilizer_bridge(FIRST_L_CHI_MINUS3_ZEROS)
        assert len(rows) == len(FIRST_L_CHI_MINUS3_ZEROS) - 1
        for row in rows:
            assert row.gap == pytest.approx(row.gamma_next - row.gamma_n)
            assert row.tag == SYMPLECTIC_BRIDGE_TAG
            assert 1 <= row.stabilizer.state_idx <= 15

    def test_histogram_sums(self) -> None:
        rows = analyze_stabilizer_bridge(FIRST_L_CHI_MINUS3_ZEROS)
        hist = stabilizer_histogram(rows)
        assert set(hist.keys()) == set(range(1, 16))
        assert sum(hist.values()) == len(rows)

    def test_stabilizer_label(self) -> None:
        assert stabilizer_label(1) == "S_1"
        assert stabilizer_label(15) == "S_15"
        with pytest.raises(ValueError):
            stabilizer_label(0)


class TestGovernance:
    def test_tag_is_c(self) -> None:
        assert SYMPLECTIC_BRIDGE_TAG == "[C]"
        assert GOVERNANCE["tag_interpretive"] == "[C]"
        assert GOVERNANCE["claim_id"] == "BH-C-09"

    def test_not_claimed_blocks_qec_primes(self) -> None:
        nc = GOVERNANCE["not_claimed"]
        assert "QEC" in nc or "[[5,1,3]]" in nc
        assert "primes" in nc.lower() or "QEC-stabilized" in nc

    def test_build_and_export(self, tmp_path: Path) -> None:
        analysis = build_stabilizer_bridge_analysis(
            gammas=FIRST_L_CHI_MINUS3_ZEROS,
            fundamental_freq=FUNDAMENTAL_FREQ_DEFAULT,
        )
        assert analysis["governance"] == "[C]"
        assert analysis["gap_count"] == 9
        out = export_stabilizer_bridge_json(analysis, tmp_path / "out.json")
        payload = json.loads(out.read_text(encoding="utf-8"))
        assert len(payload["records"]) == 9
        assert sum(int(v) for v in payload["stabilizer_histogram"].values()) == 9
