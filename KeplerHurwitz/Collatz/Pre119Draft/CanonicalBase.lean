import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.IntervalCases
import KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
import KeplerHurwitz.Collatz.Pre119Draft.ApMemberFromTransfer
import KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — CanonicalBase (PR #15, Schicht 3)

`∃!` dyadic seed for

`2187 · b + 2347 ≡ 2^{e+8} (mod 2^{e+9})`,

with representative `b < 2^{e+9}`.

Realization remains `[C]`. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase

open Nat
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.ApMemberFromTransfer

/-- Affine coefficient `3^7`. -/
def coeff3 : Nat := 2187

theorem coeff3_eq_three_pow : coeff3 = 3 ^ 7 := by native_decide

/-- Modulus `2^{e+9}`. -/
def seedModulus (e : Nat) : Nat := 2 ^ (e + 9)

theorem seedModulus_pos (e : Nat) : 0 < seedModulus e :=
  Nat.pow_pos (by decide : 0 < 2)

instance seedModulus.instNeZero (e : Nat) : NeZero (seedModulus e) :=
  ⟨Nat.pos_iff_ne_zero.mp (seedModulus_pos e)⟩

theorem coeff3_coprime_seedModulus (e : Nat) :
    Nat.Coprime coeff3 (seedModulus e) := by
  -- 2187 = 3^7 is odd, hence coprime to every `2^k`.
  have h : Nat.Coprime coeff3 2 := by native_decide
  exact (Nat.coprime_pow_right_iff (by omega : 0 < e + 9) coeff3 2).2 h

theorem isUnit_coeff3 (e : Nat) :
    IsUnit ((coeff3 : ZMod (seedModulus e))) :=
  (ZMod.isUnit_iff_coprime coeff3 (seedModulus e)).2
    (coeff3_coprime_seedModulus e)

/-- Unique-residue predicate. -/
def IsCanonicalSeed (e b : Nat) : Prop :=
  b < seedModulus e ∧
    (coeff3 * b + 2347) ≡ 2 ^ (e + 8) [MOD seedModulus e]

instance decidesIsCanonicalSeed (e b : Nat) : Decidable (IsCanonicalSeed e b) := by
  dsimp [IsCanonicalSeed]
  infer_instance

set_option maxHeartbeats 400000 in
-- ZMod residual algebra for the unique seed expands beyond the default limit.
/--
`[A]` Existence and uniqueness of the Core6 single-step canonical seed.
-/
theorem exists_unique_canonicalBase (e : Nat) :
    ∃! b : Nat, IsCanonicalSeed e b := by
  classical
  let M := seedModulus e
  haveI : NeZero M := seedModulus.instNeZero e
  have hunit : IsUnit ((coeff3 : ZMod M)) := isUnit_coeff3 e
  set u := hunit.unit
  have hu : (u : ZMod M) = (coeff3 : ZMod M) := (IsUnit.unit_spec hunit).symm
  -- Important: cast the *Nat* power, do not power inside `ZMod`.
  let powTerm : ZMod M := ↑(2 ^ (e + 8) : Nat)
  let target : ZMod M := powTerm - ↑(2347 : Nat)
  let bZ : ZMod M := (↑u⁻¹) * target
  have hinvL : (↑u⁻¹ : ZMod M) * ↑u = 1 := by simp
  have hinvR : (↑u : ZMod M) * ↑u⁻¹ = 1 := by simp
  refine ExistsUnique.intro bZ.val ⟨ZMod.val_lt bZ, ?hex⟩ ?huniq
  · -- existence: translate ZMod equality → ModEq
    refine (ZMod.natCast_eq_natCast_iff _ _ M).1 ?_
    have hb : (bZ.val : ZMod M) = bZ := ZMod.natCast_zmod_val bZ
    have h1 :
        (↑(coeff3 * bZ.val + 2347) : ZMod M) =
          (coeff3 : ZMod M) * (bZ.val : ZMod M) + ↑(2347 : Nat) := by
      simp only [Nat.cast_add, Nat.cast_mul]
    have h2 :
        (coeff3 : ZMod M) * (bZ.val : ZMod M) + ↑(2347 : Nat) =
          (coeff3 : ZMod M) * bZ + ↑(2347 : Nat) := by rw [hb]
    have h3 :
        (coeff3 : ZMod M) * bZ + ↑(2347 : Nat) =
          (↑u) * ((↑u⁻¹) * target) + ↑(2347 : Nat) := by
      rw [← hu]
    have h4 :
        (↑u) * ((↑u⁻¹) * target) + ↑(2347 : Nat) =
          target + ↑(2347 : Nat) := by
      rw [← mul_assoc, hinvR, one_mul]
    have h5 : target + ↑(2347 : Nat) = powTerm := by
      simp [target]
    exact h1.trans (h2.trans (h3.trans (h4.trans h5)))
  · -- uniqueness via coprime cancellation in ModEq
    intro b hb
    obtain ⟨hlt, hmod⟩ := hb
    have hbase : (coeff3 * bZ.val + 2347) ≡ 2 ^ (e + 8) [MOD M] := by
      have : IsCanonicalSeed e bZ.val := by
        refine ⟨ZMod.val_lt bZ, ?_⟩
        refine (ZMod.natCast_eq_natCast_iff _ _ M).1 ?_
        have hb' : (bZ.val : ZMod M) = bZ := ZMod.natCast_zmod_val bZ
        have h1 :
            (↑(coeff3 * bZ.val + 2347) : ZMod M) =
              (coeff3 : ZMod M) * (bZ.val : ZMod M) + ↑(2347 : Nat) := by
          simp only [Nat.cast_add, Nat.cast_mul]
        have h2 :
            (coeff3 : ZMod M) * (bZ.val : ZMod M) + ↑(2347 : Nat) =
              (coeff3 : ZMod M) * bZ + ↑(2347 : Nat) := by rw [hb']
        have h3 :
            (coeff3 : ZMod M) * bZ + ↑(2347 : Nat) =
              (↑u) * ((↑u⁻¹) * target) + ↑(2347 : Nat) := by
          rw [← hu]
        have h4 :
            (↑u) * ((↑u⁻¹) * target) + ↑(2347 : Nat) =
              target + ↑(2347 : Nat) := by
          rw [← mul_assoc, hinvR, one_mul]
        have h5 : target + ↑(2347 : Nat) = powTerm := by simp [target]
        exact h1.trans (h2.trans (h3.trans (h4.trans h5)))
      exact this.2
    have hmul' : coeff3 * b ≡ coeff3 * bZ.val [MOD M] := by
      have hsum : (coeff3 * b + 2347) ≡ (coeff3 * bZ.val + 2347) [MOD M] :=
        hmod.trans hbase.symm
      exact Nat.ModEq.add_right_cancel' 2347 hsum
    have hcop : Nat.gcd M coeff3 = 1 := by
      simpa [Nat.coprime_iff_gcd_eq_one, Nat.gcd_comm] using
        coeff3_coprime_seedModulus e
    have hcancel : b ≡ bZ.val [MOD M] :=
      Nat.ModEq.cancel_left_of_coprime hcop hmul'
    have hbmod : b % M = bZ.val :=
      mod_eq_of_modEq hcancel (ZMod.val_lt bZ)
    have : b = bZ.val := by
      rwa [Nat.mod_eq_of_lt hlt] at hbmod
    exact this

/-- Canonical seed via unique choice. -/
noncomputable def canonicalBase (e : Nat) : Nat :=
  Classical.choose (ExistsUnique.exists (exists_unique_canonicalBase e))

theorem canonicalBase_isCanonicalSeed (e : Nat) :
    IsCanonicalSeed e (canonicalBase e) :=
  Classical.choose_spec (ExistsUnique.exists (exists_unique_canonicalBase e))

theorem canonicalBase_lt (e : Nat) :
    canonicalBase e < seedModulus e :=
  (canonicalBase_isCanonicalSeed e).1

theorem canonicalBase_modEq (e : Nat) :
    (coeff3 * canonicalBase e + 2347) ≡ 2 ^ (e + 8) [MOD seedModulus e] :=
  (canonicalBase_isCanonicalSeed e).2

theorem canonicalBase_unique {e b : Nat} (hb : IsCanonicalSeed e b) :
    b = canonicalBase e :=
  (exists_unique_canonicalBase e).unique hb (canonicalBase_isCanonicalSeed e)

/-! ### Census regression `e = 4..11` -/

private theorem classBase_isCanonicalSeed_of_le_eleven {e : Nat}
    (h4 : 4 ≤ e) (h11 : e ≤ 11) :
    IsCanonicalSeed e (classBase e) := by
  interval_cases e <;> native_decide

/--
`[A]` On `4 ≤ e ≤ 11`, census `classBase` equals the unique canonical residue.
-/
theorem canonicalBase_eq_classBase {e : Nat}
    (h4 : 4 ≤ e) (h11 : e ≤ 11) :
    canonicalBase e = classBase e :=
  (canonicalBase_unique (classBase_isCanonicalSeed_of_le_eleven h4 h11)).symm

/-- `[C]` Realization goal (needs reverse AffineOddQuotient). -/
def CanonicalBaseRealizesGoal : Prop :=
  ∀ e : Nat, 4 ≤ e →
    RealizesWord (fiberE e) (canonicalBase e)

/-- `[C]` Universal lifting goal after realization. -/
def CanonicalInfiniteLiftingViaCanonicalBaseGoal : Prop :=
  ∀ e : Nat, 8 ≤ e →
    ∀ k : Nat, ApMemberOkFrom e (canonicalBase e) k

end KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
