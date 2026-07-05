---
title: Diagnostics Parameter-Atlas
date: 2026-07-05
status: "[B]/[C]"
evidence_id: E-075
---

# Diagnostics Parameter-Atlas

**Implementierung:** `src/kepler_hurwitz/diagnostics.py` (`ATLAS_PRIMARY_FUNCTIONS`)  
**Tests:** `tests/test_diagnostics.py`  
**Brücke:** [`theory/distilled_parameters.md`](theory/distilled_parameters.md)

**Statusformel:** Parameter-Atlas statt neuer Großsatz.

---

## Governance

\[
\boxed{\text{Parameter destillieren ja; Identifikation behaupten nein.}}
\]

> Der Parameter-Atlas führt keine neuen Identitätsbehauptungen ein. Er misst Projektionsverluste, Defekte, Kosten, Balance und Chiralität zwischen bereits bestehenden Schichten. Er ist eine Diagnose- und Export-Schicht, kein neuer Beweiskern.

| Explizit **nicht** behauptet | |
|---|---|
| Beweise oder Theoreme | nur numerische Diagnostics |
| Kepler-Ellipse **ist** Quaternionennorm | nur Analogiesprache `[C]` |
| Globale Collatz-Vermutung | Collatz-Parameter sind Witness-Diagnostics `[C]` |
| Dedekind-Ideal-Identifikation $\Phi(v)=\gamma$ | offen `[C]` |

---

## Top-8 Parameter

| # | Funktion | Formel | Tag |
|---|---|---|---|
| 1 | `net_descent_margin(n, descended_value)` | $\Delta_{\mathrm{net}} = n - \mathrm{descended\_value}$ | `[B]` / Collatz `[C]` |
| 2 | `bad_run_cost(t_good)` | $C_{\mathrm{bad}} = t_{\mathrm{good}}$ | `[B]` |
| 3 | `shrink_efficiency(net_margin, bad_run_cost)` | $\eta = \Delta_{\mathrm{net}} / (C_{\mathrm{bad}} + 1)$ | `[B]` |
| 4 | `channel_entropy(signature)` | $-\sum_c p_c \log p_c$, $p_c = X/M$, $c=0$ überspringen | `[B]` |
| 5 | `prime_grid_compression(eabc_mass, omega)` | $\rho_{\mathrm{PG}} = M / \Omega$; `ValueError` wenn $M < 0$ oder $\Omega \le 0$ | `[B]` |
| 6 | `norm_signature_defect(product_sig, norm_sig)` | $\delta_H = \|H(N) - H(P)\|_1$ | `[B]` |
| 7 | `projection_loss(omega_norm, eabc_mass_norm)` | $L_\pi = \Omega - M$ | `[B]` |
| 8 | `chirality_norm(alpha, beta, gamma)` | $\|\chi\| = \sqrt{\alpha^2+\beta^2+\gamma^2}$ | `[C]` |

---

## Formeln (Primär-API)

```python
net_descent_margin(n, descended_value)  # n - descended_value
bad_run_cost(t_good)                    # t_good
shrink_efficiency(net_margin, c_bad)    # net_margin / (c_bad + 1)
channel_entropy((E, A, B, C))           # -sum(p_c * log(p_c)), p_c = c/M, skip c=0
prime_grid_compression(M, omega)        # M / omega; ValueError if M < 0 or omega <= 0
norm_signature_defect(H_P, H_N)         # L1 distance
projection_loss(omega, eabc_mass)       # omega - eabc_mass
chirality_norm(alpha, beta, gamma)      # sqrt(alpha^2 + beta^2 + gamma^2)
```

---

## Guards (defensive Eingabevalidierung)

| Funktion | Guard |
|---|---|
| `net_descent_margin(n, descended_value)` | `ValueError` wenn `n < 0` oder `descended_value < 0` |
| `bad_run_cost(t_good)` | `ValueError` wenn `t_good < 0` |
| `shrink_efficiency(net_margin, bad_run_cost)` | `ValueError` wenn `bad_run_cost < 0` |
| `channel_entropy(signature)` | alle vier Kanäle `>= 0`, sonst `ValueError`; bei $M = 0$ Rückgabe `0.0` |
| `prime_grid_compression(M, omega)` | `ValueError` wenn `M < 0` oder `omega <= 0` |
| `norm_signature_defect(H_P, H_N)` | je vier Kanäle, alle `>= 0`, sonst `ValueError` |
| `projection_loss(omega, eabc_mass)` | `ValueError` wenn nicht `omega >= eabc_mass >= 0` |
| `chirality_norm(α, β, γ)` | keine (reelle Argumente, `sqrt` für beliebige Floats) |

**Ergänzende Wrapper** (Nat/Primvierling/Collatz-Kette):  
`bad_run_cost_from_n`, `net_descent_margin_from_collatz`, `shrink_efficiency_from_collatz`,  
`channel_entropy_from_value`, `prime_grid_compression_from_nat`, `projection_loss_from_nat`,  
`norm_signature_defect_from_primvierling`, `collatz_net_descent_diagnostics`.

---

## Primvierling-Beispiel

$v = (5, 7, 11, 13)$, $\gamma_v = 5 + 7i + 11j + 13k$

| Größe | Wert |
|---|---|
| $P(v) = 5 \cdot 7 \cdot 11 \cdot 13$ | $5005$ |
| $H(P(v))$ | $(1, 1, 1, 1)$ |
| $N(\gamma_v)$ | $364$ |
| $H(N(\gamma_v))$ | $(1, 0, 1, 0)$ |
| $\delta_H(v) = \|H(N) - H(P)\|_1$ | $2$ |
| $L_\pi(N(\gamma_v)) = \Omega(364) - M(364)$ | $2$ |

```python
from kepler_hurwitz.diagnostics import norm_signature_defect_from_primvierling

assert norm_signature_defect_from_primvierling((5, 7, 11, 13)) == 2
assert norm_signature_defect((1, 1, 1, 1), (1, 0, 1, 0)) == 2
```

---

## Repo-Anschluss

| Artefakt | Pfad |
|---|---|
| Primär-API | `kepler_hurwitz.diagnostics` |
| CSV-Export | `kepler_hurwitz.diagnostics_export` · `examples/run_diagnostics_export.py` |
| Beispiel-CSV | `docs/energiedoku_exports/diagnostics_parameter_atlas.csv` |
| Legacy-Reexport | `kepler_hurwitz.distilled_parameters` |
| Theorie-Index | [`theory/README.md`](theory/README.md) |
| Destillierte Parameter | [`theory/distilled_parameters.md`](theory/distilled_parameters.md) |

### Export (CSV)

```bash
PYTHONPATH=src python examples/run_diagnostics_export.py
```

Spalten: `source_kind`, `source_key`, `t_loc` (nur Collatz) plus die Top-8-Parameter. Leere Zellen = nicht anwendbar (kein Identitäts- oder Beweisclaim).

---

## Referenzexport

Reproduzierbare Referenzmenge für Primvierlinge, EABC-Natürliche und Collatz-Witness-Fälle — **Diagnosewerte only**, keine Beweisclaims.

| Artefakt | Pfad |
|---|---|
| Export-Skript | `examples/export_diagnostics_atlas.py` |
| Referenz-CSV | `docs/energiedoku_exports/diagnostics_atlas_reference.csv` |

```bash
PYTHONPATH=src python examples/export_diagnostics_atlas.py
```

**Referenzmenge (Default):**

- Primvierlinge: erste 5 kanonische Primquadrupel `(p, p+2, p+6, p+8)` via `generate_prime_quadruplets`
- EABC-Natürliche: `6, 12, 30, 60, 210`
- Collatz: `(n, local_shrink_time) = (27, 3)` und `(15, 3)`

**Spalten:**

| Block | Spalten |
|---|---|
| Primvierling | `p`, `quadruple`, `product`, `norm`, `product_signature`, `norm_signature`, `norm_signature_defect`, `projection_loss`, `channel_entropy_norm`, `prime_grid_compression_norm` |
| Collatz | `n`, `t_good`, `m_good`, `local_shrink_time`, `descended_value`, `net_descent_margin`, `bad_run_cost`, `shrink_efficiency` |
| Meta | `source_kind` ∈ `{primvierling, eabc, collatz}` — leere Zellen = für diese Zeile nicht anwendbar |

**Governance (Referenzexport):**

- Keine Beweisclaims — nur destillierte Diagnosegrößen aus `kepler_hurwitz.diagnostics`.
- `norm_signature_defect` misst $\|H(N(\gamma_v)) - H(P(v))\|_1$; **beweist keine Dedekind-Brücke** `[C]`.
- `net_descent_margin > 0` ist **lokale Witness-Diagnose** für den gewählten `local_shrink_time`; **kein globaler Collatz-Beweis** `[C]`.

---

## Dumas Cone–Orbit (Erwartungen und Prüfmodule)

**Theorie:** [`theory/dumas_cone_orbit_model.md`](theory/dumas_cone_orbit_model.md) §16–§17 — Erwartungen, Falsifikationsrahmen, Prüfmodule A–E.

Der Parameter-Atlas dient als **Vergleichsanker** für offene statistische Tests (Module **B–E**, Hypothesen H12–H15):

| Modul | Atlas-Parameter | Frage |
|---|---|---|
| **C** | `channel_entropy` | Umfeld-Entropie \(S_L(p)\) vor Primvierlingen vs. Vergleichsgruppen |
| **E** | `channel_entropy`, Gewichtungsfeatures | Korrelation mit Lücken \(\Delta_i\) — nicht Entropie-Konstanz (H8) |
| **B**, **D** | indirekt via Export | Rotorphase, CEAB-Orientierung — siehe `dumas_cone_orbit_model.md` §17 |

Solange Nullmodelle nicht verworfen sind, bleiben diese Prognosen **`[B0]` prognoseneutral**: `channel_entropy`, `norm_signature_defect` und `projection_loss` liefern Diagnosewerte, aber **keine behauptete Vorhersagekraft** über die bereits verifizierte Dumas-Strukturidentität (Prüfmodul A) hinaus.

---

## Geplante Meissner-Schicht `[B]` (future layer)

**Bewertung:** [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md) · **Dossier:** [`reports/physical_reference_analogies.md`](reports/physical_reference_analogies.md) (E-076)

Der Parameter-Atlas kann um eine **Bulk/Shell-Meissner-Schicht** erweitert werden — erst `[B]`, wenn operationalisiert und exportiert. Vorgeschlagene Felder (noch **nicht** in `diagnostics.py`):

| Feld | Rolle |
|---|---|
| `bulk_defect_before` | $D_{\mathrm{bulk}}^{\mathrm{before}}$ vor Retraktion |
| `bulk_defect_after` | $D_{\mathrm{bulk}}^{\mathrm{after}}$ nach Retraktion |
| `shell_defect_after` | $D_{\mathrm{shell}}^{\mathrm{after}}$ am Rand |
| `shell_ratio` | $\rho_{\mathrm{shell}}$ — Defekt-Konzentration in Shell |
| `isotropy_index` | $\iota = \Delta / \mathrm{tr}(M)$ |
| `nullmodel_comparison` | Profil vs. Nullmodelle |

**Governance:** Meissner-Diagnostik diagnostiziert Nähe zum isotropen Fixpunkt — **ersetzt nicht** `prime_norm_full_restoration`. Bis Implementierung: **`[C]`-motiviert**.

---

## Shell-Separationsdiagnostik (E-077 / E-078 / E-079, `[C]`)

**Bridge-Target:** [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md) §2 · **Register:** E-077–E-079 (`[C]`)

| Artefakt | Pfad |
|---|---|
| Primär-API | `kepler_hurwitz.shell_separation_diagnostics` |
| Protokoll | [`reports/shell_separation_diagnostics_protocol.md`](reports/shell_separation_diagnostics_protocol.md) |
| Tests | `tests/test_shell_separation_diagnostics.py` |
| CSV-Export | `scripts/shell_separation_diagnostics.py` |
| Demo (JSON) | `examples/run_shell_separation_diagnostics.py` |
| CSV | `docs/energiedoku_exports/shell_separation_diagnostics.csv` |
| Box-Dim CSV | `docs/energiedoku_exports/shell_box_dimension_estimates.csv` |

**Funktionen:** `pairwise_min_distance`, `shell_sep`, `shell_overlap`, `sep`, `shell_separation_loss`, `first_loss`, `first_loss_n`, `box_dimension_estimate`, `embedding_quality`

```bash
PYTHONPATH=src python scripts/shell_separation_diagnostics.py
```

**Governance:** Diagnose only — beweist **nicht** `MetricSeparationLossExists`, globale `R³`-Einbettung oder Bouligand-Dimension. `projection_loss` (Top-8) bleibt Prime-Grid $L_\pi=\Omega-M$; metrischer Shell-Separationsverlust ist **separate** Schicht. `shellPrimeMatchAtFirstLoss` inaktiv bis internes `first_loss_n`.
