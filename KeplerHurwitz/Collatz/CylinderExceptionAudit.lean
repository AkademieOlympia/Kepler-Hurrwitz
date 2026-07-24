import Mathlib
import KeplerHurwitz.Collatz.StrongCylinderDescent

/-!
# Cylinder exception audit — finite `N_a = ⌊B/M⌋` `[B]`

**Collatz?** **NEIN.**

For positive-margin words that are not strong at the canonical residue
(e.g. `(2,2)` with `r=1`), descent holds for all realizing `n > N_a`.
Finite exceptions may be discharged by `findWitnessWithFuel`.
-/

namespace KeplerHurwitz.Collatz.CylinderExceptionAudit

open KeplerHurwitz.Collatz.AffineCylinderBlockDescent
open KeplerHurwitz.Collatz.ExactValuationCylinder
open KeplerHurwitz.Collatz.StrongCylinderDescent
open KeplerHurwitz.Collatz.CollatzChirurgeryBridge

/-- Exception threshold `N_a = ⌊B/M⌋` under positive margin. -/
def exceptionBound {k : Nat} (a : Fin k → Nat)
    (hmargin : 3 ^ k < 2 ^ cumulativeValuation a k) : Nat :=
  blockConstant a / posMargin a

/--
`[A]`→`[B]` Outside the finite exception window `n > �
`[A]`→`[B]` Outside the finite exception window `n > ⌊B/M⌋`, positive margin
implies block descent on every realizing start.
-/
theorem positiveMargin_descent_outside_exceptions
    {k n : Nat} {a : Fin k → Nat}
    (hreal : RealizesValuationWord n a)
    (hmargin : 3 ^ k < 2 ^ cumulativeValuation a k)
    (hn : exceptionBound a hmargin < n) :
    oddCoreSyracuseIter k n < n := by
  have hMpos : 0 < posMargin a := by
    simp [posMargin]
    omega
  have hB : blockConstant a < posMargin a * n := by
    -- `B < M · n` from `⌊B/M⌋ < n`
    have hdiv := Nat.div_add_mod (blockConstant a) (posMargin a)
    -- `B = M * ⌊B/M⌋ + B%M < M * n` since ⌊B/M⌋ < n and rem < M
    have hrem : blockConstant a % posMargin a < posMargin a :=
      Nat.mod_lt _ hMpos
    have : posMargin a * (blockConstant a / posMargin a) +
        blockConstant a % posMargin a < posMargin a * n := by
      have hmul :
          posMargin a * (blockConstant a / posMargin a) + posMargin a ≤
            posMargin a * n := by
        have : blockConstant a / posMargin a + 1 ≤ n := by omega
        calc
          posMargin a * (blockConstant a / posMargin a) + posMargin a
              = posMargin a * (blockConstant a / posMargin a + 1) := by ring
          _ ≤ posMargin a * n := Nat.mul_le_mul_left _ this
      omega
    simpa [posMargin, hdiv.symm] using this
  have hBound :
      blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n := by
    simpa [posMargin] using hB
  exact block_descent_of_margin hreal hmargin hBound

/-! #########################################################################
## Concrete word `(2,2)`
######################################################################### -/

theorem exceptionBound_word_2_2 :
    exceptionBound word_2_2 margin_word_2_2_pos = 1 := by
  simp [exceptionBound, posMargin, blockConstant_word_2_2, cumulativeValuation_word_2_2]

/--
`[B]` Every realizing `(2,2)`-start with `n > 1` descends in two accelerated steps.
(Canonical residue `r=1` is the unique exception candidate; `n=1` is the fixed point.)
-/
theorem word_2_2_descent_outside_exceptions
    {n : Nat} (hreal : RealizesValuationWord n word_2_2) (hn : 1 < n) :
    oddCoreSyracuseIter 2 n < n := by
  have hbound : exceptionBound word_2_2 margin_word_2_2_pos < n := by
    rw [exceptionBound_word_2_2]
    omega
  exact positiveMargin_descent_outside_exceptions hreal margin_word_2_2_pos hbound

/-- Via residue certificate: all `n ≡ 1 (mod 32)` with `n > 1` descend. -/
theorem word_2_2_descent_of_mod32
    {n : Nat} (hmod : n % 32 = 1) (hn : 1 < n) :
    oddCoreSyracuseIter 2 n < n :=
  word_2_2_descent_outside_exceptions
    ((realizesWord_iff_modEq_residue_word_2_2 n).mpr hmod) hn

/--
Hook: the unique odd exception `n = 1` on the `(2,2)` cylinder is the fixed point
`T(1)=1`; fuel search correctly reports no shrink step from fuel windows that
exclude the trivial non-descent.
-/
theorem word_2_2_exception_is_one :
    RealizesValuationWord 1 word_2_2 ∧ ¬ oddCoreSyracuseIter 2 1 < 1 := by
  refine ⟨(realizesWord_iff_modEq_residue_word_2_2 1).mpr (by decide), ?_⟩
  simp [oddCoreSyracuseIter, oddCoreSyracuse_one]

/-- Fuel-search hook packaging (soundness reused from ChirurgeryBridge). -/
theorem findWitnessWithFuel_hook_word_2_2
    {n fuel t : Nat}
    (h : findWitnessWithFuel n fuel 1 = some t) :
    1 ≤ t ∧ t < 1 + fuel ∧ 0 < t ∧ oddCoreSyracuseIter t n < n :=
  findWitnessWithFuel_sound h

set_option linter.style.nativeDecide false

/-- Concrete certified descent on the cylinder: `n = 33 ≡ 1 (mod 32)`. -/
theorem example_word_2_2_mod32_descent :
    (33 % 32 = 1) ∧ oddCoreSyracuseIter 2 33 < 33 := by
  refine ⟨by decide, ?_⟩
  exact word_2_2_descent_of_mod32 (by decide) (by decide)

end KeplerHurwitz.Collatz.CylinderExceptionAudit
