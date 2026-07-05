# Testkonzept — Primzahlvierlinge, EABC-Masse und Dedekind-Ideal-Schicht

**Evidenz:** `[B]`/`[C]` — arithmetische Lesart definitorisch/getestet; idealtheoretische Brücke offen  
**Register:** E-046/E-048 (Primvierling/Dumas), E-053 (Dedekind–Hasse), E-067–E-069 (Dedekind-Ideal-Schicht), E-072 (mod-12-Kanalpartition), E-073 (HoTT Identity Layer)  
**Referenz:** [`docs/pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md)  
**Daten:** [`docs/energiedoku_exports/pure_prime_quadruples.csv`](energiedoku_exports/pure_prime_quadruples.csv)  
**Konvention:** [`docs/eabc_mass_convention.md`](eabc_mass_convention.md)  
**Tests:** `tests/test_prime_quadruple_eabc.py`, `tests/test_prime_quadruple_governance_docs.py`

---

## Ziel

Die Primzahlvierlings-Schicht

\[
v=(p,p+2,p+6,p+8),\qquad p>3,
\]

soll systematisch auf drei Ebenen getestet werden:

1. **arithmetisch:** PrimeQuadruplet, Norm, Produkt, EABC-Signatur;
2. **symmetrisch:** Dumas-Host, Host-Dreier, CEAB-/Rotor-Invarianz;
3. **idealtheoretisch:** nur als Interface- und Governance-Schicht, solange die Brücke

\[
\Phi : \text{EABC / Primvierling}
\longrightarrow
\text{Quaternionenordnung / Idealpfade}
\]

offen ist.

Die Tests dürfen arithmetische und endliche Strukturbehauptungen absichern. Sie dürfen aber **nicht** aus einem Primvierling automatisch ein Primelement, Primideal oder HoTT-Pfadobjekt in einer konkreten Quaternionenordnung machen.

---

## 1. Testmatrix

| Testbereich | Frage | Erwartung | Status |
|---|---|---|---|
| PrimeQuadruplet | Ist \(v=(p,p+2,p+6,p+8)\) vollständig prim? | alle vier Komponenten prim | `[B]` testbar |
| Distinktheit | Sind alle Komponenten verschieden? | ja für \(p>3\) | `[A]`/`[B]` |
| Komponentenkanäle | Decken die vier Primzahlen E/A/B/C ab? | exakt einmal je Kanal | `[B]` testbar |
| Produktmasse | Gilt \(H(P(v))=(1,1,1,1)\)? | ja für echte Vierlinge \(p>3\) | `[B]` **strukturell invariant** |
| Normmasse | Wie verhält sich \(M(n(v))\)? | Referenz-/Empiriegröße, **kein Axiom** | `[B]` empirisch |
| Dumas-Host | Ist jeder Host-Dreier das Komplement einer Komponente? | ja | `[A]`/`[B]` |
| CEAB-/Rotor | Bleibt die Norm unter Rotation invariant? | ja | `[A]`/`[B]` |
| Idealpfad | Erzeugt \(\Phi(v)=\gamma\) Links-/Rechtsidealkandidaten? | nur falls \(\Phi\) existiert | `[C]` |
| Chiralität | Erklärt Kanalstruktur Idealchiralität? | offen | `[C]` |
| HoTT-Unit-Migration | Sind Unit-Pfade formal bewiesen? | nein, nur Interface | `[C]` |

**Schärfung Produkt vs. Norm:**

- \(M(P(v))=4\) ist für echte Primvierlinge \(p>3\) **strukturell invariant**: die vier Komponenten belegen modulo 12 genau die Restklassen \(\{1,5,7,11\}\) (E-072), daher volle Kanalabdeckung im Produkt.
- \(M(n(v))\) hängt von der Faktorisierung von \(n(v)=a^2+b^2+c^2+e^2\) ab; Referenzfall und CSV-Empirie, **kein globales Axiom**.

---

## 2. Arithmetische Basistests

**Datei:** `tests/test_prime_quadruple_eabc.py`

### 2.1 Positive PrimeQuadruplet-Witnesses

Referenzfälle: `(5, 7, 11, 13)`, `(11, 13, 17, 19)`, `(101, 103, 107, 109)`.

Erwartung: `is_prime_quadruplet(v) == True`

### 2.2 Negative Fälle

`p ∈ {7, 13, 17}` → `build_prime_quadruplet(p)` wird abgelehnt (nicht alle Komponenten prim).

---

## 3. Komponentenkanal-Tests

Für echte Vierlinge \(v=(p,p+2,p+6,p+8)\) mit \(p>3\) decken die vier Komponenten die EABC-Kanäle **exakt einmal** ab.

Beispiel \(v=(5,7,11,13)\): mod 12 → A, B, C, E; `set(component_channels(v)) == {"E","A","B","C"}`.

**Abgrenzung p-only-Schicht:** p-only: ein Kanal, \(M(p)=1\); Vierling: volle Kanalabdeckung im Produkt.

---

## 4. Produkt-Signaturtest (strukturell invariant)

Für \(P(v)=a\cdot b\cdot c\cdot e\) und alle echten Primvierlinge \(p>3\):

\[
H(P(v))=(1,1,1,1),\qquad M(P(v))=4.
\]

**Struktureller Begründungssatz.** Sei \(v=(p,p+2,p+6,p+8)\) mit \(p>3\) und alle vier Komponenten prim.

1. **Startprimzahl:** \(p \equiv 5\) oder \(p \equiv 11 \pmod{12}\) — denn \(p \equiv 1 \pmod{12}\) würde \(p+2 \equiv 3\) (teilbar durch 3), \(p \equiv 7 \pmod{12}\) würde \(p+8 \equiv 3\).
2. **Zyklen:** Die vier Restklassen \(\{1,5,7,11\}\) erscheinen in genau einer der beiden zyklischen Anordnungen \((5,7,11,1)\) oder \((11,1,5,7)\) auf den Komponenten \(p, p+2, p+6, p+8\).
3. **Produkt:** Da jede Primkomponente genau einen EABC-Kanal trägt, trifft \(P(v)\) jeden Kanal genau einmal — also \(H(P(v))=(1,1,1,1)\) und \(M(P(v))=4\).
4. **Test:** `[B]`-regressionstauglicher Strukturcheck via `test_prime_quadruple_product_mass_four_is_structural_invariant`.

Für echte Primvierlinge \(p>3\) ist \(M(P(v))=4\) ein struktureller Test: Die vier Komponenten durchlaufen modulo 12 einen der Zyklen \((5,7,11,1)\) oder \((11,1,5,7)\); die volle Kanalabdeckung betrifft das **Komponentenprodukt** \(P(v)\), nicht die Quaternionennorm \(n(v)\).

Implementiert als `test_prime_quadruple_product_mass_four_is_structural_invariant`, parametrisiert über `STRUCTURAL_INVARIANT_WITNESSES` (bekannte Fälle, generierte Vierlinge, CSV-Zeilen).

`as_tuple()`: kanonische E/A/B/C-Signatur; `sorted_counts()`: Partitionsform — beide getrennt prüfen.

---

## 5. Norm-Signaturtest (Referenz, kein globales Axiom)

\(n(v)=a^2+b^2+c^2+e^2\). Referenzfall \(v=(5,7,11,13)\): \(n(v)=364=2^2\cdot7\cdot13\), \(H(364)=(1,0,1,0)\), \(M(364)=2\).

**Wichtig:** Referenztest, kein globaler Satz. \(M(n(v))\) kann 2, 3, 4, … sein — siehe CSV-Empirie-Test.

\(M(n(v))=2\) für \((5,7,11,13)\) ist Referenzfall, kein Invariantensatz über alle Primvierlinge; die Normsignatur hängt faktorisatorisch von \(n(v)\) ab und darf **nicht** als globale Eigenschaft behauptet werden.

Struktureller Kontrast (nur Referenzfall): Normsignatur \(\neq\) Produktsignatur, \(M(n(v))=2 \neq M(P(v))=4\).

---

## 6. CSV-Regressionstests

**Datenquelle:** `docs/energiedoku_exports/pure_prime_quadruples.csv`

Minimaltests: CSV existiert; erste Zeilen sind echte Vierlinge; \(b=a+2\), \(c=a+6\), \(e=a+8\); mod-12 \(\{1,5,7,11\}\); Produkt \(M=4\); Normsignatur berechnet und mit CSV abgeglichen — **nicht** als globaler Invariantensatz überdeutet.

---

## 7. Dumas-/Host-Tests

**Lean:** `KeplerHurwitz/PrimvierlingSymmetry.lean`  
**Register:** E-048 — Host-Dreier = Komplement der Host-Komponente

Für \(v=(a,b,c,e)\): `host_triple(host, v)` = `P(v) \ {host_component(host, v)}`; `verify_dumas_lemma(v)` auf Referenz-Vierlingen.

---

## 8. CEAB-/Norminvarianztest

Lean-Referenz: `dedekindHasse_quatNorm_CEAB_invariant`

`quat_norm(v) == quat_norm(ceab_rotate(v))` — Governance: Norminvarianz ist **kein** Idealtheorie-Beweis.

---

## 9. Dedekind-Ideal-Interface-Tests

**Datei:** `tests/test_prime_quadruple_governance_docs.py`

Nicht testen: `assert is_prime_ideal(phi(v))` solange \(\Phi\) undefiniert.

Doku muss enthalten: \(\Phi\) offen; Primquadruplet \(\Rightarrow\) Primelement **nicht** behauptet; Dedekind-Hasse erklärt EABC-Masse **nicht**.

---

## 10. Governance-Tests

Negativsätze in der Dedekind-Doku:

- Dedekind-Hasse erklärt **nicht** die EABC-Masse.
- mod-12-Kanal erklärt **nicht bewiesen** die Idealchiralität.
- HoTT/Univalenz/HITs sind **nicht** formal bewiesen.
- Kanalvierling \(\neq\) Primquadruplet.

Evidence-Trennung: `[B]` für arithmetische Tests; `[C]` für \(\Phi\), Chiralität, HoTT.

---

## 11. Empfohlene Testdateien

### `tests/test_prime_quadruple_eabc.py`

1. `test_known_prime_quadruplets_are_detected`
2. `test_non_quadruplets_are_rejected`
3. `test_quadruple_components_cover_all_eabc_channels`
4. `test_prime_quadruple_product_mass_four_is_structural_invariant`
5. `test_quadruple_product_signature_full_coverage`
6. `test_quadruple_norm_signature_reference_case`
7. `test_norm_mass_differs_from_product_mass_reference_case`
8. `test_prime_quadruple_norm_mass_empirical_distribution_from_csv`
9. `test_pure_prime_quadruples_csv_first_rows`
10. `test_dumas_host_triple_is_component_complement`
11. `test_verify_dumas_lemma_on_prime_quadruplets`
12. `test_ceab_rotation_preserves_quat_norm`

### `tests/test_prime_quadruple_governance_docs.py`

Governance-Negativsätze und Verweis auf dieses Testkonzept.

---

## 12. Bewusst nicht testen

```python
# FALSCH — globales Norm-Mass-Theorem (faktorisatorisch variabel):
assert eabc_mass(quat_norm(v)) == 2  # für alle Vierlinge

# FALSCH — Φ undefiniert:
assert phi(v).is_prime_element()

# FALSCH — offene Brücke:
assert mod12_channel(v) == ideal_chirality(v)

# FALSCH — E-073 nur konzeptionell:
assert hott_unit_path(v)
```

---

## 13. Praktische Repo-Folge

```
Primzahlvierling
    ↓
arithmetisch testbar:
PrimeQuadruplet, Norm (Referenz/Empirie), Produkt, EABC-Signatur
    ↓
symmetrisch testbar:
Dumas-Host, CEAB-Rotation, Norminvarianz
    ↓
idealtheoretisch nur als Interface:
Φ, Links-/Rechtsidealpfade, Chiralität, Unit-Migration
```

**Kern:**

- \(v=(p,p+2,p+6,p+8)\) ist ein voller Vierachsen-Primzeugen-Witness.
- \(M(P(v))=4\) testet die **vollständige mod-12-Kanalabdeckung** — strukturell invariant für \(p>3\).
- \(M(n(v))\) testet die Normsignatur ohne globale Überhöhung; Normsignatur \(\neq\) Produktsignatur.

Die Dedekind-Idealtheorie beginnt erst bei \(\Phi(v)=\gamma\) in einer konkreten Quaternionenordnung. Vorher bleibt sie eine kontrollierte `[C]`-Brücke.

**Methodischer Satz:**

\[
M(P(v))=4 \;\text{ist starker arithmetischer Vollabdeckungs-Test;}\quad
\Phi(v)=\gamma \;\text{ist die offene Brücke zur dedekindschen Idealtheorie.}
\]

> **Governance-Kern**
>
> - \(M(P(v))=4\) ist arithmetisch strukturell testbar (`[B]`).
> - \(\Phi(v)=\gamma\) bleibt offene dedekindsche Brücke (`[C]`).
> - \(M(n(v))\) bleibt empirisch/referenzbasiert, kein Axiom.
