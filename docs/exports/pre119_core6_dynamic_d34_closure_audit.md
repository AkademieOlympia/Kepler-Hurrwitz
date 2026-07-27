# PR #19 Closure Audit — Core6 Dynamic D3.4 Residual Fine-Structure

**Status:** `[C→A]` until review ∧ merge ∧ **separate** promotion commit to `[A]`.  
**ClaimsFreeze:** false · **Collatz:** unproved · **0 sorry**

## Tip

| Item | Value |
|------|--------|
| Branch | `cursor/core6-dynamic-d34-residual-2ed1` |
| Base | `cursor/core6-dynamic-d3-4007` (PR #18 / D3.3 math freeze `24bd5c8`) |
| Module | `KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD34` |
| Build | `lake build KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD34` |
| Manuscript (DE) | `docs/manuscripts/pre119_core6_residualdynamik.de.tex` |

## Mathematical content (D3.4)

\[
R_{e_0}
=
C_{e_0}\setminus\mathrm{FeedIn}(e_0)
=
\mathrm{FiniteExit}(e_0)\;\dot\cup\;\mathrm{ForeverExp}(e_0)
\]

for expanding channels \(e_0\in\{1,2,3\}\).

| Claim | In PR #19? |
|-------|------------|
| `finiteBlockExitSet` / `foreverExpandingBoundarySet` | **yes** `[C→A]` |
| Off-Core6 depth-0 ⊆ FiniteExit (witness 31) | **yes** |
| FiniteExit / ForeverExp ⊆ Residual, disjoint | **yes** |
| Residual dichotomy | **yes** |
| `ResidualFeedInGoal` discharged | **no** `[C]` |
| Off-Core6 re-entry / ForeverExp exclusion | **no** `[C]` |
| Global Collatz | **no** |

Entry: `theorem core6DynamicD34ResidualGoals_named`.

## Epistemic stack (programme wall)

| Layer | Tag | Content |
|-------|-----|---------|
| PR #15–#16 | `[A]`-Pfad / promotion after stack merge | Core6 existence, \(C_e\simeq\mathbb{N}\), relative dyadic density \(1/8\) |
| PR #17–#18 | `[C→A]` | 1-block D2b, path-AP (D3.2), Residual ⇔ Reachability (D3.3d) |
| PR #19 (D3.4) | `[C→A]` (this draft) | \(R_{e_0}=\mathrm{FiniteExit}\,\dot\cup\,\mathrm{ForeverExp}\) |
| Re-Entry / Reaches | `[C]` | convergence on FiniteExit; exclusion of ForeverExp |

## Governance sequence (do not skip)

1. Await CI green on PR #19: Lean Action, Quality Gate, Evidence Register Audit.
2. Review manuscript + `Core6DynamicD34.lean`.
3. Merge PR #19 onto its **accepted D3.3 base** (stack order `#15 → #16 → #17 → #18 → #19`); do **not** jump ahead of unmerged freeze PRs into `main`.
4. **Separate** promotion commit: `[C→A] → [A]` for D3.4 only after merge.
5. Open D4 follow-up for ResidualFeedIn / ForeverExp dynamics (`[C]`).

Merge alone must not silently change the epistemic tag.

## Sorry / admit scan

```bash
rg -n -P '(^|[^A-Za-z0-9_/`])(sorry|admit)([^A-Za-z0-9_]|$)' \
  KeplerHurwitz/Collatz/Pre119Draft/Core6DynamicD34.lean
```

**Result:** no `sorry` / `admit`.
