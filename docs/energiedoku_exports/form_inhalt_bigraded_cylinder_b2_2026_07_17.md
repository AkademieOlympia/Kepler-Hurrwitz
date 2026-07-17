---
title: Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell
date: 2026-07-17
status: "Lokal reproduziert und gehasht am 2026-07-17; Arbeitsbaum enthielt
         unbezogene Dirty-Dateien außerhalb dieses Seals; externe
         Verifikation offen; kein Collatz-Beweis."
governance: "[B] diagnostic cutoff audit; Z_<=P; kein Collatz-Beweis; B3 blocked"
canonical: true
---

# Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell

**Schicht:** B2 — Exhaustiver 2-adischer Zylinder-Cutoff-Audit  
**Stand:** 2026-07-17  
**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku-Archiv / Bamberg B2 Cutoff  
**Governance:** **[B]** diagnostischer Cutoff-Audit — **kein** Collatz-Beweis  
**Kanonische Datei:** dieses Dokument (Querverweis-Stub: [`bigraded_cylinder_cutoff_b2_2026_07_17.md`](bigraded_cylinder_cutoff_b2_2026_07_17.md))

**Querverweise:**

- Theorie §5.6: [`docs/theory/bh_c11_scale_invariance_homogeneity.md`](../theory/bh_c11_scale_invariance_homogeneity.md)
- Bibliothek: [`src/kepler_hurwitz/bigraded_cylinder_graph.py`](../../src/kepler_hurwitz/bigraded_cylinder_graph.py)
- Runner:

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/audit-cylinder-normal.json
```

---

## Epistemische Grenze

$$
\boxed{\text{vollständige Spezifikation} \quad \neq \quad \text{lokale Ausführung} \quad \neq \quad \text{revisionssicher beglaubigter Freeze}}
$$

$$
\boxed{\text{B2 Cutoff-Audit} \;\neq\; \text{Collatz-Beweis}}
$$

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cutoff-Audits; externe Reproduktion durch Dritte; Freigabe von Schicht B3 (Fano-/Inzidenz-Kopplung).

---

## Historische Freeze-Kandidat-Deklaration

Vor dem physischen Beglaubigungslauf galt (und bleibt als Kandidatur-Wortlaut archiviert):

```yaml
status: "Vollständig spezifizierter und ausführbarer Freeze-Kandidat; 
         lokale Ausführung und Revisionsartefakte ausstehend."
```

Das mathematische und kombinatorische Skelett von Schicht B2 war damit als **vollständige Spezifikation** fixiert — noch **ohne** lokale Ausführung und **ohne** revisionssichere Freeze-Attestation.

---

## Statuszusammenfassung (Schicht B2)

$$
\boxed{\begin{aligned}
\text{Präzisions-Cutoff:}\quad& \mathcal{Z}_{\le P} \text{ mit exakt } 2^P-1 \text{ Zuständen im Code erzwungen}, \\
\text{Lift-Schranken:}\quad& \lvert E_{\mathrm{lift}}^{\mathrm{internal}}\rvert = 2^P-2 \text{ und } \lvert E_{\mathrm{lift}}^{\mathrm{boundary}}\rvert = 2^P \text{ analytisch geschlossen}, \\
\text{Dynamik-Schranken:}\quad& \lvert E_{\mathrm{dyn}}\rvert = (2^P-1)-P \text{ und } E_{\mathrm{dyn}}^{\mathrm{boundary}}=0 \text{ als harte Sollgrößen}, \\
\text{Singular-Split:}\quad& \text{Lemma } \{p, p+1\} \text{ auf jeder Ebene nachgewiesen (Kardinalität = 1)}, \\
\text{Singular-Pfad:}\quad& \text{fortlaufend lift-verbundene Kette nach } -1/3 \in \mathbb{Z}_2 \text{ serialisiert}, \\
\text{Doppel-Prüfung:}\quad& \text{Runner validiert die Berichtsmetadaten gegen separate analytische Sollwerte}, \\
\text{Fano-Aktion:}\quad& \text{Schicht B3 (Inzidenz-Kopplung) blockiert bis zur Schließung von B2}.
\end{aligned}}
$$

**B3 bleibt blockiert**, bis B2 durch Laufprotokoll + Hash + Commit geschlossen ist. Auch nach lokalem Attest: **kein** Collatz-Beweis; **externe Verifikation offen**.

---

## Ausstehendes Beglaubigungs-Protokoll

Jede Anhebung auf reproduzierbare Beglaubigung verlangt den zusammenhängenden Terminalnachweis mit:

1. **Struktureller JSON-Identitätsnachweis:** absolut leerer Ausgang von  
   `diff -u docs/exports/audit-cylinder-normal.json docs/exports/audit-cylinder-optimized.json`
2. **Funktionaler Regressionsnachweis:** grünes Protokoll von  
   `pytest tests/test_bigraded_cylinder_graph.py -v`
3. **Repository-Integrität:** uneditierte Rückgaben von `git remote get-url origin`, `git status --short`, `git diff --check` und 40-stelligem `git rev-parse HEAD`
4. **Krypto-Hashes:** `shasum -a 256` der vier Quelltexte und beider JSON-Laufprotokolle

*(Die vier Quelltexte: `bigraded_cylinder_graph.py`, `run_bigraded_cylinder_audit.py`, `tests/test_bigraded_cylinder_graph.py`, `examples/run_bigraded_cylinder_audit.py`.)*

---

## Lokaler Attestationslauf (2026-07-17)

Lauf gegen Quell-/Runner-Stand auf Parent-HEAD (vor Seal-Commit dieses Archivs).  
**Ergebnis:** Protokoll erfolgreich → Frontmatter-Status von Freeze-Kandidat auf lokale Attestation angehoben; externe Verifikation bleibt offen.

### 1. Repository-Identität

| Feld | Wert |
|---|---|
| `git remote get-url origin` | `https://github.com/AkademieOlympia/Kepler-Hurrwitz.git` |
| `git rev-parse HEAD` (Pre-Seal, Quellstand vor diesem Commit) | `0b05411bb0c2c4bb8928b3a2b36bc22961b34c17` |
| Seal-Commit (B2 Archiv + kanonische Protokollartefakte) | `d99a0f8bab2dc375497111c50987411c626a8d53` |
| `git tag --points-at HEAD` | **kein Tag** |

### 2. Arbeitsbaum und Diff-Check

| Prüfung | Ergebnis |
|---|---|
| `git status --short` | **dirty** — 446 Zeilen unbezogene lokale Änderungen/Untracked außerhalb dieses Seals. Freeze-Claim bezieht sich **nur** auf die hier gehashten B2-Quellen und Protokollartefakte. |
| `git diff --check` | exit 2 — Trailing-Whitespace in **unbezogenen** Dateien (`docs/atome_hypothese.md`, `docs/theory/README.md`, …). Kein Whitespace-Fehler in den B2-Seal-Quellen. |

### 3. Optimierungsunabhängigkeit (`python` vs `python -O`)

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/audit-cylinder-normal.json
PYTHONPATH=src python -O -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/audit-cylinder-optimized.json
diff -u docs/exports/audit-cylinder-normal.json \
        docs/exports/audit-cylinder-optimized.json
```

| Prüfung | Ergebnis |
|---|---|
| Runner-Stdout | beide: `BIGRADED CYLINDER AUDIT: PASSED` |
| `diff -u` JSON | **leer** (exit 0) |
| `diff -u` stdout | **leer** (exit 0) |
| Identität zu Alias `bigraded_cylinder_cutoff_protocol.json` | **identisch** |

### 4. pytest

```bash
PYTHONPATH=src pytest tests/test_bigraded_cylinder_graph.py -v
```

```
============================= test session starts ==============================
platform darwin -- Python 3.13.11, pytest-9.1.0
collected 12 items

tests/test_bigraded_cylinder_graph.py::TestRequire::test_passes_on_true PASSED
tests/test_bigraded_cylinder_graph.py::TestRequire::test_raises_on_false PASSED
tests/test_bigraded_cylinder_graph.py::TestVisibleValuation::test_basic_odd_residue PASSED
tests/test_bigraded_cylinder_graph.py::TestVisibleValuation::test_singular_at_p3 PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_combinatorial_counts_and_singular_path[3] PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_combinatorial_counts_and_singular_path[4] PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_combinatorial_counts_and_singular_path[6] PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_combinatorial_counts_and_singular_path[8] PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_incomplete_universe_fails PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_empty_universe_fails PASSED
tests/test_bigraded_cylinder_graph.py::TestCompleteCutoffAudit::test_duplicates_fail PASSED
tests/test_bigraded_cylinder_graph.py::TestOptimizationFlagIndependence::test_audit_runner_stdout_identical_under_dash_o PASSED

============================== 12 passed in 0.42s ==============================
```

### 5. SHA-256 (`shasum -a 256`)

Vier Quelltexte + beide kanonischen JSON-Protokolle:

| Datei | sha256 |
|---|---|
| `src/kepler_hurwitz/bigraded_cylinder_graph.py` | `cfa6a825107ffe24750fb648f9e27eaa47dbab46a00d482b821c29ff1213aa6b` |
| `src/kepler_hurwitz/run_bigraded_cylinder_audit.py` | `6a132b8f8f94fd6728e6c3b12ca2f48a34550c344599a3e03bbff27a93e4d955` |
| `tests/test_bigraded_cylinder_graph.py` | `205d3d82b6fd15dfe0cd56ec7c31456648543a44e3c36c1059cb2ca1af610c92` |
| `examples/run_bigraded_cylinder_audit.py` | `5420671c8565ef1597ec63c51a5b0dc3cadb32dc65fd560f7914e6434b0734df` |
| `docs/exports/audit-cylinder-normal.json` | `9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45` |
| `docs/exports/audit-cylinder-optimized.json` | `9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45` |

Alias (identischer Inhalt): `docs/exports/bigraded_cylinder_cutoff_protocol.json` → dieselbe sha256 `9c78601a…`.

---

## Governance-Box

```
[B] Bigraded cylinder cutoff diagnostic audit (Schicht B2)
Precisions: 4, 6, 8, 10 (default runner)
B3 (Fano/Inzidenz) blocked until B2 closed
≠ Collatz proof
≠ external verification
≠ revisionssicher beglaubigter Freeze ohne Hash+Commit+externe Prüfung
```
