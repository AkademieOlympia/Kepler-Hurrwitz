---
title: Affine cylinder block-descent — arithmetic core
date: 2026-07-21
status: >-
  Affine margin arithmetic proved in Lean `[A]`. Adaptive certificate tree /
  Collatz cover open `[C]`. Strong cylinder residue stub `[B]/[C]`.
governance: >-
  Collatz? NEIN. No claim that every odd n>1 admits a positive-margin word.
  Packaging into OddNetDescent is conditional on the open cover hypothesis.
lean_module: KeplerHurwitz/Collatz/AffineCylinderBlockDescent.lean
branch: pr/11-collatz-v27-net-descent
not_claimed:
  - Collatz bewiesen
  - AdaptiveCylinderCertificateTreeWellFounded
  - AffineCylinderPositiveMarginCover (existence for all odd n>1)
  - StrongCylinderUniformDescent residue structure
---

# Affine cylinder block-descent (2026-07-21)

**Collatz?** **NEIN**

Lean home (prefer worktree):
`KeplerHurwitz/Collatz/AffineCylinderBlockDescent.lean`

Naming aligns with
`CollatzChirurgeryBridge.oddCoreSyracuse` /
`oddCoreSyracuseIter` /
`OddNetDescentStatement` /
`odd_descent_implies_reaches_one`.

---

## Boxed statements

### Affine core `[A]`

For a valuation word `a : Fin k → ℕ` realized by odd `n`
(`ν₂(3 T^j(n)+1) = a_j`), with cumulative `A_j = ∑_{i<j} a_i` and

\[
B_k = \sum_{j<k} 3^{k-1-j}\,2^{A_j},
\qquad
\text{margin} = 2^{A_k}-3^k \in \mathbb{Z},
\]

the multiply-form identity holds:

\[
\boxed{2^{A_k}\cdot T^k(n) = 3^k\cdot n + B_k}
\]

(`accelerated_iterate_mul_twoPow`).

Under positive margin `3^k < 2^{A_k}`:

\[
\boxed{T^k(n) < n \;\Longleftrightarrow\; B_k < (2^{A_k}-3^k)\,n}
\]

(`block_descent_iff` / `block_descent_of_margin`).

Under negative margin `2^{A_k} < 3^k` and `k>0` (`B_k>0`):

\[
\boxed{T^k(n) > n}
\]

(`block_growth_of_neg_margin'`).

Zero-margin equality is impossible for `k>0`:

\[
\boxed{2^{A} \neq 3^{k}\quad(k>0)}
\]

(`two_pow_ne_three_pow` / `blockMargin_ne_zero`).

### Strong cylinder uniform descent `[B]/[C]`

Intended: a residue `r_a (mod 2^{A_k})` such that the whole odd cylinder
realizes `a` and descends under the margin test.
**Stub only** (`StrongCylinderUniformDescent`) — residue/Hensel structure
not formalized; affine arithmetic is the proved core.

### Adaptive certificate tree `[C]`

\[
\boxed{\text{WF adaptive cylinder certificate tree} \;\Rightarrow\; \text{Collatz}}
\]

Named hypothesis only:
`AdaptiveCylinderCertificateTreeWellFounded`
(`:= AffineCylinderPositiveMarginCover`).
**Not claimed proved.** No `axiom`.

### Fixed universal block length `L`

All-ones word of length `L≥2` has `A_L=L` and `2^L<3^L`, hence **grows**
on every realizing odd start (`allOnes_block_growth`).
There is **no** uniform fixed-`L≥2` descent cover via the minimal word;
any cover must be adaptive in the valuation word (and typically in `L`).
Related probe: `n_L = 2^{L+1}-1` (octonion `witnessStart` family).

---

## Status table

| Claim | Status | Lean name(s) |
|---|---|---|
| Affine multiply formula | **`[A]`** | `accelerated_iterate_mul_twoPow` |
| Exact margin descent iff | **`[A]`** | `block_descent_iff`, `block_descent_of_margin` |
| Negative-margin growth | **`[A]`** | `block_growth_of_neg_margin'` |
| `2^A ≠ 3^k` (`k>0`) | **`[A]`** | `two_pow_ne_three_pow` |
| Examples `(1,2)` growth / `(2,2)` descent | **`[A]`** | `example_word_1_2_growth`, `example_word_2_2_descent` |
| All-ones fixed-`L` growth | **`[A]`** | `allOnes_block_growth` |
| Strong cylinder residue cover | **`[B]/[C]`** stub | `StrongCylinderUniformDescent` |
| Adaptive tree WF ⇒ Collatz | **`[C]`** open | `AdaptiveCylinderCertificateTreeWellFounded` |
| Cover of all odd `n>1` | **`[C]`** open | `AffineCylinderPositiveMarginCover` |

---

## Bridge to OddNetDescent / ChirurgeryBridge

Conditional packaging only (`[A]` once the cover is assumed):

1. `AffineCylinderPositiveMarginCover`
   → `OddNetDescent_of_affine_cylinder_cover`
   → `OddNetDescentStatement`
2. `odd_descent_reaches_one_of_affine_cylinder_cover`
   = `odd_descent_implies_reaches_one` ∘ (1)
3. Further arrows in `CollatzChirurgeryBridge`
   (`oddCoreCollatz_of_OddNetDescent`, classical strip) remain
   **conditional** on that open cover — they do **not** close Collatz.

---

## Concrete checks

| Word | `A_k` | `B_k` | margin | Example |
|---|---|---|---|---|
| `(1,2)` | 3 | 5 | `8-9 = -1` | `n=11`: `T^2=13>11` (growth) |
| `(2,2)` | 4 | 7 | `16-9 = +7` | `n=33`: `T^2=19<33` (descent; needs `n>1`) |

Python mirror: `tests/test_affine_cylinder_block_descent.py`.
