# Hc Numerical Stability Freeze — Metadata

**Status:** frozen / `passed`  
**SSOT operators:** [`hc_spectral_stability_spec.json`](hc_spectral_stability_spec.json)  
**Report:** [`hc_numerical_freeze_report.json`](hc_numerical_freeze_report.json)  
**Runner:** `scripts/run_hc_numerical_freeze.py`  
**Module:** `src/kepler_hurwitz/hc_spectral_freeze.py`

## Governance

| Schicht | Inhalt |
|---|---|
| **A/B normativ** | Rationale Matrizen `L_C4`, `V`, `N_II_*` in der Spezifikation; Hermitizität und Rayleigh-Identitäten als Hard Controls |
| **C numerisch** | Zertifizierter Freeze-Radius \(\varepsilon_*\) gegen Rauschklassen |
| **Nicht behauptet** | Formaler Lean-Beweis; Identifikation von \(\varepsilon_*\) mit einer Naturkonstante |

Numerischer Freeze **≠** formaler Beweis. Die Lean-Formalisierung kann auf dem eingefrorenen Stabilitätsbereich aufsetzen, ersetzt ihn aber nicht.

## Basisordnung

verbindlich: `rest_0`, `channel_5`, `channel_11`, `rest_3`  
Bamberg-Mode (unnormiert): \((0,1,-1,0)\)

## Limiting Criterion

Primär: \(|R_b(L_{C_4}+V) - R_b(L_{C_4}+\varepsilon N)| \ge \tfrac14\)  
kontinuierlich ab \(\varepsilon=0\) (contiguous-from-zero).

Sekundär (diagnostisch): `spectral_projector_overlap` der Bamberg-Mode.

## Symmetrischer Radius

\[
\varepsilon_*^{\mathrm{sym}} = \min_{\text{noise class}} \varepsilon_*^{(\cdot)}
\]

Limiting class: **`N_II_channel`** (Kanal-Mimikry von \(V\)).  
Analytisch: \(|2-(3-\varepsilon)|\ge\tfrac14\) ab \(\varepsilon=0\) \(\Rightarrow\) \(\varepsilon_*\le\tfrac34\).

## Trennung der Verantwortlichkeiten

1. Commit 1 — normative rationale Operatoren + Fraction-Validierung.  
2. Commit 2 — Freeze-Metadaten, Bracket-Intervalle, Reproduzierbarkeitstests.  
3. Danach — Lean-Formalisierung auf eingefrorenem Bereich.
