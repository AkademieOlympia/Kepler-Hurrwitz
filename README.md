# Kepler-Hurrwitz

Formaler Unterbau fuer EABC mit Hurwitz-Primzahlen, metakommutativen Orbits und Kepler-Invarianten.

## Ziel

Dieses Projekt entwickelt eine mathematisch belastbare Anschlussstruktur:

\[
\text{Hurwitz-Primzahlen}
\rightarrow
\text{Quaternionen-Arithmetik}
\rightarrow
\text{Permutation/Orbitstruktur}
\rightarrow
\text{Vorzeichen/Chiralitaet}.
\]

Kernidee:

\[
\boxed{
\text{EABC-Defekte werden als metakommutative Hurwitz-Prime-Orbits modelliert.}
}
\]

## Startpunkte

- `docs/grundgedanken.md`: formale Definitionen und Hypothesen
- `docs/arbeitsprogramm.md`: konkrete naechste Schritte und Validierung

## Minimaler Scope (v0)

1. EABC-Signatur als orientierte Hurwitz-Signatur \(\mathcal H(n)\) definieren
2. Doppelkegel-Projektion und Kegelschnitt-Klassifikation praezisieren
3. Kepler-Invarianten \(\kappa(n)\) konsistent herleiten
4. Metakommutation \(PQ=Q'P'\) als Defekt-Operator formal einbauen

## Hinweis zum Anspruch

Der Ansatz liefert einen formalen Rahmen fuer Chiralitaet, Orbitstruktur und diskrete Holonomie im EABC-Kontext.  
Er ist **kein** unmittelbarer Beweis fuer 24I\(_3\)-Restauration, Collatz oder RH.

## Langfristiger Programmrahmen (L4)

Das Projekt untersucht, ob sich die im formalen Kern entwickelten diskreten
Operator- und Geometriemodelle langfristig als mathematische Sprache fuer
Phaenomene eignen, die heute in unterschiedlichen physikalischen Theorien
(beispielsweise QED, QCD oder kosmologischen Modellen) beschrieben werden.

Diese Zielrichtung dient der Forschungsorientierung und stellt ausdruecklich
keine Aussage ueber eine bereits etablierte physikalische Beschreibung oder
Herleitung dieser Theorien dar.

Strukturelle Motivation:
Das Projekt uebernimmt die mathematische Trennung zwischen
Verbindungsstruktur, Defekt/Kruemmungsstruktur und Observablen als
Arbeitssprache. Diese Uebernahme ist rein methodisch und keine
physikalische Identifikation.

Zur strukturellen Rollenklassifikation (orthogonal zu Evidenzklassen) siehe
`docs/layer_taxonomy.md`.

Holographisches Strukturmotiv (L4):
Das Projekt untersucht programmatisch, ob sich Bulk/Boundary-Ideen als
mathematische Kodierungsfrage formulieren lassen
(`Volumen -> Oberflaeche -> Randinvariante -> rekonstruierbare Innenstruktur`).
Das ist ausdruecklich **kein** Claim einer realisierten AdS/CFT-Physik.
Details: `docs/l4_holography_structural_inspiration.md`.

Thermodynamisches Strukturmotiv (L4):
Das Projekt nutzt thermodynamische Begriffe zunaechst als mathematische
Metasprache fuer Spektren, Zustandssummen, Dichten und Skalenfluesse.
Dies ist ausdruecklich kein Herleitungsanspruch physikalischer Konstanten
innerhalb des EABC-Modells.
Details: `docs/l4_thermodynamic_structural_inspiration.md`.

Quantengravitative Strukturmotive (L4):
Stringtheorie und Loop Quantum Gravity werden ausschliesslich als
mathematische Inspirationsquellen fuer Dualitaet, Projektion und diskrete
Graphgeometrie genutzt.
Details: `docs/l4_quantum_gravity_structural_inspiration.md`.

Quanteninformations-Strukturmotive (L4):
Bell-/Teleportationskonzepte werden als mathematische Inspirationsquelle fuer
Korrelation, Nicht-Faktorisierbarkeit, Basisprojektion und Rekonstruktion
genutzt (ohne physikalische EABC-Identifikation).
Details: `docs/l4_quantum_information_structural_inspiration.md`.

QFT-Symmetriestruktur (L4):
Gruppenwirkungen, Operatorik und invariante Unterraeume werden als
mathematische Sprache genutzt (ohne physikalischen Ableitungsclaim).
Details: `docs/l4_qft_symmetry_structural_inspiration.md`.

Die uebergeordnete L4-Strukturkarte steht in:
`docs/l4_structural_map.md`.
Einheitlicher Meta-Rahmen: `docs/l4_unified_structural_framework.md`.  
Begriffsnormierung: `docs/l4_glossary.md`.

L4-Referenzmatrix: `docs/l4_reference_matrix.md`.  
Offene Forschungsfragen: `docs/open_research_questions.md`.  
Projektweites Begriffslexikon: `docs/glossary.md`.
Forschungslandkarte (Ideenkategorien): `docs/research_map.md`.

## Evidenzregeln pro Ebene

| Ebene | Inhalt | Aenderungsregel |
|---|---|---|
| `[A]` | Formale Definitionen und Theoreme (Lean) | Nur durch Beweis |
| `[B]` | Reproduzierbare numerische Experimente | Nur durch reproduzierbare Daten |
| `[C]` | Offene mathematische Hypothesen und Interfaces | Explizit als offen gekennzeichnet |
| `L4` | Programmatische und physikalische Interpretation | Darf keine Aussagen der Ebenen `[A]-[C]` veraendern |

Zentrale Aussagen und ihr Reifegrad werden im `EVIDENCE_REGISTER.md` gefuehrt.
Die maschinenlesbare Spiegelung liegt in `EVIDENCE_REGISTER.json`.
Strukturentscheidungen und ihre Begruendung stehen in `DECISIONS.md`.

## Embedding Audit Pipeline

Schalen-Einbettungen werden nicht an Rohkoordinaten, sondern an geometrischen Invarianten
(sep, overlap, Distanz-/Gram-Spektrum, Procrustes) geprueft — siehe
[`docs/reports/EMBEDDING_AUDIT_PIPELINE.md`](docs/reports/EMBEDDING_AUDIT_PIPELINE.md).

| Schritt | Status |
|---|---|
| Detector-Controls | DONE |
| Energiedoku-Koordinaten n=1,2,3 | DONE (CSV 84 rows) |
| Embedding-Audit-Code + Audit run | DONE |
| ι_n-Revision n≥2 | **NEXT** |
| ε_n-Schaerfung | PENDING |

Audit laeuft scharf gegen `docs/energiedoku_exports/shell_coordinates_energiedoku_n1_n3.csv`.
Schnellstart: `PYTHONPATH=src python scripts/shell_embedding_geometry_audit.py --n-max 3`
