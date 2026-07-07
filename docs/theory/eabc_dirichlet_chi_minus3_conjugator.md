# Dirichlet L(s, χ_{-3}) als EABC-Konjugator — a ↔ bc

**Status:** `[C]` Hypothese / interpretive Diagnostik  
**Register:** E-093 (Geschwister), Claim **BH-C-10**  
**Modul:** `src/kepler_hurwitz/eabc_dirichlet_chi_minus3.py`  
**Basis:** [`eabc_six_state_prime_axes.md`](eabc_six_state_prime_axes.md), [`eabc_riemann_axis_monopole.md`](eabc_riemann_axis_monopole.md)

---

## Motivation

Primzahlen $p > 3$ besetzen in der mod-6-EABC-Projektion nur die konjugierte Dualachse $(a, bc)$:

| Restklasse | EABC-Zustand | $\chi_{-3}(p)$ |
|---|---|---|
| $p \equiv 1 \pmod 6$ | **a** | $+1$ |
| $p \equiv 5 \pmod 6$ | **bc** | $-1$ |
| $3 \mid p$ | — | $0$ |

Die **Riemann-Zeta-Funktion** $\zeta(s)$ aggregiert alle Primbeiträge ohne Vorzeichenunterscheidung zwischen $6k+1$ und $6k-1$. Eine **saubere Achsentrennung** der analytischen Information erfordert daher den **Dirichlet-Konjugator** $L(s, \chi_{-3})$.

---

## Warum $\zeta(s)$ die Achsen nicht spaltet

Die ungewichtete Prim-Partialsumme (Kritische Linie, rein formal):

$$
\Psi_{\mathrm{zeta}}(\gamma) = \sum_{p} \frac{\cos(\gamma \ln p)}{\sqrt{p}}
$$

behandelt $a$- und $bc$-Primzahlen **symmetrisch** (gleiches Vorzeichen). Die Differenz $\psi_a - \psi_{bc}$ aus dem Monopol-Modul ist zwar numerisch sichtbar, aber **nicht** als natürliche Zerlegung von $\zeta$ eingebettet — sie entspricht erst der $\chi_{-3}$-Gewichtung.

---

## $L(s, \chi_{-3})$ als mathematischer Konjugator

**Definition** (quadratischer Charakter mod 3):

$$
\chi_{-3}(n) = \begin{cases}
+1 & n \equiv 1 \pmod 3 \\
-1 & n \equiv 2 \pmod 3 \\
0 & 3 \mid n
\end{cases}
$$

**Eulerprodukt:**

$$
L(s, \chi_{-3}) = \prod_p \left(1 - \frac{\chi_{-3}(p)}{p^s}\right)^{-1}
$$

**Partialsumme** (implementiert als `compute_l_chi_partial_sum`):

$$
\sum_{p \leq L} \frac{\chi_{-3}(p)}{p^s}
$$

**Resonanzvariante** auf $\mathrm{Re}(s)=\tfrac12$ (`compute_l_chi_resonance_sum`):

$$
\sum_p \chi_{-3}(p)\,\frac{\cos(\gamma \ln p)}{\sqrt{p}} = \psi_a(\gamma) - \psi_{bc}(\gamma)
$$

Die letzte Gleichheit folgt aus $\chi_{-3}(p)=+1$ auf Achse $a$ und $-1$ auf Achse $bc$.

| Lesart | Klasse |
|---|---|
| Charakterwerte auf Restklassen | `[A/B]` |
| $L(s,\chi_{-3})$ konjugiert $a \leftrightarrow bc$ | `[A/B]` Charaktertheorie |
| Quaternionen-Identifikation $a \times b = c$ | `[C]` EABC |

---

## Vergleich zeta-symmetrisch vs. L-chi-gewichtet

`compare_zeta_vs_lchi_axis_resonance(gamma, prime_limit)` liefert:

| Feld | Bedeutung |
|---|---|
| `zeta_symmetric_sum` | Ungewichtete Achsen-Pool-Summe |
| `lchi_weighted_sum` | $\chi_{-3}$-gewichtete Resonanz ($= \delta$) |
| `asymmetry_ratio` | $\|L\text{-chi}\| / \|\Psi_{\mathrm{zeta}}\|$ — Misst Achsen-Asymmetrie |
| `zeta_symmetry_score` | Balance $(\psi_a+\psi_{bc})$ vs. $|L\text{-chi}|$ |

**Governance:** Asymmetrie-Ratios sind **nicht** discovery-tauglich ohne Präregistrierung.

---

## Verknüpfung zum Monopol-Resonanztest

Das Modul [`eabc_monopole_axis_resonance.py`](../../src/kepler_hurwitz/eabc_monopole_axis_resonance.py) berechnet $\delta = \psi_a - \psi_{bc}$ ohne expliziten $\chi_{-3}$-Bezug. Dieses Dokument und `eabc_dirichlet_chi_minus3.py` **formalisieren** die im Monopol-Modul vermerkte Notwendigkeit von $L(s, \chi_{-3})$ als Konjugator.

Empfohlener Workflow:

1. Monopol-Test: explorative $\delta$-Oszillation an bekannten $\gamma_n$ (`BH-C-08`)
2. Konjugator-Test: $\chi_{-3}$-Gewichtung und zeta-vs-L-chi-Vergleich (`BH-C-10`)
3. Energetische Dualachse: Vektor-$a$ vs. Bivektor-$bc$ Gap-Asymmetrie (`BH-C-11`, [`eabc_energy_square_sum_substitution.md`](eabc_energy_square_sum_substitution.md))

---

## Artefakte

| Artefakt | Pfad |
|---|---|
| Python-Modul | `src/kepler_hurwitz/eabc_dirichlet_chi_minus3.py` |
| Sage-Cross-Check | `scripts/black_hole/eabc_dirichlet_chi_minus3.sage` |
| Tests | `tests/test_eabc_dirichlet_chi_minus3.py` |
| Monopol-Geschwister | `docs/theory/eabc_riemann_axis_monopole.md` |

---

## Claim-Grenze

| Erlaubt `[C]` | Nicht behauptet |
|---|---|
| Reproduzierbare $\chi_{-3}$-Werte und Partialsummen | Vollständige analytische Fortsetzung von $L(s,\chi_{-3})$ |
| Interpretive Konjugator-Lesesprache $a \leftrightarrow bc$ | $\zeta$ zerlegt mod 6 ohne Dirichlet-$L$ |
| Verweis auf Monopol-Resonanz als Geschwister-Test | RH-Beweis oder Monopol-Quantisierung |
