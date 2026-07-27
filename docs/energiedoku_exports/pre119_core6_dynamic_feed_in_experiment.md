# Experiment plan — Core6 Dynamic Feed-In `[C]` / partial `[C→A]`

**Branch:** `cursor/core6-dynamic-feed-in-4007`  
**Base:** `cursor/core6-cylinder-partition-4007` (PR #16 stack)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn`

## Status wall (after D1 pilot + D2a witness)

| Object | Status |
|--------|--------|
| D1 representative census | `[B]` |
| `OneBlockFeedInGoal` (universal) | empirically falsified |
| `¬ OneBlockFeedInGoal` | **`[C→A]`** Lean candidate (`not_oneBlockFeedInGoal`) |
| `ReachabilityFeedInGoal` | **`[C]`** open |
| observed finite hits | `[B]` existence only |
| universal reachability / collapse | not claimed |

`[B]` may support or falsify a `[C]` hypothesis; it never replaces a Lean proof and never creates `[A]` alone.

## Lean goals

### Refuted universal one-block claim

```lean
def OneBlockFeedInGoal : Prop :=
  ∀ e₀, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ canonicalCylinder e₀,
      realizedImage n (fiberE e₀) ∈ contractingMass
```

**Witness (D2a):** `e₀=1`, `n=31`, `realizedImage 31 (fiberE 1) = 137 ∉ contractingMass`.  
Lean: `theorem not_oneBlockFeedInGoal : ¬ OneBlockFeedInGoal`.

One-block evaluation does **not** depend on the reachability horizon `T`.
Correct phrasing for the pilot: **0 of 56 stage representatives are one-block hits**
— not “0 one-block hits until T=32”.

### Characterization set (D2b)

```lean
def oneBlockFeedInSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ contractingMass}
```

Open structural question: for which `n ∈ C_{e₀}` does one-block feed-in hold?

### Reachability (still open)

```lean
def ReachabilityFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ t, 1 ≤ t ∧ syracuseOddIterate t n ∈ contractingMass
```

## Claim wall

| Static fact (PR #16) | Illegal dynamical reading |
|----------------------|---------------------------|
| `#contr / #Core6 → 1/8` | hitting probability |
| `R_m^contr ⊆ R_m^Core6` | orbits enter contracting fibers |
| `¬ OneBlockFeedInGoal` | `¬ ReachabilityFeedInGoal` |

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
| **D2b** | characterize `oneBlockFeedInSet` | open |
| **D3** | sufficient reachability conditions | open `[C]` / later `[C→A]` |
| **D4** | universal reachability | open `[C]` |

## Non-goals

No natural density, no Collatz collapse, no promotion of reachability from census hits.
