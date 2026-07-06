# Tao-inspirierte Collatz-Diagnostics (Syracuse / First Passage)

**Code:** `src/kepler_hurwitz/tao_collatz_diagnostics.py` · **Export:** `examples/run_tao_collatz_diagnostics_export.py`

**Verwandt:** [`collatz_analytical_perspectives.md`](collatz_analytical_perspectives.md) · [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) (V2.7)

> **Governance.** This module is **[B] numerical diagnostics only** — Syracuse valuation profiles, first-passage statistics, and Geom(2) marginal comparisons. It does **not** prove the Collatz conjecture, does **not** formalize Tao (2019), and does **not** establish IID Geom(2) structure, Tao-style stabilization, or class-specific density theorems.

> **Governance.** Dieses Modul ist ausschließlich **[B] numerische Diagnostik** — Syracuse-Valuation-Profile, First-Passage-Statistik und Geom(2)-Marginalvergleiche. Es beweist **nicht** die Collatz-Vermutung, formalisiert **nicht** Tao (2019) und etabliert **weder** IID-Geom(2)-Struktur **noch** Tao-Stabilisierung **noch** klassenspezifische Dichtesätze.

---

## Defensive interpretation (English)

> **Measured [B]**
>
> - Pooled **marginal** valuation histogram vs Geom(2), with **tail-corrected** total-variation distance
> - **Relative** first passage to `floor(N/2)` as a net-descent diagnostic per start value `N`
> - Companion **Tao-style fixed-x** first passage at `x ∈ {10, 100, 1000, 10000}` (labeled separately in summary JSON)
> - Lag-1 autocorrelation and positional Geom(2) distances (marginal at each step index)
> - Continuous **log-scale approximation** sampling over odd integers (not exact discrete `1/n` unless using `discrete_log_odd_sample`)

> **NOT measured — do not over-read**
>
> - Full **IID** Geom(2) independence of valuation steps (pair test is a simple deviation check only)
> - Tao (2019) proof or formalization
> - Collatz conjecture / global termination

---

## Claim-Grenze (verbatim)

> **Governance [B] only**
>
> - Does NOT prove Collatz
> - Does NOT formalize Tao's proof
> - Inspired by Tao 2019 (arXiv:1909.03562) for numerical experiments
> - Link to Collatz V2.7: first passage ↔ witness descent, valuation profile ↔ BadRun/2-adic

---

## Namensabgrenzung: Tao vs. τ (tau)

| Bezeichnung | Bedeutung | Code / Formalisierung |
|---|---|---|
| **Tao** | Terence Tao (2019): Collatz/Syracuse, Dichte-Aussagen, First-Passage, Geom(2)-Heuristik für Valuation-Profile | `tao_collatz_diagnostics.py`, dieses Dokument |
| **τ (tau)** | EABC-Kanal-Gauge (`EABCChannel ≃ EABCChannel`) oder Orbit-Phase in Kepler-Zeit — **unabhängig** von Collatz/Tao | `DreiMusketiere.lean` (E-031/E-032), `discrete_time_flow.py` |

**Häufige Verwechslung:** Fragen wie „Tao-Superposition auf der Kleinschen Vierergruppe“ meinen **Tao** (Syracuse-/Ensemble-Heuristik auf ungeraden Restklassen), **nicht** τ-Superposition auf EABC-Kanälen. Der Begriff „Tau-Superposition“ existiert im Repo **nicht** als definierter Term.

**Klein-Vierergruppe im Collatz-Kontext:** `KeplerHurwitz/KleinCollapse.lean` — vier ungerade mod-8-Klassen `{1,3,5,7}`. Bezug zu Tao ist höchstens **`[C]`-Analogie** (vier Buckets); kein formaler Beweislink zu `BadRunNetDescentWitness` oder zu τ-Gauge.

---

## Tao-Notation (Lesesprache)

Terence Tao (2019) arbeitet mit Collatz-Orbits und Dichte-Aussagen: Tao zeigt, dass **fast alle Orbits im Sinne der logarithmischen Dichte** irgendwann „fast beschränkte“ Werte erreichen — **logarithmisch fast alle** Startwerte, nicht für alle Startwerte und nicht im Sinne einer vollständigen natürlichen-Dichte- oder Einzelklassen-Aussage. Für die numerische Spiegelung in diesem Modul:

| Symbol | Bedeutung (Modul) | V2.7-Analog |
|---|---|---|
| **Col_min** | Truncated Col_min/Syr_min-Analog bis `max_steps` (`syracuse_orbit_min` / Export `orbit_min`) | lokaler Abstieg / Shrink unter Startwert (nur endliches Fenster) |
| **T_x** | Erste Passage-Zeit: Syracuse-Schritte bis `S^t(n) ≤ threshold` (Export `time`) | Zeitschritt bis Witness-Abstieg sichtbar |
| **Pass_x** | Orbit-Wert an der ersten Passage `S^{T_x(n)}(n)` (Export `location`) | Witness-Lage nach endlichem Abstieg |
| **hit** | Ob Schwellwert innerhalb von `max_steps` erreicht wurde (Export `hit`) | Existenz eines endlichen Witness-Fensters |

Diese Zuordnung ist **heuristisch** — sie strukturiert Experimente, ersetzt aber weder `BadRunNetDescentWitness` noch Tao's Beweis.

**Literatur:** Tao, T. (2019). *Almost all orbits of the Collatz map attain almost bounded values.* [arXiv:1909.03562](https://arxiv.org/abs/1909.03562)

---

## Syracuse vs. Collatz

Die **Collatz-Abbildung** auf natürlichen Zahlen:

\[
\mathrm{Col}(n) = \begin{cases} n/2 & n \text{ gerade} \\ 3n+1 & n \text{ ungerade} \end{cases}
\]

Die **Syracuse-Abbildung** (nur auf ungeraden positiven \(n\)) fasst einen ungeraden Schritt plus alle folgenden geraden Divisionen zusammen:

\[
S(n) = \frac{3n+1}{2^{v_2(3n+1)}}
\]

| Aspekt | Collatz (`collatz_analytics.collatz_step`) | Syracuse (`tao_collatz_diagnostics.syracuse`) |
|---|---|---|
| Domäne | alle \(n \geq 1\) | ungerade \(n > 0\) |
| Parität | expliziter gerader/ungerader Zweig | nur ungerade Iterationen |
| 2-adische Tiefe | in Bad Runs via `padicValNat 2 (n+1)` (Lean V2.5) | Valuation-Profil \(a_j = v_2(3 S^{j-1}(n)+1)\) |

Python: Vorwärts-Trajektorien und Stopping Times bleiben in `collatz_analytics.py`; Syracuse-First-Passage und Valuation-Profile liegen in `tao_collatz_diagnostics.py` — **keine Duplikation** der Collatz-Schrittfunktion.

---

## Valuation-Profil und Geom(2)-Heuristik

Für ungerades Start-\(n\) und Schritte \(j = 1,\ldots,J\):

\[
a_j = v_2\bigl(3 \cdot S^{j-1}(n) + 1\bigr)
\]

Tao (2019) nutzt eine **Tao-nahe Valuation-Heuristik** für typisch große \(N\) und kurze Fenster \(J \ll \log N\): die \(a_j\) werden **als Referenz** wie \(\mathrm{Geom}(2)\)-Ziehungen auf \(\{1,2,\ldots\}\) mit \(\mathbb{P}(a_j = k) = 2^{-k}\) behandelt — **`[C]`**-Lesesprache, **kein** bewiesenes IID-Modell und **keine** Tao-Stabilisierung.

**Diagnostik (endlich, `[B]`):** Das Modul misst **finite Marginalen** und einfache Korrelationstests — `geom2_profile_distance` (tail-korrigierte TV-Distanz zu Geom(2)), `positional_geom2_distances` (Marginalen pro Schrittindex `j`), `lag1_autocorrelation`, `pair_distribution_l1_deviation`. Das belegt **weder** IID-Struktur **noch** Tao-Stabilisierung; es vergleicht nur **aggregierte Marginalen** und sequenzielle Abweichungen. Für mod-8-Klassen liefert `geom2_collective_profile_distance` die Abweichung auf **gepoolten** Profilen; `free_geom2_distance_excluding_position_0` schließt Position 0 und post-Absorption-Werte aus (siehe unten).

### Interpretation of mod-8 stratified Geom(2) diagnostics

**English (primary).** Mod-8 stratified exports compare Syracuse valuation histograms to the Geom(2) reference. Three scopes must not be conflated:

| Metric | Scope | Interpretation |
|---|---|---|
| `geom2_delta_start` / positional `0` | First valuation `a_1 = v_2(3n+1)` only | **Deterministic Klein mod-8 channel signature** — fixed by start residue, not a free Geom(2) draw |
| `geom2_delta_free` / `free_geom2_distance_excluding_position_0` | Positions `1..` before Syracuse hits fixed point `1` | **Free tail** — closest finite analogue to Tao's short-window IID heuristic |
| `collective_geom2_distance` | All positions pooled | **Mixed** — combines start signature, free tail, and (without censoring) repeated `v_2(4)=2` after absorption |

**Censoring at `S(n)=1`.** `syracuse_valuation_profile(..., censor_at_one=True)` stops when the Syracuse iterate reaches `1`. Without censoring, profiles continue with `v_2(3·1+1)=v_2(4)=2` forever — an **absorption artifact**, not IID Geom(2). Late-position TV growth in uncensored `positional_geom2` often reflects shrinking active sample size plus this fixed tail, not improved Tao alignment.

**Active sample counts.** `active_sample_count_by_position` tracks how many censored profiles still contribute at index `j`. Counts decrease as orbits absorb at `1`; late positions compare fewer, longer-orbit survivors.

**Governance.** Status **`[B]`** — numerical diagnostic only. This is **not** an IID Geom(2) test, **not** Tao stabilization, and **not** a Collatz proof.

**Deutsch (Kurz).** Position 0 ist die **deterministische Klein-Kanal-Signatur** (mod 8). Späte positional-TV-Anstiege ohne Zensur sind oft **Absorptionsartefakte** bei `S(n)=1` (`v_2(4)=2`). `collective_geom2_distance` mischt Start-, freie und Absorptions-Effekte; für Tao-nahe Lesart `geom2_delta_free` und Zensur verwenden. Status **`[B]`**, kein IID-Test.

**Optional step cap.** `effective_profile_steps(n, profile_steps, steps_cap_log_n=…)` caps length at `min(profile_steps, max(1, int(c·log n)))` — Tao-nearer short windows for large `n`.

### Heuristische Brücke zu V2.7 (`[C]`, kein Beweis)

Unter der IID-Geom(2)-Heuristik gilt \(\mathbb{E}[a_j] = 2\) (Erwartungswert der geometrischen Verteilung mit Erfolgswahrscheinlichkeit \(1/2\)). Pro Syracuse-Schritt skaliert der ungerade Kern im Mittel mit Faktor \(3/2^{\mathbb{E}[a]} = 3/4\) — ein **netto multiplikativer Schrumpfungsfaktor** pro Syracuse-Iteration, **wenn** die Valuationen unabhängig Geom(2)-verteilt wären.

| Größe | Heuristik | Governance |
|---|---|---|
| \(\mathbb{E}[a_j]\) unter Geom(2) | \(2\) | `[C]` Referenzverteilung |
| Netto-Faktor pro Syracuse-Schritt | \(3/4\) | `[C]` Ensemble-Heuristik |
| \(\Delta_{\mathrm{net}} > 0\) (V2.7 Witness) | offen | `[C]` — **kein** Lean-Beweis aus Tao-Diagnostics |

Diese \(3/4\)-Lesart strukturiert den Vergleich mit V2.7 (`BadRunNetDescentWitness`, mod-4-Net-Descent) als **heuristische Brücke**, nicht als Ableitung aus Tao (2019) oder aus den numerischen Exporten (**`[B]`**).

**V2.7-Bezug:** In Bad Runs extrahiert Lean V2.5 die 2-adische Tiefe über `padicValNat 2 (n+1)`; das Valuation-Profil ist die Syracuse-seitige **empirische** Spiegelung dieser Paritäts-/2-adischen Struktur — ohne Lean-Identifikation.

---

## Export-Artefakte

| Datei | Inhalt |
|---|---|
| [`exports/tao_collatz_first_passage_upto_1000000.csv`](exports/tao_collatz_first_passage_upto_1000000.csv) | Log-uniform ungerade Stichprobe bis \(10^6\): Passage, Orbit-Minimum, Geom(2)-Abstand |
| [`exports/tao_collatz_first_passage_upto_1000000.summary.json`](exports/tao_collatz_first_passage_upto_1000000.summary.json) | Aggregierte Hit-Rate (**relative** `floor(N/2)`), Tao-style fixed-x companion thresholds, tail-corrected TV, lag-1 autocorr, positional Geom(2) |
| [`exports/tao_collatz_mod8_stratified.summary.json`](exports/tao_collatz_mod8_stratified.summary.json) | First-Passage pro Klein-Klasse `{1,3,5,7}` inkl. gepooltem Geom(2)-Abstand |
| [`exports/tao_collatz_geom2_by_mod8.summary.json`](exports/tao_collatz_geom2_by_mod8.summary.json) | Tail-corrected collective Geom(2) TV, lag-1 autocorr, positional Geom(2) je mod-8-Klasse |

**Standardparameter Export:** `limit=1_000_000`, primary threshold **relative** `floor(N/2)`, `samples=8000`, companion fixed-x thresholds `{10,100,1000,10000}` with `fixed_threshold_samples=2000`, `mod8_samples=2000` pro Klasse, **continuous log-scale approximation** over odd integers.

**Größere Limits:** `--limit` (CLI) erlaubt z. B. `--limit $((2**64))` für einen langsamen Vollbereichslauf; CI und Standard-Export bleiben bei \(10^6\).

---

## API-Übersicht

| Funktion | Zweck |
|---|---|
| `v2(n)` | 2-adische Valuation |
| `syracuse(n)` | Syracuse-Schritt (ungerade) |
| `syracuse_valuation_profile(n, steps, censor_at_one=False)` | Profil `(a_j)`; optional stop at `S(n)=1` |
| `syracuse_valuation_profile_censored(n, steps)` | Profil mit Zensur bei Syracuse-Fixpunkt `1` |
| `effective_profile_steps(n, profile_steps, steps_cap_log_n=…)` | Optional `min(profile_steps, int(c·log n))` |
| `free_geom2_distance_excluding_position_0(profiles)` | Gepoolte TV ohne Position 0 |
| `active_sample_count_by_position(profiles)` | Aktive Stichprobenzahl pro Profilindex |
| `syracuse_orbit_min(n, max_steps)` | Truncated Col_min/Syr_min-Analog bis `max_steps` |
| `first_passage_syracuse(n, threshold, max_steps)` | `hit`, `time` (= T_x), `location` (= Pass_x) |
| `geom2_profile_distance(profile_or_counts, max_k=…)` | Tail-korrigierte TV-Distanz zu Geom(2) |
| `geom2_collective_profile_distance(profiles, max_k=…)` | Gepoolte tail-korrigierte TV-Distanz |
| `lag1_autocorrelation(values)` | Lag-1-Autokorrelation (Pearson) |
| `positional_geom2_distances(profiles, max_k=…)` | Marginal-TV pro Schrittindex |
| `pair_distribution_l1_deviation(profiles)` | Einfacher Paar- vs.-Marginal-Abweichungstest |
| `relative_net_descent_threshold(n)` | `floor(N/2)` für relative First Passage |
| `log_uniform_odd_sample(limit)` | **Continuous log-scale approximation** (ungerade) |
| `discrete_log_odd_sample(limit)` | Exakte diskrete `1/n`-Gewichtung (moderate Limits) |
| `batch_first_passage_experiment(..., threshold="relative"|int)` | Batch + Summary inkl. Governance-Felder |
| `batch_fixed_threshold_first_passage_summaries(...)` | Tao-style fixed-x Schwellen `{10,100,1000,10000}` |
| `log_uniform_odd_sample_mod8(limit, residue)` | Log-uniform ungerade Probe in einer mod-8-Klasse |
| `batch_first_passage_by_mod8(...)` | First-Passage-Statistik pro Klein-Klasse `{1,3,5,7}` |
| `export_mod8_stratified_summary_json(...)` | JSON-Export mod-8 Summary (ohne Zeilen) |
| `export_mod8_geom2_summary_json(...)` | JSON-Export collective Geom(2) je Klasse |

---

## Klein-V₄-Sicht und Tao-Diagnostik

**Lean-Referenz:** `KeplerHurwitz/KleinCollapse.lean` — `IsKleinFourClass m` ist genau
`m % 8 ∈ {1,3,5,7}`. Für jedes ungerade `m` gilt `isKleinFourClass_of_odd` — die vier
Klassen sind **keine echte Einschränkung** auf der ungeraden Syracuse-Schicht, sondern eine
**vollständige 4-Wege-Stratifizierung** des Odd-Kerns (analog zur Mod-8-Tabelle in
`ResidueFilters.lean` / `OddCoreDynamics.lean`).

### Syracuse = Tao-Schicht = Klein-Odd-Kern

Tao (2019) arbeitet auf der **Syracuse-Abbildung** `S(n) = (3n+1)/2^{v_2(3n+1)}` für
ungerade `n`. Das ist dieselbe Schicht wie der ungerade Collatz-Kern in V2 und die
Klein-V₄-Klassifikation: Jeder Syracuse-Schritt startet bei ungeradem `n`, und jedes
ungerade `n` liegt in genau einer mod-8-Klasse. Gerade Divisionen (`n/2`) sind in Syracuse
**eingefaltet** — Tao zählt Valuationen `a_j = v_2(3 S^{j-1}(n)+1)` statt einzelner
Collatz-Schritte.

| Ebene | Objekt | Governance |
|---|---|---|
| Lean Klein | `IsKleinFourClass`, `eSchalenSprung`-Kanaltabelle | `[A]` Typisierung |
| Lean V2.5 | `padicValNat 2 (n+1)` in Bad Runs (`mod 4 = 3`) | `[A]` Extraktion |
| Tao-Modul | `v2(3n+1)`, Valuation-Profil, First Passage `T_x` | `[B]` Diagnostik |
| Tao 2019 | Fast alle Orbits in **logarithmischer Dichte** („almost bounded“); nicht alle Startwerte, keine Einzelklassen-Aussage | `[C]` extern |

### Restklassen-Experimente: ja — Beweis pro Klasse: nein

**Kann man Tao-Experimente auf eine mod-8-Klasse einschränken?** Ja, **`[B]`**:
`batch_first_passage_by_mod8(limit, threshold, samples, seed)` zieht log-uniform pro
Klasse `1, 3, 5, 7` und liefert Hit-Rate, mittlere Passage-Zeit `T_x` und
Geom(2)-Profilabstand je Klasse.

**Beweist Tao Collatz auf Klein-Klassen?** Nein. Tao liefert im hier verwendeten Repo-Kontext
**keinen separat formalisierten Satz pro einzelner mod-8-Klasse**. Eine stratifizierte
Auswertung ist numerisch **`[B]`** möglich, aber daraus folgt **kein** klassenspezifischer
Collatz-Beweis und **kein** uniformes `Δ_net > 0` — **kein** Ersatz für
`BadRunNetDescentWitness` (V2.7, **`[C]` offen**).

### Verbindung zu V2.5 / V2.7

- **Valuation:** `a_1 = v_2(3n+1)` im Tao-Profil ist dasselbe 2-adische Objekt wie die
  Syracuse-seitige Lesart der Bad-Run-Tiefe; Lean V2.5 formalisiert die Extraktion über
  `padicValNat 2 (n+1)` für `n ≡ 3 (mod 4)` — **keine** automatische Lean-Identifikation
  mit Tao's IID-Geom(2)-Heuristik (**`[C]`**).
- **First Passage ↔ Witness:** `first_passage_syracuse(n, threshold, …)` misst, ob und
  wann die Syracuse-Orbit unter einen Schwellwert fällt — **heuristische** Spiegelung von
  „endlicher Witness-Zeit“, ersetzt aber weder `BadRunNetDescentWitness` noch Tao's
  Dichte-Argument.
- **mod 4 = 3 (Bad Branch):** Die offene V2.7-Kernungleichung `Δ_net > 0` betrifft
  **nur** `n ≡ 3 (mod 4)`, nicht einzelne mod-8-Klassen isoliert. Empirisch unterscheiden
  sich Valuation-Profile und First-Passage-Statistik **zwischen** den vier Klein-Klassen
  (und zwischen `mod 4 = 1` vs. `mod 4 = 3`) — testbar via
  `batch_first_passage_by_mod8` und `geom2_profile_distance`.

### Klein V₄ als Stratifikation, nicht als Beweis-Shortcut

Die Klein-Vierergruppe liefert vier **Kanäle** mit fester `(3m+1) mod 8`-Tabelle
(`ResidueFilters.lean`) und unterschiedlichem `eSchalenSprung` (`KleinCollapse.lean`).
Das ist nützlich, um Tao-Diagnostics **stratifiziert** auszuwerten — **nicht**, um aus
„vier gleichberechtigten Klassen“ einen Collatz-Beweis zu konstruieren. Der Beweiskern
bleibt mod-4-getrieben (Good/Bad-Branch); mod-8 verfeinert die Schalenkanal-Typisierung.
Optional: `klein_bifurcation_nullmodel.py` vergleicht **[B]** Klein-V₄-Nachbar-Bifurkation
mit echten Syracuse-Label-Pfaden — ergänzende Nullmodell-Diagnostik, kein Beweisersatz.

### Governance-Boxen (Klein × Tao)

| Aussage | Status |
|---|---|
| Jede ungerade Zahl ist Klein-Klasse `{1,3,5,7}` | `[A]` (`isKleinFourClass_of_odd`) |
| Syracuse/Valuation-Profile numerisch messbar | `[B]` (`tao_collatz_diagnostics.py`) |
| Stratifizierte First-Passage pro mod-8-Klasse | `[B]` (`batch_first_passage_by_mod8`) |
| Tao „almost all“ ⇒ Collatz auf einer mod-8-Klasse | **nein** — `[C]` extern, Dichte ≠ Einzelklasse |
| Tao-Heuristik ⇒ `BadRunNetDescentWitness` / `Δ_net > 0` | **nein** — `[C]` offen (V2.7) |
| Klein-V₄ als vierfacher Beweisweg | **nein** — Stratifikation/Diagnostik only |

---

## Siehe auch

- [`collatz_analytical_perspectives.md`](collatz_analytical_perspectives.md) — drei analytische Perspektiven, Tao-Kontext
- [`collatz_v2_evidence_chain.md`](collatz_v2_evidence_chain.md) — V2.7 Net-Descent, `[A]`/`[C]`-Grenzen
- [`collatz_v27_net_descent.md`](collatz_v27_net_descent.md) — `BadRunNetDescentWitness`
- `src/kepler_hurwitz/collatz_analytics.py` — Collatz-Trajektorien (getrennte Schicht)
