# Testkonzept — Primzahlvierlinge, EABC-Masse und Dedekind-Ideal-Schicht

**Referenz:** [`docs/pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md)  
**Tests:** `tests/test_prime_quadruple_eabc.py`, `tests/test_prime_quadruple_governance_docs.py`  
**Daten:** [`docs/energiedoku_exports/pure_prime_quadruples.csv`](energiedoku_exports/pure_prime_quadruples.csv)

---

## Ziel

Die Primzahlvierlings-Schicht \(v=(p,p+2,p+6,p+8)\) wird gegen drei Ebenen geprüft:

1. **Arithmetisch** — PrimeQuadruplet, Norm, Produkt, EABC-Signatur `[B]`
2. **Dumas/Symmetrie** — Host-Komponenten, CEAB-Rotation, Norminvarianz `[A/B]`
3. **Dedekind/Ideal** — nur Interface solange \(\Phi\) offen `[C]`

---

## Governance-Prinzip

| Erlaubt | Nicht erlaubt |
|---|---|
| `is_prime_quadruplet`, `quat_norm`, `signature_from_nat` testen | `M(n(v))==2` global als Theorem |
| Witness-basierte Norm-/Produkt-Signaturen | `phi(v).is_prime_element()` ohne \(\Phi\) |
| Doku-Tests: \(\Phi\) offen, Kandidat-Sprache | Idealchiralität aus mod 12 behaupten |
| CEAB-Norminvarianz (Regression) | HoTT/Unit-Migration als Beweis |

---

## Testmatrix (Kurz)

| Bereich | Frage | Status |
|---|---|---|
| PrimeQuadruplet | Alle vier Komponenten prim? | `[B]` |
| Komponentenkanäle | E/A/B/C je einmal? | `[B]` |
| Produktmasse | \(H(P(v))=(1,1,1,1)\), \(M=4\)? | `[B]` |
| Normmasse | Referenzfall + ≠ Produktmasse | `[B]` empirisch |
| CSV-Regression | Erste Zeilen konsistent | `[B]` |
| CEAB-Norm | Invariant unter Rotation | `[A/B]` |
| \(\Phi\)-Brücke | Offen, Kandidat-Sprache | `[C]` Doku |
| Kanalvierling ≠ Primquadruplet | Abgrenzung | `[C]` Doku |

---

## Implementierte Tests

### `tests/test_prime_quadruple_eabc.py`

1. Bekannte Vierlinge `(5,7,11,13)`, `(11,13,17,19)`, `(101,103,107,109)` erkannt
2. Negative Anker `p=7,13,17` abgelehnt
3. `component_channels` deckt E/A/B/C ab
4. Produkt-Signatur: `as_tuple()` und `sorted_counts()` getrennt
5. Norm-Referenz `(5,7,11,13)` → `n=364`, `(1,0,1,0)`, `M=2`
6. `norm_mass != product_mass`
7. CSV-Regression (erste 20 Zeilen, dedupliziert)
8. CEAB-Norminvarianz via `ceab_rotate` / `ceab_orbit`

### `tests/test_prime_quadruple_governance_docs.py`

- \(\Phi\) als offene Brücke dokumentiert
- Idealpfade nur als Kandidat (`Hγ`, `γH`)
- HoTT/Univalenz nicht behauptet
- Kanalvierling ≠ Primquadruplet
- Negativsätze (Dedekind-Hasse, mod-12-Chiralität)

---

## Bewusst nicht getestet

```python
# FALSCH — globales Norm-Mass-Theorem:
assert eabc_mass(quat_norm(v)) == 2  # für alle v

# FALSCH — Φ undefiniert:
assert phi(v).is_prime_element()

# FALSCH — offene Brücke:
assert mod12_channel(v) == ideal_chirality(v)
```

---

## Repo-Funktionen

| Konzept | Modul |
|---|---|
| `is_prime_quadruplet`, `quat_norm`, `component_channels` | `kepler_hurwitz.primvierling` |
| `ceab_rotate`, `ceab_orbit` | Aliase für `symmetry_shift_ceab`, `orbit_under_ceab` |
| `signature_from_nat`, `eabc_mass` | `kepler_hurwitz.signatures` |
| Dumas Host | `kepler_hurwitz.dumas_natural_fill` (E-048, separat getestet) |
| Lean | `KeplerHurwitz/PrimvierlingSymmetry.lean` |
