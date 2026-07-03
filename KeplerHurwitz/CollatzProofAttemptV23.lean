import Mathlib
import KeplerHurwitz.CollatzProofAttemptV22

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace ExitDepth

/--
`BadRunDepth d n` says that `n` has exact bad-run depth `d`.
It is the residue class
  n ≡ 2^d - 1 mod 2^(d+1).
Examples:
* d = 2: 3 mod 8
* d = 3: 7 mod 16
* d = 4: 15 mod 32
-/
def BadRunDepth (d n : Nat) : Prop :=
  2 ≤ d ∧ n % (2 ^ (d + 1)) = 2 ^ d - 1

theorem bad_run_depth_iff_level_exit_residue
    {d n : Nat}
    (hd : 2 ≤ d) :
    BadRunDepth d n ↔
      ExitClasses.LevelExitResidue (d + 1) n := by
  unfold BadRunDepth ExitClasses.LevelExitResidue
  constructor
  · intro h
    have hsub : d + 1 - 1 = d := by omega
    simpa [hsub] using h.2
  · intro h
    constructor
    · exact hd
    · have hsub : d + 1 - 1 = d := by omega
      simpa [hsub] using h

theorem bad_run_depth_two_mod8_three
    {n : Nat}
    (hdepth : BadRunDepth 2 n) :
    n % 8 = 3 := by
  unfold BadRunDepth at hdepth
  norm_num at hdepth
  exact hdepth

/--
Every exact bad-run depth `d ≥ 2` reaches the final exit class `3 mod 8`
after `d - 2` applications of `T_odd`.
-/
theorem bad_run_depth_iterates_to_mod8_three
    {d n : Nat}
    (hd : 2 ≤ d)
    (hdepth : BadRunDepth d n) :
    (T_odd^[d - 2]) n % 8 = 3 := by
  by_cases hd2 : d = 2
  · subst d
    simpa using bad_run_depth_two_mod8_three hdepth
  · have hd3 : 3 ≤ d := by omega
    have hlevel : 4 ≤ d + 1 := by omega
    have hexit : ExitClasses.LevelExitResidue (d + 1) n :=
      (bad_run_depth_iff_level_exit_residue (d := d) (n := n) (by omega)).mp hdepth
    have h :=
      ExitClasses.level_exit_residue_iterates_to_mod8_three
        (m := d + 1)
        (n := n)
        hlevel
        hexit
    have hidx : d + 1 - 3 = d - 2 := by omega
    simpa [hidx] using h

/--
Uniform bad-run-depth shrink theorem.
For every exact bad-run depth `d ≥ 2`, after `d - 2` applications of
`T_odd` the orbit reaches the final `3 mod 8` exit state; the subsequent
odd-step state lies in the good `1 mod 4` branch and satisfies the local
V2 shrink.
This is local only: it does not assert descent below the original `n`.
-/
theorem bad_run_depth_eventually_good_branch_shrink_uniform
    {d n : Nat}
    (hd : 2 ≤ d)
    (hdepth : BadRunDepth d n) :
    (3 * T_odd ((T_odd^[d - 2]) n) + 1) / 4 < T_odd ((T_odd^[d - 2]) n) := by
  have hmod8 := bad_run_depth_iterates_to_mod8_three hd hdepth
  exact ExitClasses.exit_mod8_three_then_good_shrink
    (n := (T_odd^[d - 2]) n)
    (ExitClasses.one_lt_T_odd_of_mod8_eq_three
      (ExitClasses.one_lt_of_mod8_eq_three hmod8)
      hmod8)
    hmod8

/--
Bad-run-depth statement.
Every state with exact bad-run depth `d ≥ 2` reaches, after `d - 2`
odd steps, a state whose following odd-step lies in the good `1 mod 4`
branch and locally shrinks under the V2 good step.
This is local only and does not assert global Collatz termination.
-/
def BadRunDepthStatement : Prop :=
  ∀ {d n : Nat},
    2 ≤ d →
    BadRunDepth d n →
    (3 * T_odd ((T_odd^[d - 2]) n) + 1) / 4 < T_odd ((T_odd^[d - 2]) n)

theorem bad_run_depth_statement_holds :
    BadRunDepthStatement := by
  intro d n hd hdepth
  exact bad_run_depth_eventually_good_branch_shrink_uniform hd hdepth

/--
If `n` has exact bad-run depth `d ≥ 3`, then after `d - 2`
applications of `T_odd`, the following odd-step state lies in the good
`1 mod 4` branch and therefore satisfies the local V2 shrink.
This is local only: it does not assert descent below the original `n`.
-/
theorem bad_run_depth_eventually_good_branch_shrink
    {d n : Nat}
    (hd : 3 ≤ d)
    (hdepth : BadRunDepth d n) :
    (3 * T_odd ((T_odd^[d - 2]) n) + 1) / 4 < T_odd ((T_odd^[d - 2]) n) := by
  exact bad_run_depth_eventually_good_branch_shrink_uniform (by omega) hdepth

end ExitDepth
end CollatzAttemptV2

end KeplerHurwitz
