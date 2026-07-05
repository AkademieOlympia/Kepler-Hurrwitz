"""Governance and interface tests for the prime quadruple Dedekind layer."""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEDEKIND_DOC = ROOT / "docs" / "pure_prime_quadruple_dedekind_interpretation.md"
TEST_CONCEPT_DOC = ROOT / "docs" / "prime_quadruple_test_concept.md"


def _dedekind_text() -> str:
    return DEDEKIND_DOC.read_text(encoding="utf-8")


def test_phi_bridge_declared_open() -> None:
    text = _dedekind_text()
    assert "Phi" in text or "Φ" in text or "\\Phi" in text
    assert "offen" in text
    assert "nicht behauptet" in text


def test_no_ideal_theorem_claimed() -> None:
    text = _dedekind_text()
    assert "Kandidat" in text
    assert "Hγ" in text or "H\\gamma" in text
    assert "γH" in text or "\\gamma H" in text
    assert "is_prime_element" not in text
    assert "is_prime_ideal" not in text


def test_hott_claims_declared_conceptual() -> None:
    text = _dedekind_text()
    assert "HoTT" in text
    assert "nicht behauptet" in text
    assert "[C]" in text


def test_channel_quadruple_not_identified_with_prime_quadruplet() -> None:
    text = _dedekind_text()
    assert "Kanalvierling" in text
    assert "Primquadruplet" in text
    assert "nicht" in text


def test_governance_negative_claims_present() -> None:
    text = _dedekind_text()
    assert "Dedekind-Hasse" in text
    assert "HoTT" in text
    assert "Kanalvierling" in text


def test_test_concept_doc_exists_and_references_layers() -> None:
    assert TEST_CONCEPT_DOC.is_file()
    text = TEST_CONCEPT_DOC.read_text(encoding="utf-8")
    assert "[B]" in text
    assert "[C]" in text
    assert "Phi" in text or "Φ" in text or "\\Phi" in text
    assert "Kanalvierling" in text
