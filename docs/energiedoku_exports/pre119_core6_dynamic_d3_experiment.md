# Experiment plan — Core6 Dynamic D3 (after D2b freeze)

**Branch:** `cursor/core6-dynamic-d3-4007`  
**Base:** `cursor/core6-dynamic-feed-in-4007` (PR #17, D2b frozen at `18e8747`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3`

## Scope

Algebraic D3.0–D3.2. Universal dynamical goals are defined but open `[C]`.

| Phase | Content | Status |
|-------|---------|--------|
| D3.0 | one-block trichotomy + expanding-return APs | `[C→A]` |
| D3.1 | affine target-index transport (`+2187 r`) | `[C→A]` |
| D3.2 | finite channel paths (defs + length-2 + hop step) | `[C→A]` |
| D3.3 | `BlockBoundaryFeedInGoal` | defined; open `[C]` |
| D3.4 | `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ReachabilityFeedInGoal` | still `[C]` |

## Delivered

### D3.0
- `oneBlockExpandingReturnSet`, `oneBlockOffCore6Set`
- `canonicalCylinder_eq_oneBlock_trichotomy` + pairwise disjointness
- `oneBlockExpandingReturnSet = ⋃_{1≤f≤3} P_{e₀,f}`
- Off-Core6 witness: `31 ∈ oneBlockOffCore6Set 1`

### D3.1
- `oneBlockTargetBaseIndex` / `oneBlock_targetIndex_affine`
- `BlockBoundaryFeedInGoal → ReachabilityFeedInGoal` (implication only)

### D3.2
- `RealizesChannelPath`, `channelPathIndexModulus`, `channelPathIndexClass`
- `channelPathIndexMap` / `channelPathProgression`
- Length-2: progression = `oneBlockTargetProgression`; fiber-index κ-class iff
- Hop composition: `realizesChannelPath_cons_fiberIndex_step` + residual congruence
- Witness: `RealizesChannelPath [1, 4] 1246239`

## Non-goals

No universal reachability discharge. Finite path APs are structure, not a ∀-proof.
No Collatz claim. D2b package untouched.

## Next algebraic knot

Full arbitrary-length path characterization via CRT composition of residuals
(same engine as length-2 / hop-step). Still `[C→A]` for each fixed path; not D3.3/D4.
