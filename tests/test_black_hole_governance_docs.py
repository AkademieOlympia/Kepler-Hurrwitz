"""Governance tests for Projekt Black Hole (E-093)."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
HYPOTHESE = ROOT / "docs" / "black_hole_hypothese.md"
BRIDGE = ROOT / "docs" / "theory" / "black_hole_legendre_gwtc_bridge.md"
CLAIM_REGISTER = ROOT / "docs" / "black_hole" / "claim_register.md"
PREREGISTRATION = ROOT / "docs" / "black_hole" / "preregistration_gwtc5.md"


def test_hypothese_declares_c_status():
    text = HYPOTHESE.read_text(encoding="utf-8")
    assert "E-093" in text
    assert "[C]" in text
    assert "ORQ-093" in text


def test_no_gw_physics_identity_claim():
    text = BRIDGE.read_text(encoding="utf-8")
    assert "nicht behauptet" in text.lower() or "not_claimed" in text
    assert "kein EABC-Gravitationswellen-Claim" in text or "no EABC" in text.lower()


def test_kappa_sweep_governance_warning():
    text = BRIDGE.read_text(encoding="utf-8")
    assert "kappa" in text.lower() or "\\kappa" in text
    assert "Präregistrierung" in text or "preregistration" in text.lower()


def test_claim_register_separates_algebra_and_physics():
    text = CLAIM_REGISTER.read_text(encoding="utf-8")
    assert "[A/B]" in text
    assert "[C]" in text
    assert "BH-P-04" in text
    assert "Nein" in text


def test_mock_data_not_proof():
    text = CLAIM_REGISTER.read_text(encoding="utf-8")
    assert "Mock" in text
    assert "Nein" in text


def test_preregistration_gwtc5_lock():
    assert PREREGISTRATION.is_file()
    text = PREREGISTRATION.read_text(encoding="utf-8")
    assert "LOCK" in text
    assert "Bonferroni" in text
    assert "92" in text
    assert "GWTC-3" in text
    assert "GWTC-5" in text
    assert "BH-GOV-01" in CLAIM_REGISTER.read_text(encoding="utf-8")
    assert "BH-GOV-02" in CLAIM_REGISTER.read_text(encoding="utf-8")
