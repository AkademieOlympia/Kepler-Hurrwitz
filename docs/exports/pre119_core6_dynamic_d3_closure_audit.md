# PR #18 Closure Audit — Core6 Dynamic D3.3 Freeze

**Status:** `[C→A]` until review ∧ merge ∧ separate promotion commit to `[A]`.

Remote CI for head `24bd5c8` reported green (Lean Action, Quality Gate,
Evidence Register Audit). Packaging tip may advance docs-only after the math
freeze without mathematical divergence.

## Freeze cascade

| Layer | SHA | Role |
|-------|-----|------|
| **1. Mathematical freeze (D3.0–D3.3d)** | `24bd5c83718da11c9ec2bfa8962de331be117369` | trichotomy through residual ↔ reachability |
| **2. Claim-audit / freeze packaging** | *(this tip)* | freeze notice, audit, D3.4 roadmap only |

No Lean mathematics after layer 1 on this PR.

## Toolchain

| Item | Value |
|------|--------|
| Lean | 4.31.0 |
| Module | `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3` |
| Build | `lake build KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3` |
| Local build | success |

## Sorry / admit scan

```bash
rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' \
  KeplerHurwitz/Collatz/Pre119Draft/Core6DynamicD3.lean
```

**Result:** no `sorry` / `admit` tactics.

## `#print axioms` (selected)

### `core6DynamicD3AlgebraGoals_named`

Depends on: `propext`, `Classical.choice`, `Quot.sound`, plus `native_decide`
certificates for fixed Nat identities (CanonicalBase / D2b witnesses / Core6
nil-checks). No unpaid proof debt.

### `residualFeedIn_iff_reachability`

Depends on: `propext`, `Classical.choice`, `Quot.sound`, and
`coeff3_coprime_seedModulus` native_decide. No unpaid proof debt.

### `not_core6PathFeedInGoal`

Depends on: kernel/classical axioms plus D2b witness native_decide certificates
for `31 ↦ 137 ∉ core6`. No unpaid proof debt.

## Closure package (bundled)

| Field / theorem | Role |
|-----------------|------|
| `core6PathFeedInSet_eq_iUnion_progressions` | D3.3a packaging |
| `not_core6PathFeedInGoal` | D3.3b refutation |
| `canonicalCylinder_eq_core6PathFeedIn_union_residual` | D3.3c split |
| `mem_core6PathFeedInSet_reaches_contractingMass` | First-Hit bridge |
| `residualFeedIn_iff_reachability` | D3.3d equivalence |

Entry point: `theorem core6DynamicD3AlgebraGoals_named : Core6DynamicD3AlgebraGoals`.

## Claim wall (frozen)

| Claim | In PR #18 math freeze? |
|-------|------------------------|
| Core6-internal First-Hit AP packaging | **yes** |
| `¬ Core6PathFeedInGoal` | **yes** |
| Feed-In / Residual decomposition | **yes** |
| Residual ↔ Reachability (via bridge) | **yes** |
| Residual fine-structure (FiniteExit / ForeverExpanding) | **no** (D3.4 follow-up) |
| `ResidualFeedInGoal` discharged | **no** (`[C]`) |
| Global Collatz / natural density | **no** |

## What the reduction does / does not do

- Feed-In share needs **no further dynamics** (bridge gives `t = 7r` hit).
- Residual is a **localization of the full open difficulty**, not a weakening:
  `ResidualFeedInGoal ↔ ReachabilityFeedInGoal`.
- Residual is heterogeneous; currently only Off-Core6 ⊆ Residual is proved.
  `OffCore6ReentryGoal` is a depth-1 subclass, not a substitute for D4.

## Stack merge order

1. Integrate PR #15 → #16 → #17 (D2b freeze) first.  
2. Retarget/rebase PR #18 onto accepted feed-in base if needed.  
3. Re-run full CI on the tip.  
4. Review & merge PR #18.  
5. Separate status-promotion commit `[C→A] → [A]` for D3.0–D3.3d after merge.  
6. Open follow-up branch `cursor/core6-dynamic-d34-residual-4007` for D3.4 / D4.

## Out of scope after freeze

No FiniteBlockExit / ForeverExpanding Lean definitions on this tip.
No residual dynamics / re-entry proofs.
No Collatz claim.
Only proof/import/linter/doc/review fixes until merge.
