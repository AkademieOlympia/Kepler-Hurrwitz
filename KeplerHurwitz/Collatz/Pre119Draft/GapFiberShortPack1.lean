import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

-- Pre119Draft fiber certificates: finite `native_decide` evaluations (not mathlib library code).
set_option linter.style.nativeDecide false

/-!
# Pre119Draft — GapFiberShortPack1

Short-Pack 1: smallest open short-gap witnesses at the Pack791@k21 frontier.

Targets `n ∈ {4639, 8735, 9247}` with **true** first-good valuation words
(computed from Syracuse dynamics). The sketched patterns in an earlier draft
(`[…,1,1,1,5]`, `[…,1,2,1,4]`, `[…,1,1,3,3]`) do **not** realize on these starts;
this module uses the verified first-good fibers instead.

Epistemics: `[A]` realizes + contracts for three finite witnesses.
No CoverUpTo / ∀n / Collatz claim. 0 sorry. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.GapFiberShortPack1

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-! ### 1. Witness n = 4639 (first-good len=15, S=25) -/

def fiberE_4639 : List Nat :=
  [1, 1, 1, 1, 2, 2, 3, 1, 2, 1, 1, 2, 2, 2, 3]

theorem fiberE_4639_isGood : isGoodExpSequence fiberE_4639 := by
  native_decide

theorem realizes_fiber_4639 : RealizesWord fiberE_4639 4639 := by
  native_decide

theorem realized_image_4639_eq : realizedImage 4639 fiberE_4639 = 1985 := by
  native_decide

theorem fiber_4639_contracts : realizedImage 4639 fiberE_4639 < 4639 := by
  native_decide

/-! ### 2. Witness n = 8735 (first-good len=8, S=13) -/

def fiberE_8735 : List Nat :=
  [1, 1, 1, 1, 2, 2, 3, 2]

theorem fiberE_8735_isGood : isGoodExpSequence fiberE_8735 := by
  native_decide

theorem realizes_fiber_8735 : RealizesWord fiberE_8735 8735 := by
  native_decide

theorem realized_image_8735_eq : realizedImage 8735 fiberE_8735 = 6997 := by
  native_decide

theorem fiber_8735_contracts : realizedImage 8735 fiberE_8735 < 8735 := by
  native_decide

/-! ### 3. Witness n = 9247 (first-good len=13, S=21) -/

def fiberE_9247 : List Nat :=
  [1, 1, 1, 1, 2, 2, 1, 1, 1, 1, 3, 3, 3]

theorem fiberE_9247_isGood : isGoodExpSequence fiberE_9247 := by
  native_decide

theorem realizes_fiber_9247 : RealizesWord fiberE_9247 9247 := by
  native_decide

theorem realized_image_9247_eq : realizedImage 9247 fiberE_9247 = 7031 := by
  native_decide

theorem fiber_9247_contracts : realizedImage 9247 fiberE_9247 < 9247 := by
  native_decide

/-- `[A]` Bundle: all three Short-Pack-1 witnesses strictly contract. -/
theorem short_pack1_all_contract :
    realizedImage 4639 fiberE_4639 < 4639 ∧
    realizedImage 8735 fiberE_8735 < 8735 ∧
    realizedImage 9247 fiberE_9247 < 9247 :=
  ⟨fiber_4639_contracts, fiber_8735_contracts, fiber_9247_contracts⟩

/-- `[A]` Bundle: all three fibers are good exponent sequences. -/
theorem short_pack1_all_good :
    isGoodExpSequence fiberE_4639 ∧
    isGoodExpSequence fiberE_8735 ∧
    isGoodExpSequence fiberE_9247 :=
  ⟨fiberE_4639_isGood, fiberE_8735_isGood, fiberE_9247_isGood⟩

/-- `[A]` Bundle: all three realize their first-good words. -/
theorem short_pack1_all_realize :
    RealizesWord fiberE_4639 4639 ∧
    RealizesWord fiberE_8735 8735 ∧
    RealizesWord fiberE_9247 9247 :=
  ⟨realizes_fiber_4639, realizes_fiber_8735, realizes_fiber_9247⟩

end KeplerHurwitz.Collatz.Pre119Draft.GapFiberShortPack1
