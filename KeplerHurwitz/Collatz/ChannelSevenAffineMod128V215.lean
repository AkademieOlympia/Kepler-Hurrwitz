import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

/-!
# Kanal-7 V2.15 — H7-A: mod-128 affine Permutation (`[A]`)

Governance:
\[
\boxed{\text{Zielfaser algebraisch parametrisiert} \neq \text{Zielfaser dynamisch erreicht}}
\]
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215

open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

abbrev mod128 := ZMod 128

theorem coeff243_mul_59_mod128 : (243 : mod128) * 59 = 1 := by native_decide

theorem coeff59_mul_243_mod128 : (59 : mod128) * 243 = 1 := by native_decide

theorem coeff243_unit_mod128 : IsUnit (243 : mod128) :=
  isUnit_iff_exists_inv.mpr ⟨59, coeff243_mul_59_mod128⟩

def deepLiftConstantZMod (j : ℕ) : mod128 :=
  (deepLiftConstant j : mod128)

def deepLiftAffineZMod (j : ℕ) (t : mod128) : mod128 :=
  243 * t + deepLiftConstantZMod j

/-- Inverse Parameter `t ≡ 59·(a - c_j)` modulo `128`. -/
def entryParameterMod128 (j : ℕ) (a : mod128) : mod128 :=
  59 * (a - deepLiftConstantZMod j)

abbrev deepLiftAffine_target_parameter := entryParameterMod128

abbrev deepLiftFiberZMod (j : ℕ) (t : mod128) : mod128 :=
  deepLiftAffineZMod j t

theorem deepLiftAffine_entry_spec (j : ℕ) (a : mod128) :
    deepLiftAffineZMod j (entryParameterMod128 j a) = a := by
  dsimp [deepLiftAffineZMod, entryParameterMod128, deepLiftConstantZMod]
  calc (243 : mod128) * (59 * (a - deepLiftConstantZMod j)) + deepLiftConstantZMod j
      = ((243 : mod128) * 59) * (a - deepLiftConstantZMod j) + deepLiftConstantZMod j := by ring
    _ = 1 * (a - deepLiftConstantZMod j) + deepLiftConstantZMod j := by rw [coeff243_mul_59_mod128]
    _ = a := by ring

abbrev deepLiftFiber_entry_spec := deepLiftAffine_entry_spec
abbrev deepLiftAffine_target_spec := deepLiftAffine_entry_spec

theorem deepLiftAffine_entry_unique (j : ℕ) (a t : mod128)
    (ht : deepLiftAffineZMod j t = a) :
    t = entryParameterMod128 j a := by
  have h59 := congrArg (fun x => (59 : mod128) * x) ht
  rw [deepLiftAffineZMod, mul_add, ← mul_assoc, coeff59_mul_243_mod128, one_mul] at h59
  calc t
      = (59 : mod128) * a - (59 : mod128) * deepLiftConstantZMod j := eq_sub_of_add_eq h59
    _ = (59 : mod128) * (a - deepLiftConstantZMod j) := by rw [mul_sub]
    _ = entryParameterMod128 j a := rfl

abbrev deepLiftFiber_entry_unique := deepLiftAffine_entry_unique
abbrev deepLiftAffine_target_unique := deepLiftAffine_entry_unique

theorem deepLiftAffine_has_unique_parameter_type (j : ℕ) (a : mod128) :
    ∃! t : mod128, deepLiftAffineZMod j t = a :=
  ⟨entryParameterMod128 j a, deepLiftAffine_entry_spec j a,
    fun t ht => deepLiftAffine_entry_unique j a t ht⟩

abbrev deepLiftFiber_has_unique_parameter_type := deepLiftAffine_has_unique_parameter_type

def deepLiftAffine_mod128_equiv (j : ℕ) : mod128 ≃ mod128 where
  toFun t := deepLiftAffineZMod j t
  invFun a := entryParameterMod128 j a
  left_inv t := (deepLiftAffine_entry_unique j (deepLiftAffineZMod j t) t rfl).symm
  right_inv a := deepLiftAffine_entry_spec j a

def deepLiftFiberPermutation (j : ℕ) : Equiv.Perm mod128 :=
  deepLiftAffine_mod128_equiv j

end KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
