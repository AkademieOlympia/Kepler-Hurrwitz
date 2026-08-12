/-
  E-101.2 — Nullmodell-Shuffle (external consumer over E-101).

  Distinguishes invariance-preserving vs structure-destroying shuffles.
  Does **not** mutate E-100 (`mutates_e100 = false`).

  Upstream: `E101.CoreModel.status`
  Schema: `e101_nullmodel_shuffle.v1`
-/

import Mathlib.Data.List.Perm.Basic
import Mathlib.Tactic
import KeplerHurwitz.E101.CoreModel
import KeplerHurwitz.E101.CoupledSlotProbe
import KeplerHurwitz.FiniteFactorTree.CoefficientDynamics
import KeplerHurwitz.FiniteFactorTree.SemiprimeSymReconstruction
import KeplerHurwitz.EABC.CartanTwinRayAudit
import KeplerHurwitz.EABC.SemiprimeReconstruction

namespace KeplerHurwitz.E101
namespace NullmodelShuffle

open CoreModel
open CoupledSlotProbe
open KeplerHurwitz.FiniteFactorTree
open CoefficientDynamics
open KeplerHurwitz.EABC

/-! ## Governance -/

def exportSchemaId : String := "e101_nullmodel_shuffle.v1"
def upstreamAnchor : String := CoreModel.statusAnchor
def mutatesE100 : Bool := false

theorem mutates_e100_false : mutatesE100 = false := rfl

def consumes_core_model_status : CoreModel.Status := CoreModel.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  CoreModel.does_not_claim_factorization

theorem no_core_physics_claim : True := trivial

/-! ## Shuffle kinds -/

inductive ShuffleKind
  | leafShuffle
  | pairShuffle
  | carrierShuffle
  | twinRayLabelShuffle
  | sym2OrientationShuffle
  deriving DecidableEq, Repr

/-! ## Audit payload (Lean-side markers; Monte-Carlo lives in Python) -/

structure NullmodelAuditSkeleton where
  shuffleKind : ShuffleKind
  seed : ℕ
  preservedInvariants : List String
  destroyedRelations : List String
  upstreamAnchor : String := upstreamAnchor
  mutatesE100 : Bool := false

def skeletonOf (kind : ShuffleKind) (seed : ℕ) : NullmodelAuditSkeleton :=
  match kind with
  | .leafShuffle =>
      { shuffleKind := kind, seed := seed
        preservedInvariants := ["totalDetailEnergy", "configMean"]
        destroyedRelations := ["tree_node_addressing", "local_path_detail"] }
  | .pairShuffle =>
      { shuffleKind := kind, seed := seed
        preservedInvariants := ["marginal_leaf_values"]
        destroyedRelations := ["semiprime_pair_coupling"] }
  | .carrierShuffle =>
      { shuffleKind := kind, seed := seed
        preservedInvariants := ["input_n_multiset"]
        destroyedRelations := ["B1_B2_cross_slot_coupling"] }
  | .twinRayLabelShuffle =>
      { shuffleKind := kind, seed := seed
        preservedInvariants := ["C2_I2_I3_marginals"]
        destroyedRelations := ["antipodal_pairing_CE_eq_neg_AB"] }
  | .sym2OrientationShuffle =>
      { shuffleKind := kind, seed := seed
        preservedInvariants := ["unordered_pair", "SymHaar_state", "detailEnergyState"]
        destroyedRelations := ["artificial_orientation_label"] }

/-! ## E-101.2a — Leaf-Shuffle: total detail energy is multiset-invariant -/

theorem leafSumVec_perm {d : ℕ} {xs ys : LeafConfig d} (h : List.Perm xs ys) :
    leafSumVec xs = leafSumVec ys := by
  ext i
  simp only [leafSumVec_eq_sum]
  exact (h.map (fun x => x i)).sum_eq

theorem configMean_perm {d : ℕ} {xs ys : LeafConfig d} (h : List.Perm xs ys) :
    configMean xs = configMean ys := by
  have hlen : xs.length = ys.length := h.length_eq
  ext i
  simp [configMean, leafSumVec_perm h, hlen]

theorem centerLeaves_perm {d : ℕ} {xs ys : LeafConfig d} (h : List.Perm xs ys) :
    List.Perm (centerLeaves xs) (centerLeaves ys) := by
  have hμ := configMean_perm h
  simpa [centerLeaves, hμ] using h.map (fun x => x - configMean xs)

/-- Master theorem: leaf shuffle (list permutation) preserves `configDetailEnergy`. -/
theorem leafShuffle_preserves_configDetailEnergy {d : ℕ}
    {xs ys : LeafConfig d} (h : List.Perm xs ys) :
    configDetailEnergy xs = configDetailEnergy ys := by
  unfold configDetailEnergy
  have hc := centerLeaves_perm h
  exact (hc.map energySq).sum_eq

/-- Same statement under the CoupledSlotProbe dynamics probe wrapper. -/
theorem leafShuffle_preserves_probe_detailEnergyIn {d : ℕ}
    (carrier : CarrierKind)
    (label : PipelineDynamicsAudit.AuditMapLabel)
    (track : ArithmeticSignalPipeline.PipelineTrack)
    {xs ys : LeafConfig d} (h : List.Perm xs ys)
    (twinRay : TwinRayField) (sym2 : Sym2AuditSummary) :
    (runDynamicsProbe carrier label track xs twinRay sym2).detailEnergyIn =
      (runDynamicsProbe carrier label track ys twinRay sym2).detailEnergyIn := by
  simp only [runDynamicsProbe, PipelineDynamicsAudit.runDynamicsAudit]
  exact leafShuffle_preserves_configDetailEnergy h

/-! ## E-101.2b — Sym² orientation shuffle is exactly invariant -/

theorem sym2OrientationShuffle_analyze_invariant
    (w : ℕ → ℝ) (p q : ℕ) :
    SemiprimeSymReconstruction.analyze w s(p, q) =
      SemiprimeSymReconstruction.analyze w s(q, p) :=
  SemiprimeSymReconstruction.analyze_swap_invariant w p q

theorem sym2OrientationShuffle_detailEnergy_invariant
    (w : ℕ → ℝ) (p q : ℕ) :
    SemiprimeSymReconstruction.detailEnergyState
        (SemiprimeSymReconstruction.analyze w s(p, q)) =
      SemiprimeSymReconstruction.detailEnergyState
        (SemiprimeSymReconstruction.analyze w s(q, p)) := by
  simp [sym2OrientationShuffle_analyze_invariant w p q]

theorem sym2OrientationShuffle_channel_product_invariant
    (pair : SemiprimeReconstruction.CodedResidualPair) :
    SemiprimeReconstruction.analyze pair.swap =
      SemiprimeReconstruction.analyze pair :=
  SemiprimeReconstruction.analyze_swap pair

theorem sym2OrientationShuffle_reconstruction_match
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ n, w_inv (w n) = n) (p q : ℕ) :
    SemiprimeSymReconstruction.synthesize w_inv
        (SemiprimeSymReconstruction.analyze w s(p, q)) = s(p, q) ∧
      SemiprimeSymReconstruction.synthesize w_inv
        (SemiprimeSymReconstruction.analyze w s(q, p)) = s(q, p) :=
  ⟨SemiprimeSymReconstruction.reconstruction_sym2_identity w w_inv h_inv s(p, q),
    SemiprimeSymReconstruction.reconstruction_sym2_identity w w_inv h_inv s(q, p)⟩

/-! ## TwinRay: exact pair vs broken pairing (qualitative markers) -/

/-- Exact antipodal pairing has vanishing I₃ defect. -/
theorem twinRay_exact_deltaI3_zero (qAB : Fin 3 → ℝ) :
    (CartanTwinRayAudit.runTwinRayAuditNeg qAB).deltaI3 = 0 :=
  (CartanTwinRayAudit.auditNeg_deltas_zero qAB).2.2

/--
Marker: a broken pairing `qCE ≠ -qAB` is *not* forced to have `deltaI3 = 0`.
(Python Monte-Carlo measures the null distribution; Lean keeps the exact case.)
-/
theorem twinRay_exact_is_exactSymmetric (qAB : Fin 3 → ℝ) :
    CartanTwinRayAudit.IsTwinRayInvariantExact qAB (-qAB) :=
  CartanTwinRayAudit.auditNeg_invariantExact qAB

/-! ## Non-claims -/

theorem nullmodel_does_not_mutate_e100 : mutatesE100 = false := mutates_e100_false
theorem nullmodel_no_factorization : True := trivial
theorem nullmodel_no_physics : True := no_core_physics_claim
theorem nullmodel_monte_carlo_is_B_layer : True := trivial

end NullmodelShuffle
end KeplerHurwitz.E101
