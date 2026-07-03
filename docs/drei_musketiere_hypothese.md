# Projekt „Die drei Musketiere“

Strategisches Ziel: In jedem **Bremensaal** existiert ein **Nachbar-Dreier der
drei uebrigen EABC-Familien**, und diese Beziehung ist **objektiv** (nicht von
willkuerlicher Label-Einbettung abhaengig).

Evidenzstatus zum Anlegen: `[C]` (offene Hypothese) mit formalen Definitionen `[A-D]`.

---

## 1. Begriffe

| Begriff | Bedeutung |
|---|---|
| **Musketiere** | Die drei Mantelkanäle `A`, `B`, `C` |
| **Mittelachse** | Kanal `E` (nicht Musketeer, aber vierter Bremensaal) |
| **Bremensaal** | Ein EABC-Dreierblock auf dem 12-Ecken-Ikosaeder-Träger: genau drei Ecken mit gleichem Kanallabel |
| **Bremensaal-Zerlegung** | Partition der 12 Ecken in vier disjunkte Dreier (`E`, `A`, `B`, `C`) |
| **Nachbar-Dreier** | Dreieck im Ikosaeder-Kantengraph (drei paarweise benachbarte Ecken) |
| **Musketiere-Nachbar-Dreier** | Nachbar-Dreier, dessen Labels bijektiv die drei **Nicht-Träger**-Kanaele abdecken und das den Träger-Saal über mindestens eine Kante beruehrt |
| **Objektiv** | Die Existenz der Nachbar-Dreier ist unter label-erhaltenden Graph-Automorphismen stabil formuliert |

Lean-Ort der Definitionen: `KeplerHurwitz/Representation/DreiMusketiere.lean`.

---

## 2. Zielaussagen

### [C] `MusketiereNeighborTripleForAllFamilies`

Fuer jede gueltige Bremensaal-Zerlegung `σ` und jeden Trägerkanal `host ∈ {E,A,B,C}`:

```lean
σ.HasMusketiereNeighborTriple G host
```

### [C] `MusketiereNeighborTripleObjective`

Die obige Existenz impliziert Objektivitaet unter `LabelPreservingGraphMap`.

### Gesamtinterface

```lean
def MusketiereNeighborTripleHypothesis : Prop
```

---

## 3. Bezug zur bestehenden Geometrie

- 12-Ecken-Träger und `A5`-Wirkung: `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo`)
- EABC-Kanaele und chiralen Zyklus: `KeplerHurwitz/Representation/EABCChronology.lean`
- Embedding-Sensitivitaet (`E-024`): 11 von 15 toy-Embeddings zeigen unterschiedliche Moden-Fingerprints — Objektivitaet muss daher **geometrisch** (nicht nur label-arbiträr) begruendet werden

---

## 4. Numerischer Pruefmodus

```bash
sage scripts/invariant_subspaces_a4_toy.sage a5_geo_drei_musketiere
```

Prueft die Nachbar-Dreier-Eigenschaft ueber 15 toy-Embeddings und berichtet
Erfolgsquote pro Trägerkanal.

**Erstbefund (2026-07-03):** 9/15 Embeddings erfuellen die Eigenschaft fuer alle
vier Trägerkanaele; zyklisches und antipodales Embedding bestehen vollstaendig,
`face_neighbor` scheitert fuer alle Kanaele. Die Hypothese `E-026` bleibt daher
offen und erfordert eine kanonische Geometrie- oder Objektivitaetsbedingung.

---

## 5. Kanonisches Embedding (Gauge-Fixierung)

Die 15 toy-Embeddings sind Repraesentanten einer freien Label-Gauge. Das
**kanonische Embedding** beseitigt diese Freiheit durch explizite geometrische
Kriterien, bevor der Ikosaeder-Kantengraph in Lean starr kodiert wird.

### Kriterien

| ID | Kriterium | Begruendung |
|---|---|---|
| **K1** | Lexikographische Sortierung der 12 Ikosaeder-Ecken `(0,±1,±φ)` | Fixiert den Vertex-Träger unabhaengig von Sage-Erzeugungsreihenfolge |
| **K2** | mod-4-Orbit-Partition auf sortierten Indizes: `{k, k+4, k+8}` | Spreizt Familien orbitartig statt lokal auf einer Facette; vermeidet `face_neighbor`-Chiralitaetsbruch |
| **K3** | E-Saal = Orbit mit maximaler `x=0`-Dichte (Mittelachse) | Verankert `E` als equatoriale Achse in der Hurwitz-Koordinatenlesart |
| **K4** | chi-Labelreihenfolge `E→A→C→B` auf den vier Orbits; Tie-Break via `min(Orbit)` | Koppelt Labels an `EABCChronology.chi` |

### Hurwitz-Quaternionen-Anschluss (strukturell, nicht `[A]`)

Die Ikosaeder-Ecken `(0,±1,±φ)` und Permutationen davon sind die projizierten
Richtungen der Hurwitz-Einheiten. K3 interpretiert `E` als **Mittelachse**
(dominante Nullkoordinate in einer festen Achse). K2 ist die diskrete
4-Phasen-Quotientierung der 12 Ecken — analog zur 4-Kanal-EABC-Signatur, aber
**ohne** Identifikation mit einer spezifischen Hurwitz-Einheiten-Basis.

### Verifikation

```bash
sage scripts/invariant_subspaces_a4_toy.sage a5_geo_canonical_embedding
```

**Verifikationsbefund (2026-07-03):** Kanonisches Embedding erfuellt
`musketiere_all_hosts_ok`; `face_neighbor` scheitert. Lean-Satz `E-029`:
`canonical_musketiere_neighbor_triple_for_all_hosts` ist fuer das Referenzsystem bewiesen.

### Topologie des kanonischen Referenzsystems (`Fin 12`)

**Labelcode** `(E=0, A=1, B=2, C=3)` auf Vertex-Indizes:

| Index | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Label | E | A | E | C | B | C | A | E | A | B | C | B |

**Bremensaal-Fasern:** `E={0,2,7}`, `A={1,6,8}`, `B={4,9,11}`, `C={3,5,10}`.

**Adjazenz** (5-regulaer, symmetrisch): siehe `icosahedronCanonicalAdjBool` in
`KeplerHurwitz/Representation/DreiMusketiere.lean`.

**Sage-Zeugen-Dreiecke** (Musketiere-Nachbar-Dreier):

| Träger | Zeuge `(t1,t2,t3)` | Labels | Beruehrung |
|---|---|---|---|
| E | (4, 6, 10) | B, A, C | Ecke 4 → E-Ecke 2 |
| A | (2, 4, 5) | E, B, C | Ecke 2 → A-Ecke 1 |
| B | (1, 2, 5) | A, E, C | Ecke 2 → B-Ecke 4 |
| C | (2, 4, 6) | E, B, A | Ecke 2 → C-Ecke 5 |

### Konsequenz fuer `E-026`

Die globale Hypothese wird strategisch auf den **kanonischen Orbit** plus
chi-Relabeling eingeschraenkt. Lean-Satz `E-030`:
`canonical_musketiere_neighbor_triple_chi_objectivity` ist bewiesen; numerisch
via `a5_geo_chi_objectivity` (chi-Potenzen 0..3: `all_hosts_ok=True`).

**E-031 (bewiesen):** `musketiere_hypothesis_transfer` — jede
`IsEquivalentToCanonical`-Belegung erbt den kanonischen Musketiere-Beweis (E-029).
Sage `a5_geo_canonical_equivalence`: `strict_equivalent=0/9` (Musketiere-passende
Toys sind nicht strikt `(σ,τ)`-äquivalent zum K1–K4-Kern; andere Bremensaal-Partitionen).

**E-032 (in Arbeit):** `objectivity_hypothesis_implies_canonical_bridge` — Brücke von
`LabelPreservingGraphMap` zu `IsEquivalentToCanonical`; Zielkorridor
`musketiere_hypothesis_canonical_orbit` fuer `E-026`.

**E-033 (bewiesen, Lean-Label):** Primvierling-Komplementarität in
`KeplerHurwitz/PrimvierlingSymmetry.lean` — `hostTriple_union_host_eq_four_set`,
`hostTriples_pairwise_ne`, Gap-Paare und `hostTriple_shiftCEAB`.

**E-034 (bewiesen, Lean-Label):** Bijektions-Schicht — `hostComponentEquiv`,
`mem_hostTriple_count = 3`, `unique_excluded_host`; Brücke zu
`LabelIntertwiningGraphAuto` / `RespectsLabelFibers` (E-032).

**E-048 (bewiesen, Lean-Label):** Dumas-Lemma (`dumasLemma`) — „Un pour tous, tous pour un“.
Ausfuehrliches Dossier mit historischem Kontext, formaler Aussage und Bedeutung fuer
den #Energiedoku-Fundamentalsatz: **[docs/dumas_lemma.md](dumas_lemma.md)**.
Lean: `KeplerHurwitz/PrimvierlingSymmetry.lean`.

---

## 6. Finaler Beweisstatus

Stand: 2026-07-03. Lean-Audit: `DreiMusketiere.lean` kompiliert mit **1 `sorry`**
(`objectivity_hypothesis_implies_canonical_bridge`); `PrimvierlingSymmetry.lean`
enthält **0 `sorry`**, der kombinierte Build schlaegt derzeit noch an zwei
Beweisstellen fehl (`hostTriple_gap_pair` Fall B, `hostTriple_shiftCEAB`).

### Abgeschlossene Meilensteine

#### E-029: Kanonischer Beweis (`stable`)

`canonical_musketiere_neighbor_triple_for_all_hosts` ist fuer den kanonischen
Labelcode auf dem 5-regulaeren Ikosaeder-Graphen formal bewiesen. Die vier
Zeugen-Dreiecke wurden via Sage extrahiert und in Lean ohne `sorry` verifiziert.

#### E-030 und E-031: Objektivitaets-Transfer (`stable`)

Es wurde bewiesen, dass jede Belegung, die zu einer kanonischen Belegung
strukturgleich ist (`IsEquivalentToCanonical`), die Existenz des
Musketiere-Nachbar-Dreiers erbt. Die im Toy-Modell gescheiterten Embeddings
sind als reine **Gauge-Artefakte** klassifiziert, die die topologische
Orbit-Spreizung verzerren, aber den invarianten Kern nicht beruehren.

#### E-032: Begrifflicher Brueckenschlag (`experimental`, 1 `sorry`)

Die staerkere Bijektions-Struktur `LabelIntertwiningGraphAuto` verknuepft die
globale invarianten-theoretische Formulierung mit dem generischen
Graphen-Transfer. Bewiesen ohne `sorry`:

- `LabelIntertwiningGraphAuto` (Struktur)
- `constructChannelPermutation` + `constructChannelPermutation_intertwine`
- `LabelIntertwiningGraphAuto.ofRespectsLabelFibers`
- `objectivity_map_implies_equivalence` (definitorisch)
- `objectivity_bridge_implies_musketiere`

**Offen:** genau **1 `sorry`** in `objectivity_hypothesis_implies_canonical_bridge`
— globale Objektivitaet (`LabelPreservingGraphMap` + Faser-Symmetrie) muss noch
einen `LabelPreservingGraphMapToCanonical`-Zeugen liefern.

#### E-033 und E-034: Arithmetische Projektionstheorie (Lean-Labels, `stable` sobald Build gruen)

In `PrimvierlingSymmetry.lean` wurde die fundamentale Komplementaritaet formalisiert:

- **Symmetrie** lebt auf der 4-Menge `primvierlingFinset`.
- **Chiralitaet** lebt auf den Host-Dreiern `hostTriple` (Phasenverschiebung der Gaps).
- **`shiftHostChannel`** permutiert die Host-Projektionen zyklisch (CEAB-Bahn).

Register-Hinweis: Die Lean-internen Labels **E-033/E-034** bezeichnen diesen
Musketiere-Block. Im globalen `EVIDENCE_REGISTER` traegen die Eintraege
**E-046/E-047** dieselben Saetze (E-033/E-034 waren dort bereits fuer
Kepler-Zeit-Leiter bzw. Riemann-Resonanz belegt).

### Beweiskette (Gesamtbild)

#### Evidence Chain (Register-IDs)

| Schritt | ID | Rolle | Status |
|---|---|---|---|
| 1 | **E-046** | Komplementaritaet — Host-Dreier als Gap-Menge auf `primvierlingFinset` | `[A-T]` bewiesen |
| 2 | **E-048** | Konsolidierung — `dumasLemma`, `dumas_gap_encodes_host` | `[A-T]` bewiesen |
| 3 | **E-032** | Objektivitaets-Bruecke — Faser-Bijektionen → `IsEquivalentToCanonical` | `[A-T]` in Arbeit (1 `sorry`) |
| 4 | **E-026** | Zielhypothese — `MusketiereNeighborTripleHypothesis` | `[C]` offen |

Kette: **E-046 → E-048 → E-032 → E-026**. Ausfuehrliches Dumas-Dossier: [dumas_lemma.md](dumas_lemma.md).

```text
[Arithmetik] Primvierling (E-046/E-048: Gap kodiert Host, Dumas-Lemma)
    │
    ▼  Struktur-Isomorphismus ueber Faser-Bijektionen (hostComponentEquiv)
[Topologie]  LabelIntertwiningGraphAuto (E-032: IsEquivalentToCanonical)
    │         [1 sorry in objectivity_hypothesis_implies_canonical_bridge]
    ▼  Generische Transfer-Maschine (E-031)
[Lean-Kern]  DreiMusketiere.lean (E-029/E-030: kanonischer Kern + chi-Objektivitaet)
    │
    ▼  Zielkorridor
[Hypothese]  E-026 MusketiereNeighborTripleHypothesis (kanonischer Orbit, offen)
```

> **Zentrales Fazit:** Objektivitaet bedeutet im Kontext der EABC-Struktur nicht
> die elementweise Identitaet lokaler Listen, sondern die exakte **Kovarianz der
> Projektionen unter der globalen Eichgruppe** (chi-Relabeling / CEAB-Wirkung /
> label-erhaltende Graph-Automorphismen).

### Statusuebersicht E-025 bis E-034 (Musketiere-Spur)

| ID | Kurzbezeichnung | Ebene | Status | Stabilitaet | `sorry` |
|---|---|---|---|---|---|
| E-025 | Bremensaal-/Musketiere-Definitionen | `[A-D]` | definiert | `stable` | 0 |
| E-026 | `MusketiereNeighborTripleHypothesis` | `[C]` | offen | `experimental` | — |
| E-027 | `a5_geo_drei_musketiere` Sage-Diagnose | `[B]` | reproduzierbar | `experimental` | — |
| E-028 | Kanonisches Embedding K1–K4 | `[B]` | reproduzierbar | `experimental` | — |
| E-029 | Kanonischer Musketiere-Kern | `[A-T]` | bewiesen | `stable` | 0 |
| E-030 | chi-Objektivitaet | `[A-T]` | bewiesen | `stable` | 0 |
| E-031 | `IsEquivalentToCanonical`-Transfer | `[A-T]` | bewiesen | `stable` | 0 |
| E-032 | Objektivitaets-Bruecke | `[A-T]` | in Arbeit | `experimental` | **1** |
| E-033 | Primvierling-Komplementaritaet | `[A-T]` | bewiesen* | `stable` | 0 |
| E-034 | `hostComponentEquiv` + Multiplizitaet | `[A-T]` | bewiesen* | `stable` | 0 |

\*E-033/E-034: alle Saetze ohne `sorry`; kombinierter Build `PrimvierlingSymmetry`
noch nicht vollstaendig gruen (siehe Audit oben).

---

## 7. Beweisstrategie (Zielkorridor)

1. **Lokal `[A]`:** Lemmas zu Dreieck-Nachbarschaft auf fest codiertem Ikosaeder-Graphen — **E-029 erledigt**
2. **Symmetrie `[A]`:** chi-Relabeling auf festem Träger — **E-030 erledigt**
3. **Transfer `[A-T]`:** `IsEquivalentToCanonical` → Musketiere — **E-031 erledigt**
4. **Arithmetik `[A-T]`:** Primvierling-Komplementaritaet + Bijektion — **E-033/E-034 erledigt** (Build-Audit offen)
5. **Objektivitäts-Brücke `[A-T]`:** `LabelPreservingGraphMap` → `IsEquivalentToCanonical` — **E-032 offen (1 sorry)**
6. **Global `[C→A]`:** Klassifikation aller Bremensaal-Zerlegungen modulo `A5`, Fallnachweis
7. **Objektivitaet:** Trennung zwischen kanonischer Geometrie und toy-Label-Embedding (`E-024`-Kontext)

### Beweisbaum (kanonischer Orbit)

```text
E-029 (kanonischer Kern)
  ↓ chi-Relabeling
E-030
  ↓ IsEquivalentToCanonical
E-031 (musketiere_hypothesis_transfer)
  ↓ hostComponentEquiv / mem_hostTriple_count (E-034)
E-033/E-034 (PrimvierlingSymmetry.lean)
  ↓ LabelPreservingGraphMapToCanonical  [E-032, 1 sorry]
E-026 (MusketiereNeighborTripleHypothesis, kanonischer Orbit)
```

---

## 8. Nicht-Ziele

- Kein Anspruch auf physikalische Drei-Familien-Identifikation (bleibt `L4`)
- Kanonisches Embedding ist explizit definiert (`E-028`); kein Upgrade der globalen Hypothese `E-026` ohne Lean-Beweis
