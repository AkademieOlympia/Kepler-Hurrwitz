# Open Research Questions

Dieses Dokument ist der **Kurz-Index** offener Forschungsfragen und ORQ-IDs.

**Kanonischer Katalog (Governance, Prioritäten, Abhängigkeiten):** [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md)

Es enthält bewusst keine Behauptungen über bereits gesicherte Resultate.

**Konvention:** `ORQ-xxx` = interne Open-Research-Question-ID (Fragestellung);
`E-xxx` = Evidenzregister-Eintrag in [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md).

---

## Formale Dynamik und Attraktorik

- Existiert ein natuerliches Lyapunov-Funktional fuer `oddCore`-basierte Dynamik?
- Laesst sich Retraktion in eine kategorientheoretische Charakterisierung uebersetzen?
- Gibt es eine intrinsische Automorphismengruppe des EABC-Zustandsraums?

## Defekt- und Spektralstruktur

- Besitzt der Defektoperator eine kanonische Spektralzerlegung?
- Existiert ein natuerlicher Holonomiebegriff fuer diskrete EABC-Orbits?
- Welche minimalen Annahmen reichen fuer ein globales Coverage-Lemma (`E-009`)?

## Thermodynamische Strukturfragen (L4 -> C/B/A)

- Gibt es einen wohldefinierten Zustandssummenoperator fuer endliche EABC-Spektren?
- Welche Spektralparameter sind fuer robuste Entropie-Schaetzungen stabil?
- Wann sind thermodynamische Groessen reine Reparametrisierungen vorhandener Observablen?

## Bulk-Boundary / Rekonstruktion

- Lassen sich Bulk-/Boundary-Projektionen formal definieren?
- Welche Randinvarianten beschraenken innere Freiheitsgrade minimal?
- Gibt es eine diskrete Rekonstruktionsabbildung mit wohldefinierter Fehlerschranke?

## Korrelation und Nichtfaktorisierbarkeit

- Existieren nichtfaktorisierbare EABC-Korrelationen in kanonischer Modellklasse?
- Lässt sich ein Bell-typisches Testfunktional als diskrete Operatorform definieren?
- Welche Transfer-/Labelkanaele bewahren rekonstruktive Information?

## Projekt „Die drei Musketiere“ (E-026)

- Existiert in jedem Bremensaal ein Nachbar-Dreier der drei uebrigen EABC-Familien?
- Unter welchen Annahmen ist die Musketiere-Nachbar-Relation objektiv (chi-Aequivalenz / `LabelPreservingGraphMap`)?
- Welche `A5`-Orbits der 6 scheiternden toy-Embeddings liegen ausserhalb des kanonischen Partitionsmusters (`E-028`)?

## Fixed-Locus / Riemann-Programm (L4)

### ORQ-087: Fixed-Locus Nullstellen-Konfinierung via SDTC

- **Kontext:** Involutive Selbstdualität \(D(s)=1-\bar{s}\); Lokations-Aussage \(\sigma=\tfrac{1}{2}\) als Fixpunkt-Locus; programmatischer HoTT-Anschluss (Identitätstyp \(D(z)\equiv z\)).
- **Kernfrage:** Lässt sich die Abweichung einer Nullstelle von der kritischen Linie als anti-invarianter spektraler Operator \(\mathcal{A}\) so darstellen, dass *Self-Dual Trace Confinement (SDTC)* eine spurlos gegen Null konvergierende Dominanz erzwingt?
- **Status:** `[C / programmatisch-offen]` — kein Register-Upgrade ohne explizite Operator-Brücke.
- **Abhängigkeiten:** Lean-Stufe 3 (abstraktes Symmetrie-Skelett); blockiert nicht den Daten-Kanonisierungs-Branch `extract-energiedoku-shell-coordinates-n1-n3`.
- **Gegen-Evidenz:** E-034 (`[C]` refuted) — Kosinus-Mittelung über \(\Delta M\) erzeugt keine Trennschärfe; E-035 (`[C]` open_hypothesis) — Skalenpfad offen.
- **Dossier:** [`theory/fixed_locus_riemann_program.md`](theory/fixed_locus_riemann_program.md)

---

## ORQ-Index: Bridge Targets (priorisiert)

Vollstaendige Statements, Governance-Tabelle und Durchbruchspfad: [`open_mathematical_bridge_targets.md`](open_mathematical_bridge_targets.md).

| Prio | ORQ | Kurztitel | E-ID | Status |
|---|---|---|---|---|
| 1 | ORQ-077 | `MetricSeparationLossExist` | E-077 | `[C]` → `[B]`-Ziel |
| 2 | ORQ-078 | Globale R³-Einbettung | E-078 | `[C]` |
| 3 | ORQ-079 | Minkowski–Bouligand | E-079 | `[C]` |
| 4 | ORQ-085 | Dedekind $\Phi(v)=\gamma$ | E-067–E-069 | `[C]` |
| 5 | ORQ-083 | Berry-Holonomie | E-083 | `[C]` |
| 6 | ORQ-084 | `GeometryScaffold` | E-084 | `[C]` |
| 7 | ORQ-080 | Hurwitz-Windungs-Monopol | E-080 | `[C]` |
| 8 | ORQ-081 | Dirac–Schwinger emergent | E-081 | `[C]` |
| 8 | ORQ-082 | Dipol/Oktupol-Monopol | E-082 | `[C]` |
| 9 | ORQ-086 | `shellPrimeMatchAtFirstLoss` | E-085 | `[C]` GATE INACTIVE / PRE-REGISTRATION NOT COMPLETE (→ Protokoll Pre-Registration Gate) |

**Shell-Separationsdiagnostik (E-077–E-079):** Mess-Schicht `[C]` — [`reports/shell_separation_diagnostics_protocol.md`](reports/shell_separation_diagnostics_protocol.md) · CSV via `scripts/shell_separation_diagnostics.py`

**Meissner (E-076):** Interpretive Lesesprache nur fuer ORQ-077 — siehe [`theory/meissner_analogy_assessment.md`](theory/meissner_analogy_assessment.md).
