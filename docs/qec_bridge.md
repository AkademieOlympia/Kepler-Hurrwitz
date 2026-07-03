# Fano-QEC-Brücke

Forschungsblock **„Dyadische Wurzeln, Fano-Stabilisatoren und Schalen-Syndrome“**  
(kurz: **Fano-QEC-Brücke**)

**Status (v1):** QEC-Block E-038–E-042 + S8 **eingefroren** (2026-07-03). Keine weiteren Suchläufe ohne neues Evidenz-Register-Item.

Dieses Dokument definiert die defensive QEC-kompatible Lesart der bereits
vorhandenen EABC-/Kepler-Hurwitz-Strukturen. Es behauptet **nicht**, dass
Raumzeit ein Quantenfehlerkorrekturcode ist.

## Zentrale Forschungsfrage

> Welche endlichen Stabilisatorrelationen werden durch die Fano-Tripel und
> dyadischen Hurwitz-Wurzeln erzwungen?

## Arbeitshypothese `[C]`

> Schalenresonanzen entsprechen nicht bloß numerischen Attraktoren, sondern
> diskreten Syndromklassen.

Die Hypothese ist **programmatisch** und wird erst nach vollständiger
kombinatorischer Prüfung (Stufe 1–2) interpretativ verwendet (Stufe 3).

## Claim-Klassen

| Klasse | Bedeutung | In diesem Block |
|--------|-----------|-----------------|
| `[A]` | formal bewiesen (Lean) | nur indirekt (Oktonion-Multiplikationstabelle) |
| `[B]` | reproduzierbar numerisch/kombinatorisch | Fano-Closure, Syndrompartition, Klassenzählungen |
| `[C]` | offene Hypothese/Interface | Schalen ↔ Syndrom, QEC-Analogie |
| `L4` | programmatische Interpretation | „algebraischer Mechanismus für Schalenstabilität“ |

## Begriffszuordnung

| Bisheriger Begriff | QEC-Brückenbegriff | Evidenz |
|--------------------|--------------------|---------|
| Fano-Tripel | Stabilisator-Generatoren (Paritätschecks) | `discrete_time_flow.fano_triples()` |
| Assoziator-Kollaps | Fehlerneutralisierung (assoziativer Zweig) | E-037 |
| Metakommutations-Paare | Syndrom-Übergänge | E-037 |
| Schalen-Pumpen | diskrete Korrekturdynamik | E-036 |
| Fixpunkte bei `N=4,8` | stabile Code-Unterräume | E-036 |
| Bifurkation bei `N=6` | nichttriviale Syndromspaltung | E-036 |

## Drei Prüfstufen

### Stufe 1 — Reine Kombinatorik `[B]`

- 7 Fano-Linien → 7 Paritätsmasken auf den 7 imaginären Einheiten
- Rang über **GF(2)**: **4** unabhängige Generatoren (Linienabhängigkeiten; kein voller Steane-Rang 6 ohne Zusatzstruktur)
- 112 dyadische Norm-2-Wurzeln → Support-Klassen, Fano-Ausrichtung, Realachse-Anteil

Implementierung: `kepler_hurwitz.qec_bridge`

### Stufe 2b — CSS-Projektion der 4 Generatoren `[B]`

Aus den 7 Fano-Linien (je Gewicht 3) folgt über **GF(2)**:

| Größe | Fano-Parität | Steane `[[7,1,3]]` Referenz |
|-------|--------------|-------------------------------|
| Zeilenraum-Rang | **4** | **3** (`H_X`) + **3** (`H_Z`) = 6 CSS-Generatoren |
| Kern-Dimension | **3** | 1 (logisches Qubit) |
| Zeilenraum-Schnitt mit `H_X` | **Dimension 1** | — |
| `H_X` ⊆ Fano-Zeilenraum? | **nein** | — |
| Min. Hamming-Gewicht im Kern | **4** | **3** (klassische Distanz) |

**Interpretation (defensiv):** Die erste Fano-Linie `(1,2,3)` stimmt mit der ersten
Steane-`H_X`-Zeile überein, aber die vollen Zeilenräume **brechen die Symmetrie**:
Rang 4 statt 3, Schnittdimension 1, Mindestgewicht 4 statt 3. Das ist kein Defekt —
es verhindert vorschnelle Identifikation mit dem klassischen Steane-Code.

Implementierung: `analyze_css_projection()` in `qec_bridge.py`  
Export-Feld: `css_projection` in `qec_bridge.json`

### Stufe 2 — Code-Struktur `[B]`

- Syndromtabelle aus der Metakommutation (E-037): Partition nach
  `(assoziativ/nicht-assoziativ, dyadischer/halbgitter Partner, Partner-Vielfachheit)`
- Keine physikalische Interpretation — nur degeneracy counts und closure checks

Export: `docs/energiedoku_exports/qec_bridge.json` (via `examples/run_qec_bridge_analysis.py`)

### Stufe 2c — E-039-pre: Fano-Kernfreiheiten ↔ Schalenkandidaten `[C]`

Funktion: `analyze_fano_kernel_shell_map()`

| Befund | Wert |
|--------|------|
| `dim ker(R_Fano)` | 3 |
| `\|ker\|` | 8 |
| Gewichtsprofil | `{0:1, 4:7}` |
| `d_min` (nichttrivial) | 4 |
| GL(3,GF(2))-Invarianz | Gewichtsprofil, Mindestgewicht, Schalen-Distanzen ja; Koordinatenlabels nein |

Schalenkarte (Kandidaten, keine Kausalidentifikation):

| Shell | Stabilisierung (E-036) | Distanz zu `ker` | Koordinaten (basisabhängig) |
|-------|------------------------|------------------|----------------------------|
| N=4 | Pumpen, Fixpunkt | 1 | (0,1,0) |
| N=6 | Bifurkation | 1 | (1,0,0) |
| N=8 | Fixpunkt | 1 | (0,1,0) |

**Hinweis:** N=4 und N=8 teilen dieselben nächsten Kernkoordinaten — Upgrade zu E-039 `[B]` erfordert basisunabhängige Koset-Trennung.

Export: `docs/energiedoku_exports/fano_kernel_shell_map.json`  
Register: **E-039-pre `[C]`**

### Stufe 2d — Koset-Quotient modulo ker(R_Fano) `[C]`

Funktion: `analyze_shell_cosets_mod_kernel()`

| Shell | Parität v_N | Syndrom σ_N | Koset vs N=8 |
|-------|-------------|-------------|--------------|
| N=4 | (1,0,0,0,0,0,0) | (1,0,0,0) | **gleich** |
| N=6 | (0,0,0,1,0,0,0) | (0,0,0,1) | verschieden |
| N=8 | (1,0,0,0,0,0,0) | (1,0,0,0) | — |

**Upgrade-Test:** `sigma_4 != sigma_8` ist **false** — N=4 und N=8 haben identische dyadische Paritätsvektoren, daher dasselbe Koset. E-039 bleibt `[C]` (`e039_upgrade_eligible=false`). N=6 ist quotient-invariant getrennt.

Syndrom-Labels sind GL(3,GF(2))-invariant; nächste Kernkoordinaten **nicht** als Invariante verwendet.

Export: `docs/energiedoku_exports/fano_shell_cosets.json`

### Stufe 2e — E-040-pre: verfeinerte Shell-Projektion `[C]`

Funktion: `analyze_refined_shell_projection()`

**Leitformel E-039:** σ₄ = σ₈, σ₆ ≠ σ₄.

Drei kanonische Verfeinerungen (vor Label-Vergleich definiert):

| Modus | Trennt N=4/N=8? | N=6-Trennung erhalten? |
|-------|-----------------|------------------------|
| `hurwitz_residue` (volle Projektion) | ja | ja |
| `signed_support` | ja | ja |
| `real_axis` | ja | ja |

**Negativer Teilsatz:** `residue_key` allein (Projektionsrest modulo nearest dyadic) ist für N=4 und N=8 **identisch** — Verfeinerung braucht volle Hurwitz-Projektion oder Vorzeichen.

E-039 bleibt negativer GF(2)-Quotient-Test; E-040-pre ist **kein** automatisches E-039-Upgrade.

Export: `docs/energiedoku_exports/refined_shell_projection.json`

### Stufe 2f — E-041: signierte Shell-Syndrome `[B]`

Funktionen: `analyze_signed_shell_syndromes()`, `analyze_refined_shell_cosets(mode="signed_support")`

**Claim:** `signed_support` trennt N=4, N=6, N=8 paarweise und hebt die E-039 GF(2)-Kollision (σ₄=σ₈) auf — **ohne E-039 zu revidieren**.

**Primär:** `signed_support` — **Kontrolle:** `full_hurwitz_projection` — **Ausgeschlossen:** `residue_key` allein

| Relation | signed_support | residue_only |
|----------|----------------|--------------|
| N=4 vs N=8 | **getrennt** | gleich |
| N=6 vs N=4/N=8 | getrennt | getrennt |

σ₄=σ₈ bleibt als negative GF(2)-Aussage (E-039 `[C]`) erhalten. Upgrade: `upgraded_from_pre`, validiert durch E-042.

Export: `docs/energiedoku_exports/signed_shell_syndromes.json`

### Stufe 2g — E-042 `[C]`: Symmetrieinvarianz (Invarianzvalidator)

**E-041 `[B]` ist der Strukturclaim; E-042 `[C]` ist der Invarianzvalidator.**

Funktionen: `model_symmetry_group_specification()`, `enumerate_model_symmetry_group()`, `analyze_signed_support_symmetry_invariance()`

**Symmetriegruppe (vor Auswertung definiert):**

\[
G_{\mathrm{model}}
=
\mathrm{Aut}(\mathrm{Fano}_7)
\times
\mathbb{Z}_2^{\mathrm{global\,imag\,sign}},
\qquad
|G_{\mathrm{model}}|=336.
\]

- **Aut(Fano_7):** Permutationen der imaginären Achsen {1,…,7}, die alle Fano-Linien erhalten
- **$\mathbb{Z}_2^{\mathrm{global\,imag\,sign}}$:** globaler Vorzeichenflip auf allen imaginären Koordinaten; Realachse fix

| Paar | ∀g∈G: sig(gN₄)≠sig(gN₈)? |
|------|---------------------------|
| N=4 vs N=8 | ja (0 Fehler / 336) |
| N=4 vs N=6 | ja |
| N=6 vs N=8 | ja |

**Upgrade-Bedingungen (erfüllt):** Kanonizität ✓, Symmetrieinvarianz ✓, Reproduzierbarkeit ✓ → E-041 auf `[B]` gehoben (`upgraded_from_pre`).

Export: `docs/energiedoku_exports/signed_support_symmetry.json`

Example: `examples/run_signed_support_symmetry.py`

### Stufe 2h — Governance-Freeze und S8 `[B]` (Paper-Proposition)

**Status:** QEC-Block E-038–E-042 eingefroren (2026-07-03). Keil B abgeschlossen genug fuer Keil A/N-Body ohne offene Governance-Schulden.

| ID | Klasse | Rolle |
|---|---|---|
| E-038 | `[B]` | Steane-kompatibel, aber nicht Steane-identisch |
| E-039 | `[C]` | negativer GF(2)-Quotiententest |
| E-040 | `[C]` | Verfeinerungskatalog |
| E-041 | `[B]` | signierte Support-Trennung |
| E-042 | `[C]` | Symmetrievalidator |
| **S8** | **`[B]`** | kondensierter Strukturclaim fürs Paper |

#### Proposition S8: Signierte Fano-Shell-Trennung

Die reine dyadische GF(2)-Projektion trennt (N=4) und (N=8) nicht: \(\sigma_4=\sigma_8\), \(\sigma_6\neq\sigma_4\). Die kanonische `signed_support`-Verfeinerung trennt (N=4,6,8) paarweise und bleibt unter

\[
G_{\mathrm{model}} = \mathrm{Aut}(\mathrm{Fano}_7) \times \mathbb{Z}_2^{\mathrm{global\,imag\,sign}}, \quad |G_{\mathrm{model}}|=336
\]

für alle \(g\in G_{\mathrm{model}}\) invariant (0 Fehler / 336).

**Defensive Schlussfolgerung:** Die verlorene N=4/N=8-Unterscheidung liegt in der symmetrieinvarianten Vorzeichen-/Support-Schicht — nicht im GF(2)-Quotienten. Keine kausale Pumpen/Fixpunkt/Bifurkations-Identifikation.

**Paper-Satz:** E-039 zeigt die Grenze der reinen GF(2)-Quotientenprojektion. E-041 überschreitet diese Grenze nicht durch nachträgliche Anpassung, sondern durch eine vorab definierte signierte Support-Projektion, deren Trennung in E-042 unter der vollständigen Modell-Symmetriegruppe invariant bleibt.

### Stufe 3 — Interpretation `[C]` / `L4`

Erst nach Stufe 1–2:

> Die Kepler-/EABC-/Oktonionen-Struktur verhält sich *wie* ein geometrischer
> Fehlerkorrekturmechanismus.

Schalen-Stabilisierungsklassen (E-036) erhalten **grobe** Syndrom-Labels
(Fixpunkt → stabiler Unterraum, Bifurkation → Spaltung, …). Das ist eine
Analogietabelle, keine Bijektion.

## Sprachregeln (defensiv)

**Vermeiden:**

- „unanfechtbar“, „bewiesen, dass Raumzeit QEC ist“
- starre Bijektion auf das unendliche `(E_8)`-Gitter
- deterministische Erklärung der Gravitation

**Verwenden:**

- reproduzierbar, formal isoliert, numerisch stabil
- kombinatorisch vollständig geprüft
- QEC-kompatible Stabilisatorstruktur
- algebraischer Mechanismus für Schalenstabilität

## Architektur: zuerst Code, dann Kosmos

1. **Fano-QEC-Brücke** (dieser Block) — endlich, diskret, testbar; **eingefroren** (E-038–E-042, S8)
2. **N-Body-Brücke** (naechste Stufe) — dynamische Anwendung stabilisierter Schalen-Syndrome

Die N-Body-Richtung bleibt explizit **zweite Stufe** und baut auf E-036/E-037 auf.

## Artefakte

| Artefakt | Zweck |
|----------|-------|
| `docs/qec_bridge.md` | Begriffe, Hypothesen, Claim-Klassen |
| `src/kepler_hurwitz/qec_bridge.py` | Fano-Stabilisatoren, Wurzelklassen, Syndromtabellen |
| `tests/test_qec_bridge.py` | closure, involution, commutation, partition, degeneracy |
| `examples/run_qec_bridge_analysis.py` | Reproduzierbarer Export E-038 |
| `examples/run_fano_kernel_shell_map.py` | E-039 Kernel/Shell-Map |
| `examples/run_fano_shell_cosets.py` | E-039 Koset-Quotient |
| `examples/run_signed_shell_syndromes.py` | E-041 signierte Syndrome |
| `examples/run_signed_support_symmetry.py` | E-042 Symmetrieinvarianz |
| `examples/run_qec_stabilizer_check.py` | E-044 [[5,1,3]]-Stabilisator-Brücke |
| `docs/paper-outline.md` §4.6 | Proposition S8 `[B]` |

### Erweiterung E-044: [[5,1,3]]-Stabilisator-Brücke `[C]`

Parallel zur Fano/Steane-Abgrenzung (E-038) projiziert `map_dyadic_to_stabilizers()` alle
112 dyadischen Norm-2-Wurzeln auf die 15 nichttrivialen Stabilisatoren des
kanonischen `[[5,1,3]]`-Codes (Generatoren `XZZXI`, `IXZZX`, `XIXZZ`, `ZXIXZ`).

| Größe | Ergebnis |
|---|---|
| Stabilisatoren | **15** (alle paarweise kommutierend) |
| Match-Paare | **1680** = 112 × 15 |
| Code-Space-Anteil (`commutation_signum=+1`) | **784 / 1680** |
| Distinkte symplektische Wurzelklassen | **> 1** |
| Shell-Kommutationsquote N=4/6/8 | **7/15** (entartet, identisch) |

**Defensive Lesart:** Die [[5,1,3]]-Projektion liefert eine vollständige
Pauli-Stabilisator-Tabelle, trennt die Shell-Proxies N=4/6/8 in dieser
Kommutationsstatistik jedoch **nicht**. Die empirisch validierte Trennung
bleibt in E-037 (`associative_ratio`: 1.0 vs 0.767). Keine Behauptung, dass
Raumzeit der `[[5,1,3]]`-Code ist.

Export: `docs/energiedoku_exports/five_qubit_stabilizer_bridge.json`

### Erweiterung E-045-pre: signiertes Stabilizer-Profil `[C]`

Funktion: `analyze_signed_stabilizer_support_profile()`

| Ebene | Befund |
|---|---|
| Skalar (E-044) | #(+1)=7/15 für N=4,6,8 |
| Rohprofile \(v_N\) | paarweise **verschieden** |
| Orbit unter \(G_{\mathrm{5-code}}\) (|G|=20) | **identisch** |

**Negativ:** Orbitklassen trennen N=4/6/8 nicht → `e045_upgrade_eligible=false`. Kein E-044-„Rettungsmanöver“.

Export: `docs/energiedoku_exports/signed_stabilizer_support_profile.json`

## Abhängigkeiten

- E-037: `metacommutation.py`, `dyadic_metacommutation.json`
- E-036: `arithmetic_evolution.py`, `arithmetic_transition_matrix.json`
- Oktonion-Basis: `discrete_time_flow.py`

## Naechste Stufe (nach Governance-Freeze)

Der QEC-Block E-038–E-042 + S8 ist eingefroren. Offene Arbeit liegt ausserhalb dieses Blocks:

- **Keil A / N-Body-Brücke:** dynamische Anwendung stabilisierter Schalen-Syndrome (baut auf E-036/E-037/S8 auf)
- **Manuskript:** S8-Proposition in `docs/paper_draft.tex` einfuegen
- **Lean (optional):** Fano-Closure als infrastrukturelles Lemma
