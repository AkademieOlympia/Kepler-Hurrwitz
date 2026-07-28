/-
  Necessary conditions for odd-core Syracuse cycles (Option A — algebraic).

  Makes cycle-exclusion *gaps precise*. Does **not** prove that the only
  Collatz cycle is `{1,2,4}`.

  Claim wall:
    [A] one-step fixed points of `SyracuseNormHypothesis` are exactly `κ=1, v=2`
    [A] a three-step block that returns (`κ'''=κ`) cannot be a macro-descent
    [B] V₄ channel-product dictionary along finite channel lists
    [C] / NON-CLAIM: no full V₄ / Collatz cycle-exclusion; no ergodic density

  Docs: docs/eabc_collatz_audit_grid.md § Cycle necessary conditions
-/

import KeplerHurwitz.EABC.CollatzThreeStep
import KeplerHurwitz.EABC.V4

namespace KeplerHurwitz.EABC
namespace CollatzCycleNecessary

open CollatzBridge
open CollatzSyracuseNorm
open CollatzThreeStep

/-! ## One-step fixed points [A] -/

private theorem pow_two_ge_eight (n : ℕ) : 8 ≤ 2 ^ (n + 3) := by
  induction n with
  | zero => decide
  | succ n ih =>
    calc
      8 ≤ 2 ^ (n + 3) := ih
      _ ≤ 2 ^ (n + 4) :=
        Nat.pow_le_pow_right (by decide : 0 < (2 : ℕ)) (Nat.le_succ _)

/--
`[A]` The only embeddable accelerated one-step fixed point is `κ = 1`, `v = 2`
(the odd-core reading of the classical attractor loop through `1`).
-/
theorem odd_core_fixed_point_eq_one
    {κ v : ℕ} (H : SyracuseNormHypothesis κ κ v) :
    κ = 1 ∧ v = 2 := by
  have hex : 3 * κ + 1 = κ * 2 ^ v := H.step_exact
  have hvpos := H.v_pos
  match v with
  | 0 =>
    exact (Nat.lt_irrefl _ hvpos).elim
  | 1 =>
    -- 3κ+1 = 2κ ⇒ κ+1 = 0 impossible
    have : 3 * κ + 1 = κ * 2 := by simpa [pow_one] using hex
    omega
  | 2 =>
    -- 3κ+1 = 4κ ⇒ κ = 1
    have : 3 * κ + 1 = κ * 4 := by simpa using hex
    refine ⟨?_, rfl⟩
    omega
  | n + 3 =>
    -- 3κ+1 = κ·2^{n+3} ≥ 8κ ⇒ 1 ≥ 5κ, impossible for κ ≥ 1
    have h8 : 8 ≤ 2 ^ (n + 3) := pow_two_ge_eight n
    have hκ : 0 < κ := by
      by_contra hz
      have : κ = 0 := Nat.eq_zero_of_not_pos hz
      simp [this] at hex
    have hge : 8 * κ ≤ κ * 2 ^ (n + 3) := by
      calc
        8 * κ ≤ 2 ^ (n + 3) * κ := Nat.mul_le_mul_right κ h8
        _ = κ * 2 ^ (n + 3) := Nat.mul_comm _ _
    have : 8 * κ ≤ 3 * κ + 1 := by
      calc
        8 * κ ≤ κ * 2 ^ (n + 3) := hge
        _ = 3 * κ + 1 := hex.symm
    omega

/-- Concrete witness: `1 → 1` with `v = 2`. -/
theorem fixed_point_one :
    SyracuseNormHypothesis 1 1 2 where
  embeddable_pre := by decide
  embeddable_post := by decide
  step_exact := by decide
  v_pos := by decide

/-! ## Three-step return forbids macro-descent [A] -/

/--
A three-step block that returns (`κ''' = κ`) cannot satisfy macro-descent.
-/
theorem threeStep_return_not_macroDescent
    {κ κ' κ'' v1 v2 v3 : ℕ}
    (_H : SyracuseThreeStepHypothesis κ κ' κ'' κ v1 v2 v3) :
    ¬ ThreeStepMacroDescent κ κ := by
  intro h
  exact Nat.lt_irrefl κ h

/-- Returning three-step blocks fail the compensation inequality. -/
theorem threeStep_return_not_compensation
    {κ κ' κ'' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ v1 v2 v3) :
    ¬ (3 * κ'' + 1 < κ * 2 ^ v3) := by
  intro hbound
  exact threeStep_return_not_macroDescent H
    ((threeStep_macroDescent_iff H).mpr hbound)

/-- Macro-descent excludes period-3 return to the same start. -/
theorem macroDescent_excludes_threeStep_return
    {κ κ' κ'' κ''' v1 v2 v3 : ℕ}
    (H : SyracuseThreeStepHypothesis κ κ' κ'' κ''' v1 v2 v3)
    (hDesc : ThreeStepMacroDescent κ κ''') :
    κ''' ≠ κ := by
  intro heq
  subst heq
  exact threeStep_return_not_macroDescent H hDesc

theorem threeStep_11_17_13_5_excludes_return :
    (5 : ℕ) ≠ 11 :=
  macroDescent_excludes_threeStep_return
    threeStep_11_17_13_5 threeStep_11_17_13_5_macroDescent

/-! ## V₄ channel product dictionary [B] -/

def channelProduct : List V4 → V4
  | [] => V4.E
  | x :: xs => x * channelProduct xs

theorem channelProduct_nil : channelProduct [] = V4.E := rfl

/--
Schematic: successive channel product is `E`.
Dictionary only — not implied by Syracuse arithmetic.
-/
def CycleChannelProductIsE (chs : List V4) : Prop :=
  channelProduct chs = V4.E

theorem cycleChannelProduct_singleton_E :
    CycleChannelProductIsE [V4.E] := rfl

theorem cycleChannelProduct_AA_is_E :
    CycleChannelProductIsE [V4.A, V4.A] := rfl

/-- Combinatorial label for channels along `11,17,13,5`. -/
theorem channelProduct_C_A_E_A :
    channelProduct [V4.C, V4.A, V4.E, V4.A] = V4.C := rfl

/-! ## Explicit non-claims -/

/--
**NON-CLAIM / OFFEN:** No proof that every closed odd-core Syracuse orbit is
the trivial fixed point `1`, nor a full \(V_4\) exotic-cycle exclusion.
-/
theorem full_cycle_exclusion_not_claimed : True := trivial

/-- **NON-CLAIM:** Option B (cylinder / log-density) is not formalized here.
Python operational scan: `src/kepler_hurwitz/eabc_cylinder_noncompensator_scan.py`
(docs/eabc_collatz_audit_grid.md §5.4). No density→0 theorem. -/
theorem ergodic_cylinder_density_not_claimed : True := trivial

/-- This module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_cycle_necessary : True := trivial

structure CycleNecessaryStatus where
  fixedPointOnlyOne : ∀ {κ v : ℕ}, SyracuseNormHypothesis κ κ v → κ = 1 ∧ v = 2
  returnForbidsMacro : ∀ {κ κ' κ'' v1 v2 v3 : ℕ},
    SyracuseThreeStepHypothesis κ κ' κ'' κ v1 v2 v3 →
      ¬ ThreeStepMacroDescent κ κ
  fullExclusionOpen : True

def cycle_necessary_status : CycleNecessaryStatus where
  fixedPointOnlyOne := fun H => odd_core_fixed_point_eq_one H
  returnForbidsMacro := fun H => threeStep_return_not_macroDescent H
  fullExclusionOpen := full_cycle_exclusion_not_claimed

end CollatzCycleNecessary
end KeplerHurwitz.EABC
