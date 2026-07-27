import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

-- Pre119Draft fiber class certificates (finite `native_decide`).
set_option linter.style.nativeDecide false

/-!
# Pre119Draft — GapFiberClassTail5

Muster-Systematisierung: first-good Faserklasse
`fiberE = [1,1,1,1,2,2,5]` (Core-6 + Endexponent `5`).

Offline `[B]` (Scan odd `n < 2^21`): genau **128** Starter realisieren dieses
first-good-Wort. Sie bilden die AP
`n_k = 10783 + k · 2^14` für `k = 0..127` (alle kontrahierend).

Dieses Modul verankert unter `[A]`:
- Güte der Klassenfaser,
- den kanonischen Repräsentanten `n=10783`,
- einen finiten Pilot-Pack `k ∈ {0..7}` entlang der AP.

Kein CoverUpTo / ∀n / Collatz-Claim. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail5

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-- Class fiber: Core-6 prefix + terminal valuation `5`. -/
def fiberE_tail5 : List Nat := [1, 1, 1, 1, 2, 2, 5]

theorem fiberE_tail5_length : fiberE_tail5.length = 7 := by native_decide
theorem fiberE_tail5_sum : fiberE_tail5.sum = 13 := by native_decide

theorem fiberE_tail5_isGood : isGoodExpSequence fiberE_tail5 := by
  native_decide

/-- Arithmetic progression of the Tail-5 class below `2^21` (offline: 128 members). -/
def tail5ClassMember (k : Nat) : Nat := 10783 + k * 2 ^ 14

theorem tail5ClassMember_zero : tail5ClassMember 0 = 10783 := by rfl

/-! ### Canonical representative n = 10783 (k = 0) -/

theorem realizes_fiber_10783 : RealizesWord fiberE_tail5 10783 := by
  native_decide

theorem realized_image_10783_eq : realizedImage 10783 fiberE_tail5 = 2879 := by
  native_decide

theorem fiber_10783_contracts : realizedImage 10783 fiberE_tail5 < 10783 := by
  native_decide

/-! ### AP pilots k = 1..7 -/

theorem realizes_tail5_k1 :
    RealizesWord fiberE_tail5 (tail5ClassMember 1) := by native_decide
theorem contracts_tail5_k1 :
    realizedImage (tail5ClassMember 1) fiberE_tail5 < tail5ClassMember 1 := by
  native_decide

theorem realizes_tail5_k2 :
    RealizesWord fiberE_tail5 (tail5ClassMember 2) := by native_decide
theorem contracts_tail5_k2 :
    realizedImage (tail5ClassMember 2) fiberE_tail5 < tail5ClassMember 2 := by
  native_decide

theorem realizes_tail5_k3 :
    RealizesWord fiberE_tail5 (tail5ClassMember 3) := by native_decide
theorem contracts_tail5_k3 :
    realizedImage (tail5ClassMember 3) fiberE_tail5 < tail5ClassMember 3 := by
  native_decide

theorem realizes_tail5_k4 :
    RealizesWord fiberE_tail5 (tail5ClassMember 4) := by native_decide
theorem contracts_tail5_k4 :
    realizedImage (tail5ClassMember 4) fiberE_tail5 < tail5ClassMember 4 := by
  native_decide

theorem realizes_tail5_k5 :
    RealizesWord fiberE_tail5 (tail5ClassMember 5) := by native_decide
theorem contracts_tail5_k5 :
    realizedImage (tail5ClassMember 5) fiberE_tail5 < tail5ClassMember 5 := by
  native_decide

theorem realizes_tail5_k6 :
    RealizesWord fiberE_tail5 (tail5ClassMember 6) := by native_decide
theorem contracts_tail5_k6 :
    realizedImage (tail5ClassMember 6) fiberE_tail5 < tail5ClassMember 6 := by
  native_decide

theorem realizes_tail5_k7 :
    RealizesWord fiberE_tail5 (tail5ClassMember 7) := by native_decide
theorem contracts_tail5_k7 :
    realizedImage (tail5ClassMember 7) fiberE_tail5 < tail5ClassMember 7 := by
  native_decide

/-- `[A]` Bundle: class word is good and the eight AP pilots realize + contract. -/
theorem tail5_class_pilot_pack :
    isGoodExpSequence fiberE_tail5 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 0) ∧
    realizedImage (tail5ClassMember 0) fiberE_tail5 < tail5ClassMember 0 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 1) ∧
    realizedImage (tail5ClassMember 1) fiberE_tail5 < tail5ClassMember 1 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 2) ∧
    realizedImage (tail5ClassMember 2) fiberE_tail5 < tail5ClassMember 2 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 3) ∧
    realizedImage (tail5ClassMember 3) fiberE_tail5 < tail5ClassMember 3 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 4) ∧
    realizedImage (tail5ClassMember 4) fiberE_tail5 < tail5ClassMember 4 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 5) ∧
    realizedImage (tail5ClassMember 5) fiberE_tail5 < tail5ClassMember 5 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 6) ∧
    realizedImage (tail5ClassMember 6) fiberE_tail5 < tail5ClassMember 6 ∧
    RealizesWord fiberE_tail5 (tail5ClassMember 7) ∧
    realizedImage (tail5ClassMember 7) fiberE_tail5 < tail5ClassMember 7 :=
  ⟨fiberE_tail5_isGood,
    realizes_fiber_10783, fiber_10783_contracts,
    realizes_tail5_k1, contracts_tail5_k1,
    realizes_tail5_k2, contracts_tail5_k2,
    realizes_tail5_k3, contracts_tail5_k3,
    realizes_tail5_k4, contracts_tail5_k4,
    realizes_tail5_k5, contracts_tail5_k5,
    realizes_tail5_k6, contracts_tail5_k6,
    realizes_tail5_k7, contracts_tail5_k7⟩

/-- Offline census marker (not a proof of the count): period `2^14`, base `10783`. -/
def tail5ClassPeriod : Nat := 2 ^ 14
def tail5ClassBase : Nat := 10783
def tail5ClassCountBelow2pow21_offline : Nat := 128

end KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail5
