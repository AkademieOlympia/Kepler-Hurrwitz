# Projekt „Phaseninvarianz“

Strategisches Ziel: Prüfen, ob **Pauli-Phasenoperatoren** auf quadratischen/quartischen **EABC-Energietermen** einen **Schutzmechanismus** für die Primachse \(a\) (6k+1) offenlegen — und ob der **Bivektor-Kanal** \(bc\) durch partielle Tensorfehler **verwundbar** ist und volle QEC-Grammatik erfordert.

Evidenzstatus zum Anlegen: `[C]` (offene Hypothese) mit `[A/B]`-Invarianzfakten; Upgrade zu `[B]` erst nach präregistriertem Fehler-Injektionsprotokoll über Nullmodelle hinaus.

**Register:** E-094 · **ORQ:** ORQ-094 · **Dossier:** [`theory/phaseninvarianz_pauli_energy_bridge.md`](theory/phaseninvarianz_pauli_energy_bridge.md), [`theory/phaseninvarianz_crosstalk_symmetry_break.md`](theory/phaseninvarianz_crosstalk_symmetry_break.md), [`theory/phaseninvarianz_fermat_factorization_bridge.md`](theory/phaseninvarianz_fermat_factorization_bridge.md) · **Claim-Register:** [`phaseninvarianz/claim_register.md`](phaseninvarianz/claim_register.md)

---

## 1. Kernzerlegung

| Kanal | Energie | Pauli-Test | Ergebnis |
|---|---|---|---|
| **a-Achse (Vektor)** | \(E_a = a_x^2 + a_y^2\) | Z: \(a_x \to -a_x\) | **invariant** `[A/B]` |
| **a-Achse** | \(E_a\) | X: \(a_x \leftrightarrow a_y\) | **invariant** `[A/B]` |
| **bc-Achse (Bivektor)** | \(E_{bc} = (b_x^2+b_y^2)(c_x^2+c_y^2)\) | Cross-Talk: \(b_x \leftrightarrow c_x\) | **bricht** \(\Delta E=(b_x^2-c_x^2)(c_y^2-b_y^2)\) `[A/B]` |
| **bc-Achse (Bivektor)** | \(E_{bc}\) | 15 Tensorprodukte \(P_b \otimes P_c\) auf getrennten Paaren | **alle 15 invariant** `[A/B]` |
| **bc-Schutz** | Quartische Kreuzterme | Volle `[[5,1,3]]`-QEC | Lesesprache `[C]` |
| **bc-Crosstalk** | \(\Delta E = (b_x^2-c_x^2)(c_y^2-b_y^2)\) | Fermat-Brücke auf bc-Achse | PI-C-03/04 `[A/B]`/`[C]` |

**Analogie `[C]`:** Die 6k+1-Primachse \(a\) trägt **Phaseninvarianz** wie ein geschützter logischer Qubit; der konjugierte Bivektor \(bc\) benötigt **vollständige Fehlerkorrektur** (E-044, BH-C-09).

---

## 2. Testprotokoll

Für jede Amplitudenkonfiguration \((a_x, a_y, b_x, b_y, c_x, c_y)\):

1. Berechne \(E_a\), \(E_{bc}\) und expandierte Kreuzterme.
2. Wende Pauli Z und X auf die \(a\)-Amplituden an; prüfe \(E_a\)-Invarianz.
3. Wende Cross-Talk-Fehler \(b_x \leftrightarrow c_x\) an; dokumentiere \(\Delta E = (b_x^2-c_x^2)(c_y^2-b_y^2)\) und Kreuzterm-Umstrukturierung.
4. Wende alle 15 nichttrivialen Tensorprodukte \(P_b \otimes P_c\) auf getrennte \((b_x,b_y)\)- und \((c_x,c_y)\)-Paare an; zähle `invariant_count` (erwartet 15/15).
5. Markiere symmetrische Spezialfälle (\(b_x = c_x\) oder \(b_y = c_y\)).
6. **Nullmodell (Pflicht für `[B]`-Upgrade):** Zufällige Amplituden-Shuffles, Kanal-Permutation, Varianz-Match.

**Urteil:** Phaseninvarianz auf \(a\) ist **algebraisch reproduzierbar**; QEC-Schutz-Claim für Primzahlen nur bei explizitem Fehler-Injektionsprotokoll über Shuffle hinaus.

---

## 3. Implementierung

| Artefakt | Pfad |
|---|---|
| Diagnostik-Modul | `src/kepler_hurwitz/phaseninvarianz_pauli_energy.py` |
| Tensor-Invarianten-Modul | `src/kepler_hurwitz/phaseninvarianz_tensor_invariants.py` |
| Cross-Talk-Modul | `src/kepler_hurwitz/phaseninvarianz_crosstalk.py` |
| Fermat-Faktorisierung | `src/kepler_hurwitz/phaseninvarianz_fermat_factorization.py` |
| Export-Skript | `examples/run_phaseninvarianz_export.py` |
| Tensor-Export | `examples/run_phaseninvarianz_tensor_invariants_export.py` |
| Tests | `tests/test_phaseninvarianz_pauli_energy.py`, `tests/test_phaseninvarianz_tensor_invariants.py`, `tests/test_phaseninvarianz_crosstalk.py`, `tests/test_phaseninvarianz_fermat_factorization.py`, `tests/test_phaseninvarianz_governance_docs.py` |
| Sage — symbolische Invarianz | `scripts/phaseninvarianz/pauli_energy_invariance.sage` |
| Sage — 15 Tensoroperatoren | `scripts/phaseninvarianz/pauli_tensor_invariant_subspace.sage` |
| Sage — Cross-Talk Faktorisierung | `scripts/phaseninvarianz/crosstalk_symmetry_break.sage` |
| Sage — Fermat-Brücke | `scripts/phaseninvarianz/fermat_factorization_via_crosstalk.sage` |
| Lean-Interface `[C]` | `KeplerHurwitz/PhaseninvarianzInterface.lean` |
| Lean `[A]` Energie | `KeplerHurwitz/PhaseninvarianzEnergy.lean` |
| Lean `[A]` Crosstalk | `KeplerHurwitz/PhaseninvarianzCrosstalk.lean` |
| Lean `[A]` mod-6 | `KeplerHurwitz/EabcSixStateMod6.lean` |
| Export-Ziel | `docs/exports/phaseninvarianz_pauli_energy.json`, `docs/exports/phaseninvarianz_tensor_invariants.json` |

```bash
PYTHONPATH=src python examples/run_phaseninvarianz_export.py
PYTHONPATH=src python examples/run_phaseninvarianz_tensor_invariants_export.py
pytest tests/test_phaseninvarianz_pauli_energy.py tests/test_phaseninvarianz_tensor_invariants.py tests/test_phaseninvarianz_crosstalk.py tests/test_phaseninvarianz_fermat_factorization.py tests/test_phaseninvarianz_governance_docs.py -q
# Sage (optional):
sage scripts/phaseninvarianz/pauli_energy_invariance.sage
sage scripts/phaseninvarianz/pauli_tensor_invariant_subspace.sage
sage scripts/phaseninvarianz/crosstalk_symmetry_break.sage
sage scripts/phaseninvarianz/fermat_factorization_via_crosstalk.sage
```

---

## 4. Governance (verbindlich)

| Claim | Erlaubt? |
|---|---|
| \(E_a\) invariant unter Pauli Z/X | Ja — `[A/B]` |
| \(E_{bc}\) verwundbar unter Cross-Talk (bx↔cx) | Ja — `[A/B]` |
| Alle 15 lokalen \(P_b \otimes P_c\) invariant auf \(E_{bc}\) | Ja — `[A/B]` |
| \(\Delta E \neq 0\) → Primkopplungsverlust | Nur `[C]`-Lesesprache |
| Alle 15 per-Paar-Tensorprodukte lassen \(E_{bc}\) invariant | Ja — `[A/B]` |
| Primzahlen auf Achse \(a\) sind QEC-geschützt | **Nein** — nur `[C]`-Lesesprache |
| Pauli-Operatoren = QM-Hilbertraum-Identität | **Nein** |
| Phaseninvarianz erklärt Twin-Prime-Struktur | **Nein** |

\[
\boxed{
\text{Phaseninvarianz testet } E_a \leftrightarrow \text{Pauli Z/X}\text{ und } E_{bc} \leftrightarrow \text{Tensor-X-Fehler, nicht EABC = QEC.}
}
\]

---

## 5. Lean-Kern `[A]`

Die Module `PhaseninvarianzEnergy.lean`, `PhaseninvarianzCrosstalk.lean` und `EabcSixStateMod6.lean` formalisieren ausschließlich algebraische Fakten ohne QEC- oder Physik-Lesesprache. `PhaseninvarianzEnergy` liefert `axisAEnergy`/`axisBCEnergy`/`pairEnergy` mit Nichtnegativität (`axisAEnergy_nonneg`, `axisBCEnergy_nonneg`, `pairEnergy_nonneg`) und Pauli-Z/X/Y-Invarianz (`axisAEnergy_pauliZ_x`, `axisAEnergy_pauliZ_y`, `axisAEnergy_pauliX`, `pairEnergy_pauliZ_x`, `pairEnergy_pauliZ_y`, `pairEnergy_pauliX`, `pairEnergy_pauliY`). `PhaseninvarianzCrosstalk` formalisiert `crosstalkDelta` mit Vier-Term-Expansion (`crosstalkDelta_eq_expanded`), Fermat-Faktorisierung (`sq_sub_sq_bx_cx`, `crosstalkDelta_fermat_factorization`) und Nullfaellen (`crosstalkDelta_eq_zero_of_bx_eq_cx`, `crosstalkDelta_eq_zero_of_b_y_eq_cy`). `EabcSixStateMod6` definiert `IsPrimeAxisA`/`IsPrimeAxisBC` und beweist `prime_gt_three_mod_six` für Primzahlen `p > 3`. Alle drei sind über `KeplerHurwitz/Core.lean` eingebunden; das ältere `PhaseninvarianzInterface.lean` bleibt als abstraktes `[C]`-Skelett erhalten.

---

## 6. Querverweise

| Dokument | Rolle |
|---|---|
| [`phaseninvarianz_pauli_energy_bridge.md`](theory/phaseninvarianz_pauli_energy_bridge.md) | Vollprotokoll PI-C-01 |
| [`phaseninvarianz_tensor_invariant_subspace.md`](theory/phaseninvarianz_tensor_invariant_subspace.md) | Vollprotokoll PI-C-02 |
| [`phaseninvarianz_crosstalk_symmetry_break.md`](theory/phaseninvarianz_crosstalk_symmetry_break.md) | Cross-Talk ΔE PI-C-03 |
| [`phaseninvarianz_fermat_factorization_bridge.md`](theory/phaseninvarianz_fermat_factorization_bridge.md) | Fermat-Brücke PI-C-04 |
| [`phaseninvarianz/claim_register.md`](phaseninvarianz/claim_register.md) | Claim-Governance PI-C-01.. |
| [`eabc_energy_square_sum_substitution.md`](theory/eabc_energy_square_sum_substitution.md) | Energetische Norm BH-C-11 |
| [`eabc_symplectic_l_gap_bridge.md`](theory/eabc_symplectic_l_gap_bridge.md) | `[[5,1,3]]`-Stabilisator BH-C-09 |
| [`eabc_six_state_prime_axes.md`](theory/eabc_six_state_prime_axes.md) | mod-6-Primachsen BH-C-07 |
| [`open_research_questions.md`](open_research_questions.md) | ORQ-094 |
| `qec_bridge.py` (E-044) | Five-qubit QEC-Grammatik |
