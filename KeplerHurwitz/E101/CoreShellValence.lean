/-
  E-101.7 — Core / Shell / Valence Reading (external [C] consumer).

  Orthogonal state split (Parseval):
    ||q||^2 = Lambda101 + C2
  Valence is a coupling role, NOT a third Parseval summand:
    Valence101(q) := (q101, K_B1B2, alpha101)

  Layer [C] over sealed E-101.6 nomenclature.
  Schema: e101_core_shell_valence.v1
-/

import Mathlib.Tactic
import KeplerHurwitz.E101.CoreModel
import KeplerHurwitz.E101.ConstantNomenclature
import KeplerHurwitz.E101.AnalogyProbe
import KeplerHurwitz.FiniteFactorTree.ClaimWall
import KeplerHurwitz.FiniteFactorTree.EabcResidueTree
import KeplerHurwitz.EABC.SemiprimeWaveletCartan
import KeplerHurwitz.EABC.SemiprimeWaveletEnergy
import KeplerHurwitz.EABC.SemiprimeWaveletCore

namespace KeplerHurwitz.E101
namespace CoreShellValence

open CoreModel
open ConstantNomenclature
open KeplerHurwitz.FiniteFactorTree
open EabcResidue
open KeplerHurwitz.EABC
open SemiprimeWavelet

/-! ## Governance -/

def exportSchemaId : String := "e101_core_shell_valence.v1"
def upstreamAnchor : String := CoreModel.statusAnchor
def mutatesE100 : Bool := false
def mappingLevel : String := "exclusion_shell_reading_C"

theorem mutates_e100_false : mutatesE100 = false := rfl

def consumes_core_model_status : CoreModel.Status := CoreModel.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  CoreModel.does_not_claim_factorization

/-! ## Architectural booleans (claim wall) -/

def ExclusionShellReading : Bool := true
def CoreIsIsotropicReference : Bool := true
def ShellIsAnisotropicDetail : Bool := true
def ValenceIsCouplingRole : Bool := true
/-- Critical: valence is relational, not a Parseval energy block. -/
def ValenceIsThirdParsevalSummand : Bool := false
def AtomicShellIdentity : Bool := false
def NuclearShellIdentity : Bool := false
def ChemicalValenceIdentity : Bool := false
def SuperconductivityClaim : Bool := false
def NuclearBindingEnergyClaim : Bool := false
def ElectricChargeClaim : Bool := false
def CollatzProofClaim : Bool := false
def EABCProofFromAnalogy : Bool := false
def ResidualEqualsC2Claim : Bool := false
def MeissnerPhysicsClaim : Bool := false

theorem ExclusionShellReading_true : ExclusionShellReading = true := rfl
theorem CoreIsIsotropicReference_true : CoreIsIsotropicReference = true := rfl
theorem ShellIsAnisotropicDetail_true : ShellIsAnisotropicDetail = true := rfl
theorem ValenceIsCouplingRole_true : ValenceIsCouplingRole = true := rfl
theorem ValenceIsThirdParsevalSummand_false :
    ValenceIsThirdParsevalSummand = false := rfl
theorem AtomicShellIdentity_false : AtomicShellIdentity = false := rfl
theorem NuclearShellIdentity_false : NuclearShellIdentity = false := rfl
theorem ChemicalValenceIdentity_false : ChemicalValenceIdentity = false := rfl
theorem SuperconductivityClaim_false : SuperconductivityClaim = false := rfl
theorem NuclearBindingEnergyClaim_false : NuclearBindingEnergyClaim = false := rfl
theorem ResidualEqualsC2Claim_false : ResidualEqualsC2Claim = false := rfl
theorem CollatzProofClaim_false : CollatzProofClaim = false := rfl
theorem EABCProofFromAnalogy_false : EABCProofFromAnalogy = false := rfl

/-! ## I. Orthogonal state decomposition (Kern / Schale) -/

/-- Core: isotropic reference energy \(\Lambda_{101}=\|P_{\mathrm{iso}}q\|^2\). -/
noncomputable def coreEnergy (q : Fin 3 → ℝ) : ℝ :=
  Lambda101 q

/-- Shell: anisotropic detail \(C_2=\|P_{\mathrm{aniso}}q\|^2\). -/
noncomputable def shellEnergy (q : Fin 3 → ℝ) : ℝ :=
  C2 q

noncomputable def shellAmplitude (q : Fin 3 → ℝ) : ℝ :=
  mu101_triad q

theorem shellEnergy_eq_detail (q : Fin 3 → ℝ) :
    shellEnergy q = detailEnergy q :=
  AnalogyProbe.c2_is_anisotropyEnergy q

theorem shellEnergy_eq_P_aniso_normSq (q : Fin 3 → ℝ) :
    shellEnergy q = SemiprimeWavelet.energySq (P_aniso q) := by
  simp [shellEnergy, ← detailEnergy_eq_C2, detailEnergy]

/-- Exact orthogonal Parseval split — only two summands. -/
theorem parseval_core_plus_shell (q : Fin 3 → ℝ) :
    SemiprimeWavelet.energySq q = coreEnergy q + shellEnergy q := by
  simpa [coreEnergy, shellEnergy, ← detailEnergy_eq_C2] using
    parseval_iso_plus_detail q

/-! ## II. Relational valence (coupling role, not energy block) -/

/--
Valence data: active outer signature / coupling structure.
Not a scalar in the Parseval norm.
-/
structure Valence101 where
  /-- Character signature \(\mathbf q_{101}=\chi\). -/
  q101 : Fin 2 → ℝ
  /-- Cross-slot covariance observable \(K_{B1,B2}\). -/
  K_B1B2 : ℝ
  /-- Dimensionless coupling index \(\alpha_{101}\). -/
  alpha101 : ℝ

/-- Assemble valence from character, measured \(K\), and audit config / \(C_2\). -/
noncomputable def valence101
    (cfg : E101ConstantNomenclature)
    (x : V4) (K C2val : ℝ) : Valence101 where
  q101 := characterSignature x
  K_B1B2 := K
  alpha101 := ConstantNomenclature.alpha101 cfg K C2val

theorem valence_character_normSq (v : Valence101) (x : V4)
    (h : v.q101 = characterSignature x) :
    FiniteFactorTree.energySq v.q101 = 2 := by
  simpa [h] using characterSignature_normSq x

/-- Architectural marker: valence is not added into \(\|q\|^2\). -/
theorem valence_not_parseval_summand :
    ValenceIsThirdParsevalSummand = false ∧
      ValenceIsCouplingRole = true :=
  ⟨rfl, rfl⟩

/-! ## III. Allowed / forbidden labels (documentation markers) -/

def allowedCoreLabel : String := "inert-core-like"
def allowedShellLabel : String := "shell-like detail"
def allowedValenceLabel : String := "valence-coupling-data"

def meissnerHookLabel : String := "boundary-compensated defect exclusion"
def e092HookLabel : String := "smooth_reference_plus_structured_residual"

/-! ## Master shield -/

/--
Kern-Schale-Valenz = Zerlegungs- und Kopplungssprache
≠ Atom-, Kern- oder Chemiephysik.
-/
theorem core_shell_valence_ne_physics :
    ExclusionShellReading = true ∧
      ValenceIsThirdParsevalSummand = false ∧
      AtomicShellIdentity = false ∧
      NuclearShellIdentity = false ∧
      ChemicalValenceIdentity = false ∧
      SuperconductivityClaim = false ∧
      NuclearBindingEnergyClaim = false ∧
      ResidualEqualsC2Claim = false ∧
      CollatzProofClaim = false ∧
      EABCProofFromAnalogy = false :=
  ⟨rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl, rfl⟩

theorem reading_does_not_mutate_e100 : mutatesE100 = false := mutates_e100_false
theorem reading_inherits_nomenclature_wall :
    ConstantNomenclature.nomenclatureOnly = true := rfl

end CoreShellValence
end KeplerHurwitz.E101
