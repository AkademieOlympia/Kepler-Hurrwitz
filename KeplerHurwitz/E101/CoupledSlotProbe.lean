/-
  E-101.1 — Coupled Slot Probe (external consumer over E-101 CoreModel / E-100).

  Synchronously couples the five Kernmodell slots on shared coded inputs.
  Does **not** mutate E-100 (`mutates_e100 = false`).

  Upstream anchor: `E101.CoreModel.status`
  Schema: `e101_coupled_slot_probe.v1`
-/

import Mathlib.Tactic
import KeplerHurwitz.E101.CoreModel
import KeplerHurwitz.FiniteFactorTree.PipelineDynamicsAudit
import KeplerHurwitz.FiniteFactorTree.SemiprimeSymReconstruction
import KeplerHurwitz.EABC.CartanTwinRayAudit
import KeplerHurwitz.EABC.SemiprimeReconstruction

namespace KeplerHurwitz.E101
namespace CoupledSlotProbe

open CoreModel
open KeplerHurwitz.FiniteFactorTree
open KeplerHurwitz.FiniteFactorTree.PipelineDynamicsAudit
open KeplerHurwitz.FiniteFactorTree.CoefficientDynamics
open KeplerHurwitz.EABC

/-! ## Governance -/

def exportSchemaId : String := "e101_coupled_slot_probe.v1"
def upstreamAnchor : String := CoreModel.statusAnchor
def mutatesE100 : Bool := false

theorem mutates_e100_false : mutatesE100 = false := rfl

def consumes_core_model_status : CoreModel.Status := CoreModel.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  CoreModel.does_not_claim_factorization

theorem no_core_physics_claim : True := trivial

/-! ## Input / dynamics labels -/

inductive CarrierKind
  | B1
  | B2
  | Triad
  deriving DecidableEq, Repr

inductive Sym2Kind
  | channel
  | natWeights
  | notApplicable
  deriving DecidableEq, Repr

/-! ## Optional TwinRay payload (typed; never fake zeros) -/

inductive TwinRayField
  | notApplicable
  | present (audit : CartanTwinRayAudit.TwinRayAuditResult)

/-! ## Sym² audit summary -/

structure Sym2AuditSummary where
  kind : Sym2Kind
  unorderedMatch : Prop
  swapInvariant : Prop

/-! ## Coupled probe result -/

structure CoupledSlotProbeResult (d : ℕ) where
  carrier : CarrierKind
  mapLabel : AuditMapLabel
  detailEnergyIn : ℝ
  detailEnergyOut : ℝ
  energyDelta : ℝ
  centeringDefectEnergy : ℝ
  twinRay : TwinRayField
  sym2 : Sym2AuditSummary
  upstreamAnchor : String := upstreamAnchor
  mutatesE100 : Bool := false
  freezeE100 : String := CoreModel.e100FreezeAnchor

/-- Dynamics-only coupled probe (TwinRay optional, Sym² summary supplied). -/
noncomputable def runDynamicsProbe {d : ℕ}
    (carrier : CarrierKind)
    (label : AuditMapLabel)
    (track : ArithmeticSignalPipeline.PipelineTrack)
    (xs : LeafConfig d)
    (twinRay : TwinRayField)
    (sym2 : Sym2AuditSummary) :
    CoupledSlotProbeResult d :=
  let dyn := runDynamicsAudit label track xs
  { carrier := carrier
    mapLabel := label
    detailEnergyIn := dyn.inputDetailEnergy
    detailEnergyOut := dyn.outputDetailEnergy
    energyDelta := dyn.energyDelta
    centeringDefectEnergy := dyn.centeringDefectEnergy
    twinRay := twinRay
    sym2 := sym2 }

/-- Attach TwinRay audit when a triad is available. -/
noncomputable def withTwinRayNeg (qAB : Fin 3 → ℝ) : TwinRayField :=
  .present (CartanTwinRayAudit.runTwinRayAuditNeg qAB)

def twinRayNA : TwinRayField := .notApplicable

/-- Sym² channel summary from coded residual pair. -/
def sym2Channel (p : SemiprimeReconstruction.CodedResidualPair) : Sym2AuditSummary where
  kind := .channel
  unorderedMatch :=
    SemiprimeReconstruction.UnorderedEq
      (SemiprimeReconstruction.synthesize
        (SemiprimeReconstruction.analyze p)
        (SemiprimeReconstruction.analyze_isResidual p)) p
  swapInvariant :=
    SemiprimeReconstruction.analyze p.swap =
      SemiprimeReconstruction.analyze p

/-- Sym²(ℕ) summary under left-invertible weights. -/
def sym2Nat
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (_h_inv : ∀ n, w_inv (w n) = n)
    (pair : Sym2 ℕ) : Sym2AuditSummary where
  kind := .natWeights
  unorderedMatch :=
    SemiprimeSymReconstruction.synthesize w_inv
        (SemiprimeSymReconstruction.analyze w pair) = pair
  swapInvariant :=
    ∀ p q : ℕ, pair = s(p, q) →
      SemiprimeSymReconstruction.analyze w s(p, q) =
        SemiprimeSymReconstruction.analyze w s(q, p)

/-! ## Core theorems (E-101.1a / E-101.1b) -/

theorem coupledProbe_idMap_preservesDetailEnergy {d : ℕ}
    (carrier : CarrierKind)
    (track : ArithmeticSignalPipeline.PipelineTrack)
    (xs : LeafConfig d)
    (twinRay : TwinRayField)
    (sym2 : Sym2AuditSummary) :
    (runDynamicsProbe carrier .idMap track xs twinRay sym2).detailEnergyOut =
      (runDynamicsProbe carrier .idMap track xs twinRay sym2).detailEnergyIn :=
  audit_idMap_preserves_energy track xs

theorem coupledProbe_idMap_energyDelta_zero {d : ℕ}
    (carrier : CarrierKind)
    (track : ArithmeticSignalPipeline.PipelineTrack)
    (xs : LeafConfig d)
    (twinRay : TwinRayField)
    (sym2 : Sym2AuditSummary) :
    (runDynamicsProbe carrier .idMap track xs twinRay sym2).energyDelta = 0 := by
  simp [runDynamicsProbe, runDynamicsAudit, mapOfLabel, idMap]

theorem coupledProbe_collapse_zeroDetailEnergy {d : ℕ}
    (carrier : CarrierKind)
    (track : ArithmeticSignalPipeline.PipelineTrack)
    (xs : LeafConfig d)
    (hne : xs ≠ [])
    (twinRay : TwinRayField)
    (sym2 : Sym2AuditSummary) :
    (runDynamicsProbe carrier .collapseToMean track xs twinRay sym2).detailEnergyOut = 0 :=
  audit_collapseToMean_output_zero track xs hne

/-- TwinRay optional field: present neg-pair has vanishing deltas. -/
theorem twinRayNeg_deltas_zero (qAB : Fin 3 → ℝ) :
    let a := CartanTwinRayAudit.runTwinRayAuditNeg qAB
    a.deltaC2 = 0 ∧ a.deltaI2 = 0 ∧ a.deltaI3 = 0 :=
  CartanTwinRayAudit.auditNeg_deltas_zero qAB

theorem sym2Channel_unorderedMatch (p : SemiprimeReconstruction.CodedResidualPair) :
    (sym2Channel p).unorderedMatch :=
  SemiprimeReconstruction.synthesize_analyze_unordered p

theorem sym2Channel_swapInvariant (p : SemiprimeReconstruction.CodedResidualPair) :
    (sym2Channel p).swapInvariant :=
  SemiprimeReconstruction.analyze_swap p

theorem sym2Nat_unorderedMatch
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ n, w_inv (w n) = n)
    (pair : Sym2 ℕ) :
    (sym2Nat w w_inv h_inv pair).unorderedMatch :=
  SemiprimeSymReconstruction.reconstruction_sym2_identity w w_inv h_inv pair

theorem sym2Nat_swapInvariant
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ n, w_inv (w n) = n)
    (pair : Sym2 ℕ) :
    (sym2Nat w w_inv h_inv pair).swapInvariant := by
  intro p q hpq
  simpa [hpq] using SemiprimeSymReconstruction.analyze_swap_invariant w p q

/-! ## Non-claims -/

theorem probe_does_not_mutate_e100 : mutatesE100 = false := mutates_e100_false
theorem probe_no_factorization : True := trivial
theorem probe_no_physics : True := no_core_physics_claim

end CoupledSlotProbe
end KeplerHurwitz.E101
