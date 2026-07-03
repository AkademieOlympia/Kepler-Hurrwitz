import Mathlib
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.CollatzProofAttemptV21

namespace KeplerHurwitz

namespace CollatzAttemptV2
namespace ExitClasses

/--
Level-`m` exit residue.
Inside modulus `2^m`, this is the residue class that is still
`-1 mod 2^(m-1)` but not `-1 mod 2^m`.
Examples:
* `m = 3`: `3 mod 8`
* `m = 4`: `7 mod 16`
* `m = 5`: `15 mod 32`
-/
def LevelExitResidue (m n : Nat) : Prop :=
  n % (2 ^ m) = 2 ^ (m - 1) - 1

abbrev BadRunExitResidue := LevelExitResidue

/--
Exit depth interface.
A number exits the bad-run channel at level `m` if it lies in the
level-`m` exit residue.
This interface is intentionally local and does not assert global
termination or descent below the starting value.
-/
def HasBadRunExitAtLevel (m n : Nat) : Prop :=
  3 ≤ m ∧ LevelExitResidue m n

theorem one_lt_T_odd_of_mod8_eq_three
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 8 = 3) :
    1 < T_odd n := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_three]
  omega

theorem exit_mod8_three_then_good_shrink
    {n : Nat}
    (hn : 1 < T_odd n)
    (hmod : n % 8 = 3) :
    (3 * T_odd n + 1) / 4 < T_odd n := by
  have hgood : T_odd n % 4 = 1 :=
    T_odd_mod4_eq_one_of_mod8_eq_three hmod
  exact three_mul_add_one_quarter_lt_of_mod4_eq_one
    (n := T_odd n) hn hgood

theorem exit_mod8_three_then_good_shrink_of_one_lt
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 8 = 3) :
    (3 * T_odd n + 1) / 4 < T_odd n := by
  exact exit_mod8_three_then_good_shrink
    (hn := one_lt_T_odd_of_mod8_eq_three hn hmod)
    hmod

/--
General exit-to-good-branch target.
If the bad-run chain exits at the final `3 mod 8` class,
then the next odd step enters the good `1 mod 4` shrink branch.
-/
def BadRunExitToGoodBranchStatement : Prop :=
  ∀ {n : Nat},
    1 < n →
    n % 8 = 3 →
    T_odd n % 4 = 1

theorem bad_run_exit_to_good_branch_statement_holds :
    BadRunExitToGoodBranchStatement := by
  intro n _hn hmod
  exact T_odd_mod4_eq_one_of_mod8_eq_three hmod

theorem exists_eq_pow_two_mul_add_half_pow_two_sub_one_of_level_exit
    {m n : Nat}
    (hexit : LevelExitResidue m n) :
    ∃ k, n = 2 ^ m * k + (2 ^ (m - 1) - 1) := by
  unfold LevelExitResidue at hexit
  refine ⟨n / (2 ^ m), ?_⟩
  calc
    n = n % (2 ^ m) + (2 ^ m) * (n / (2 ^ m)) := by
          simpa [Nat.add_comm, Nat.add_left_comm, Nat.add_assoc] using
            (Nat.mod_add_div n (2 ^ m)).symm
    _ = (2 ^ (m - 1) - 1) + (2 ^ m) * (n / (2 ^ m)) := by simp [hexit]
    _ = 2 ^ m * (n / (2 ^ m)) + (2 ^ (m - 1) - 1) := by omega

theorem T_odd_of_pow_two_mul_add_half_pow_two_sub_one
    (m k : Nat)
    (hm : 2 ≤ m) :
    T_odd (2 ^ m * k + (2 ^ (m - 1) - 1))
      =
    3 * 2 ^ (m - 1) * k + (3 * 2 ^ (m - 2) - 1) := by
  let u : Nat := 2 ^ (m - 1)
  let t : Nat := u * k
  let r : Nat := 3 * t + (3 * 2 ^ (m - 2) - 1)
  unfold T_odd
  have hu : 2 ^ m = 2 * u := by
    simp only [u]
    calc
      2 ^ m = 2 ^ (m - 1 + 1) := by
            have h : m - 1 + 1 = m := by omega
            rw [h]
      _ = 2 ^ (m - 1) * 2 := by rw [Nat.pow_succ]
      _ = 2 * u := by simp [u, Nat.mul_comm]
  have hk2 : 2 * u * k = 2 * t := by
    calc
      2 * u * k = 2 * (u * k) := by ring
      _ = 2 * t := by simp [t]
  have hhalf : 2 ^ (m - 1) = 2 * 2 ^ (m - 2) := by
    calc
      2 ^ (m - 1) = 2 ^ (m - 2 + 1) := by
            have h : m - 2 + 1 = m - 1 := by omega
            rw [h]
      _ = 2 ^ (m - 2) * 2 := by rw [Nat.pow_succ]
      _ = 2 * 2 ^ (m - 2) := by ring
  have hpos : 0 < 2 ^ (m - 1) := pow_pos (by decide) (m - 1)
  have hone : 1 ≤ 2 ^ (m - 1) := Nat.succ_le_of_lt hpos
  have hnum :
      3 * (2 ^ m * k + (2 ^ (m - 1) - 1)) + 1 = 2 * r := by
    rw [hu, hk2]
    simp only [u, t, r]
    rw [hhalf]
    omega
  rw [hnum]
  calc
    (2 * r) / 2 = r := by simpa using (Nat.mul_div_right r 2)
    _ = 3 * 2 ^ (m - 1) * k + (3 * 2 ^ (m - 2) - 1) := by
          simp [r, t, u, Nat.mul_assoc, Nat.mul_comm]

theorem three_mul_two_h_mul_k_add_three_h_sub_one_mod_two_h
    (h k : Nat)
    (hh : 0 < h) :
    (3 * (2 * h) * k + (3 * h - 1)) % (2 * h) = h - 1 := by
  have hh1 : 1 ≤ h := Nat.succ_le_of_lt hh
  have hdecomp :
      3 * (2 * h) * k + (3 * h - 1) = (2 * h) * (3 * k + 1) + (h - 1) := by
    calc
      3 * (2 * h) * k + (3 * h - 1)
          = 3 * (2 * h) * k + (2 * h + (h - 1)) := by omega
      _ = (2 * h) * (3 * k + 1) + (h - 1) := by ring
  have hlt : h - 1 < 2 * h := by omega
  calc
    (3 * (2 * h) * k + (3 * h - 1)) % (2 * h)
        = ((2 * h) * (3 * k + 1) + (h - 1)) % (2 * h) := by rw [hdecomp]
    _ = (((2 * h) * (3 * k + 1)) % (2 * h) + (h - 1) % (2 * h)) % (2 * h) := by rw [Nat.add_mod]
    _ = (0 + (h - 1) % (2 * h)) % (2 * h) := by simp [Nat.mul_mod_right]
    _ = (h - 1) % (2 * h) := by simp
    _ = h - 1 := Nat.mod_eq_of_lt hlt

/--
One-step descent for level-exit residues.
The exit residue at level `m` descends to the exit residue at level `m-1`
under one application of `T_odd`.
-/
theorem T_odd_level_exit_residue_descends
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : LevelExitResidue m n) :
    LevelExitResidue (m - 1) (T_odd n) := by
  unfold LevelExitResidue at hexit ⊢
  rcases exists_eq_pow_two_mul_add_half_pow_two_sub_one_of_level_exit hexit with ⟨k, rfl⟩
  rw [T_odd_of_pow_two_mul_add_half_pow_two_sub_one m k (by omega)]
  have hpow : 2 ^ (m - 1) = 2 * 2 ^ (m - 2) := by
    calc
      2 ^ (m - 1) = 2 ^ (m - 2 + 1) := by
            have h : m - 2 + 1 = m - 1 := by omega
            rw [h]
      _ = 2 ^ (m - 2) * 2 := by rw [Nat.pow_succ]
      _ = 2 * 2 ^ (m - 2) := by ring
  have hsub : m - 1 - 1 = m - 2 := by omega
  rw [hsub]
  have hform :
      3 * 2 ^ (m - 1) * k + (3 * 2 ^ (m - 2) - 1)
        = 3 * (2 * 2 ^ (m - 2)) * k + (3 * 2 ^ (m - 2) - 1) := by
    rw [hpow]
  rw [hform, hpow]
  exact three_mul_two_h_mul_k_add_three_h_sub_one_mod_two_h
    (h := 2 ^ (m - 2)) (k := k) (by positivity)

/--
One-step induction bridge for iterated level-exit descent.
-/
theorem level_exit_residue_iterated_descent_step
    {m r n : Nat}
    (hlevel : 4 ≤ m - r)
    (hres : LevelExitResidue (m - r) ((T_odd^[r]) n)) :
    LevelExitResidue (m - r - 1) ((T_odd^[r + 1]) n) := by
  have h :=
    T_odd_level_exit_residue_descends
      (m := m - r)
      (n := (T_odd^[r]) n)
      hlevel
      hres
  rw [Function.iterate_succ_apply']
  exact h

/--
Iterated level-exit descent.
A level-`m` exit residue descends after `r` odd steps to the
level-`m-r` exit residue.
-/
theorem level_exit_residue_iterated_descent
    {m r n : Nat}
    (hm : 4 ≤ m)
    (hr : r ≤ m - 3)
    (hexit : LevelExitResidue m n) :
    LevelExitResidue (m - r) ((T_odd^[r]) n) := by
  induction r generalizing m n with
  | zero =>
      simp only [Function.iterate_zero]
      exact hexit
  | succ r ih =>
      have hr_prev : r ≤ m - 4 := by omega
      have ih' := ih hm (by omega) hexit
      have hlevel : 4 ≤ m - r := by omega
      have hstep :=
        level_exit_residue_iterated_descent_step
          (m := m) (r := r) (n := n) hlevel ih'
      have hiter : T_odd^[Nat.succ r] n = T_odd^[r + 1] n := rfl
      have hsub : m - Nat.succ r = m - r - 1 := by omega
      rw [hiter, hsub]
      exact hstep

/--
Iterated descent for level-exit residues.
If `n` lies in the level-`m` exit residue, then after `m - 3`
applications of `T_odd` the orbit lies in the final exit class `3 mod 8`.
This is a local 2-adic exit-chain statement only, not a global Collatz claim.
-/
theorem level_exit_residue_iterates_to_mod8_three
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : LevelExitResidue m n) :
    (T_odd^[m - 3]) n % 8 = 3 := by
  have h := level_exit_residue_iterated_descent hm (Nat.le_refl (m - 3)) hexit
  unfold LevelExitResidue at h
  have hsub : m - (m - 3) = 3 := by omega
  simpa [hsub] using h

theorem one_lt_of_mod8_eq_three
    {x : Nat}
    (hmod : x % 8 = 3) :
    1 < x := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three hmod with ⟨k, rfl⟩
  omega

theorem one_lt_T_odd_of_iterated_level_exit
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : LevelExitResidue m n) :
    1 < T_odd ((T_odd^[m - 3]) n) := by
  have hmod8 := level_exit_residue_iterates_to_mod8_three hm hexit
  have hx : 1 < (T_odd^[m - 3]) n := one_lt_of_mod8_eq_three hmod8
  exact one_lt_T_odd_of_mod8_eq_three hx hmod8

/--
A level-exit residue reaches the final `3 mod 8` exit class; after one
odd step, the orbit enters the good `1 mod 4` branch, where the local
V2 shrink applies.
This is a local tail-shrink statement, not a global descent below the
original starting value.
-/
theorem level_exit_residue_eventually_good_branch_shrink
    {m n : Nat}
    (hm : 4 ≤ m)
    (hn : 1 < T_odd ((T_odd^[m - 3]) n))
    (hexit : LevelExitResidue m n) :
    (3 * T_odd ((T_odd^[m - 3]) n) + 1) / 4 < T_odd ((T_odd^[m - 3]) n) := by
  have hmod8 := level_exit_residue_iterates_to_mod8_three hm hexit
  exact exit_mod8_three_then_good_shrink
    (n := (T_odd^[m - 3]) n)
    hn
    hmod8

/--
Level-exit residue implies local good-branch shrink on the exit tail.
If `x = T_odd^[m-3] n` lies in `3 mod 8`, then `y = T_odd x` lies in
`1 mod 4` and satisfies `(3y+1)/4 < y`.
This does not assert descent below the original starting value `n`.
-/
theorem level_exit_residue_eventually_good_branch_shrink_of_level_exit
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : LevelExitResidue m n) :
    (3 * T_odd ((T_odd^[m - 3]) n) + 1) / 4 < T_odd ((T_odd^[m - 3]) n) := by
  exact level_exit_residue_eventually_good_branch_shrink
    hm
    (one_lt_T_odd_of_iterated_level_exit hm hexit)
    hexit

end ExitClasses
end CollatzAttemptV2

end KeplerHurwitz
