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

## Governance sequence (PR #19)

1. CI green (Lean Action, Quality Gate, Evidence Register Audit).
2. Review of manuscript + `Core6DynamicD34.lean`.
3. Merge PR #19.
4. **Separate** promotion commit `[C→A] → [A]` for D3.4.
5. Only then: D4 residual dynamics (`ResidualFeedInGoal`, re-entry, ForeverExp exclusion).

Merge alone must not silently change the epistemic tag. ClaimsFreeze remains false.

## Manuscript

German article: `docs/manuscripts/pre119_core6_residualdynamik.de.tex`

## Governance sequence

1. CI green (Lean Action, Quality Gate, Evidence Audit)
2. Review manuscript + `Core6DynamicD34.lean`
3. Merge onto accepted D3.3 base (stack `#15→#16→#17→#18→#19`; no jump to `main`)
4. Separate promotion commit `[C→A] → [A]` for D3.4
5. D4 follow-up remains `[C]` (FiniteExit re-entry / ForeverExp exclusion)

See `docs/exports/pre119_core6_dynamic_d34_closure_audit.md`.
Closure audit: `docs/exports/pre119_core6_dynamic_d34_closure_audit.md`
