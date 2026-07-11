"""Governance tests for Projekt Phaseninvarianz (E-094)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HYPOTHESE = ROOT / "docs" / "phaseninvarianz_hypothese.md"
BRIDGE = ROOT / "docs" / "theory" / "phaseninvarianz_pauli_energy_bridge.md"
CLAIM_REGISTER = ROOT / "docs" / "phaseninvarianz" / "claim_register.md"


def test_hypothese_declares_c_status():
    text = HYPOTHESE.read_text(encoding="utf-8")
    assert "E-094" in text
    assert "[C]" in text
    assert "ORQ-094" in text


def test_no_qm_identity_claim():
    text = BRIDGE.read_text(encoding="utf-8")
    assert "not_claimed" in text or "nicht behauptet" in text.lower()
    assert "QM" in text or "Hilbert" in text


def test_qec_protection_governance():
    text = BRIDGE.read_text(encoding="utf-8")
    assert "QEC" in text or "[[5,1,3]]" in text
    assert "E-044" in text or "qec_bridge" in text


def test_claim_register_separates_ab_and_c():
    text = CLAIM_REGISTER.read_text(encoding="utf-8")
    assert "[A/B]" in text
    assert "[C]" in text
    assert "PI-C-01" in text
    assert "PI-C-02" in text
    assert "PI-C-03" in text
    assert "PI-P" in text or "Nein" in text


def test_crosstalk_dossier_exists():
    crosstalk = ROOT / "docs" / "theory" / "phaseninvarianz_crosstalk_symmetry_break.md"
    assert crosstalk.exists()
    text = crosstalk.read_text(encoding="utf-8")
    assert "15" in text
    assert "Cross-Talk" in text or "cross-talk" in text.lower()


def test_cross_links_to_black_hole_energy():
    text = HYPOTHESE.read_text(encoding="utf-8")
    assert "BH-C-11" in text or "eabc_energy_square_sum" in text
    assert "BH-C-09" in text or "symplectic" in text.lower()
