# Experiment plan — Core6 Dynamic Feed-In `[C]` / partial `[C→A]`

**Branch:** `cursor/core6-dynamic-feed-in-4007`  
**Base:** `cursor/core6-cylinder-partition-4007` (PR #16 stack)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn`

## Status wall (after D1 pilot + D2a + D2b skeleton)

| Object | Mathematical status | Repository status |
|--------|---------------------|-------------------|
| D1 representative census | finite reproducible evidence | `[B]` |
| `OneBlockFeedInGoal` | formally refuted | no positive claim |
| `not_oneBlockFeedInGoal` | Lean theorem on branch | `[C→A]` |
| `oneBlockFeedInSet` | characterization object | D2b in progress |
| `oneBlockFeedInSet 1 ⊂ C_1` | Lean theorem (witness `31`) | `[C→A]` |
| `ReachabilityFeedInGoal` | undecided | `[C]` |
| universal reachability / collapse | not claimed | — |

`[B]` may support or falsify a `[C]` hypothesis; it never replaces a Lean proof and never creates `[A]` alone.
Promotion of `[C→A]` → accepted repo-`[A]` waits for CI, review, and merge.

## Lean goals

### Refuted universal one-block claim (D2a)

```lean
def OneBlockFeedInGoal : Prop :=
  ∀ e₀, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      realizedImage n (fiberE e₀) ∈ contractingMass
```

**Witness:** `e₀=1`, `n=31`, `realizedImage 31 (fiberE 1) = 137 ∉ contractingMass`.  
Lean: `theorem not_oneBlockFeedInGoal : ¬ OneBlockFeedInGoal`.

Kernel packaging:
\[
31\in C_1 \;\land\;
\operatorname{realizedImage}(31,\operatorname{fiberE}(1))=137 \;\land\;
137\notin\operatorname{contractingMass}
\quad\Longrightarrow\quad
\neg\texttt{OneBlockFeedInGoal}.
\]

One-block evaluation does **not** depend on the reachability horizon `T`.
Correct phrasing for the pilot: **0 of 56 stage representatives are one-block hits**
— not “0 one-block hits until T=32”.

### Characterization set (D2b)

```lean
def oneBlockFeedInSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ contractingMass}
```

Delivered skeleton (`[C→A]`):
- `OneBlockFeedInGoal ↔ ∀ e₀∈{1,2,3}, oneBlockFeedInSet e₀ = C_{e₀}`
- `31 ∉ oneBlockFeedInSet 1`
- `oneBlockFeedInSet 1 ⊂ canonicalCylinder 1`

Still open: emptiness / positive membership / arithmetic structure of
`oneBlockFeedInSet(e₀)` beyond the proper-subset witness. A finite D1 census
with zero one-block hits among stage representatives does **not** prove emptiness
of the infinite-fiber set.

### Reachability (still open)

```lean
def ReachabilityFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ t, 1 ≤ t ∧ syracuseOddIterate t n ∈ contractingMass
```

Quantifier distinction:
\[
\neg\texttt{OneBlockFeedInGoal}
\;=\;
\exists n\in\mathrm{expandingMass}:\;
U^{\circ 7}(n)\notin\mathrm{contractingMass},
\]
while reachability asks for some (possibly later) odd iterate. Explicitly:
\[
\neg\texttt{OneBlockFeedInGoal}
\;\not\Rightarrow\;
\neg\texttt{ReachabilityFeedInGoal}.
\]

## Claim wall

| Static / local fact | Illegal dynamical reading |
|---------------------|---------------------------|
| `#contr / #Core6 → 1/8` | hitting probability |
| `R_m^contr ⊆ R_m^Core6` | orbits enter contracting fibers |
| `¬ OneBlockFeedInGoal` | `¬ ReachabilityFeedInGoal` |
| `oneBlockFeedInSet 1 ⊂ C_1` | `oneBlockFeedInSet e₀ = ∅` |

## D1 — full census of **stage representatives** `[B]`

For stage `m ≥ 3`, enumerate all canonical expanding residues at `Q_m = 2^{m+9}`:

$$
n=\Phi_{e_0}(k)=b_{e_0}+k\cdot 2^{e_0+9},\qquad
e_0\in\{1,2,3\},\qquad 0\le k<2^{m-e_0}.
$$

This is a complete census of **stage representatives**, not of all elements of the
infinite fibers `C_1,C_2,C_3`. Without a dynamical congruence-stability theorem,
lift behaviour does not automatically transfer.

### Pilot `m=6`, `T=32` (`param_hash=ccd46f0393bb72e4`)

| | count |
|--|------:|
| starts | 56 |
| reachability hits (≤T) | 2 |
| censored at T | 54 |
| one-block hits | **0** (independent of T) |

- `e₀=1`: hit at `t=10`, target `e=4`
- `e₀=2`: hit at `t=28`, target `e=7`
- `e₀=3`: no hit ≤32
- Censoring ≠ counterexample to reachability

Artifact: `docs/exports/artifacts/d1_census/summary_m6_T32.json`

```bash
PYTHONPATH=. python3 scripts/core6_dynamic_feed_in_d1_census.py --m 8 --T 64 \
  --jsonl /tmp/d1.jsonl --summary /tmp/d1_summary.json
```

## Ladder

| Phase | Content | Status |
|-------|---------|--------|
| **D0** | definitions, claim wall | done |
| **D1** | full representative census `[B]` | pilot done |
| **D2a** | formal `¬ OneBlockFeedInGoal` | Lean candidate `[C→A]` |
| **D2b** | structure of `oneBlockFeedInSet` | skeleton: proper subset `e₀=1`; structure open |
| **D3** | sufficient multi-step reachability conditions | open `[C]` |
| **D4** | `ReachabilityFeedInGoal` | open `[C]` |

## Non-goals

No natural density, no Collatz collapse, no promotion of reachability from census hits.
