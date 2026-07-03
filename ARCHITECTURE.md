# Kepler-Hurrwitz Architecture (v1.0 Zielbild)

Dieses Dokument beschreibt die geschichtete Evidenzarchitektur des Projekts.
Es trennt bewusst zwischen formalen Beweisen, empirischer Validierung,
offenen Hypothesen und Interpretation.

## Schichtenmodell

- `L1 / [A]`: Formale Definitionen und Lean-Theoreme (maschinell verifiziert)
- `L2 / [B]`: Reproduzierbare numerische Experimente (Python/Sage)
- `L3 / [C]`: Offene Bridge-Interfaces und Strukturhypothesen
- `L4`: Konzeptionelle/physikalische Interpretation (explizit getrennt)

## Architekturfluss

```text
                +-----------------------+
                |   Lean Core [A]       |
                +-----------+-----------+
                            |
            ----------------+----------------
            |                               |
            v                               v
       Geometry Layer [A]            Collatz Layer [A]
            |                               |
            +---------------+---------------+
                            |
                            v
                  Bridge Interfaces [C]
                            |
                            v
                Python Validation [B]
                            |
                            v
                   Interpretation [L4]
```

## Modulmatrix

| Modul | Aufgabe | Evidenz |
|---|---|---|
| `KeplerHurwitz/Core.lean` | zentraler Lean-Einstieg und Modulbündel | `[A]` |
| `KeplerHurwitz/SmoothAttraktor.lean` | Attraktor-Definitionen (`IsBSmooth`, `IsSmoothAttraktor`) | `[A]` |
| `KeplerHurwitz/SymbolicResultants.lean` | formale Spiegelung der Sage-Resultanten, Interferenztyp | `[A]` |
| `KeplerHurwitz/InterferenceAttraktorBridge.lean` | defensive Bridge-Schnittstelle (`InterferenceSelectsB11`) | `[C]` |
| `src/kepler_hurwitz/sage_bridge.py` | symbolische Sage-Eliminierung, Resultantenexport | `[B]` |
| `src/kepler_hurwitz/interference_attraktor_bridge.py` | empirischer Bridge-Test (`Interference -> Restklassen -> B11`) | `[B]` |
| `tests/` | Regressions- und Integritätstests für Python/Sage-Interfaces | `[A]/[B]` |
| `docs/` | Forschungslogik, Evidenzklassifikation, Interpretation | `[L4]` |

## Reproduzierbarkeit (Kurzbefehle)

- Python-Tests: `pytest`
- Lean-Build: `lake build KeplerHurwitz`
- Registry-Validation + Evidenzgraph: `python scripts/validate_registry.py --registry EVIDENCE_REGISTER.json --out-dir results`
- Sage-Symbolik: `sage -python examples/run_sage_bridge.py --json --out docs/energiedoku_exports/sage_symbolic_constraints.json`
- Energiedoku-Exporte: `python examples/export_energiedoku_artifacts.py`

## Defensivregeln

- Keine Hypothese wird als Theorem ausgegeben, solange kein Lean-Beweis vorliegt.
- Offene Brücken bleiben als Interface markiert (`[C]`), nicht als Axiom verschleiert.
- Empirische Evidenz (`[B]`) ist reproduzierbar, aber nicht formal beweisgleich.
- Interpretation (`L4`) bleibt getrennt von Beweis- und Datenebene.
- Zentrale Aussagen werden mit ID im `EVIDENCE_REGISTER.md` gefuehrt.
- Strukturentscheidungen und ihre Begruendung werden in `DECISIONS.md` gepflegt.

Prinzip der strukturellen Sparsamkeit:
Neue Definitionen, Operatoren oder Hypothesen werden nur eingefuehrt, wenn sie
mindestens eine der folgenden Bedingungen erfuellen:
1. sie ermoeglichen einen bestehenden formalen Satz,
2. sie erzeugen reproduzierbare numerische Vorhersagen,
3. sie vereinigen mehrere bestehende Strukturen unter einem gemeinsamen Rahmen.

## L4-Ankerbild (Projektbeschreibung)

Langfristiger Programmrahmen (`L4`):
Das Projekt untersucht, ob sich die im formalen Kern entwickelten diskreten
Operator- und Geometriemodelle langfristig als mathematische Sprache fuer
Phaenomene eignen, die heute in unterschiedlichen physikalischen Theorien
(beispielsweise QED, QCD oder kosmologischen Modellen) beschrieben werden.
Diese Zielrichtung dient der Forschungsorientierung und stellt ausdruecklich
keine Aussage ueber eine bereits etablierte physikalische Beschreibung oder
Herleitung dieser Theorien dar.

Folgende Themen gelten als Zielraum fuer kuenftige Modellierungsarbeit:

- Dunkle Energie,
- Dunkle Materie,
- Proton/Elektron-Massenverhaeltnis,
- Drei-Familien-Struktur.

Der methodische Vertrag bleibt:
Interpretation darf motivieren, aber nur Evidenz in `[A]/[B]/[C]` zaehlt als
technischer Projektstatus.

Methodischer Vertrag:
Alle physikalischen Bezuege werden ausschliesslich auf Ebene `L4` gefuehrt.
Aenderungen an `L4` duerfen weder den Wahrheitsgehalt noch die
Evidenzklassifikation der Ebenen `[A]`, `[B]` oder `[C]` beeinflussen.
Umgekehrt duerfen formale oder numerische Ergebnisse nur dann in `L4`
uebernommen werden, wenn ihr Geltungsbereich und ihre Voraussetzungen
explizit dokumentiert sind.

L4-Prinzip der Nichtidentifikation:
Eine strukturelle Aehnlichkeit zu einer etablierten Theorie begruendet weder
mathematische Aequivalenz noch physikalische Identitaet. Jede L4-Analogie
dient ausschliesslich als Heuristik zur Entwicklung neuer Definitionen,
Theoreme oder numerischer Experimente. Nur Ergebnisse auf `[A]`, `[B]` oder
`[C]` koennen den wissenschaftlichen Status des Projekts veraendern.

## Structural Inspiration (L4)

Als strukturelle Orientierung (nicht als Evidenz) nutzt das Projekt die
mathematische Trennung von Verbindungsstruktur, Krummungsstruktur und
Observablen, wie sie in Eichtheorien exemplarisch sichtbar wird.

| Physik (strukturell) | EABC-Strukturebene |
|---|---|
| Verbindung `A` | Uebergangsoperator / Transportregel |
| Kruemmung `F` | Defektoperator / Umlaufdefekt |
| Holonomie | Orbit-/Interferenzinvariante |
| Eichinvarianz | Gruppeninvarianz |
| Observable | Spektrum, IPR, Defektgewicht |

Diese Analogien dienen ausschliesslich der mathematischen Orientierung.
Sie begruenden keine physikalische Identifikation und keine neue
Evidenzstufe.

## Holographic Structural Inspiration (L4)

Holographie wird als Strukturprinzip gelesen:
Volumeninformation kann auf Rand-/Oberflaechenfreiheitsgrade projiziert werden
(`Boundary Encoding`).

Wichtige Abgrenzung:
Diese Bezuge sind programmatische Strukturmotive. Sie stellen **keine**
Behauptung dar, dass EABC eine AdS/CFT-Dualitaet realisiert oder eine
etablierte Quantengravitationstheorie ersetzt.

### Struktur-Mapping (motivisch)

| Holographie / AdS-CFT | EABC-Struktur |
|---|---|
| Bulk | innerer Zustandsraum / Normschalen |
| Boundary | Rand-/Oberflaechenkanaele |
| CFT-Daten | diskrete Observablen / Signaturen |
| Radiale Richtung | Skalen-/Schalenrichtung |
| RG-Fluss | Renormierungskette / Retraktion |
| Entanglement-Wedge | rekonstruierbarer Teilraum aus Randdaten |
| Holographisches Prinzip | Informationsreduktion auf Randinvarianten |

### Leitfrage

Als L4-Arbeitshypothese wird geprueft, ob ein 8-dimensionaler
Signaturraum als bulk-artiger Traegerraum gelesen werden kann, dessen
zulaessige Dichten/Zustaende durch Randbedingungen eingeschraenkt werden.

Das ist eine Strukturfrage, keine Physik-Identifikation.
Vertiefung: `docs/l4_holography_structural_inspiration.md`.

## Thermodynamic Structural Inspiration (L4)

Das Projekt untersucht thermodynamische Begriffe zunaechst als mathematische
Organisationssprache fuer Spektren, Zustandsraeume, Dichten und Skalenfluesse.

Wichtige Abgrenzung:
Begriffe wie Temperatur, Entropie, freie Energie oder Referenzkonstanten
werden auf dieser Ebene nicht als physikalisch hergeleitete Groessen des
EABC-Modells beansprucht, sondern als Strukturhilfen fuer moegliche spaetere
Modellbildung.

### Strukturfluss (motivisch)

`Zustandsraum -> Spektrum -> Zustandssumme -> Temperatur/Entropie/freie Energie`

### Rollenmatrix (projektintern)

| Ebene | Bedeutung im Projekt | Evidenz |
|---|---|---|
| Spektrum | Eigenwerte diskreter Operatoren | `[A]` / `[B]` je nach Formalisierung |
| Zustandssumme | formale Groesse `Z(beta)=sum exp(-beta*E_i)` | zunaechst `[C]` oder `A-D` |
| Thermodynamik | Entropie, freie Energie, Temperatur als Strukturparameter | zunaechst `[C]` / `L4` |
| Physikalische Konstanten | `k_B`, `hbar`, `c`, `alpha`, `sigma` | ausschliesslich `L4`, solange keine Herleitung vorliegt |

### Schutzregel

Physikalische Konstanten duerfen ausserhalb von `L4` erst verwendet werden,
wenn sie als dimensionslose/normalisierte Modellparameter oder als klar
kalibrierte externe Konstanten eingefuehrt sind.

Vertiefung: `docs/l4_thermodynamic_structural_inspiration.md`.

## String Theory as Structural Inspiration (L4)

Stringtheorie wird als Strukturquelle fuer folgende Motive gelesen:

- hoeherdimensionale Zielraeume
- Dualitaeten
- Branen-/Randobjekte
- Kompaktifizierung
- Spektren aus Geometrie
- Modulraeume

Projektfrage (L4):
Wie lassen sich hoeherdimensionale Signaturraeume ueber Projektion,
Randbedingungen oder Dualitaetsideen auf beobachtbare, niedrigdimensionale
Strukturen abbilden?

## Loop Quantum Gravity as Structural Inspiration (L4)

LQG wird als Strukturquelle fuer folgende Motive gelesen:

- diskrete Geometrie
- Spin-Netzwerk-Idee
- Graphen plus Labels
- lokale Knoten / globale Netzstruktur
- Flaechen-/Volumenstruktur als diskrete Organisationsidee

Projektfrage (L4):
Wie lassen sich diskrete, gelabelte Graphstrukturen mit lokalen Operatoren so
koppeln, dass globale Invarianten, Defekte und Spektren konsistent entstehen?

Schutzsatz:
Stringtheorie und Loop Quantum Gravity werden ausschliesslich als
mathematische Inspirationsquellen genutzt. Es wird keine Identifikation des
EABC-Modells mit einer etablierten Theorie der Quantengravitation behauptet.

Vertiefung: `docs/l4_quantum_gravity_structural_inspiration.md`.

## Quantum Information Structural Inspiration (L4)

Quanteninformation wird als Strukturquelle fuer folgende Motive gelesen:

- Verschraenkung / Nicht-Faktorisierbarkeit
- Korrelationsstruktur
- Messbasis und Projektionsregeln
- klassischer Transferkanal
- Rekonstruktion aus Korrelation plus Kanalinformation

Projektfrage (L4):
Wann sind Signaturzustaende nicht als lokale Produkte beschreibbar
(`P(a,b) != P_A(a) * P_B(b)` bzw. nicht-faktorisierbare Signaturdarstellung),
und welche Rolle spielen Basisprojektion und Transferlabels fuer ihre
Rekonstruktion?

Schutzsatz:
Quantenteleportation, Bell-Ungleichungen und experimentelle Arbeiten von
Clauser, Aspect und Zeilinger werden ausschliesslich als mathematische
Strukturquellen genutzt. Es wird nicht behauptet, dass EABC
Quantenteleportation physikalisch erklaert oder daraus direkt folgt.

Vertiefung: `docs/l4_quantum_information_structural_inspiration.md`.

## QFT Symmetry Structural Inspiration (L4)

QFT-nahe Begriffe werden als mathematische Sprache fuer
Symmetrie-/Operatorstrukturen genutzt:

- Gruppenwirkung auf linearen Raeumen
- invariante Unterraeume
- sektorielle Operatorik

Diese Einordnung ist rein strukturell und kein physikalischer
Identifikationsanspruch.
Vertiefung: `docs/l4_qft_symmetry_structural_inspiration.md`.

## L4-Synthese

Die L4-Inhalte werden ueber eine gemeinsame Strukturkarte organisiert,
damit keine lose Sammlung von Analogien entsteht.
Siehe `docs/l4_structural_map.md`.
Der uebergeordnete Rahmen steht in `docs/l4_unified_structural_framework.md`,
Begriffsnormierung in `docs/l4_glossary.md`.
Schnelluebersicht je Quelle: `docs/l4_reference_matrix.md`.
Offene Fragenliste: `docs/open_research_questions.md`.

## Layer-Typisierung (Orthogonal zur Evidenz)

Zusaetzlich nutzt das Projekt eine reine Rollenklassifikation von Objekten:

- `L-Conn`: Verbindungs-/Transportstruktur
- `L-Curv`: Kruemmung/Defektstruktur
- `L-Obs`: Beobachtbare Groessen
- `L-Inv`: Invariante Struktur

Details und Beispiele stehen in `docs/layer_taxonomy.md`.
Diese Layer-Typen sind **keine** Evidenzklassen.

## Evidenz-Upgrade-Regeln

- `C -> B`: nur mit reproduzierbarer numerischer Untersuchung
  (klarer Laufweg, Datenartefakt, Reproduktionskommando).
- `B -> A`: nur mit formalem Beweis (Lean oder explizit dokumentierter
  mathematischer Beweisstandard).
- `A -> L4`: nur als Interpretation eines bereits belegten formalen Kerns.
- Keine Rueckwaertsableitung: `L4` darf niemals `A/B/C` begruenden oder ersetzen.

### Upgrade-Regeln nach A-Klasse

- `A-D -> A-T`: wenn aus einer formalen Definition ein bewiesenes Theorem folgt.
- `A-I -> A-T`: wenn eine Infrastrukturkomponente erstmals zur Herleitung
  eines konkreten formalen Satzes verwendet wird.
- `A-I` bleibt ansonsten bewusst Infrastruktur und wird nicht als
  mathematischer Theoremfortschritt verbucht.
