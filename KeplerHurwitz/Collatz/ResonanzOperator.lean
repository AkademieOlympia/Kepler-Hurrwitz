/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team

Survivor-Shift-Transfer M_w (H7/Clog-Atlas).

* Edge: shift compatibility (concrete: index list from export).
* Weight: w(0)=1/2, w(1)=3/2.
* Abstract: word/bit layer for induction.
* Concrete: Fin n audit from docs/exports/h7_shift_L*_C*.json.

Epistemics:
* Proved here: small acyclic certificate L=8,C=12 (rho=0, row sums < 1).
* Open: recurrent dissipativity (C=8: empirical rho ~ 1.20 > 1).
* Not a Collatz proof.
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic

namespace KeplerHurwitz.Collatz.ResonanzOperator

open Matrix

/-! ## Abstract weight layer -/

/-- Resonance weight of the appended bit (false -> 0, true -> 1). -/
def resonanceWeight (b : Bool) : Rat :=
  bif b then (3 : Rat) / 2 else (1 : Rat) / 2

theorem resonanceWeight_false : resonanceWeight false = 1 / 2 := rfl
theorem resonanceWeight_true : resonanceWeight true = 3 / 2 := rfl

/-- Word as bit vector of length L. Index 0 = leftmost char of the Python export word. -/
def Word (L : Nat) := Fin L → Bool

/-- Shift edge of equal length: u[1:] = v[:-1]. -/
def IsShiftEdge {L : Nat} (u v : Word L) : Prop :=
  ∀ i : Fin L, ∀ h : i.val + 1 < L, u ⟨i.val + 1, h⟩ = v i

/-- Weight of a shift edge via the last bit of v. -/
def shiftEdgeWeight {L : Nat} [NeZero L] (u v : Word L) (_h : IsShiftEdge u v) : Rat :=
  resonanceWeight (v ⟨L - 1, Nat.sub_one_lt (NeZero.ne L)⟩)

/-! ## Concrete audit: Clog C=12, L=8, |V|=3 (acyclic)

Data from docs/exports/h7_shift_L8_C12p0.json:
* 0: 10111110 (residue 41)
* 1: 11011111 (residue 27)
* 2: 11111010 (residue 31)
* sole edge: 1 -> 0 with weight 1/2
-/

def survivors_L8_C12 : Fin 3 → String
  | 0 => "10111110"
  | 1 => "11011111"
  | 2 => "11111010"

/-- Weighted shift transfer matrix on Fin 3. -/
def Mw_L8_C12 : Matrix (Fin 3) (Fin 3) Rat :=
  !![(0 : Rat), 0, 0; (1 : Rat) / 2, 0, 0; 0, 0, 0]

theorem Mw_L8_C12_apply_10 : Mw_L8_C12 1 0 = 1 / 2 := by
  simp [Mw_L8_C12]

def rowSum_L8_C12 (i : Fin 3) : Rat :=
  Mw_L8_C12 i 0 + Mw_L8_C12 i 1 + Mw_L8_C12 i 2

theorem rowSum_L8_C12_lt_one (i : Fin 3) : rowSum_L8_C12 i < 1 := by
  fin_cases i
  · simp [rowSum_L8_C12, Mw_L8_C12]
  · simp [rowSum_L8_C12, Mw_L8_C12]; norm_num
  · simp [rowSum_L8_C12, Mw_L8_C12]

theorem row_dissipative_L8_C12 :
    ∀ i : Fin 3, rowSum_L8_C12 i < 1 :=
  rowSum_L8_C12_lt_one

/-- Nilpotence: no closed walks of length >= 2. -/
theorem Mw_L8_C12_sq_eq_zero : Mw_L8_C12 * Mw_L8_C12 = 0 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [Mw_L8_C12, Matrix.mul_apply, Fin.sum_univ_three]

/-- Perron witness: strictly positive vector. -/
def perronWitness_L8_C12 : Fin 3 → Rat := fun _ => 1

theorem Mw_mulVec_le_half_perron :
    ∀ i : Fin 3,
      (Mw_L8_C12.mulVec perronWitness_L8_C12) i
        ≤ ((1 : Rat) / 2) * perronWitness_L8_C12 i := by
  intro i
  fin_cases i <;>
    simp [Mw_L8_C12, perronWitness_L8_C12, Matrix.mulVec, dotProduct, Fin.sum_univ_three]

/-! ## Target predicate and open recurrent gap -/

/-- Weighted dissipativity: exists theta < 1 and v > 0 with M v <= theta v. -/
def IsWeightedDissipative {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ θ : Rat, θ < 1 ∧ ∃ v : Fin n → Rat,
    (∀ i, 0 < v i) ∧ ∀ i, (M.mulVec v) i ≤ θ * v i

theorem isWeightedDissipative_L8_C12 : IsWeightedDissipative Mw_L8_C12 := by
  refine ⟨(1 : Rat) / 2, by norm_num, perronWitness_L8_C12, ?_, ?_⟩
  · intro i; simp [perronWitness_L8_C12]
  · exact Mw_mulVec_le_half_perron

/--
Recurrent soft case (C=8): empirically rho approx 1.20 > 1.
Placeholder Prop only — no theorem claimed.
-/
def RecurrentWeightedGap (_L : Nat) (_C : Rat) : Prop :=
  ∃ n : Nat, ∃ _M : Matrix (Fin n) (Fin n) Rat, True

/-! ## Phase C: Doob transform and certificates

Doob kernel (for `v i ≠ 0`, `θ ≠ 0`):
  `M̃_ij = M_ij * v_j / (θ * v_i)`

Exact eigenpair `M v = θ v` makes Doob rows sum to 1.
Subinvariance `M v ≤ θ v` with `v > 0` is the constructive upper certificate (`ρ ≤ θ`).

Goal regime: `HasContractiveDoob` with `θ < 1`.
C=8 infrastructure uses certificates with `θ > 1` (no false golden claim).
-/

/-- Doob kernel. Caller ensures `θ ≠ 0` and `v i ≠ 0` at evaluation sites. -/
def doobTransform {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) :
    Matrix (Fin n) (Fin n) Rat :=
  Matrix.of fun i j => M i j * v j / (θ * v i)

/-- Exact eigenpair certificate. -/
def IsExactEigenpair {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) :
    Prop :=
  ∀ i, (M.mulVec v) i = θ * v i

/-- Row-stochastic Doob kernel (equivalent to exact eigenpair when `v,θ` invertible). -/
def IsDoobCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) : Prop :=
  (∀ i, v i ≠ 0) ∧ θ ≠ 0 ∧ ∀ i, ∑ j : Fin n, doobTransform M v θ i j = 1

/-- Subinvariant Perron certificate (upper bound on spectral radius). -/
def IsSubinvariantCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) : Prop :=
  (∀ i, 0 < v i) ∧ 0 < θ ∧ ∀ i, (M.mulVec v) i ≤ θ * v i

/-- Superinvariant certificate (lower bound). -/
def IsSuperinvariantCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (lam : Rat) : Prop :=
  (∃ i, v i ≠ 0) ∧ 0 < lam ∧ ∀ i, (M.mulVec v) i ≥ lam * v i

/-- Golden target: subinvariant certificate with contraction rate `< 1`. -/
def HasContractiveDoob {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ v : Fin n → Rat, ∃ θ : Rat, θ < 1 ∧ IsSubinvariantCertificate M v θ

/-- Acyclic audit already supplies a contractive subinvariant certificate. -/
theorem hasContractiveDoob_L8_C12 : HasContractiveDoob Mw_L8_C12 := by
  refine ⟨perronWitness_L8_C12, (1 : Rat) / 2, by norm_num, ?_⟩
  refine ⟨?_, by norm_num, Mw_mulVec_le_half_perron⟩
  intro i; simp [perronWitness_L8_C12]

end KeplerHurwitz.Collatz.ResonanzOperator
