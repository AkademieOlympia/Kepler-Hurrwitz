import Mathlib
import KeplerHurwitz.OddCore

/-!
# Pre119Draft — FiberWordBasics

Minimal Syracuse valuation-word API for Pre119Draft fiber modules.

Governance: `[A]` formal, `[B]` diagnostic, `[C]` open.
No Collatz claim; `ClaimsFreeze` remains false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

open KeplerHurwitz

/-- 2-adic valuation of `3n+1`. -/
def valuationStep (n : Nat) : Nat :=
  padicValNat 2 (3 * n + 1)

/-- Next odd Syracuse iterate: `oddCore (3n+1)`. -/
def nextOdd (n : Nat) : Nat :=
  oddCore (3 * n + 1)

/-- Realizes a valuation word on an odd start. -/
def RealizesWord : List Nat → Nat → Prop
  | [], _ => True
  | e :: es, n => n % 2 = 1 ∧ valuationStep n = e ∧ RealizesWord es (nextOdd n)

/-- Image after applying the valuation word (assumes realization). -/
def realizedImage (n : Nat) : List Nat → Nat
  | [] => n
  | _ :: es => realizedImage (nextOdd n) es

/-- Good exponent sequence: `3^m < 2^S`. -/
def isGoodExpSequence (E : List Nat) : Prop :=
  3 ^ E.length < 2 ^ E.sum

instance decidesRealizesWord (E : List Nat) (n : Nat) : Decidable (RealizesWord E n) := by
  induction E generalizing n with
  | nil =>
    dsimp [RealizesWord]
    exact inferInstanceAs (Decidable True)
  | cons e es ih =>
    dsimp [RealizesWord]
    have : Decidable (RealizesWord es (nextOdd n)) := ih (nextOdd n)
    infer_instance

instance decidesIsGoodExpSequence (E : List Nat) : Decidable (isGoodExpSequence E) := by
  dsimp [isGoodExpSequence]
  infer_instance

theorem realizesWord_nil (n : Nat) : RealizesWord [] n := trivial

theorem realizedImage_nil (n : Nat) : realizedImage n [] = n := rfl

end KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
