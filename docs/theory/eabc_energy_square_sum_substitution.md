---
title: EABC Energetische Quadratsummen-Substitution
date: 2026-07-07
status: "[C]"
orq_id: ORQ-093
evidence_id: E-093
claim_id: BH-C-11
claim_boundary: >-
  Achse a (und symmetrisch andere imaginäre Zustände) als Energiedichte-Metrik
  a = a_x² + a_y² lesen — nicht als fundamentalen Skalar/Vektor. Keine QM-Energie-Identität;
  Quaternionen-Multiplikation in [A]-Schicht bleibt unberührt.
not_claimed:
  - Identität der EABC-Energiedichte mit Hamilton-Operator oder QM-Eigenwerten
  - Ersatz der Quaternionen-Multiplikation a × b = c in der [A]-Schicht
  - Physikalische Einheiten oder Kalibrierung von EEG ohne Präregistrierung
  - Dass Primzahlen auf Achse a eine messbare Energiedichte tragen
ab_claims:
  - Für reelle Amplituden a_x, a_y gilt a_energy = a_x² + a_y² ≥ 0 (positive Definitheit)
  - Orthogonale Zerlegung e_i = a_x², e_j = a_y² summiert linear zu a_energy
c_claims:
  - Harmonischer-Oszillator-Analogie: zwei orthogonale Freiheitsgrade pro Achse
  - Rückkehr in Skalarraum: imaginäre Quaternionenrichtungen tragen interne energetische Struktur
  - EEG-Skalierung als explorative Gesamtenergie-Lesesprache
---

> **Evidence status:** `[C]` Paradigmenwechsel-Lesesprache · `[A/B]` für Quadratform-Definitheit  
> **Geschwister:** [`eabc_six_state_prime_axes.md`](eabc_six_state_prime_axes.md) (BH-C-07), [`eabc_dirichlet_chi_minus3_conjugator.md`](eabc_dirichlet_chi_minus3_conjugator.md) (BH-C-10)  
> **Modul:** `src/kepler_hurwitz/eabc_energy_square_sum.py`  
> **Sage:** `scripts/black_hole/eabc_energy_square_sum.sage`

# EABC Energetische Quadratsummen-Substitution

**Stand:** 7. Juli 2026  
**Register:** E-093 (Geschwister), Claim **BH-C-11**  
**Zweck:** Achse `a` (und symmetrisch `b`, `c`, `ab`, `ac`, `bc`) nicht als fundamentalen Skalar, sondern als **Energiedichte-Metrik** aus zwei orthogonalen Freiheitsgraden lesen.

---

## Paradigmenwechsel

Statt einer Achse `a` als elementarem imaginären Quaternionen-Basislabel wird die **energetische Norm** eingeführt:

$$
a_{\mathrm{energy}} = a_x^2 + a_y^2
$$

mit orthogonalen Beiträgen $e_i = a_x^2$, $e_j = a_y^2$. Die Amplituden $a_x$, $a_y$ sind interne Freiheitsgrade der Achsenrichtung — analog zu $|q|^2$ für Quaternionen $q$, bei dem sich imaginäre Anteile unter Quadrierung zu einem positiven Skalar summieren.

---

## Energetische Norm `[A/B]`

| Symbol | Definition | Klasse |
|---|---|---|
| $e_i$ | $a_x^2$ | `[A/B]` |
| $e_j$ | $a_y^2$ | `[A/B]` |
| $a_{\mathrm{energy}}$ | $e_i + e_j = a_x^2 + a_y^2$ | `[A/B]` |

Für reelle Amplituden gilt $a_{\mathrm{energy}} \geq 0$ mit Gleichheit genau dann, wenn $a_x = a_y = 0$.

---

## Drei Konsequenzen

### 1. Positive Definitheit `[A/B]`

Für Primzahlen auf Achse **a** ($p \equiv 1 \pmod 6$) ist die energetische Lesart ein **stets positiver reeller Skalar** — keine Vorzeichenambiguität in der Energiedichte selbst. (Vorzeichenasymmetrie zwischen $a$ und $bc$ bleibt Sache des Dirichlet-Konjugators $L(s,\chi_{-3})$; siehe BH-C-10.)

### 2. Rückkehr in den Skalarraum `[C]`

Quaternionenrichtungen besitzen **interne energetische Struktur**: imaginäre Teile „annihilieren" sich unter Quadrierung wie bei $|q|^2$. Die Achse ist damit kein nackter Basisvektor, sondern ein **Energiedichte-Träger** mit zwei internen Moden.

### 3. Orthogonale Entkopplung `[C]`

Die $a$-Achse entsteht aus zwei orthogonalen Freiheitsgraden ($e_i$, $e_j$) — **Harmonischer-Oszillator-Analogie**: zwei unabhängige Moden summieren ihre Energiebeiträge linear.

**Energiesuperposition:** Lineare Superposition der Quadratform; Interferenz vereinfacht sich zur Spur über quadrierte Basiselemente (keine Kreuzterme $a_x a_y$ in der Energiedichte).

---

## EEG-Skalierung

Mit explorativem Skalierungsfaktor **EEG** (EABC-Energie-Gewicht, `[C]`):

$$
E_{\mathrm{total}} = \mathrm{EEG} \cdot a_{\mathrm{energy}} = \mathrm{EEG}\,(a_x^2 + a_y^2)
$$

Entwickelt:

$$
E_{\mathrm{total}} = \mathrm{EEG}\cdot a_x^2 + \mathrm{EEG}\cdot a_y^2
$$

Implementierung: `total_energy_with_eeg`, `expanded_energy_terms` in `eabc_energy_square_sum.py`.

---

## Anbindung an Sechs-Zustands-Achsen

Die Substitution gilt **symmetrisch** für alle imaginären Basiszustände $\{a, b, c, ab, ac, bc\}$:

| Achse | Amplituden | Energiedichte |
|---|---|---|
| **a** | $a_x, a_y$ | $a_x^2 + a_y^2$ |
| **bc** | $b_x, b_y$ (konjugiert) | $b_x^2 + b_y^2$ |
| **b**, **c**, **ab**, **ac** | analog | gleiches Muster |

Primachsen-Paar $(a, bc)$ aus dem Sechs-Zustands-Dossier (BH-C-07) erhält damit eine **parallele energetische Doppelstruktur**: je zwei orthogonale Moden pro Achse, konjugiert über $\chi_{-3}$.

**Erweiterung — Vektor vs. Bivektor:** Auf der $a$-Achse bleibt die Energie **quadratisch** ($E_a = a_x^2 + a_y^2$, zwei gekoppelte Moden). Auf der konjugierten $bc$-Achse wird die Energie als **Bivektor-Produkt** gelesen: $E_b = b_x^2 + b_y^2$, $E_c = c_x^2 + c_y^2$, $E_{bc} = E_b \cdot E_c$ mit vier Kreuztermen — **quartische** Skalierung bei gleichen Amplituden. Details: Abschnitt unten und `compare_dual_axis_scaling()` in `eabc_energy_square_sum.py`.

Skizze: `symmetric_axes_energy_template()` — keine numerische Primzuordnung, nur das formale Muster `[C]`.

---

## Vektor-Energie vs. Bivektor-Energie

Die konjugierte Dualachse $(a, bc)$ aus BH-C-07 trägt nicht nur analytische Vorzeichenasymmetrie ($\chi_{-3}$, BH-C-10), sondern auch eine **energetische Lückenasymmetrie** zwischen Vektor- und Bivektor-Lesesprache `[C]`.

### $a$-Achse — Vektor-Energie (6k+1)

$$
E_a = a_x^2 + a_y^2
$$

Zwei orthogonale Freiheitsgrade, **quadratische** Skalierung. Physikalische Lesart `[C]`: fundamentale Ein-Teilchen-Moden (kein Teilchenphysik-Beweis).

### $bc$-Achse — Bivektor-Energie (6k−1)

$$
E_b = b_x^2 + b_y^2,\quad E_c = c_x^2 + c_y^2,\quad E_{bc} = E_b \cdot E_c
$$

Entwickelt in vier Kreuzterme:

$$
E_{bc} = b_x^2 c_x^2 + b_x^2 c_y^2 + b_y^2 c_x^2 + b_y^2 c_y^2
$$

Vier gekoppelte Amplituden aus der $b \times c$-Interaktion — **quartische** Skalierung. Lesart `[C]`: zusammengesetztes / verschränktes System (Meson-Analogie; nicht als Teilchenphysik-Nachweis behauptet).

### Vergleich bei gleichen Amplituden

Mit $a_x = a_y = b_x = b_y = c_x = c_y = u$:

| Größe | Wert | Skalierungsgrad |
|---|---|---|
| $E_a$ | $2u^2$ | 2 (quadratisch) |
| $E_{bc}$ | $4u^4$ | 4 (quartisch) |
| $E_{bc}/E_a$ | $2u^2$ | — |

Bei $u = 1$: $E_a = 2$, $E_{bc} = 4$, Verhältnis $= 2$. Verdopplung aller $bc$-Amplituden skaliert $E_{bc}$ mit $2^4 = 16$.

### EEG-Skalierung (dual)

$$
E_{\mathrm{total},a} = \mathrm{EEG} \cdot E_a,\qquad
E_{\mathrm{total},bc} = \mathrm{EEG} \cdot E_{bc}
$$

Implementierung: `axis_a_energy`, `axis_bc_energy`, `expanded_bc_terms`, `compare_dual_axis_scaling`, `dual_axis_totals_with_eeg`.

### Verknüpfung $\chi_{-3}$-Konjugation vs. energetische Asymmetrie

| Ebene | $a$ (6k+1) | $bc$ (6k−1) | Quelle |
|---|---|---|---|
| Analytisch | $\chi_{-3}(p) = +1$ | $\chi_{-3}(p) = -1$ | BH-C-10 |
| Energetisch | quadratisch, 2 Moden | quartisch, 4 Kreuzterme | BH-C-11 |

Die Konjugation $a \leftrightarrow bc$ im Dirichlet-Konjugator betrifft **Vorzeichen** in $L(s,\chi_{-3})$; die energetische Asymmetrie betrifft **Kopplungsordnung** (2-Faktor vs. 4-Faktor). Beide Lesarten sind komplementär `[C]`, nicht identisch.

---

## Governance

| Klasse | Inhalt |
|---|---|
| `[A/B]` | $a_{\mathrm{energy}} = a_x^2 + a_y^2 \geq 0$; lineare EEG-Skalierung; Term-Entwicklung |
| `[C]` | Harmonischer-Oszillator-Lesesprache; Skalarraum-Rückkehr; symmetrische Achsenbehandlung |

**Nicht behauptet:**

- Identität mit QM-Hamilton-Operator oder messbarer EEG-Signatur
- Ersatz der Quaternionen-Multiplikation in der `[A]`-Schicht
- Dass Primzahlen auf Achse $a$ eine kalibrierte Energiedichte tragen
- Meson-/Zusammensetzungs-Analogie auf $bc$ als Teilchenphysik-Nachweis
- Physikalische Einheiten für EEG ohne Präregistrierung

---

## Artefakte

| Artefakt | Pfad |
|---|---|
| Python-Modul | `src/kepler_hurwitz/eabc_energy_square_sum.py` |
| Sage-Symbolik (a-Achse) | `scripts/black_hole/eabc_energy_square_sum.sage` |
| Sage-Symbolik (dual a/bc) | `scripts/black_hole/eabc_dual_axis_energy_asymmetry.sage` |
| Export (Quadratsumme) | `examples/run_eabc_energy_square_sum_export.py` → `docs/exports/eabc_energy_square_sum.json` |
| Export (dual a/bc) | `examples/run_eabc_dual_axis_energy_export.py` → `docs/exports/eabc_dual_axis_energy_asymmetry.json` |
| Tests | `tests/test_eabc_energy_square_sum.py`, `tests/test_eabc_dual_axis_energy_asymmetry.py` |
| Claim | `docs/black_hole/claim_register.md` (BH-C-11) |
