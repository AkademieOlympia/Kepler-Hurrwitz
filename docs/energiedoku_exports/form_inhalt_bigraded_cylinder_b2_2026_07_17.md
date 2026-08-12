---
title: Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell
date: 2026-07-17
status: "Schicht B2 vollständig spezifiziert; Git-Verankerung und materielle
         Beglaubigung ausstehend. Ein ununterbrochener, automatisierter B1-Sanity-Check
         über ein Here-Doc-Muster wurde erfolgreich definiert. Schicht B3 bleibt blockiert."
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
- B1-Gatekeeper (optional, gleiche Logik): [`scripts/b1_cylinder_sanity.py`](../../scripts/b1_cylinder_sanity.py)
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
| B1 Here-Doc (unten) | dieses Dokument, Abschnitt „B1-Sanity-Check (Here-Doc-Gatekeeper)“ |
| B1 Skript (optional) | `scripts/b1_cylinder_sanity.py` |
| Theorie §5.6 | `docs/theory/bh_c11_scale_invariance_homogeneity.md` |
| Kompatibilität | `src/kepler_hurwitz/bigraded_cylinder_graph.py` (Re-Export) |

---

## Epistemische Grenze

$$
\boxed{\text{B1\_SANITY deklariert} \quad \neq \quad \text{B2 auf HEAD verankert} \quad \neq \quad \text{B2 ausgeführt und beglaubigt}}
$$

$$
\boxed{\text{Spezifikation} \;\neq\; \text{Agenten-Behauptung} \;\neq\; \text{revisionssicheres Artefakt}}
$$

$$
\boxed{\text{vollständige Spezifikation} \quad \neq \quad \text{lokale Ausführung} \quad \neq \quad \text{revisionssicher beglaubigter Freeze}}
$$

$$
\boxed{\text{B2 Cutoff-Audit} \;\neq\; \text{Collatz-Beweis}}
$$

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cutoff-Audits; physischer Bamberg-Terminalauszug; revisionssichere Freeze-Attestation; Freigabe von Schicht B3 (Fano-/Inzidenz-Kopplung); dass die Definition des B1-Here-Docs bereits B2-Beglaubigung wäre.

**Attestation:** Nur der **unedierte Bamberg-Terminal-Paste** der unten stehenden Befehlskette zählt als Beglaubigung. Agenten-IDs, Agentenberichte und Agenten-Smoke-Tests sind **keine** Commits und **keine** Beglaubigung. Ein lokaler oder Agenten-Lauf von `B1_SANITY` ist **kein** Bamberg-Evidenznachweis.

---

## Bindender Status (Schicht B2)

```yaml
status: "Schicht B2 vollständig spezifiziert; Git-Verankerung und materielle
         Beglaubigung ausstehend. Ein ununterbrochener, automatisierter B1-Sanity-Check
         über ein Here-Doc-Muster wurde erfolgreich definiert. Schicht B3 bleibt blockiert."
```

Das mathematische und kombinatorische Skelett von Schicht B2 ist vollständig spezifiziert. Der B1-Sanity-Gatekeeper ist als kopierbares Here-Doc archiviert. Offen bleiben Git-Verankerung im Sinne der Bamberg-Attestation und materielle Beglaubigung (Pytest, `-O`-Diff, Hashes). **Kein** Collatz-Beweis. **B3 bleibt blockiert.**

---

## B1-Sanity-Check (Here-Doc-Gatekeeper)

**Zweck:** Operationeller Vorabtest der B1-Kombinatorik (`P ∈ {4,6}`): Cutoff-Größe \(2^P-1\), genau ein singulärer Zustand \(j=p\) pro Ebene, sichtbare Bewertung im erlaubten Bereich, Singular-Split \(\{p,p+1\}\), Dynamikziele im Universum bei \(j<p\), Lift-Zählungen (internal/boundary).  

**Härte:** Kein ungenutzter `Cylinder`-Import; bei Abweichung sofort `raise SystemExit("B1_SANITY FAILED: ...")`; bei vollem Pass genau eine Zeile `B1_SANITY: PASSED` und Exit 0.

**Erste Amtshandlung (macOS-Shell, Repo-Root):**

```bash
PYTHONPATH=. python <<'PY'
"""B1 sanity gatekeeper (Schicht B1): hard SystemExit on mismatch."""
from __future__ import annotations

from mathdictate.bigraded_cylinder_graph import (
    audit_cylinder_cutoff,
    complete_cutoff,
    compute_visible_valuation,
)


def fail(msg: str) -> None:
    raise SystemExit(f"B1_SANITY FAILED: {msg}")


def check_precision(P: int) -> None:
    cylinders = complete_cutoff(P)
    expected_states = (1 << P) - 1
    if len(cylinders) != expected_states:
        fail(f"cutoff size for P={P}: got {len(cylinders)}, expected {expected_states}")

    universe_keys = {(c.residue, c.precision) for c in cylinders}
    singular_by_p: dict[int, object] = {}
    internal_lifts = 0
    boundary_lifts = 0

    for c in cylinders:
        j = compute_visible_valuation(c.residue, c.precision)
        if not (1 <= j <= c.precision):
            fail(f"visible valuation out of range at r={c.residue} p={c.precision}: j={j}")

        if j < c.precision:
            next_p = c.precision - j
            next_r = ((3 * c.residue + 1) // (1 << j)) % (1 << next_p)
            target = (next_r, next_p)
            if target not in universe_keys:
                fail(f"dynamics target missing: ({c.residue},{c.precision}) -> {target}")
        else:
            if c.precision in singular_by_p:
                fail(f"more than one singular j=p on level p={c.precision}")
            singular_by_p[c.precision] = c
            r0, p = c.residue, c.precision
            j1 = compute_visible_valuation(r0, p + 1)
            j2 = compute_visible_valuation(r0 + (1 << p), p + 1)
            if {j1, j2} != {p, p + 1}:
                fail(f"singular split at p={p} r={r0}: got {{{j1},{j2}}}")

        for lift_r in (c.residue, c.residue + (1 << c.precision)):
            in_universe = (lift_r, c.precision + 1) in universe_keys
            expected_boundary = c.precision == P
            if in_universe == expected_boundary:
                fail(
                    f"lift boundary class at r={c.residue} p={c.precision} "
                    f"lift_r={lift_r}: in_universe={in_universe} "
                    f"expected_boundary={expected_boundary}"
                )
            if expected_boundary:
                boundary_lifts += 1
            else:
                internal_lifts += 1

    for p in range(1, P + 1):
        if p not in singular_by_p:
            fail(f"missing singular j=p on level p={p}")

    if internal_lifts != (1 << P) - 2:
        fail(f"internal lifts P={P}: got {internal_lifts}, expected {(1 << P) - 2}")
    if boundary_lifts != (1 << P):
        fail(f"boundary lifts P={P}: got {boundary_lifts}, expected {1 << P}")

    _, _, report = audit_cylinder_cutoff(cylinders)
    if report.state_count != expected_states:
        fail(f"auditor state_count P={P}: {report.state_count}")
    if report.internal_lift_edges != (1 << P) - 2:
        fail(f"auditor internal lifts P={P}: {report.internal_lift_edges}")
    if report.boundary_lift_edges != (1 << P):
        fail(f"auditor boundary lifts P={P}: {report.boundary_lift_edges}")
    if report.singular_split_verified_count != P:
        fail(
            f"auditor singular_split_verified_count P={P}: "
            f"{report.singular_split_verified_count}"
        )
    for p in range(1, P + 1):
        if report.lift_required_by_precision.get(p) != 1:
            fail(
                f"auditor singular count on p={p}: "
                f"{report.lift_required_by_precision.get(p)}"
            )


for P in (4, 6):
    check_precision(P)

print("B1_SANITY: PASSED")
PY
```

Optional äquivalent: `PYTHONPATH=. python scripts/b1_cylinder_sanity.py` (ersetzt **nicht** das Here-Doc in diesem Archiv).

Hinweis: Definition und erfolgreicher Agenten-Smoke ≠ Bamberg-Evidenz. Der Nutzer muss den Lauf lokal ausführen und den uneditierten Terminalauszug liefern.

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

Nach dem B1-Here-Doc: zusammenhängender **physischer** Terminalnachweis (Bamberg) der B2-Kette — nicht nur eine Agentenmeldung. Vom Repo-Root:

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
B1_SANITY Here-Doc defined ≠ B2 attested
Precisions: 4, 6, 8, 10, 12 (default --max-precisions)
B3 (Fano/Inzidenz) blocked until B2 closed by physical Bamberg attestation
≠ Collatz proof
≠ automated agent report as attestation
≠ revisionssicher beglaubigter Freeze
```
