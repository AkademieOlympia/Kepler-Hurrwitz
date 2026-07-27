import KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting
import KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — Core6InfiniteLifting

Discharge of `InfiniteApLiftingHypothesis e` for fixed `e = 4..7`, plus
integration/minimal probes `e = 8` and `e = 9`: concrete seed/base/margin only,
proved via the existing `FiberWordAffine` API.

No new inductive core, no family `∀ e ≥ 8`, no `liftExponent` / packaging API.

Governance: `[A]` for discharged instances; no ∀n / CoverCertified / Collatz.
`ClaimsFreeze` remains false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6InfiniteLifting

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting
open KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail4
open KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail5

/-- Common Core6++[e] affine remainder (independent of the last exponent). -/
theorem wordC_fiberE4 : wordC (fiberE 4) = 2347 := by native_decide
theorem wordC_fiberE5 : wordC (fiberE 5) = 2347 := by native_decide
theorem wordC_fiberE6 : wordC (fiberE 6) = 2347 := by native_decide
theorem wordC_fiberE7 : wordC (fiberE 7) = 2347 := by native_decide
theorem wordC_fiberE8 : wordC (fiberE 8) = 2347 := by native_decide

theorem fiberE_length_seven (e : Nat) : (fiberE e).length = 7 :=
  fiberE_length e

theorem fiberE_sum_eight_add (e : Nat) : (fiberE e).sum = 8 + e :=
  fiberE_sum e

theorem good_le_fiberE {e : Nat} (he : 4 ≤ e) :
    3 ^ (fiberE e).length ≤ 2 ^ (fiberE e).sum := by
  have hstrict : isGoodExpSequence (fiberE e) := isGood_fiberE_of_e_ge_four he
  exact Nat.le_of_lt hstrict

/-- Period matches the lifting modulus `2^{sum+1}`. -/
theorem classPeriod_eq_sum_succ (e : Nat) :
    classPeriod e = 2 ^ ((fiberE e).sum + 1) := by
  simp [classPeriod]

theorem realizes_apMember_of_base {e k : Nat}
    (hbase : RealizesWord (fiberE e) (classBase e)) :
    RealizesWord (fiberE e) (apMember e k) := by
  have h := realizesWord_add_pow (E := fiberE e) (n := classBase e) (k := k) hbase
  simpa [apMember, classMember, classPeriod_eq_sum_succ] using h

theorem contracts_apMember_of_base {e k : Nat}
    (he : 4 ≤ e)
    (hreal : RealizesWord (fiberE e) (apMember e k))
    (hmargin : wordC (fiberE e) <
        classBase e * (2 ^ (fiberE e).sum - 3 ^ (fiberE e).length)) :
    realizedImage (apMember e k) (fiberE e) < apMember e k := by
  have hle : classBase e ≤ apMember e k := by
    simp [apMember, classMember]
  exact contracts_of_le_base hreal (good_le_fiberE he) hmargin hle

/-- Base margin check for `e = 4` (`2347 < 6687 · 1909`). -/
theorem margin_e4 :
    wordC (fiberE 4) <
      classBase 4 * (2 ^ (fiberE 4).sum - 3 ^ (fiberE 4).length) := by
  native_decide

theorem margin_e5 :
    wordC (fiberE 5) <
      classBase 5 * (2 ^ (fiberE 5).sum - 3 ^ (fiberE 5).length) := by
  native_decide

theorem margin_e6 :
    wordC (fiberE 6) <
      classBase 6 * (2 ^ (fiberE 6).sum - 3 ^ (fiberE 6).length) := by
  native_decide

theorem margin_e7 :
    wordC (fiberE 7) <
      classBase 7 * (2 ^ (fiberE 7).sum - 3 ^ (fiberE 7).length) := by
  native_decide

theorem realizes_base_e4 : RealizesWord (fiberE 4) (classBase 4) := by
  simpa [classBase, fiberE_tail4_matches] using realizes_fiber_6687

theorem realizes_base_e5 : RealizesWord (fiberE 5) (classBase 5) := by
  simpa [classBase, fiberE_tail5_matches] using realizes_fiber_10783

theorem realizes_base_e6 : RealizesWord (fiberE 6) (classBase 6) :=
  realizes_e6_base

theorem realizes_base_e7 : RealizesWord (fiberE 7) (classBase 7) :=
  realizes_e7_base

/-- `[A]` Every AP index for `e = 4` is a realizing contractor. -/
theorem apMemberOk_e4 (k : Nat) : ApMemberOk 4 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e4
  · exact contracts_apMember_of_base (by decide : 4 ≤ 4)
      (realizes_apMember_of_base realizes_base_e4) margin_e4

/-- `[A]` Every AP index for `e = 5` is a realizing contractor. -/
theorem apMemberOk_e5 (k : Nat) : ApMemberOk 5 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e5
  · exact contracts_apMember_of_base (by decide : 4 ≤ 5)
      (realizes_apMember_of_base realizes_base_e5) margin_e5

/-- `[A]` Every AP index for `e = 6` is a realizing contractor. -/
theorem apMemberOk_e6 (k : Nat) : ApMemberOk 6 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e6
  · exact contracts_apMember_of_base (by decide : 4 ≤ 6)
      (realizes_apMember_of_base realizes_base_e6) margin_e6

/-- `[A]` Every AP index for `e = 7` is a realizing contractor. -/
theorem apMemberOk_e7 (k : Nat) : ApMemberOk 7 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e7
  · exact contracts_apMember_of_base (by decide : 4 ≤ 7)
      (realizes_apMember_of_base realizes_base_e7) margin_e7

/-- `[A]` Discharge of the infinite AP lifting hypothesis for `e = 4`. -/
theorem infinite_lifting_e4 : InfiniteApLiftingHypothesis 4 := fun _ k =>
  apMemberOk_e4 k

/-- `[A]` Discharge of the infinite AP lifting hypothesis for `e = 5`. -/
theorem infinite_lifting_e5 : InfiniteApLiftingHypothesis 5 := fun _ k =>
  apMemberOk_e5 k

/-- `[A]` Discharge of the infinite AP lifting hypothesis for `e = 6`. -/
theorem infinite_lifting_e6 : InfiniteApLiftingHypothesis 6 := fun _ k =>
  apMemberOk_e6 k

/-- `[A]` Discharge of the infinite AP lifting hypothesis for `e = 7`. -/
theorem infinite_lifting_e7 : InfiniteApLiftingHypothesis 7 := fun _ k =>
  apMemberOk_e7 k

/--
`[A]` Pack: infinite AP lifting for the four closed Core6 single-step
exponents `e = 4..7`.
-/
theorem infinite_lifting_e4_to_e7 :
    InfiniteApLiftingHypothesis 4 ∧
      InfiniteApLiftingHypothesis 5 ∧
      InfiniteApLiftingHypothesis 6 ∧
      InfiniteApLiftingHypothesis 7 :=
  ⟨infinite_lifting_e4, infinite_lifting_e5, infinite_lifting_e6, infinite_lifting_e7⟩

/-! ### Integration probe `e = 8` (concrete data only; existing core) -/

theorem classBase_eight : classBase 8 = 100895 := rfl
theorem classPeriod_eight : classPeriod 8 = 2 ^ 17 := by native_decide

/-- Seed: base realizes `fiberE 8` (finite `native_decide` on one odd start). -/
theorem realizes_base_e8 : RealizesWord (fiberE 8) (classBase 8) := by
  native_decide

/-- Margin: `2347 < 100895 · 63349`. -/
theorem margin_e8 :
    wordC (fiberE 8) <
      classBase 8 * (2 ^ (fiberE 8).sum - 3 ^ (fiberE 8).length) := by
  native_decide

/-- `[A]` Every AP index for `e = 8` is a realizing contractor. -/
theorem apMemberOk_e8 (k : Nat) : ApMemberOk 8 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e8
  · exact contracts_apMember_of_base (by decide : 4 ≤ 8)
      (realizes_apMember_of_base realizes_base_e8) margin_e8

/--
`[A]` Integration probe: infinite AP lifting for `e = 8` via the **same**
`realizes_apMember_of_base` / `contracts_apMember_of_base` path as `e = 4..7`.
Does **not** claim `∀ e ≥ 8`.
-/
theorem infinite_lifting_e8 : InfiniteApLiftingHypothesis 8 := fun _ k =>
  apMemberOk_e8 k

/-! ### Minimal probe `e = 9` (new data, same transfer core; Folge-PR) -/

theorem wordC_fiberE9 : wordC (fiberE 9) = 2347 := by native_decide
theorem classBase_nine : classBase 9 = 166431 := rfl
theorem classPeriod_nine : classPeriod 9 = 2 ^ 18 := by native_decide

/-- Seed: base realizes `fiberE 9` (finite `native_decide` on one odd start). -/
theorem realizes_base_e9 : RealizesWord (fiberE 9) (classBase 9) := by
  native_decide

/-- Margin: `2347 < 166431 · 128885`. -/
theorem margin_e9 :
    wordC (fiberE 9) <
      classBase 9 * (2 ^ (fiberE 9).sum - 3 ^ (fiberE 9).length) := by
  native_decide

/-- `[A]` Every AP index for `e = 9` is a realizing contractor. -/
theorem apMemberOk_e9 (k : Nat) : ApMemberOk 9 k := by
  refine ⟨?_, ?_⟩
  · exact realizes_apMember_of_base realizes_base_e9
  · exact contracts_apMember_of_base (by decide : 4 ≤ 9)
      (realizes_apMember_of_base realizes_base_e9) margin_e9

/--
`[A]` Minimal probe: infinite AP lifting for `e = 9` via the existing transfer API.
Does **not** claim `∀ e ≥ 8`, nor an exponent step `e → e+1`.
-/
theorem infinite_lifting_e9 : InfiniteApLiftingHypothesis 9 := fun _ k =>
  apMemberOk_e9 k

end KeplerHurwitz.Collatz.Pre119Draft.Core6InfiniteLifting
