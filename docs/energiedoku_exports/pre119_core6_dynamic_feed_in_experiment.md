# Experiment plan — Core6 Dynamic Feed-In `[C]` / partial `[C→A]`

**Branch:** `cursor/core6-dynamic-feed-in-4007`  
**Base:** `cursor/core6-cylinder-partition-4007` (PR #16 stack)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn`

## Status wall (after D2b.1–.5)

| Object | Mathematical status | Repository status |
|--------|---------------------|-------------------|
| D1 representative census | finite reproducible evidence | `[B]` |
| `OneBlockFeedInGoal` | formally refuted | no positive claim |
| `not_oneBlockFeedInGoal` | Lean theorem | `[C→A]` |
| `realizedImage_fiberIndexMap` | affine block map `q+4374k` | `[C→A]` |
| Cancel-by-2 bridge | image∈C_f ↔ k≡κ | `[C→A]` |
| `oneBlockIndexClass` | unique κ mod `2^{f+8}` | `[C→A]` |
| `1246239 ∈ oneBlockFeedInSet 1` | positive witness | `[C→A]` |
| `∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1` | sandwich | `[C→A]` |
| `oneBlockFeedInSet = ⋃_{f≥4} P_{e₀,f}` | D2b.5 decomposition | `[C→A]` |
| pairwise disjoint progressions | via PR #16 cylinders | `[C→A]` |
| `ReachabilityFeedInGoal` | undecided | `[C]` |

Promotion of `[C→A]` → accepted repo-`[A]` waits for CI, review, and merge.

## Lean goals

### D2a — refuted universal one-block

Witness: `e₀=1`, `n=31`, image `137 ∉ contractingMass`.

### D2b.1 — affine index formula

`realizedImage (fiberIndexMap e₀ k) (fiberE e₀) = q_{e₀} + 4374·k`.

### Cancel-by-2 + D2b.2–.3

```lean
theorem fiberIndexImage_mem_target_iff_index_modEq
    {e₀ f k} (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) ∈ canonicalCylinder f ↔
      k ≡ oneBlockIndexClass e₀ f [MOD oneBlockIndexModulus f]
```

Proved via `2M ∣ 2x ↔ M ∣ x` on `ℤ`, then unique κ.

### D2b.4 — positive witness

`k=1217`, `n=1246239`, image `5323295 ∈ C_4` ⇒ sandwich.

### D2b.5 — progression decomposition

```lean
def oneBlockTargetProgression (e₀ f : Nat) : Set Nat
theorem oneBlockFeedInSet_eq_iUnion_progressions :
    oneBlockFeedInSet e₀ = ⋃ f ≥ 4, oneBlockTargetProgression e₀ f
```

Each `P_{e₀,f}` is nonempty and infinite; pairwise disjoint for `f≠g`
by PR #16 cylinder disjointness on the one-block image.

### Reachability (still open)

`¬ OneBlockFeedInGoal ⇏ ¬ ReachabilityFeedInGoal`.  
D2b classifies the one-block edge; D3/D4 treat multi-step residues.

## Ladder

| Phase | Content | Status |
|-------|---------|--------|
| **D0** | definitions, claim wall | done |
| **D1** | full representative census `[B]` | pilot done |
| **D2a** | formal `¬ OneBlockFeedInGoal` | `[C→A]` |
| **D2b.1–.5** | affine map → Cancel-by-2 → κ → witness → AP decomp | `[C→A]` |
| **D3** | multi-step conditions | open `[C]` |
| **D4** | `ReachabilityFeedInGoal` | open `[C]` |

## Non-goals

No natural density, no Collatz collapse, no promotion of reachability from census hits.
