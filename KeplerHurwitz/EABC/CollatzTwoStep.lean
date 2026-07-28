/-
  Macro / two-step Syracuse algebra on odd-core embeddings.

  Bundles two accelerated steps `κ → κ' → κ''` and classifies when the
  composite yields embedding-norm descent — without claiming that every
  trajectory eventually meets such a block.

  Claim wall:
    [A] under `SyracuseTwoStepHypothesis`, core/norm identities and
        the exact compensation criterion `κ'' < κ ↔ 3κ'+1 < κ·2^{v₂}`
    [A] if first step is a B/C half-step (`v₁=1`), then `κ' > κ` for `κ>0`,
        so macro-descent requires a compensating second step
    [B] V₄ successive-channel product (dictionary); concrete witnesses
    [C] / NON-CLAIM: no ergodic ⟨v⟩>log₂3 theorem; no cycle exclusion;
        no global Collatz proof

  Docs: docs/eabc_collatz_audit_grid.md § Two-step / macro descent
-/

import KeplerHurwitz.EABC.CollatzSyracuseNorm
import KeplerHurwitz.EABC.V4

namespace KeplerHurwitz.EABC
namespace CollatzTwoStep

open CollatzBridge
open CollatzSyracuseNorm
open EABCCoord

/-! ## Two-step hypothesis -/

/--
Two consecutive accelerated Syracuse steps on embeddable odd cores:
`κ --v₁--> κ' --v₂--> κ''`.
-/
structure SyracuseTwoStepHypothesis
    (κ κ' κ'' : ℕ) (v1 v2 : ℕ) : Prop where
  step1 : SyracuseNormHypothesis κ κ' v1
  step2 : SyracuseNormHypothesis κ' κ'' v2

/-- Build a two-step hypothesis from two single-step hypotheses. -/
def ofSteps
    {κ κ' κ'' v1 v2 : ℕ}
    (H1 : SyracuseNormHypothesis κ κ' v1)
    (H2 : SyracuseNormHypothesis κ' κ'' v2) :
    SyracuseTwoStepHypothesis κ κ' κ'' v1 v2 :=
  ⟨H1, H2⟩

/-- First step is a B/C half-step (`v₁ = 1`). -/
def IsHalfThenStep (κ κ' κ'' : ℕ) (v2 : ℕ) : Prop :=
  Nonempty (SyracuseTwoStepHypothesis κ κ' κ'' 1 v2)

/-! ## Core / norm calculus under H₂ [A under H] -/

theorem embeddable_triple
    {κ κ' κ'' v1 v2 : ℕ} (H : SyracuseTwoStepHypothesis κ κ' κ'' v1 v2) :
    OddCoreEmbeddable κ ∧ OddCoreEmbeddable κ' ∧ OddCoreEmbeddable κ'' :=
  ⟨H.step1.embeddable_pre, H.step1.embeddable_post, H.step2.embeddable_post⟩

/--
`[A under H₂]` Embedding norms are the three core squares.
-/
theorem normSq_embed_of_twoStep
    {κ κ' κ'' v1 v2 : ℕ} (H : SyracuseTwoStepHypothesis κ κ' κ'' v1 v2) :
    normSq (embedOddCore κ H.step1.embeddable_pre) = (κ : ℤ) ^ 2 ∧
      normSq (embedOddCore κ' H.step1.embeddable_post) = (κ' : ℤ) ^ 2 ∧
      normSq (embedOddCore κ'' H.step2.embeddable_post) = (κ'' : ℤ) ^ 2 :=
  ⟨normSq_embedOddCore _ _, normSq_embedOddCore _ _, normSq_embedOddCore _ _⟩

/--
Macro descent on cores (and hence on embedding norms).
-/
abbrev TwoStepMacroDescent (κ κ'' : ℕ) : Prop :=
  κ'' < κ

theorem twoStep_normSq_descent_of_core_lt
    {κ κ' κ'' v1 v2 : ℕ} (H : SyracuseTwoStepHypothesis κ κ' κ'' v1 v2)
    (h : TwoStepMacroDescent κ κ'') :
    normSq (embedOddCore κ'' H.step2.embeddable_post) <
      normSq (embedOddCore κ H.step1.embeddable_pre) := by
  have hκ : (κ'' : ℤ) < (κ : ℤ) := by exact_mod_cast h
  have hsq : (κ'' : ℤ) ^ 2 < (κ : ℤ) ^ 2 := by
    nlinarith [sq_nonneg (κ'' : ℤ), sq_nonneg (κ : ℤ)]
  rw [normSq_embedOddCore, normSq_embedOddCore]
  exact hsq

/--
`[A under H₂]` Exact compensation criterion after the second step identity:
macro-descent `κ'' < κ` holds iff `3κ' + 1 < κ · 2^{v₂}`.
-/
theorem twoStep_macroDescent_iff
    {κ κ' κ'' v1 v2 : ℕ} (H : SyracuseTwoStepHypothesis κ κ' κ'' v1 v2) :
    TwoStepMacroDescent κ κ'' ↔ 3 * κ' + 1 < κ * 2 ^ v2 := by
  have hv2 : 0 < 2 ^ v2 := Nat.pow_pos (by decide : 0 < (2 : ℕ))
  have hExact : 3 * κ' + 1 = κ'' * 2 ^ v2 := H.step2.step_exact
  constructor
  · intro hlt
    have : κ'' * 2 ^ v2 < κ * 2 ^ v2 :=
      Nat.mul_lt_mul_of_pos_right hlt hv2
    simpa [hExact] using this
  · intro hbound
    have : κ'' * 2 ^ v2 < κ * 2 ^ v2 := by simpa [hExact] using hbound
    exact Nat.lt_of_mul_lt_mul_right this

/-! ## Half-step then compensate [A] -/

/--
On a positive B/C half-step the intermediate core ascends: `κ < κ'`.
Hence macro-descent cannot come from the first step alone.
-/
theorem half_step_intermediate_ascent
    {κ κ' : ℕ} (H : SyracuseHalfStepHypothesis κ κ') (hκ : 0 < κ) :
    κ < κ' := by
  have h2 : 2 ∣ 3 * κ + 1 := H.even_step.two_dvd
  have hκ' : κ' = (3 * κ + 1) / 2 := H.half_step
  have : κ * 2 < 3 * κ + 1 := by omega
  have : κ < (3 * κ + 1) / 2 := by
    have hmul := Nat.div_mul_cancel h2
    omega
  simpa [hκ'] using this

/-- Recover a half-step hypothesis from an accelerated step with `v = 1`. -/
theorem toHalfStep_of_normHyp_v1
    {κ κ' : ℕ} (H : SyracuseNormHypothesis κ κ' 1) :
    SyracuseHalfStepHypothesis κ κ' where
  embeddable_pre := H.embeddable_pre
  embeddable_post := H.embeddable_post
  half_step := by
    have hex := H.step_exact
    simp only [pow_one] at hex
    omega
  even_step := by
    have hex := H.step_exact
    simp only [pow_one] at hex
    exact even_iff_two_dvd.mpr ⟨κ', by omega⟩

/--
`[A under H₂]` If the first step is a half-step (`v₁=1`) and `κ>0`, then
macro-descent requires a **strict compensating** second step:
`3κ' + 1 < κ · 2^{v₂}` (equivalently `κ'' < κ`).
-/
theorem half_then_step_macroDescent_requires_compensation
    {κ κ' κ'' v2 : ℕ}
    (H : SyracuseTwoStepHypothesis κ κ' κ'' 1 v2)
    (hκ : 0 < κ)
    (hDesc : TwoStepMacroDescent κ κ'') :
    3 * κ' + 1 < κ * 2 ^ v2 ∧ κ < κ' := by
  refine ⟨(twoStep_macroDescent_iff H).mp hDesc, ?_⟩
  exact half_step_intermediate_ascent (toHalfStep_of_normHyp_v1 H.step1) hκ

/-! ## V₄ successive-channel dictionary [B] -/

/--
Successive \(V_4\) labels along a two-step block (not a dynamical law —
additive `+1` still blocks multiplicative reconstruction of `κ''`).
-/
def twoStepChannelPair
    {κ κ' : ℕ} (hκ : OddCoreEmbeddable κ) (hκ' : OddCoreEmbeddable κ') :
    V4 × V4 :=
  (toV4 κ hκ, toV4 κ' hκ')

/-- Product of the two successive residual channels in \(V_4\). -/
def twoStepChannelProduct
    {κ κ' : ℕ} (hκ : OddCoreEmbeddable κ) (hκ' : OddCoreEmbeddable κ') : V4 :=
  toV4 κ hκ * toV4 κ' hκ'

/--
`[B]` Dictionary marker: the \(V_4\) product of successive channels is a
combinatorial label; it need not equal `toV4 κ''`.
-/
theorem twoStepChannelProduct_is_dictionary : True := trivial

/-! ## Concrete witnesses [B]/[A] -/

/-- Two-step descent: `13 → 5 → 1` (`v₁=3`, `v₂=4`). -/
theorem twoStep_13_5_1 :
    SyracuseTwoStepHypothesis 13 5 1 3 4 where
  step1 := {
    embeddable_pre := by decide
    embeddable_post := by decide
    step_exact := by decide
    v_pos := by decide
  }
  step2 := {
    embeddable_pre := by decide
    embeddable_post := by decide
    step_exact := by decide
    v_pos := by decide
  }

theorem twoStep_13_5_1_macroDescent : TwoStepMacroDescent 13 1 := by decide

theorem twoStep_13_5_1_normSq_descent :
    normSq (embedOddCore 1 (by decide)) < normSq (embedOddCore 13 (by decide)) :=
  twoStep_normSq_descent_of_core_lt twoStep_13_5_1 twoStep_13_5_1_macroDescent

theorem twoStep_13_5_1_compensation :
    3 * 5 + 1 < 13 * 2 ^ 4 :=
  (twoStep_macroDescent_iff twoStep_13_5_1).mp twoStep_13_5_1_macroDescent

/-- Two-step ascent: `7 → 11 → 17` (both half-steps). -/
theorem twoStep_7_11_17 :
    SyracuseTwoStepHypothesis 7 11 17 1 1 where
  step1 := syracuseNormHypothesis_7_11
  step2 := syracuseNormHypothesis_11_17

theorem twoStep_7_11_17_not_macroDescent : ¬ TwoStepMacroDescent 7 17 := by decide

/-- Channels along `7 → 11`: B then C; product `B*C = A`. -/
theorem twoStep_channels_7_11 :
    twoStepChannelPair (by decide : OddCoreEmbeddable 7)
        (by decide : OddCoreEmbeddable 11) =
      (V4.B, V4.C) ∧
    twoStepChannelProduct (by decide : OddCoreEmbeddable 7)
        (by decide : OddCoreEmbeddable 11) =
      V4.A := by
  constructor
  · simp [twoStepChannelPair, toV4]
  · simp [twoStepChannelProduct, toV4]
    rfl

/-- Channels along `13 → 5`: E then A; product `E*A = A`. -/
theorem twoStep_channels_13_5 :
    twoStepChannelPair (by decide : OddCoreEmbeddable 13)
        (by decide : OddCoreEmbeddable 5) =
      (V4.E, V4.A) ∧
    twoStepChannelProduct (by decide : OddCoreEmbeddable 13)
        (by decide : OddCoreEmbeddable 5) =
      V4.A := by
  constructor <;> simp [twoStepChannelPair, twoStepChannelProduct, toV4]

/-! ## Explicit non-claims -/

/--
**NON-CLAIM:** No theorem that every odd orbit eventually meets a two-step
block with `TwoStepMacroDescent`. Ergodic `𝔼[v] > log₂ 3` remains open.
-/
theorem twoStep_eventual_macroDescent_not_claimed : True := trivial

/-- **NON-CLAIM:** No cycle-exclusion theorem in `EABCCoord ℤ`. -/
theorem twoStep_cycle_exclusion_not_claimed : True := trivial

/-- This module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_two_step : True := trivial

/-- Status bundle for documentation / ReachableTheorems. -/
structure TwoStepStatus where
  descentWitness : TwoStepMacroDescent 13 1
  ascentWitness : ¬ TwoStepMacroDescent 7 17
  compensationIff : ∀ {κ κ' κ'' v1 v2 : ℕ}
    (_H : SyracuseTwoStepHypothesis κ κ' κ'' v1 v2),
    TwoStepMacroDescent κ κ'' ↔ 3 * κ' + 1 < κ * 2 ^ v2
  globalOpen : True

def two_step_status : TwoStepStatus where
  descentWitness := twoStep_13_5_1_macroDescent
  ascentWitness := twoStep_7_11_17_not_macroDescent
  compensationIff := fun H => twoStep_macroDescent_iff H
  globalOpen := twoStep_eventual_macroDescent_not_claimed

end CollatzTwoStep
end KeplerHurwitz.EABC
