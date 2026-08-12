/-
  Three-step Syracuse compensation bound on odd-core embeddings.

  Bundles `κ → κ' → κ'' → κ'''` and classifies when the composite yields
  embedding-norm descent — especially after one or two half-step ascents.

  Claim wall:
    [A] under `SyracuseThreeStepHypothesis`, core/norm identities and
        `κ''' < κ ↔ 3κ''+1 < κ·2^{v₃}`
    [A] double half-step prefix (`v₁=v₂=1`) forces intermediate ascent;
        macro-descent then requires a compensating third valuation
    [B] concrete witnesses (descent / non-descent)
    [C] / NON-CLAIM: no ergodic ⟨v⟩ theorem; no cycle/divergence exclusion;
        no Collatz proof

  Docs: docs/eabc_collatz_audit_grid.md § Three-step compensation
-/

import KeplerHurwitz.EABC.CollatzTwoStep

namespace KeplerHurwitz.EABC
namespace CollatzThreeStep

open CollatzBridge
open CollatzSyracuseNorm
open CollatzTwoStep
open EABCCoord

/-! ## Three-step hypothesis -/

/--
Three consecutive accelerated Syracuse steps:
`κ --v₁--> κ' --v₂--> κ'' --v₃--> κ'''`.
-/
structure SyracuseThreeStepHypothesis
    (κ κ' κ'' κ''' : ℕ) (v1 v2 v3 : ℕ) : Prop where
  step1 : SyracuseNormHypothesis κ κ' v1
  step2 : SyracuseNormHypothesis κ' κ'' v2
  step3 : SyracuseNormHypothesis κ'' κ''' v3

def ofSteps
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H1 : SyracuseNormHypothesis κ κ' v1)
    (H2 : SyracuseNormHypothesis κ' κ'' v2)
    (H3 : SyracuseNormHypothesis κ'' κ''' v3) :
    SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3 :=
  ⟨H1, H2, H3⟩

/-- Prefix two-step extracted from a three-step block. -/
def prefixTwoStep
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3) :
    SyracuseTwoStepHypothesis κ κ' κ'' v1 v2 :=
  ⟨H.step1, H.step2⟩

/-- Double half-step prefix: `v₁ = v₂ = 1`. -/
abbrev IsDoubleHalfThenStep (κ κ' κ'' κ''' : ℕ) (v3 : ℕ) : Prop :=
  Nonempty (SyracuseThreeStepHypothesis κ κ' κ'' κ''' 1 1 v3)

/-! ## Macro descent / compensation [A under H] -/

/-- Macro descent after three accelerated steps. -/
abbrev ThreeStepMacroDescent (κ κ''' : ℕ) : Prop :=
  κ''' < κ

theorem normSq_embed_of_threeStep
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3) :
    normSq (embedOddCore κ H.step1.embeddable_pre) = (κ : ℤ) ^ 2 ∧
      normSq (embedOddCore κ' H.step1.embeddable_post) = (κ' : ℤ) ^ 2 ∧
      normSq (embedOddCore κ'' H.step2.embeddable_post) = (κ'' : ℤ) ^ 2 ∧
      normSq (embedOddCore κ''' H.step3.embeddable_post) = (κ''' : ℤ) ^ 2 :=
  ⟨normSq_embedOddCore _ _, normSq_embedOddCore _ _,
    normSq_embedOddCore _ _, normSq_embedOddCore _ _⟩

theorem threeStep_normSq_descent_of_core_lt
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3)
    (h : ThreeStepMacroDescent κ κ''') :
    normSq (embedOddCore κ''' H.step3.embeddable_post) <
      normSq (embedOddCore κ H.step1.embeddable_pre) := by
  have hκ : (κ''' : ℤ) < (κ : ℤ) := by exact_mod_cast h
  have hsq : (κ''' : ℤ) ^ 2 < (κ : ℤ) ^ 2 := by
    nlinarith [sq_nonneg (κ''' : ℤ), sq_nonneg (κ : ℤ)]
  rw [normSq_embedOddCore, normSq_embedOddCore]
  exact hsq

/--
`[A under H₃]` Exact three-step compensation criterion:
`κ''' < κ` iff `3κ'' + 1 < κ · 2^{v₃}`.
-/
theorem threeStep_macroDescent_iff
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3) :
    ThreeStepMacroDescent κ κ''' ↔ 3 * κ'' + 1 < κ * 2 ^ v3 := by
  have hv3 : 0 < 2 ^ v3 := Nat.pow_pos (by decide : 0 < (2 : ℕ))
  have hExact : 3 * κ'' + 1 = κ''' * 2 ^ v3 := H.step3.step_exact
  constructor
  · intro hlt
    have : κ''' * 2 ^ v3 < κ * 2 ^ v3 :=
      Nat.mul_lt_mul_of_pos_right hlt hv3
    simpa [hExact] using this
  · intro hbound
    have : κ''' * 2 ^ v3 < κ * 2 ^ v3 := by simpa [hExact] using hbound
    exact Nat.lt_of_mul_lt_mul_right this

/--
`[A under H₃]` Macro-descent forces the third-step compensation inequality.
-/
theorem threeStep_compensation_bound
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3)
    (hDesc : ThreeStepMacroDescent κ κ''') :
    3 * κ'' + 1 < κ * 2 ^ v3 :=
  (threeStep_macroDescent_iff H).mp hDesc

/-! ## Double half-step then compensate [A] -/

/--
After two positive half-steps, the second intermediate core strictly exceeds
the start: `κ < κ''`. Macro-descent therefore cannot be inherited from the
prefix alone.
-/
theorem double_half_prefix_ascent
    {κ κ' κ'' κ''' v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' 1 1 v3)
    (hκ : 0 < κ) :
    κ < κ' ∧ κ' < κ'' := by
  have h1 := half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H.step1) hκ
  have h2 :=
    half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H.step2)
      (Nat.zero_lt_of_lt h1)
  exact ⟨h1, h2⟩

/--
`[A under H₃]` Double half-step prefix + macro-descent ⇒ third step compensates:
`3κ'' + 1 < κ · 2^{v₃}` and `κ < κ''`.
-/
theorem double_half_then_macroDescent_requires_compensation
    {κ κ' κ'' κ''' v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' 1 1 v3)
    (hκ : 0 < κ)
    (hDesc : ThreeStepMacroDescent κ κ''') :
    3 * κ'' + 1 < κ * 2 ^ v3 ∧ κ < κ'' := by
  have hasc := double_half_prefix_ascent H hκ
  refine ⟨threeStep_compensation_bound H hDesc, Nat.lt_trans hasc.1 hasc.2⟩

/-! ## Concrete witnesses [B]/[A] -/

/--
Three-step descent: `11 → 17 → 13 → 5`
(`v = 1, 2, 3`; ends below start).
-/
theorem threeStep_11_17_13_5 :
    SyracuseThreeStepHypothesis 11 17 13 5 1 2 3 where
  step1 := syracuseNormHypothesis_11_17
  step2 := {
    embeddable_pre := by decide
    embeddable_post := by decide
    step_exact := by decide
    v_pos := by decide
  }
  step3 := {
    embeddable_pre := by decide
    embeddable_post := by decide
    step_exact := by decide
    v_pos := by decide
  }

theorem threeStep_11_17_13_5_macroDescent : ThreeStepMacroDescent 11 5 := by
  decide

theorem threeStep_11_17_13_5_normSq_descent :
    normSq (embedOddCore 5 (by decide)) < normSq (embedOddCore 11 (by decide)) :=
  threeStep_normSq_descent_of_core_lt threeStep_11_17_13_5
    threeStep_11_17_13_5_macroDescent

theorem threeStep_11_17_13_5_compensation :
    3 * 13 + 1 < 11 * 2 ^ 3 :=
  threeStep_compensation_bound threeStep_11_17_13_5 threeStep_11_17_13_5_macroDescent

/--
Three-step non-descent: `7 → 11 → 17 → 13`
(double half-step then `v₃=2`; still `13 > 7`).
-/
theorem threeStep_7_11_17_13 :
    SyracuseThreeStepHypothesis 7 11 17 13 1 1 2 where
  step1 := syracuseNormHypothesis_7_11
  step2 := syracuseNormHypothesis_11_17
  step3 := {
    embeddable_pre := by decide
    embeddable_post := by decide
    step_exact := by decide
    v_pos := by decide
  }

theorem threeStep_7_11_17_13_not_macroDescent :
    ¬ ThreeStepMacroDescent 7 13 := by
  decide

theorem threeStep_7_11_17_13_prefix_ascent :
    7 < 11 ∧ 11 < 17 :=
  double_half_prefix_ascent threeStep_7_11_17_13 (by decide)

/--
Same start with a stronger third valuation would be needed for descent:
here `v₃=2` fails the compensation inequality against start `7`.
-/
theorem threeStep_7_11_17_13_compensation_fails :
    ¬ (3 * 17 + 1 < 7 * 2 ^ 2) := by
  decide

/-! ## Explicit non-claims -/

/--
**NON-CLAIM:** No theorem that every odd orbit eventually meets a three-step
block with `ThreeStepMacroDescent`. Ergodic `𝔼[v] > log₂ 3` remains open.
-/
theorem threeStep_eventual_macroDescent_not_claimed : True := trivial

/-- **NON-CLAIM:** No cycle-exclusion / divergence-exclusion theorem. -/
theorem threeStep_cycle_and_divergence_not_claimed : True := trivial

/-- This module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_three_step : True := trivial

structure ThreeStepStatus where
  descentWitness : ThreeStepMacroDescent 11 5
  ascentWitness : ¬ ThreeStepMacroDescent 7 13
  compensationIff : ∀ {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (_H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3),
    ThreeStepMacroDescent κ κ''' ↔ 3 * κ'' + 1 < κ * 2 ^ v3
  globalOpen : True

def three_step_status : ThreeStepStatus where
  descentWitness := threeStep_11_17_13_5_macroDescent
  ascentWitness := threeStep_7_11_17_13_not_macroDescent
  compensationIff := fun H => threeStep_macroDescent_iff H
  globalOpen := threeStep_eventual_macroDescent_not_claimed

end CollatzThreeStep
end KeplerHurwitz.EABC
