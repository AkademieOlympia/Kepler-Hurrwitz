/-
  Prime tower dictionary: Gaussian / two-squares, Lagrange four-squares,
  Eisenstein mod-3 hints, Hurwitz-norm definition, octonion & Riemann markers.

  Claim wall:
    * [A] two-squares for mod-12 channel E∪A; Lagrange via Mathlib
    * [A] channel ↔ mod-4 / mod-3 tables
    * [B]/[C] Hurwitz-prime dictionary; Φ open
    * [C] octonion / Riemann sphere markers only
-/

import Mathlib
import Mathlib.NumberTheory.SumTwoSquares
import Mathlib.NumberTheory.SumFourSquares
import KeplerHurwitz.EABC.Basic
import KeplerHurwitz.EABC.NormalForm
import KeplerHurwitz.EABC.QuaternionBridge

open Quaternion

namespace KeplerHurwitz.EABC

/-! ## Mod-12 channels vs. mod-4 (Gaussian gate) -/

theorem channelE_mod4_eq_one {p : ℕ} (hp : IsChannelEPrime p) : p % 4 = 1 := by
  have h12 : p % 12 = 1 := hp.2.2
  have : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
  simpa [h12] using this.symm

theorem channelA_mod4_eq_one {p : ℕ} (hA : p % 12 = 5) : p % 4 = 1 := by
  have : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
  simpa [hA] using this.symm

theorem channelB_mod4_eq_three {p : ℕ} (hB : p % 12 = 7) : p % 4 = 3 := by
  have : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
  simpa [hB] using this.symm

theorem channelC_mod4_eq_three {p : ℕ} (hC : p % 12 = 11) : p % 4 = 3 := by
  have : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
  simpa [hC] using this.symm

theorem odd_of_mod12_five {p : ℕ} (hA : p % 12 = 5) : Odd p := by
  have h2 : (p % 12) % 2 = p % 2 := Nat.mod_mod_of_dvd p (by decide : 2 ∣ 12)
  have : p % 2 = 1 := by simpa [hA] using h2.symm
  exact Nat.odd_iff.mpr this

/-- Channel-E primes are sums of two squares. -/
theorem channelE_sum_of_two_squares {p : ℕ} [Fact p.Prime]
    (hpE : IsChannelEPrime p) : IsSumOfTwoSquares p := by
  have hp2 : p ≠ 2 := by
    intro h; subst h; exact absurd hpE.2.1 (by decide)
  have h4 : p % 4 = 1 := channelE_mod4_eq_one hpE
  have hodd : Odd p := Nat.Prime.odd_of_ne_two Fact.out hp2
  have hEA : isE p ∨ isA p := (isE_or_isA_iff_mod4_eq_one hodd).2 h4
  exact (odd_prime_sum_of_two_squares_iff_EA hp2).2 hEA

/-- Channel-A primes (`≡ 5 mod 12`) are sums of two squares. -/
theorem channelA_sum_of_two_squares {p : ℕ} [Fact p.Prime]
    (hA : p % 12 = 5) : IsSumOfTwoSquares p := by
  have hp2 : p ≠ 2 := by
    intro h; subst h; simp at hA
  have h4 : p % 4 = 1 := channelA_mod4_eq_one hA
  have hodd : Odd p := odd_of_mod12_five hA
  have hEA : isE p ∨ isA p := (isE_or_isA_iff_mod4_eq_one hodd).2 h4
  exact (odd_prime_sum_of_two_squares_iff_EA hp2).2 hEA

/-- Mod-12 channels E and A admit two-square decompositions. -/
theorem channelEA_sum_of_two_squares {p : ℕ} [Fact p.Prime]
    (h : IsChannelEPrime p ∨ p % 12 = 5) :
    IsSumOfTwoSquares p := by
  rcases h with hE | h5
  · exact channelE_sum_of_two_squares hE
  · exact channelA_sum_of_two_squares h5

/-! ## Lagrange four squares ↔ quaternion norm -/

theorem lagrange_four_squares (n : ℕ) :
    ∃ a b c d : ℕ, a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = n :=
  Nat.sum_four_squares n

theorem exists_lipschitz_norm (n : ℕ) :
    ∃ a b c e : ℕ, normSq (ofNatComponents a b c e) = (n : ℤ) := by
  obtain ⟨a, b, c, e, h⟩ := Nat.sum_four_squares n
  refine ⟨a, b, c, e, ?_⟩
  rw [normSq_ofNatComponents]
  exact_mod_cast h

/-! ## Eisenstein mod-3 gate (dictionary) -/

theorem mod6_one_mod3_one {p : ℕ} (h : p % 6 = 1) : p % 3 = 1 := by
  have : (p % 6) % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide : 3 ∣ 6)
  simpa [h] using this.symm

theorem mod6_five_mod3_two {p : ℕ} (h : p % 6 = 5) : p % 3 = 2 := by
  have : (p % 6) % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide : 3 ∣ 6)
  simpa [h] using this.symm

/-! ## Unique double-split: channel E = Gaussian ∩ Eisenstein among EABC units -/

/-- Gaussian-split residue among odd primes: `≡ 1 (mod 4)`. -/
def IsGaussianSplitResidue (p : ℕ) : Prop := p % 4 = 1

/-- Eisenstein-split residue: `≡ 1 (mod 3)`. -/
def IsEisensteinSplitResidue (p : ℕ) : Prop := p % 3 = 1

/-- EABC unit residue classes mod 12. -/
def IsEABCUnitResidue (p : ℕ) : Prop :=
  p % 12 = 1 ∨ p % 12 = 5 ∨ p % 12 = 7 ∨ p % 12 = 11

/-- Among EABC unit classes, Gaussian∩Eisenstein split isolates channel E (`≡ 1 mod 12`).
Gaussian: E,A (≡1 mod 4). Eisenstein: E,B (≡1 mod 6). Intersection: E. -/
theorem channelE_iff_double_split {p : ℕ} (h : IsEABCUnitResidue p) :
    p % 12 = 1 ↔ IsGaussianSplitResidue p ∧ IsEisensteinSplitResidue p := by
  constructor
  · intro h1
    refine ⟨?_, ?_⟩
    · have : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
      simpa [IsGaussianSplitResidue, h1] using this.symm
    · have : (p % 12) % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide : 3 ∣ 12)
      simpa [IsEisensteinSplitResidue, h1] using this.symm
  · intro ⟨hg, he⟩
    rcases h with h1 | h5 | h7 | h11
    · exact h1
    · -- 5 mod 12 ⇒ mod 3 = 2, contradicts Eisenstein split
      have : p % 3 = 2 := by
        have h' : (p % 12) % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide : 3 ∣ 12)
        simpa [h5] using h'.symm
      simp [IsEisensteinSplitResidue] at he
      omega
    · -- 7 mod 12 ⇒ mod 4 = 3, contradicts Gaussian split
      have : p % 4 = 3 := by
        have h' : (p % 12) % 4 = p % 4 := Nat.mod_mod_of_dvd p (by decide : 4 ∣ 12)
        simpa [h7] using h'.symm
      simp [IsGaussianSplitResidue] at hg
      omega
    · -- 11 mod 12 ⇒ fails both
      have h3 : p % 3 = 2 := by
        have h' : (p % 12) % 3 = p % 3 := Nat.mod_mod_of_dvd p (by decide : 3 ∣ 12)
        simpa [h11] using h'.symm
      simp [IsEisensteinSplitResidue] at he
      omega

theorem channelE_of_double_split {p : ℕ} (h : IsEABCUnitResidue p)
    (hg : IsGaussianSplitResidue p) (he : IsEisensteinSplitResidue p) :
    p % 12 = 1 :=
  (channelE_iff_double_split h).2 ⟨hg, he⟩

/-! ## Hurwitz-prime dictionary -/

/-- Norm equals a rational prime (Lipschitz stand-in for Hurwitz-prime). -/
def IsLipschitzHurwitzPrimeCandidate (γ : Lipschitz) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ normSq γ = (p : ℤ)

/-- `axisPure` has norm `p^2`, so it is not a Hurwitz-prime candidate when `1 < p`. -/
theorem axisPure_not_hurwitz_prime_candidate {ch : V4} {p : ℕ}
    (hp1 : 1 < p) :
    ¬ IsLipschitzHurwitzPrimeCandidate (axisPure ch (p : ℤ)) := by
  intro ⟨q, hq, hN⟩
  have hnorm : normSq (axisPure ch (p : ℤ)) = (p : ℤ) ^ 2 :=
    normSq_axisPure_nat ch p
  have hqZ : (q : ℤ) = (p : ℤ) ^ 2 := by rw [← hN, hnorm]
  have hqeq : q = p * p := by
    have : (q : ℤ) = ((p * p : ℕ) : ℤ) := by simpa [pow_two] using hqZ
    exact Nat.cast_injective this
  have hpne : p ≠ 1 := Nat.ne_of_gt hp1
  have hnot : ¬ Nat.Prime (p * p) := Nat.not_prime_mul hpne hpne
  exact hnot (hqeq ▸ hq)

/-! ## Overmodel markers -/

def octonionOvermodelMarker : True := trivial
def riemannSphereMarker : True := trivial
def hurwitzPhiOpen : True := trivial

end KeplerHurwitz.EABC
