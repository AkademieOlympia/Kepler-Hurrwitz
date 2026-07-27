# Experiment plan — Core6 Dynamic D3 (after D2b freeze)

**Branch:** `cursor/core6-dynamic-d3-4007`  
**Base:** `cursor/core6-dynamic-feed-in-4007` (PR #17, D2b frozen at `18e8747`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3`

## Scope

Algebraic D3.0–D3.1 only. Universal dynamical goals are defined but open `[C]`.

| Phase | Content | Status |
|-------|---------|--------|
| D3.0 | one-block trichotomy + expanding-return APs | `[C→A]` |
| D3.1 | affine target-index transport (`+2187 r`) | `[C→A]` |
| D3.2 | finite channel-path composition | deferred |
| D3.3 | `BlockBoundaryFeedInGoal` | defined; open `[C]` |
| D3.4 | `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ReachabilityFeedInGoal` | still `[C]` |

## Delivered

- `oneBlockExpandingReturnSet`, `oneBlockOffCore6Set`
- `canonicalCylinder_eq_oneBlock_trichotomy` + pairwise disjointness
- `oneBlockExpandingReturnSet = ⋃_{1≤f≤3} P_{e₀,f}`
- Off-Core6 witness: `31 ∈ oneBlockOffCore6Set 1`
- `oneBlockTargetBaseIndex` / `oneBlock_targetIndex_affine`
- `BlockBoundaryFeedInGoal → ReachabilityFeedInGoal` (implication only)

## Non-goals

No universal reachability discharge. No Collatz claim. D2b package untouched.
