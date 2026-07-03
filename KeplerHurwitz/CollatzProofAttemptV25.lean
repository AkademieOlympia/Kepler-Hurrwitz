import Mathlib
import KeplerHurwitz.CollatzProofAttemptV24

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace ProofAttempt

open DepthExtraction
open ExitDepth

/--
`n ≡ 3 (mod 4)` forces `4 ∣ n+1`, hence `ν₂(n+1) ≥ 2`.
-/
theorem two_le_padicValNat_two_of_mod4_eq_three
    {n : Nat}
    (hmod : n % 4 = 3) :
    2 ≤ padicValNat 2 (n + 1) := by
  have hn : n + 1 ≠ 0 := by omega
  have h4 : 4 ∣ n + 1 := by omega
  exact (padicValNat_dvd_iff_le (p := 2) (a := n + 1) hn).1 (by simpa using h4)

/--
Exact 2-adic depth of `n+1` is given by `padicValNat 2 (n+1)`.
Requires `ν₂(n+1) ≥ 2`, e.g. from `n ≡ 3 (mod 4)`.
-/
theorem exact_two_adic_depth_of_padicValNat_succ
    {n : Nat}
    (hd : 2 ≤ padicValNat 2 (n + 1)) :
    ExactTwoAdicDepthOfSucc (padicValNat 2 (n + 1)) n := by
  unfold ExactTwoAdicDepthOfSucc
  have hn : n + 1 ≠ 0 := by
    intro h
    rw [h] at hd
    simp at hd
  refine ⟨hd, ?_, ?_⟩
  · exact pow_padicValNat_dvd (p := 2) (n := n + 1)
  · exact pow_succ_padicValNat_not_dvd hn

theorem exact_two_adic_depth_extraction_statement_holds :
    ExactTwoAdicDepthExtractionStatement := by
  intro n hmod4
  refine ⟨padicValNat 2 (n + 1), ?_⟩
  exact exact_two_adic_depth_of_padicValNat_succ
    (two_le_padicValNat_two_of_mod4_eq_three hmod4)

theorem bad_run_depth_extraction_statement_holds :
    BadRunDepthExtractionStatement := by
  exact bad_run_depth_extraction_of_exact_two_adic_depth_extraction
    exact_two_adic_depth_extraction_statement_holds

theorem bad_branch_eventually_local_shrink_statement_holds :
    BadBranchEventuallyLocalShrinkStatement := by
  exact bad_branch_eventually_local_shrink_of_depth_extraction
    bad_run_depth_extraction_statement_holds

/--
Every `mod 4 = 3` state reaches a good-branch shrink after finitely many
odd steps. The depth is `ν₂(n+1)`.
-/
theorem mod4_eq_three_has_eventually_local_shrink
    {n : Nat}
    (hmod : n % 4 = 3) :
    ∃ d : Nat,
      2 ≤ d ∧
      (3 * T_odd ((T_odd^[d - 2]) n) + 1) / 4 < T_odd ((T_odd^[d - 2]) n) := by
  exact bad_branch_eventually_local_shrink_statement_holds hmod

/--
Resolved local bad-branch target.
-/
def BadBranchLocalShrinkResolved : Prop :=
  BadBranchEventuallyLocalShrinkStatement

theorem bad_branch_local_shrink_resolved :
    BadBranchLocalShrinkResolved := by
  exact bad_branch_eventually_local_shrink_statement_holds

/--
Resolved 2-adic depth extraction target.
-/
def ExactTwoAdicDepthExtractionResolved : Prop :=
  ExactTwoAdicDepthExtractionStatement

theorem exact_two_adic_depth_extraction_resolved :
    ExactTwoAdicDepthExtractionResolved := by
  exact exact_two_adic_depth_extraction_statement_holds

/--
Resolved bad-run depth extraction target.
-/
def BadRunDepthExtractionResolved : Prop :=
  BadRunDepthExtractionStatement

theorem bad_run_depth_extraction_resolved :
    BadRunDepthExtractionResolved := by
  exact bad_run_depth_extraction_statement_holds

/--
V2 good-branch case: `mod 4 = 1` implies strict local shrink.
Already proved in V2.
-/
def GoodBranchShrinkResolved : Prop :=
  CollatzAttemptV2Mod4EqOneShrink

theorem good_branch_shrink_resolved :
    GoodBranchShrinkResolved := by
  exact collatz_attempt_v2_case_mod4_eq_one

/--
Global Collatz termination target (still open).
Every `n > 1` eventually reaches `1` under standard `collatzStep`.
-/
def CollatzGlobalTerminationStatement : Prop :=
  ∀ {n : Nat}, 1 < n → ∃ t, (collatzStep^[t]) n = 1

/--
Open V2 sub-target: from `mod 4 = 3`, find a genuine `collatzStep`
descent below the starting value.
Local odd-tail shrink is proved; bridging to `collatzStep` iteration
and global well-foundedness remains open.
-/
def CollatzMod4ThreeGlobalDescentStatement : Prop :=
  CollatzAttemptV2OpenCase

/--
Proof-attempt status bundle.
Records what is proved locally and what remains globally open.
-/
structure CollatzProofAttemptStatus : Prop where
  good_branch : GoodBranchShrinkResolved
  exact_depth_extraction : ExactTwoAdicDepthExtractionResolved
  bad_run_depth_extraction : BadRunDepthExtractionResolved
  bad_branch_local_shrink : BadBranchLocalShrinkResolved

theorem collatz_proof_attempt_status : CollatzProofAttemptStatus where
  good_branch := good_branch_shrink_resolved
  exact_depth_extraction := exact_two_adic_depth_extraction_resolved
  bad_run_depth_extraction := bad_run_depth_extraction_resolved
  bad_branch_local_shrink := bad_branch_local_shrink_resolved

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
