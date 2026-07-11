# EABC Riemann-Achsen-Monopol — a vs. bc Resonanz

**Status:** `[C]` Hypothese / explorative Diagnostik  
**Register:** E-093 (Geschwister), Claim **BH-C-08**  
**Modul:** `src/kepler_hurwitz/eabc_monopole_axis_resonance.py`  
**Basis:** [`eabc_six_state_prime_axes.md`](eabc_six_state_prime_axes.md)

---

## Motivation (Energiedoku)

Nicht-triviale Imaginärteile `γ_n` der Riemann-Zeta-Nullstellen sollen unterschiedlich mit den mod-6-Primachsen **a** (6k+1) und **bc** (6k−1) resonieren — analog zu einem „Monopol“ zwischen konjugierten Quaternionenachsen.

---

## Resonanzmetrik

Für eine Probe `γ` und Primliste `P`:

```
ψ(γ, P) = Σ_{p ∈ P} cos(γ ln p) / √p
```

Achsenspezifisch:

| Symbol | Primachse |
|---|---|
| `ψ_a(γ)` | `p ≡ 1 (mod 6)` → Zustand **a** |
| `ψ_bc(γ)` | `p ≡ 5 (mod 6)` → Zustand **bc** |

**Delta:**

```
δ(γ) = ψ_a(γ) − ψ_bc(γ)
```

**Dominante Achse:** `a` wenn `δ > 0`, `bc` wenn `δ < 0`, sonst `tie`.

Implementierung: `compute_resonance`, `analyze_zero_axis_resonance` — reine Python-Partialsummen, kein `lcalc` in Tests.

---

## Delta-Oszillation `[C]`

**Hypothese:** Aufeinanderfolgende Nullstellen `γ_n` wechseln vorzugsweise die dominante Achse (Vorzeichen von `δ` oszilliert).

**Governance:** Diese Beobachtung ist **nicht** discovery-tauglich ohne Präregistrierung. Numerische Alternation beweist **kein** Monopol und **keinen** RH-Beweis. Sie dient nur als Lesesprache-Brücke zum GUE-Monopol-Skript.

Verwandtes Toy: [`scripts/black_hole/monopole_gap_test.sage`](../../scripts/black_hole/monopole_gap_test.sage) (BH-C-05) — Stabilisator-Phasen vs. GUE-Abstandsheuristik.

---

## Dirichlet-L als mathematischer Konjugator

Eine **saubere** mod-6-Achsentrennung der Zeta-Information erfordert die Dirichlet-L-Funktion `L(s, χ_{-3})` als Konjugator — nicht die bloße Kosinus-Partialsumme auf `{a}` vs `{bc}`.

**Implementierung:** [`eabc_dirichlet_chi_minus3.py`](../../src/kepler_hurwitz/eabc_dirichlet_chi_minus3.py) und Dossier [`eabc_dirichlet_chi_minus3_conjugator.md`](eabc_dirichlet_chi_minus3_conjugator.md) (Claim **BH-C-10**). Dieses Monopol-Modul behält die explorative ungewichtete Kosinus-Metrik; der Konjugator formalisiert χ_{-3}-Gewichtung und den zeta-vs-L-chi-Vergleich.

---

## Symplektische L-Gap-Erweiterung (Geschwister)

**Dossier:** [`eabc_symplectic_l_gap_bridge.md`](eabc_symplectic_l_gap_bridge.md)  
**Modul:** `src/kepler_hurwitz/eabc_symplectic_stabilizer_bridge.py`  
**Claim:** **BH-C-09** — Nachbarabstände \(\Delta\gamma\) von \(L(s,\chi_{-3})\)-Nullstellen auf 15 symplektische `[[5,1,3]]`-Stabilisatoren projiziert (Gap als Phasenübergang `[C]`).

---

## Artefakte

| Artefakt | Pfad |
|---|---|
| Python-Modul | `src/kepler_hurwitz/eabc_monopole_axis_resonance.py` |
| Sage-Driver | `scripts/black_hole/eabc_monopole_axis_resonance.sage` |
| CLI-Export | `examples/run_eabc_monopole_axis_resonance.py` |
| JSON | `docs/exports/eabc_monopole_axis_resonance.json` |
| Tests | `tests/test_eabc_monopole_axis_resonance.py` |
| Claim | `docs/black_hole/claim_register.md` → **BH-C-08** |

---

## Claim-Grenze

| Erlaubt `[C]` | Nicht behauptet |
|---|---|
| Explorative Achsen-Resonanz an bekannten γ_n | RH-Beweis |
| Reproduzierbare Partialsummen `[B]` bei fixiertem `prime_limit` | Perfektes Monopol / Quantensprung |
| Verweis auf χ_{-3} als mathematischen nächsten Schritt | Zeta zerlegt mod 6 ohne Dirichlet-L |
| Delta-Oszillation als Hypothese | Alternation als Hauptbefund ohne Präregistrierung |
