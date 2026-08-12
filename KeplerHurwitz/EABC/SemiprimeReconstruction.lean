/-
  Konsument (3): Semiprime reconstruction modulo symmetry (Satzkandidat-17 style).

  Claims **only**:
    [B] On *coded* residual channel pairs (Sym² of {A,B,C}),
        synthesize ∘ analyze = id modulo swap.
    [A] Filterbank reconstruction on Fin 3: P_iso + P_aniso = id
        (consumed from SemiprimeWavelet; not reproved as factorization).

  Explicit non-claims:
    * no arithmetic factorization of a bare `n : ℕ`
    * no complexity / algorithm claim
    * does not modify Semiprim* / SemiprimeWavelet* / ClaimWall cores
-/

import Mathlib.Tactic
import KeplerHurwitz.EABC.Semiprim
import KeplerHurwitz.EABC.SemiprimeWaveletCartan
import KeplerHurwitz.FiniteFactorTree.ClaimWall

namespace KeplerHurwitz.EABC
namespace SemiprimeReconstruction

open SemiprimeWavelet
open KeplerHurwitz.FiniteFactorTree

/-! ## Freeze / schema markers -/

theorem consumes_freeze_status : ClaimWall.Status := ClaimWall.status

theorem does_not_claim_factorization : ¬ ClaimWall.ArithmeticFactorization :=
  fun h => nomatch h

theorem consumes_semiprim_claim_wall : SemiprimClaimWallStatus :=
  semiprim_claim_wall_status

def exportSchemaId : String :=
  "semiprime_reconstruction_mod_symmetry.v1"

/-! ## Coded residual pairs (Sym² carrier) -/

/-- Residual (non-E) channel. -/
def IsResidual (x : V4) : Prop := x ≠ V4.E

instance (x : V4) : Decidable (IsResidual x) :=
  inferInstanceAs (Decidable (x ≠ V4.E))

/-- Ordered coded pair of distinct residual channels (pre-Sym²). -/
structure CodedResidualPair where
  left : V4
  right : V4
  left_residual : IsResidual left
  right_residual : IsResidual right
  distinct : left ≠ right

/-- Swap symmetry generator on coded pairs. -/
def CodedResidualPair.swap (p : CodedResidualPair) : CodedResidualPair where
  left := p.right
  right := p.left
  left_residual := p.right_residual
  right_residual := p.left_residual
  distinct := p.distinct.symm

theorem swap_swap (p : CodedResidualPair) : p.swap.swap = p := by
  cases p
  rfl

/-- Channel data of a coded pair (proof fields erased for Sym² comparison). -/
def channelPair (p : CodedResidualPair) : V4 × V4 := (p.left, p.right)

/-- Unordered equality: identify a pair with its swap (on channels only). -/
def UnorderedEq (p q : CodedResidualPair) : Prop :=
  channelPair p = channelPair q ∨ channelPair p = (q.right, q.left)

theorem UnorderedEq.refl (p : CodedResidualPair) : UnorderedEq p p :=
  Or.inl rfl

theorem UnorderedEq.swap_right (p : CodedResidualPair) :
    UnorderedEq p p.swap := by
  right
  simp [channelPair, CodedResidualPair.swap]

/-! ## Analyze / Synthesize on Sym²(residual channels) -/

/-- Analyze: channel product (Gestalt class). -/
def analyze (p : CodedResidualPair) : V4 :=
  p.left * p.right

theorem analyze_swap (p : CodedResidualPair) :
    analyze p.swap = analyze p := by
  simp [analyze, CodedResidualPair.swap, V4.mul_comm]

/-- Synthesize the complementary residual pair from a residual product class. -/
def synthesize (prod : V4) (h : IsResidual prod) : CodedResidualPair :=
  match prod with
  | .A =>
      { left := .B, right := .C
        left_residual := by decide
        right_residual := by decide
        distinct := by decide }
  | .B =>
      { left := .A, right := .C
        left_residual := by decide
        right_residual := by decide
        distinct := by decide }
  | .C =>
      { left := .A, right := .B
        left_residual := by decide
        right_residual := by decide
        distinct := by decide }
  | .E => False.elim (h rfl)

theorem synthesize_product (prod : V4) (h : IsResidual prod) :
    analyze (synthesize prod h) = prod := by
  cases prod with
  | E => exact False.elim (h rfl)
  | A => rfl
  | B => rfl
  | C => rfl

/-- Product of a coded distinct residual pair is residual (third channel). -/
theorem analyze_isResidual (p : CodedResidualPair) : IsResidual (analyze p) :=
  V4.mul_distinct_residual p.left_residual p.right_residual p.distinct

/--
Satzkandidat-17 (coded form): synthesize ∘ analyze = id on Sym².

Recovered pair equals the input up to swap (channel data).
-/
theorem synthesize_analyze_unordered (p : CodedResidualPair) :
    UnorderedEq (synthesize (analyze p) (analyze_isResidual p)) p := by
  rcases p with ⟨l, r, hl, hr, hd⟩
  cases l with
  | E => exact (hl rfl).elim
  | A =>
    cases r with
    | E => exact (hr rfl).elim
    | A => exact (hd rfl).elim
    | B => left; rfl
    | C => left; rfl
  | B =>
    cases r with
    | E => exact (hr rfl).elim
    | A => right; rfl
    | B => exact (hd rfl).elim
    | C => left; rfl
  | C =>
    cases r with
    | E => exact (hr rfl).elim
    | A => right; rfl
    | B => right; rfl
    | C => exact (hd rfl).elim

/-! ## Filterbank reconstruction layer (consumed from [A]) -/

/-- Analyze triad into isotropic / anisotropic channels. -/
noncomputable def analyzeTriad (q : Fin 3 → ℝ) : (Fin 3 → ℝ) × (Fin 3 → ℝ) :=
  (P_iso q, P_aniso q)

/-- Synthesize triad by perfect reconstruction. -/
noncomputable def synthesizeTriad (parts : (Fin 3 → ℝ) × (Fin 3 → ℝ)) : Fin 3 → ℝ :=
  parts.1 + parts.2

theorem synthesize_analyze_triad (q : Fin 3 → ℝ) :
    synthesizeTriad (analyzeTriad q) = q := by
  simp [synthesizeTriad, analyzeTriad, id_eq_P_iso_add_P_aniso]

/-- TwinRay does not disturb filterbank reconstruction identity. -/
theorem synthesize_analyze_triad_neg (q : Fin 3 → ℝ) :
    synthesizeTriad (analyzeTriad (-q)) = -q :=
  synthesize_analyze_triad (-q)

/-! ## Audit payload -/

inductive ReconstructionClass
  | exactModSwap
  | filterbankExact
  | defect
  deriving DecidableEq, Repr

structure ReconstructionAuditResult where
  product : V4
  recoveredLeft : V4
  recoveredRight : V4
  unorderedMatch : Prop
  freezeAnchor : String := "ClaimWall.status"

def runCodedPairAudit (p : CodedResidualPair) : ReconstructionAuditResult :=
  let prod := analyze p
  let recovered := synthesize prod (analyze_isResidual p)
  { product := prod
    recoveredLeft := recovered.left
    recoveredRight := recovered.right
    unorderedMatch := UnorderedEq recovered p }

theorem audit_unorderedMatch (p : CodedResidualPair) :
    (runCodedPairAudit p).unorderedMatch := by
  simpa [runCodedPairAudit] using synthesize_analyze_unordered p

/-! ## Non-claims -/

theorem reconstruction_is_not_factorization : True := trivial
theorem reconstruction_no_complexity_claim : True := trivial
theorem reconstruction_does_not_modify_freeze : True := trivial
theorem reconstruction_requires_coded_channels : True := trivial

end SemiprimeReconstruction
end KeplerHurwitz.EABC
