import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

/-!
# Kanal-7 V2.15 — H7-A: mod-128 affine Permutation (`[A]`)
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215

open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

abbrev mod128 := ZMod 128

theorem coeff243_mul_59_mod128 : (243 : mod128) * 59 = 1 := by native_decide

theorem coeff59_mul_243_mod128 : (59 : mod128) * 243 = 1 := by native_decide

theorem coeff243_unit_mod128 : IsUnit (243 : mod128) :=
  isUnit_iff_exists_inv.mpr ⟨59, coeff243_mul_59_mod128⟩

theorem coeff243_inverse_mod128 : (243 : mod128)⁻¹ = 59 :=
  inv_eq_of_mul_eq_one_right coeff243_mul_59_mod128

def deepLiftConstantZMod (j : ℕ) : mod128 :=
  (deepLiftConstant j : mod128)

def deepLiftAffineZMod (j : ℕ) (t : mod128) : mod128 :=
  243 * t + deepLiftConstantZMod j

def deepLiftAffine_target_parameter (j : ℕ) (a : mod128) : mod128 :=
  59 * (a - deepLiftConstantZMod j)

abbrev controlledTargetParameter := deepLiftAffine_target_parameter

theorem deepLiftAffine_target_spec (j : ℕ) (a : mod128) :
    deepLiftAffineZMod j (deepLiftAffine_target_parameter j a) = a := by
  simp [deepLiftAffineZMod, deepLiftAffine_target_parameter, deepLiftConstantZMod,
    coeff243_mul_59_mod128, mul_assoc]

theorem deepLiftAffine_target_unique (j : ℕ) (a t : mod128)
    (ht : deepLiftAffineZMod j t = a) :
    t = deepLiftAffine_target_parameter j a := by
  have h59 := congrArg (fun x => (59 : mod128) * x) ht
  rw [deepLiftAffineZMod, mul_add, ← mul_assoc, coeff59_mul_243_mod128, one_mul] at h59
  calc t
      = 59 * a - 59 * deepLiftConstantZMod j := eq_sub_of_add_eq h59
    _ = 59 * (a - deepLiftConstantZMod j) := by rw [mul_sub]
    _ = deepLiftAffine_target_parameter j a := rfl

theorem deepLiftAffine_has_unique_parameter_type (j : ℕ) (a : mod128) :
    ∃! t : mod128, deepLiftAffineZMod j t = a := by
  refine ⟨deepLiftAffine_target_parameter j a, deepLiftAffine_target_spec j a, ?_⟩
  intro t ht
  exact deepLiftAffine_target_unique j a t ht

def deepLiftAffine_mod128_equiv (j : ℕ) : mod128 ≃ mod128 where
  toFun t := deepLiftAffineZMod j t
  invFun a := deepLiftAffine_target_parameter j a
  left_inv t :=
    (deepLiftAffine_has_unique_parameter_type j (deepLiftAffineZMod j t)).unique
      (deepLiftAffine_target_spec j (deepLiftAffineZMod j t)) rfl
  right_inv a := deepLiftAffine_target_spec j a

end KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
