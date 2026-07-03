# Layer Taxonomy (Strukturell, nicht evidenziell)

Dieses Dokument fuehrt eine reine Rollenklassifikation fuer mathematische
Objekte im Projekt ein. Es ist **keine** Evidenzstufe und ersetzt nicht die
Klassen `[A]/[B]/[C]/L4`.

## Layer-Typen

| Layer | Bedeutung | Typische Beispiele |
|---|---|---|
| `L-Conn` | Verbindungs-/Transportstruktur | Uebergangsoperator, Green-Kernel, Transportregel |
| `L-Curv` | Kruemmung / Defektstruktur | Defektoperator, Umlaufdefekt, Retraktionsdefekt |
| `L-Obs` | Beobachtbare Groessen | Spektrum, IPR, PR, Defektgewicht |
| `L-Inv` | Invariante Struktur | Gruppeninvarianz, Orbitstruktur, Holonomie-Invarianten |

## Methodische Regel

- Layer-Typen beantworten die Frage: *Welche Rolle hat ein Objekt in der Architektur?*
- Evidenzklassen beantworten die Frage: *Wie gut ist eine Aussage gestuetzt?*
- Beide Achsen sind absichtlich orthogonal und duerfen nicht vermischt werden.

## Einordnung im Projekt

- `L-Conn` findet sich z. B. in Transport-/Brueckenbegriffen aus
  `PhotonModel`, `EABCLayer`, `GodelKerr`.
- `L-Curv` findet sich in Defekt-/Interferenzstrukturen aus
  `OctonionicSlice`, `InterferenceAttraktorBridge`, `KleinCollapse`.
- `L-Obs` findet sich in numerischen und spektralen Auswertungen
  (`docs/energiedoku_exports`, Python-Studien).
- `L-Inv` findet sich in Orbit- und Norminvarianzmodulen wie
  `PrimvierlingSymmetry`, `CyclicWordOrbit`, `SymbolicResultants`.

Diese Taxonomie dient ausschliesslich der strukturellen Lesbarkeit und
transportiert keine physikalische Identifikation.
