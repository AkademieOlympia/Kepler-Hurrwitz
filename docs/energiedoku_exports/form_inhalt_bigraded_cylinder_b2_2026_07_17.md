---
title: Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell
date: 2026-07-17
status: "Vollständig spezifizierter und ausführbarer Freeze-Kandidat; 
         lokale Ausführung und Revisionsartefakte weiterhin ausstehend."
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
\boxed{\text{Automatisierte Meldung} \;\neq\; \text{physischer Vollzug} \;\neq\; \text{revisionssicher beglaubigtes Artefakt}}
$$

$$
\boxed{\text{vollständige Spezifikation} \quad \neq \quad \text{lokale Ausführung} \quad \neq \quad \text{revisionssicher beglaubigter Freeze}}
$$

$$
\boxed{\text{B2 Cutoff-Audit} \;\neq\; \text{Collatz-Beweis}}
$$

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cutoff-Audits; physischer Bamberg-Terminalauszug; revisionssichere Freeze-Attestation; Freigabe von Schicht B3 (Fano-/Inzidenz-Kopplung).

**Orientierung (kein Status-Lift):** Feature-Commit der B2-Implementierung `a637bdb74da4fb96d1bd7aa820f3389a170bb2aa`. Cursor-Agent-IDs (`a44ce950`, `06d8c6c1`) sind **keine** Git-Commits und ersetzen keinen physischen Beglaubigungslauf. Tag `eabc-b2-cylinder-cutoff-v1` mag existieren — das allein macht den Stand **nicht** revisionssicher.

---

## Bindender Status (Schicht B2)

```yaml
status: "Vollständig spezifizierter und ausführbarer Freeze-Kandidat; 
         lokale Ausführung und Revisionsartefakte weiterhin ausstehend."
```

Das mathematische und kombinatorische Skelett von Schicht B2 ist als **vollständige Spezifikation** und ausführbarer Freeze-Kandidat fixiert — noch **ohne** anerkannten physischen Bamberg-Vollzug und **ohne** revisionssichere Freeze-Attestation. Automatisierte Agentenmeldungen gelten **nicht** als Beglaubigung.

---

## Statuszusammenfassung (kombinatorische Spezifikation)

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

**B3 bleibt blockiert**, bis B2 durch physischen Bamberg-Laufnachweis + Hash + anerkanntes Revisionsartefakt geschlossen ist. **Kein** Collatz-Beweis.

---

## Ausstehendes Beglaubigungs-Protokoll

Jede Anhebung auf reproduzierbare Beglaubigung verlangt den zusammenhängenden **physischen** Terminalnachweis (Bamberg), nicht nur eine Agentenmeldung:

1. **Struktureller JSON-Identitätsnachweis:** absolut leerer Ausgang von  
   `diff -u docs/exports/audit-cylinder-normal.json docs/exports/audit-cylinder-optimized.json`
2. **Funktionaler Regressionsnachweis:** grünes Protokoll von  
   `pytest tests/test_bigraded_cylinder_graph.py -v`
3. **Repository-Integrität:** uneditierte Rückgaben von `git remote get-url origin`, `git status --short`, `git diff --check` und 40-stelligem `git rev-parse HEAD`
4. **Krypto-Hashes:** `shasum -a 256` der vier Quelltexte und beider JSON-Laufprotokolle

*(Die vier Quelltexte: `bigraded_cylinder_graph.py`, `run_bigraded_cylinder_audit.py`, `tests/test_bigraded_cylinder_graph.py`, `examples/run_bigraded_cylinder_audit.py`.)*

JSON-Dateien unter `docs/exports/` (falls vorhanden) sind höchstens **nicht-attestierte Arbeitsprodukte** — **keine** Beglaubigung.

---

## Agentenbericht (nicht revisionssicher; kein Bamberg-Vollzug)

> **Warnung:** Der folgende Abschnitt dokumentiert lediglich, was Cursor-Agenten *gemeldet* haben. Er gilt **nicht** als physischer Bamberg-Terminalauszug, **nicht** als lokale Freeze-Attestation und **nicht** als revisionssicheres Energiedoku-Artefakt. Status bleibt Freeze-Kandidat (siehe Frontmatter).

Agenten berichteten (2026-07-17) u. a. pytest 12× passed und JSON-Identität unter `python` / `python -O`; zugehörige Hashes und Commit-Hashes in älteren Entwürfen wurden hier **absichtlich nicht** als Seal-/Freeze-Beweis übernommen. Ohne physischen Terminalauszug bleibt der Frontmatter-Status unverändert.

---

## Governance-Box

```
[B] Bigraded cylinder cutoff diagnostic audit (Schicht B2)
Precisions: 4, 6, 8, 10 (default runner)
B3 (Fano/Inzidenz) blocked until B2 closed by physical Bamberg attestation
≠ Collatz proof
≠ automated agent report as attestation
≠ revisionssicher beglaubigter Freeze
```
