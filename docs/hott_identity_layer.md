# HoTT Identity Layer — konzeptionelles Interface [C] (E-073)

**Evidenz:** `[C]` Grundlagenhypothese · **Lean-Label:** E-073 · **Register:** E-073  
**Quelle:** `KeplerHurwitz/HoTTIdentityLayer.lean`  
**Register-Dokumentation:** [`docs/evidence_register.md`](evidence_register.md)  
**Abhängigkeiten:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-072 (mod-12-Kanalpartition)

> **ID-Hinweis:** Die Ausarbeitung führte diesen Layer als „E-067 HoTT“; nach Renumberierung der
> Dedekind-Ideal-Schicht (E-067–E-069) ist **E-073** die aktuelle Register-ID.
> E-067 (`DedekindIdealLayer`) bleibt die algebraische Ideal-Schicht; **E-073 ist Anschlussraum**,
> kein Ersatz für E-067–E-069 — hier docken spätere HoTT-/Topologie-Hypothesen an.

## Was dieses Modul ist — und was nicht

| | |
|---|---|
| **Ist** | Saubere Schnittstelle für Unit-Migration, Chiralität, mod-12-Periodik und Dedekind–Hasse-Defekte als **explizite Hypothesenfelder** |
| **Ist nicht** | Eine HoTT-Implementierung in Standard-Lean 4 |
| **Ist nicht** | Ein Beweis von π₁ ≃ Z/12Z, Univalenz für Ideale oder echten Higher Inductive Types |
| **Ist nicht** | Ersatz für die Dedekind-Ideal-Schicht E-067–E-069 |

### Lean 4 vs HoTT vs Coq-HoTT

| System | Grundlagen | Univalenz / HITs |
|---|---|---|
| **Lean 4** (dieses Repo) | Calculus of Constructions mit Universen und induktiven Typen | **Nicht** nativ; verwandt mit HoTT, aber nicht identisch |
| **Lean 2 HoTT** | Historisches HoTT-Experiment | Veraltet; nicht Basis dieses Repos |
| **Coq-HoTT** | Univalent Foundations | Traditionell stärker für Univalenz und Higher Inductive Types |

Standard-Lean/mathlib wird hier **nicht** als univalente HoTT-Grundlage verwendet.
Alle identitätsrelevanten Aussagen erscheinen als **Felder** in `HoTT_EABC_Interface`.

## Paradigmenwechsel (Zielbild, nicht implementiert)

| Ebene | Klassisch (ZFC-Stil) | HoTT / Univalent (Ziel) |
|---|---|---|
| Identität | `a = b` als boolesche Gleichheit | Pfad-Typ `Path A a b` |
| Äquivalenz | Bijektion / Isomorphismus | `A ≃ B` mit Univalenz |
| Einheiten | Assoziativität als Axiom | Pfade in ∞-Groupoid |
| Chiralität | Asymmetrie als Metrik | Obstruktion gegen Identitätskollaps |

HoTT liefert ein **fruchtbares Interpretationsbild** für das quaternionische Primzahlmodell —
ohne vollständige Cubical/HoTT-Formalisation in diesem Repo.

## Zentrales Interface

```lean
structure HoTT_EABC_Interface where
  QuatSpace : Type u
  FundamentalPeriod : Type v
  period_equiv_zmod12 : FundamentalPeriod ≃ ZMod 12
    -- Hypothesenfeld: gewählte Modellierung der Fundamentalperiode
    -- NICHT die Homotopieaussage π₁ ≃ Z/12Z
  Unit : Type w
  unit_act : QuatSpace → Unit → QuatSpace
  migrates : QuatSpace → QuatSpace → Prop
  PathWitness : QuatSpace → QuatSpace → Type   -- Pfad-Typfamilie (HoTT: Path A a b)
  migration_path : ∀ x y, migrates x y → PathWitness x y
    -- stärkster Kern: postuliert Pfadzeugen, nicht x = y
  Ideal : Type z
  leftIdeal : QuatSpace → Ideal
  rightIdeal : QuatSpace → Ideal
  chirality_obstruction : QuatSpace → Prop
  hasse_defect : QuatSpace → QuatSpace → Prop
  defect_repair_path : ∀ x y, hasse_defect x y → x = y  -- HIT-Reparatur als Postulat
```

## Schichten

| Schicht | Symbole | Status |
|---|---|---|
| **Unit-Migration** (stärkster Kern) | `PathWitness`, `migration_path`, `UnitMigrationPath`, `UnitChainEquivalence` | `[C]` Hypothese (Pfadzeuge, kein abgeleiteter HoTT-Satz) |
| Ideal-Univalenz | `IdealUnivalenceHypothesis`, `IdealUnivalenceAxiom` (Marker) | `[C]` optionales Axiom/Feld |
| DH_Quat HIT-Stub | `DH_QuatPoint`, `DH_QuatPath_H17`, `DH_QuatPath_H713` | `[C]` Modellskizze |
| mod 12 / π₁ | `period_equiv_zmod12` (Modellierung), `EabcMod12Pi1Hypothesis` (π₁ separat) | `[C]` Hypothesenfelder |
| Brücke Ideal → HoTT | `IdealPathsAsDH_QuatCells`, `Mod12ToIdealChiralityBridge` | `[C]` offen |

## Kernkonzepte

### 1. Unit-Migration — stärkster Kern

Assoziierte Quaternionen werden über die Einheitenaktion `unit_act` verbunden.
Das Hypothesenfeld `migration_path` **postuliert einen Pfadzeugen** (`PathWitness x y`),
wenn `y` aus `x` durch Einheitenmigration entsteht.

In HoTT ist der Pfad selbst Information — **nicht** bloße Gleichmachung (`x = y`).
`migration_path` ist der stärkste Kern des Interfaces, aber **kein abgeleiteter HoTT-Satz**
in Standard-Lean 4.

Schnittstellenmarker `UnitMigrationPath` und `UnitChainEquivalence` dokumentieren das
1-Zellen-/2-Zellen-Bild. Brücke zu E-067:
`unitMigrationFromPrincipalLeft` / `unitMigrationFromPrincipalRight`.

**Bewiesen (endlicher Check):** links/rechts-Migration hat verschiedene Ziele
(`unitMigrationPaths_distinct_targets`).

### 2. Ideal-Univalenz — optionales Axiom, kein Lean-Theorem

`IdealUnivalenceHypothesis` und der Prop-Marker `IdealUnivalenceAxiom` dokumentieren das
Univalenz-Bild für Ideale: strukturelle Äquivalenz links/rechts soll Identität implizieren.

Bei genuiner Chiralität blockiert Asymmetrie den Kollaps (`IdealChiralityBlocksUnivalence` → E-068).

**Nicht behauptet:** kein Univalence-Axiom aus HoTT/Coq-HoTT formalisiert oder bewiesen.

### 3. DH_Quat — HIT-Reparatur als Modellskizze

Typ `DH_Quat` mit Pfad-Konstruktoren für geometrische „Löcher“:

- `Q(√-7)` → `DH_QuatPath_H17` (Ordnung `H_{1,7}`)
- `Q(√-13)` → `DH_QuatPath_H713` (Ordnung `H_{7,13}`)

Das Feld `defect_repair_path` in `HoTT_EABC_Interface` modelliert die Reparatur als Postulat.
Echte HITs sind in Standard-Lean 4 **nicht** nativ verfügbar.

### 4. mod 12 / π₁ — getrennte Hypothesenfelder

| Symbol | Rolle |
|---|---|
| `period_equiv_zmod12` | **Hypothesenfeld:** gewählte Modellierung der Fundamentalperiode als `≃ ZMod 12` — **nicht** π₁ ≃ Z/12Z |
| `EabcMod12Pi1Hypothesis` | **Separates** Prop-Marker-Interface für die π₁-Interpretation |
| `EabcMod12ChannelMapping` | **Bewiesen:** vier Restklassen `{1,5,7,11}` mappen auf EABC-Kanäle (E-072) |

Die endliche Kanalabbildung ist ein Schnittstellen-Check — **kein** Beweis der
Homotopiegruppe π₁ ≃ Z/12Z.

## Bewiesen in Lean (endliche Schnittstellen-Checks)

- `eabcMod12ChannelMapping_holds` — vier Restklassen mappen auf EABC-Kanäle
- `unitMigrationPaths_distinct_targets` — links/rechts-Migration hat verschiedene Ziele
- `hott_identity_layer_status` — Status-Bündel ohne `sorry`, ohne HoTT-Theoreme

## Governance — Nicht behauptet

- **E-073 ist Anschlussraum**, kein Ersatz für E-067–E-069 (Dedekind-Ideal-Schicht).
- **Lean 4 ≠ HoTT mit Univalenz** — Coq-HoTT wäre für echte Univalenz/HITs traditionell stärker.
- HoTT **beweist nicht** EABC-Isotropierestauration, Dumas (E-048) oder Dedekind-PID (E-053).
- **`migration_path`** postuliert Pfadzeugen — stärkster Kern, aber **kein abgeleiteter HoTT-Satz**.
- **`period_equiv_zmod12`** ist Modellierung der Fundamentalperiode — **nicht** π₁ ≃ Z/12Z.
- **π₁ ≃ Z/12Z** (`EabcMod12Pi1Hypothesis`) ist separates Hypotheseninterface, keine bewiesene Homotopiegruppe.
- **Univalenz für Ideale** ist optionales Axiom/Feld, kein Lean-Theorem.
- **HIT-Reparatur** (`defect_repair_path`) ist Modellskizze/Postulat, kein nativer HIT.
- `IdealPathsAsDH_QuatCells` und `Mod12ToIdealChiralityBridge` sind **offen**.
- Keine formalen HoTT-Beweise in Standard-Lean behauptet.

### Externe Referenzen (Referenzrahmen, nicht implementiert)

> Diese Quellen definieren den **externen Referenzrahmen** für HoTT-Begriffe in E-073
> (Univalenz, HITs, Pfad-Identität). Sie sind **nicht** implementiert, importiert oder
> formal verwendet in diesem Repo — kein Ersatz für die Governance-Hinweise oben.

| Referenz | Link | Rolle im Referenzrahmen |
|---|---|---|
| **HoTT Book** | [homotopytypetheory.org/book](https://homotopytypetheory.org/book/) | Grundlegende Univalent Foundations; Begriffsrahmen für Pfad-Typen und `A ≃ B` |
| **Coq-HoTT** | [github.com/HoTT/Coq-HoTT](https://github.com/HoTT/Coq-HoTT) | Traditionelle HoTT-Bibliothek für Univalenz und HITs — **Referenz**, nicht Basis dieses Repos |
| **Lean 2 HoTT** | [lean2/hott](https://github.com/leanprover/lean2/tree/master/hott) | Historisches Lean-HoTT-Experiment; veraltet, nicht Lean 4 |
| **nLab: Lean** | [nLab/Lean](https://ncatlab.org/nlab/show/Lean) | Dokumentiert: **Lean 4 ≠ HoTT mit Univalenz** |
| **nLab: Univalenzaxiom** | [nLab/univalence+axiom](https://ncatlab.org/nlab/show/univalence+axiom) | Begriffsrahmen für `IdealUnivalenceHypothesis` (Hypothesenfeld, kein Theorem) |
| **nLab: Higher Inductive Types** | [nLab/higher+inductive+type](https://ncatlab.org/nlab/show/higher+inductive+type) | Begriffsrahmen für `DH_Quat`-Modellskizze und `defect_repair_path` (Postulat, kein nativer HIT) |

**Build:** `lake build KeplerHurwitz.HoTTIdentityLayer`

## Verwandte Einträge

| ID | Inhalt |
|---|---|
| E-053 | Dedekind–Hasse ↔ Dumas methodische Schnittstelle |
| E-067–E-069 | Dedekind-Ideal-Schicht (Pfade, Chiralität, Obstruktion) |
| E-072 | EABC-Kanal-Partition mod 12 |

## Registersatz (E-073)

> E-073 schließt keine HoTT-Theorie ab, sondern öffnet eine kontrollierte Schnittstelle: Alles, was später topologisch, univalent oder HIT-artig formalisiert werden könnte, ist hier als explizite Hypothese sichtbar gemacht — ohne die bestehenden Lean-Beweise aufzublähen oder zu überdeuten.
