# Governance Decisions

Dieses Dokument protokolliert projektweite, langlebige Entscheidungen.
Es beantwortet die Frage: **Warum wurde eine Strukturentscheidung getroffen?**

## ADR-001: Evidenzebenen A/B/C/L4

- **Status:** Accepted
- **Datum:** 2026-07-02
- **Entscheidung:** Einfuehrung der Ebenen `[A]`, `[B]`, `[C]`, `L4` als
  verbindliche Trennschicht fuer Beweise, Numerik, Hypothesen und Interpretation.
- **Begruendung:** Vermeidung der Vermischung von formalen Aussagen,
  numerischer Evidenz und programmatischer Deutung.

## ADR-002: Negative Ergebnisse bleiben dokumentiert

- **Status:** Accepted
- **Datum:** 2026-07-02
- **Entscheidung:** Negative Resultate werden dauerhaft in Doku/Artefakten
  erhalten und nicht stillschweigend entfernt.
- **Begruendung:** Negative Evidenz ist Teil des wissenschaftlichen Ergebnisses
  und reduziert Fehlinterpretationen in spaeteren Zyklen.

## ADR-003: Physikalische Aussagen nur in L4

- **Status:** Accepted
- **Datum:** 2026-07-02
- **Entscheidung:** Physikalische Bezugnahmen werden ausschliesslich auf Ebene
  `L4` gefuehrt; sie duerfen keine Evidenzklassifikation in `[A]/[B]/[C]`
  ersetzen oder implizit aufwerten.
- **Begruendung:** Schutz vor semantischem Ebenenvermischen und unbelegten
  Evidenzspruengen.

## ADR-004: Build-Target-Konvention fuer Lean-Dateien

- **Status:** Accepted
- **Datum:** 2026-07-02
- **Entscheidung:** Fuer gezielte Lean-Builds wird der vollqualifizierte
  Lake-Modulname verwendet.
  - Beispiel: `lake build KeplerHurwitz.Collatz.CkA.OrbitSmoothBridge`
  - Nicht bevorzugt: `lake build Collatz.CkA.OrbitSmoothBridge`
- **Begruendung:** Die Repo-Struktur fuehrt Module unter dem Praefix
  `KeplerHurwitz`; vollqualifizierte Targets vermeiden Mehrdeutigkeiten und
  verbessern die Reproduzierbarkeit in CI und Dokumentation.

## ADR-005: Evidence Register Audit in CI

- **Status:** Accepted
- **Datum:** 2026-07-02
- **Context:** Das Projekt pflegt ein maschinenlesbares und ein
  menschenlesbares Evidence-Register. Um Drift zwischen Lean-Symbolen,
  Dokumentation, JSON-Eintraegen und Markdown-Tabellen zu vermeiden, muss das
  Register automatisiert geprueft werden.
- **Decision:** Ein minimaler, CI-kompatibler Audit laeuft auf jedem Push und
  jedem Pull Request. Der Audit prueft eindeutige IDs, bekannte
  Evidence-Levels, Dateireferenzen, optionalen Symbolvorkommens-Check und die
  Konsistenz zwischen `EVIDENCE_REGISTER.md` und `EVIDENCE_REGISTER.json`.
- **Consequences:** Die Evidenzschicht wird Teil des
  Reproduzierbarkeitsvertrags. Neue formale oder empirische Aussagen muessen
  konsistent registriert werden; veraltete oder aspirative Eintraege werden
  frueh erkannt.

## Pflege

- Neue Entscheidungen fortlaufend als `ADR-XXX` ergaenzen.
- Jede Entscheidung enthaelt mindestens `Status`, `Datum`, `Entscheidung`,
  `Begruendung`.
