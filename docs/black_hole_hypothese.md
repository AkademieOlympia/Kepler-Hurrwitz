# Projekt „Black Hole“

Strategisches Ziel: Prüfen, ob **Legendre-verbotene Quaternionen-Normschalen** (Drei-Quadrate-Satz, Form \(4^a(8b+7)\)) mit der **Primär-Massenverteilung** und der **Spin-Präzession** (\(\chi_p\)) im GWTC-Katalog korrelieren — unter explizitem **Quantisierungsfaktor** \(\kappa\) von Sonnenmassen in den diskreten EABC-Zahlenraum.

Evidenzstatus zum Anlegen: `[C]` (offene Hypothese) mit `[B]`-Diagnostik-Stub; Upgrade zu `[B]` erst nach präregistriertem \(\kappa\)-Protokoll auf **echtem** GWTC-Datensatz und signifikantem Fisher-Test über Permutations-Nullmodellen hinaus.

**Register:** E-093 · **ORQ:** ORQ-093 · **Dossier:** [`theory/black_hole_legendre_gwtc_bridge.md`](theory/black_hole_legendre_gwtc_bridge.md) · **Claim-Register:** [`black_hole/claim_register.md`](black_hole/claim_register.md) · **Präregistrierung (LOCK):** [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md)

---

## 1. Kernzerlegung

| Schicht | Inhalt | Status |
|---|---|---|
| **Algebra `[A/B]`** | Legendre-Lücken, Drei-Quadrate-Obstruktion, verbotene \(s^2\) | Sage + Python reproduzierbar |
| **Brücke `[C]`** | \(\kappa : M_\odot \to \mathbb{Z}\) (Quantisierung) | Parameter offen, Sweep explorativ |
| Heuristik `[C]` | \(\chi_p \approx 0\) → 1G; \(\chi_p \gg 0\) → 2G-Merger | Lesesprache, nicht Identität |
| **MC-Fehler `[C]`** | Split-Normal \(P_{\mathrm{gap}}\), Permutation über \(\sum P_{\mathrm{gap}}\) | Ersetzt binäre Lückentreffer bei `--use-monte-carlo` |
| **Empirie `[B]`-Ziel** | Kontingenztafel + Fisher-Test GWTC vs. Lücken | Mock-Katalog implementiert |

\[
m_{\mathrm{quant}} = \kappa \cdot M_{\odot,\mathrm{primary}}
\qquad
\text{Treffer in Legendre-Lücke wenn } |m_{\mathrm{quant}} - m_{\mathrm{forbidden}}| \le \tau.
\]

---

## 2. Testprotokoll

1. **Theorie:** `get_forbidden_mass_integers(max_norm)` aus Primnormen \(p\) und \(s^2 = p - m^2\).
2. **Daten:** GWTC-5 (oder Mock) mit \(M_1, M_2, \chi_p\).
3. **Klassifikation:** 1G wenn \(\chi_p < 0{,}2\); sonst 2G-Kandidat.
4. **Kontingenztafel:**

|  | In Legendre-Lücke | Außerhalb |
|---|---|---|
| **1G** | \(A\) | \(B\) |
| **2G** | \(C\) | \(D\) |

5. **Fisher Exact Test** (`alternative='less'`): Meiden 1G-Kandidaten die Lücken häufiger als 2G?
6. **Permutations-Nullmodell:** \(\chi_p\)-Shuffle bei fixen Massen; binäre Metrik `obs_1g_in_gap` **oder** (MC-Modus) \(\sum P_{\mathrm{gap}}\) über 1G-Kandidaten.
7. **Monte-Carlo-Fehlerfortpflanzung `[C]`:** Split-Normal aus GWOSC-Median + `mass_1_source_lower/upper` (90%-CI → \(\sigma = |\mathrm{err}|/1{,}645\)); \(P_{\mathrm{gap}}\) = Anteil der MC-Ziehungen in Legendre-Lücke nach \(\kappa\)-Quantisierung. Fisher-Kontingenztafel ist im MC-Modus **deprecated** als Primärmetrik.
8. **\(\kappa\)-Sweep (explorativ):** \(\kappa \in [0{,}1, 10{,}0]\) in Schritten — **nicht** als Discovery-Claim ohne Präregistrierung.

**Urteil:** EABC-Lückenhypothese nur bei präregistriertem \(\kappa\), echtem GWOSC-Katalog und signifikantem Permutations-Nullmodell.

---

## 3. Implementierung

| Artefakt | Pfad |
|---|---|
| Diagnostik-Modul | `src/kepler_hurwitz/black_hole_legendre_gwtc.py` |
| Export-Skript | `examples/run_black_hole_gwtc_export.py` |
| Tests | `tests/test_black_hole_legendre_gwtc.py`, `tests/test_black_hole_governance_docs.py` |
| Sage — Legendre-Lücken | `scripts/black_hole/legendre_mass_gaps.sage` |
| Sage — 2G-Merger | `scripts/black_hole/eabc_merger.sage` |
| Sage — [[5,1,3]]-Brücke | `scripts/black_hole/five_qubit_bridge.sage` |
| Sage — GUE-Monopol | `scripts/black_hole/monopole_gap_test.sage` |
| Sage — MC \(P_{\mathrm{gap}}\) | `scripts/black_hole/monte_carlo_pgap.sage` |
| Sage — Sechs-Zustands-Primachsen `[C]` | `scripts/black_hole/eabc_prime_six_state.sage` |
| Dirichlet χ_{-3}-Konjugator `[C]` | `src/kepler_hurwitz/eabc_dirichlet_chi_minus3.py`, `scripts/black_hole/eabc_dirichlet_chi_minus3.sage` |
| **Phase-1-Kalibrierung (BH-GOV-02)** | `src/kepler_hurwitz/black_hole_gwtc_preregistered.py`, `examples/run_black_hole_phase1_calibration.py` |
| Sechs-Zustands-Theorie (Geschwister) | [`theory/eabc_six_state_prime_axes.md`](theory/eabc_six_state_prime_axes.md) |
| χ_{-3}-Konjugator-Theorie | [`theory/eabc_dirichlet_chi_minus3_conjugator.md`](theory/eabc_dirichlet_chi_minus3_conjugator.md) |
| Lean-Interface `[C]` | `KeplerHurwitz/BlackHoleInterface.lean` |
| Mock-Katalog | `data/black_hole/mock_gwtc5.csv` |
| GWOSC-Fixture (Tests) | `data/black_hole/gwosc_fixture.csv` |
| GWTC-3-Fixture (Phase 1) | `data/black_hole/gwosc_gwtc3_fixture.csv` |
| **Präregistrierung (LOCK)** | [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md) |
| Export-Ziel | `docs/exports/black_hole_gwtc_*.json/csv` |

**Loader:** `load_official_gwtc_catalog` / `load_gwtc_catalog` — GWOSC-Spalten `mass_1_source`, `mass_2_source`, `chi_p` (Fallback `mass_1`/`mass_2`); optional `mass_1_source_lower/upper`; Legacy-Mock `m1_solar`, `m2_solar`. **Nullmodell:** `permutation_null_model` (binär) oder `permutation_test_mc` (Split-Normal \(P_{\mathrm{gap}}\), Flag `--use-monte-carlo`).

```bash
PYTHONPATH=src python examples/run_black_hole_gwtc_export.py
PYTHONPATH=src python examples/run_black_hole_gwtc_export.py --use-monte-carlo --mc-samples 500 --perm-iterations 500
PYTHONPATH=src python examples/run_black_hole_phase1_calibration.py --mc-samples 500 --perm-iterations 500
pytest tests/test_black_hole_legendre_gwtc.py tests/test_black_hole_governance_docs.py \
  tests/test_black_hole_gwtc_preregistered.py tests/test_eabc_dirichlet_chi_minus3.py -q
# Sage (optional):
sage scripts/black_hole/legendre_mass_gaps.sage
sage scripts/black_hole/monte_carlo_pgap.sage
```

---

## 4. Governance (verbindlich)

**Präregistrierung (BH-GOV-01, LOCK):** Das formale Protokoll [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md) fixiert \(\kappa\)-Grid, \(\tau\)-Werte, Lockbox-Partitionierung (Phase 1: GWTC-3 + Bonferroni über 92 Tests; Phase 2: GWTC-4/5 blind) und Ausschlusskriterien. **Phase-1-Pipeline (BH-GOV-02):** `run_phase1_calibration` implementiert das 92er-Grid; Export via `run_black_hole_phase1_calibration.py` → `docs/exports/black_hole_phase1_calibration.json`. Phase-1-Signifikanz **upgraded nicht** zu `[B]`. **Echter GWTC-3/5-CSV:** offizieller GWOSC-Parameter-Estimation-Katalog (z. B. GWTC-3 PE-Release auf [gwosc.org](https://gwosc.org/)); bis dahin Fixture (`gwosc_gwtc3_fixture.csv`) und Mock.

| Claim | Erlaubt? |
|---|---|
| Legendre-Lücken als algebraischer `[A/B]`-Kern | Ja |
| \(\kappa\)-Brücke als methodische Lesesprache | Ja — `[C]` |
| 1G/2G über \(\chi_p\) als Identität mit EABC-Merger | **Nein** |
| Mock-GWTC als Beweis für Raumzeit-Quantisierung | **Nein** |
| \(\kappa\)-Minimum-Scan als publizierbarer Befund ohne Präregistrierung | **Nein** |
| GWTC-5-Katalog vor LOCK-Commit als Discovery-Quelle | **Nein** |

\[
\boxed{
\text{Black Hole testet } \kappa \cdot M_\odot \leftrightarrow \text{Legendre-Lücken} \times \chi_p\text{-Stratifizierung, nicht EABC = GW.}
}
\]

---

## 5. Querverweise

| Dokument | Rolle |
|---|---|
| [`black_hole_legendre_gwtc_bridge.md`](theory/black_hole_legendre_gwtc_bridge.md) | Vollprotokoll E-093 |
| [`black_hole/claim_register.md`](black_hole/claim_register.md) | Claim-Governance |
| [`black_hole/preregistration_gwtc5.md`](black_hole/preregistration_gwtc5.md) | Präregistrierung LOCK (BH-GOV-01) |
| [`GodelKerr.lean`](../KeplerHurwitz/GodelKerr.lean) | Abstraktes Rotations-Interface |
| [`open_research_questions.md`](open_research_questions.md) | ORQ-093 |
| [`nuclear_binding_multiscale_analogy.md`](theory/nuclear_binding_multiscale_analogy.md) | Geschwister-Residualtest E-092 |
| [`eabc_six_state_prime_axes.md`](theory/eabc_six_state_prime_axes.md) | mod-6-Primachsen, Gap-Rotation `[C]` (Geschwister E-093) |
