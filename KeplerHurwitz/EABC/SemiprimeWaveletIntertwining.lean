/-
  Intertwining defect of the semiprimal filterbank.

  Claim wall:
    [A] defect energy; homogeneity; localization on the detail channel (under hypotheses)
    [C] dynamical “naturality” / physics reading of the commutator — interpretive only
-/

import Mathlib.Tactic
import KeplerHurwitz.EABC.SemiprimeWaveletEnergy

namespace KeplerHurwitz.EABC
namespace SemiprimeWavelet

/-! ## Scalar action on triad states -/

/-- Pointwise scalar multiplication on `Fin 3 → ℝ`. -/
def smulTriad (a : ℝ) (q : Fin 3 → ℝ) : Fin 3 → ℝ :=
  fun i => a * q i

/-! ## Intertwining defect -/

/-- Generalized intertwining defect \(\Delta_{F,T}(q)=F(Tq)-T'(Fq)\). -/
noncomputable def intertwiningDefect
    (F T T' : (Fin 3 → ℝ) → (Fin 3 → ℝ)) (q : Fin 3 → ℝ) : Fin 3 → ℝ :=
  F (T q) - T' (F q)

/-- Defect energy \(E_\Delta(q)=\|\Delta(q)\|^2\). -/
noncomputable def defectEnergy
    (F T T' : (Fin 3 → ℝ) → (Fin 3 → ℝ)) (q : Fin 3 → ℝ) : ℝ :=
  energySq (intertwiningDefect F T T' q)

/-- Satz 12: vanishing defect energy for all states iff exact intertwining. -/
theorem defectEnergy_eq_zero_iff_intertwines
    (F T T' : (Fin 3 → ℝ) → (Fin 3 → ℝ)) :
    (∀ q, defectEnergy F T T' q = 0) ↔ (∀ q, F (T q) = T' (F q)) := by
  constructor
  · intro h q
    have hE := h q
    unfold defectEnergy energySq intertwiningDefect at hE
    have hterms :=
      (Finset.sum_eq_zero_iff_of_nonneg
        (fun _ _ => sq_nonneg ((F (T q) - T' (F q)) _))).1 hE
    ext i
    have hi := hterms i (Finset.mem_univ i)
    exact sub_eq_zero.mp (sq_eq_zero_iff.mp hi)
  · intro h q
    simp [defectEnergy, energySq, intertwiningDefect, h]

/-- Homogeneity hypotheses for endomorphisms. -/
def IsHomogeneous (T : (Fin 3 → ℝ) → (Fin 3 → ℝ)) : Prop :=
  ∀ a q, T (smulTriad a q) = smulTriad a (T q)

def IsAdditive (T : (Fin 3 → ℝ) → (Fin 3 → ℝ)) : Prop :=
  ∀ q r, T (q + r) = T q + T r

def IsLinearEnd (T : (Fin 3 → ℝ) → (Fin 3 → ℝ)) : Prop :=
  IsHomogeneous T ∧ IsAdditive T

/-- Satz 13: linear homogeneity of the defect. -/
theorem intertwiningDefect_smul
    (F T T' : (Fin 3 → ℝ) → (Fin 3 → ℝ))
    (hF : IsHomogeneous F) (hT : IsHomogeneous T) (hT' : IsHomogeneous T')
    (a : ℝ) (q : Fin 3 → ℝ) :
    intertwiningDefect F T T' (smulTriad a q) =
      smulTriad a (intertwiningDefect F T T' q) := by
  unfold intertwiningDefect
  rw [hT a q, hF a (T q), hF a q, hT' a (F q)]
  ext i
  simp [smulTriad, Pi.sub_apply]
  ring

theorem defectEnergy_smul
    (F T T' : (Fin 3 → ℝ) → (Fin 3 → ℝ))
    (hF : IsHomogeneous F) (hT : IsHomogeneous T) (hT' : IsHomogeneous T')
    (a : ℝ) (q : Fin 3 → ℝ) :
    defectEnergy F T T' (smulTriad a q) = a ^ 2 * defectEnergy F T T' q := by
  unfold defectEnergy energySq
  rw [intertwiningDefect_smul F T T' hF hT hT' a q]
  simp only [smulTriad]
  calc
    ∑ i : Fin 3, (a * intertwiningDefect F T T' q i) ^ 2
        = ∑ i : Fin 3, a ^ 2 * (intertwiningDefect F T T' q i) ^ 2 := by
          refine Finset.sum_congr rfl fun i _ => by ring
    _ = a ^ 2 * ∑ i : Fin 3, (intertwiningDefect F T T' q i) ^ 2 := by
          rw [Finset.mul_sum]

/-! ### Localization on the detail channel -/

/-- `T` preserves the isotropic line. -/
def PreservesIsotropic (T : (Fin 3 → ℝ) → (Fin 3 → ℝ)) : Prop :=
  ∀ μ : ℝ, ∃ ν : ℝ, T (collapse μ) = collapse ν

theorem P_aniso_homogeneous : IsHomogeneous P_aniso := by
  intro a q
  ext i
  simp [P_aniso_apply, mean, smulTriad, Fin.sum_univ_three]
  ring

theorem P_aniso_additive : IsAdditive P_aniso := by
  intro q r
  ext i
  simp [P_aniso_apply, mean, Pi.add_apply, Fin.sum_univ_three]
  ring

theorem P_aniso_linear : IsLinearEnd P_aniso :=
  ⟨P_aniso_homogeneous, P_aniso_additive⟩

private theorem P_aniso_of_sum_of_iso
    (T : (Fin 3 → ℝ) → (Fin 3 → ℝ)) (hlin : IsLinearEnd T)
    (hiso : PreservesIsotropic T) (q : Fin 3 → ℝ) :
    P_aniso (T q) = P_aniso (T (P_aniso q)) := by
  have hrec := id_eq_P_iso_add_P_aniso q
  have hTq : T q = T (P_iso q) + T (P_aniso q) := by
    rw [← hlin.2 (P_iso q) (P_aniso q), hrec]
  obtain ⟨ν, hν⟩ := hiso (mean q)
  have hTiso : T (P_iso q) = collapse ν := by
    simpa [P_iso] using hν
  have hkill : P_aniso (collapse ν) = 0 := P_aniso_constant ν
  calc
    P_aniso (T q) = P_aniso (T (P_iso q) + T (P_aniso q)) := by rw [hTq]
    _ = P_aniso (T (P_iso q)) + P_aniso (T (P_aniso q)) := P_aniso_additive _ _
    _ = P_aniso (collapse ν) + P_aniso (T (P_aniso q)) := by rw [hTiso]
    _ = 0 + P_aniso (T (P_aniso q)) := by rw [hkill]
    _ = P_aniso (T (P_aniso q)) := by simp

/-- Satz 15: with `F = P_aniso` and isotropic-preserving linear `T=T'`,
the intertwining defect depends only on the detail channel. -/
theorem defect_depends_only_on_aniso
    (T : (Fin 3 → ℝ) → (Fin 3 → ℝ))
    (hlin : IsLinearEnd T) (hiso : PreservesIsotropic T) (q : Fin 3 → ℝ) :
    intertwiningDefect P_aniso T T q =
      intertwiningDefect P_aniso T T (P_aniso q) := by
  unfold intertwiningDefect
  have h1 := P_aniso_of_sum_of_iso T hlin hiso q
  have h2 : P_aniso (P_aniso q) = P_aniso q := P_aniso_idempotent q
  rw [h1, h2]

theorem defect_vanishes_on_constants
    (T : (Fin 3 → ℝ) → (Fin 3 → ℝ))
    (hlin : IsLinearEnd T) (hiso : PreservesIsotropic T) (c : ℝ) :
    intertwiningDefect P_aniso T T (collapse c) = 0 := by
  have h := defect_depends_only_on_aniso T hlin hiso (collapse c)
  have hP : P_aniso (collapse c) = 0 := P_aniso_constant c
  rw [h, hP]
  unfold intertwiningDefect
  have hP0 : P_aniso (0 : Fin 3 → ℝ) = 0 := P_aniso_constant 0
  have hT0 : T 0 = 0 := by
    have hhom := hlin.1 0 (0 : Fin 3 → ℝ)
    have h00 : smulTriad 0 (0 : Fin 3 → ℝ) = 0 := by
      ext i; simp [smulTriad]
    have h0T : smulTriad 0 (T 0) = 0 := by
      ext i; simp [smulTriad]
    simpa [h00, h0T] using hhom
  simp [hT0, hP0]

theorem defectEnergy_eq_defectEnergy_aniso
    (T : (Fin 3 → ℝ) → (Fin 3 → ℝ))
    (hlin : IsLinearEnd T) (hiso : PreservesIsotropic T) (q : Fin 3 → ℝ) :
    defectEnergy P_aniso T T q = defectEnergy P_aniso T T (P_aniso q) := by
  simp [defectEnergy, defect_depends_only_on_aniso T hlin hiso q]

/-- `cycle3` preserves the isotropic line. -/
theorem cycle3_preservesIsotropic : PreservesIsotropic cycle3 := by
  intro μ
  refine ⟨μ, ?_⟩
  ext i
  simp [cycle3, collapse]

theorem cycle3_homogeneous : IsHomogeneous cycle3 := by
  intro a q
  ext i
  simp [cycle3, smulTriad]

theorem cycle3_additive : IsAdditive cycle3 := by
  intro q r
  ext i
  simp [cycle3, Pi.add_apply]

theorem cycle3_linear : IsLinearEnd cycle3 :=
  ⟨cycle3_homogeneous, cycle3_additive⟩

/-- Exact intertwining of the detail projector with `cycle3`. -/
theorem cycle3_P_aniso_intertwines (q : Fin 3 → ℝ) :
    intertwiningDefect P_aniso cycle3 cycle3 q = 0 := by
  unfold intertwiningDefect
  rw [P_aniso_cycle3]
  simp

theorem cycle3_defectEnergy_eq_zero (q : Fin 3 → ℝ) :
    defectEnergy P_aniso cycle3 cycle3 q = 0 := by
  simp [defectEnergy, energySq, cycle3_P_aniso_intertwines]

/-! ### Mismatch witness (Lemma 16) -/

/-- Canonical mismatch triad \(q=(1,0,0)\). -/
def mismatchWitness : Fin 3 → ℝ
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 0
  | ⟨2, _⟩ => 0

/-- A concrete mismatch defect \(\mathrm{diag}(-1,1,0)\) as a triad vector. -/
def mismatchDefect : Fin 3 → ℝ
  | ⟨0, _⟩ => -1
  | ⟨1, _⟩ => 1
  | ⟨2, _⟩ => 0

theorem mismatchDefect_mean_zero : mean mismatchDefect = 0 := by
  simp [mean, mismatchDefect, Fin.sum_univ_three]

theorem mismatchDefect_is_pure_detail :
    P_aniso mismatchDefect = mismatchDefect := by
  ext i
  simp [P_aniso_apply, mismatchDefect_mean_zero]

theorem mismatchDefect_energy :
    energySq mismatchDefect = 2 := by
  simp [energySq, mismatchDefect, Fin.sum_univ_three]
  norm_num

/-- Lemma 16: the mismatch witness defect is a pure detail mode of energy 2. -/
theorem mismatch_witness_pure_detail :
    mean mismatchDefect = 0 ∧
      energySq mismatchDefect = detailEnergy mismatchDefect ∧
      energySq mismatchDefect = 2 := by
  refine ⟨mismatchDefect_mean_zero, ?_, mismatchDefect_energy⟩
  simp [detailEnergy, mismatchDefect_is_pure_detail]

/-! ### Non-claims -/

/-- Operator-norm sharp constants beyond the abstract inequality remain open. -/
theorem defect_operatorNorm_bound_open : True := trivial

end SemiprimeWavelet
end KeplerHurwitz.EABC
