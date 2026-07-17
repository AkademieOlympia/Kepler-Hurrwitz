---
title: Schicht B2 — Agenten-Laufanhang (pytest / diff / sha256)
date: 2026-07-17
status: "Nicht-attestierter Agentenlauf; Freeze-Kandidat unverändert; kein Bamberg-Vollzug"
canonical: false
---

# Schicht B2 — Agenten-Laufanhang (paste-fähig)

> **Epistemik:** Dies ist ein Agenten-Terminalprotokoll zum Einfügen/Prüfen.
> Es ist **kein** physischer Bamberg-Vollzug und hebt den Status **nicht**
> auf revisionssicher an. Agent-IDs (`a44ce950`, `06d8c6c1`) sind **keine** Commits.

## Repo / HEAD

```text
cwd: /Users/thomashoffbauer/Projects/Kepler-Hurrwitz
origin: https://github.com/AkademieOlympia/Kepler-Hurrwitz.git
branch: post-freeze/octonionic-collatz-proof-attempt
HEAD: 6a38c9e0c36eeddef6c63bcbcf31b5e09b5464a2
a637bdb ancestor of HEAD: yes (merge-base --is-ancestor exit 0)
B2 sources at 237869f: yes (unter src/kepler_hurwitz/, nicht mathdictate/)
mathdictate/: absent
```

## Präsenz

```text
src/kepler_hurwitz/bigraded_cylinder_graph.py          9481 B
src/kepler_hurwitz/run_bigraded_cylinder_audit.py      2915 B
tests/test_bigraded_cylinder_graph.py                  5503 B
examples/run_bigraded_cylinder_audit.py                 474 B
mathdictate/bigraded_cylinder_graph.py                 MISSING (wrong path)
```

## pytest

```text
pytest tests/test_bigraded_cylinder_graph.py -v
============================== 12 passed in 0.37s ==============================
exit: 0
```

## Runner normal / -O

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/audit-cylinder-normal.json
PYTHONPATH=src python -O -m kepler_hurwitz.run_bigraded_cylinder_audit \
  --out docs/exports/audit-cylinder-optimized.json
diff -u docs/exports/audit-cylinder-normal.json \
        docs/exports/audit-cylinder-optimized.json
# empty diff; DIFF_EXIT: 0
```

## sha256

```text
9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45  docs/exports/audit-cylinder-normal.json
9c78601ad0ef8ae95da3a3d7a9a67cd60aeb2481a11f268c20e846de2331ac45  docs/exports/audit-cylinder-optimized.json
cfa6a825107ffe24750fb648f9e27eaa47dbab46a00d482b821c29ff1213aa6b  src/kepler_hurwitz/bigraded_cylinder_graph.py
6a132b8f8f94fd6728e6c3b12ca2f48a34550c344599a3e03bbff27a93e4d955  src/kepler_hurwitz/run_bigraded_cylinder_audit.py
205d3d82b6fd15dfe0cd56ec7c31456648543a44e3c36c1059cb2ca1af610c92  tests/test_bigraded_cylinder_graph.py
5420671c8565ef1597ec63c51a5b0dc3cadb32dc65fd560f7914e6434b0734df  examples/run_bigraded_cylinder_audit.py
```

## Korrigierte Statusbox (zum Ersetzen in Chat-Entwürfen)

```
[B] Schicht B2 — Zylinder-Cutoff-Audit
Quellen: src/kepler_hurwitz/bigraded_cylinder_graph.py (+ runner/tests/examples)
NICHT: mathdictate/...  (falscher Chat-Pfad; Repo-Paket ist src/kepler_hurwitz/)
Zustand Quellen: physisch vorhanden seit a637bdb; auch in 237869f
Status: Freeze-Kandidat — Bamberg-physische Attestation ausstehend
≠ revisionssicherer Freeze
≠ Collatz-Beweis
Agent-IDs ≠ Git-Commits
```
