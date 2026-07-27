# Experiment plan — Core6 Dynamic D3 (after D2b freeze)

**Branch:** `cursor/core6-dynamic-d3-4007`  
**Base:** `cursor/core6-dynamic-feed-in-4007` (PR #17, D2b frozen at `18e8747`)  
**Module:** `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3`

## D3.3 freeze

**Math freeze head:** `24bd5c83718da11c9ec2bfa8962de331be117369`  
**Packaging tip:** `adb2dd84ea87473dd4e6c49ace50de15cb676297`

D3.0–D3.3d (trichotomy through residual ↔ reachability) are **mathematically
closed** on the math freeze head. Further work on PR #18 is limited to CI /
linter / review packaging — **no new kernel mathematics**.

The packaging tip is a Packaging/Docs-Commit with **exclusively non-semantic
Lean comments** (module freeze notice / non-theorem docs) plus audit artefacts.
It does **not** change definitions, theorems, proofs, or certificates.

Promotion of `[C→A]` → accepted repo-`[A]` waits for review ∧ merge ∧ a
**separate** promotion commit. ClaimsFreeze remains false until that commit.


## Status wall (after D3.3 freeze)

| Stufe | Aussage | Status |
|-------|---------|--------|
| D3.0–D3.2 | trichotomy / affine / path AP | `[C→A]`, CI-grün |
| D3.3a | feste First-Hit-Pfade und AP-Vereinigung | `[C→A]`, CI-grün |
| D3.3b | `¬ Core6PathFeedInGoal` | `[C→A]`, CI-grün |
| D3.3c | Feed-In/Residual-Zerlegung | `[C→A]`, CI-grün |
| D3.3d | `ResidualFeedInGoal ↔ ReachabilityFeedInGoal` | `[C→A]`, CI-grün |
| D3.4 | Residualstruktur / Re-Entry | `[C]` (follow-up) |
| D4 | Beweis von `ResidualFeedInGoal` | `[C]` |
| globale Reachability | folgt äquivalent aus D4 | `[C]` |

## Already formal (D3.3a–d)

- Packaging `core6PathFeedInSet = ⋃_p AP_p`
- `¬ Core6PathFeedInGoal` via `31 ∈ C_1`, `31 ∉ FeedIn`
- `C = FeedIn ∪̇ Residual`; Off-Core6 ⊆ Residual; Residual nonempty
- First-Hit bridge: FeedIn ⇒ contracting mass at `t = 7r`
- `ResidualFeedInGoal ↔ ReachabilityFeedInGoal`

The Core6-internal feed-in share is dynamically finished. The entire remaining
reachability question lies exactly in the residual set.

## Planned D3.4 architecture (design only — not in this freeze)

Residual is dynamically heterogeneous. Currently only

`oneBlockOffCore6Set ⊆ core6PathResidualSet`

is proved. The intended static split is a **Designziel**:

```
Residual = FiniteBlockExit ∪̇ ForeverExpandingBoundary
```

It is **not** a Lean statement and **not** a mathematical result in PR #18.
`OffCore6ReentryGoal` covers only the depth-1 exit class and is **not** a
substitute for `ResidualFeedInGoal`. Follow-up branch prefix:
`cursor/core6-dynamic-d34-residual-4007`.

## Non-goals on this tip

No D3.4 Lean definitions. No revival of `Core6PathFeedInGoal`. No Collatz
claim. No promotion to `[A]` without separate post-merge commit. D2b untouched.
