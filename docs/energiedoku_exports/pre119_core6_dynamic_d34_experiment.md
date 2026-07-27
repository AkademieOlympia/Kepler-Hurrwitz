# Experiment — Core6 Dynamic D3.4 Residual Fine-Structure

**Branch:** `cursor/core6-dynamic-d34-residual-2ed1`  
**Base:** `cursor/core6-dynamic-d3-4007` (PR #18, D3.3 math freeze `24bd5c8`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD34`

## Delivered

```
core6PathResidualSet e₀
  = finiteBlockExitSet e₀ ∪̇ foreverExpandingBoundarySet e₀
```

for expanding start channels `e₀ ∈ {1,2,3}`.

| Item | Status |
|------|--------|
| `finiteBlockExitSet` | `[C→A]` |
| `foreverExpandingBoundarySet` | `[C→A]` |
| `oneBlockOffCore6Set ⊆ finiteBlockExitSet` | `[C→A]` |
| witness `31 ∈ finiteBlockExitSet 1` | `[C→A]` |
| both subsets of residual | `[C→A]` |
| disjointness | `[C→A]` |
| residual dichotomy | `[C→A]` |
| `ResidualFeedInGoal` | still `[C]` |
| `OffCore6ReentryGoal` | still `[C]` |
| Collatz / ClaimsFreeze | open / false |

Entry point: `theorem core6DynamicD34ResidualGoals_named`.

## Non-goals

No discharge of residual reachability. No forever-boundary exclusion.
No Collatz claim. D3.3 freeze tip untouched as mathematical content.

## Manuscript

German article: `docs/manuscripts/pre119_core6_residualdynamik.de.tex`
