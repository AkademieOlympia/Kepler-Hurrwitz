import KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
import KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

/-!
# Pre119Draft — FiberEWordAlgebra (PR #15, Schicht 1)

Parametric word algebra for `fiberE e = Core6 ++ [e]`:
- `wordC (fiberE e) = 2347` for **all** `e` (exact identity, not a census observation);
- specialized affine image identity on realizing starts.

Governance: `[A]` for proved identities. No `canonicalBase_realizes`, no universal
infinite lifting, no Collatz. ClaimsFreeze false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra

open KeplerHurwitz
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema

theorem fiberE_list (e : Nat) : fiberE e = [1, 1, 1, 1, 2, 2, e] := by
  simp [fiberE, core6]

theorem wordC_singleton (e : Nat) : wordC [e] = 1 := by
  simp [wordC]

/--
`[A]` Exact identity: the Core6-single-step affine remainder is independent of `e`.
-/
theorem wordC_fiberE (e : Nat) : wordC (fiberE e) = 2347 := by
  rw [fiberE_list]
  -- Unfold; the last factor is `2^e * wordC [] = 0`, so `e` cancels.
  simp [wordC]

theorem fiberE_length_seven' (e : Nat) : (fiberE e).length = 7 :=
  fiberE_length e

theorem fiberE_sum_eight_add' (e : Nat) : (fiberE e).sum = e + 8 := by
  rw [fiberE_sum]
  omega

/--
`[A]` Specialized affine identity for realizing `fiberE e` starts.
-/
theorem fiberE_affine_identity {e n : Nat}
    (h : RealizesWord (fiberE e) n) :
    realizedImage n (fiberE e) * 2 ^ (e + 8) =
      3 ^ 7 * n + 2347 := by
  have hmul := realizedImage_mul_pow h
  simpa [fiberE_length_seven', fiberE_sum_eight_add', wordC_fiberE e, Nat.add_comm] using hmul

end KeplerHurwitz.Collatz.Pre119Draft.FiberEWordAlgebra
