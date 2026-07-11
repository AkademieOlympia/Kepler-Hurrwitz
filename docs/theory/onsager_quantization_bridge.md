---
title: Onsager Quantization Bridge
date: 2026-07-05
status: "[C]"
orq_id: ORQ-089
evidence_id: E-089
claim_boundary: >-
  Lars Onsagers Beiträge (Flussquantisierung, quantisierte Wirbel, 2D-Ising-Lösung,
  Reziprozitätsbeziehungen) dienen als Resonanzsprache für diskrete EABC-Strukturen —
  keine physikalische Identifikation, kein Beweis von Kanalpartition, Holonomie oder
  Phasenübergang im Formal Core.
not_claimed:
  - EABC implementiert Suprafluidität, Supraleitung oder das 2D-Ising-Modell
  - Flussquant Φ₀ = h/(2e) ist im Hurwitz-Formalismus definiert
  - Onsager-Reziprozität beweist Weyl-Kommutator-Symmetrie oder Dedekind-Idealpfade
  - 2D-Ising-Kritikalität erklärt ShellSeparationLoss oder shellPrimeMatchAtFirstLoss
---

> **Evidence status:** `[C]` Physik-Analogie / Brückenhypothese (ORQ-089, E-089)  
> **Verwandte ORQs:** ORQ-080 (Hurwitz-Windung), ORQ-083 (Berry-Holonomie), ORQ-087 (Weyl-Kommutator), ORQ-077 (ShellSeparationLoss)  
> **Geschwister-Dossier:** [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md) (E-076: AB / Klitzing / Meissner)

# ORQ-089: Onsager Quantization Bridge

**Stand:** 5. Juli 2026  
**Governance:** `[C]` — Upgrade zu `[B]` nur über operationalisierte Diskretisierungs- und Reversibilitätsdiagnostik mit Nullmodellen  
**Physiker:** Lars Onsager (1903–1976) — Nobelpreis für Chemie 1968 (Reziprozitätsbeziehungen)

---

## Kernfrage

**Lassen sich Onsagers vier Grundbeiträge als komplementäre Resonanzachsen für diskrete EABC-Strukturen lesen — ohne physikalische Identifikation?**

Formal: Existiert eine kontrollierte Abbildung

$$\text{Onsager-Achse} \;\leadsto\; \text{EABC-Lesefrage} \;\leadsto\; \text{operationalisierbare Diagnostik } [B]?$$

Die vier Achsen sind unabhängig voneinander und dürfen nicht vermischt werden.

---

## Governance (verbindlich)

\[
\boxed{
\text{Onsager-Analogie = Interpretation, nicht Beweis.}
}
\]

| Kurzformel | Bedeutung |
|---|---|
| **`[A]` etablierte Physik** | Onsagers Resultate (1944–1953) — nur Referenzbild |
| **`[C]` Interpretation** | EABC-Lesefragen entlang der vier Achsen |
| **`[B]` Diagnostik** | Erst nach reproduzierbarem Export mit Nullmodellen |
| **Trennung E-076 ↔ E-089** | E-076 (AB/Klitzing/Meissner) und E-089 (Onsager) ergänzen sich — keine gegenseitige Deduktion |

**Kern-Satz:** Onsager liefert **Sprache für Diskretisierung, Umlauf, Kritikalität und Reversibilität** — nicht für arithmetische Beweise.

---

## Deep Dive: zwei makroskopische Quantenphänomene

Beide Phänomene zeigen, wie Quantenmechanik — sonst auf atomarer Skala verborgen — im Labor **sichtbar und greifbar** wird. Sie bilden den Schwerpunkt von ORQ-089/E-089 und sind unten mit EABC-Lesefragen verknüpft (`[C]` only).

---

### A. Flussquantisierung und Cooper-Paare

#### Onsagers Vorhersage (1953)

Onsager schlug vor, dass der magnetische Fluss $\Phi$ durch einen supraleitenden Ring **quantisiert** sein muss. Er argumentierte über die **Phase** der Wellenfunktion: Umrundet man den Ring einmal, muss die Phase sich um ein ganzzahliges Vielfaches von $2\pi$ schließen. Mit der Elementarladung $e$ folgte zunächst:

$$\Phi = n \cdot \frac{h}{e}, \qquad n \in \mathbb{Z}$$

#### Die Überraschung von 1961

1961 bestätigten **Doll & Näbauer** (München) und **Deaver & Fairbank** (Stanford) die Quantisierung experimentell — aber der gemessene Fluss war **halb so groß** wie Onsager ursprünglich berechnet hatte:

$$\Phi_{\mathrm{gemessen}} = n \cdot \frac{h}{2e}$$

#### Warum der Faktor 2 alles veränderte

1957 hatten **Bardeen, Cooper & Schrieffer** die BCS-Theorie der Supraleitung formuliert:

| Objekt | Eigenschaft | Konsequenz für Fluss |
|---|---|---|
| Einzelnes Elektron | Fermion, Spin $\tfrac{1}{2}$ | Onsagers ursprüngliche Lesart ($h/e$) |
| **Cooper-Paar** | Effektives Boson, Spin $0$ | Ladungsträger mit $q = 2e$ |
| Makroskopisches Paar-Kondensat | Alle Paare im gleichen Grundzustand | Eine gigantische Wellenfunktion im Bulk |

Die korrigierte, bis heute gültige Formel:

$$\boxed{\Phi_0 = \frac{h}{2e}}$$

Der experimentelle Beweis der Flussquantisierung war damit **gleichzeitig** der stärkste empirische Beleg für Cooper-Paare — Theorie und Experiment verschmolzen in einer einzigen Zahl.

#### EABC-Lesefrage `[C]` (Flussachse)

| Physik-Bild | Strukturelle Lesart im EABC-Programm |
|---|---|
| Ganzzahlige Flussquanten $\Phi = n\Phi_0$ | Diskrete Kanal-Buckets; mod-$12$-Stufen $\{1,5,7,11\}$ (E-072) |
| Falscher Nenner ($h/e$) → Korrektur ($h/2e$) durch **tiefere Paarstruktur** | Signatur $H(n)$ trägt mehr Information als ihre Projektion $M(n)$ — Lift vs.\ Projektionsverlust |
| Bosonisches Kondensat = eine makroskopische Zustandsfunktion | Isotroper Fixpunkt $24I_3$ nach Retraktion — Bulk-Kohärenz ohne lokale Anisotropie |
| Robustheit gegen Störung | Kanalpartition und Greedy-Satz bleiben unter Retraktion stabil |

**Anschluss:** E-072; `channel_entropy`, `prime_grid_compression`; von-Klitzing-Achse (E-076 §5) — QHE-Plateaus und Flussquanten sind **Geschwisterbilder** diskreter Stufen, nicht identisch.

**Nicht behaupten:** EABC besitzt Cooper-Paare, $\Phi_0$ oder ein supraleitendes Kondensat.

---

### B. Quantenwirbel in Suprafluiden

#### Der Quantenzwang

Ein Suprafluid (Helium-4 unter $\approx 2{,}17\,\mathrm{K}$) wird durch **eine einzige makroskopische Wellenfunktion** beschrieben:

$$\psi = \sqrt{\rho}\, e^{i\theta}$$

$\rho$ = Dichte, $\theta$ = Phase. Geht man im Kreis um einen Punkt herum, muss $\theta$ um ein ganzzahliges Vielfaches von $2\pi$ springen — die Wellenfunktion muss **eindeutig** sein. Daraus folgt die Quantisierung der **Zirkulation**:

$$\Gamma = \oint \mathbf{v}\cdot d\mathbf{r} = n \cdot \frac{h}{m}, \qquad n = 1, 2, 3, \ldots$$

($m$ = Masse des Heliumatoms.) Onsager (1949) sagte dies voraus; Feynman kam unabhängig zum gleichen Ergebnis — heute **Onsager–Feynman-Wirbel**.

#### Wie ein Wirbel aussieht

Im Gegensatz zu rotierendem Kaffee kann sich das Suprafluid **nicht stufenlos** mitdrehen:

1. Es bleibt im Wesentlichen **in Ruhe**, bis die Rotation eine Schwelle überschreitet.
2. Dann „poppt" plötzlich ein **fadenförmiger Vortex** im Zentrum auf.
3. Im **Vortex-Kern** bricht die Suprafluidität zusammen ($\rho \to 0$) — ein mikroskopisches „Loch" in der Quantenflüssigkeit.
4. Bei höherer Rotation entstehen **weitere identische Wirbel**, oft in einem **Dreiecksgitter** (Abrikosov-Gitter).

Abrikosov übertrug das Konzept 1957 auf **Typ-II-Supraleiter**: Magnetfeldlinien dringen als quantisierte Wirbel ein — Nobelpreis 2003.

#### EABC-Lesefrage `[C]` (Wirbelachse)

| Physik-Bild | Strukturelle Lesart im EABC-Programm |
|---|---|
| Quantisierte Zirkulation $\Gamma = nh/m$ | Algebraischer Windungsindex $\mathrm{wind}_{\mathbb{H}}(O_v)$ (ORQ-080) |
| Phase $\theta$ muss sich beim Umlauf schließen | Holonomie entlang CEAB-Orbit-Schleife (ORQ-083); AB-Phasenanker (E-076 §4) |
| Vortex-Kern: Defekt, $\rho = 0$ | Gap-Rotor / isolierter „D'Artagnan"-Kanal im Dumas-Modell — lokaler Defektpunkt |
| Abrikosov-Gitter: diskretes Defektgitter | Regelmäßige Orbit-/Kanal-Anordnung auf Primvierling-Normalform |
| Kein stufenloses Mitdrehen | Diskrete Orbit-Schritte — kein kontinuierlicher Abstieg ohne Witness (Collatz V2.7) |

**Anschluss:** ORQ-080, ORQ-083; [`dumas_cone_orbit_model.md`](dumas_cone_orbit_model.md) (Gap-Rotor, Kepler-Kreis); [`orbit_symmetry_guide.md`](../orbit_symmetry_guide.md).

**Nicht behaupten:** Hurwitz-Orbits sind physikalische Vortex-Linien oder Abrikosov-Gitter.

---

### C. Fluss vs. Wirbel — struktureller Vergleich

| | **Flussquantisierung** | **Quantenwirbel** |
|---|---|---|
| **Kernbedingung** | Phasenschließung um geschlossenen Ring | Phasenschließung um geschlossene Schleife im Fluid |
| **Quantisierte Größe** | $\Phi = n h/2e$ | $\Gamma = n h/m$ |
| **Defekt-Bild** | Kein lokales Feld im Bulk (Meissner) | Fadenförmiger Kern mit $\rho = 0$ |
| **Entdeckungsdrama** | Faktor-2-Überraschung → Cooper-Paare | „Poppen" einzelner Wirbel statt starrer Rotation |
| **EABC-Anker** | Diskrete Kanal-Stufen, Projektions-Lift | Orbit-Windung, Holonomie, Gap-Defekt |
| **Geschwister in E-076** | von Klitzing / QHE | Aharonov–Bohm |

Beide Phänomene teilen **dieselbe logische Wurzel**: eine makroskopische Wellenfunktion erzwingt **Ganzzahligkeit** beim Umlauf. Der Unterschied liegt im **Träger** (Cooper-Paar-Ladung vs. Helium-Masse) und im **Defektbild** (feldfreier Bulk vs. Kern-Singularität).

---

## Vier Onsager-Achsen (Kurzindex)

### 1. Quantisierung des magnetischen Flusses (1953)

Siehe **Deep Dive §A** oben. Kurzformel: $\Phi_0 = h/(2e)$.

**EABC-Lesefrage `[C]`:** mod-$12$-Kanäle, E-072, `channel_entropy`.

**Nicht behaupten:** EABC liefert $\Phi_0$ oder Cooper-Paare.

---

### 2. Quantisierte Wirbel in Suprafluiden (1949)

Siehe **Deep Dive §B** oben. Kurzformel: $\Gamma = n h/m$.

**EABC-Lesefrage `[C]`:** ORQ-080, ORQ-083, Dumas Gap-Rotor.

**Nicht behaupten:** Hurwitz-Orbits sind physikalische Vortex-Linien.

---

### 3. Exakte Lösung des 2D-Ising-Modells (1944)

**Physik:** Onsager löste das zweidimensionale Ising-Modell exakt und bewies einen **Phasenübergang** aus mikroskopischen Spin-Wechselwirkungen — Grundstein konformer Feldtheorie.

**EABC-Lesefrage `[C]`:**

| Physik | EABC-Analog (nicht Identität) |
|---|---|
| Kritischer Punkt / Phasenübergang | Erster metrischer Separationsverlust $\mathrm{ShellSeparationLoss}(n_0)$ (ORQ-077) |
| 2D-Gitter-Struktur | Schalen-Einbettung $\iota_n : S_n \hookrightarrow \mathbb{R}^3$ (ORQ-078) |
| Skaleninvariante Kritikalität | Minkowski–Bouligand-Dimension $\dim_B(S)$ (ORQ-079) |
| Exakte Lösbarkeit | Dumas-Normalform H1–H11 als kombinatorische exakte Struktur `[A-T]`/`[B]` |

**Anschluss im Repo:** ORQ-077–079 (Shell-Geometrie); [`dumas_cone_orbit_model.md`](dumas_cone_orbit_model.md); [`fixed_locus_riemann_program.md`](fixed_locus_riemann_program.md) (spektrale Kritikalität, ORQ-088 — programmatisch getrennt).

**Nicht behaupten:** ShellSeparationLoss ist ein Ising-Übergang oder hat Onsager-Kritische Exponenten.

---

### 4. Onsager-Reziprozitätsbeziehungen (Nobelpreis 1968)

**Physik:** Thermodynamische Flüsse außerhalb des Gleichgewichts (Wärme, Strom) sind durch **Mikroskopische Reversibilität** (Zeitsymmetrie der Bewegungsgleichungen) gebunden:

$$L_{ij} = L_{ji} \quad \text{(Onsager-Koeffizienten)}$$

**EABC-Lesefrage `[C]`:**

| Physik | EABC-Analog (nicht Identität) |
|---|---|
| Mikroskopische Reversibilität | Zeitumkehr-Symmetrie von Orbit-Schritten / CEAB-Permutationen |
| Kreuz-Kopplungen ($L_{ij}$) | Links-/Rechts-Idealpfade $H\gamma$ vs.\ $\gamma H$ (ORQ-085, ORQ-087) |
| Nichtgleichgewichts-Flüsse | Net-Descent, Orbit-Kosten in Collatz V2.7 |

**Anschluss im Repo:** ORQ-087 (`weyl_commutator_diagnostics.py`); L4-Thermodynamik ([`l4_thermodynamic_structural_inspiration.md`](../l4_thermodynamic_structural_inspiration.md)); Collatz Net-Descent ([`collatz_v27_net_descent.md`](../collatz_v27_net_descent.md)).

**Nicht behaupten:** Onsager-Relationen beweisen $\Delta_{\mathrm{LR}}(\gamma)=0$ unter Zeitumkehr oder Dedekind-Symmetrie.

---

## Vergleichstabelle: vier Onsager-Achsen

| | **Flussquantisierung** | **Quantisierte Wirbel** | **2D-Ising** | **Reziprozität** |
|---|---|---|---|---|
| **Jahr** | 1953 | 1949 | 1944 | 1931/1968 |
| **Observable** | $\Phi = n \Phi_0$ | $\kappa = n h/m$ | Magnetisierung / Kritikalität | $L_{ij} = L_{ji}$ |
| **Diskretheit** | Ganzzahlige Flussquanten | Ganzzahlige Zirkulation | Phasenübergang bei $T_c$ | Symmetrie der Kopplungsmatrix |
| **EABC-Anker** | mod-$12$-Kanäle, Buckets | Orbit-Windung, Gap-Rotor | ShellSeparationLoss, $\dim_B$ | $\Delta_{\mathrm{LR}}$, Net-Descent |
| **Verwandte ORQ** | (E-072) | ORQ-080, ORQ-083 | ORQ-077–079 | ORQ-087, ORQ-085 |
| **Tag** | `[C]` | `[C]` | `[C]` | `[C]` |

---

## Bridge to EABC `[C]`

| Onsager-Bild | EABC / Hurwitz-Lesart | Status |
|---|---|---|
| Flussquant $\Phi_0$ | Diskrete Kanal-/Signatur-Stufen | `[C]` |
| Vortex-Zirkulation $\kappa$ | $\mathrm{wind}_{\mathbb{H}}(O_v)$, Holonomie | `[C]` |
| Ising-Phasenübergang | Metrischer Separationsverlust, Schalen-Kritikalität | `[C]` |
| Reversibilität $L_{ij}=L_{ji}$ | Idealpfad-Symmetrie, Kommutator-Defekt | `[C]` |

**Scope für dieses Repo:** Die vier Achsen sind **unabhängige Resonanzanker** — analog zu AB / Klitzing / Meissner in E-076, aber mit stärkerem Fokus auf **Diskretisierung, Umlauf, Kritikalität und Zeitumkehr**.

---

## Verhältnis zu E-076 (Physical Analogies)

$$\text{E-076 (AB / Klitzing / Meissner)} \;\parallel\; \text{E-089 (Onsager-Achsen)}$$

| E-076-Achse | Onsager-Ergänzung |
|---|---|
| von Klitzing / QHE (Plateaus) | Flussquantisierung $\Phi_0$ (supraleitender Kontext) |
| Aharonov–Bohm (Holonomie) | Quantisierte Wirbel (Zirkulation als Defekt) |
| Meissner (Bulk–Shell) | 2D-Ising (Phasenübergang / Kritikalität an Shell-Grenze) |
| — | Reziprozität (neu: Zeitumkehr / Pfad-Symmetrie) |

**Regel:** Ein Onsager-Befund darf **nicht** post hoc als AB-/Meissner-Bestätigung gelesen werden. Umgekehrt rechtfertigt E-076 **keine** Onsager-Hypothese.

---

## Vorgeschlagene Diagnostik `[B]` (noch nicht implementiert)

| Metrik | Definition / Idee | Verwandte Achse | Tag |
|---|---|---|---|
| **Diskretisierungs-Index** | Anteil ganzzahliger Kanal-Bucket-Grenzen vs.\ kontinuierliche Approximation | Flussquantisierung | `[B]` vorgeschlagen |
| **Zirkulations-Defekt** | Umlauf-Invariante entlang CEAB-Schleife vs.\ trivialer Pfad | Quantisierte Wirbel | `[B]` vorgeschlagen |
| **Separations-Kritikalitäts-Profil** | $\mathrm{ShellSeparationLoss}(n)$ vs.\ $n$ — Plateau-/Sprung-Charakter | 2D-Ising | `[B]` vorgeschlagen |
| **Reversibilitäts-Asymmetrie** | $\Delta_{\mathrm{LR}}(\gamma)$ unter Pfad-Umkehr vs.\ Vorwärts | Reziprozität | `[B]` — Stub in `weyl_commutator_diagnostics.py` |

**Governance:** Bis Export und Nullmodell-Trennung — **`[C]`-motiviert**, nicht `[B]`.

**Implementierung (Stub):** `src/kepler_hurwitz/onsager_vortex_diagnostics.py` · Tests: `tests/test_onsager_vortex_diagnostics.py`  
**Batch-Export:** `scripts/onsager_vortex_export.py` → `docs/exports/onsager_vortex_circulation_upto_1000000.csv`  
**Summary:** `docs/exports/onsager_vortex_circulation_upto_1000000.summary.json` — Governance-Metadaten (`status: B`, kein Physikclaim)  
**Nullmodelle (optional):** `--include-nullmodels shuffle,ceab` → erweiterte CSV mit `model_type` und Kontrastspalten

### Experimental export: vortex circulation records

The script `scripts/onsager_vortex_export.py` exports the combinatorial circulation
diagnostics for prime quadruplets `(p,p+2,p+6,p+8)` up to a chosen bound (`--limit`
applies to `p+8`).

The exported winding number is **not** interpreted as a physical vortex.
It records whether the Dumas Gap-Rotor loop closes discretely, encircles all four
D'Artagnan defect slots, and separates the non-trivial loop from the trivial loop.

**Status:** `[B]` experimental diagnostic.

**Title (governance):** `onsager_vortex_circulation` = Dumas/EABC circulation diagnostic,
not physics claim.

Strukturierte Diagnostik (Gap-Law-aware): `vortex_winding`, `phase_closure_ok`, `encircles_defect` erfordern gültige Dumas-Gap-Paare — reine Host-Zyklen allein reichen nicht.

| Analogie | Funktion | Mechanismus |
|---|---|---|
| Phasenschließung / Holonomie | `accumulate_holonomy_phase`, `holonomy_phase_closure_ok` | Diskrete Channel-Phase mod 4 schließt auf Gap-Rotor-Schleife |
| Windungsindex $n$ | `circulation_quantum_number` | Ein E→A→B→C-Zyklus = $n=1$; triviales Host-Loop = $n=0$ |
| Vortex-Kern ($\rho=0$) | `defect_musketeer_overlap`, `defect_core_prime` | D'Artagnan-Prim fehlt in Musketeer-Triple — strukturell 0 |
| Pop-Schwelle | `partial_rotor_winding` | Erst ab 4 Schritten $n\geq 1$ — kein partielles Mitdrehen |
| Defekt-Umschließung | `loop_encircles_defect_structure` | Alle 4 Host-Perspektiven / D'Artagnan-Slots besucht |
| CEAB-Schleife | `ceab_holonomy_loop` | Involutive 2-Schritt-Phase (`shiftCEAB² = Id`) |

---

## Minimaler Angriffspfad

Onsager-Sprache ist **interpretativ** und folgt dem Open-Core-Pfad:

\[
\boxed{
\text{interne Geometrie (ORQ-077–079)} \;\to\; \text{arithmetischer Test} \;\to\; \text{Onsager-Deutung}
}
\]

1. **Nicht** mit Ising-Kritikalität beginnen, um $n_0$ vorzuwählen.
2. **Nicht** Flussquantisierung als Beweis für mod-$12$-Plateaus verwenden.
3. Wirbel-/Holonomie-Sprache erst **nach** reproduzierbarem Orbit-Index (ORQ-080/083).
4. Reziprozitäts-Lesart komplementär zu ORQ-087 — nicht als Ersatz.

---

## Governance-Tabelle

| Claim | Erlaubt? | Tag |
|---|---|---|
| Onsager-Wirbel erklären Dumas-Gap-Rotor | Nein — nur interpretative Parallele | `[C]` |
| $\Phi_0$-Analogie für mod-$12$-Kanäle | Ja — als **Analogie** gekennzeichnet | `[C]` |
| ShellSeparationLoss ist Ising-$T_c$ | Nein | — |
| Reversibilität $\Rightarrow$ $\Delta_{\mathrm{LR}}=0$ | Nein — Hypothese, nicht Satz | `[C]` |
| Onsager-Diagnostik-Export | Ja — wenn reproduzierbar | `[B]` |
| Onsager in Lean `[A]` hochstufen | Nein | — |

---

## Querverweise

| Dokument | Rolle |
|---|---|
| [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md) | Geschwister E-076 (AB / Klitzing / Meissner) |
| [`weyl_commutator_operator_bridge.md`](weyl_commutator_operator_bridge.md) | ORQ-087 — Reversibilitäts-Komplement |
| [`weyl_onsager_bridge_attack.md`](weyl_onsager_bridge_attack.md) | ORQ-089 ↔ ORQ-087 Ordnungs-Defekt-Parallelismus |
| [`open_mathematical_bridge_targets.md`](../open_mathematical_bridge_targets.md) | ORQ-077–087 Kanonischer Katalog |
| [`dumas_cone_orbit_model.md`](dumas_cone_orbit_model.md) | Wirbel-/Orbit-Normalform |
| [`greens_stokes_circulation_bridge.md`](greens_stokes_circulation_bridge.md) | Green/Stokes Rand↔Curl-Referenz; numerische Scheiben-Verifikation `[B]` |
| [`distilled_parameters.md`](distilled_parameters.md) | Diagnostik-API |
| [`l4_thermodynamic_structural_inspiration.md`](../l4_thermodynamic_structural_inspiration.md) | Thermodynamische Metasprache |
| [`l4_reference_matrix.md`](../l4_reference_matrix.md) | L4-Strukturmatrix |

---

## Zusammenfassung

Lars Onsagers vier Grundbeiträge — **Flussquantisierung**, **quantisierte Wirbel**, **2D-Ising-Lösung**, **Reziprozitätsbeziehungen** — liefern im Kepler-Hurrwitz-Programm **vier komplementäre Resonanzachsen** für diskrete EABC-Strukturen:

1. **Diskretisierung** — ganzzahlige Kanal-/Signatur-Stufen
2. **Umlauf / Defekt** — Windungsindex und Holonomie auf Orbits
3. **Kritikalität** — metrischer Phasenübergang an Schalen-Grenzen
4. **Reversibilität** — Symmetrie von Idealpfaden und Kommutator-Defekten

Keine dieser Achsen beweist EABC, Dedekind-Idealstruktur oder Renorm-Restauration. Sie strukturieren **interpretative Lesefragen** in Phase `[C]` — ergänzend zu E-076, strikt getrennt von Dumas-Empirie und Shell-Diagnostik.
