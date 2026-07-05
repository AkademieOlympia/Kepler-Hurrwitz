# Research Map

Diese Karte ordnet neue Ideen in genau eine inhaltliche Kategorie ein.
Sie ist orthogonal zu den Evidenzklassen `[A]/[B]/[C]/L4`.

## Kategorien

| Kategorie | Bedeutung | Typischer Zielzustand |
|---|---|---|
| Definition | neue formale Begriffsbildung | `A-D` oder vorbereitend fuer `A-T` |
| Theorem | formal bewiesene Aussage | `A-T` |
| Numerik | reproduzierbare experimentelle Auswertung | `[B]` |
| Hypothese | offene mathematische Behauptung | `[C]` |
| Interpretation | programmatischer Strukturrahmen | `L4` |

## Einordnungsregel

Jede neue Projektidee wird primaer in **eine** Kategorie eingeordnet.
Falls mehrere Rollen entstehen, werden sie in getrennte Eintraege zerlegt.

Beispiel:
- formale Definition eines Operators -> `Definition`
- numerischer Scan des Operators -> `Numerik`
- offene globale Aussage ueber den Operator -> `Hypothese`

---

## Registrierte offene Bridge Targets (priorisiert, 2026-07-05)

**Kanonischer Katalog:** [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md)  
**ORQ-Kurzindex:** [`open_research_questions.md`](open_research_questions.md)

| Prio | Cluster | ORQ | E-ID | Research Map |
|---|---|---|---|---|
| 1 | Metrischer Separationsverlust | ORQ-077 | E-077 | Hypothese → `[B]`-Ziel |
| 2 | Globale R³-Einbettung | ORQ-078 | E-078 | Hypothese |
| 3 | Minkowski–Bouligand-Dimension | ORQ-079 | E-079 | Hypothese → Numerik |
| 4 | Dedekind $\Phi(v)=\gamma$ | ORQ-085 | E-067–E-069 | Hypothese |
| 5 | Berry-Holonomie | ORQ-083 | E-083 | Hypothese |
| 6 | GeometryScaffold (4 euklidische Saetze) | ORQ-084 | E-084 | Hypothese |
| 7 | Hurwitz-Windungs-Monopol | ORQ-080 | E-080 | Hypothese |
| 8 | Dirac–Schwinger emergent | ORQ-081 | E-081 | Interpretation / Hypothese |
| 8 | Dipol/Oktupol-Monopol | ORQ-082 | E-082 | Interpretation / Hypothese |
| 9 | shellPrimeMatchAtFirstLoss | ORQ-086 | E-085 | Hypothese (GATE INACTIVE / PRE-REGISTRATION NOT COMPLETE → Protokoll) |

**Shell-Separationsdiagnostik (E-077–E-079):** Kategorie `Numerik` (diagnostisch, `[C]`) — [`reports/shell_separation_diagnostics_protocol.md`](reports/shell_separation_diagnostics_protocol.md) · `scripts/shell_separation_diagnostics.py`

**Embedding-Audit-Pipeline (canonical vs. Energiedoku, n≤3):** [`reports/EMBEDDING_AUDIT_PIPELINE.md`](reports/EMBEDDING_AUDIT_PIPELINE.md) · Schritt 4 (ι_n-Audit n≥2) **NEXT**

**Minimaler Durchbruchspfad:** Schale → Separation → erster Verlust → Dimension → Primindex-Test — siehe kanonisches Dokument.

**Physik-Analogien (Interpretation, kein Theorem):** E-076 → Kategorie `Interpretation` / `[C]`-Dossier — siehe [`theory/README.md`](theory/README.md). Meissner nur als Lesesprache fuer E-077: [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).

**Metrische Vorlaeufer:** [`eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md) §8–9, §14 (E-053).
