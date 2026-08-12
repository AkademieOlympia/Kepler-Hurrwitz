/-
  [B] Arithmetic signal pipeline — *consumer* of the frozen factor-tree core.

  Does **not** modify:
    ClaimWall / HaarTreeCore / HaarTreeEnergy / LogFactorTree / EabcResidueTree.

  Defines typed input carriers for:
    [B1] prime-factor leaf lists → real weights → `Fin 1 → ℝ`
    [B2] unit-mod-12 residues → V₄ → character vectors → `Fin 2 → ℝ`

  Diagnostics / JSON schema live in Python
  (`src/kepler_hurwitz/finite_factor_tree_pipeline.py`).
-/

import KeplerHurwitz.EABC.V4
import KeplerHurwitz.FiniteFactorTree.ClaimWall
import KeplerHurwitz.FiniteFactorTree.EabcResidueTree
import KeplerHurwitz.FiniteFactorTree.LogFactorTree

namespace KeplerHurwitz.FiniteFactorTree
namespace ArithmeticSignalPipeline

open KeplerHurwitz.EABC
open ClaimWall

/-! ## Governance: freeze consumer -/

/-- This module only consumes `ClaimWall.status`; it does not extend the freeze. -/
theorem consumes_freeze_status : ClaimWall.Status :=
  ClaimWall.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  fun h => nomatch h

/-! ## [B1] input types -/

/-- Ordered multiset of positive prime-power factors (with multiplicity). -/
structure B1FactorLeaves where
  factors : List ℕ
  all_pos : ∀ n ∈ factors, 0 < n

/-- Abstract real weights on factor leaves (primary [B1] carrier). -/
structure B1WeightLeaves where
  weights : List ℝ

/-- Analytic specialization marker: weights come from `Real.log`. -/
structure B1LogLeaves where
  factors : List ℕ
  all_pos : ∀ n ∈ factors, 0 < n

/-- Embed abstract weights into analysis space \(V=\mathrm{Fin}\,1\to\mathbb R\). -/
def B1WeightLeaves.toAnalysis (L : B1WeightLeaves) : List (Fin 1 → ℝ) :=
  L.weights.map LogFactor.toLeaf

/-- Power-of-two length required for a balanced complete Haar tree. -/
def IsPowerOfTwoLength (n : ℕ) : Prop :=
  ∃ k : ℕ, n = 2 ^ k

/-- [B1] input is pipeline-ready when the leaf count is a positive power of two. -/
def B1WeightLeaves.IsReady (L : B1WeightLeaves) : Prop :=
  IsPowerOfTwoLength L.weights.length ∧ 0 < L.weights.length

/-! ## [B2] input types -/

/-- Ordered list of \(V_4\) channel labels (already projected from units mod 12). -/
structure B2ChannelLeaves where
  channels : List V4

/-- Embed channels into analysis space \(V=\mathrm{Fin}\,2\to\mathbb R\). -/
def B2ChannelLeaves.toAnalysis (L : B2ChannelLeaves) : List (Fin 2 → ℝ) :=
  L.channels.map EabcResidue.residueSignal

def B2ChannelLeaves.IsReady (L : B2ChannelLeaves) : Prop :=
  IsPowerOfTwoLength L.channels.length ∧ 0 < L.channels.length

/-- Project a natural number coprime to 6 to a pipeline channel leaf. -/
def channelOfUnit (n : ℕ) (h : Nat.Coprime n 6) : V4 :=
  toV4 n h

/-! ## Shared diagnostic payload markers (schema IDs) -/

/-- Stable schema id for JSON exports (Python must match). -/
def exportSchemaId : String :=
  "finite_factor_tree_pipeline.v1"

/-- Track tag for audits. -/
inductive PipelineTrack
  | B1_logWeights
  | B2_residueCharacters
  deriving DecidableEq, Repr

/-- Minimal report skeleton mirrored by the Python exporter. -/
structure PipelineReportSkeleton where
  schemaId : String := exportSchemaId
  track : PipelineTrack
  leafCount : ℕ
  totalDetailEnergy : ℝ
  centeredLeafEnergy : ℝ
  energyMatch : Prop
  freezeAnchor : String := "ClaimWall.status"

/-- Energy-match predicate: consumer check against the frozen variance identity. -/
def energiesMatch (detail centered : ℝ) : Prop :=
  detail = centered

theorem energiesMatch_of_freeze {d : ℕ}
    (t : BinTree (Fin d → ℝ)) (hb : t.IsBalanced) :
    energiesMatch (totalDetailEnergy t) (centeredLeafEnergy t) :=
  ClaimWall.master_identity_is_variance_in_V t hb

/-! ## Explicit non-claims of this consumer layer -/

theorem pipeline_no_factorization_algo : True := trivial
theorem pipeline_no_physical_energy : True := trivial
theorem pipeline_diagnostics_are_B_layer : True := trivial

end ArithmeticSignalPipeline
end KeplerHurwitz.FiniteFactorTree
