import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.Collatz.AffineCylinderBlockDescent

/-!
# Exact valuation cylinders — residue certificates `[B]→[A]`

**Collatz?** **NEIN.** Finite residue certificates for concrete valuation words.

Architecture: affine margin core `[A]` (imported) → finite certificates here `[B]`.
Does **not** claim a global cover of all odd `n > 1`.
-/

namespace KeplerHurwitz.Collatz.ExactValuationCylinder

open KeplerHurwitz
open KeplerHurwitz.Collatz.AffineCylinderBlockDescent
open KeplerHurwitz.Collatz.CollatzChirurgeryBridge

/--
Finite residue certificate for a valuation word `a`.

Intended modulus is `2^{A_k+1}` (one bit past the cumulative valuation),
matching classical exact-`ν₂` cylinder lifting for length-`k` words.
-/
structure CylinderResidueCertificate {k : Nat} (a : Fin k → Nat) where
  /-- Residue representative `0 ≤ residue < modulus`. -/
  residue : Nat
  /-- Cylinder modulus; typically `2^{A_k+1}`. -/
  modulus : Nat
  modulus_pos : 0 < modulus
  residue_lt : residue < modulus
  /-- Realizing the word is equivalent to lying in the residue class. -/
  realizes_iff :
    ∀ n : Nat, RealizesValuationWord n a ↔ n % modulus = residue

/-- Canonical modulus `2^{A_k+1}` for word `a`. -/
def cylinderModulus {k : Nat} (a : Fin k → Nat) : Nat :=
  2 ^ (cumulativeValuation a k + 1)

theorem cylinderModulus_word_2_2 : cylinderModulus word_2_2 = 32 := by
  simp [cylinderModulus, cumulativeValuation_word_2_2]

theorem cylinderModulus_word_1_2 : cylinderModulus word_1_2 = 16 := by
  simp [cylinderModulus, cumulativeValuation_word_1_2]

/-! #########################################################################
## Word `(2,2)` — full residue certificate
######################################################################### -/

lemma word_2_2_of_mod32 {n : Nat} (h : n % 32 = 1) :
    RealizesValuationWord n word_2_2 := by
  have hn_odd : n % 2 = 1 := by omega
  have hn : n = 32 * (n / 32) + 1 := by
    have := Nat.div_add_mod n 32
    omega
  set t := n / 32
  have hν0 : padicValNat 2 (3 * n + 1) = 2 := by
    have hmod8 : n % 8 = 1 := by omega
    exact nu2_three_mul_add_one_eq_two_of_mod8_eq1 hmod8
  have hT : oddCoreSyracuse n = 24 * t + 1 := by
    have hmul := oddCoreSyracuse_mul_twoPow n
    rw [hν0] at hmul
    have h3n : 3 * n + 1 = 96 * t + 4 := by omega
    omega
  have hν1 : padicValNat 2 (3 * oddCoreSyracuse n + 1) = 2 := by
    have hmod8 : (24 * t + 1) % 8 = 1 := by omega
    rw [hT]
    exact nu2_three_mul_add_one_eq_two_of_mod8_eq1 hmod8
  refine ⟨hn_odd, ?_⟩
  intro j
  fin_cases j
  · simpa [word_2_2, oddCoreSyracuseIter] using hν0
  · simpa [word_2_2, oddCoreSyracuseIter, hT] using hν1

lemma mod32_of_word_2_2 {n : Nat} (h : RealizesValuationWord n word_2_2) :
    n % 32 = 1 := by
  have hn_odd : n % 2 = 1 := h.1
  have hν0 : padicValNat 2 (3 * n + 1) = 2 := by
    simpa [word_2_2, oddCoreSyracuseIter] using h.2 ⟨0, by decide⟩
  have hν1 : padicValNat 2 (3 * oddCoreSyracuse n + 1) = 2 := by
    simpa [word_2_2, oddCoreSyracuseIter] using h.2 ⟨1, by decide⟩
  have hn0 : 3 * n + 1 ≠ 0 := by omega
  have h4 : 4 ∣ 3 * n + 1 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 3 * n + 1) hn0).2 (by omega)
  have h8not : ¬8 ∣ 3 * n + 1 := by
    intro h8
    have : 3 ≤ padicValNat 2 (3 * n + 1) :=
      (padicValNat_dvd_iff_le (p := 2) (a := 3 * n + 1) hn0).1 (by simpa using h8)
    omega
  have hn_mod8 : n % 8 = 1 := by omega
  obtain ⟨t, ht⟩ : ∃ t, n = 8 * t + 1 := ⟨n / 8, by omega⟩
  have hT : oddCoreSyracuse n = 6 * t + 1 := by
    have hmul := oddCoreSyracuse_mul_twoPow n
    rw [hν0] at hmul
    have h3n : 3 * n + 1 = 24 * t + 4 := by omega
    omega
  have hT0 : 3 * oddCoreSyracuse n + 1 ≠ 0 := by omega
  have h4T : 4 ∣ 3 * oddCoreSyracuse n + 1 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 3 * oddCoreSyracuse n + 1) hT0).2
      (by omega)
  have h8Tnot : ¬8 ∣ 3 * oddCoreSyracuse n + 1 := by
    intro h8
    have : 3 ≤ padicValNat 2 (3 * oddCoreSyracuse n + 1) :=
      (padicValNat_dvd_iff_le (p := 2) (a := 3 * oddCoreSyracuse n + 1) hT0).1
        (by simpa using h8)
    omega
  have h3T : 3 * oddCoreSyracuse n + 1 = 18 * t + 4 := by omega
  have ht_even : t % 2 = 0 := by
    by_contra _
    have ht1 : t % 2 = 1 := by omega
    have : ¬4 ∣ 18 * t + 4 := by omega
    exact this (by simpa [h3T] using h4T)
  obtain ⟨s, hs⟩ : ∃ s, t = 2 * s := ⟨t / 2, by omega⟩
  have hs_even : s % 2 = 0 := by
    by_contra _
    have hs1 : s % 2 = 1 := by omega
    have : 8 ∣ 18 * t + 4 := by omega
    exact h8Tnot (by simpa [h3T] using this)
  obtain ⟨u, hu⟩ : ∃ u, s = 2 * u := ⟨s / 2, by omega⟩
  have hn32 : n = 32 * u + 1 := by omega
  omega

/-- `[B]` Full residue certificate for word `(2,2)`: realizes ↔ `n ≡ 1 (mod 32)`. -/
def cert_word_2_2 : CylinderResidueCertificate word_2_2 where
  residue := 1
  modulus := 32
  modulus_pos := by decide
  residue_lt := by decide
  realizes_iff := fun n =>
    ⟨mod32_of_word_2_2, word_2_2_of_mod32⟩

theorem realizesWord_iff_modEq_residue_word_2_2 (n : Nat) :
    RealizesValuationWord n word_2_2 ↔ n % 32 = 1 :=
  cert_word_2_2.realizes_iff n

/-! #########################################################################
## Word `(1,3)` — strong-leaf residue family
######################################################################### -/

/-- Word `(1,3)`. -/
def word_1_3 : Fin 2 → Nat
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 3

theorem cumulativeValuation_word_1_3 :
    cumulativeValuation word_1_3 2 = 4 := by
  decide

theorem blockConstant_word_1_3 : blockConstant word_1_3 = 5 := by
  decide

theorem margin_word_1_3_pos : 3 ^ 2 < 2 ^ cumulativeValuation word_1_3 2 := by
  rw [cumulativeValuation_word_1_3]
  decide

theorem cylinderModulus_word_1_3 : cylinderModulus word_1_3 = 32 := by
  simp [cylinderModulus, cumulativeValuation_word_1_3]

lemma word_1_3_of_mod32 {n : Nat} (h : n % 32 = 19) :
    RealizesValuationWord n word_1_3 := by
  have hn_odd : n % 2 = 1 := by omega
  have hn : n = 32 * (n / 32) + 19 := by
    have := Nat.div_add_mod n 32
    omega
  set t := n / 32
  have hν0 : padicValNat 2 (3 * n + 1) = 1 := by
    have hmod8 : n % 8 = 3 := by omega
    exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 hmod8
  have hT : oddCoreSyracuse n = 48 * t + 29 := by
    have hmul := oddCoreSyracuse_mul_twoPow n
    rw [hν0] at hmul
    have h3n : 3 * n + 1 = 96 * t + 58 := by omega
    omega
  have hν1 : padicValNat 2 (3 * oddCoreSyracuse n + 1) = 3 := by
    rw [hT]
    have hmod8 : (48 * t + 29) % 8 = 5 := by omega
    have hfactor : 3 * (48 * t + 29) + 1 = 8 * (18 * t + 11) := by omega
    have hodd : Odd (18 * t + 11) := Nat.odd_iff.mpr (by omega)
    exact nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd hmod8 hfactor hodd
  refine ⟨hn_odd, ?_⟩
  intro j
  fin_cases j
  · simpa [word_1_3, oddCoreSyracuseIter] using hν0
  · simpa [word_1_3, oddCoreSyracuseIter, hT] using hν1

/--
Reverse uniqueness for `(1,3)`.

SORRY(residue-uniqueness): reverse direction for word `(1,3)`.
Forward `n ≡ 19 (mod 32) → realizes` is proved above.
-/
lemma mod32_of_word_1_3 {n : Nat} (h : RealizesValuationWord n word_1_3) :
    n % 32 = 19 := by
  sorry

/-- `[B]` Residue certificate for `(1,3)` (reverse uniqueness labeled sorry). -/
def cert_word_1_3 : CylinderResidueCertificate word_1_3 where
  residue := 19
  modulus := 32
  modulus_pos := by decide
  residue_lt := by decide
  realizes_iff := fun n =>
    ⟨mod32_of_word_1_3, word_1_3_of_mod32⟩

/-- One-sided residue implication (sorry-free). -/
theorem realizes_word_1_3_of_modEq (n : Nat) (h : n % 32 = 19) :
    RealizesValuationWord n word_1_3 :=
  word_1_3_of_mod32 h

/-! #########################################################################
## Word `(1,2)` — growth cylinder (not strong)
######################################################################### -/

theorem example_residue_word_1_2 : 11 % cylinderModulus word_1_2 = 11 := by
  decide

theorem realizes_word_1_2_eleven : RealizesValuationWord 11 word_1_2 :=
  (example_word_1_2_growth).1

end KeplerHurwitz.Collatz.ExactValuationCylinder
