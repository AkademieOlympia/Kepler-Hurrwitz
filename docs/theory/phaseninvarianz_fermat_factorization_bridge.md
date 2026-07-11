# Phaseninvarianz — Fermat-Faktorisierungsbrücke via Crosstalk ΔE (E-094, PI-C-04)

**Status:** `[C]` interpretive bridge with `[A/B]` Fermat / ΔE algebra  
**Register:** E-094 · **ORQ:** ORQ-094  
**Claim:** PI-C-04  
**Code:** `src/kepler_hurwitz/phaseninvarianz_fermat_factorization.py`  
**Sage:** `scripts/phaseninvarianz/fermat_factorization_via_crosstalk.sage`  
**Sibling:** [`phaseninvarianz_crosstalk_symmetry_break.md`](phaseninvarianz_crosstalk_symmetry_break.md) (PI-C-03, ΔE definition)

---

## 1. Vier lineare Faktoren

Cross-talk-Störung (partieller bx↔cx-Tausch) auf \(E_{bc}\):

\[
\Delta E = (b_x^2 - c_x^2)(c_y^2 - b_y^2)
         = (b_x - c_x)(b_x + c_x)(c_y - b_y)(c_y + b_y).
\]

Das ist eine **Differenz von Quadraten** in jedem Paar — die klassische Fermat-Zerlegung
\(x^2 - y^2 = (x-y)(x+y)\).

**Governance `[A/B]`:** Algebraisch exakt in `phaseninvarianz_crosstalk.py` und Sage.

---

## 2. bc-Achse und Semiprimzahlen

Aus `eabc_six_state_prime_axes.py`: ungerade Primzahlen \(p>3\) liegen auf \(\{a, bc\}\);
\(n \equiv 5 \pmod 6\) markiert die **bc-Bivektor-Achse**.

Zusammengesetztes \(n\) auf der bc-Achse (z. B. \(n=35\), \(n=143\)) bricht die orthogonale
Faktorisierung von \(E_{bc}\); nichtverschwindendes \(\Delta E\) kodiert die Primfaktoren
in der Lesesprache `[C]`.

---

## 3. Walkthrough \(n = 35 = 5 \times 7\)

**Schritt 1:** \(35 \bmod 6 = 5\) → bc-Achse.

**Schritt 2:** Fermat-Einheitszerlegung pro ungeradem Faktor \(f\):
\[
f = (b_x - c_x)(b_x + c_x),\quad b_x - c_x = 1
\Rightarrow b_x = \frac{f+1}{2},\; c_x = \frac{f-1}{2}.
\]

Für \(f_1 = 5\): \(b_x=3,\; c_x=2 \Rightarrow b_x^2 - c_x^2 = 9-4 = 5\).

Für \(f_2 = 7\): \(c_y=4,\; b_y=3 \Rightarrow c_y^2 - b_y^2 = 16-9 = 7\).

**Schritt 3:** \(\Delta E = 5 \times 7 = 35\).

`find_amplitudes_for_factors(35)` liefert dieselben Amplituden und verifiziert das Produkt.

---

## 4. Walkthrough \(n = 143 = 11 \times 13\)

\(143 = 6 \times 24 - 1 \equiv 5 \pmod 6\).

| Faktor | Amplituden | Quadrat-Differenz |
|---|---|---|
| 11 | \(b_x=6,\; c_x=5\) | \(36-25=11\) |
| 13 | \(c_y=7,\; b_y=6\) | \(49-36=13\) |

\(\Delta E = 11 \times 13 = 143\).

---

## 5. Link zur Fermat-Methode

Klassisch sucht Fermat \(n = a^2 - b^2\). Hier ist jeder Faktor \(f\) selbst als
\(f = \bigl(\frac{f+1}{2}\bigr)^2 - \bigl(\frac{f-1}{2}\bigr)^2\) geschrieben (Einheits-Split).
Das Produkt zweier solcher Splits in den gekreuzten \(b/c\)-Kanälen reproduziert
\(n = f_1 \cdot f_2\) als \(\Delta E\).

**Nicht behauptet:** Dies ersetzt keinen allgemeinen Faktorisierungsalgorithmus; es ist ein
**konstruktives Beispiel** der Crosstalk-Geometrie auf bc-Achsen-Semiprimzahlen.

---

## 6. Governance

| Claim | Klasse |
|---|---|
| \(\Delta E = (b_x^2-c_x^2)(c_y^2-b_y^2)\) vierfach linear | `[A/B]` |
| Fermat-Differenz-von-Quadraten pro Faktor | `[A/B]` |
| Faktorisierung = Entartung verschränkter Bivektor-Primzustand | `[C]` |
| Allgemeine Primfaktorzerlegung aus \(\Delta E\) | **Nein** |

---

## 7. Artefakte

| Artefakt | Pfad |
|---|---|
| Modul | `src/kepler_hurwitz/phaseninvarianz_fermat_factorization.py` |
| Sage | `scripts/phaseninvarianz/fermat_factorization_via_crosstalk.sage` |
| Tests | `tests/test_phaseninvarianz_fermat_factorization.py` |
| Claim-Register | [`../phaseninvarianz/claim_register.md`](../phaseninvarianz/claim_register.md) PI-C-04 |
