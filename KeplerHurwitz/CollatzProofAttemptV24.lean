import Mathlib
import KeplerHurwitz.CollatzProofAttemptV23

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace DepthExtraction

/--
Exact 2-adic depth of `n + 1`: `2^d` divides `n + 1`, but `2^(d+1)` does not.
-/
def ExactTwoAdicDepthOfSucc (d n : Nat) : Prop :=
  2 ≤ d ∧
  2 ^ d ∣ n + 1 ∧
  ¬ 2 ^ (d + 1) ∣ n + 1

/--
Modular decomposition form of exact depth: `n = 2^(d+1) * a + (2^d - 1)`.
-/
def SuccDecomposesAtDepth (d n : Nat) : Prop :=
  ∃ a : Nat, n = 2 ^ (d + 1) * a + (2 ^ d - 1)

/--
Every exact 2-adic depth of `n + 1` yields the corresponding `BadRunDepth`.
This is the modular translation layer; it does not extract depth itself.
-/
def ExactTwoAdicDepthToBadRunDepthStatement : Prop :=
  ∀ {d n : Nat},
    ExactTwoAdicDepthOfSucc d n →
    ExitDepth.BadRunDepth d n

/--
Every `mod 4 = 3` state admits an exact 2-adic depth for `n + 1`.
This is the remaining arithmetic extraction target.
-/
def ExactTwoAdicDepthExtractionStatement : Prop :=
  ∀ {n : Nat},
    n % 4 = 3 →
    ∃ d : Nat, ExactTwoAdicDepthOfSucc d n

/--
A `mod 4 = 3` odd state has some exact bad-run depth.
This is the depth-extraction target: it says that every state in the
persistent bad branch admits a finite exact bad-run depth `d ≥ 2`.
This is local/arithmetic only and does not assert global Collatz descent.
-/
def BadRunDepthExtractionStatement : Prop :=
  ∀ {n : Nat},
    n % 4 = 3 →
    ∃ d : Nat,
      2 ≤ d ∧ ExitDepth.BadRunDepth d n

theorem succ_decomposes_at_depth_implies_bad_run_depth
    {d n : Nat}
    (hd : 2 ≤ d)
    (h : SuccDecomposesAtDepth d n) :
    ExitDepth.BadRunDepth d n := by
  rcases h with ⟨a, rfl⟩
  unfold ExitDepth.BadRunDepth
  constructor
  · exact hd
  · have hone : 1 ≤ 2 ^ d := by
      have htwo : 2 ≤ 2 ^ d := by
        calc
          2 = 2 ^ 1 := by norm_num
          _ ≤ 2 ^ d := Nat.pow_le_pow_right (by decide) (by omega)
      omega
    have hlt : 2 ^ d - 1 < 2 ^ (d + 1) := by
      calc
        2 ^ d - 1 < 2 ^ d := Nat.sub_lt hone (by decide)
        _ < 2 ^ d * 2 := by omega
        _ = 2 ^ (d + 1) := by rw [Nat.pow_succ]
    calc
      (2 ^ (d + 1) * a + (2 ^ d - 1)) % (2 ^ (d + 1))
          = ((2 ^ (d + 1) * a) % (2 ^ (d + 1)) + (2 ^ d - 1) % (2 ^ (d + 1))) % (2 ^ (d + 1)) := by
            rw [Nat.add_mod]
      _ = (0 + (2 ^ d - 1) % (2 ^ (d + 1))) % (2 ^ (d + 1)) := by
            simp [Nat.mul_mod_right]
      _ = (2 ^ d - 1) % (2 ^ (d + 1)) := by simp
      _ = 2 ^ d - 1 := Nat.mod_eq_of_lt hlt

theorem exact_two_adic_depth_of_succ_implies_succ_decomposes_at_depth
    {d n : Nat}
    (h : ExactTwoAdicDepthOfSucc d n) :
    SuccDecomposesAtDepth d n := by
  obtain ⟨hd, hdiv, hnot⟩ := h
  obtain ⟨k, hk⟩ := hdiv
  have hk1 : k % 2 = 1 := by
    by_contra hpar
    have hk0 : k % 2 = 0 := by omega
    have h2k : 2 ∣ k := Nat.dvd_of_mod_eq_zero hk0
    have hpow : 2 ^ (d + 1) ∣ 2 ^ d * k := by
      rw [Nat.pow_succ]
      exact Nat.mul_dvd_mul_left (2 ^ d) h2k
    rw [← hk] at hpow
    exact hnot hpow
  refine ⟨k / 2, ?_⟩
  have ha : k = 2 * (k / 2) + 1 := by
    calc
      k = 2 * (k / 2) + k % 2 := (Nat.div_add_mod k 2).symm
      _ = 2 * (k / 2) + 1 := by rw [hk1]
  have hmul : 2 ^ d * (2 * (k / 2) + 1) = 2 ^ (d + 1) * (k / 2) + 2 ^ d := by
    calc
      2 ^ d * (2 * (k / 2) + 1) = 2 ^ d * (2 * (k / 2)) + 2 ^ d * 1 := by rw [Nat.mul_add]
      _ = 2 ^ d * (2 * (k / 2)) + 2 ^ d := by ring
      _ = (2 ^ d * 2) * (k / 2) + 2 ^ d := by rw [Nat.mul_assoc]
      _ = 2 ^ (d + 1) * (k / 2) + 2 ^ d := by rw [Nat.pow_succ]
  have hone : 1 ≤ 2 ^ d := by
    have htwo : 2 ≤ 2 ^ d := by
      calc
        2 = 2 ^ 1 := by norm_num
        _ ≤ 2 ^ d := Nat.pow_le_pow_right (by decide) (by omega)
    omega
  change n = 2 ^ (d + 1) * (k / 2) + (2 ^ d - 1)
  have hn : n = 2 ^ d * k - 1 := by omega
  have hstep : 2 ^ d * k - 1 = 2 ^ d * (2 * (k / 2) + 1) - 1 := by
    have hk' : 2 ^ d * k = 2 ^ d * (2 * (k / 2) + 1) :=
      congrArg (Nat.mul (2 ^ d)) ha
    rw [hk']
  calc
    n = 2 ^ d * k - 1 := hn
    _ = 2 ^ d * (2 * (k / 2) + 1) - 1 := hstep
    _ = 2 ^ (d + 1) * (k / 2) + 2 ^ d - 1 := by rw [hmul]
    _ = 2 ^ (d + 1) * (k / 2) + (2 ^ d - 1) := by omega

theorem exact_two_adic_depth_of_succ_implies_bad_run_depth
    {d n : Nat}
    (h : ExactTwoAdicDepthOfSucc d n) :
    ExitDepth.BadRunDepth d n := by
  exact succ_decomposes_at_depth_implies_bad_run_depth
    (hd := h.1)
    (exact_two_adic_depth_of_succ_implies_succ_decomposes_at_depth h)

theorem exact_two_adic_depth_to_bad_run_depth_statement_holds :
    ExactTwoAdicDepthToBadRunDepthStatement := by
  intro d n h
  exact exact_two_adic_depth_of_succ_implies_bad_run_depth h

theorem bad_run_depth_extraction_of_exact_two_adic_depth_extraction
    (hExtract : ExactTwoAdicDepthExtractionStatement) :
    BadRunDepthExtractionStatement := by
  intro n hmod4
  rcases hExtract hmod4 with ⟨d, hexact⟩
  exact ⟨d, hexact.1, exact_two_adic_depth_of_succ_implies_bad_run_depth hexact⟩

/--
If depth extraction holds, every `mod 4 = 3` state eventually reaches a
local good-branch shrink after finitely many odd steps.
This is local only and does not assert descent below the original `n`.
-/
def BadBranchEventuallyLocalShrinkStatement : Prop :=
  ∀ {n : Nat},
    n % 4 = 3 →
    ∃ d : Nat,
      2 ≤ d ∧
      (3 * T_odd ((T_odd^[d - 2]) n) + 1) / 4 < T_odd ((T_odd^[d - 2]) n)

theorem bad_branch_eventually_local_shrink_of_depth_extraction
    (hExtract : BadRunDepthExtractionStatement) :
    BadBranchEventuallyLocalShrinkStatement := by
  intro n hmod4
  rcases hExtract hmod4 with ⟨d, hd, hdepth⟩
  exact ⟨d, hd,
    ExitDepth.bad_run_depth_eventually_good_branch_shrink_uniform
      hd
      hdepth⟩

theorem bad_branch_eventually_local_shrink_of_exact_two_adic_depth_extraction
    (hExtract : ExactTwoAdicDepthExtractionStatement) :
    BadBranchEventuallyLocalShrinkStatement := by
  exact bad_branch_eventually_local_shrink_of_depth_extraction
    (bad_run_depth_extraction_of_exact_two_adic_depth_extraction hExtract)

theorem mod8_three_has_bad_run_depth_two
    {n : Nat}
    (hmod : n % 8 = 3) :
    ExitDepth.BadRunDepth 2 n := by
  unfold ExitDepth.BadRunDepth
  constructor
  · norm_num
  · norm_num
    exact hmod

theorem mod16_seven_has_bad_run_depth_three
    {n : Nat}
    (hmod : n % 16 = 7) :
    ExitDepth.BadRunDepth 3 n := by
  unfold ExitDepth.BadRunDepth
  constructor
  · norm_num
  · norm_num
    exact hmod

theorem mod32_fifteen_has_bad_run_depth_four
    {n : Nat}
    (hmod : n % 32 = 15) :
    ExitDepth.BadRunDepth 4 n := by
  unfold ExitDepth.BadRunDepth
  constructor
  · norm_num
  · norm_num
    exact hmod

end DepthExtraction
end CollatzAttemptV2

end KeplerHurwitz
