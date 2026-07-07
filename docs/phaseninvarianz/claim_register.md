# Claim Register — Projekt Phaseninvarianz (E-094)

**Zweck:** Trennung zwischen rigoroser Algebra und physikalischer Heuristik. Jeder Claim trägt eine Evidenzklasse; Upgrades nur gemäß `EVIDENCE_REGISTER.md`.

**Stand:** 7. Juli 2026 · **ORQ:** ORQ-094

---

## Legende

| Klasse | Bedeutung |
|---|---|
| `[A]` | Formal bewiesen (Lean) oder algebraisch exakt (Sage) |
| `[B]` | Reproduzierbare numerische Diagnostik |
| `[C]` | Hypothese / Lesesprache / offene Brücke |
| `[D]` | Externe Analogie (nicht implementiert) |

---

## Algebraischer Kern

| ID | Claim | Klasse | Quelle | Status |
|---|---|---|---|---|
| PI-C-01 | \(E_a = a_x^2 + a_y^2\) invariant unter Pauli Z und X auf der \(a\)-Achse | `[A/B]` | `phaseninvarianz_pauli_energy.py`, `pauli_energy_invariance.sage` | reproduzierbar |
| PI-C-01 | \(E_{bc}\) **nicht** invariant unter partiellem Tensor-X (\(b_x \leftrightarrow c_x\)) | `[A/B]` | `phaseninvarianz_pauli_energy.py` | reproduzierbar |
| PI-C-02 | Alle 15 nichttrivialen Tensorprodukte \(P_b \otimes P_c\) auf getrennten \((b_x,b_y)\)- und \((c_x,c_y)\)-Paaren lassen \(E_{bc}=(b_x^2+b_y^2)(c_x^2+c_y^2)\) invariant | `[A/B]` | `phaseninvarianz_tensor_invariants.py`, `pauli_tensor_invariant_subspace.sage` | reproduzierbar |
| PI-C-02 | \(E_{\mathrm{pair}}=v_x^2+v_y^2\) invariant unter Pauli I, X, Y, Z (einzelnes Amplitudenpaar) | `[A/B]` | `phaseninvarianz_tensor_invariants.py` | reproduzierbar |
| PI-C-03 | Cross-Talk \(b_x \leftrightarrow c_x\) bricht \(E_{bc}\): \(\Delta E = (b_x^2-c_x^2)(c_y^2-b_y^2)\); \(\Delta E=0\) iff \(b_x=c_x\) oder \(b_y=c_y\) | `[A/B]` | `phaseninvarianz_crosstalk.py`, `crosstalk_symmetry_break.sage` | reproduzierbar |
| PI-C-03 | Nicht-null \(\Delta E\) → Verlust orthogonaler Faktorisierung / Primkopplung | `[C]` | `phaseninvarianz_crosstalk.py`, Crosstalk-Dossier | dokumentiert |
| PI-C-04 | Fermat-Differenz-von-Quadraten: \(\Delta E\) vier lineare Faktoren; bc-Achsen-Semiprimzahlen rekonstruierbar aus Amplituden | `[A/B]` Algebra, `[C]` Entartungslesung | `phaseninvarianz_fermat_factorization.py`, `fermat_factorization_via_crosstalk.sage` | reproduzierbar |

---

## Physikalische Brücke (strikt `[C]`)

| ID | Claim | Erlaubt? | Anmerkung |
|---|---|---|---|
| PI-P-01 | 6k+1-Primachse \(a\) genießt Phasen-/Bitflip-Schutz auf quadratischer Energie | Explorativ `[C]` | Algebraische Invarianz ≠ physisches QEC |
| PI-P-02 | Volle 15/15-Tensor-Invarianz von \(E_{bc}\) ersetzt `[[5,1,3]]`-Schutz | **Nein** | Kreuzfeld-Partialfehler bleiben verwundbar (PI-C-01) |
| PI-P-03 | Pauli-Tensor-Eigenzustand \(S(E)=E\) beweist QEC-Stabilisierung von Primzahlen | **Nein** | Nur algebraische Lesesprache |
| PI-P-04 | Phaseninvarianz erklärt Twin-Prime-Struktur | **Nein** | Governance-Box |
| PI-P-05 | Pauli-Operatoren = QM-Hilbertraum-Identität | **Nein** | Amplitudenpaar-Analogie, nicht Qubit |

---

## Governance

| ID | Claim | Klasse | Quelle | Status |
|---|---|---|---|---|
| PI-GOV-01 | Unterscheidung per-Paar-Tensor vs. partiellem Kreuzfeld-Tensor-X | Governance | `phaseninvarianz_pauli_energy.py`, `phaseninvarianz_tensor_invariants.py` | dokumentiert |
| PI-GOV-02 | `[B]`-Upgrade erfordert präregistriertes Fehler-Injektionsprotokoll | Governance | `phaseninvarianz_hypothese.md` | offen |

---

## Querverweise

| Dokument | Rolle |
|---|---|
| [`phaseninvarianz_hypothese.md`](../phaseninvarianz_hypothese.md) | Strategisches Dossier |
| [`phaseninvarianz_pauli_energy_bridge.md`](../theory/phaseninvarianz_pauli_energy_bridge.md) | PI-C-01 Vollprotokoll |
| [`phaseninvarianz_tensor_invariant_subspace.md`](../theory/phaseninvarianz_tensor_invariant_subspace.md) | PI-C-02 Vollprotokoll |
| [`phaseninvarianz_crosstalk_symmetry_break.md`](../theory/phaseninvarianz_crosstalk_symmetry_break.md) | PI-C-03 Cross-Talk ΔE |
| [`phaseninvarianz_fermat_factorization_bridge.md`](../theory/phaseninvarianz_fermat_factorization_bridge.md) | PI-C-04 Fermat-Brücke |
| [`eabc_energy_square_sum_substitution.md`](../theory/eabc_energy_square_sum_substitution.md) | BH-C-11 Energetische Norm |
