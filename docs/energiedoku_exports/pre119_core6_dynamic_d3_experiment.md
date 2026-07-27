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
| D3.3b | `not_core6PathFeedInGoal` | `[C→A]` (coverage false) |
| D3.3c | `core6PathResidualSet` decomposition | `[C→A]` |
| D3.4 | `ResidualFeedInGoal` / `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ReachabilityFeedInGoal` | still `[C]` |

## D3.3a–c delivered

- `IsContractingFirstHitPath` — expanding start/interior, first contracting hit at end
- `core6PathFeedInSet` — union of realizers of such paths
- `core6PathFeedInSet_eq_iUnion_progressions` — packaging via D3.2
- Witness `1246239 ∈ core6PathFeedInSet 1`; exclusion `31 ∉ core6PathFeedInSet 1`
- `not_core6PathFeedInGoal` — formal refutation via `31 ∈ C_1`
- `core6PathResidualSet = C_{e₀} \ core6PathFeedInSet`
- `C_{e₀} = core6PathFeedInSet ∪ residual` (disjoint); Off-Core6 ⊆ residual
- Implications (premise false; implications still valid):
  `Core6PathFeedInGoal ⇒ BlockBoundaryFeedInGoal ⇒ ReachabilityFeedInGoal`

## Quantifier boundary

D3.3a packages `∀ p, Realizer(p) = AP_p`. The coverage
`∀ n ∈ C₁∪C₂∪C₃, ∃ p` is **false** for this path family, not merely open:
`⋃_p AP_p ⊊ C_1` (witness `31`). Residual re-entry is D3.4 `[C]`.

## Non-goals

No attempt to revive `Core6PathFeedInGoal`. No Collatz claim. D2b untouched.
