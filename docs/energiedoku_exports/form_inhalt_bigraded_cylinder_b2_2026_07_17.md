---
title: Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell
date: 2026-07-17
status: "Vollständig spezifizierter Entwurf; physische Materialisierung 
         im Workspace und reale Terminal-Evidenz weiterhin ausstehend."
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
- Bibliothek (Attestationspfad): [`mathdictate/bigraded_cylinder_graph.py`](../../mathdictate/bigraded_cylinder_graph.py)
- Runner:

```bash
PYTHONPATH=. python -m mathdictate.run_bigraded_cylinder_audit \
  --max-precisions 4 6 8 10 12 > audit-cylinder-normal.json
```

---

## Physische Quellpfade (Attestationskette: `mathdictate/`)

Die verbindliche Beglaubigungs-Kette nutzt **`mathdictate/`** (nicht allein `src/kepler_hurwitz/`).  
`kepler_hurwitz.bigraded_cylinder_graph` re-exportiert aus `mathdictate` (Single Source of Truth).

| Rolle | Pfad |
| --- | --- |
| Bibliothek (kanonisch) | `mathdictate/bigraded_cylinder_graph.py` |
| Runner (Modul) | `mathdictate/run_bigraded_cylinder_audit.py` |
| Tests | `tests/test_bigraded_cylinder_graph.py` |
| Theorie §5.6 | `docs/theory/bh_c11_scale_invariance_homogeneity.md` |
| Kompatibilität | `src/kepler_hurwitz/bigraded_cylinder_graph.py` (Re-Export) |

---

## Epistemische Grenze

$$
\boxed{\text{Spezifikation} \;\neq\; \text{Agenten-Behauptung} \;\neq\; \text{revisionssicheres Artefakt}}
$$

$$
\boxed{\text{vollständige Spezifikation} \quad \neq \quad \text{lokale Ausführung} \quad \neq \quad \text{revisionssicher beglaubigter Freeze}}
$$

$$
\boxed{\text{B2 Cutoff-Audit} \;\neq\; \text{Collatz-Beweis}}
$$

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cutoff-Audits; physischer Bamberg-Terminalauszug; revisionssichere Freeze-Attestation; Freigabe von Schicht B3 (Fano-/Inzidenz-Kopplung).

**Attestation:** Nur der **unedierte Bamberg-Terminal-Paste** der unten stehenden Befehlskette zählt als Beglaubigung. Agenten-IDs, Agentenberichte und Agenten-Smoke-Tests sind **keine** Commits und **keine** Beglaubigung.

---

## Bindender Status (Schicht B2)

```yaml
status: "Vollständig spezifizierter Entwurf; physische Materialisierung 
         im Workspace und reale Terminal-Evidenz weiterhin ausstehend."
```

Das mathematische und kombinatorische Skelett von Schicht B2 ist als **vollständig spezifizierter Entwurf** fixiert. Offen bleiben anerkannte physische Materialisierung im Sinne der Bamberg-Attestation und reale Terminal-Evidenz. Automatisierte Agentenmeldungen gelten **nicht** als Beglaubigung. **Kein** Collatz-Beweis.

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

## Ausstehendes Beglaubigungs-Protokoll (nur Nutzer-Paste)

Jede Anhebung auf reproduzierbare Beglaubigung verlangt den zusammenhängenden **physischen** Terminalnachweis (Bamberg), nicht nur eine Agentenmeldung. Vom Repo-Root:

```bash
PYTHONPATH=. python -m mathdictate.run_bigraded_cylinder_audit --max-precisions 4 6 8 10 12 > audit-cylinder-normal.json
PYTHONPATH=. python -O -m mathdictate.run_bigraded_cylinder_audit --max-precisions 4 6 8 10 12 > audit-cylinder-optimized.json
diff -u audit-cylinder-normal.json audit-cylinder-optimized.json
pytest tests/test_bigraded_cylinder_graph.py -v
shasum -a 256 mathdictate/bigraded_cylinder_graph.py \
  mathdictate/run_bigraded_cylinder_audit.py \
  tests/test_bigraded_cylinder_graph.py \
  docs/theory/bh_c11_scale_invariance_homogeneity.md \
  audit-cylinder-normal.json audit-cylinder-optimized.json
```

Hinweis: `PYTHONPATH=.` ist erforderlich, sofern das Paket nicht editierbar installiert ist. Pytest nutzt `pythonpath = [".", "src"]` aus `pyproject.toml`.

Lokale JSON-Dateien im Repo-Root (`audit-cylinder-*.json`) sind gitignored und höchstens **nicht-attestierte Arbeitsprodukte** — **keine** Beglaubigung ohne uneditierten Bamberg-Paste.

---

## Governance-Box

```
[B] Bigraded cylinder cutoff diagnostic audit (Schicht B2)
Attestation paths: mathdictate/
Precisions: 4, 6, 8, 10, 12 (default --max-precisions)
B3 (Fano/Inzidenz) blocked until B2 closed by physical Bamberg attestation
≠ Collatz proof
≠ automated agent report as attestation
≠ revisionssicher beglaubigter Freeze
```
