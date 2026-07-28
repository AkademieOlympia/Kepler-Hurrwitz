/-
  E-101.8 — Dirac-like Audit Operator (external consumer).

  Applies E-101.5 Dirac-picture governance to E-101.7 Core/Shell/Valence
  as a finite real 2x2 audit model (not a physical Dirac equation):

    D_101 = Λ I + μ σ₃ + g σ₁
    λ± = Λ ± √(C₂ + G₁₀₁ K²)

  Schema: e101_dirac_like_audit.v1
-/

import Mathlib.Tactic
import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Real.Basic
import KeplerHurwitz.E101.CoreModel
import KeplerHurwitz.E101.ConstantNomenclature
import KeplerHurwitz.E101.CoreShellValence
import KeplerHurwitz.E101.DiracPictureGovernance
import KeplerHurwitz.E101.AnalogyProbe
import KeplerHurwitz.FiniteFactorTree.ClaimWall
import KeplerHurwitz.EABC.SemiprimeWaveletCartan

namespace KeplerHurwitz.E101
namespace DiracLikeAudit

open CoreModel
open ConstantNomenclature
open CoreShellValence
open Matrix
open KeplerHurwitz.FiniteFactorTree
open ClaimWall
open KeplerHurwitz.EABC
open SemiprimeWavelet

/-! ## Governance -/

def exportSchemaId : String := "e101_dirac_like_audit.v1"
def upstreamAnchor : String := CoreModel.statusAnchor
def mutatesE100 : Bool := false
def mappingLevel : String := "dirac_like_audit_C"

theorem mutates_e100_false : mutatesE100 = false := rfl

def consumes_core_model_status : CoreModel.Status := CoreModel.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  CoreModel.does_not_claim_factorization

def isExternalConsumer : Bool := true
theorem isExternalConsumer_true : isExternalConsumer = true := rfl

/-! ## Final freeze status (passive audit consumer) -/

/--
E-101.8 final status: read-only audit consumer over sealed upstream.
Does not mutate E-100 / Cartan / Parseval cores.
-/
structure FinalAuditConsumerStatus where
  schemaId : String := exportSchemaId
  passiveAuditConsumer : Bool := true
  mutatesUpstreamCores : Bool := false
  sealedAsResearchAuditInfrastructure : Bool := true
  validatedPhysicalModel : Bool := false
  auditDoubletIsDiracEquation : Bool := false
  auditGapIsRestMass : Bool := false
  auditGapIsMaterialBandGap : Bool := false
  valenceIsPhysicalGaugeCoupling : Bool := false
  masterFormula : String :=
    "lambda_pm = Lambda101 +/- sqrt(C2 + G101 K^2)"

def finalAuditConsumerStatus : FinalAuditConsumerStatus := {}

theorem final_audit_consumer_sealed :
    finalAuditConsumerStatus.passiveAuditConsumer = true ∧
      finalAuditConsumerStatus.mutatesUpstreamCores = false ∧
      finalAuditConsumerStatus.sealedAsResearchAuditInfrastructure = true ∧
      finalAuditConsumerStatus.validatedPhysicalModel = false ∧
      finalAuditConsumerStatus.auditDoubletIsDiracEquation = false ∧
      finalAuditConsumerStatus.auditGapIsRestMass = false :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl⟩

/-! ## No-Gos -/

def physicalDiracEquation : Bool := false
def relativisticFermion : Bool := false
def spinHalfClaim : Bool := false
def antiparticleClaim : Bool := false
def physicalMassGap : Bool := false
def materialBandGap : Bool := false
def diracSeaClaim : Bool := false
def zitterbewegungClaim : Bool := false
def planckQuantumClaim : Bool := false
def lightSpeedClaim : Bool := false
def atomicShellFromSpectrum : Bool := false
def particleEnergyFromEigenvalue : Bool := false

theorem physicalDiracEquation_false : physicalDiracEquation = false := rfl
theorem physicalMassGap_false : physicalMassGap = false := rfl
theorem materialBandGap_false : materialBandGap = false := rfl
theorem particleEnergyFromEigenvalue_false :
    particleEnergyFromEigenvalue = false := rfl
theorem spinHalfClaim_false : spinHalfClaim = false := rfl

/-! ## Coupling, gap, spectrum branches -/

/-- Off-diagonal valence coupling \(g_{101}=\sqrt{G_{101}}\,K\). -/
noncomputable def g101 (cfg : E101ConstantNomenclature) (K : ℝ) : ℝ :=
  Real.sqrt cfg.G101 * K

theorem g101_sq (cfg : E101ConstantNomenclature) (K : ℝ) :
    (g101 cfg K) ^ 2 = cfg.G101 * K ^ 2 := by
  simp [g101, mul_pow, Real.sq_sqrt cfg.G101_nonneg]

/-- Half-gap \(s=\sqrt{C_2+G_{101}K^2}\). -/
noncomputable def gapHalf
    (cfg : E101ConstantNomenclature) (C2 K : ℝ) : ℝ :=
  Real.sqrt (C2 + cfg.G101 * K ^ 2)

theorem gapHalf_sq
    (cfg : E101ConstantNomenclature) {C2 K : ℝ} (hC2 : 0 ≤ C2) :
    (gapHalf cfg C2 K) ^ 2 = C2 + cfg.G101 * K ^ 2 := by
  have h : 0 ≤ C2 + cfg.G101 * K ^ 2 :=
    add_nonneg hC2 (mul_nonneg cfg.G101_nonneg (sq_nonneg K))
  simpa [gapHalf] using Real.sq_sqrt h

/-- Audit gap \(\Delta_{101}=2s\). -/
noncomputable def auditGap
    (cfg : E101ConstantNomenclature) (C2 K : ℝ) : ℝ :=
  2 * gapHalf cfg C2 K

noncomputable def lambdaPlus
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) : ℝ :=
  Λ + gapHalf cfg C2 K

noncomputable def lambdaMinus
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) : ℝ :=
  Λ - gapHalf cfg C2 K

theorem auditGap_eq_branch_diff
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) :
    auditGap cfg C2 K =
      lambdaPlus cfg Λ C2 K - lambdaMinus cfg Λ C2 K := by
  unfold auditGap lambdaPlus lambdaMinus
  ring

theorem spectrum_inversion_even
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) :
    lambdaPlus cfg Λ C2 (-K) = lambdaPlus cfg Λ C2 K ∧
      lambdaMinus cfg Λ C2 (-K) = lambdaMinus cfg Λ C2 K := by
  constructor <;> simp [lambdaPlus, lambdaMinus, gapHalf]

/-! ## 2×2 matrix and eigenrelations -/

def sigma1 : Matrix (Fin 2) (Fin 2) ℝ := ![![0, 1], ![1, 0]]
def sigma3 : Matrix (Fin 2) (Fin 2) ℝ := ![![1, 0], ![0, -1]]

noncomputable def diracLikeMatrix (Λ μ g : ℝ) : Matrix (Fin 2) (Fin 2) ℝ :=
  ![![Λ + μ, g], ![g, Λ - μ]]

theorem diracLikeMatrix_as_pauli (Λ μ g : ℝ) :
    diracLikeMatrix Λ μ g =
      Λ • (1 : Matrix (Fin 2) (Fin 2) ℝ) + μ • sigma3 + g • sigma1 := by
  ext i j
  fin_cases i <;> fin_cases j <;>
    simp [diracLikeMatrix, sigma1, sigma3, Matrix.smul_apply]
  all_goals ring

theorem diracLike_eigen_plus
    (Λ μ g : ℝ) (hs : 0 ≤ μ ^ 2 + g ^ 2) :
    let s := Real.sqrt (μ ^ 2 + g ^ 2)
    diracLikeMatrix Λ μ g *ᵥ ![μ + s, g] = (Λ + s) • ![μ + s, g] := by
  intro s
  have hs' : s ^ 2 = μ ^ 2 + g ^ 2 := Real.sq_sqrt hs
  ext i
  fin_cases i <;>
    simp [diracLikeMatrix, Matrix.mulVec, Fin.sum_univ_two, Pi.smul_apply,
      smul_eq_mul]
  · nlinarith [hs']
  · ring

theorem diracLike_eigen_minus
    (Λ μ g : ℝ) (hs : 0 ≤ μ ^ 2 + g ^ 2) :
    let s := Real.sqrt (μ ^ 2 + g ^ 2)
    diracLikeMatrix Λ μ g *ᵥ ![g, -(μ + s)] = (Λ - s) • ![g, -(μ + s)] := by
  intro s
  have hs' : s ^ 2 = μ ^ 2 + g ^ 2 := Real.sq_sqrt hs
  ext i
  fin_cases i <;>
    simp [diracLikeMatrix, Matrix.mulVec, Fin.sum_univ_two, Pi.smul_apply,
      smul_eq_mul]
  · ring
  · nlinarith [hs']

/-! ## Master spectral doublet -/

private theorem gap_eq_sqrt_mu_sq_g_sq
    (cfg : E101ConstantNomenclature) {C2 K : ℝ} (hC2 : 0 ≤ C2) :
    gapHalf cfg C2 K =
      Real.sqrt ((Real.sqrt C2) ^ 2 + (g101 cfg K) ^ 2) := by
  rw [gapHalf, Real.sq_sqrt hC2, g101_sq]

/--
Core–Shell–Valence Spectral Doublet:
\(\operatorname{spec}(D)=\{\Lambda\pm\sqrt{C_2+G K^2}\}\) via explicit eigenvectors.
-/
theorem core_shell_valence_spectral_doublet
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) (hC2 : 0 ≤ C2) :
    let μ := Real.sqrt C2
    let g := g101 cfg K
    let s := gapHalf cfg C2 K
    μ ^ 2 = C2 ∧
      g ^ 2 = cfg.G101 * K ^ 2 ∧
      s ^ 2 = C2 + cfg.G101 * K ^ 2 ∧
      diracLikeMatrix Λ μ g *ᵥ ![μ + s, g] = (Λ + s) • ![μ + s, g] ∧
      diracLikeMatrix Λ μ g *ᵥ ![g, -(μ + s)] = (Λ - s) • ![g, -(μ + s)] := by
  intro μ g s
  have hμ : μ ^ 2 = C2 := Real.sq_sqrt hC2
  have hg : g ^ 2 = cfg.G101 * K ^ 2 := g101_sq cfg K
  have hs0 : 0 ≤ μ ^ 2 + g ^ 2 := by
    rw [hμ, hg]
    exact add_nonneg hC2 (mul_nonneg cfg.G101_nonneg (sq_nonneg K))
  have hs : s ^ 2 = C2 + cfg.G101 * K ^ 2 := gapHalf_sq cfg hC2
  have hs' : s = Real.sqrt (μ ^ 2 + g ^ 2) := gap_eq_sqrt_mu_sq_g_sq cfg hC2
  refine ⟨hμ, hg, hs, ?_, ?_⟩
  · simpa [hs'] using diracLike_eigen_plus Λ μ g hs0
  · simpa [hs'] using diracLike_eigen_minus Λ μ g hs0

theorem lambda_eq_eigenvalues
    (cfg : E101ConstantNomenclature) (Λ C2 K : ℝ) :
    lambdaPlus cfg Λ C2 K = Λ + gapHalf cfg C2 K ∧
      lambdaMinus cfg Λ C2 K = Λ - gapHalf cfg C2 K :=
  ⟨rfl, rfl⟩

/-! ## Orientation companion -/

noncomputable def orientationLabel (q : Fin 3 → ℝ) : ℝ :=
  Real.sign (I3 q)

theorem orientation_odd_under_neg (q : Fin 3 → ℝ) :
    I3 (-q) = -I3 q :=
  AnalogyProbe.i3_is_orientationOdd q

/-! ## Regimes -/

inductive SpectralRegime
  | fullyClosed
  | pureShell
  | pureValence
  | coupled
  deriving DecidableEq, Repr

noncomputable def classifyRegime (C2 K : ℝ) : SpectralRegime :=
  if C2 = 0 ∧ K = 0 then .fullyClosed
  else if K = 0 then .pureShell
  else if C2 = 0 then .pureValence
  else .coupled

theorem regime_fullyClosed_degenerate
    (cfg : E101ConstantNomenclature) (Λ : ℝ) :
    lambdaPlus cfg Λ 0 0 = Λ ∧ lambdaMinus cfg Λ 0 0 = Λ := by
  simp [lambdaPlus, lambdaMinus, gapHalf]

theorem regime_pureShell
    (cfg : E101ConstantNomenclature) (Λ C2 : ℝ) :
    lambdaPlus cfg Λ C2 0 = Λ + Real.sqrt C2 ∧
      lambdaMinus cfg Λ C2 0 = Λ - Real.sqrt C2 := by
  simp [lambdaPlus, lambdaMinus, gapHalf]

theorem regime_pureValence
    (cfg : E101ConstantNomenclature) (Λ K : ℝ) :
    lambdaPlus cfg Λ 0 K = Λ + Real.sqrt (cfg.G101 * K ^ 2) ∧
      lambdaMinus cfg Λ 0 K = Λ - Real.sqrt (cfg.G101 * K ^ 2) := by
  simp [lambdaPlus, lambdaMinus, gapHalf]

/-! ## Role dictionary + master shield -/

def roleCore : String := "spectral_center_bulk_offset"
def roleShell : String := "diagonal_gap_amplitude"
def roleValence : String := "off_diagonal_mixing"
def roleI3 : String := "orientation_odd_companion"

/--
Bulk sets the center; shell and valence set the gap; I₃ sets orientation.
No physical Dirac / mass-gap / particle-energy claim.
-/
theorem master_reading_shield :
    roleCore = "spectral_center_bulk_offset" ∧
      roleShell = "diagonal_gap_amplitude" ∧
      roleValence = "off_diagonal_mixing" ∧
      roleI3 = "orientation_odd_companion" ∧
      physicalDiracEquation = false ∧
      physicalMassGap = false ∧
      particleEnergyFromEigenvalue = false ∧
      ValenceIsThirdParsevalSummand = false ∧
      DiracPictureGovernance.corePhysicsClaim = false :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem does_not_mutate_e100 : mutatesE100 = false := mutates_e100_false

end DiracLikeAudit
end KeplerHurwitz.E101
