import KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient
import KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting

set_option linter.style.nativeDecide false

/-!
# Pre119Draft — ApMemberFromTransfer (PR #15, Schicht 4 prelude)

Seed-independent transfer API: lifting is stated relative to an arbitrary realizing
base `b`, not the finite `classBase` census table.

Uniform margin for `e ≥ 5` and the generic infinite-AP transfer are `[A]`.
`canonicalBase` / `canonicalBase_realizes` remain `[C]` (Schicht 3).

No Collatz claim. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.ApMemberFromTransfer

open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
open KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.Core6Lifting

/-- AP member relative to an arbitrary seed `b`. -/
def apMemberFrom (e b k : Nat) : Nat :=
  b + k * classPeriod e

/-- Realizes + contracts on the seed-relative AP. -/
def ApMemberOkFrom (e b k : Nat) : Prop :=
  RealizesWord (fiberE e) (apMemberFrom e b k) ∧
    realizedImage (apMemberFrom e b k) (fiberE e) < apMemberFrom e b k

theorem apMemberFrom_zero (e b : Nat) : apMemberFrom e b 0 = b := by
  simp [apMemberFrom]

theorem realizes_apMemberFrom_of_base {e b k : Nat}
    (hbase : RealizesWord (fiberE e) b) :
    RealizesWord (fiberE e) (apMemberFrom e b k) := by
  have h := realizesWord_add_pow (E := fiberE e) (n := b) (k := k) hbase
  have hper : classPeriod e = 2 ^ ((fiberE e).sum + 1) := by
    simp [classPeriod]
  simpa [apMemberFrom, hper] using h

/-- Odd realizing starts are at least `1`. -/
theorem one_le_of_realizes_cons {e : Nat} {es : List Nat} {n : Nat}
    (h : RealizesWord (e :: es) n) : 1 ≤ n := by
  obtain ⟨hodd, _, _⟩ := h
  omega

private theorem pow_sub_ge_of_e_ge_five {e : Nat} (he : 5 ≤ e) :
    6005 ≤ 2 ^ (e + 8) - 2187 := by
  have hle : 2 ^ 13 ≤ 2 ^ (e + 8) :=
    Nat.pow_le_pow_right (by decide : 0 < 2) (by omega)
  have h13 : 2 ^ 13 - 2187 = 6005 := by native_decide
  -- 2187 ≤ 2^13 ≤ 2^{e+8}, so subtraction is exact and monotone
  have h2187 : 2187 ≤ 2 ^ 13 := by native_decide
  have h2187' : 2187 ≤ 2 ^ (e + 8) := Nat.le_trans h2187 hle
  calc
    6005 = 2 ^ 13 - 2187 := h13.symm
    _ ≤ 2 ^ (e + 8) - 2187 := Nat.sub_le_sub_right hle _

/--
`[A]` Uniform margin for Core6 single-step fibers with `e ≥ 5`:
once a start realizes the word, the affine contraction margin holds automatically.
-/
theorem margin_fiberE_of_realizes {e b : Nat}
    (he : 5 ≤ e) (hb : RealizesWord (fiberE e) b) :
    wordC (fiberE e) <
      b * (2 ^ (fiberE e).sum - 3 ^ (fiberE e).length) := by
  have hb1 : 1 ≤ b := by
    rw [fiberE_list] at hb
    exact one_le_of_realizes_cons hb
  have hC : wordC (fiberE e) = 2347 := wordC_fiberE e
  have hlen : (fiberE e).length = 7 := fiberE_length e
  have hsum : (fiberE e).sum = e + 8 := by
    rw [fiberE_sum]; omega
  have hmarg : 6005 ≤ 2 ^ (e + 8) - 2187 := pow_sub_ge_of_e_ge_five he
  have h2347 : 2347 < 6005 := by native_decide
  have hstrict : 2347 < 2 ^ (e + 8) - 2187 := Nat.lt_of_lt_of_le h2347 hmarg
  have hmul : 2 ^ (e + 8) - 2187 ≤ b * (2 ^ (e + 8) - 2187) := by
    exact Nat.le_mul_of_pos_left _ hb1
  have : 2347 < b * (2 ^ (e + 8) - 2187) :=
    Nat.lt_of_lt_of_le hstrict hmul
  simpa [hC, hlen, hsum, Nat.reducePow] using this

/--
`[A]` Seed-independent infinite AP transfer for `e ≥ 5`: any realizing base
lifts to every AP index via the existing `FiberWordAffine` core.
-/
theorem infinite_lifting_from_realizing_base {e b : Nat}
    (he : 5 ≤ e) (hbase : RealizesWord (fiberE e) b) :
    ∀ k : Nat, ApMemberOkFrom e b k := by
  intro k
  refine ⟨realizes_apMemberFrom_of_base hbase, ?_⟩
  have hreal := realizes_apMemberFrom_of_base (e := e) (b := b) (k := k) hbase
  have hgood : 3 ^ (fiberE e).length ≤ 2 ^ (fiberE e).sum := by
    have : 4 ≤ e := by omega
    exact Nat.le_of_lt (isGood_fiberE_of_e_ge_four this)
  have hmargin := margin_fiberE_of_realizes he hbase
  have hle : b ≤ apMemberFrom e b k := by
    simp [apMemberFrom]
  exact contracts_of_le_base hreal hgood hmargin hle

/--
`[C]` Universal target once a realizing canonical seed exists for every `e ≥ 8`
(Schicht 3: `canonicalBase_realizes`). Not discharged here.
-/
def CanonicalInfiniteLiftingGoal : Prop :=
  ∀ e : Nat, 8 ≤ e →
    ∃ b : Nat,
      RealizesWord (fiberE e) b ∧
        ∀ k : Nat, ApMemberOkFrom e b k

end KeplerHurwitz.Collatz.Pre119Draft.ApMemberFromTransfer
