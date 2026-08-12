/-
  [A]-consumer: TwinRay / Cartan-(C₂,I₂,I₃) audit.

  Consumes SemiprimeWavelet Cartan + FiniteFactorTree ClaimWall.status.
  Does **not** modify SemiprimeWavelet* / ClaimWall / PipelineDynamics cores.

  For a pair (qAB, qCE), audits even invariance of C₂,I₂ and odd sign-reversal of I₃.
  Exact TwinRay means qCE = -qAB (central inversion on the triad).
-/

import Mathlib.Tactic
import KeplerHurwitz.EABC.SemiprimeWaveletCartan
import KeplerHurwitz.FiniteFactorTree.ClaimWall

namespace KeplerHurwitz.EABC
namespace CartanTwinRayAudit

open SemiprimeWavelet
open KeplerHurwitz.FiniteFactorTree

/-! ## Freeze / schema markers -/

theorem consumes_freeze_status : ClaimWall.Status := ClaimWall.status

def exportSchemaId : String :=
  "cartan_twinray_audit.v1"

/-! ## Invariant triple -/

structure CartanInvariants where
  C2 : ℝ
  I2 : ℝ
  I3 : ℝ

noncomputable def invariantsOf (q : Fin 3 → ℝ) : CartanInvariants where
  C2 := C2 q
  I2 := I2 q
  I3 := I3 q

/-! ## Exactness predicates -/

/-- Central TwinRay inversion on the triad. -/
def IsTwinRayExact (qAB qCE : Fin 3 → ℝ) : Prop :=
  qCE = -qAB

/-- Even Cartan invariants match. -/
def IsEvenInvariantExact (qAB qCE : Fin 3 → ℝ) : Prop :=
  C2 qCE = C2 qAB ∧ I2 qCE = I2 qAB

/-- Cubic invariant flips sign. -/
def IsOddSignReversing (qAB qCE : Fin 3 → ℝ) : Prop :=
  I3 qCE = -I3 qAB

/-- Full invariant TwinRay package (even exact + odd reversing). -/
def IsTwinRayInvariantExact (qAB qCE : Fin 3 → ℝ) : Prop :=
  IsEvenInvariantExact qAB qCE ∧ IsOddSignReversing qAB qCE

/-! ## Classification labels (Python decides numerically; Lean uses Prop flags) -/

inductive TwinRayClass
  | exactSymmetric
  | evenDefect
  | oddDefect
  | totalDefect
  deriving DecidableEq, Repr

/-- Class from Boolean flags (Python / concrete witnesses). -/
def twinRayClassOfBool (evenExact oddExact : Bool) : TwinRayClass :=
  match evenExact, oddExact with
  | true, true => .exactSymmetric
  | true, false => .oddDefect
  | false, true => .evenDefect
  | false, false => .totalDefect

/-! ## Audit payload -/

structure TwinRayAuditResult where
  invariantsAB : CartanInvariants
  invariantsCE : CartanInvariants
  deltaC2 : ℝ
  deltaI2 : ℝ
  deltaI3 : ℝ
  freezeAnchor : String := "ClaimWall.status"

noncomputable def runTwinRayAudit (qAB qCE : Fin 3 → ℝ) : TwinRayAuditResult where
  invariantsAB := invariantsOf qAB
  invariantsCE := invariantsOf qCE
  deltaC2 := |C2 qCE - C2 qAB|
  deltaI2 := |I2 qCE - I2 qAB|
  deltaI3 := |I3 qCE + I3 qAB|

/-- Canonical exact TwinRay pair from a single triad. -/
noncomputable def runTwinRayAuditNeg (qAB : Fin 3 → ℝ) : TwinRayAuditResult :=
  runTwinRayAudit qAB (-qAB)

/-! ## Algebraic TwinRay theorems (consume sealed Cartan lemmas) -/

theorem twinRay_I2_eq (qAB : Fin 3 → ℝ) :
    I2 (-qAB) = I2 qAB := by
  simp [I2, twinRay_C2_eq]

theorem twinRayExact_implies_even (qAB qCE : Fin 3 → ℝ)
    (h : IsTwinRayExact qAB qCE) :
    IsEvenInvariantExact qAB qCE := by
  rw [IsTwinRayExact] at h
  subst h
  exact ⟨twinRay_C2_eq qAB, twinRay_I2_eq qAB⟩

theorem twinRayExact_implies_odd (qAB qCE : Fin 3 → ℝ)
    (h : IsTwinRayExact qAB qCE) :
    IsOddSignReversing qAB qCE := by
  rw [IsTwinRayExact] at h
  subst h
  exact twinRay_I3_neg qAB

theorem twinRayExact_implies_invariantExact (qAB qCE : Fin 3 → ℝ)
    (h : IsTwinRayExact qAB qCE) :
    IsTwinRayInvariantExact qAB qCE :=
  ⟨twinRayExact_implies_even qAB qCE h, twinRayExact_implies_odd qAB qCE h⟩

theorem twinRayNeg_evenExact (qAB : Fin 3 → ℝ) :
    IsEvenInvariantExact qAB (-qAB) :=
  twinRayExact_implies_even qAB (-qAB) rfl

theorem twinRayNeg_oddExact (qAB : Fin 3 → ℝ) :
    IsOddSignReversing qAB (-qAB) :=
  twinRayExact_implies_odd qAB (-qAB) rfl

theorem auditNeg_deltas_zero (qAB : Fin 3 → ℝ) :
    (runTwinRayAuditNeg qAB).deltaC2 = 0 ∧
      (runTwinRayAuditNeg qAB).deltaI2 = 0 ∧
      (runTwinRayAuditNeg qAB).deltaI3 = 0 := by
  simp [runTwinRayAuditNeg, runTwinRayAudit, twinRay_C2_eq, twinRay_I2_eq, twinRay_I3_neg,
    abs_zero]

theorem auditNeg_invariantExact (qAB : Fin 3 → ℝ) :
    IsTwinRayInvariantExact qAB (-qAB) :=
  twinRayExact_implies_invariantExact qAB (-qAB) rfl

theorem auditNeg_classBool_exactSymmetric :
    twinRayClassOfBool true true = .exactSymmetric := rfl

/-- Detail energy of each ray equals Cartan C₂ (sealed [A] identity). -/
theorem audit_C2_eq_detailEnergy (qAB qCE : Fin 3 → ℝ) :
    (runTwinRayAudit qAB qCE).invariantsAB.C2 = detailEnergy qAB ∧
      (runTwinRayAudit qAB qCE).invariantsCE.C2 = detailEnergy qCE := by
  simp [runTwinRayAudit, invariantsOf, detailEnergy_eq_C2]

/-! ## Non-claims -/

theorem twinray_audit_no_lie_dynamics : True := trivial
theorem twinray_audit_no_factorization : True := trivial
theorem twinray_audit_does_not_modify_freeze : True := trivial

end CartanTwinRayAudit
end KeplerHurwitz.EABC
