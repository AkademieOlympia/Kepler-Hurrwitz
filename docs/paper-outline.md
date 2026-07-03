# Paper Outline (Draft)

Arbeitstitel:
- `EABC Prime-Factor Signatures, Hurwitz Cones, and Kepler-Type Arithmetic Invariants`

Alternativ:
- `A Conic-Section Model for Prime-Factor Signatures in Residue Classes mod 12`

## 1. Problemstellung und Beitrag

- Ziel: Primfaktorstruktur nicht nur zaehlen, sondern geometrisch als Signaturdynamik modellieren.
- Kernobjekt: `H(n)=(E,A,B,C)` als vierkanalige additive Struktur.
- Hauptbeitrag:
  1) formale Normschalen-Dynamik,
  2) projektionale Kepler-Invarianten,
  3) defensive Schnittstellen zu Hurwitz/Goedel-Kerr/Photon-Modulen.

## 2. Mathematischer Unterbau

- Additive Funktionen auf Primfaktor-Mengen in Progressionen.
- `nu2`-Bewertung und ungerader Kern (`oddCore`) als kontrollierte Reduktion.
- Nichtkommutative Anschlussstruktur: Hurwitz-Primes/Metakommutation (als Perspektive, nicht als bereits bewiesene Identitaet).

## 3. Formale Lean-Kernsaetze

**Lean-Status:** Satzgruppen S1–S3 (Lean-Kern): vollstaendig maschinell verifiziert (`collatz_iterate_pow_two_*`, `oddCore`, `nu2`-Bounds). Der globale Gesamtbuild der Bibliothek ist aktuell durch ein verbleibendes `sorry` im Randmodul `KeplerHurwitz/Representation/DreiMusketiere.lean` (Symmetriebrechung) blockiert.

### 3.1 Normschalen und Collatz-Reduktion
- `collatz_iterate_pow_two_to_one`
- `collatz_iterate_pow_two_mul`
- `oddCore`-Zerlegung und `nu2`-Bruecke
- Aequivalenz:
  - `ClassicalCollatzConjecture <-> OddCoreCollatzConjecture`

### 3.2 Odd-Core-Dynamik
- `oddCoreStep m = oddCore (3*m+1)`
- Erreichbarkeit des naechsten ungeraden Kerns durch endliche Collatz-Iteration
- Mod-8-Falltabellen fuer `3*m+1`
- `nu2`-Bounds je Restklasse

### 3.3 Geometrische Schicht
- Kepler-Ratio und Geschwindigkeitsverhaeltnis:
  - `radiusRatio_eq_speedRatio`
- Photon-Kepler-Shift-Lemmas:
  - Monotonie von `radiusRatio` in `e`
  - Frequenz-/Wellenlaengen-Vergleiche bei fixer Gegenvariable

## 4. Modellarchitektur

- Ebene A (Analytik): `H(n)=(E,A,B,C)`
- Ebene B (Dynamik): `oddCoreStep`, `nu2`-Bounds, Residue-Filter
- Ebene C (Geometrie): Projektion `H -> (a,e,R_v)` und Kepler-Lesart
- Ebene D (Erweiterung): Hurwitz/Oktonion-/Physik-Interfaces (defensiv, modular)

### 4.1 `#Energiedoku`: Gitter-Rigiditaet bis arithmetische Schalen-Resonanz

Reproduzierbare Kette (E-033 bis E-036):

1. **Kepler-Zeit-Leiter `[B]` (E-033):** `Phi^{-1}` → diskretes `Delta M`-Linienspektrum auf Floquet-Attraktoren (Tail-Periode 8; 2/3/1 Linien je Branch).
2. **Riemann-Kopplung `[C]` (E-034, Verdict: refuted):** `S(Delta M)=mean cos(gamma * Delta M)` → asymptotisch ~10^-7; identisch zum Zufalls-Nullmodell; `S(0)=1` trivial. Schnittstellen-Kosinus-Mittelung zeigt destruktive Interferenz — kein Baseline-Ueberhang.
3. **Skalen-Interferenz `[C]` (E-035, Verdict: open_hypothesis / experimental):** `S(x_0)=mean cos(gamma * log(a/a_0))` → kein statistisch signifikantes Signal unter Kosinus-Mittelung; negative Evidenz, aber keine formale Widerlegung der strukturellen Kopplung.
4. **Arithmetische Evolution `[C]` (E-036):** Shell-Proxies fuer Zielnormen 3/5/7 auf E8 (N=4,6,8); **6 quantisierte Schalen** `x_0 in {-2,-1,0,0.5,1,2}`; `periodic_recovery=12/12`.
5. **Fano-QEC-Brücke `[B]` (E-038):** GF(2)-CSS-Projektion der 7 Fano-Linien; Syndrompartition ueber E-037; Steane-Abgrenzung (Rang 4 vs 3, Schnittdimension 1, Kern-Mindestgewicht 4 vs 3).

**Manuskript-Begriff:** *arithmetisch induzierte Schalen-Resonanz* — diskretes Floquet-Pumpen zwischen Bohrschen Schalen, keine thermische Dissipation.

Export-Artefakte:
- `docs/plots/spectrum_*.dat`
- `docs/energiedoku_exports/riemann_resonance.json`
- `docs/energiedoku_exports/riemann_scale_resonance.json`
- `docs/energiedoku_exports/arithmetic_transition_matrix.json`
- `docs/energiedoku_exports/arithmetic_energy_levels.tex` (`\\label{tab:quantized-energy-levels}`)
- `docs/energiedoku_exports/dyadic_metacommutation.json`
- `docs/energiedoku_exports/qec_bridge.json`
- `docs/energiedoku_exports/fano_kernel_shell_map.json`
- `docs/energiedoku_exports/fano_shell_cosets.json`
- `docs/energiedoku_exports/refined_shell_projection.json`
- `docs/energiedoku_exports/signed_shell_syndromes.json`
- `docs/energiedoku_exports/signed_support_symmetry.json`
- `docs/energiedoku_exports/coupled_shell_resonance_graph.json`
- `docs/qec_bridge.md`

### 4.2 Kapitel IV → V: Dyadische Metakommutation als Ursache der Schalen-Resonanz

**Manuskript-Anker:** `docs/paper_draft.tex`, Section IV (*Dyadic Metacommutation and Associator Collapse*) vor Section V (*Arithmetic Shell Resonance*).

Architekturprinzip: Erst die algebraischen Kommutationszoepfe (Ursache), dann die quantisierte Schalen-Dynamik (Wirkung).

**Reihenfolge-Hinweis:** Manuskript-Reihenfolge: algebraische Ursache (Kapitel IV / E-037) vor dynamischer Wirkung (Kapitel V / E-036). Im Evidenz-Register gilt die Build-Abhaengigkeit E-036 → E-037 (numerische Pipeline-Reihenfolge).

#### Kapitel IV — Dyadic Metacommutation (E-037, `[C]`)

- **Norm 2 als Kopplungsoperator:** 112 ganzzahlige Norm-2-Wurzeln (zwei nichtverschwindende `+-1`-Eintraege) bilden die dyadische Basis der Metakommutation.
- **Hurwitz-Einheiten:** 240 Hurwitz-Einheiten gesamt, bestehend aus 112 ganzzahligen Norm-2-Wurzeln (dyadische Basis) und 128 Halbgitter-Einheiten.
- **Ungerade Primnormen auf E8:** exhaustive Suche in `[-5,5]^8` liefert fuer `||v||^2 in {3,5,7,...}` **keine** Hurwitz-Gitterpunkte → Shell-Proxies N=4,6,8 sind numerisch erzwungen, nicht willkuerlich. Reproduzierbar via `tests/test_prime_norms.py` und `kepler_hurwitz.hurwitz_lattice_sieve`.
- **Vollstaendige Metakommutationstabelle:** `P·U = U'·P'` fuer 112 dyadische Norm-2-Wurzeln x 240 Einheiten — **26880/26880 aufloesbar**; 12544 dyadische / 14336 Halbgitter-Partner; 7904 assoziativ / 18976 nicht-assoziativ (Oktonion-Zopf).
- **Shell-Proxy-Assoziator-Profil:** N=4 und N=8: `associative_ratio=1.0`; N=6: `0.767` (partieller Kollaps).

#### Kapitel V — Arithmetic Shell Resonance (E-036, `[C]`, baut auf IV auf)

- **Dynamische Konsequenz:** 6 quantisierte Niveaus `x_0 in {-2,-1,0,0.5,1,2}`; `\input{energiedoku_exports/arithmetic_energy_levels.tex}`.
- **Uebergangsmatrix** (`arithmetic_transition_matrix.json`): dokumentiert ausgehende stationaere Stroeme fuer die fuenf stabilisierten Schalen; die 6. Schale `x_0=2` agiert rein transitiv (kein Fixpunkt, kein Pumpen-Knoten) und erscheint deshalb nicht mit ausgehenden stationaeren Zeilen in der Matrix.
- **Operator-Asymmetrie aus IV gelesen:** N=4 Pumpen (deterministisch), N=8 Fixpunkt, N=6 Bifurkation `P=0.5/0.5` bei `x_0=1`.
- **H3 (qualitativ, drei Schichten):** (A) `rho_alg` algebraische Dichte, (B) `P_row` dynamische Matrix, (C) `Q_sym` + Gap `G=rho_alg-max P_k`. Explizit **nicht**: Konkavität erklaert allein `H_alg -> H_row`. Code: `entropy_bridge.py`, Lean `EntropyBridge.lean` (`Qsym2`, exakt `23/30-1/2=4/15`).

### 4.3 Fano-QEC-Brücke: CSS-Projektion und Steane-Abgrenzung (E-038, `[B]`)

**Leitformel:** *Steane-kompatibel, aber nicht Steane-identisch.*

**Manuskript-Anker:** `docs/qec_bridge.md`; Export `docs/energiedoku_exports/qec_bridge.json`; Code `src/kepler_hurwitz/qec_bridge.py`.

Die Fano-QEC-Brücke untersucht, ob die im oktonionischen Framework auftretenden Fano-Paritaetsstrukturen als stabilisator-aehnliche Fehlerkorrekturstruktur gelesen werden koennen. Der Vergleich mit dem Steane-`[[7,1,3]]`-Code dient **nicht** als Identifikation, sondern als kontrollierte Referenzgeometrie.

#### CSS-Projektion (kombinatorisch, E-038)

Sei `R_Fano` die 7×7-Fano-Paritaetsmatrix ueber GF(2) (7 Linien, je Gewicht 3). Die CSS-Projektion liefert:

| Groesse | Fano-Paritaet | Steane `H_X` (Referenz) |
|---|---|---|
| `rank(R_Fano)` | **4** | **3** |
| `dim ker(R_Fano)` | **3** | **1** (logisches Qubit) |
| `dim(R_Fano ∩ R_Steane)` | **1** | — |
| `R_Steane ⊆ R_Fano` | **nein** | — |
| RREF-Generatorgewichte | **(3, 3, 3, 4)** | (3, 3, 3) |
| `d_min(ker R_Fano)` | **4** | **3** |

Explizit:

- `rank(R_Fano) = 4`, `dim ker(R_Fano) = 3`
- `dim(R_Fano ∩ R_Steane) = 1`
- erste Fano-Linie `(1,2,3) = (1,1,1,0,0,0,0)` ist Steane-kompatibel, aber `R_Steane ⊄ R_Fano`
- die vierte unabhaengige RREF-Zeile (Gewicht 4) verschiebt die Mindestdistanz des Fano-Kerns gegenueber dem Steane-Profil

**Defensive Kernaussage:**

> Die Fano-QEC-Brücke besitzt ein Steane-kompatibles Geruest, ist aber kein Steane-Code. Sie teilt eine Fano-Linie mit dem Steane-`H_X`-Block, divergiert jedoch im vollen Zeilenraum, im Rang und im minimalen Kerngewicht.

Fuer das Framework ist dies ein Stabilitaetsbefund: Die QEC-Brücke liefert keine nachtraegliche Identifikation mit einem bekannten Code, sondern eine eigenstaendige endliche Syndromstruktur. Die Abweichung ist durch explizite GF(2)-Linearalgebra begruendet — nicht durch Namensaehnlichkeit oder Fano-Symbolik.

#### Syndrompartition (E-037 → E-038)

Ueber die Metakommutation (26880/26880 aufgeloest) ergeben sich **4 Syndromklassen**:

| Syndromklasse | Paare |
|---|---|
| `non_associative_half_integer` | 10752 |
| `non_associative_dyadic` | 8224 |
| `associative_dyadic` | 4320 |
| `associative_half_integer` | 3584 |

Grobe Schalen-Syndrom-Map (Stufe 3, `[C]`, noch nicht als Evidenz registriert):

| Stabilisierungsklasse (E-036) | QEC-Analog |
|---|---|
| Fixpunkt (`N=4,8`) | stabiler Code-Unterraum |
| Bifurkation (`N=6`) | Syndrom-Spaltung |
| Pumpen | diskrete Korrekturdynamik |
| Ground shell | Vakuum-Syndrom |
| Transitiv | transientes Syndrom |

#### Register und Hypothese

- **E-038 `[B]`:** haengt von E-037 ab; reproduzierbar via `tests/test_qec_bridge.py` (16 Tests)
- **unterstuetzt H3:** Schalenresonanzen besitzen eine endliche, stabilisatoraehnliche Paritaetsstruktur, ohne bereits als vollstaendiger quantenmechanischer Fehlerkorrekturcode interpretiert zu werden

#### QEC-Kette (**eingefroren**, Keil B abgeschlossen, v1)

Der QEC-Block E-038–E-042 ist methodisch abgeschlossen und fuer v1 eingefroren. Keine weiteren Suchlaeufe ohne neues Evidenz-Register-Item.

| ID | Klasse | Rolle |
|---|---|---|
| E-038 | `[B]` | Steane-kompatibel, aber nicht Steane-identisch |
| E-039 | `[C]` | negativer GF(2)-Quotiententest (σ₄=σ₈) |
| E-040 | `[C]` | Verfeinerungskatalog |
| E-041 | `[B]` | signierte Support-Trennung |
| E-042 | `[C]` | Symmetrievalidator unter G_model |
| **S8** | **`[B]`** | kondensierter Strukturclaim (Paper-Proposition) |

**E-039 bleibt negativ:** σ₄=σ₈ wird nicht revidiert. **E-041 [B]** ist Verfeinerungsebene, kein Rettungsmanoever.

**E-039 `[C]`:** Negativer Quotient-Test — **σ₄ = σ₈**, **σ₆ ≠ σ₄**. Dyadische Fano-Projektion trennt Bifurkation (N=6), nicht Pumpen/Fixpunkt (N=4 vs N=8).

**E-040 `[C]`:** Verfeinerungskatalog — `residue_key` allein trennt N=4/N=8 nicht; volle Projektion und `signed_support` schon.

**E-041 `[B]`:** Signierte Support-Projektion trennt N=4, N=6, N=8 paarweise; hebt σ₄=σ₈ auf, ohne E-039 zu revidieren. Validiert durch E-042 unter G_model (|G|=336).

### 4.4 Signierte Shell-Syndrome (E-041 `[B]` — Strukturclaim)

E-040 prüfte kanonische Verfeinerungen; **E-041 `[B]`** setzt `signed_support` als kanonische Verfeinerung — eine vorab definierte Vorzeichen-/Support-Schicht der Hurwitz-Projektion, nicht eine nachträgliche Anpassung.

> E-039 zeigt die Grenze der reinen GF(2)-Quotientenprojektion. E-041 überschreitet diese Grenze nicht durch nachträgliche Anpassung, sondern durch eine vorab definierte signierte Support-Projektion, deren Trennung in E-042 `[C]` unter der vollständigen Modell-Symmetriegruppe invariant bleibt.

**Defensive Lesart:** Keine kausale Erklärung von Pumpen, Fixpunkt oder Bifurkation — nur eine kanonische, symmetrieinvariante Verfeinerung.

| Test | Ergebnis |
|------|----------|
| Primär `signed_support` | N=4 ≠ N=8, N=6 paarweise getrennt |
| E-039 GF(2)-Kollision | σ₄=σ₈ **erhalten** (E-039 bleibt `[C]`) |
| Kontrolle `full_hurwitz_projection` | gleiche Trennung |
| `residue_key` allein | N=4 = N=8 (ausgeschlossen) |

Export: `docs/energiedoku_exports/signed_shell_syndromes.json`

### 4.5 Symmetrieinvarianz (E-042 `[C]` — Invarianzvalidator)

**E-041 `[B]` ist der Strukturclaim; E-042 `[C]` ist der Invarianzvalidator.** Die Symmetriegruppe wird **vor** der Auswertung festgelegt:

\[
G_{\mathrm{model}}
=
\mathrm{Aut}(\mathrm{Fano}_7)
\times
\mathbb{Z}_2^{\mathrm{global\,imag\,sign}},
\qquad
|G_{\mathrm{model}}|=336.
\]

Unter allen \(g \in G_{\mathrm{model}}\) bleibt die `signed_support`-Trennung für N=4/N=8, N=4/N=6 und N=6/N=8 erhalten (0 Fehler / 336). Dies validiert E-041 `[B]`.

Export: `docs/energiedoku_exports/signed_support_symmetry.json`

### 4.6 Proposition S8 `[B]`: Signierte Fano-Shell-Trennung

**Paper-Satzgruppe S8** kondensiert E-039–E-042 zu einem publikationsfaehigen Strukturclaim.

#### Proposition (Signierte Fano-Shell-Trennung)

Die reine dyadische GF(2)-Projektion der Fano-Shell-Daten trennt die Klassen (N=4) und (N=8) nicht. In dieser Projektion gilt

\[
\sigma_4=\sigma_8,
\qquad
\sigma_6\neq\sigma_4.
\]

Damit erkennt der Fano-Kernquotient die Klasse (N=6) als getrennt, unterscheidet jedoch (N=4) und (N=8) nicht.

Eine kanonische Verfeinerung durch die signierte Support-Projektion der Hurwitz-Daten trennt dagegen alle drei Klassen (N=4,6,8) paarweise. Diese Trennung bleibt unter der vorab festgelegten Modell-Symmetriegruppe invariant:

\[
G_{\mathrm{model}}
=
\mathrm{Aut}(\mathrm{Fano}_7)
\times
\mathbb{Z}_2^{\mathrm{global\,imag\,sign}},
\qquad
|G_{\mathrm{model}}|=336.
\]

Fuer alle \(g\in G_{\mathrm{model}}\) bleiben die Paare (N=4) vs. (N=8), (N=4) vs. (N=6) und (N=6) vs. (N=8) getrennt (0 Fehler / 336).

#### Defensive Schlussfolgerung

Die verlorene Unterscheidung zwischen (N=4) und (N=8) liegt nicht im dyadischen GF(2)-Quotienten, sondern in einer kanonischen, symmetrieinvarianten Vorzeichen-/Support-Schicht der Hurwitz-Projektion. Daraus folgt **keine** kausale Identifikation von Pumpen, Fixpunkt oder Bifurkation, wohl aber ein belastbarer Strukturclaim fuer die Fano-QEC-Bruecke.

**Evidenz-Mapping:** E-039 (negativ) + E-040 (Katalog) + E-041 (Struktur) + E-042 (Invarianzvalidator) → **S8 [B]**.

### 4.7 Keil A-pre: Coupled Shell Resonance Graph (E-043-pre, `[C]`)

> Nach dem eingefrorenen QEC-Block wird die N-Body-Brücke nicht als physikalische Gravitationstheorie eingeführt, sondern als endliche Kopplungsdynamik der bereits validierten Shell-Proxy-Operatoren (N=4,6,8).

**Startfrage:** Was passiert, wenn mehrere Shell-Proxy-Operatoren \(N_i\in\{4,6,8\}\) gekoppelt werden?

\[
(N_i, N_j) \longmapsto \text{gekoppelte Übergänge auf den sechs } x_0\text{-Schalen.}
\]

**Governance-Kette:** Einzeloperatoren (E-036/S6) → gekoppelte Operatoren → Resonanzgraph → erst danach N-Body-Analogie.

| Artefakt | Rolle |
|---|---|
| E-036 | Einzeloperator-Übergangsmatrix auf \(x_0\)-Niveaus |
| E-037 | algebraischer Unterbau (Metakommutation) |
| E-041 / S8 | validierte Einzelschalen-Signaturen (QEC eingefroren) |
| **E-043-pre** | paarweise/dreifach gekoppelte Resonanzgraphen |

Funktion: `analyze_coupled_shell_resonance_graph()` — Output: `coupled_shell_resonance_graph.json`

**Defensive Lesart:** Keine astrophysikalische Identifikation; endliche gekoppelte Shell-Dynamik only.

### 4.8 [[5,1,3]]-Stabilisator-Brücke (E-044, `[C]` — Manuskript Kapitel VII)

> Nach dem eingefrorenen Fano-QEC-Block (S8) wird die `[[5,1,3]]`-Brücke nicht als physikalische Raumzeit-Identifikation eingeführt, sondern als endliche symplektische Testschicht für dyadische Shell-Daten.

**Claim:** Vollständige Projektion der 112 dyadischen Wurzeln auf die 15 nichttrivialen Stabilisatoren des kanonischen `[[5,1,3]]`-Codes.

| Befund | Wert |
|--------|------|
| Stabilisatoren | 15/15, paarweise kommutierend |
| Match-Paare | 1680 = 112 × 15 |
| `commutation_signum=+1` | 784/1680 = **7/15** |
| Symplektische Wurzelklassen | 49 |

**Negativer Teilsatz:** Kommutationsquote **7/15** für N=4, N=6, N=8 **identisch** — keine Trennung auf Skalarebene. Trennung bleibt in E-037 (`associative_ratio` 1.0 vs 0.767).

**Folgeexperiment (E-045, offen):** Signiertes Stabilizer-Support-Profil \(v_N \in \{\pm1\}^{15}\) innerhalb der `[[5,1,3]]`-Projektion, wenn die Quote degeneriert bleibt.

Export: `docs/energiedoku_exports/five_qubit_stabilizer_bridge.json` — Manuskript: `paper_draft.tex` §VII (`sec:qec-stabilizer-bridge`)

### 4.9 E-045-pre: Signiertes `[[5,1,3]]`-Stabilizer-Profil (nach Kapitel VII)

**Frage:** Bleibt die Skalardegeneration \(7/15\) auch im vollen signierten Profil \(v_N \in \{\pm1\}^{15}\)?

| Ebene | Befund |
|-------|--------|
| Skalar (E-044 erhalten) | \(\#\{s: v_N(s)=+1\}=7\) für N=4,6,8 |
| Rohprofile | **verschieden** (N4≠N6≠N8) |
| Orbit unter \(G_{\mathrm{5-code}}\) (\|G\|=20) | **identisch** → kein trennendes Invariant |

**Negativer Teilsatz:** E-045 liefert kein Upgrade — Orbitklassen unter vorab definierter Code-Symmetrie degenerieren. Trennung bleibt in E-037 (`associative_ratio`).

Funktion: `analyze_signed_stabilizer_support_profile()` — Export: `signed_stabilizer_support_profile.json`

## 5. Hauptsaetze / Hypothesen im Manuskript

- Satzgruppe S1 (formal bewiesen): Normschalen-Reduktionen und Odd-Core-Aequivalenz.
- Satzgruppe S2 (formal bewiesen): Modulo-basierte `nu2`-Schranken fuer `3m+1`.
- Satzgruppe S3 (formal bewiesen): Kepler-Ratio-Identitaet und monotone Shift-Lemmas.
- **Satzgruppe S4 (numerisch `[B]`, E-033):** Algebraische Floquet-Rigiditaet — diskrete `Delta M`-Zeit-Leiter auf E8-Attraktoren.
- **Satzgruppe S5a (numerisch negativ `[C]`, E-034, refuted):** Globale Riemann-Kosinus-Mittelung auf `Delta M` traegt keinen Baseline-Ueberhang (destruktive Interferenz).
- **Satzgruppe S5b (numerisch offen `[C]`, E-035, open_hypothesis):** Skalen-Kosinus-Mittelung auf `x_0` zeigt kein signifikantes Signal; strukturelle Kopplung nicht widerlegt.
- **Satzgruppe S6 (numerisch `[C]`, E-036):** Arithmetisch induzierte Schalen-Resonanz — quantisierte `x_0`-Niveaus, operator-asymmetrische Uebergangsmatrix, 100% periodische Erholung.
- **Satzgruppe S7 (kombinatorisch `[B]`, E-038):** Fano-QEC-Brücke — GF(2)-Rang 4, Kern-Dimension 3, Steane-Abgrenzung (Schnittdimension 1, `d_min(ker)=4` vs Steane 3); *Steane-kompatibel, aber nicht Steane-identisch*.
- **Satzgruppe S8 (kombinatorisch `[B]`, E-039–E-042):** Signierte Fano-Shell-Trennung unter \(G_{\mathrm{model}}\) — GF(2)-Kollision \(\sigma_4=\sigma_8\) bleibt (E-039 negativ); kanonische `signed_support`-Verfeinerung trennt N=4,6,8 paarweise; Invarianz unter \(|G_{\mathrm{model}}|=336\) (E-042); keine kausale Pumpen/Fixpunkt/Bifurkations-Identifikation.
- Hypothese H1 (offen): globale Odd-Core-Dynamik konvergiert.
- Hypothese H2 (programmatisch): EABC-Chiralitaet als residue-class shadow nichtkommutativer Hurwitz-Orbits.
- **Hypothese H3 (programmatisch):** Metakommutations-Signum steuert Zeilenentropie der Schalen-Uebergangsmatrix (Anschluss E-036 ↔ E-037 ↔ E-038); Schalen-Syndrom-Trennung symmetrieinvariant unter S8 (E-039–E-042); exakte Abbildung `0.767 -> 0.5/0.5` noch analytisch offen.

### 5.1 Abschnitt *Arithmetic Shell Resonance* (arXiv-Kapitelentwurf)

**Definition.** Sei `x_0 = log(a/a_0)` die Skalenkomponente von `Phi`. Die **Schalen-Resonanz** ist das Paar `(Spektrum(x_0), P(x_0'|x_0, op))` unter Shell-Proxy-Operatoren `N in {4,6,8}` plus Unit-Relaxation.

**Stabilisierungsklassen** (Tabelle `arithmetic_energy_levels.tex`):

| Klasse | Mechanismus | Beispiel |
|---|---|---|
| Fixpunkt | Topologischer Isolator | `N=8` auf `x_0=0`; `N=4,N=8` auf `x_0=-2` |
| Pumpen | Deterministischer Transfer | `N=4`: `0.5 -> 1.0` |
| Bifurkation | Quanten-Strahlteiler | `N=6`: `P=0.5/0.5` bei `x_0=1` |

**Kernaussage:** Das System verhaelt sich wie ein diskretes Floquet-Pumpen zwischen 6 Bohrschen Schalen — nicht wie diffusive Dissipation.

[^x0-transit]: Die 6. Schale `x_0=2` (Klasse *Transitiv* in `arithmetic_energy_levels.tex`) besitzt weder Fixpunkt noch Pumpen-Knoten; sie traegt deshalb in `arithmetic_transition_matrix.json` keine ausgehenden stationaeren Stroeme (`x0_states` listet nur `{-2,-1,0,0.5,1.0}`).

## 6. Empirie und Reproduzierbarkeit

- Python/Sage-Filterpipeline als explorative Ebene.
- Lean als verifizierende Ebene.
- Gemeinsame Invarianten:
  - Modulo-Faelle (8/24),
  - `nu2`,
  - Odd-Core-Uebergang.
- **`#Energiedoku`-Pipeline (186 pytest, Stand 2026-07-03):**
  - `examples/run_kepler_time_bridge.py`
  - `examples/run_riemann_resonance_check.py`
  - `examples/run_arithmetic_evolution.py`
  - `examples/run_metacommutation_analysis.py`
  - `examples/run_qec_bridge_analysis.py`
  - `examples/run_fano_kernel_shell_map.py`
  - `examples/run_signed_shell_syndromes.py`
  - `examples/run_signed_support_symmetry.py`
  - Manuskript: `docs/paper_draft.tex`
  - `examples/run_coupled_shell_resonance.py`
  - `examples/run_qec_stabilizer_check.py`
  - Register: `EVIDENCE_REGISTER.md` (E-033–E-044); QEC-Block eingefroren; Keil A-pre E-043; E-044 [[5,1,3]]-Erweiterung

## 7. Abgrenzungen

- Kein RH-Beweis.
- Kein finaler Collatz-Beweis.
- Keine physikalische Volltheorie von Goedel-Kerr/Photonik; derzeit nur formale, defensive Schnittstellen.

## 8. Roadmap fuer v1 -> v2

1. EABCLayer staerker an konkrete Primfaktor-Daten anbinden.
2. Automatisierte Bruecke Lean <-> Python-Exports.
3. Fallweise Schranken fuer `oddCoreStep` weiter verschaerfen.
4. Optionale Hurwitz-Orbit-Liftings als separate Erweiterung.
5. **v2-Manuskript (`docs/paper_draft.tex`):** Kapitel I–VI angelegt; QEC-Block (E-038–E-042, S8) eingefroren; offen: H3-Entropie-Bruecke formalisieren, S8-Proposition ins Manuskript, pgfplots-Figuren fuer alle Branches, BibTeX statt stub bibliography.
6. ~~**Fano-Kernfreiheiten ↔ Schalenklassen:**~~ Teilweise adressiert durch S8 (E-039–E-042); offen bleibt die analytische H3-Entropie-Bruecke.
