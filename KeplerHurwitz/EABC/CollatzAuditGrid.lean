/-
  Collatz / Syracuse audit grid on the EABC / V₄ layer.

  Claim wall:
    [A] 2-adic divisibility of 3κ+1 by mod-12 channel; mod-24 target residues for B/C
    [B] audit-grid reading (docs/eabc_collatz_audit_grid.md)
    [C] no Collatz proof; additive barrier (+1) breaks multiplicative reconstruction

  Docs: docs/eabc_collatz_audit_grid.md · Register E-097
-/

import KeplerHurwitz.EABC.Basic
import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm

namespace KeplerHurwitz.EABC

/-! ## 2-adic divisibility of `3κ+1` by mod-12 channel -/

/-- Channel E (κ ≡ 1 mod 12): at least \(2^2\) divides \(3κ+1\). -/
theorem four_dvd_three_mul_add_one_of_mod12_one {κ : ℕ} (h : κ % 12 = 1) :
    4 ∣ 3 * κ + 1 := by omega

/-- Channel A (κ ≡ 5 mod 12): at least \(2^2\) divides \(3κ+1\). -/
theorem four_dvd_three_mul_add_one_of_mod12_five {κ : ℕ} (h : κ % 12 = 5) :
    4 ∣ 3 * κ + 1 := by omega

/-- Channel B (κ ≡ 7 mod 12): exactly one factor of 2. -/
theorem exactly_one_two_of_mod12_seven {κ : ℕ} (h : κ % 12 = 7) :
    2 ∣ 3 * κ + 1 ∧ ¬ 4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/-- Channel C (κ ≡ 11 mod 12): exactly one factor of 2. -/
theorem exactly_one_two_of_mod12_eleven {κ : ℕ} (h : κ % 12 = 11) :
    2 ∣ 3 * κ + 1 ∧ ¬ 4 ∣ 3 * κ + 1 := by
  constructor <;> omega

/-! ## Mod-24 target residues after dividing out the single factor 2 (B/C) -/

/-- κ ≡ 7 (mod 24) ⇒ (3κ+1)/2 ≡ 11 (mod 12) → channel C. -/
theorem syracuse_half_mod12_of_mod24_seven {κ : ℕ} (h : κ % 24 = 7) :
    ((3 * κ + 1) / 2) % 12 = 11 := by omega

/-- κ ≡ 19 (mod 24) ⇒ (3κ+1)/2 ≡ 5 (mod 12) → channel A. -/
theorem syracuse_half_mod12_of_mod24_nineteen {κ : ℕ} (h : κ % 24 = 19) :
    ((3 * κ + 1) / 2) % 12 = 5 := by omega

/-- κ ≡ 11 (mod 24) ⇒ (3κ+1)/2 ≡ 5 (mod 12) → channel A. -/
theorem syracuse_half_mod12_of_mod24_eleven {κ : ℕ} (h : κ % 24 = 11) :
    ((3 * κ + 1) / 2) % 12 = 5 := by omega

/-- κ ≡ 23 (mod 24) ⇒ (3κ+1)/2 ≡ 11 (mod 12) → channel C (not always A!). -/
theorem syracuse_half_mod12_of_mod24_twentythree {κ : ℕ} (h : κ % 24 = 23) :
    ((3 * κ + 1) / 2) % 12 = 11 := by omega

/-- Concrete witnesses (match the audit-grid examples). -/
theorem syracuse_witness_7_to_11 : (3 * 7 + 1) / 2 = 11 := by decide
theorem syracuse_witness_19_to_29 : (3 * 19 + 1) / 2 = 29 := by decide
theorem syracuse_witness_11_to_17 : (3 * 11 + 1) / 2 = 17 := by decide
theorem syracuse_witness_23_to_35 : (3 * 23 + 1) / 2 = 35 := by decide

theorem toV4_after_syracuse_7 :
    toV4 ((3 * 7 + 1) / 2) (by decide) = V4.C := by
  simp [syracuse_witness_7_to_11, toV4]

theorem toV4_after_syracuse_19 :
    toV4 ((3 * 19 + 1) / 2) (by decide) = V4.A := by
  simp [syracuse_witness_19_to_29, toV4]

theorem toV4_after_syracuse_11 :
    toV4 ((3 * 11 + 1) / 2) (by decide) = V4.A := by
  simp [syracuse_witness_11_to_17, toV4]

/-! ## Mod-8 Collatz layer ≠ mod-12 \(V_4\) (no silent identification) -/

/--
Witness: odd 7 is class **C** mod 8 (`EABCClass`), but \(V_4\)-class **B** mod 12.
Net-Descent / mod-8 Collatz channels must not be identified with the audit-grid \(V_4\).
-/
theorem mod8_class_not_equal_v4_class_witness_seven :
    classify 7 (by decide) = EABCClass.C ∧ toV4 7 (by decide) = V4.B := by
  constructor
  · decide
  · rfl

/-! ## Claim-boundary markers -/

/-- Audit-grid only: multiplicative EABC data do not reconstruct after +1. -/
theorem additive_barrier_no_multiplicative_reconstruction : True := trivial

/-- Explicit non-claim: this module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_eabc_audit_grid : True := trivial

end KeplerHurwitz.EABC
