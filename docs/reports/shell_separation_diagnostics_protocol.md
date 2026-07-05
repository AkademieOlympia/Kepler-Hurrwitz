# Shell Separation Diagnostics Protocol

**Evidence IDs:** E-077, E-078, E-079  
**Status:** `[C]` — diagnostic measurement layer only  
**Date:** 2026-07-05

---

## Purpose

This protocol operationalizes Open-Core path E-077–E-079 as a **diagnostic measurement layer**. It does **not** add proof claims, Lean theorems, or upgrades to `[B]` without the gates listed below.

| ID | Target | Register status |
|---|---|---|
| E-077 | `MetricSeparationLossExist` / `ShellSeparationLoss(n)` | `[C]` |
| E-078 | Global `R³` embedding of all shells (`ι_n` for all n) | `[C]` |
| E-079 | Minkowski–Bouligand box dimension from shell metric | `[C]` |

**Upgrade to `[B]`** for E-077–E-079 requires **all** of:

1. a fixed shell construction,
2. a fixed metric,
3. a fixed threshold rule `ε_n`,
4. reproducible exports,
5. tests against degenerate and null configurations.

---

## Governance Guard

This diagnostic layer does not prove MetricSeparationLossExist, global `\mathbb R^3`-embedding, or Minkowski–Bouligand dimension existence.

It only operationalizes measurable quantities:

\[
\mathrm{sep}(n), \qquad
\mathrm{overlap}(n), \qquad
\mathrm{ShellSeparationLoss}(n), \qquad
\widehat{\dim}_B(S).
\]

The status of E-077–E-079 remains `[C]` until the following are available:

1. a fixed shell construction,
2. a fixed metric,
3. a fixed threshold rule `\varepsilon_n`,
4. reproducible exports,
5. tests against degenerate and null configurations.

Meissner language is allowed only as interpretive vocabulary `[C]`:

> Bulk stable, shell carries stress.

It must not be used as evidence for separation loss, prime-index coupling, or Collatz descent.

---

## Activation Gate: shellPrimeMatchAtFirstLoss

The hypothesis shellPrimeMatchAtFirstLoss remains inactive until an internal first-loss index n_0 has been determined.

The internal sequence is:

sep(n) → ShellSeparationLoss(n) → n_0.

Only after n_0 is fixed without reference to prime indices may the arithmetic coupling hypothesis be tested:

n_0 → shellPrimeMatchAtFirstLoss.

No prime index, EABC channel count, or arithmetic signal may be used to choose the shell metric, the threshold rule ε_n, or the first-loss index n_0. This guard prevents post-hoc fitting and keeps the separation diagnostic independent of the later arithmetic test.

### Forschungsfluss / research flow

| DE | EN |
|---|---|
| Schalenmodell fixieren → `sep(n)` messen → `ShellSeparationLoss(n)` → `n_0` intern bestimmen | Fix shell model → measure `sep(n)` → `ShellSeparationLoss(n)` → determine internal `n_0` |
| Erst danach: `n_0` → `shellPrimeMatchAtFirstLoss` | Only then: `n_0` → `shellPrimeMatchAtFirstLoss` |

### Negative Regel / negative rule

**DE:** Kein Primindex darf zur Wahl von `n_0`, `ε_n`, `sep(n)` oder Schalenmetrik verwendet werden (post-hoc-Fitting verboten).

**EN:** No prime index may be used to choose `n_0`, `ε_n`, `sep(n)`, or the shell metric (post-hoc fitting forbidden).

### Gate status (canonical run v1)

| Check | Result |
|---|---|
| `∃ n : ShellSeparationLoss(n)?` | **nein** (n = 1 … 17, `canonical_from_qec_bridge`) |
| `first_loss_n` / `n_0` | **NONE** |
| **Gate** | **INACTIVE** |

---

## Pre-Registration Gate: shellPrimeMatchAtFirstLoss

**Status:** **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE**

Canonical runs v1 and v2: `first_loss_n` = **NONE**, tested range **n = 1 … 17**.

Reproducibility snapshot: [`shell_separation_preregistration.json`](shell_separation_preregistration.json)

The hypothesis shellPrimeMatchAtFirstLoss remains inactive until an internal first-loss index n_0 has been determined.

The internal diagnostic sequence is:

fixed shell model → sep(n) → ShellSeparationLoss(n) → n_0.

Only after n_0 is fixed without reference to prime indices may the arithmetic coupling hypothesis be tested:

n_0 → shellPrimeMatchAtFirstLoss.

Before the arithmetic test is activated, the following items must be frozen:

1. the shell construction,
2. the shell metric,
3. the threshold rule ε_n,
4. the tested range of n,
5. the definition of sep(n),
6. the definition of ShellSeparationLoss(n),
7. the rule for extracting the first-loss index n_0.

No prime index, EABC channel count, residue signal, or arithmetic feature may be used to choose the shell model, shell metric, threshold rule ε_n, search range, separation statistic, or first-loss index n_0.

This guard prevents post-hoc fitting. It keeps the separation diagnostic independent of the later arithmetic test and enforces the sequence:

first internal geometry, then arithmetic coupling.

> **Merksatz (DE):** n_0 muss geometrisch blind entstehen.
>
> **Merksatz (DE):** Erst danach: Trifft n_0 einen EABC-Primindex?

### Frozen-items checklist (canonical v1 / v2)

| # | Item | Frozen? | Canonical value / note |
|---|---|---|---|
| 1 | Shell construction | ✅ **frozen** | `canonical_from_qec_bridge` (`canonical_shell_vertices.py`; qec_bridge Hurwitz projection) |
| 2 | Shell metric | ✅ **frozen** | `euclidean_l2_r3` (centroid L2 on R³) |
| 3 | Threshold rule ε_n | ✅ **frozen** | v1: `provisional_inverse_n` (= `1/n`); v2: `theorematic_energiedoku_v1` (Energiedoku §8 for n ∈ {1,2,3}; `φ⁻³` fallback for n > 3); v3: `theorematic_mn_sep_v1` (`ε_n = 4^{-n}` from `M_n^sep = 4^n`, `[C]` convention) |
| 4 | Tested range of n | ✅ **frozen** | **n = 1 … 17** (`max_renorm_level()` ≈ 17) |
| 5 | Definition of `sep(n)` | ✅ **frozen** | `shell_sep`: minimum pairwise Euclidean distance between shell centroids at level n |
| 6 | Definition of `ShellSeparationLoss(n)` | ✅ **frozen** | `shell_separation_loss`: boolean `sep(n) ≤ ε_n` |
| 7 | Rule for extracting `n_0` | ✅ **definition frozen**; ⏳ **value awaits loss** | `first_loss_n`: smallest ascending `n` where `ShellSeparationLoss(n)` is true |

**Awaiting `n_0`:** Items 1–7 are pre-registered and frozen for canonical v1/v2. No observed `n_0` yet (`first_loss_n` = NONE). The arithmetic coupling test (`shellPrimeMatchAtFirstLoss`) remains **inactive** until an internal `n_0` appears under this frozen protocol.

**Relation to Activation Gate:** The Activation Gate states the high-level inactivity rule; this Pre-Registration Gate is the **canonical governance record** with the full frozen-items checklist and reproducibility artifact.

---

## Dual-Track n₀ Governance

**Decision (2026-07-05):** `n_0` wird **nicht** zwischen Konstruktionsschichten vermischt. Zwei parallele Spuren sind formal getrennt; E-085 bleibt **GATE INACTIVE**, bis eine explizite Spur-Wahl oder eine dokumentierte Vereinheitlichung vorliegt.

Reproducibility snapshot: [`shell_separation_preregistration.json`](shell_separation_preregistration.json) (`tracks.track_a_canonical`, `tracks.track_b_energiedoku_full`).

Decision memo: [`shell_n0_dual_track_decision.md`](shell_n0_dual_track_decision.md).

### Track A — Primary Pre-Registration

| Field | Value |
|---|---|
| **Track ID** | `track_a_canonical` |
| **Construction** | `canonical_from_qec_bridge` |
| **Combinatorics** | `|Shell(n)| = n + 1` (prefix of qec_bridge Hurwitz list) |
| **ε_n rule (pre-reg)** | v1: `provisional_inverse_n`; v2: `theorematic_energiedoku_v1`; v3: `theorematic_mn_sep_v1` |
| **Tested range** | **n = 1 … 17** |
| **`first_loss_n` / `n_0`** | **NONE** (undetermined) |
| **E-085 gate eligibility** | **Eligible only after observed `n_0`** under this frozen track — not yet satisfied |
| **Status** | **Primary frozen construction** for pre-registration |

### Track B — Theorematic Reference (exploratory)

| Field | Value |
|---|---|
| **Track ID** | `track_b_energiedoku_full` |
| **Construction** | `energiedoku_full` (`EnergiedokuShellConstruction(mode='full')`) |
| **Combinatorics** | `|ShellVertex(n)| = 4^n` (EABC words of length n) |
| **ε_n rule** | **`theorematic_energiedoku_v1` ONLY** (Energiedoku §8; `φ⁻³` fallback for n > 3) |
| **Tested range** | **n = 1 … 3** (full `4^n` only implemented for n ≤ 3) |
| **`exploratory_n_0`** | **2** (first loss under φ thresholds; `sep(2) = φ⁻² = ε₂`, boundary equality) |
| **Label** | **`[C]`** — diagnostic / theorematic reference, not primary pre-reg |
| **E-085 gate eligibility** | **`gate_eligible: false`** — does **NOT** activate E-085 |
| **Status** | Exploratory first hint: `∃ n : ShellSeparationLoss(n)` under theorematic `4^n` construction |

**Interpretation (Track B):** The n=2 loss on full `ShellVertex(2)` is **robust** (16 words, not diagnostic-subset artefact). It fires because the boolean diagnostic uses `sep(n) ≤ ε_n` with equality. This is **not** a claim that Track B's `n_0 = 2` satisfies the E-085 pre-registration gate while Track A remains primary.

### Negative rule (cross-track)

> **`n_0` from Track B MUST NOT be used for `shellPrimeMatchAtFirstLoss` while Track A remains the primary frozen construction.**

Rationale:

1. Track A and Track B use **incompatible combinatorics** (`n+1` vs `4^n`) and **different embeddings** (`qec_bridge` vs Lean cardinal-lattice).
2. No documented global bijection `prefix_index ↔ ShellVertex(n)` exists (see "Prefix mapping + full 4^n energiedoku").
3. Mixing tracks would violate the pre-registration sequence: *fixed shell model → sep(n) → ShellSeparationLoss(n) → n_0*.

### Upgrade path to activate E-085 gate

The gate may be activated **only** after one of:

| Path | Requirement | Exists today? |
|---|---|---|
| **B1 — Track switch** | **New pre-registration** freezing Track B (`energiedoku_full`) as the **sole** primary construction for `n_0` extraction | ❌ No |
| **B2 — Unified bridge** | Documented bijection / compatible global embeddings `ι_n` bridging both combinatorics with prefix compatibility `ι_{n+1}|_{S_n} = ι_n` | ⚠️ **Partial** — interpretive bridge documented for n≤3; no global bijection; **gate_eligible: false** |
| **B3 — Track A loss** | Observed `n_0` from Track A under frozen canonical pre-reg (items 1–7 above) | ❌ No (`first_loss_n` = NONE) |

Until one path is completed and re-registered: **`SHELL_PRIME_MATCH_GATE_ACTIVE = false`**.

### Decision matrix (reviewer)

| Question | Track A (primary) | Track B (reference) | Gate impact |
|---|---|---|---|
| Primary pre-reg construction? | ✅ Yes | ❌ No | — |
| Frozen combinatorics | `n + 1` | `4^n` | Must not mix |
| `first_loss_n` observed? | **NONE** | **2** (φ rule only) | Track B value **ignored** for E-085 |
| Activates E-085? | Only if future `n_0` under Track A | **Never** (while A primary) | Gate **INACTIVE** |
| Label | Pre-reg primary | `[C]` exploratory | — |
| Use for primindex coupling? | After blind `n_0` fix | **Forbidden** until track switch or unified `ι_n` | — |

---

## Distinction from `projection_loss` (Top-8 Atlas)

`projection_loss` in `kepler_hurwitz.diagnostics` is **Prime-Grid** \(L_\pi = \Omega - M\), **not** metric `ShellSeparationLoss`. The two layers must not be conflated in exports or evidence upgrades.

---

## Implementation

| Component | Path |
|---|---|
| Primary API | `src/kepler_hurwitz/shell_separation_diagnostics.py` |
| Construction protocol | `src/kepler_hurwitz/shell_construction.py` |
| Canonical vertices / embedding | `src/kepler_hurwitz/canonical_shell_vertices.py` |
| qec_bridge projection basis | `src/kepler_hurwitz/qec_bridge.py` (`build_shell_projection_bundle`) |
| Runner | `scripts/shell_separation_diagnostics.py` |
| Unit tests | `tests/test_shell_separation_diagnostics.py` |
| Demo (JSON) | `examples/run_shell_separation_diagnostics.py` |

### Core functions

| Function | Role |
|---|---|
| `pairwise_min_distance` | Min distance between two point sets |
| `shell_sep` | Min centroid separation across shells at one level |
| `shell_overlap` / `overlap(n, …)` | Overlap pair count at threshold `ε` |
| `sep(n, …)` | Separation at level `n` |
| `shell_separation_loss` | Boolean flag `sep(n) ≤ ε_n` |
| `first_loss` / `first_loss_n` | First level where loss flag is true |
| `box_dimension_estimate` | From point cloud or precomputed cover counts |
| `embedding_quality` | Optional proxy `sep/ε` (not an embedding proof) |

---

## Detector Validation Controls

**Status:** `[C]` — measurement-layer validation only  
**Module:** `src/kepler_hurwitz/shell_detector_controls.py`  
**Export:** `docs/energiedoku_exports/shell_detector_controls.csv`

The control suite validates that the shell-separation **detector** responds correctly to known geometric inputs before any canonical shell search is interpreted. It does **not** upgrade E-077–E-079, does **not** fix `n_0`, and does **not** activate `shellPrimeMatchAtFirstLoss`.

### Control cases

| Control | Generator | Expected |
|---|---|---|
| Positive (stress) | `generate_overlapping_shells()` | `shell_separation_loss = True`, `overlap_count > 0` |
| Negative (null) | `generate_separated_shells()` | `shell_separation_loss = False`, `overlap_count = 0` |
| Degenerate | `generate_degenerate_shells()` | `sep = 0`, `shell_separation_loss = True` |
| Random null | `generate_random_shells(seed)` | Reproducible baseline; outcome recorded, not asserted |

Run the full suite:

```bash
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --controls
```

CSV columns: `control_name`, `seed`, `n_shells`, `points_per_shell`, `epsilon`, `sep`, `overlap_count`, `shell_separation_loss`, `expected_loss`, `passed`, `notes`.

### Detector Validation Guard

The control suite validates the behavior of the shell-separation detector. It does not prove MetricSeparationLossExist, does not establish a global `\mathbb R^3`-embedding, and does not determine an internal first-loss index `n_0`.

The detector must pass three basic controls before any search for genuine shell separation loss is interpreted:

1. Positive control: intentionally overlapping shells must trigger ShellSeparationLoss.
2. Negative control: clearly separated shells must not trigger ShellSeparationLoss.
3. Degenerate control: identical or collapsed shells must yield zero separation and trigger loss.

Random point-cloud controls are used only to calibrate the detector's baseline loss rate under non-canonical inputs. They are not evidence for or against the EABC shell model.

The hypothesis shellPrimeMatchAtFirstLoss remains inactive throughout this validation layer. No prime index, EABC channel count, residue signal, or arithmetic feature may be used to tune the detector, metric, threshold rule, or shell construction.

**DE:** Tests validieren nur die Messschicht; kein `n_0`; kein Gate-Aktivierung.

---

## Data layers (Toy vs real)

| Layer | Scope | Claim |
|---|---|---|
| **Toy** | `ToyShellConstruction` / `build_toy_shell_series_n_le_3` — n ∈ {1, 2, 3} | Explicit centroids for regression only; **not** global `R³` embedding |
| **Synthetic** | `SyntheticShellConstruction` / `build_synthetic_shell_series` — configurable n_max | Controlled separation decay for pipeline tests |
| **Combined** | `CombinedShellConstruction` — toy + synthetic (synthetic wins on overlap) | Default runner; backward-compatible with pre-protocol exports |
| **Canonical** | `CanonicalShellConstruction` / `canonical_from_qec_bridge` | Operational qec_bridge Hurwitz projection — **approximation**, not formal Energiedoku `ShellVertex` |

---

## Canonical run v1 (2026-07-05)

**Construction source:** `canonical_from_qec_bridge`  
**Module:** `src/kepler_hurwitz/canonical_shell_vertices.py`  
**Embedding:** `hurwitz_projected_imaginary_xyz` — `(projected[1], projected[2], projected[3])` from `build_shell_projection_bundle`

### Operational definition

| Item | Value |
|---|---|
| `ShellVertex(n)` | Prefix of length `n+1` from fixed parity-class-unique dyadic norm-2 root list |
| Degenerate filter | Origin `(0,0,0)` excluded |
| Compatibility | `ι_{n+1}` = prefix restriction on same ordered list |
| Max level | `max_renorm_level()` ≈ 17 (18 unique non-origin R³ reps) |
| Metric | `euclidean_l2_r3` |
| ε_n rule | `provisional_inverse_n` (= `1/n`) |

### Diagnostic answers (canonical only — no Toy/Synthetic)

| Question | Answer |
|---|---|
| `∃ n : ShellSeparationLoss(n)?` | **nein** (canonical run v1: no loss flag up to max n) |
| `first_loss_n` / `n_0` | **NONE** |
| `shellPrimeMatchAtFirstLoss` | **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (no internal `n_0`; see Pre-Registration Gate) |
| Meissner analogy | **not used as evidence** |

### Approximations / limits

1. **Not** the formal Energiedoku `ShellVertex` type or theorem-backed `ι_n` for all `n`.
2. Energiedoku §8 documents separate embeddings for `n ∈ {1,2,3}` with `ε_n ∈ {1, φ⁻², φ⁻³}` — this run uses qec_bridge projection and `1/n` instead.
3. Shell count rule `n+1` is operational, not derived from `M_n^sep = 4^n`.
4. Levels beyond `max_renorm_level()` raise `NotImplementedError`.

### E-077–E-079 gate status after v1

| Gate | Status |
|---|---|
| `ShellConstructionProtocol` | ✅ |
| Fixed metric / ε_n documented | ✅ |
| Reproducible CSV/JSON exports | ✅ (canonical run) |
| Degenerate/null tests | ✅ |
| **`CanonicalShellConstruction` with real `ι_n`** | ⚠️ **partial** — qec_bridge approximation only |
| Enumerate formal `ShellVertex(n)` | ❌ open (operational substitute only) |
| Compatible global embeddings (theorem) | ⚠️ prefix compatibility only |
| Canonical diagnostic run | ✅ **v1 complete** |
| E-077–E-079 upgrade to `[B]` | ❌ **remain `[C]`** |
| E-085 `shellPrimeMatchAtFirstLoss` | ❌ **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (`first_loss_n` = NONE) |

### Reproduce canonical run

```bash
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --construction canonical --n-max 17
PYTHONPATH=src python scripts/shell_separation_diagnostics.py \
  --construction canonical --epsilon-rule theorematic_energiedoku_v1 --n-max 17
```

## Canonical run v2 (theorematic ε_n) (2026-07-05)

**Construction source:** `canonical_from_qec_bridge` (unchanged from v1)  
**ε_n rule:** `theorematic_energiedoku_v1` — Energiedoku §8 (`eabc_renormalisierungsprogramm.md`)

### Theorematic thresholds

| n | ε_n | Source |
|---|---|---|
| 1 | `1` | Energiedoku §8 |
| 2 | `φ⁻²` ≈ 0.381966011250105 | Energiedoku §8; `φ = (1+√5)/2` |
| 3 | `φ⁻³` ≈ 0.236067977499790 | Energiedoku §8 |
| n > 3 | `φ⁻³` | **`[C]` diagnostic fallback** — no per-level theorem in repo; not silent `1/n` |

### Diagnostic answers (canonical v2 — theorematic ε_n)

| Question | Answer |
|---|---|
| `∃ n : ShellSeparationLoss(n)?` | **nein** (n = 1 … 17) |
| `first_loss_n` / `n_0` | **NONE** |
| `shellPrimeMatchAtFirstLoss` | **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (no internal `n_0`) |
| vs v1 (`provisional_inverse_n`) | Same outcome (no loss); theorematic ε_2, ε_3 are **stricter** (smaller) than `1/n`, yet all `sep(n)` remain above threshold |

### E-077–E-079 gate status after v2

| Gate | Status |
|---|---|
| Theorematic ε_n for n ∈ {1,2,3} | ✅ implemented (`theorematic_energiedoku_v1`) |
| n > 3 extension | ⚠️ **`[C]` fallback** (`φ⁻³`); M_n^sep-derived rule open |
| Canonical diagnostic run v2 | ✅ complete |
| E-077–E-079 upgrade to `[B]` | ❌ **remain `[C]`** |
| E-085 `shellPrimeMatchAtFirstLoss` | ❌ **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (`first_loss_n` = NONE) |

### Reproduce canonical run v2

```bash
PYTHONPATH=src python scripts/shell_separation_diagnostics.py \
  --construction canonical --epsilon-rule theorematic_energiedoku_v1 --n-max 17
```

## Canonical run v3 (M_n^sep ε_n) (2026-07-05)

**Construction source:** `canonical_from_qec_bridge` (unchanged from v1/v2)  
**ε_n rule:** `theorematic_mn_sep_v1` — Energiedoku §7 (`M_n^sep = 4^n`); operational `[C]` convention

### Theorematic / conventional thresholds

| n | M_n^sep | ε_n = 4^{-n} | Source |
|---|---|---|---|
| 1 | 4 | `0.25` | §7 `M_1^sep = 4`; `[C]` inverse-scale convention |
| 2 | 16 | `0.0625` | §7 |
| 3 | 64 | `0.015625` | §7 |
| 4 | 256 | `0.00390625` | §7 |
| … | `4^n` | `4^{-n}` | §7; §8 gives no per-level ε from `M_n^sep` |

**Theory note:** Energiedoku §8 documents `ε_n ∈ {1, φ⁻², φ⁻³}` only for `n ∈ {1,2,3}` (metric embeddings). There is **no** explicit theorem `ε_n = 1/M_n^sep` in the repo. `theorematic_mn_sep_v1` implements the conservative operational convention `ε_n = 4^{-n}` motivated by §7 and the protocol upgrade path (§14.2).

### Diagnostic answers (canonical v3 — M_n^sep ε_n)

| Question | Answer |
|---|---|
| `∃ n : ShellSeparationLoss(n)?` | **nein** (n = 1 … 17) |
| `first_loss_n` / `n_0` | **NONE** |
| `shellPrimeMatchAtFirstLoss` | **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (no internal `n_0`) |
| vs v1 (`provisional_inverse_n`) | Same outcome (no loss); v3 thresholds are **much stricter** (e.g. ε_2 = 0.0625 vs 0.5; ε_3 = 0.015625 vs 0.333…) — all `sep(n) ≥ 1.0` remain above threshold |
| vs v2 (`theorematic_energiedoku_v1`) | Same outcome (no loss); v3 is stricter for all n (e.g. ε_1 = 0.25 vs 1.0; ε_2 = 0.0625 vs φ⁻² ≈ 0.382) |

### E-077–E-079 gate status after v3

| Gate | Status |
|---|---|
| M_n^sep-derived ε_n rule | ✅ implemented (`theorematic_mn_sep_v1`, `[C]` convention) |
| Canonical diagnostic run v3 | ✅ complete |
| E-077–E-079 upgrade to `[B]` | ❌ **remain `[C]`** |
| E-085 `shellPrimeMatchAtFirstLoss` | ❌ **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** (`first_loss_n` = NONE) |

### Reproduce canonical run v3

```bash
PYTHONPATH=src python scripts/shell_separation_diagnostics.py \
  --construction canonical --epsilon-rule theorematic_mn_sep_v1 --n-max 17
```

## Fixed metric and ε_n convention (provisional canonical rule)

| Field | Value | Status |
|---|---|---|
| **Metric** | Euclidean L2 on R³ (`metric_name = euclidean_l2_r3`) | Fixed convention — centroid separation between shells |
| **ε_n rule** | `epsilon_n = 1/n` (`epsilon_rule_name = provisional_inverse_n`) | Provisional; see also `theorematic_energiedoku_v1` (v2) and `theorematic_mn_sep_v1` (v3) |

CSV exports include `metric_name`, `epsilon_rule_name`, and `epsilon_n` per level.

**Upgrade path to formal `[B]`:** replace `provisional_inverse_n` with a theorem-backed threshold derived from `M_n^sep = 4^n` and the fixed shell metric (see `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` §14).

---

## Canonical construction gate for `[B]`

E-077–E-079 remain **`[C]`** until a **canonical run without Toy/Synthetic** succeeds. Checklist:

| Gate | Status |
|---|---|
| `ShellConstructionProtocol` defined | ✅ `src/kepler_hurwitz/shell_construction.py` |
| Fixed metric documented | ✅ `euclidean_l2_r3` |
| Fixed ε_n rule documented | ✅ `provisional_inverse_n` (= `1/n`, convention-labeled) |
| Reproducible CSV/JSON exports | ✅ runner + tests |
| Degenerate/null configuration tests | ✅ unit tests |
| **`CanonicalShellConstruction` with real `ι_n`** | ⚠️ **partial** — `canonical_from_qec_bridge` approximation (see "Canonical run v1") |
| Enumerate `ShellVertex(n)` per renorm level | ⚠️ **operational substitute** — dyadic parity-class prefix list |
| Compatible global embeddings `ι_{n+1}|_{S_n} = ι_n` | ⚠️ **prefix only** (not theorem-backed) |
| Canonical diagnostic run (no Toy/Synthetic) | ✅ **v1** — see "Canonical run v1" |
| E-085 `shellPrimeMatchAtFirstLoss` | ❌ **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** — no internal `first_loss_n` from canonical run |

**Repo search (2026-07-05):** no formal Lean `ShellVertex(n) → R³` pipeline. **v1 (2026-07-05):** operational `canonical_from_qec_bridge` via `canonical_shell_vertices.py` and `build_shell_projection_bundle` — approximation documented in "Canonical run v1".

**What is missing for formal `[B]`:**

1. Formal enumeration of `ShellVertex(n)` at each renorm level `n`.
2. Implementation of compatible global embeddings `ι_n : ShellVertex(n) → R³`.
3. Wiring into `CanonicalShellConstruction.shells_at(n)`.
4. Successful `--construction canonical` run producing separation diagnostics.
5. Only then: evaluate E-077–E-079 for `[B]` upgrade; E-085 remains gated on internal `first_loss_n`.

---

## Exports

| File | Content |
|---|---|
| `docs/energiedoku_exports/shell_separation_diagnostics.csv` | Per-level `sep`, overlap, loss flags, embedding quality |
| `docs/energiedoku_exports/shell_box_dimension_estimates.csv` | Box counts per `ε` and optional `\widehat{\dim}_B` |
| `docs/energiedoku_exports/shell_separation_diagnostics_sample.json` | Aggregated report (optional sample) |
| `docs/energiedoku_exports/shell_detector_controls.csv` | Detector validation controls (null/stress) |
| `docs/energiedoku_exports/shell_embedding_comparison_n123.csv` | Canonical vs energiedoku pointwise comparison (n≤3) |
| `docs/energiedoku_exports/shell_embedding_comparison_n1_n3.csv` | Invariant geometry audit (sep, spectra, Procrustes; n≤3) |
| `docs/energiedoku_exports/shell_prefix_word_map_n123.csv` | Prefix ↔ EABC word mapping (n≤3) |
| `docs/energiedoku_exports/shell_energiedoku_full_n23.csv` | Full 4^n energiedoku sep/overlap/loss (n≤3) |
| `docs/energiedoku_exports/unified_embedding_bridge_n123.csv` | Path B2 unified ι_n bridge (n≤3, exploratory) |

### Reproduce

```bash
# Default (combined: toy + synthetic, backward compatible)
PYTHONPATH=src python scripts/shell_separation_diagnostics.py

# Explicit construction layers
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --construction combined
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --construction toy
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --construction synthetic
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --construction canonical
PYTHONPATH=src python scripts/shell_separation_diagnostics.py \
  --construction canonical --epsilon-rule theorematic_energiedoku_v1 --n-max 17

# Detector validation controls (null/stress)
PYTHONPATH=src python scripts/shell_separation_diagnostics.py --controls
```

Default threshold: `ε_n = 1/n` (`provisional_inverse_n`). Theorematic alternatives: `--epsilon-rule theorematic_energiedoku_v1`, `--epsilon-rule theorematic_mn_sep_v1`. Metric: `euclidean_l2_r3`.

The `canonical` mode attempts real shell construction and exits with a clear message if unavailable (see gate checklist above).

## Canonical vs Energiedoku (n≤3) (2026-07-05)

**Purpose:** Compare operational `canonical_from_qec_bridge` with theorematic Energiedoku §8 embeddings for `n ∈ {1,2,3}` and assess whether `ι_n` should be revisited.

**Modules:** `src/kepler_hurwitz/energiedoku_shell_construction.py`, `src/kepler_hurwitz/shell_embedding_comparison.py`

**Energiedoku source:** Lean `EabcRenorm/ShellEmbedding.lean` — `cardinalShellEmbedding_one/two/three` (`cardinalDir` for `n=1`; lattice `(φ^{-n})·classIndex` for `n=2,3`). Ikosaeder branch **not** used in this comparison run.

**Reproduce:**

```bash
PYTHONPATH=src python scripts/compare_shell_embeddings.py --n-max 3
```

**Export:** `docs/energiedoku_exports/shell_embedding_comparison_n123.csv`

**Geometry audit (invariant-based):** See [Shell Embedding Geometry Audit Protocol](shell_embedding_comparison_protocol.md). Reproduce:

```bash
PYTHONPATH=src python scripts/shell_embedding_geometry_audit.py --n-max 3
```

**Export:** `docs/energiedoku_exports/shell_embedding_comparison_n1_n3.csv`

### Audit results (matched_n_plus_1, 2026-07-05)

| n | compatible | classification | sep_a | sep_b | dist_l2 | procrustes | ι_n action |
|---|---|---|---|---|---|---|---|
| 1 | **yes** | compatible | √2 | √2 | 0 | ~0 | none — same shape up to similarity |
| 2 | **no** | true_geometric_deviation | √2 | φ⁻² | 0.586 | 0.625 | audit ι_n (sep + shape differ) |
| 3 | **no** | possible_first_break_n3 | √2 | φ⁻³ | 0.631 | 0.679 | isolate n=3; audit ι_n |

**Aggregate recommendation:** True geometric deviation at n≥2; audit theorematic ι_n mapping. Do **not** rebuild unified bridge until label/orientation ruled out (n=1 is compatible under Procrustes).

### Combinatorics (fundamental mismatch)

| Layer | `ShellVertex(n)` rule | Count at n=1,2,3 |
|---|---|---|
| **Canonical** | Prefix of length `n+1` from qec_bridge Hurwitz list | 2, 3, 4 |
| **Energiedoku** | Words of length `n` over `{E,A,B,C}` | 4, 16, 64 |

Pointwise comparison uses the **diagnostic** subset (first `n+1` lex-ordered words) on the Energiedoku side to align with the canonical runner’s shell count — **not** a claim that `4^n = n+1`.

### Coordinate alignment (diagnostic index, 2026-07-05 run)

| n | Identical shells | max ‖Δ‖₂ | sep(canonical) | sep(energiedoku diag) | sep(energiedoku full) |
|---|---|---|---|---|---|
| 1 | none | 2.0 | √2 ≈ 1.414 | √2 ≈ 1.414 | √2 ≈ 1.414 |
| 2 | none | 1.382 | √2 ≈ 1.414 | φ⁻² ≈ 0.382 | φ⁻² ≈ 0.382 |
| 3 | none | 1.472 | √2 ≈ 1.414 | φ⁻³ ≈ 0.236 | φ⁻³ ≈ 0.236 |

**Pattern:** Canonical qec_bridge yields axis directions with **sign flips** on `y`/`z` vs Lean `cardinalDir`. Diagnostic Energiedoku uses lex-first words (`E`, `EA`, …) — **not** the same EABC letters as qec_bridge prefix order (`C`, `A`, `B`, …).

**Hausdorff proxy (canonical vs energiedoku diagnostic):** 1.414 (n=1), 1.258 (n=2), 1.000 (n=3).

### sep(n) and ShellSeparationLoss

| n | ε (theorematic_energiedoku_v1) | Loss canonical? | Loss energiedoku diag? | Loss energiedoku full? |
|---|---|---|---|---|
| 1 | 1 | no | no | no |
| 2 | φ⁻² | no | **yes** (sep = ε, boundary) | **yes** |
| 3 | φ⁻³ | no | no | no |

| n | ε (theorematic_mn_sep_v1 = 4⁻ⁿ) | Loss canonical? | Loss energiedoku diag? |
|---|---|---|---|
| 1 | 0.25 | no | no |
| 2 | 0.0625 | no | no |
| 3 | 0.015625 | no | no |

**Key finding:** At **n=2**, energiedoku diagnostic/full embedding hits `sep(n) = φ⁻² = ε₂` exactly (collinear lattice words `EE`, `EA`, `EB`), so `ShellSeparationLoss` flags **true** under `theorematic_energiedoku_v1` while canonical remains **false**. This is a **diagnostic boundary artefact** (`sep ≤ ε`), not a violation of Lean’s proved `≥ ε` separation on distinct `ShellVertex(2)` pairs. Under `theorematic_mn_sep_v1`, neither construction shows loss.

### Does `ι_n` need rethinking?

**Yes — for formal `[B]`, not for the diagnostic runner alone.**

1. **Replace qec_bridge?** **No.** Keep `canonical_from_qec_bridge` as the all-`n` operational scaffold (currently `n ≤ 17`).
2. **Supplement with theorematic `ι_n`?** **Yes** for `n ≤ 3`: wire `EnergiedokuShellConstruction` / Lean cardinal-lattice coords into a parallel construction mode; do not merge combinatorics blindly (`4^n` vs `n+1`).
3. **n=2 loss artefact:** Diagnostic subset `EE, EA, EB` is collinear with spacing exactly `φ⁻²`; `ShellSeparationLoss` fires at equality — distinguish from Lean’s strict `≥ ε` on all distinct pairs in full `ShellVertex(2)`.
4. **Open:** Map qec_bridge parity-class prefix order to EABC word tree; prove prefix compatibility `ι_{n+1}|_{S_n} = ι_n`.
5. **Ikosaeder branch** (`icosahedronShellEmbedding_one`) not compared — optional follow-up.

### E-077–E-079 gate status (this comparison)

| Gate | Status |
|---|---|
| Theorematic `ι_n` for n ∈ {1,2,3} implemented in Python | ✅ `energiedoku_shell_construction.py` |
| Pointwise / sep comparison vs qec_bridge | ✅ this section + CSV |
| Replace qec_bridge with energiedoku for all n | ❌ not supported (`4^n` vs `n+1`, no all-n lattice) |
| E-077–E-079 upgrade to `[B]` | ❌ **remain `[C]`** |
| E-085 `shellPrimeMatchAtFirstLoss` | ❌ **GATE INACTIVE** / **PRE-REGISTRATION NOT COMPLETE** |

## Prefix mapping + full 4^n energiedoku (n=2,3) (2026-07-05)

**Purpose:** Close open gaps (A) qec_bridge prefix order ↔ EABC word tree and (B) full `ShellVertex(n)` diagnostics at `n=2,3` (16 and 64 points).

**Modules:** `src/kepler_hurwitz/shell_prefix_word_map.py`, `src/kepler_hurwitz/shell_embedding_comparison.py` (`run_full_energiedoku_diagnostics`)

**Reproduce:**

```bash
PYTHONPATH=src python scripts/compare_shell_embeddings.py --full-energiedoku --n-max 3
```

**Exports:**

| File | Content |
|---|---|
| `docs/energiedoku_exports/shell_prefix_word_map_n123.csv` | Prefix index → diagnostic lex word, axis label, nearest full word |
| `docs/energiedoku_exports/shell_energiedoku_full_n23.csv` | Full `4^n` sep, overlap, ShellSeparationLoss (both ε rules) |

### (A) Prefix ↔ EABC word mapping

| Question | Answer |
|---|---|
| Global bijection `prefix_index ↔ ShellVertex(n)`? | **No** (`partial_no_global_bijection`) |
| Cardinality | Prefix `n+1` vs `4^n` words |
| Order | qec_bridge parity discovery ≠ lex `E<A<B<C` |
| Coordinate exact match (diagnostic lex index)? | **None** at n=1,2,3 |
| Axis-label correspondence | Prefix idx0 `(-1,0,0)` → **C** (not lex-first **E**); y/z often sign-flipped vs `cardinalDir` |
| Nearest-word map (full `ShellVertex(n)`) | Partial, not injective at n≥2 (multiple prefix indices share nearest word) |

**Mapping rules documented:**

1. `index_diagnostic` — prefix index `i` → `i`-th lex word (aligned shell count only).
2. `coordinate_axis_label` — dominant axis → EABC letter (sign-aware).
3. `coordinate_nearest_word` — nearest full `ShellVertex(n)` under energiedoku embedding.

**Recommendation:** Do **not** treat diagnostic index alignment as a bijection. Use axis-label map for interpretive correspondence; use `EnergiedokuShellConstruction(mode='full')` for theorematic `4^n` checks at n≤3.

### (B) Full 4^n energiedoku diagnostics

| n | \|ShellVertex(n)\| | sep | overlap (ε=φ rule) | Loss (theorematic_energiedoku_v1)? | Loss (theorematic_mn_sep_v1)? |
|---|---|---|---|---|---|
| 1 | 4 | √2 ≈ 1.414 | 0 | no | no |
| 2 | **16** | **φ⁻² ≈ 0.382** | **24** | **yes** (sep = ε, boundary) | no |
| 3 | **64** | φ⁻³ ≈ 0.236 | 0 | no | no |

| Question | Answer |
|---|---|
| n=2 loss robust on full `ShellVertex(2)`? | **Yes** — not a diagnostic-subset artefact; collinear lattice words `EE`, `EA`, `EB`, … share min spacing exactly φ⁻² |
| `first_loss_n` (energiedoku full, φ thresholds)? | **2** |
| `first_loss_n` (energiedoku full, 4⁻ⁿ thresholds)? | **NONE** |
| Gate `shellPrimeMatchAtFirstLoss` | **INACTIVE** (no primindex coupling; Track B `n_0=2` not gate-eligible — see Dual-Track n₀ Governance) |

**Interpretation:** `ShellSeparationLoss` at n=2 fires because `sep(n) ≤ ε_n` with equality (`sep = φ⁻² = ε₂`). Lean proves strict `≥ ε` on **distinct** pairs in full `ShellVertex(2)`; the boolean diagnostic uses `≤`. Under `theorematic_mn_sep_v1`, full n=2,3 show no loss.

### Does `ι_n` need rethinking? (updated)

1. **Replace qec_bridge?** **No** — keep as all-n scaffold (n ≤ 17).
2. **Supplement with theorematic `ι_n`?** **Yes** for n≤3 — use `mode='full'` for `4^n` theorematic checks.
3. **Prefix↔word bridge?** **Partial only** — document three mapping rules; no global bijection.
4. **n=2 loss:** **Robust on full 16-word shell** — equality boundary, not subset-only artefact.

## Path B2: Unified ι_n bridge (exploratory) (2026-07-05)

**Purpose:** Document a **partial / interpretive** bridge `ι_n` between Track A (`canonical_from_qec_bridge`, prefix `n+1`) and Track B (`energiedoku_full`, `4^n`) for `n ∈ {1,2,3}` without activating E-085.

**Module:** `src/kepler_hurwitz/unified_shell_embedding.py`  
**Script:** `scripts/unified_shell_embedding_bridge.py`  
**Export:** `docs/energiedoku_exports/unified_embedding_bridge_n123.csv`

**Reproduce:**

```bash
PYTHONPATH=src python scripts/unified_shell_embedding_bridge.py --n-max 3
```

### Documented bridge rules

| Rule | Description | Proof label |
|---|---|---|
| `axis_label_map` | Prefix index → interpretive EABC letter (explicit table for n=1,2,3) | `[C]` / `[H]` |
| `coordinate_transform` | Uniform `(x,y,z) → (x,-y,-z)` sign correction vs `cardinalDir` | `[C]` convention |
| `prefix_compatibility` | `ι_{n+1}|_{S_n} = ι_n` on shared indices `0..n` under bridged coords | `[A]` verified n=1→2, 2→3 |
| `bridge_sep` | `sep(n)` under bridged coordinates vs both tracks | `[C]` diagnostic |

### Status summary

| Question | Answer |
|---|---|
| Global bijection on primary track? | **No** (`partial_interpretive_no_global_bijection`) |
| Prefix compatibility `ι_{n+1}|_{S_n} = ι_n`? | **Yes** on bridged Track-A coords for n=1→2, 2→3 `[A]` |
| `sep_bridged` vs `sep_canonical`? | **Identical** (uniform transform preserves pairwise distances) |
| `sep_bridged` vs energiedoku diagnostic? | **Diverges** — different combinatorics and embeddings |
| Gate eligibility | **`gate_eligible: false`** — bridge does **not** activate E-085 |
| `SHELL_PRIME_MATCH_GATE_ACTIVE` | **`false`** (unchanged) |

### What would satisfy B2 (checklist)

**Partial B2 (today):**

- [x] Explicit correspondence rules for n=1,2,3 documented
- [x] Compatibility check `ι_{n+1}|_{S_n} = ι_n` where checkable `[A]`
- [x] Proof-status labels `[A]` / `[C]` / `[H]` on each rule
- [x] CSV export + tests; gate remains inactive

**Full B2 (gate-eligible on primary track — not achieved):**

- [ ] Documented **bijection** `prefix_index ↔ ShellVertex(n)` on Track A primary construction for all n in pre-reg range, **or**
- [ ] New pre-registration (B1) adopting Track B as sole primary, **or**
- [ ] Reviewer sign-off that interpretive bridge suffices for `n_0` extraction (explicit policy change)

**Recommendation:** Track B remains a **separate theorematic reference strand** `[C]`. B2 partial bridge aids interpretive alignment (axis labels, sign correction) but cannot activate the gate without Track A bijection or B1 track switch.

## Related documents

- [`open_mathematical_bridge_targets.md`](../open_mathematical_bridge_targets.md)
- [`diagnostics_parameter_atlas.md`](../diagnostics_parameter_atlas.md)
- [`theory/meissner_analogy_assessment.md`](../theory/meissner_analogy_assessment.md)
- [`energiedoku_exports/eabc_renormalisierungsprogramm.md`](../energiedoku_exports/eabc_renormalisierungsprogramm.md)
- [`open_research_questions.md`](../open_research_questions.md) (ORQ-077–079, ORQ-086 gated)
- [`research_map.md`](../research_map.md)
- [`shell_separation_preregistration.json`](shell_separation_preregistration.json) (frozen parameters snapshot)
- [`shell_n0_dual_track_decision.md`](shell_n0_dual_track_decision.md) (Dual-Track n₀ decision memo)
- [`EVIDENCE_REGISTER.md`](../../EVIDENCE_REGISTER.md) (E-077–E-079, E-085)
- [`theory/README.md`](../theory/README.md)
