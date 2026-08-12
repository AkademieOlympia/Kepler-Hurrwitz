import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

-- Pre119Draft fiber class certificates (finite `native_decide`).
set_option linter.style.nativeDecide false

/-!
# Pre119Draft — GapFiberClassTail4

Parallelklasse zu Tail-5: first-good Faser
`fiberE = [1,1,1,1,2,2,4]` (Core-6 + Endexponent `4`).

Offline-Scan odd `n < 2^21`: genau **256** Starter; AP
`n_k = 6687 + k · 2^13` für `k = 0..255` (alle kontrahierend).

`[A]`: Güte, Repräsentant `n=6687` (und Katalog-Rep `14879 = n_1`),
Pilot-Pack `k ∈ {0..7}`, Vollzensus `∀ k < 256`.

Kein CoverUpTo / ∀n / Collatz-Claim. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail4

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-- Class fiber: Core-6 prefix + terminal valuation `4`. -/
def fiberE_tail4 : List Nat := [1, 1, 1, 1, 2, 2, 4]

theorem fiberE_tail4_length : fiberE_tail4.length = 7 := by native_decide
theorem fiberE_tail4_sum : fiberE_tail4.sum = 12 := by native_decide

theorem fiberE_tail4_isGood : isGoodExpSequence fiberE_tail4 := by
  native_decide

/-- AP of the Tail-4 class below `2^21` (256 members). -/
def tail4ClassMember (k : Nat) : Nat := 6687 + k * 2 ^ 13

theorem tail4ClassMember_zero : tail4ClassMember 0 = 6687 := by rfl
theorem tail4ClassMember_one : tail4ClassMember 1 = 14879 := by native_decide

/-! ### Canonical representatives -/

theorem realizes_fiber_6687 : RealizesWord fiberE_tail4 6687 := by
  native_decide

theorem realized_image_6687_eq : realizedImage 6687 fiberE_tail4 = 3571 := by
  native_decide

theorem fiber_6687_contracts : realizedImage 6687 fiberE_tail4 < 6687 := by
  native_decide

theorem realizes_fiber_14879 : RealizesWord fiberE_tail4 14879 := by
  native_decide

theorem realized_image_14879_eq : realizedImage 14879 fiberE_tail4 = 7945 := by
  native_decide

theorem fiber_14879_contracts : realizedImage 14879 fiberE_tail4 < 14879 := by
  native_decide

/-! ### AP pilots k = 2..7 -/

theorem realizes_tail4_k2 :
    RealizesWord fiberE_tail4 (tail4ClassMember 2) := by native_decide
theorem contracts_tail4_k2 :
    realizedImage (tail4ClassMember 2) fiberE_tail4 < tail4ClassMember 2 := by
  native_decide

theorem realizes_tail4_k3 :
    RealizesWord fiberE_tail4 (tail4ClassMember 3) := by native_decide
theorem contracts_tail4_k3 :
    realizedImage (tail4ClassMember 3) fiberE_tail4 < tail4ClassMember 3 := by
  native_decide

theorem realizes_tail4_k4 :
    RealizesWord fiberE_tail4 (tail4ClassMember 4) := by native_decide
theorem contracts_tail4_k4 :
    realizedImage (tail4ClassMember 4) fiberE_tail4 < tail4ClassMember 4 := by
  native_decide

theorem realizes_tail4_k5 :
    RealizesWord fiberE_tail4 (tail4ClassMember 5) := by native_decide
theorem contracts_tail4_k5 :
    realizedImage (tail4ClassMember 5) fiberE_tail4 < tail4ClassMember 5 := by
  native_decide

theorem realizes_tail4_k6 :
    RealizesWord fiberE_tail4 (tail4ClassMember 6) := by native_decide
theorem contracts_tail4_k6 :
    realizedImage (tail4ClassMember 6) fiberE_tail4 < tail4ClassMember 6 := by
  native_decide

theorem realizes_tail4_k7 :
    RealizesWord fiberE_tail4 (tail4ClassMember 7) := by native_decide
theorem contracts_tail4_k7 :
    realizedImage (tail4ClassMember 7) fiberE_tail4 < tail4ClassMember 7 := by
  native_decide

/-- `[A]` Bundle: good class word + eight AP pilots realize + contract. -/
theorem tail4_class_pilot_pack :
    isGoodExpSequence fiberE_tail4 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 0) ∧
    realizedImage (tail4ClassMember 0) fiberE_tail4 < tail4ClassMember 0 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 1) ∧
    realizedImage (tail4ClassMember 1) fiberE_tail4 < tail4ClassMember 1 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 2) ∧
    realizedImage (tail4ClassMember 2) fiberE_tail4 < tail4ClassMember 2 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 3) ∧
    realizedImage (tail4ClassMember 3) fiberE_tail4 < tail4ClassMember 3 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 4) ∧
    realizedImage (tail4ClassMember 4) fiberE_tail4 < tail4ClassMember 4 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 5) ∧
    realizedImage (tail4ClassMember 5) fiberE_tail4 < tail4ClassMember 5 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 6) ∧
    realizedImage (tail4ClassMember 6) fiberE_tail4 < tail4ClassMember 6 ∧
    RealizesWord fiberE_tail4 (tail4ClassMember 7) ∧
    realizedImage (tail4ClassMember 7) fiberE_tail4 < tail4ClassMember 7 :=
  ⟨fiberE_tail4_isGood,
    realizes_fiber_6687, fiber_6687_contracts,
    realizes_fiber_14879, fiber_14879_contracts,
    realizes_tail4_k2, contracts_tail4_k2,
    realizes_tail4_k3, contracts_tail4_k3,
    realizes_tail4_k4, contracts_tail4_k4,
    realizes_tail4_k5, contracts_tail4_k5,
    realizes_tail4_k6, contracts_tail4_k6,
    realizes_tail4_k7, contracts_tail4_k7⟩

def tail4ClassPeriod : Nat := 2 ^ 13
def tail4ClassBase : Nat := 6687
def tail4ClassCountBelow2pow21 : Nat := 256

theorem tail4ClassCountBelow2pow21_eq :
    tail4ClassCountBelow2pow21 = 256 := rfl

/-! ### Full AP census under `[A]`: all `k < 256` -/

/--
`[A]` Every index `k : Fin 256` yields a realizing, contracting Tail-4 member.
Finite class census (not ∀n).
-/
theorem tail4_forall_fin256 :
    ∀ k : Fin 256,
      RealizesWord fiberE_tail4 (tail4ClassMember k.val) ∧
        realizedImage (tail4ClassMember k.val) fiberE_tail4 <
          tail4ClassMember k.val := by
  native_decide

theorem tail4_forall_k_lt_256 {k : Nat} (hk : k < 256) :
    RealizesWord fiberE_tail4 (tail4ClassMember k) ∧
      realizedImage (tail4ClassMember k) fiberE_tail4 < tail4ClassMember k :=
  tail4_forall_fin256 ⟨k, hk⟩

end KeplerHurwitz.Collatz.Pre119Draft.GapFiberClassTail4
