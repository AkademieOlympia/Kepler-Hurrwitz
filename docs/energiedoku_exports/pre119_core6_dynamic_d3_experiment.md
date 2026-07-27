# Experiment plan — Core6 Dynamic D3 (after D2b freeze)

**Branch:** `cursor/core6-dynamic-d3-4007`  
**Base:** `cursor/core6-dynamic-feed-in-4007` (PR #17, D2b frozen at `18e8747`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3`

## Scope

| Phase | Content | Status |
|-------|---------|--------|
| D3.0 | one-block trichotomy | `[C→A]` |
| D3.1 | affine target-index transport | `[C→A]` |
| D3.2 | fixed-path AP equivalence | `[C→A]` |
| D3.3a | packaging `core6PathFeedInSet = ⋃ AP_p` | `[C→A]` |
| D3.3b | `Core6PathFeedInGoal` (coverage) | defined; open `[C]` |
| D3.4 | `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ReachabilityFeedInGoal` | still `[C]` |

## D3.3a delivered

- `IsContractingFirstHitPath` — expanding start/interior, first contracting hit at end
- `core6PathFeedInSet` — union of realizers of such paths
- `core6PathFeedInSet_eq_iUnion_progressions` — packaging via D3.2
- Index vs number modulus: `channelPathNumberModulus = 2^{e₀+9}·M_p`
- Witness `1246239 ∈ core6PathFeedInSet 1`; exclusion `31 ∉ core6PathFeedInSet 1`
- Implications:
  `Core6PathFeedInGoal ⇒ BlockBoundaryFeedInGoal ⇒ ReachabilityFeedInGoal`

## Quantifier boundary

D3.3a packages `∀ p, AP_p`. It does **not** prove `∀ n, ∃ p`.
Off-Core6 exits are outside the path-feed-in set; Re-Entry is D3.4 `[C]`.

## Non-goals

No universal coverage. No Collatz claim. D2b untouched.
