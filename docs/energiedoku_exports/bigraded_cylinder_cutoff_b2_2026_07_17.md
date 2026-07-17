---
title: Schicht B2 — Exhaustiver 2-adischer Zylinder-Cutoff-Audit
date: 2026-07-17
status: "Lokal reproduziert und gehasht am 2026-07-17; Arbeitsbaum enthielt
         unbezogene Dirty-Dateien außerhalb dieses Seals; externes
         Verifizieren offen; kein Collatz-Beweis."
governance: "[B] diagnostic cutoff audit; Z_<=P; kein Collatz-Beweis"
---

# Schicht B2 — Exhaustiver 2-adischer Zylinder-Cutoff-Audit

**Stand:** 2026-07-17  
**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku-Archiv / Bamberg B2 Cutoff  
**Governance:** **[B]** diagnostischer Cutoff-Audit — **kein** Collatz-Beweis

**Querverweise:**

- Theorie §5.6: [`docs/theory/bh_c11_scale_invariance_homogeneity.md`](../theory/bh_c11_scale_invariance_homogeneity.md)
- Bibliothek: [`src/kepler_hurwitz/bigraded_cylinder_graph.py`](../../src/kepler_hurwitz/bigraded_cylinder_graph.py)
- Runner:

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/bigraded_cylinder_cutoff_protocol.json
```

---

## Epistemische Grenze

$$
\boxed{\text{B2 Cutoff-Audit} \;\neq\; \text{Collatz-Beweis}}
$$

$$
\boxed{\text{Schicht B2 inhaltlich als exhaustiver Cutoff-Audit entworfen und ausführbar instanziiert; lokale Resultate und Revisionsartefakte nach Protokolllauf unten.}}
$$

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cutoff-Audits; externe Reproduktion durch Dritte.

---

## Lokaler Attestationslauf (2026-07-17)

### 1. Repository-Identität

| Feld | Wert |
|---|---|
| `git remote get-url origin` | `https://github.com/AkademieOlympia/Kepler-Hurrwitz.git` |
| `git rev-parse HEAD` (Pre-Seal, Quellstand vor diesem Commit) | `09ec89ac6f477280eb6c482f55e8dc3f2ddfd881` |
| `git tag --points-at HEAD` | **kein Tag** |

### 2. Arbeitsbaum

| Prüfung | Ergebnis |
|---|---|
| `git status --short` | **dirty** — zahlreiche unbezogene lokale Änderungen/Untracked außerhalb dieses Seals. Freeze-Claim bezieht sich **nur** auf die hier gehashten B2-Quellen und Protokollartefakte. |

### 3. Optimierungsunabhängigkeit (`python` vs `python -O`)

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/bigraded_cylinder_cutoff_normal.json
PYTHONPATH=src python -O -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/bigraded_cylinder_cutoff_opt.json
diff -u docs/exports/bigraded_cylinder_cutoff_normal.json \
        docs/exports/bigraded_cylinder_cutoff_opt.json
```

| Prüfung | Ergebnis |
|---|---|
| Runner-Stdout | beide: `BIGRADED CYLINDER AUDIT: PASSED` |
| `diff -u` JSON | **leer** (exit 0) |
| `diff -u` stdout | **leer** (exit 0) |
| Identität zu `bigraded_cylinder_cutoff_protocol.json` | **identisch** |

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

============================== 12 passed in 0.43s ==============================
```

### 5. SHA-256 (`shasum -a 256`)

| Datei | sha256 |
|---|---|
| `src/kepler_hurwitz/bigraded_cylinder_graph.py` | `cfa6a825107ffe24750fb648f9e27eaa47dbab46a00d482b821c29ff1213aa6b` |
| `src/kepler_hurwitz/run_bigraded_cylinder_audit.py` | `6a132b8f8f94fd6728e6c3b12ca2f48a34550c344599a3e03bbff27a93e4d955` |
| `examples/run_bigraded_cylinder_audit.py` | `5420671c8565ef1597ec63c51a5b0dc3cadb32dc65fd560f7914e6434b0734df` |
| `tests/test_bigraded_cylinder_graph.py` | `205d3d82b6fd15dfe0cd56ec7c31456648543a44e3c36c1059cb2ca1af610c92` |
| `docs/exports/bigraded_cylinder_cutoff_protocol.json` | `9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45` |
| `docs/exports/bigraded_cylinder_cutoff_normal.json` | `9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45` |
| `docs/exports/bigraded_cylinder_cutoff_opt.json` | `9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45` |

---

## Governance-Box

```
[B] Bigraded cylinder cutoff diagnostic audit (Schicht B2)
Precisions: 4, 6, 8, 10 (default runner)
≠ Collatz proof
≠ external verification
```
