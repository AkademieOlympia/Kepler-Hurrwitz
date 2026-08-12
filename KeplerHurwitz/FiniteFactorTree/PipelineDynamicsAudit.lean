/-
  Bridge consumer: ArithmeticSignalPipeline → LeafMap T → CoefficientDynamics audit.

  Composes two sealed consumers; does **not** modify
    ClaimWall / HaarTree* / LogFactorTree / EabcResidueTree /
    ArithmeticSignalPipeline / CoefficientDynamics cores beyond import.
-/

import Mathlib.Tactic
import KeplerHurwitz.FiniteFactorTree.ArithmeticSignalPipeline
import KeplerHurwitz.FiniteFactorTree.CoefficientDynamics

namespace KeplerHurwitz.FiniteFactorTree
namespace PipelineDynamicsAudit

open ArithmeticSignalPipeline
open CoefficientDynamics

/-! ## Freeze consumer marker -/

theorem consumes_freeze_status : ClaimWall.Status := ClaimWall.status

/-- Stable schema id for JSON audits (Python must match). -/
def exportSchemaId : String :=
  "finite_factor_tree_pipeline_dynamics_audit.v1"

/-! ## Audit payload -/

/-- Named reference maps whose class properties are proved in CoefficientDynamics. -/
inductive AuditMapLabel
  | idMap
  | collapseToMean
  deriving DecidableEq, Repr

/-- Pointwise energy / defect audit of `T` on a pipeline-produced leaf config. -/
structure DynamicsAuditResult (d : ℕ) where
  track : PipelineTrack
  mapLabel : AuditMapLabel
  inputConfig : LeafConfig d
  outputConfig : LeafConfig d
  inputDetailEnergy : ℝ
  outputDetailEnergy : ℝ
  energyDelta : ℝ
  centeringDefectEnergy : ℝ
  freezeAnchor : String := "ClaimWall.status"

/-- Resolve a reference label to a length-preserving leaf map. -/
noncomputable def mapOfLabel (d : ℕ) : AuditMapLabel → LeafMap d
  | .idMap => idMap d
  | .collapseToMean => collapseToMean d

/-- Core composition: config → `T` → energy / defect audit record. -/
noncomputable def runDynamicsAudit {d : ℕ}
    (label : AuditMapLabel) (track : PipelineTrack) (xs : LeafConfig d) :
    DynamicsAuditResult d :=
  let T := mapOfLabel d label
  let yout := T.toFun xs
  let ein := configDetailEnergy xs
  let eout := configDetailEnergy yout
  { track := track
    mapLabel := label
    inputConfig := xs
    outputConfig := yout
    inputDetailEnergy := ein
    outputDetailEnergy := eout
    energyDelta := ein - eout
    centeringDefectEnergy := centeringDefectEnergy T xs }

/-- [B1] bridge: weight leaves → analysis config → audit. -/
noncomputable def auditFromB1 (label : AuditMapLabel) (L : B1WeightLeaves) :
    DynamicsAuditResult 1 :=
  runDynamicsAudit label .B1_logWeights L.toAnalysis

/-- [B2] bridge: channel leaves → analysis config → audit. -/
noncomputable def auditFromB2 (label : AuditMapLabel) (L : B2ChannelLeaves) :
    DynamicsAuditResult 2 :=
  runDynamicsAudit label .B2_residueCharacters L.toAnalysis

/-! ## Classification witnesses (Lean-side; Python only mirrors) -/

structure MapClassWitness (d : ℕ) (T : LeafMap d) : Prop where
  waveletExact : IsWaveletExact T
  energyExact : IsEnergyExact T ∨ ¬ IsEnergyExact T
  controlled : ∃ C : ℝ, IsControlled T C
  asymptoticallyCollapsing : IsAsymptoticallyCollapsing T ∨ ¬ IsAsymptoticallyCollapsing T

theorem idMap_classWitness (d : ℕ) : MapClassWitness d (idMap d) where
  waveletExact := idMap_waveletExact d
  energyExact := Or.inl (idMap_energyExact d)
  controlled := ⟨1, idMap_controlled d⟩
  asymptoticallyCollapsing := Classical.em _

private theorem sum_sub_const_coord {d : ℕ} (xs : LeafConfig d) (μ : Fin d → ℝ) (j : Fin d) :
    (xs.map fun x => (x - μ) j).sum =
      (xs.map fun x => x j).sum - (xs.length : ℝ) * μ j := by
  induction xs with
  | nil => simp
  | cons x xs ih =>
    calc
      ((x :: xs).map fun y => (y - μ) j).sum
          = (x - μ) j + (xs.map fun y => (y - μ) j).sum := by simp
      _ = x j - μ j + ((xs.map fun y => y j).sum - (xs.length : ℝ) * μ j) := by
            rw [Pi.sub_apply, ih]
      _ = x j + (xs.map fun y => y j).sum - ((xs.length : ℝ) + 1) * μ j := by ring
      _ = ((x :: xs).map fun y => y j).sum - ((x :: xs).length : ℝ) * μ j := by
            simp [add_comm (xs.length : ℝ)]

private theorem configMean_centerLeaves {d : ℕ} (xs : LeafConfig d) (hne : xs ≠ []) :
    configMean (centerLeaves xs) = 0 := by
  have hpos : 0 < xs.length := List.length_pos_of_ne_nil hne
  have hlen : (xs.length : ℝ) ≠ 0 := by exact_mod_cast (ne_of_gt hpos)
  ext j
  have hsum : leafSumVec (centerLeaves xs) j = 0 := by
    simp only [leafSumVec_eq_sum, centerLeaves, List.map_map, Function.comp_def]
    rw [sum_sub_const_coord xs (configMean xs) j]
    simp [configMean, ← leafSumVec_eq_sum]
    field_simp [hlen]
    ring
  have hlenC : (centerLeaves xs).length = xs.length := by simp [centerLeaves]
  simp [configMean, hsum, hlenC]

theorem collapseToMean_waveletExact (d : ℕ) : IsWaveletExact (collapseToMean d) := by
  intro xs hne
  have hpos : 0 < xs.length := List.length_pos_of_ne_nil hne
  have hμ := configMean_replicate xs.length hpos (configMean xs)
  have hL :
      centerLeaves ((collapseToMean d).toFun xs) =
        List.replicate xs.length (0 : Fin d → ℝ) := by
    unfold centerLeaves collapseToMean
    simp [hμ, sub_self, List.map_replicate]
  have hR :
      (collapseToMean d).toFun (centerLeaves xs) =
        List.replicate xs.length (0 : Fin d → ℝ) := by
    unfold collapseToMean
    have hlenC : (centerLeaves xs).length = xs.length := by simp [centerLeaves]
    simp [configMean_centerLeaves xs hne, hlenC]
  rw [hL, hR]

theorem collapseToMean_classWitness (d : ℕ) :
    MapClassWitness d (collapseToMean d) where
  waveletExact := collapseToMean_waveletExact d
  energyExact := Classical.em _
  controlled := ⟨0, collapseToMean_controlled_zero⟩
  asymptoticallyCollapsing := Or.inl collapseToMean_asymptoticallyCollapsing

theorem classWitness_ofLabel (d : ℕ) (label : AuditMapLabel) :
    MapClassWitness d (mapOfLabel d label) := by
  cases label with
  | idMap => exact idMap_classWitness d
  | collapseToMean => exact collapseToMean_classWitness d

/-! ## Energy identities on audits -/

theorem audit_idMap_preserves_energy {d : ℕ} (track : PipelineTrack) (xs : LeafConfig d) :
    (runDynamicsAudit .idMap track xs).outputDetailEnergy =
      (runDynamicsAudit .idMap track xs).inputDetailEnergy := by
  simp [runDynamicsAudit, mapOfLabel, idMap]

theorem audit_collapseToMean_output_zero {d : ℕ} (track : PipelineTrack)
    (xs : LeafConfig d) (hne : xs ≠ []) :
    (runDynamicsAudit .collapseToMean track xs).outputDetailEnergy = 0 := by
  simp [runDynamicsAudit, mapOfLabel, collapseToMean_detail_zero xs hne]

theorem audit_idMap_defect_zero {d : ℕ} (track : PipelineTrack)
    (xs : LeafConfig d) (hne : xs ≠ []) :
    (runDynamicsAudit .idMap track xs).centeringDefectEnergy = 0 :=
  waveletExact_defectEnergy_eq_zero (idMap d) (idMap_waveletExact d) xs hne

/-- Freeze link: audit input energy is the frozen centered-leaf variance on any tree. -/
theorem audit_input_eq_centeredLeafEnergy {d : ℕ}
    (label : AuditMapLabel) (track : PipelineTrack) (t : BinTree (Fin d → ℝ)) :
    (runDynamicsAudit label track t.leaves).inputDetailEnergy = centeredLeafEnergy t := by
  simp [runDynamicsAudit, configDetailEnergy_eq_centeredLeafEnergy]

theorem auditFromB1_input_eq_configDetail (label : AuditMapLabel) (L : B1WeightLeaves) :
    (auditFromB1 label L).inputDetailEnergy = configDetailEnergy L.toAnalysis := by
  simp [auditFromB1, runDynamicsAudit]

theorem auditFromB2_input_eq_configDetail (label : AuditMapLabel) (L : B2ChannelLeaves) :
    (auditFromB2 label L).inputDetailEnergy = configDetailEnergy L.toAnalysis := by
  simp [auditFromB2, runDynamicsAudit]

/-! ## Non-claims -/

theorem bridge_no_factorization_claim : True := trivial
theorem bridge_no_new_energy_claim : True := trivial
theorem bridge_does_not_modify_freeze : True := trivial

end PipelineDynamicsAudit
end KeplerHurwitz.FiniteFactorTree
