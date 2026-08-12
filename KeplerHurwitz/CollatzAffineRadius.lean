/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team

Affiner Operator-Cover fuer Syracuse.

1. Affine Algebra (bewiesen).
2. Lokales Eintrittslemma Cylinder10/01 (bewiesen).
3. AttractHitCover (offen als Prop).
4. Reduktion Cover => log-Eintritt (bewiesen relativ zum Cover).

Epistemik: Reduktionslemma; kein Collatz-Beweis.
-/

import Mathlib.Data.Nat.Log
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic

namespace KeplerHurwitz.CollatzAffineRadius

def syracuseStep (n : Nat) : Nat :=
  if n % 2 = 0 then n / 2 else (3 * n + 1) / 2

def syracuseIter : Nat → Nat → Nat
  | n, 0 => n
  | n, k + 1 => syracuseIter (syracuseStep n) k

theorem syracuseIter_add (n a b : Nat) :
    syracuseIter n (a + b) = syracuseIter (syracuseIter n a) b := by
  induction a generalizing n with
  | zero =>
      rw [Nat.zero_add]
      rfl
  | succ a ih =>
      rw [Nat.succ_add, syracuseIter, syracuseIter, ih]

def wordMatches10 (n : Nat) : Prop :=
  n % 2 = 1 ∧ ((3 * n + 1) / 2) % 2 = 0

def wordMatches01 (n : Nat) : Prop :=
  n % 2 = 0 ∧ (n / 2) % 2 = 1

structure PrefixData where
  a : Nat
  k : Nat
  B : Nat
  hk : 0 < k
  ha : a ≤ k

def A (p : PrefixData) : Rat :=
  (3 : Rat) ^ p.a / (2 : Rat) ^ p.k

def T (p : PrefixData) (n : Nat) : Rat :=
  ((3 : Rat) ^ p.a * n + p.B) / (2 : Rat) ^ p.k

def R (p : PrefixData) (n : Nat) (xStar : Rat) : Rat :=
  |T p n - xStar|

theorem T_sub_xStar_eq_A_mul
    (p : PrefixData) (n : Nat) (xStar : Rat)
    (hx : xStar = (p.B : Rat) / ((2 : Rat) ^ p.k - (3 : Rat) ^ p.a))
    (hd : (2 : Rat) ^ p.k - (3 : Rat) ^ p.a ≠ 0) :
    T p n - xStar = A p * ((n : Rat) - xStar) := by
  have hpow : (2 : Rat) ^ p.k ≠ 0 := pow_ne_zero _ (by norm_num)
  unfold T A
  rw [hx]
  field_simp [hd, hpow]
  ring

theorem R_eq_absA_mul_dist
    (p : PrefixData) (n : Nat) (xStar : Rat)
    (hx : xStar = (p.B : Rat) / ((2 : Rat) ^ p.k - (3 : Rat) ^ p.a))
    (hd : (2 : Rat) ^ p.k - (3 : Rat) ^ p.a ≠ 0) :
    R p n xStar = |A p| * |(n : Rat) - xStar| := by
  unfold R
  rw [T_sub_xStar_eq_A_mul p n xStar hx hd, abs_mul]

def prefix10 : PrefixData := ⟨1, 2, 1, by decide, by decide⟩
def prefix01 : PrefixData := ⟨1, 2, 2, by decide, by decide⟩

theorem A_prefix10 : A prefix10 = (3 : Rat) / 4 := by
  simp [A, prefix10]; norm_num

theorem A_prefix01 : A prefix01 = (3 : Rat) / 4 := by
  simp [A, prefix01]; norm_num

theorem R_prefix10 (n : Nat) :
    R prefix10 n 1 = |(3 : Rat) / 4| * |(n : Rat) - 1| := by
  have hx : (1 : Rat) = (1 : Rat) / ((2 : Rat) ^ (2 : Nat) - (3 : Rat) ^ (1 : Nat)) := by
    norm_num
  have hd : (2 : Rat) ^ (2 : Nat) - (3 : Rat) ^ (1 : Nat) ≠ 0 := by
    norm_num
  simpa [A_prefix10] using R_eq_absA_mul_dist prefix10 n 1 hx hd

theorem R_prefix01 (n : Nat) :
    R prefix01 n 2 = |(3 : Rat) / 4| * |(n : Rat) - 2| := by
  have hx : (2 : Rat) = (2 : Rat) / ((2 : Rat) ^ (2 : Nat) - (3 : Rat) ^ (1 : Nat)) := by
    norm_num
  have hd : (2 : Rat) ^ (2 : Nat) - (3 : Rat) ^ (1 : Nat) ≠ 0 := by
    norm_num
  have h := R_eq_absA_mul_dist prefix01 n 2 (by simp [prefix01]; norm_num) hd
  simpa [A_prefix01] using h

def Cylinder10 (n : Nat) : Prop :=
  wordMatches10 n ∧ R prefix10 n 1 ≤ 2

def Cylinder01 (n : Nat) : Prop :=
  wordMatches01 n ∧ R prefix01 n 2 ≤ 2

private theorem dist_le_of_R10 {n : Nat} (hR : R prefix10 n 1 ≤ 2) :
    |(n : Rat) - 1| ≤ (8 : Rat) / 3 := by
  have hR' : (3 : Rat) / 4 * |(n : Rat) - 1| ≤ 2 := by
    have := hR
    rw [R_prefix10, abs_of_pos (by norm_num : (0 : Rat) < 3 / 4)] at this
    exact this
  have hpos : (0 : Rat) < 3 / 4 := by norm_num
  have htmp : |(n : Rat) - 1| ≤ 2 / ((3 : Rat) / 4) :=
    (le_div_iff₀ hpos).mpr (by simpa [mul_comm] using hR')
  rw [show (2 : Rat) / ((3 : Rat) / 4) = (8 : Rat) / 3 by norm_num] at htmp
  exact htmp

private theorem dist_le_of_R01 {n : Nat} (hR : R prefix01 n 2 ≤ 2) :
    |(n : Rat) - 2| ≤ (8 : Rat) / 3 := by
  have hR' : (3 : Rat) / 4 * |(n : Rat) - 2| ≤ 2 := by
    have := hR
    rw [R_prefix01, abs_of_pos (by norm_num : (0 : Rat) < 3 / 4)] at this
    exact this
  have hpos : (0 : Rat) < 3 / 4 := by norm_num
  have htmp : |(n : Rat) - 2| ≤ 2 / ((3 : Rat) / 4) :=
    (le_div_iff₀ hpos).mpr (by simpa [mul_comm] using hR')
  rw [show (2 : Rat) / ((3 : Rat) / 4) = (8 : Rat) / 3 by norm_num] at htmp
  exact htmp

theorem cylinder10_implies_eq_one {n : Nat} (h : Cylinder10 n) : n = 1 := by
  rcases h with ⟨⟨hodd, heven⟩, hR⟩
  have hdist := dist_le_of_R10 hR
  have hn_lt : n < 4 := by
    have : |(n : Rat) - 1| < 3 := lt_of_le_of_lt hdist (by norm_num)
    have habs := abs_lt.mp this
    have : (n : Rat) < 4 := by linarith [habs.2]
    exact_mod_cast this
  interval_cases n
  · exact False.elim (by cases hodd)
  · rfl
  · exact False.elim (by cases hodd)
  · exact False.elim (by
      change ((3 * 3 + 1) / 2) % 2 = 0 at heven
      norm_num at heven)

theorem cylinder01_implies_eq_two {n : Nat} (h : Cylinder01 n) : n = 2 := by
  rcases h with ⟨⟨heven, hodd⟩, hR⟩
  have hdist := dist_le_of_R01 hR
  have hn_lt : n < 5 := by
    have : |(n : Rat) - 2| < 3 := lt_of_le_of_lt hdist (by norm_num)
    have habs := abs_lt.mp this
    have : (n : Rat) < 5 := by linarith [habs.2]
    exact_mod_cast this
  interval_cases n
  · exact False.elim (by
      change (0 / 2) % 2 = 1 at hodd
      norm_num at hodd)
  · exact False.elim (by cases heven)
  · rfl
  · exact False.elim (by cases heven)
  · exact False.elim (by
      change (4 / 2) % 2 = 1 at hodd
      norm_num at hodd)

theorem cylinder10_reaches_attractor {n : Nat} (h : Cylinder10 n) :
    syracuseIter n 2 = 1 := by
  rw [cylinder10_implies_eq_one h]
  decide

theorem cylinder01_reaches_attractor {n : Nat} (h : Cylinder01 n) :
    syracuseIter n 2 = 2 := by
  rw [cylinder01_implies_eq_two h]
  decide

/-- Offenes Hit-Cover; numerisch C = 15. -/
def AttractHitCover (C : Nat) : Prop :=
  ∀ n : Nat, 1 < n →
    ∃ k : Nat,
      k ≤ C * Nat.log2 n ∧
      (Cylinder10 (syracuseIter n k) ∨ Cylinder01 (syracuseIter n k))

/-- Reduktion: Cover liefert log-Eintritt. -/
theorem attractHitCover_implies_log_entry
    (C : Nat) (hcover : AttractHitCover C) :
    ∀ n : Nat, 1 < n →
      ∃ t : Nat,
        t ≤ C * Nat.log2 n + 2 ∧
        syracuseIter n t ∈ ({1, 2} : Set Nat) := by
  intro n hn
  rcases hcover n hn with ⟨k, hk, hcyl⟩
  cases hcyl with
  | inl h10 =>
      refine ⟨k + 2, Nat.add_le_add_right hk 2, ?_⟩
      have h := cylinder10_reaches_attractor h10
      simp [syracuseIter_add, h]
  | inr h01 =>
      refine ⟨k + 2, Nat.add_le_add_right hk 2, ?_⟩
      have h := cylinder01_reaches_attractor h01
      simp [syracuseIter_add, h]



def LogHitBound (C : Nat) : Prop :=
  ∀ n : Nat, 1 < n →
    ∃ k : Nat,
      k ≤ C * Nat.log2 n + 2 ∧
      (syracuseIter n k = 1 ∨ syracuseIter n k = 2)

theorem AttractHitCover_implies_LogHitBound
    (C : Nat) (h : AttractHitCover C) : LogHitBound C := by
  intro n hn
  rcases attractHitCover_implies_log_entry C h n hn with ⟨t, ht, hmem⟩
  refine ⟨t, ht, ?_⟩
  have : syracuseIter n t = 1 ∨ syracuseIter n t = 2 := by
    simpa [Set.mem_insert_iff, Set.mem_singleton_iff] using hmem
  exact this

def AffineLogCovering
    (P : Nat → Nat → PrefixData)
    (xStar : Nat → Nat → Rat)
    (C : Nat) : Prop :=
  ∀ n : Nat, 1 < n →
    ∃ k : Nat,
      k ≤ C * Nat.log2 n ∧
      R (P n k) n (xStar n k) ≤ 2

end KeplerHurwitz.CollatzAffineRadius
