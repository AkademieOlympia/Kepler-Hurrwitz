import KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra

set_option linter.dupNamespace false

/-!
# Pre119Draft — AffineOddQuotient (PR #15, Schicht 2)

Exact odd-quotient form of the affine identity, preferred as the reverse-engineering
interface before `Nat.ModEq`.

Forward direction `[A]`; full reverse `RealizesWord ↔ AffineOddQuotient` remains
the central open kernel goal of this PR series (`[C]` until proved).

No Collatz claim. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient

open KeplerHurwitz
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine

/-- Exact odd quotient form of the affine Syracuse word identity. -/
def AffineOddQuotient (E : List Nat) (n : Nat) : Prop :=
  ∃ q : Nat, Odd q ∧ q * 2 ^ E.sum = 3 ^ E.length * n + wordC E

theorem realizedImage_odd_of_cons {e : Nat} {es : List Nat} {n : Nat}
    (h : RealizesWord (e :: es) n) :
    Odd (realizedImage n (e :: es)) := by
  induction es generalizing n e with
  | nil =>
    obtain ⟨_hodd, _hval, _⟩ := h
    have hpos : 0 < 3 * n + 1 := by omega
    simpa [realizedImage, nextOdd] using oddCore_odd_of_pos hpos
  | cons e' es' ih =>
    obtain ⟨_hodd, _hval, hrest⟩ := h
    simpa [realizedImage] using ih (e := e') (n := nextOdd n) hrest

/-- `[A]` Forward: realizing words yield an odd affine quotient. -/
theorem affineOddQuotient_of_realizesWord {E : List Nat} {n : Nat}
    (hne : E ≠ []) (h : RealizesWord E n) :
    AffineOddQuotient E n := by
  match E, hne with
  | [], hne => exact (hne rfl).elim
  | e :: es, _ =>
    refine ⟨realizedImage n (e :: es), realizedImage_odd_of_cons h, ?_⟩
    simpa using realizedImage_mul_pow h

/--
`[C]` Target: reverse characterization (to be proved by inductive exact valuation
reconstruction). Named here so later layers compose against a single interface.
-/
def RealizesWordIffAffineOddQuotientStatement : Prop :=
  ∀ (E : List Nat) (n : Nat),
    E ≠ [] →
      (∀ a ∈ E, 1 ≤ a) →
        (RealizesWord E n ↔ AffineOddQuotient E n)

/-- Marker: reverse direction not claimed in this module. -/
theorem realizesWord_iff_affineOddQuotient_forward_only {E n}
    (hne : E ≠ []) (h : RealizesWord E n) :
    AffineOddQuotient E n :=
  affineOddQuotient_of_realizesWord hne h

end KeplerHurwitz.Collatz.Pre119Draft.AffineOddQuotient
