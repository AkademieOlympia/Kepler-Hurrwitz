# Experiment plan — Core6 Dynamic Feed-In `[C]` / partial `[C→A]`

**Branch:** `cursor/core6-dynamic-feed-in-4007`  
**Base:** `cursor/core6-cylinder-partition-4007` (PR #16 stack)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn`

## Status wall (after D2b.1–.4)

| Object | Mathematical status | Repository status |
|--------|---------------------|-------------------|
| D1 representative census | finite reproducible evidence | `[B]` |
| `OneBlockFeedInGoal` | formally refuted | no positive claim |
| `not_oneBlockFeedInGoal` | Lean theorem | `[C→A]` |
| `realizedImage_fiberIndexMap` | affine block map `q+4374k` | `[C→A]` |
| `oneBlockIndexClass` / `existsUnique_…` | unique κ mod `2^{f+8}` | `[C→A]` |
| `1246239 ∈ oneBlockFeedInSet 1` | positive witness | `[C→A]` |
| `∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1` | sandwich | `[C→A]` |
| full disjoint-union decomp (D2b.5) | expected, not discharged | open |
| `ReachabilityFeedInGoal` | undecided | `[C]` |

Promotion of `[C→A]` → accepted repo-`[A]` waits for CI, review, and merge.

## Lean goals

### D2a — refuted universal one-block

Witness: `e₀=1`, `n=31`, image `137 ∉ contractingMass`.

### D2b.1 — affine index formula

```lean
theorem realizedImage_fiberIndexMap {e₀} (he₀ : 1 ≤ e₀) (k : Nat) :
    realizedImage (fiberIndexMap e₀ k) (fiberE e₀) =
      oneBlockBaseImage e₀ + 2 * 3 ^ 7 * k
```

Equivalently `q_{e₀} + 4374·k`.

### D2b.2 — target congruence

```lean
realizedImage (fiberIndexMap e₀ k) (fiberE e₀) ∈ canonicalCylinder f
  ↔ oneBlockBaseImage e₀ + 2*3^7*k ≡ canonicalBase f [MOD seedModulus f]
```

### D2b.3 — unique index class

`κ(e₀,f) = oneBlockIndexClass e₀ f` solves
`2187·κ ≡ (b_f − q_{e₀})/2` in `ZMod 2^{f+8}`, uniquely among residues `< 2^{f+8}`.

Bridge from this reduced congruence all the way to cylinder membership
(full cancel-by-2 equivalence) feeds D2b.5.

### D2b.4 — positive witness

`k=1217`, `n=Φ_1(1217)=1246239`, image `5323295 ∈ C_4`, hence
`1246239 ∈ oneBlockFeedInSet 1`, and
`∅ ⊂ oneBlockFeedInSet 1 ⊂ C_1`.

### Reachability (still open)

`¬ OneBlockFeedInGoal ⇏ ¬ ReachabilityFeedInGoal`.

## Ladder

| Phase | Content | Status |
|-------|---------|--------|
| **D0** | definitions, claim wall | done |
| **D1** | full representative census `[B]` | pilot done |
| **D2a** | formal `¬ OneBlockFeedInGoal` | `[C→A]` |
| **D2b.1** | affine `q+4374k` | `[C→A]` |
| **D2b.2** | target congruence packaging | `[C→A]` |
| **D2b.3** | unique κ class | `[C→A]` |
| **D2b.4** | positive witness + sandwich | `[C→A]` |
| **D2b.5** | disjoint progressive decomposition | open |
| **D3** | multi-step conditions | open `[C]` |
| **D4** | `ReachabilityFeedInGoal` | open `[C]` |

## Non-goals

No natural density, no Collatz collapse, no promotion of reachability from census hits.
