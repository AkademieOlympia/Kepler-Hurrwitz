import Mathlib
import KeplerHurwitz.CollatzProofAttemptV25

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace CollatzBridge

open DepthExtraction
open ExitDepth
open ExitClasses

/--
`T_odd` is definitionally the normshell `oddKick`.
-/
theorem T_odd_eq_oddKick (n : Nat) : T_odd n = oddKick n := rfl

/--
One accelerated odd step equals two standard Collatz steps.
Requires the starting value to be odd.
-/
theorem collatz_two_steps_eq_T_odd {n : Nat} (ho : n % 2 = 1) :
    (collatzStep^[2]) n = T_odd n := by
  have hne : n % 2 ≠ 0 := by omega
  have hstep : collatzStep n = 3 * n + 1 := by
    simp [collatzStep, hne]
  have he : (3 * n + 1) % 2 = 0 := three_mul_add_one_even_of_odd ho
  calc
    (collatzStep^[2]) n
        = collatzStep (collatzStep n) := by simp [Function.iterate_succ_apply']
    _ = collatzStep (3 * n + 1) := by simp [hstep]
    _ = (3 * n + 1) / 2 := by simp [collatzStep, he]
    _ = oddKick n := by simp [oddKick]
    _ = T_odd n := by simp [T_odd_eq_oddKick]

/--
Three standard Collatz steps on a good `mod 4 = 1` odd state match `T_v2`.
-/
theorem collatz_three_steps_eq_T_v2_mod4_one
    {n : Nat}
    (ho : n % 2 = 1)
    (hmod : n % 4 = 1) :
    (collatzStep^[3]) n = T_v2 n := by
  have hne : n % 2 ≠ 0 := by omega
  have hstep1 : collatzStep n = 3 * n + 1 := by simp [collatzStep, hne]
  have he1 : (3 * n + 1) % 2 = 0 := three_mul_add_one_even_of_odd ho
  have hstep2 : collatzStep (3 * n + 1) = (3 * n + 1) / 2 := by
    simp [collatzStep, he1]
  have h4 : 4 ∣ 3 * n + 1 := by omega
  have hstep3 : collatzStep ((3 * n + 1) / 2) = (3 * n + 1) / 4 := by
    rcases h4 with ⟨k, hk⟩
    have hk2 : (3 * n + 1) / 2 = 2 * k := by
      rw [hk]
      omega
    have hcoll : collatzStep (2 * k) = k := by
      simp [collatzStep, show (2 * k) % 2 = 0 from by omega]
    calc
      collatzStep ((3 * n + 1) / 2)
          = collatzStep (2 * k) := by rw [hk2]
      _ = k := hcoll
      _ = (3 * n + 1) / 4 := by
            rw [hk]
            omega
  calc
    (collatzStep^[3]) n
        = collatzStep (collatzStep (collatzStep n)) := by
            simp [Function.iterate_succ_apply']
    _ = collatzStep (collatzStep (3 * n + 1)) := by simp [hstep1]
    _ = collatzStep ((3 * n + 1) / 2) := by simp [hstep2]
    _ = (3 * n + 1) / 4 := hstep3
    _ = T_v2 n := by simp [T_v2, hmod]

/--
After bad-run depth `d`, one more odd step lands in `mod 4 = 1`.
Direct corollary of the V2.3/V2.5 local shrink chain.
-/
theorem bad_run_depth_eventually_mod4_one
    {d n : Nat}
    (hd : 2 ≤ d)
    (hdepth : BadRunDepth d n) :
    (T_odd^[d - 1]) n % 4 = 1 := by
  have hmod8 := bad_run_depth_iterates_to_mod8_three hd hdepth
  have hidx : d - 2 + 1 = d - 1 := by omega
  rw [← hidx, Function.iterate_succ_apply']
  exact T_odd_mod4_eq_one_of_mod8_eq_three hmod8

theorem bad_run_depth_odd
    {d n : Nat}
    (hd : 2 ≤ d)
    (hdepth : BadRunDepth d n) :
    n % 2 = 1 := by
  unfold BadRunDepth at hdepth
  obtain ⟨_, hmod⟩ := hdepth
  have hdiv : 2 ∣ 2 ^ (d + 1) := by
    refine ⟨2 ^ d, ?_⟩
    rw [Nat.pow_succ, Nat.mul_comm]
  rw [← Nat.mod_mod_of_dvd n hdiv, hmod]
  have hpow : 2 ^ d % 2 = 0 := by
    rcases d with _ | _ | d
    · omega
    · omega
    · simp [Nat.pow_succ]
  omega

/--
Inductive collatzStep bridge: bad-run depth `d` reaches `mod 4 = 1`
after finitely many standard Collatz steps. Local only.
-/
theorem collatz_eventually_mod4_one_of_bad_run_depth
    {d n : Nat}
    (hd : 2 ≤ d)
    (hdepth : BadRunDepth d n) :
    ∃ t, (collatzStep^[t]) n % 4 = 1 := by
  revert n
  match d with
  | 2 =>
      intro n hdepth
      have h8 := bad_run_depth_two_mod8_three hdepth
      have ho := bad_run_depth_odd (by omega) hdepth
      refine ⟨2, ?_⟩
      rw [collatz_two_steps_eq_T_odd ho]
      exact T_odd_mod4_eq_one_of_mod8_eq_three h8
  | d + 3 =>
      intro n hdepth
      have hd_succ : 2 ≤ d + 3 := by omega
      have hm : 4 ≤ d + 4 := by omega
      have hlevel :=
        (bad_run_depth_iff_level_exit_residue (d := d + 3) (n := n) hd_succ).mp hdepth
      have hlower :=
        T_odd_level_exit_residue_descends (m := d + 4) (n := n) hm hlevel
      have hlower' : LevelExitResidue (d + 3) (T_odd n) := by
        simpa [Nat.sub_add_cancel (by omega : 1 ≤ 2)] using hlower
      have hdepth' : BadRunDepth (d + 2) (T_odd n) :=
        (bad_run_depth_iff_level_exit_residue (d := d + 2) (n := T_odd n) (by omega)).mpr hlower'
      have ho := bad_run_depth_odd hd_succ hdepth
      obtain ⟨t, ht⟩ :=
        collatz_eventually_mod4_one_of_bad_run_depth (d := d + 2) (by omega) hdepth'
      refine ⟨t + 2, ?_⟩
      calc
        (collatzStep^[t + 2]) n % 4
            = (collatzStep^[t]) (collatzStep^[2] n) % 4 := by
                  rw [Function.iterate_add_apply collatzStep t 2 n]
        _ = (collatzStep^[t]) (T_odd n) % 4 := by
              rw [collatz_two_steps_eq_T_odd ho]
        _ = 1 := ht
  | 0 | 1 =>
      intro n hdepth
      omega

end CollatzBridge

namespace ProofAttempt

open CollatzBridge
open DepthExtraction
open ExitDepth

/--
From `mod 4 = 3`, some `collatzStep` iterate reaches the good branch
`mod 4 = 1`. This is the collatzStep-facing form of the V2.5 local shrink
chain; it does not assert descent below the starting value.
-/
def Mod4ThreeEventuallyMod4OneStatement : Prop :=
  ∀ {n : Nat},
    n % 4 = 3 →
    ∃ t, (collatzStep^[t]) n % 4 = 1

/--
Global `collatzStep` descent from `mod 4 = 3` (still open).
This is the same target as `CollatzAttemptV2OpenCase`.
-/
def Mod4ThreeEventuallyDescendsStatement : Prop :=
  CollatzAttemptV2OpenCase

/--
Interface `[C]`: closing the open case from local shrink data plus
eventual entry into the good `mod 4 = 1` branch.
Requires a global well-foundedness / measure argument not yet available.
-/
def CollatzOpenCaseFromLocalShrinkStatement : Prop :=
  BadBranchEventuallyLocalShrinkStatement →
  Mod4ThreeEventuallyMod4OneStatement →
  Mod4ThreeEventuallyDescendsStatement

theorem mod4_three_eventually_mod4_one_via_T_odd
    {n : Nat}
    (hmod : n % 4 = 3) :
    ∃ r, (T_odd^[r]) n % 4 = 1 := by
  rcases bad_run_depth_extraction_statement_holds hmod with ⟨d, hd, hdepth⟩
  refine ⟨d - 1, bad_run_depth_eventually_mod4_one hd hdepth⟩

theorem mod4_three_eventually_mod4_one :
    Mod4ThreeEventuallyMod4OneStatement := by
  intro n hmod
  rcases bad_run_depth_extraction_statement_holds hmod with ⟨d, hd, hdepth⟩
  exact collatz_eventually_mod4_one_of_bad_run_depth hd hdepth

/--
Resolved collatzStep-facing good-branch entry target.
-/
def Mod4ThreeEventuallyMod4OneResolved : Prop :=
  Mod4ThreeEventuallyMod4OneStatement

theorem mod4_three_eventually_mod4_one_resolved :
    Mod4ThreeEventuallyMod4OneResolved := by
  exact mod4_three_eventually_mod4_one

/--
Extended proof-attempt status: local layer plus collatzStep bridge.
Global termination remains open.
-/
structure CollatzProofAttemptStatusV26 : Prop where
  base : CollatzProofAttemptStatus
  mod4_three_eventually_mod4_one : Mod4ThreeEventuallyMod4OneResolved

theorem collatz_proof_attempt_status_v26 : CollatzProofAttemptStatusV26 where
  base := collatz_proof_attempt_status
  mod4_three_eventually_mod4_one := mod4_three_eventually_mod4_one_resolved

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
