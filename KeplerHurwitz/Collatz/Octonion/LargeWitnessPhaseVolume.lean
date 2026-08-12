/-
  Large-witness phase index / mod-8 carrier — Lean kernel core [A]/[C].

  Extracted from `large_witness_audit.py` (n ≳ 10^13 probes).
  Wired into `KeplerHurwitz.Core` and `ReachableTheorems`.

  Proved / definitional `[A]`:
  * triangular phase index `S_k = k(k+1)/2` with `k = max(1, v₂+1)`
    (= `triangleNumber` from E-099 `AnisotropicBinaryVolumeContraction`)
  * mod-8 carrier A/B/C (definition)
  * carrier depends only on `n % 8`
  * `padicValNat 2 (2^v) = v` and anchors `S_41 = 861`, Carrier-C for `≡7 (mod 8)`

  Explicitly NOT claimed `[C]` wall:
  * physical packing interpretation beyond the Q-product identity in E-099
  * identity with DualCarrier / V4 / quaternion γ
  * Collatz termination
-/

import Mathlib.Data.Nat.Basic
import Mathlib.NumberTheory.Padics.PadicVal.Basic
import KeplerHurwitz.AnisotropicBinaryVolumeContraction

set_option linter.style.nativeDecide false
set_option linter.style.docString false

namespace KeplerHurwitz.Collatz.Octonion.LargeWitness

open KeplerHurwitz (triangleNumber)

/-! ## Triangular phase index -/

/-- Triangular number `S_k = k(k+1)/2` (alias of E-099 `triangleNumber`). -/
def triangularS (k : ℕ) : ℕ :=
  k * (k + 1) / 2

theorem triangularS_eq_triangleNumber (k : ℕ) :
    triangularS k = triangleNumber k :=
  rfl

/-- Phase depth from 2-adic valuation: `k = max(1, v₂ + 1)`. -/
def phaseIndex (v2 : ℕ) : ℕ :=
  max 1 (v2 + 1)

/-- Modeling phase exponent `S(v₂) := triangularS (phaseIndex v₂)`. -/
def phaseExponent (v2 : ℕ) : ℕ :=
  triangularS (phaseIndex v2)

theorem triangularS_one : triangularS 1 = 1 := by native_decide
theorem triangularS_fourteen : triangularS 14 = 105 := by native_decide
theorem triangularS_forty_one : triangularS 41 = 861 := by native_decide

theorem phaseIndex_zero : phaseIndex 0 = 1 := by native_decide
theorem phaseIndex_thirteen : phaseIndex 13 = 14 := by native_decide
theorem phaseIndex_forty : phaseIndex 40 = 41 := by native_decide

theorem phaseExponent_zero : phaseExponent 0 = 1 := by native_decide
theorem phaseExponent_thirteen : phaseExponent 13 = 105 := by native_decide
theorem phaseExponent_forty : phaseExponent 40 = 861 := by native_decide

theorem phaseIndex_eq_succ (v2 : ℕ) : phaseIndex v2 = v2 + 1 := by
  unfold phaseIndex
  exact Nat.max_eq_right (Nat.le_add_left 1 v2)

theorem phaseExponent_eq_triangular_succ (v2 : ℕ) :
    phaseExponent v2 = triangularS (v2 + 1) := by
  simp [phaseExponent, phaseIndex_eq_succ]

/-! ## 2-adic valuation on pure powers of two -/

theorem padicValNat_two_pow (v : ℕ) : padicValNat 2 (2 ^ v) = v := by
  haveI : Fact (Nat.Prime 2) := ⟨Nat.prime_two⟩
  exact padicValNat.prime_pow (p := 2) v

theorem phaseExponent_of_two_pow (v : ℕ) :
    phaseExponent (padicValNat 2 (2 ^ v)) = triangularS (phaseIndex v) := by
  rw [padicValNat_two_pow]
  rfl

theorem phaseExponent_two_pow_forty :
    phaseExponent (padicValNat 2 (2 ^ 40)) = 861 := by
  rw [phaseExponent_of_two_pow, phaseIndex_forty, triangularS_forty_one]

/-- Odd core of a pure power of two is `1`. -/
theorem oddCore_two_pow (v : ℕ) :
    (2 ^ v) / 2 ^ padicValNat 2 (2 ^ v) = 1 := by
  rw [padicValNat_two_pow, Nat.div_self (pow_pos (by decide : 0 < 2) v)]

/-! ## Simplified mod-8 carrier (not DualCarrier) -/

inductive Mod8Carrier
  | A
  | B
  | C
  deriving DecidableEq, Repr

/--
  Carrier from residue mod 8:
  `C` if `≡7`, `B` if `≡3` or `≡5`, else `A`.
-/
def mod8Carrier (n0 : ℕ) : Mod8Carrier :=
  if n0 % 8 = 7 then .C
  else if n0 % 8 = 3 ∨ n0 % 8 = 5 then .B
  else .A

theorem mod8Carrier_of_mod_eq_seven {n : ℕ} (h : n % 8 = 7) :
    mod8Carrier n = .C := by
  simp [mod8Carrier, h]

theorem mod8Carrier_of_mod_eq_three {n : ℕ} (h : n % 8 = 3) :
    mod8Carrier n = .B := by
  simp [mod8Carrier, h]

theorem mod8Carrier_of_mod_eq_five {n : ℕ} (h : n % 8 = 5) :
    mod8Carrier n = .B := by
  simp [mod8Carrier, h]

theorem mod8Carrier_of_mod_eq_one {n : ℕ} (h : n % 8 = 1) :
    mod8Carrier n = .A := by
  simp [mod8Carrier, h]

/-- Scale-stability: the carrier depends only on the residue class mod 8. -/
theorem mod8Carrier_congr {n m : ℕ} (h : n % 8 = m % 8) :
    mod8Carrier n = mod8Carrier m := by
  simp [mod8Carrier, h]

theorem mod8Carrier_two_pow_sub_one_forty :
    mod8Carrier (2 ^ 40 - 1) = .C :=
  mod8Carrier_of_mod_eq_seven (by native_decide)

theorem mod8Carrier_ten_pow_thirteen_plus_seven :
    mod8Carrier (10 ^ 13 + 7) = .C :=
  mod8Carrier_of_mod_eq_seven (by native_decide)

theorem mod8Carrier_five_pow_thirteen :
    mod8Carrier (5 ^ 13) = .B :=
  mod8Carrier_of_mod_eq_five (by native_decide)

/-! ## Bundle: Lean-capable large-witness Satz -/

/--
  **Satz (LargeWitnessPhaseIndex).**

  1. `phaseExponent v₂ = triangularS (max 1 (v₂+1))` mit
     `triangularS k = k(k+1)/2`.
  2. Für reine Zweierpotenzen `n = 2^v` gilt
     `phaseExponent (padicValNat 2 n) = triangularS (phaseIndex v)`;
     speziell `v = 40` liefert Exponent `861`.
  3. Der mod-8-Carrier hängt nur von `n % 8` ab; für `n ≡ 7 (mod 8)`
     ist er stets `.C` (skalenstabil für große ungerade Zeugen).

  Das ist die Lean-fähige Extraktion aus dem Large-Witness-Audit —
  keine physikalische Volumen- oder DualCarrier-Behauptung.
-/
structure LargeWitnessPhaseIndexTheorem where
  triangular_formula : ∀ k, triangularS k = k * (k + 1) / 2
  phase_of_pow_two :
    ∀ v, phaseExponent (padicValNat 2 (2 ^ v)) = triangularS (phaseIndex v)
  extreme_anchor : phaseExponent (padicValNat 2 (2 ^ 40)) = 861
  carrier_mod_stable : ∀ {n m}, n % 8 = m % 8 → mod8Carrier n = mod8Carrier m
  carrier_C_of_mod7 : ∀ {n}, n % 8 = 7 → mod8Carrier n = .C

theorem large_witness_phase_index_theorem : LargeWitnessPhaseIndexTheorem where
  triangular_formula := fun _ => rfl
  phase_of_pow_two := phaseExponent_of_two_pow
  extreme_anchor := phaseExponent_two_pow_forty
  carrier_mod_stable := fun {_ _} h => mod8Carrier_congr h
  carrier_C_of_mod7 := fun {_} h => mod8Carrier_of_mod_eq_seven h

/-! ## Non-claims -/

def PhaseVolumeIsNotPhysicalClaim : Prop := True
theorem phase_volume_is_not_physical_claim : PhaseVolumeIsNotPhysicalClaim := trivial

def Mod8CarrierIsNotDualCarrier : Prop := True
theorem mod8_carrier_is_not_dual_carrier : Mod8CarrierIsNotDualCarrier := trivial

def NotCollatzProof : Prop := True
theorem not_collatz_proof : NotCollatzProof := trivial

def LargeWitnessAudit_Observed : Prop :=
  PhaseVolumeIsNotPhysicalClaim ∧
    Mod8CarrierIsNotDualCarrier ∧
    NotCollatzProof

theorem large_witness_audit_observed : LargeWitnessAudit_Observed :=
  ⟨phase_volume_is_not_physical_claim, mod8_carrier_is_not_dual_carrier, not_collatz_proof⟩

end KeplerHurwitz.Collatz.Octonion.LargeWitness
