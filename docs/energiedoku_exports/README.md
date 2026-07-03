# Energiedoku Exporte

Diese Dateien werden durch `examples/export_energiedoku_artifacts.py` erzeugt und dokumentieren
die Orbit- und Invarianz-Auswertungen fuer Primvierlinge, die Bahnreduktion
zyklischer Woerter sowie den Smoothness-Kanal-Scan der e-Schalenspruenge.

## Dateien

- `primvierling.json`
- `primvierling.csv`
- `cyclic_words.json`
- `cyclic_words.csv`
- `smoothness_channels.json`
- `smoothness_channels.csv`
- `smoothness_significance.json`
- `smoothness_scale_stability.json`
- `smoothness_b_bound_matrix.json`
- `smoothness_b_bound_summary.json`
- `octonionic_slice_constraints.json`
- `octonionic_slice_constraints.csv`
- `interference_b11_study.json`

## Primvierling-Schema

Jede Zeile (CSV) bzw. jedes Objekt in `analyses` (JSON) repraesentiert **eine Invariante fuer einen Primvierling**.

Felder:

- `base`: Basis-4-Tupel `[a, b, c, e]` als kanonischer Primvierling
- `orbit`: Bahn unter der Gruppenwirkung `abce -> ceab`
- `invariant_name`: Name der geprueften Observable
  - typische Werte: `sum`, `multiset`, `pair_gaps`, `quat_norm`, `quat_reduced_norm`
- `is_invariant`: Boolescher Wert (`true`/`false`)
- `orbit_values`: Observable-Werte fuer alle Orbit-Elemente in derselben Reihenfolge wie `orbit`

Interpretation:

- `is_invariant = true`: die Observable ist auf der gesamten Bahn konstant
- `is_invariant = false`: die Observable unterscheidet Orbit-Zustaende und ist damit keine EABC-Invariante

## Zyklische Wort-Schema

Jede Zeile (CSV) bzw. jedes Objekt in `classes` (JSON) repraesentiert **eine Orbit-Klasse unter zyklischer Rotation**.

Felder:

- `canonical`: lexikographisch kleinster Repraesentant der Klasse
- `size`: Anzahl der Woerter in der Klasse
- `members`: alle zugehoerigen Woerter (als Liste)

Interpretation:

- Woerter mit gleichem `canonical` sind aequivalent bis auf Startpunktwahl.
- Fuer Suchpipelines (z. B. Collatz-Wortfilter) kann pro Klasse nur ein Repraesentant getestet werden.

## Smoothness-Kanal-Schema

Die Smoothness-Exporte fassen den Zusammenhang zwischen Schalenkanal
(`delta_e = nu2(3m+1)`) und B-Glattheit des naechsten ungeraden Kerns zusammen.

### `smoothness_channels.csv`

Eine Zeile pro Kanal:

- `channel`: `klein`, `mittel` oder `tief`
- `total`: Anzahl der Samples im Kanal
- `b_smooth`: Anzahl der Samples mit B-glattem Folgekern
- `ratio`: `b_smooth / total`
- `limit_m`: obere Scan-Grenze fuer ungerade Kerne
- `b`: B-Schranke fuer Glattheit

### `smoothness_channels.json`

Top-level-Felder:

- `metadata`: Reproduktionsdaten
  - `generated_at_utc`
  - `limit_m`
  - `b`
  - `sample_count`
  - `script_version`
- `summary`: Kanalaggregation wie in der CSV
- `samples`: detaillierte Einzeldaten pro ungeradem `m`
  - `m`, `mod8`, `delta_e`, `channel`, `next_core`, `b`, `is_b_smooth`

## Signifikanz-Schema

`smoothness_significance.json` enthaelt den Chi-Quadrat-Unabhaengigkeitstest
fuer die 2x3-Kontingenztafel:

- Zeilen: `klein`, `mittel`, `tief`
- Spalten: `b_smooth`, `not_b_smooth`

Top-level:

- `metadata`:
  - `generated_at_utc`
  - `limit_m`
  - `b`
  - `sample_count`
  - `test_name` (aktuell `chi_square_independence`)
- `result`:
  - `chi2`
  - `p_value`
  - `degrees_of_freedom` (hier `2`)
  - `sample_count`
  - `cramers_v`
  - `observed` (beobachtete Haeufigkeiten)
  - `expected` (unter Unabhaengigkeit erwartete Haeufigkeiten)

## Skalenstabilitaets-Schema

`smoothness_scale_stability.json` dokumentiert die Entwicklung von `chi2`,
`p_value` und Cramer's `V` ueber mehrere Scan-Groessenordnungen.

Top-level:

- `generated_at_utc`
- `b_bound`
- `script_version`
- `scales`: Liste von Punkten mit
  - `limit_m`
  - `sample_size`
  - `chi2`
  - `p_value`
  - `cramers_v`

## B-Bound-Matrix-Schema

`smoothness_b_bound_matrix.json` enthaelt die Kreuzanalyse ueber mehrere
Glattheitsschranken `B` und Skalen `limit_m`.

Top-level:

- `generated_at_utc`
- `script_version`
- `limits`: verwendete Scan-Grenzen
- `scans`: Liste von B-Bound-Segmenten
  - `b_bound`
  - `results`: Liste von Punkten mit
    - `limit_m`
    - `sample_size`
    - `chi2`
    - `p_value`
    - `cramers_v`

## B-Bound-Summary-Schema

`smoothness_b_bound_summary.json` verdichtet die B-Matrix in Trendmetriken
und ein Ranking fuer die Energiedoku.

Top-level:

- `generated_at_utc`
- `script_version`
- `limits`
- `summary`
  - `most_stable_b_bound`
  - `max_effect_size_scale_last`
- `trends` mit je
  - `b_bound`
  - `v_start`
  - `v_end`
  - `v_delta`
  - `v_ratio`
  - `log10_p_start`
  - `log10_p_end`
  - `log10_p_delta`
  - `stability_score`

## Oktonionischer Slice-Schema

Die oktonionischen Exporte bilden die Grigorian-Loci im `(mu, Q)`-Plane als
harte algebraische Randbedingungen ab und halten gleichzeitig die
spur-/norminvarianten Residuen fest.

### `octonionic_slice_constraints.csv`

Eine Zeile pro Gitterpunkt `(mu, Q)`:

- `mu`, `q`: Slice-Koordinaten
- `trace`, `norm`: Invarianten-Surrogate fuer `lambda = mu + Q*u`, `u^2 = -1`
- `quartic_mu_q_residual`: Residuum der Quartik im `(mu, Q)`-Plane
- `circle_mu_q_residual`: Residuum des Kreises im `(mu, Q)`-Plane
- `quartic_trace_norm_residual`: Residuum der Invariantenform
- `circle_trace_norm_residual`: Residuum der linearen Invariantenform
- `class`: `quartic`, `circle`, `both` oder `none`

### `octonionic_slice_constraints.json`

Top-level:

- `metadata`:
  - `generated_at_utc`
  - `script_version`
  - `mu_values`
  - `q_values`
  - `grid_size`
- `assumptions`:
  - `quaternionic_associator_vanishes` (sollte `true` sein)
- `interference_points`:
  - die beiden Schnittpunkte `(-5/2, ±sqrt(15)/2)`
- `records`: dieselben Punktdaten wie in der CSV

## Reproduktion

Im Projektwurzelverzeichnis ausfuehren:

`python examples/export_energiedoku_artifacts.py`

## Dumas / Musketiere Evidence Chain (E-046 → E-048 → E-032 → E-026)

**Status:** Die Lücke im Host-Tripel ist kein Verlust, sondern die Codierung des Hosts.
Die Dumas-Schicht formalisiert die Host-Auslassung als informationsaequivalente Komplementstruktur
(`dumas_gap_encodes_host`, Alias `holographic_omission_gap_encodes_host` in
`KeplerHurwitz/PrimvierlingSymmetry.lean`).

| Ebene | ID | Funktion | Status |
|---|---|---|---|
| Kanal / Primvierling | E-046 | `hostTriple` als Gap-Menge; Komplementaritaet | `[A-T]` bewiesen |
| Dumas | E-048 | `dumasLemma`, Gap kodiert Host | `[A-T]` bewiesen |
| Ikosaeder-Bruecke | E-032 | `LabelIntertwiningGraphAuto` → kanonischer Transfer | `[A-T]` in Arbeit (1 `sorry`) |
| Zielhypothese | E-026 | `MusketiereNeighborTripleHypothesis` | `[C]` offen |

Dossier: `docs/dumas_lemma.md` · Getrennt von Collatz-V2: `docs/collatz_v2_evidence_chain.md`

## Collatz-V2 (lokale Evidence Chain, getrennt)

Lokale arithmetische Evidenz — **nicht** Teil der Energiedoku-Floquet- oder Dumas-Kette.
Offene globale Schicht: `CollatzMod4ThreeGlobalDescentStatement`.
Siehe `docs/collatz_v2_evidence_chain.md`.

## Optionale SageMath-Bruecke

Fuer symbolische Eliminierung (Resultanten) der Grigorian-Slice-Loci steht
`src/kepler_hurwitz/sage_bridge.py` bereit.

- kein harter Runtime-Import: Sage wird erst beim Aufruf geladen
- Arbeitsring: `QQ[mu,S]` mit `S=Q^2`
- zentrale API:
  - `sage_loci_polynomials()`
  - `sage_verify_interference_points()`
  - `sage_resultant_mu()`
  - `sage_resultant_Q()`

CLI-Beispiel:

`sage -python examples/run_sage_bridge.py`

JSON-Ausgabe als Artefakt:

`sage -python examples/run_sage_bridge.py --json --out docs/energiedoku_exports/sage_symbolic_constraints.json`

Die Bruecke nutzt `S=Q^2`, damit die Eliminierung der beiden `(mu,Q)`-Loci
exakt im rationalen Polynomring erfolgen kann.

## Sage-Schemaartefakt

Die Datei

`docs/energiedoku_exports/sage_symbolic_constraints.schema.json`

ist ein statisches Schema-/Template-Artefakt fuer nachgelagerte Pipelines.
Sie enthaelt bewusst keine berechneten SageMath-Resultanten.

Die echte, berechnete Ausgabe wird explizit erzeugt mit:

`sage -python examples/run_sage_bridge.py --json --out docs/energiedoku_exports/sage_symbolic_constraints.json`

## Interference-B11-Bridge-Studie

`interference_b11_study.json` dokumentiert eine reproduzierbare `[B]`-Studie
fuer die operative Bruecke `Interference -> Restklasse -> B11`.

Reproduktion:

`python examples/run_interference_b11_study.py`
