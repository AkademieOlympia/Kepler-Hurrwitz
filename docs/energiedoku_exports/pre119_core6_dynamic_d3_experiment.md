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
| D3.3b | `not_core6PathFeedInGoal` | `[C→A]` |
| D3.3c | `C = FeedIn ∪̇ Residual` | `[C→A]` |
| D3.3d | `ResidualFeedInGoal ↔ ReachabilityFeedInGoal` | `[C→A]` |
| D3.4 | residual structure / `OffCore6ReentryGoal` | defined; open `[C]` |
| D4 | `ResidualFeedInGoal` (≡ Reachability) | still `[C]` |

## Already formal (D3.3b–c)

- `¬ Core6PathFeedInGoal` via `31 ∈ C_1`, `31 ∉ core6PathFeedInSet 1`
- Cylinder decomposition and Off-Core6 ⊆ Residual
- First-Hit path class is excluded as a complete global solution

## D3.3d — equivalence needs the First-Hit bridge

The equivalence is **not** a consequence of the decomposition alone.

- **Feed-in bridge** (`[C→A]`):  
  `n ∈ core6PathFeedInSet e₀ ⇒ ∃ t, U^{∘t}(n) ∈ contractingMass`  
  via `mem_core6PathFeedInSet_reaches_contractingMass`
- **Forward:** Residual ⇒ Reachability uses decomposition + bridge
- **Reverse:** Reachability ⇒ Residual is immediate (Residual ⊆ expanding mass)

## Open front

Global dynamical proof is reduced to the residual. Open work:

- D3.4 structure of `core6PathResidualSet` / re-entry mechanisms
- D4 discharge of `ResidualFeedInGoal`

## Non-goals

No revival of `Core6PathFeedInGoal`. No Collatz claim. D2b untouched.
