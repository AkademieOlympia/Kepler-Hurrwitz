# Claim Register — Projekt Black Hole (E-093)

**Zweck:** Trennung zwischen rigoroser Algebra und physikalischer Heuristik. Jeder Claim trägt eine Evidenzklasse; Upgrades nur gemäß `EVIDENCE_REGISTER.md`.

**Stand:** 7. Juli 2026 · **ORQ:** ORQ-093

---

## Legende

| Klasse | Bedeutung |
|---|---|
| `[A]` | Formal bewiesen (Lean) oder algebraisch exakt (Sage) |
| `[B]` | Reproduzierbare numerische Diagnostik |
| `[C]` | Hypothese / Lesesprache / offene Brücke |
| `[D]` | Externe Analogie (nicht implementiert) |
| `L4` | Strukturelle Inspiration ohne Identifikation |

---

## Algebraischer Kern

| ID | Claim | Klasse | Quelle | Status |
|---|---|---|---|---|
| BH-C-01 | \(n = 4^a(8b+7)\) blockiert Drei-Quadrate-Darstellbarkeit | `[A/B]` | `legendre_mass_gaps.sage`, `black_hole_legendre_gwtc.py` | reproduzierbar |
| BH-C-02 | Verbotene \(s^2\) induzieren verbotene Massenschalen \(m\) über \(p = m^2 + s^2\) | `[B]` | `get_forbidden_mass_integers` | reproduzierbar |
| BH-C-03 | Nicht-kommutative 2G-Verschmelzung als Antwort auf BH-C-01 | `[C]` | `eabc_merger.sage` | dokumentiert |
| BH-C-04 | Hamilton-Regel \(a \times b = c\) ↔ [[5,1,3]]-Antikommutator | `[C]` | `five_qubit_bridge.sage` | dokumentiert |
| BH-C-05 | Stabilisator-Phasen ↔ GUE-Nullstellen-Statistik | `[C]` | `monopole_gap_test.sage` | dokumentiert |
| BH-C-06 | Split-Normal MC \(P_{\mathrm{gap}}\) aus GWOSC-Massenunsicherheit; Permutation über \(\sum P_{\mathrm{gap}}\) | `[C]` | `black_hole_legendre_gwtc.py`, `monte_carlo_pgap.sage` | reproduzierbar |
| BH-C-07 | Sechs-Zustands-Primachsen mod 6: $(a, bc)$-Paar, Gap-Rotation Twin/Cousin/Sexy | `[C]` | `eabc_six_state_prime_axes.py`, `eabc_prime_six_state.sage` | dokumentiert |
| BH-C-08 | Riemann-Nullstellen-Resonanz a vs. bc: \(\delta=\psi_a-\psi_{bc}\), Delta-Oszillation als Monopol-Lesesprache | `[C]` | `eabc_monopole_axis_resonance.py`, `eabc_monopole_axis_resonance.sage` | dokumentiert |
| BH-C-09 | L\((s,\chi_{-3})\)-Gap \(\Delta\gamma\) → symplektische GF\((2)^4\setminus\{0\}\)-Stabilisatoren des `[[5,1,3]]`-Codes | `[C]` | `eabc_symplectic_stabilizer_bridge.py`, `eabc_symplectic_stabilizer_bridge.sage` | dokumentiert |
| BH-C-10 | Dirichlet \(L(s,\chi_{-3})\) als Konjugator \(a \leftrightarrow bc\); zeta-symmetrisch vs. L-chi-Asymmetrie | `[C]` | `eabc_dirichlet_chi_minus3.py`, `eabc_dirichlet_chi_minus3.sage` | dokumentiert |
| BH-C-11 | Energetische Quadratsummen-Substitution; Vektor-\(a\) vs. Bivektor-\(bc\) Gap-Asymmetrie (quadratisch vs. quartisch) | `[C]` | `eabc_energy_square_sum.py`, `eabc_dual_axis_energy_asymmetry.sage` | dokumentiert |
| BH-C-11 | Energetische Quadratsumme \(a = a_x^2 + a_y^2\); EEG-Skalierung; symmetrische Achsen-Template \(\{a,b,c,ab,ac,bc\}\) | `[C]` | `eabc_energy_square_sum.py`, `eabc_energy_square_sum.sage` | dokumentiert |

---

## Physikalische Brücke (strikt `[C]` bis ORQ-093 erfüllt)

| ID | Claim | Erlaubt? | Anmerkung |
|---|---|---|---|
| BH-P-01 | \(\kappa\) mappt \(M_\odot\) auf fundamentale EABC-Normen | Explorativ `[C]` | Sweep nicht discovery-tauglich ohne Präregistrierung |
| BH-P-02 | 1G (\(\chi_p < 0{,}2\)) meidet Legendre-Lücken | Testbar `[B]`-Ziel | Fisher-Test auf echtem GWTC |
| BH-P-03 | 2G-Merger bevorzugen verbotene Zonen | Testbar `[B]`-Ziel | gleiche Kontingenztafel |
| BH-P-04 | EABC erklärt Gravitationswellen-Spektrum | **Nein** | Governance-Box |
| BH-P-05 | Legendre-Lücken = Planck-skalierte Raumzeit-Quantisierung | **Nein** | L4 nur als Lesefrage |
| BH-P-06 | Mock-GWTC-5 belegt Modell | **Nein** | nur Entwicklungs-Fixpunkt |

---

## Governance — Präregistrierung

| ID | Claim | Klasse | Quelle | Status |
|---|---|---|---|---|
| BH-GOV-01 | GWTC-5-Lücken-Test ORQ-093 präregistriert (LOCK) | Governance | [`preregistration_gwtc5.md`](preregistration_gwtc5.md) | **LOCK** (07.07.2026) |
| BH-GOV-02 | Phase-1-Kalibrierung: 92er-Grid, Bonferroni, GWTC-3, Export-Pipeline | Governance | `black_hole_gwtc_preregistered.py`, `run_black_hole_phase1_calibration.py` | reproduzierbar (Fixture) |

**BH-GOV-01 — Testdesign:**

- **Phase 1 (GWTC-3):** Grid \(\kappa \in [0{,}5, 5{,}0]\), \(\Delta\kappa=0{,}1\), \(\tau \in \{0{,}25, 0{,}5\}\) → \(N_{\text{tests}} = 92\); **Bonferroni**-Korrektur über alle 92 Hypothesentests; liefert nur \((\kappa^*, \tau^*)\), **kein** `[B]`-Claim.
- **Phase 2 (GWTC-4/5):** Blind-Verifikation mit fixiertem \((\kappa^*, \tau^*)\); **ein** präregistrierter Test, \(\alpha = 0{,}05\) einseitig — keine weitere Multiple-Test-Korrektur.
- Echter GWTC-5-Katalog erst nach LOCK-Commit; Mock/Fixture nur für Entwicklung.

---

## Upgrade-Pfad ORQ-093 → `[B]`

1. Präregistriertes \(\kappa\)-Fenster und Toleranz \(\tau\) **vor** Datenöffnung — erfüllt via BH-GOV-01.
2. Phase 1: GWTC-3-Kalibrierung mit Bonferroni über 92 Tests → \((\kappa^*, \tau^*)\).
3. Phase 2: GWTC-4/5 blind mit fixiertem \((\kappa^*, \tau^*)\); Permutations-Nullmodell (\(N=10\,000\), MC \(N=10\,000\)).
4. Kein Post-hoc-Reporting des minimalen \(p\) über explorative Sweeps als Hauptbefund.

---

## Verweise

- Präregistrierung: [`preregistration_gwtc5.md`](preregistration_gwtc5.md) (BH-GOV-01, LOCK)
- Dossier: [`../theory/black_hole_legendre_gwtc_bridge.md`](../theory/black_hole_legendre_gwtc_bridge.md)
- Hypothese: [`../black_hole_hypothese.md`](../black_hole_hypothese.md)
- Register: `EVIDENCE_REGISTER.md` (E-093)
