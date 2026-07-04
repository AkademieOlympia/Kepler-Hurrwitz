# Das Dumas-Lemma (Die Symmetrie der Musketiere)

**Evidenz:** `[A-T]` · **Lean-Label:** E-048 · **Register:** E-048  
**Quelle:** `KeplerHurwitz/PrimvierlingSymmetry.lean`  
**Abhaengigkeiten:** E-046 (Komplementaritaet), E-047 (Bijektion/Multiplizitaet)  
**Stuetzt:** E-032 (Objektivitaets-Bruecke), E-026 (Musketiere-Hypothese)

### Evidence Chain (Musketiere / Primvierling)

| Schritt | ID | Rolle | Status |
|---|---|---|---|
| 1 | **E-046** | Komplementaritaet — `hostTriple` als Gap-Menge, Vereinigung mit Host-Komponente | `[A-T]` bewiesen |
| 2 | **E-048** | Konsolidierung — `dumasLemma`, `dumas_gap_encodes_host` (Gap kodiert Host) | `[A-T]` bewiesen |
| 3 | **E-032** | Objektivitaets-Bruecke — `CanonicalBridgeHypothesis` → kanonischer Transfer | `[A-T]` bewiesen |
| 4 | **E-026** | Zielhypothese — `MusketiereNeighborTripleHypothesis` (kanonischer Orbit) | `[C]` offen |

Kette: **E-046 → E-048 → E-032 → E-026**. Die holographische Auslassung (`dumas_gap_encodes_host`,
Alias `holographic_omission_gap_encodes_host`) verankert Schritt 2: fehlende Komponente im
Host-Dreier identifiziert den Host.

**E-032-Update (2026-07-03):** Die Bruecke `objectivity_hypothesis_implies_canonical_bridge`
verwendet nun `CanonicalBridgeHypothesis` (existiert Faser-respektierendes `φ` oder
`IsEquivalentToCanonical`) statt der tautologischen `MusketiereNeighborTripleObjective`.
`RespectsLabelFibers` folgt nicht aus label-Erhaltung allein — explizite Annahme.

**Prägnant (#Energiedoku):** *Die Lücke im Tripel ist kein Verlust, sondern die Codierung des Hosts.*

**Paper-Zitierbare Lean-Sätze:**
- `hostTriple_membership_iff_not_host` — `x ∈ hostTriple ↔ x ∈ primvierlingFinset ∧ x ≠ hostComponent`
- `dumas_gap_encodes_host` / `holographic_omission_gap_encodes_host` — `x ∉ hostTriple ↔ x = hostComponent`

Im Kern beschreibt dieses Lemma eine perfekte, holografische Symmetrie: Jede der vier
Primzahlkomponenten uebernimmt einmal die Rolle des „D'Artagnan“ (die isolierte
Komponente), während die anderen drei als „die drei Musketiere“ (das Host-Triple) die
Einheit sichern.

---

## 1. Historischer Kontext und Namensgebung

Das Lemma ist nach **Alexandre Dumas** benannt, dem Autor der *Drei Musketiere*. Die
Wahl ist kein Zufall, sondern bildet die Kernstruktur des Romans exakt ab: Es gibt
vier Helden (Athos, Porthos, Aramis und D'Artagnan). Doch das beruehmte Motto lautet
nicht „Vier fuer alle“, sondern:

> *„Einer fuer alle, alle fuer einen.“* (Un pour tous, tous pour un)

Das mathematische Modell spiegelt dies perfekt wider: Die vier Kanaele (Hosts)
\(\{E, A, B, C\}\) koordinieren sich mit den vier Primzahlen des Vierlings
\(P(v) = \{a, b, c, e\}\), sodass zu jedem Zeitpunkt drei zusammenstehen und einer
die Bruecke schlaegt.

**Lean-Metapher:** In `DreiMusketiere.lean` sind `A`, `B`, `C` die Musketiere;
`E` ist die Mittelachse. Auf Komponentenebene entspricht `hostTriple host v` dem
Komplement der Host-Komponente in `primvierlingFinset v` — analog zu
`otherChannels host` auf Label-Ebene.

---

## 2. Formale Aussage

Sei \(v = (a, b, c, e)\) ein **Primvierling** mit paarweise verschiedenen
Komponenten (`primvierlingDistinct v`). Die Menge der beteiligten Primzahlen ist

\[
P(v) = \texttt{primvierlingFinset}(v) = \{a, b, c, e\}.
\]

Fuer jeden Host \(h \in \{E, A, B, C\}\) gilt:

\[
\texttt{hostComponent}(h, v) \in P(v), \qquad
\texttt{hostTriple}(h, v) = P(v) \setminus \{\texttt{hostComponent}(h, v)\}.
\]

Das **kombinierte Dumas-Lemma** (`dumasLemma`) fasst drei Teilaussagen in der
Struktur `Dumas_one_for_all_all_for_one` zusammen:

\[
\text{Dumas}(v) \;\equiv\; (\text{Tous pour un}) \wedge (\text{Un pour tous}) \wedge (\text{Division}).
\]

### 2.1 Tous pour un (Alle fuer einen)

Jeder Host besitzt ein exakt dreielementiges Primzahl-Triple. Zusammen mit der dem
Host zugeordneten Einzelkomponente wird die Gesamtheit aller Primzahlen rekonstruiert:

\[
\forall h:\;
|\texttt{hostTriple}(h, v)| = 3
\;\wedge\;
\texttt{hostTriple}(h, v) \cup \{\texttt{hostComponent}(h, v)\} = P(v).
\]

| Lean-Symbol | Rolle |
|---|---|
| `hostTriple_card` | Kardinalitaet \(= 3\) |
| `hostTriple_union_host_eq_four_set` | Vereinigung mit Host-Komponente \(= P(v)\) |

### 2.2 Un pour tous (Einer fuer alle)

Jede einzelne Primzahl \(x \in P(v)\) ist in exakt drei der vier Host-Triples
enthalten:

\[
\forall x \in P(v):\;
\bigl|\{ h : x \in \texttt{hostTriple}(h, v) \}\bigr| = 3.
\]

| Lean-Symbol | Rolle |
|---|---|
| `mem_hostTriple_count` | Multiplizitaet \(= 3\) |
| `unique_excluded_host` | Genau ein Host schliesst \(x\) aus |

### 2.3 Division (Bidirektionale Zerlegung)

Die Abbildung `hostComponent(·, v)` ist eine Bijektion zwischen den
EABC-Kanaelen und den Primzahlen des Vierlings. Eine Primzahl fehlt in einem
Host-Triple genau dann, wenn sie die ausgezeichnete Komponente dieses Hosts ist:

\[
\texttt{hostComponent}(\cdot, v) : \{E, A, B, C\} \xrightarrow{\sim} P(v),
\]

\[
\forall x \in P(v)\;\exists!\, h:\;
x \notin \texttt{hostTriple}(h, v)
\;\Longleftrightarrow\;
\texttt{hostComponent}(h, v) = x.
\]

| Lean-Symbol | Rolle |
|---|---|
| `hostComponentEquiv` | Kanonische Bijektion `EABCChannel ≃ {x // x ∈ P(v)}` |
| `dumasLemma_hostComponent_bij` | Alias fuer `hostComponentEquiv` im E-048-Buendel |
| `exists_unique_hostComponent` | Eindeutigkeit der Host-Zuordnung pro Komponente |
| `dumas_gap_encodes_host` | Gap kodiert Host: `x ∉ hostTriple ↔ x = hostComponent` |

### 2.4 Kombiniertes Lemma

```lean
theorem dumasLemma (v : Primvierling) (hv : primvierlingDistinct v) :
    Dumas_one_for_all_all_for_one v hv
```

Die Struktur `Dumas_one_for_all_all_for_one` buendelt alle vier Felder:
`hostTriple_card_three`, `hostTriple_union`, `mem_hostTriple_card_three`,
`unique_excluded`.

---

## 3. Musketiere-Korollar

Auf Label-Ebene (`DreiMusketiere.lean`) ist `otherChannels host` definiert als
\(\texttt{Finset.univ} \setminus \{h\}\) — die drei uebrigen EABC-Kanaele relativ
zum Traeger-Saal. Das Korollar beweist die strukturelle Isomorphie zwischen
arithmetischem Host-Dreier und geometrischem Kanal-Dreier:

\[
\forall h:\;
|\texttt{hostTriple}(h, v)| = |\texttt{otherChannels}(h)| = 3.
\]

```lean
theorem dumasLemma_otherChannels_card (host : EABCChannel) (v : Primvierling)
    (hv : primvierlingDistinct v) :
    (hostTriple host v).card = (otherChannels host).card
```

Damit ist die Kombinatorik der Raeume (`otherChannels`) und die Arithmetik der
Primzahlen (`hostTriple`) auf derselben Kardinalitaet \(3\) verankert.

---

## 4. Bedeutung fuer den Fundamentalsatz (#Energiedoku)

Warum ist dieses Lemma der kritische Dreh- und Angelpunkt fuer den Fundamentalsatz
der #Energiedoku?

1. **Verlustfreie Informationserhaltung:** Die Bijektion in der *Division*
   (`hostComponentEquiv`) garantiert, dass beim Uebergang von den vier Dimensionen
   der Quaternionen auf die einzelnen Host-Kanaele keine Information verloren geht.
   Aus der Struktur der Triples laesst sich jederzeit fehlerfrei auf die isolierte
   Komponente schliessen.

2. **Symmetriebruch ohne Chaos:** Wenn das Modell „schwingt“ oder Energie uebertraegt,
   verschiebt sich die Zuordnung. Das Dumas-Lemma sichert ab, dass dieser
   Symmetriebruch strengen Erhaltungssaetzen folgt. Wenn eine Primzahl ihre Rolle
   wechselt (vom Triple-Element zur Host-Komponente), zwingt die mathematische Logik
   (*Un pour tous*) die anderen Komponenten zu einer synchronen, komplementaeren
   Bewegung.

3. **Dualitaet von Raum und Zahl:** Das Korollar `dumasLemma_otherChannels_card`
   schlaegt die Bruecke zwischen der Kombinatorik der Raeume (`otherChannels`) und
   der Arithmetik der Primzahlen (`hostTriple`). Die vier fundamentalen Dimensionen
   des Quaternionenmodells und die Primvierlinge sprechen strukturell dieselbe Sprache.

Das Lemma nimmt dem Fundamentalsatz die analytische Haerte und verleiht ihm eine
algebraische Eleganz — die Basis fuer die Lean-Formalisierung in
`PrimvierlingSymmetry.lean`.

---

## 4b. Abgrenzung: Chebyshev mod-4-Bias (E-050, `[C]`)

Das Dumas-Lemma (E-048) ist **endliche Kombinatorik** auf einem Primvierling.
Der **Chebyshev-Bias** (`π(x;4,3) − π(x;4,1)`) ist ein **globales Dirichlet-Rennen**
— formal in `KeplerHurwitz/ChebyshevBiasInterface.lean` als `[C]`-Hypothesenschicht,
getrennt von E-048. Es gibt **keinen Beweis** einer Bruecke `ChebyshevDumasInterface`.

Siehe: [chebyshev_bias_interface.md](chebyshev_bias_interface.md)

---

## 4c. Abgrenzung: Dedekind-Idealtheorie (E-064–E-066)

E-053 (Dedekind–Hasse) prüft **PID-Fähigkeit**; E-064 ff. beschreiben **Idealpfade**
(`LeftIdeal`, `PrincipalLeftIdeal`, DED-1…DED-5). EABC-Signaturdeutung
(`EabcInterpretationLayer`) ist **nicht** aus Idealen bewiesen.

Siehe: [dedekind_ideal_layer.md](dedekind_ideal_layer.md)

---

## 5. Lean-Symbolverzeichnis

| Symbol | Datei | Bedeutung |
|---|---|---|
| `Dumas_one_for_all_all_for_one` | `PrimvierlingSymmetry.lean` | Zustandsbundle (Prop-Struktur) |
| `dumasLemma` | `PrimvierlingSymmetry.lean` | Kombiniertes Lemma (E-048) |
| `hostComponentEquiv` | `PrimvierlingSymmetry.lean` | Bijektion Host ↔ Komponente (E-034/E-047) |
| `dumasLemma_hostComponent_bij` | `PrimvierlingSymmetry.lean` | E-048-Alias fuer `hostComponentEquiv` |
| `mem_hostTriple_count` | `PrimvierlingSymmetry.lean` | Multiplizitaet \(= 3\) (E-034/E-047) |
| `dumasLemma_otherChannels_card` | `PrimvierlingSymmetry.lean` | Korollar ↔ `otherChannels` |
| `otherChannels` | `DreiMusketiere.lean` | Drei uebrige Kanaele auf Label-Ebene |

**Verwandte Dokumente:** [Drei-Musketiere-Hypothese](drei_musketiere_hypothese.md) ·
[Orbit-Symmetrie-Guide](orbit_symmetry_guide.md) ·
[EVIDENCE_REGISTER.md](../EVIDENCE_REGISTER.md) (E-048)

**Build:** `lake build KeplerHurwitz.PrimvierlingSymmetry` — 0 `sorry` (Stand 2026-07-03).
