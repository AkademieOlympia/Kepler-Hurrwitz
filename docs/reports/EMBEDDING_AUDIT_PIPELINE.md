# Embedding Audit Pipeline — Kanonische Referenz

**Evidence layer:** E-077 / E-078 model validation only  
**Status:** `[C]` — diagnostic measurement layer only  
**Date:** 2026-07-05  
**Interne Referenz:** zentraler Pfad für canonical vs. Energiedoku-Geometrievergleich (n = 1, 2, 3)  
**Ticket (Schritt 2 — COMPLETE):** [`docs/tickets/extract-energiedoku-shell-coordinates-n1-n3.md`](../tickets/extract-energiedoku-shell-coordinates-n1-n3.md)

---

## Die drei eisernen Abgrenzungen (Anti-Phantom-Debugging)

$$
\boxed{\text{Rohkoordinaten} \neq \text{Geometrie}}
\qquad
\boxed{\text{Koordinatenabweichung} \neq \text{Strukturabweichung}}
\qquad
\boxed{\text{Embedding-Audit} \neq \text{Loss-Nachweis}}
$$

> **Merksatz (DE):** Nicht ι_n reparieren, bevor bewiesen ist, dass ι_n das Problem ist.

**Reihenfolge (STRICT):**

1. canonical vs. Energiedoku vergleichen  
2. Abweichung klassifizieren  
3. **ι_n nur bei echter Strukturabweichung** revidieren — nicht vorher  
4. Erst danach ε_n-Regel schärfen (separater Diagnose-Lauf)

---

## Datenbasis

**Kanonische Source of Truth:** [`docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`](../energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv)

| Spalte | Bedeutung |
|---|---|
| `n` | Renorm-Stufe (1, 2, 3) |
| `shell` | Shell-Index 0 … 4^n − 1 (lex EABC-Wort-Reihenfolge) |
| `label` | EABC-Wort (z. B. `E`, `EA`, `EEE`) |
| `x`, `y`, `z` | Lean `cardinalShellEmbedding_*` / lattice `(φ^{-n})·classIndex` |

**Zeilen:** 84 Datenzeilen + Header (n=1 → 4, n=2 → 16, n=3 → 64 Punkte).

**Loader:** `src/kepler_hurwitz/energiedoku_shell_construction.py` liest diese CSV, wenn vorhanden; Fallback auf Code-Generierung aus Lean-Regeln, wenn die Datei fehlt.

**Vergleichsmodus (fair):** `matched_n_plus_1` — canonical `n+1` Prefix vs. erste `n+1` lex-Wörter der Energiedoku (gleiche Punktzahl). Modus `full` (alle 4^n Wörter) erzeugt erwartetes `count_mismatch`.

---

## Execution Commands

```bash
# Schritt 3: Invarianten-Audit (Default: fair matched_n_plus_1)
PYTHONPATH=src python scripts/shell_embedding_geometry_audit.py --n-max 3

# Optional: volle 4^n Energiedoku (count mismatch erwartet)
PYTHONPATH=src python scripts/shell_embedding_geometry_audit.py --n-max 3 --mode full

# Ergänzend: Punkt-für-Punkt Koordinatenvergleich
PYTHONPATH=src python scripts/compare_shell_embeddings.py --n-max 3

# Optional: Prefix↔Word-Mapping + volle 4^n sep/overlap
PYTHONPATH=src python scripts/compare_shell_embeddings.py --n-max 3 --full-energiedoku
```

**Module:**

| Skript | Modul |
|---|---|
| `scripts/shell_embedding_geometry_audit.py` | `src/kepler_hurwitz/shell_embedding_geometry_audit.py` |
| `scripts/compare_shell_embeddings.py` | `src/kepler_hurwitz/shell_embedding_comparison.py` |

**Audit-Export:** `docs/energiedoku_exports/shell_embedding_comparison_n1_n3.csv`  
**Koordinaten-Export:** `docs/energiedoku_exports/shell_embedding_comparison_n123.csv`

---

## Mathematischer Kern — Invarianten

Shape-Normalisierung vor Spektrumvergleich: Zentrierung am Schwerpunkt, Skalierung auf Einheits-Frobenius-Norm.

| Invariante | Definition |
|---|---|
| `sep(n)` | Minimale paarweise Centroid-Separation |
| `overlap(n)` | Überlappungszähler bei theorematischem `ε_n` (in Audit-`notes`, nicht CSV-Spalte) |
| Distanzspektrum | L2 zwischen sortierten paarweisen Distanzen (shape-normalisiert) |
| Gram-Spektrum | L2 zwischen sortierten Eigenwerten der Gram-Matrix (shape-normalisiert) |
| Radiusprofil | L2 zwischen sortierten Abständen vom Schwerpunkt (shape-normalisiert) |
| Procrustes-RMSD | RMSD nach optimaler Ähnlichkeitstransformation + optionaler Label-Permutation (≤ 8 Punkte) |

Absolute Koordinaten dürfen sich durch Translation, Rotation, Skalierung oder erlaubte Relabeling unterscheiden. **Nur Invarianten-Diskrepanz zählt als strukturelle Abweichung.**

**Harte Regel:** Invariantenvergleich (Distanz-/Gram-Spektrum, Procrustes) erfordert **gleiche Punktzahl** → für fairen Geometrievergleich immer `matched_n_plus_1`.

---

## Entscheidungsmatrix

| Ergebnis | Deutung | Aktion |
|---|---|---|
| `sep`, Distanzspektrum, Gram stimmen überein; Procrustes klein | **compatible** | weiter ε_n-Kalibrierung (Schritt 5) |
| `sep` ok, Procrustes groß | **label/orientation** | Prefix↔Word-Mapping prüfen (`shell_prefix_word_map_n123.csv`) |
| Distanzspektrum weicht ab | **true geometric deviation** | **audit ι_n** (Schritt 4) |
| nur `n=3` weicht ab | **possible first break** | n=3 isolieren |
| Punktzahl ungleich | **count_mismatch** | `matched_n_plus_1` verwenden |

**Harte Regel:** Unified-ι_n-Brücke **nur** revidieren, wenn der Invarianten-Audit echte geometrische Abweichung zeigt — nicht bei reiner Label-/Orientierungsfrage.

---

## Embedding Audit Rule

The canonical embedding ι_n must not be revised before it is compared against the explicit Energiedoku coordinates for n=1,2,3.

The comparison is performed on geometric invariants, not on raw coordinates alone:
sep(n), overlap(n), distance spectrum, Gram spectrum, radius profile, Procrustes RMSD.

Absolute coordinates may differ by translation, rotation, scaling, or permitted relabeling. Only invariant disagreement counts as structural disagreement.

If the canonical and Energiedoku embeddings agree on invariants, ι_n remains accepted for diagnostic use. If they disagree, the discrepancy must be classified before any ε_n-calibration, ShellSeparationLoss(n) search, or shellPrimeMatchAtFirstLoss test is interpreted.

This comparison is a model-validation step only. It does not prove MetricSeparationLossExist, does not establish a global R^3-embedding, does not determine n_0, and does not activate shellPrimeMatchAtFirstLoss.

---

## Pipeline (ASCII)

```
  [1] Detector-Controls bestanden
           |
           v
  [2] Energiedoku-Koordinaten kanonisieren
      (shell_coordinates_energiedoku_n1_n3.csv)
           |
           v
  [3] Embedding Geometry Audit
      (Invarianten: sep, overlap, spectra, Procrustes)
           |
           +---- compatible --------------------> [5] epsilon_n Kalibrierung
           |                                      (separater Diagnose-Lauf)
           |
           +---- label/orientation ----------> Mapping pruefen
           |                                  (shell_prefix_word_map)
           |
           +---- true geometric deviation ---> [4] audit iota_n (n >= 2)
           |                                      |
           +---- possible first break n=3 -------+--> dann [5]
```

**Kanonischer Pfad (Schritte 1–5):**

1. **Detector-Controls bestanden** — `shell_detector_controls.csv`  
2. **Energiedoku-Koordinaten n=1,2,3 kanonisieren** — `shell_coordinates_energiedoku_n1_n3.csv` ([Ticket](../tickets/extract-energiedoku-shell-coordinates-n1-n3.md) · COMPLETE 2026-07-05)  
3. **Embedding-Audit ausführen** — dieses Dokument / [`shell_embedding_comparison_protocol.md`](shell_embedding_comparison_protocol.md)  
4. **Nur bei echter Invariantenabweichung ι_n überdenken**  
5. **Erst danach ε_n-Regel schärfen** — separater Diagnose-Lauf (kein Gate für E-085)

---

## Current Status

**Audit scharf geschaltet:** Kanonische Energiedoku-Koordinaten sind materialisiert; der Geometry-Audit lädt `csv:shell_coordinates_energiedoku_n1_n3.csv` (84 Datenzeilen) — kein Toy-/Fallback-Pfad mehr für n = 1, 2, 3.

**Modus:** `matched_n_plus_1` · **Datum:** 2026-07-05 · **Koordinatenquelle:** `csv:shell_coordinates_energiedoku_n1_n3.csv`

> **NEXT = ι_n-Audit (n ≥ 2), nicht CSV-Extraktion.** Invariantenabweichung für n = 2/3 ist nachgewiesen; Schritt 2 und 3 sind abgeschlossen.

| Schritt | Status |
|---|---|
| Detector-Controls | **DONE** |
| Energiedoku-Koordinaten n = 1, 2, 3 | **DONE** ([Ticket](../tickets/extract-energiedoku-shell-coordinates-n1-n3.md) · CSV 84 rows — [`shell_coordinates_energiedoku_n1_n3.csv`](../energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv)) |
| Embedding-Audit-Code + Audit run | **DONE** (n = 1 compatible; n = 2/3 Abweichung) |
| ι_n-Revision n ≥ 2 | **NEXT** (Invariantenabweichung nachgewiesen) |
| ε_n-Schärfung | **PENDING** |
| ShellSeparationLoss(n)-Suche | **later** |
| `shellPrimeMatchAtFirstLoss` | **INACTIVE** |

### Audit-Ergebnisse (Schritt 3)

| n | compatible | classification | sep (canon / energiedoku) | dist_l2 | procrustes |
|---|---|---|---|---|---|
| 1 | yes | compatible | √2 / √2 | 0 | ~0 |
| 2 | no | true_geometric_deviation | √2 / φ⁻² | 0.586 | 0.625 |
| 3 | no | possible_first_break_n3 | √2 / φ⁻³ | 0.631 | 0.679 |

**Interpretation:**

- **n=1:** Gleiche endliche Geometrie bis auf Ähnlichkeitstransform — **keine ι_n-Revision**.  
- **n=2:** `sep` und Distanzspektrum weichen ab — **echte geometrische Abweichung**.  
- **n=3:** Wie n=2, zusätzlich **possible first break** — n=3 isoliert prüfen.

**Empfehlung (Schritt 4):** ι_n-Revision **indicated** für n ≥ 2. Unified-B2-Brücke **nicht** vor Abschluss des ι_n-Audits ersetzen.

---

## Governance

| Regel | Status |
|---|---|
| Modellvalidierung only | ✅ |
| **Kein** `MetricSeparationLossExist`-Claim | ✅ |
| **Kein** `first_loss_n` in diesem Audit-Output | ✅ |
| `shellPrimeMatchAtFirstLoss` | **INACTIVE** |
| Meissner-Sprache | `[C]` interpretive vocabulary only |
| Lean / `[B]` upgrade | ❌ not implied by this audit |

> Bulk stable, shell carries stress — interpretive only; not evidence for separation loss or prime coupling.

---

## Canonical Embedding Audit Pipeline

The embedding audit separates raw coordinate disagreement from structural geometric disagreement.

Raw coordinates in ℛ³ are not canonical. They may differ by translation, rotation, scaling, or permitted relabeling. Therefore, the canonical embedding ι_n must not be revised merely because coordinates differ.

The audit compares geometric invariants:

- sep(n)
- overlap(n)
- distance spectrum
- Gram spectrum
- radius profile
- Procrustes RMSD

Only disagreement of these invariants counts as structural disagreement.

The pipeline is:

detector controls → Energiedoku coordinates for n=1,2,3 → embedding audit → ε_n-calibration.

If the canonical and Energiedoku embeddings agree on invariants, ι_n remains accepted for diagnostic use. If they disagree, the discrepancy must be classified before any ε_n-calibration or ShellSeparationLoss(n) search is interpreted.

This audit does not prove MetricSeparationLossExist, does not establish a global ℛ³-embedding, does not determine n_0, and does not activate shellPrimeMatchAtFirstLoss.

---

## Das eiserne Prinzip

$$
\boxed{\text{Daten kanonisieren} \longrightarrow \text{Invarianten prüfen} \longrightarrow \text{erst dann Theorie schärfen}}
$$

**Marschrichtung:** Keine voreilige ι_n-Reparatur. Schritt 2 (Energiedoku-CSV) und Schritt 3 (Embedding-Audit) sind abgeschlossen. Nächstes Ticket: **ι_n-Audit für n ≥ 2** — die Invariantenabweichung ist nachgewiesen, die Klassifikation muss vor ε_n-Schärfung oder Loss-Suche abgeschlossen werden.

---

## Related

| Dokument / Artefakt | Rolle |
|---|---|
| [`shell_embedding_comparison_protocol.md`](shell_embedding_comparison_protocol.md) | Detailliertes Audit-Protokoll |
| [`shell_separation_diagnostics_protocol.md`](shell_separation_diagnostics_protocol.md) | Parent: Detector + sep pipeline |
| `shell_embedding_comparison_n123.csv` | Punkt-für-Punkt Koordinatenvergleich |
| `shell_prefix_word_map_n123.csv` | Prefix ↔ EABC-Wort-Mapping |
| `shell_energiedoku_full_n23.csv` | Volle 4^n sep/overlap (separater Lauf) |
