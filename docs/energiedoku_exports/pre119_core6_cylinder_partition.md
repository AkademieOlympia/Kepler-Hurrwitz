# Pre119 — Core6 Cylinder Partition (PR #16)

**Epistemic wall:** This document describes the **target architecture** of PR #16.
It must not be confused with repository `[A]` status.

## Repo-of-record `[A]` (PR #15 only)

$$
\forall e \ge 4;\ \forall k,\quad
\operatorname{ApMemberOkFrom}\bigl(e,\operatorname{canonicalBase}(e),k\bigr).
$$

Canonical base, realization for `e≥4`, infinite AP lifting, contraction on those APs.
Coverage densities in PR #15 docs remain **documented expectations**, not Lean
partition theorems.

## PR #16 target ladder — all `[C→A]` until CI-green merge

| Paket | Inhalt | Status |
|-------|--------|--------|
| 16a | `canonicalBase_realizes_of_one_le` (`∀ e≥1`, kanonischer Seed — nicht bloß ∃) | `[C→A]` |
| 16b | `mem_canonicalCylinder_iff_realizes_fiberE` | `[C→A]` |
| 16c | `tailExponent_unique` ∧ Disjunktheit | `[C→A]` |
| 16d | `core6Cylinder = ⊔_{e≥1} C_e` und Komplement `C_1 ⊔ C_2 ⊔ C_3` | `[C→A]` |
| 16e | Expansion `e≤3` vs Kontraktion `e≥4` (kein konservierender Kanal) | `[C→A]` |
| 16f | endlich-kombinatorische Abzählung mod `2^{m+9}` (→ Dichteinterpretation) | `[C→A]` |
| danach | Zuführung `C_1,C_2,C_3` → kontraktive Familie | `[C]` |

Candidate Lean may appear on branch
`cursor/core6-cylinder-partition-4007` / PR #16. Symbols are **not** part of the
PR #15 `[A]` claim surface. Promote package-by-package to `[A]` only after CI
on this PR is green and the stack is accepted.

## Proof order (target)

```
Realisierungsäquivalenz
  ⟹ Partition
  ⟹ Disjunktheit
  ⟹ Komplement
  ⟹ Expansion/Kontraktion-Dichotomie
  ⟹ endliche Zählung (dann erst Dichteablesung)
```

## Linguistic sharpenings

1. **Not mere existence for `e≥1`:** the target is
   `RealizesWord (fiberE e) (canonicalBase e)` — canonical, unique dyadic class;
   `canonicalBase` remains `noncomputable`.
2. **Hard dichotomy:** `e∈{1,2,3}` ⇒ image `> n`; `e≥4` ⇒ image `< n`.
   No conserving channel; `e=4` is already strictly contracting.
3. **No “analytic” density foundation:** first finite residue counts mod `2^{m+9}`;
   density is a limit reading. The deep open step after 16f is dynamical feed-in.

## After 16a–16e accepted as `[A]`

Then the accurate status line would be:

`[A]` structure complete · `[C→A]` only finite counting (16f) · `[C]` global feed-in.

Until CI/merge: that sentence is **aspirational**, not repo status.
