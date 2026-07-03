# Architektur-Spiegelung: Symmetrie & Invarianten (OrbitSymmetry)
Dieses Dokument spiegelt die formalen Garantien aus den Lean-Modulen `KeplerHurwitz.PrimvierlingSymmetry` und `KeplerHurwitz.CyclicWordOrbit` in lesbarer Form. Es dokumentiert, wie das EABC-Programm Symmetrie als dynamische Operation nutzt, um Suchraeume zu reduzieren und algebraische Erhaltungssaetze zu sichern.
---
## 1) Die Primvierling-Ebene (`KeplerHurwitz.PrimvierlingSymmetry`)
Ein Primvierling wird strukturell als vierdimensionales Tupel `(a, b, c, e)` betrachtet. Statt einer starren Reihenfolge operiert auf diesem Objekt eine zyklische Transformationsstruktur.
* **Kern-Operation (`shiftCEAB`):** Die Transformation vertauscht die Bloecke paarweise: `(a, b, c, e) -> (c, e, a, b)`.
* **Geometrische Garantie (`shiftCEAB_involutive`):** Die Operation ist involutiv. Zweimaliges Anwenden fuehrt exakt zum Ausgangszustand zurueck (`g^2 = Id`).
* **Orbit (`orbitCEAB`):** Die Menge aller Zustaende, die ein Vierling unter dieser Symmetrie einnehmen kann.
### Zertifizierte Invarianten (konstant auf der gesamten Bahn)
* **`pairGapsInt` (geometrischer Diagonalabstand):** Der Ausdruck `(a-c)^2 + (b-e)^2` bleibt unter `shiftCEAB` invariant.
* **`quatNorm` (quaternionische Feld-Norm):** Die Gesamtnorm `a^2 + b^2 + c^2 + e^2` bleibt invariant und stuetzt die Interpretation als globale Erhaltungsgroesse.
> ⚠️ **Symmetriebruch auf Komponentenebene:** `firstComponent` ist *nicht* invariant. Das zeigt formal, dass die tragende Struktur im EABC-Modell in globalen Relationen liegt, nicht in einzelnen Komponenten.

### Dumas-Lemma (E-048)

Das **Dumas-Lemma** (`dumasLemma`) buendelt die Host-Komplementaritaet (E-033/E-046)
und die Bijektions-Schicht (E-034/E-047) unter dem Motto *Un pour tous, tous pour un*:
Jeder der vier Kanaele sieht genau die drei uebrigen Primzahlkomponenten (`hostTriple`),
jede Komponente liegt in genau drei Host-Dreiern (`mem_hostTriple_count`), und
`hostComponentEquiv` identifiziert Hosts bijektiv mit Komponenten. Das Korollar
`dumasLemma_otherChannels_card` verknuepft diese arithmetische Struktur mit
`otherChannels` aus `DreiMusketiere.lean`. Ausfuehrliches Dossier:
[docs/dumas_lemma.md](dumas_lemma.md).
---
## 2) Die Collatz-Wort-Ebene (`KeplerHurwitz.CyclicWordOrbit`)
Fuer die kombinatorische Analyse von Zyklusmustern wird die Symmetrie auf Woerter (Listen) uebertragen.
* **Transformation (`rotateLeft`):** Zyklischer Links-Shift, z. B. `1011 -> 0111`.
* **Aequivalenzrelation (`CyclicEquivalent`):** Zwei Woerter sind strukturell identisch, wenn sie durch endlich viele Rotationen ineinander ueberfuehrt werden koennen.
* **Formale Eigenschaften in Lean:**
  * `cyclicEquivalent_refl`: Reflexivitaet
  * `cyclicEquivalent_trans`: Transitivitaet
* **Algorithmischer Zugriff (`orbitPrefix`):** Liefert berechenbare Anfangssegmente von Wort-Bahnen.
### Praktischer Nutzen fuer die Filterpipeline
Ein periodisches Muster ist unabhaengig vom Einstiegspunkt. Deshalb muss in der Pipeline nicht jedes Wort einzeln geprueft werden: Es reicht ein **Repraesentant pro Orbitklasse**. Das reduziert den Suchraum deutlich und bleibt durch die formale Lean-Schicht mathematisch konsistent.
---
## Verweis auf die formale Quelle
Der narrative Einstieg liegt in `KeplerHurwitz/README_OrbitSymmetry.lean`. Dort sind die zentralen Typen, Operationen und Saetze per `#check` ausfuehrbar dokumentiert.
