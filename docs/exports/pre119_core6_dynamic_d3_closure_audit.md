# PR #18 Closure Audit — Core6 Dynamic D3.3 Freeze

**Status:** `[C→A]` until review ∧ merge ∧ separate promotion commit to `[A]`.

## Two-SHA freeze structure (mathematical content)

| Layer | SHA | Role |
|-------|-----|------|
| **Math freeze (D3.0–D3.3d)** | `24bd5c83718da11c9ec2bfa8962de331be117369` | final mathematical content |
| **Packaging with Lean comments** | `adb2dd84ea87473dd4e6c49ace50de15cb676297` | freeze notice in module + audit docs |

Remote CI for the math freeze `24bd5c8` was fully green (Lean Action, Quality
Gate, Evidence Register Audit). Later packaging tips may still have Quality Gate
queued while Lean / Evidence Audit are already green.

### Precise nature of packaging commit `adb2dd8`

`adb2dd8` is **not** literally “docs-only / no Lean file touched”.

Against the math freeze it adds exactly one commit with:

- three documentation / audit artefacts under `docs/`;
- **20 lines** in `Core6DynamicD3.lean` that are **exclusively** module
  comments and freeze / non-theorem documentation.

No definitions, theorems, proofs, or bundled certificates changed.

Exact label:

> Packaging/Docs-Commit mit ausschließlich nichtsemantischen Lean-Kommentaren.

Incorrect label:

> „Der Commit verändert keine Lean-Datei.“

A subsequent tip may add further **literal docs-only** audit wording fixes
without touching Lean; those do not move the mathematical freeze.

## Governance boundary (strict freeze)

**No new kernel mathematics in PR #18.**

Allowed:

- CI / import fixes;
- linter fixes;
- review-driven proof repairs without scope expansion;
- documentation, audit, and packaging adjustments.

Forbidden:

- `FiniteBlockExit` / `ForeverExpandingBoundary` definitions;
- new residual decompositions;
- re-entry theorems;
- attempts to prove `ResidualFeedInGoal`;
- premature promotion to `[A]`.

Follow-up branch prefix: `cursor/core6-dynamic-d34-residual-4007`.

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

## `#print axioms` (selected; math freeze)

### `core6DynamicD3AlgebraGoals_named`

Depends on: `propext`, `Classical.choice`, `Quot.sound`, plus `native_decide`
certificates for fixed Nat identities. No unpaid proof debt.

### `residualFeedIn_iff_reachability`

Depends on: `propext`, `Classical.choice`, `Quot.sound`, and
`coeff3_coprime_seedModulus` native_decide. No unpaid proof debt.

### `not_core6PathFeedInGoal`

Depends on: kernel/classical axioms plus D2b witness native_decide certificates
for `31 ↦ 137 ∉ core6`. No unpaid proof debt.

## Frozen mathematical content (at `24bd5c8`)

| Item | Status |
|------|--------|
| One-block trichotomy | `[C→A]` |
| Affine target-index transport | `[C→A]` |
| Fixed-path AP characterization | `[C→A]` |
| `core6PathFeedInSet = ⋃_p AP_p` | `[C→A]` |
| `¬ Core6PathFeedInGoal` | `[C→A]` |
| `C = FeedIn ∪̇ Residual` | `[C→A]` |
| First-Hit bridge (FeedIn ⇒ contracting mass) | `[C→A]` |
| `ResidualFeedInGoal ↔ ReachabilityFeedInGoal` | `[C→A]` |

Entry point: `theorem core6DynamicD3AlgebraGoals_named`.

## Claim wall

| Claim | In PR #18 math freeze? |
|-------|------------------------|
| Core6-internal First-Hit AP packaging | **yes** |
| `¬ Core6PathFeedInGoal` | **yes** |
| Feed-In / Residual decomposition | **yes** |
| Residual ↔ Reachability (via bridge) | **yes** |
| Residual fine-structure (FiniteExit / ForeverExpanding) | **no** — design only |
| `ResidualFeedInGoal` discharged | **no** (`[C]`) |
| Global Collatz / natural density | **no** |

## D3.4 design (not a Lean statement)

Planned split (paper architecture only):

`Residual = FiniteBlockExit ∪̇ ForeverExpandingBoundary`

Status: **Designziel, keine Lean-Aussage und kein mathematisches Resultat.**
Formalization belongs exclusively in the follow-up PR.

## Promotion process

`[C→A] xrightarrow{Review ∧ Merge} accepted repository content xrightarrow{separate commit} [A]`

Merge alone must not silently change the epistemic tag.

## Stack merge order

1. Integrate PR #15 → #16 → #17 (D2b freeze) first.  
2. Retarget/rebase PR #18 onto accepted feed-in base if needed.  
3. Wait for packaging-tip CI fully green; review & merge PR #18.  
4. Separate status-promotion commit `[C→A] → [A]` for D3.0–D3.3d.  
5. Open follow-up branch for D3.4 / D4.

## Out of scope after freeze

No new residual mathematics on this PR. Stabilize and review PR #18;
any further residual mathematics belongs in the follow-up PR.
