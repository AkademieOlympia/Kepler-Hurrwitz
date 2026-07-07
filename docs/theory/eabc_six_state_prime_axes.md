# EABC Six-State / mod-6 Prime Axes

**Status:** `[C]` interpretive Lesesprache mit `[A/B]`-Residuenfakten  
**Modul:** `src/kepler_hurwitz/eabc_six_state_prime_axes.py`  
**Geschwister:** E-093 (Black Hole), mod-12-Kanalpartition in `signatures.py`

---

## Sechs Zustände

Imaginäre Quaternionen-Basislabels `{a, b, c, ab, ac, bc}` via `n mod 6`:

| Residuum | Zustand |
|---|---|
| 0 | c |
| 1 | a |
| 2 | ac |
| 3 | ab |
| 4 | b |
| 5 | bc |

## Primachsen

Für ungerade Primzahlen `p > 3` gilt `p ≡ ±1 (mod 6)` — nur die konjugierte Dualachse **a** (6k+1) und **bc** (6k−1) trägt Primzahlen.

Lückenübergänge: `d ≡ 0 (mod 6)` → gleiche Achse; `d ≡ 2, 4 (mod 6)` → konjugierter Flip a↔bc `[C]`.

**Energetische Erweiterung:** Vektor-$a$ vs. Bivektor-$bc$ Gap-Asymmetrie (quadratisch vs. quartisch) — [`eabc_energy_square_sum_substitution.md`](eabc_energy_square_sum_substitution.md) Abschnitt „Vektor-Energie vs. Bivektor-Energie“ (BH-C-11). Analytische Konjugation via $\chi_{-3}$: [`eabc_dirichlet_chi_minus3_conjugator.md`](eabc_dirichlet_chi_minus3_conjugator.md) (BH-C-10).

---

## Riemann-Achsen-Monopol (Erweiterung)

**Dossier:** [`eabc_riemann_axis_monopole.md`](eabc_riemann_axis_monopole.md)  
**Modul:** `src/kepler_hurwitz/eabc_monopole_axis_resonance.py`  
**Sage:** `scripts/black_hole/eabc_monopole_axis_resonance.sage`  
**Export:** `docs/exports/eabc_monopole_axis_resonance.json`

## Symplektische L-Gap-Brücke (Erweiterung)

**Dossier:** [`eabc_symplectic_l_gap_bridge.md`](eabc_symplectic_l_gap_bridge.md)  
**Modul:** `src/kepler_hurwitz/eabc_symplectic_stabilizer_bridge.py`  
**Sage:** `scripts/black_hole/eabc_symplectic_stabilizer_bridge.sage`  
**Export:** `docs/exports/eabc_symplectic_stabilizer_bridge.json`  
**Claim:** BH-C-09 — \(\Delta\gamma\) von \(L(s,\chi_{-3})\) auf 15 `[[5,1,3]]`-Stabilisatoren `[C]`

## Energetische Quadratsummen-Substitution (Erweiterung)

**Dossier:** [`eabc_energy_square_sum_substitution.md`](eabc_energy_square_sum_substitution.md)  
**Modul:** `src/kepler_hurwitz/eabc_energy_square_sum.py`  
**Sage:** `scripts/black_hole/eabc_energy_square_sum.sage`  
**Export:** `docs/exports/eabc_energy_square_sum.json`  
**Claim:** BH-C-11 — Achse \(a = a_x^2 + a_y^2\) als Energiedichte-Metrik; symmetrische Behandlung von \(\{a,b,c,ab,ac,bc\}\) `[C]`

---

## Governance

| Klasse | Inhalt |
|---|---|
| `[A/B]` | mod-6-Residuentabelle, Primachsen-Zuordnung |
| `[C]` | Quaternion-Konjugation, Gap-as-Rotation, Riemann-Resonanz |

**Nicht behauptet:** Ersatz der mod-12 E/A/B/C-Partition; formale Beweise von Zwilling-/Cousin-/Sexy-Prim-Vermutungen; Identifikation mit GWTC-χ_p-Stratifizierung.
