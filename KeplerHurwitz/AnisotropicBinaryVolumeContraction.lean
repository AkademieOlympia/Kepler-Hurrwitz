/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team
-/

import Mathlib

namespace KeplerHurwitz

/-!
## Anisotropic binary volume contraction (E-099 / ORQ-099)

Elementary algebra for the directed scale family
\[
T_n = (2^{-1},\ldots,2^{-n}),\qquad
\prod_{k=1}^n 2^{-k} = 2^{-\tfrac{n(n+1)}{2}}.
\]

Governance:
* Product / triangle-exponent identities are **`[A]`** (this file).
* EABC / quaternion / \((L,H,W)\leftrightarrow(i,j,k)\) readings remain **`[C]`**
  hypotheses below — not theorems.

Documentation: `docs/theory/anisotropic_binary_volume_contraction.md`.
-/

/--
A-D (E-099): \(n\)-th triangle number \(S_n = n(n+1)/2\).
-/
def triangleNumber (n : Nat) : Nat :=
  n * (n + 1) / 2

/--
A-T (E-099): \(\sum_{k=1}^n k = S_n\).
-/
theorem sum_Icc_id_eq_triangleNumber (n : Nat) :
    ∑ k ∈ Finset.Icc 1 n, k = triangleNumber n := by
  have h0 : 0 ∉ Finset.Icc 1 n := by simp
  have hinsert : insert 0 (Finset.Icc 1 n) = Finset.range (n + 1) := by
    ext x
    simp only [Finset.mem_insert, Finset.mem_Icc, Finset.mem_range]
    constructor
    · rintro (rfl | ⟨h1, h2⟩)
      · exact Nat.succ_pos _
      · exact Nat.lt_succ_of_le h2
    · intro hx
      by_cases hx0 : x = 0
      · exact Or.inl hx0
      · exact Or.inr ⟨Nat.pos_of_ne_zero hx0, Nat.le_of_lt_succ hx⟩
  have hsum_range : ∑ k ∈ Finset.range (n + 1), k = ∑ k ∈ Finset.Icc 1 n, k := by
    rw [← hinsert, Finset.sum_insert h0, zero_add]
  rw [← hsum_range, Finset.sum_range_id, triangleNumber]
  simp [Nat.mul_comm]

/--
A-T (E-099): \(\prod_{k=1}^n 2^k = 2^{S_n}\) (Nat form).
-/
theorem prod_two_pow_eq_two_pow_triangle (n : Nat) :
    ∏ k ∈ Finset.Icc 1 n, (2 : Nat) ^ k = 2 ^ triangleNumber n := by
  rw [Finset.prod_pow_eq_pow_sum, sum_Icc_id_eq_triangleNumber]

/--
A-T (E-099): \(\prod_{k=1}^n 2^{-k} = 2^{-S_n}\) over \(\mathbb{Q}\).
-/
theorem prod_two_zpow_neg_eq_two_zpow_neg_triangle (n : Nat) :
    ∏ k ∈ Finset.Icc 1 n, (2 : ℚ) ^ (-(k : ℤ)) =
      (2 : ℚ) ^ (-(triangleNumber n : ℤ)) := by
  have hpow :
      ∏ k ∈ Finset.Icc 1 n, (2 : ℚ) ^ k = (2 : ℚ) ^ triangleNumber n := by
    simpa [Nat.cast_pow] using
      congrArg (fun t : Nat => (t : ℚ)) (prod_two_pow_eq_two_pow_triangle n)
  have hfactor (k : Nat) : (2 : ℚ) ^ (-(k : ℤ)) = ((2 : ℚ) ^ k)⁻¹ := by
    simp [zpow_neg]
  simp_rw [hfactor]
  rw [Finset.prod_inv_distrib, hpow, ← zpow_natCast, ← zpow_neg]

/--
A-D (E-099): Anisotropic binary scales as a list
\((2^{-1},\ldots,2^{-n})\) in \(\mathbb{Q}\).
-/
def anisotropicBinaryScales (n : Nat) : List ℚ :=
  (List.range n).map fun i => (2 : ℚ) ^ (-((i + 1 : Nat) : ℤ))

/--
A-D (E-099): Global volume factor \(2^{-S_n}\).
-/
def anisotropicVolumeFactor (n : Nat) : ℚ :=
  (2 : ℚ) ^ (-(triangleNumber n : ℤ))

/--
A-T (E-099): Volume factor equals the Finset product of directed scales.
-/
theorem anisotropicVolumeFactor_eq_prod (n : Nat) :
    anisotropicVolumeFactor n =
      ∏ k ∈ Finset.Icc 1 n, (2 : ℚ) ^ (-(k : ℤ)) :=
  (prod_two_zpow_neg_eq_two_zpow_neg_triangle n).symm

/-!
### Concrete \(n = 3\) witness (`[A]`)
-/

/-- A-T (E-099): \(S_3 = 6\). -/
theorem triangleNumber_three : triangleNumber 3 = 6 := by
  native_decide

/-- A-T (E-099): Scales \(\bigl(\tfrac12,\tfrac14,\tfrac18\bigr)\). -/
theorem anisotropicBinaryScales_three :
    anisotropicBinaryScales 3 = [(1 : ℚ) / 2, (1 : ℚ) / 4, (1 : ℚ) / 8] := by
  native_decide

/-- A-T (E-099): Volume \(\tfrac12\cdot\tfrac14\cdot\tfrac18 = \tfrac1{64} = 2^{-6}\). -/
theorem anisotropicVolumeFactor_three :
    anisotropicVolumeFactor 3 = (1 : ℚ) / 64 := by
  native_decide

theorem prod_scales_three_eq_inv_sixty_four :
    ((1 : ℚ) / 2) * ((1 : ℚ) / 4) * ((1 : ℚ) / 8) = (1 : ℚ) / 64 := by
  native_decide

/-- Didactic binary reduction \(\tfrac{5}{10}=\tfrac12\) (`[A]`, not an EABC-class claim). -/
theorem five_div_ten_eq_half : (5 : ℚ) / 10 = 1 / 2 := by
  native_decide

/-!
### EABC reading markers (`[C]` — not theorems)
-/

/--
[C] Hypothesis: the three directed scales may be *read* as contractions along
three independent axes analogous to \((i,j,k)\) — not an identification.
-/
def AnisotropicAxesQuaternionReadingHypothesis : Prop :=
  True

/--
[C] Hypothesis: \(2^{-S_n}\) can serve as a multiscale audit metric on EABC
sector data — pending `[B]` exports with null models.
-/
def AnisotropicVolumeAuditHypothesis : Prop :=
  True

/--
[C] Bundle marker for ORQ-099 / E-099 (complementary to isotropic retraction \(R^*\)).
-/
def AnisotropicBinaryVolumeContractionHypothesis : Prop :=
  True

end KeplerHurwitz
