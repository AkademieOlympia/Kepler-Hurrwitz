# Evidence Register — narrative Dokumentation

Das vollständige maschinenlesbare Register liegt in [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md) und [`EVIDENCE_REGISTER.json`](../EVIDENCE_REGISTER.json). Diese Datei enthält narrative Register-Einträge und ausführlichere Kontextdokumentation zu ausgewählten Evidenz-IDs.

---

## E-073 — HoTT Identity Layer

* **Status:** `[C]` (Conceptual / Grundlagenhypothese)
* **Verweis:** [`KeplerHurwitz/HoTTIdentityLayer.lean`](../KeplerHurwitz/HoTTIdentityLayer.lean)
* **Dossier:** [`docs/hott_identity_layer.md`](hott_identity_layer.md)
* **Registerzeile:** [`EVIDENCE_REGISTER.md`](../EVIDENCE_REGISTER.md) (E-073)
* **Logische Anbindung:** Ergänzt E-053 (Dedekind–Hasse), baut auf E-067–E-069 (Dedekind Ideal Layer / Defekt-Klassen) auf und korrespondiert mit E-072 (EABC-Kanal-Partition mod 12).

> **ID-Hinweis:** Die Ausarbeitung führte diesen Layer als „E-067 HoTT“; nach Renumberierung der Dedekind-Ideal-Schicht (E-067–E-069) ist **E-073** die aktuelle Register-ID. E-073 ist **Anschlussraum**, kein Ersatz für E-067–E-069.

### Beschreibung

Modellierung der arithmetischen Unit-Migration und der geometrischen Asymmetrien nicht als numerische Unschärfe, sondern als formale Schnittstelle zu höheren Identitätstypen (∞-Groupoids). Dieser Eintrag etabliert ein kontrolliertes Interface für Konzepte der Homotopietypentheorie (HoTT) und univalenter Grundlagen innerhalb des quaternionischen Primzahlmodells, ohne die konstruktiven Schranken von Standard-Lean 4 zu überschreiten.

### Kernkomponenten des Interfaces

1. **`PathWitness` / `migration_path` (Unit-Migration):** Die Pfad-Typfamilie `PathWitness x y` modelliert HoTT-Pfadtypen (`Path A a b`); `migration_path` postuliert explizite Pfadzeugen (1-Zellen), wenn `y` aus `x` durch Einheitenmigration entsteht — stärkster Kern, aber **kein Identitätskollaps** (`x = y`) und kein abgeleiteter HoTT-Satz in Standard-Lean 4.

2. **`IdealUnivalence` (Univalenz-Schnittstelle):** Dokumentiert ein **univalentes Zielbild** — wann Identität strukturierter Idealtypen und strukturelle Äquivalenz **zusammenfallen könnten** (HoTT: Univalenz als **Äquivalenz** zwischen Identität und Äquivalenz, nicht bloße Implikation $A \simeq B \Rightarrow A = B$). Im Repo nur als **optionales Axiom/Marker** (`IdealUnivalenceHypothesis`, `IdealUnivalenceAxiom`), **nicht** als Lean-Theorem oder Voevodsky-Postulat formalisiert. Strukturelle Chiralität (E-068) blockiert den univalenten Kollaps und wird als topologische Obstruktion im höheren Identitätstyp sichtbar.

3. **`defect_repair_path` (HIT-Modellskizze):** Simuliert das Verhalten Höherer Induktiver Typen (HITs) für die Dedekind-Hasse-Defekte in nicht-euklidischen Ordnungen (`DH_QuatPath_H17`, `DH_QuatPath_H713`). Der geometrische Gitterdefekt wird als topologischer Verbindungspfad im Typzeitsystem skizziert — Modellskizze/Postulat, **kein nativer HIT** in Lean 4.

4. **`period_equiv_zmod12` (Fundamentalperiode):** **Hypothesenfeld** — gewählte Modellierung der Fundamentalperiode als `≃ ZMod 12`. Das ist **nicht** die Homotopieaussage π₁ ≃ Z/12Z; die π₁-Interpretation bleibt **separates Hypotheseninterface** (`EabcMod12Pi1Hypothesis`), nicht bewiesen. Die endliche Kanalabbildung `{1,5,7,11}` aus E-072 (`EabcMod12ChannelMapping`) ist ein Schnittstellen-Check — **keine** Homotopieaussage.

### Lean-Governance & Systemgrenzen

* **Kein HoTT-Beweissystem:** Standard-Lean 4 wird explizit *nicht* als univalentes HoTT-System deklariert. Alle homotopischen und HIT-artigen Strukturen sind als nicht-bewiesene Hypothesenfelder, Schnittstellen oder Modelleigenschaften isoliert.
* **Endliche Verifikation:** Bestehende, konstruktive Gitter-Prüfungen (`hott_identity_layer_status`, `eabcMod12ChannelMapping_holds`, `unitMigrationPaths_distinct_targets`) bleiben von dieser konzeptionellen Erweiterung unberührt und werden nicht künstlich aufgebläht — 0 `sorry`; `lake build KeplerHurwitz.HoTTIdentityLayer` grün.
* **Nicht behauptet:** HoTT beweist nicht EABC-Isotropierestauration, Dumas (E-048) oder Dedekind-PID (E-053). `period_equiv_zmod12` modelliert Fundamentalperiode, nicht π₁ ≃ Z/12Z. `IdealUnivalence*` ist Zielbild-Marker, kein Voevodsky-Axiom. E-072-Kanalabbildung ≠ Homotopieaussage. `IdealPathsAsDH_QuatCells` und `Mod12ToIdealChiralityBridge` sind offen.

> **Registerschlusssatz:**  
> E-073 schließt keine HoTT-Theorie ab, sondern öffnet eine kontrollierte Schnittstelle: Alles, was später topologisch, univalent oder HIT-artig formalisiert werden könnte, ist hier als explizite Hypothese sichtbar gemacht — ohne die bestehenden Lean-Beweise aufzublähen oder zu überdeuten.
