/-
  Finite half-step digraph on odd residues mod 16.

  Turns the image lemmas of `CollatzModularV2` into an explicit edge relation
  and proves the sharp ascent-cycle obstruction:

  * the only directed cycles inside the ascent set {3,7,11,15} are the
    constant-15 loops (`15 → 15`);
  * those loops do not lift to a natural fixed point of the half-step map;
  * ascent residues {3,7,11} reach a descent class in at most two half-steps
    (class 15 excluded: residue self-loop may persist on the digraph).

  Claim wall:
    [A] combinatorial digraph facts from proved half-step images
    [C] / NON-CLAIM: no Baire / ℤ₂ / λ_max→0; no theorem that every
        ℕ-orbit eventually leaves ascent residues; no Collatz proof;
        Approach 1 (Baire) alone insufficient; Approach 3 (Christol) deferred

  Docs: docs/eabc_collatz_audit_grid.md §5.12
-/

import Mathlib
import KeplerHurwitz.EABC.CollatzModularV2

namespace KeplerHurwitz.EABC
namespace CollatzDigraph

open CollatzModularV2

/-! ## Classes [A] -/

/-- Ascent / forced half-step residues (`ν₂ = 1`): `{3,7,11,15}`. -/
def IsAscentClass (r : ℕ) : Prop :=
  r = 3 ∨ r = 7 ∨ r = 11 ∨ r = 15

/-- Immediate descent residues after leaving the ascent set. -/
def IsDescentClass (r : ℕ) : Prop :=
  r = 1 ∨ r = 5 ∨ r = 9 ∨ r = 13

theorem isAscentClass_iff (r : ℕ) :
    IsAscentClass r ↔ r ∈ ({3, 7, 11, 15} : Finset ℕ) := by
  simp [IsAscentClass]

theorem isDescentClass_iff (r : ℕ) :
    IsDescentClass r ↔ r ∈ ({1, 5, 9, 13} : Finset ℕ) := by
  simp [IsDescentClass]

theorem not_ascent_of_descent {r : ℕ} (h : IsDescentClass r) :
    ¬ IsAscentClass r := by
  rcases h with h | h | h | h <;> intro ha <;> rcases ha with ha | ha | ha | ha <;> omega

/-! ## Half-step edges [A] -/

/--
Half-step successor relation on residues, matching
`mod16_{fifteen,seven,three,eleven}_half_image`.
-/
def HalfStepEdge (r r' : ℕ) : Prop :=
  (r = 15 ∧ (r' = 7 ∨ r' = 15)) ∨
  (r = 7 ∧ (r' = 3 ∨ r' = 11)) ∨
  (r = 3 ∧ (r' = 5 ∨ r' = 13)) ∨
  (r = 11 ∧ (r' = 1 ∨ r' = 9))

theorem halfStepEdge_fifteen_self : HalfStepEdge 15 15 :=
  Or.inl ⟨rfl, Or.inr rfl⟩

theorem halfStepEdge_fifteen_seven : HalfStepEdge 15 7 :=
  Or.inl ⟨rfl, Or.inl rfl⟩

theorem halfStepEdge_of_mod16_fifteen {κ : ℕ} (h : κ % 16 = 15) :
    HalfStepEdge 15 (((3 * κ + 1) / 2) % 16) := by
  refine Or.inl ⟨rfl, ?_⟩
  simpa using mod16_fifteen_half_image h

theorem halfStepEdge_of_mod16_seven {κ : ℕ} (h : κ % 16 = 7) :
    HalfStepEdge 7 (((3 * κ + 1) / 2) % 16) := by
  refine Or.inr (Or.inl ⟨rfl, ?_⟩)
  simpa using mod16_seven_half_image h

theorem halfStepEdge_of_mod16_three {κ : ℕ} (h : κ % 16 = 3) :
    HalfStepEdge 3 (((3 * κ + 1) / 2) % 16) := by
  refine Or.inr (Or.inr (Or.inl ⟨rfl, ?_⟩))
  simpa using mod16_three_half_image h

theorem halfStepEdge_of_mod16_eleven {κ : ℕ} (h : κ % 16 = 11) :
    HalfStepEdge 11 (((3 * κ + 1) / 2) % 16) := by
  refine Or.inr (Or.inr (Or.inr ⟨rfl, ?_⟩))
  simpa using mod16_eleven_half_image h

theorem halfStepEdge_src_ascent {r r' : ℕ} (h : HalfStepEdge r r') :
    IsAscentClass r := by
  rcases h with ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ <;> simp [IsAscentClass, hr]

theorem halfStepEdge_three_targets {r' : ℕ} (h : HalfStepEdge 3 r') :
    r' = 5 ∨ r' = 13 := by
  rcases h with ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨_, ht⟩ | ⟨hr, _⟩ <;> first | exact ht | omega

theorem halfStepEdge_eleven_targets {r' : ℕ} (h : HalfStepEdge 11 r') :
    r' = 1 ∨ r' = 9 := by
  rcases h with ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨_, ht⟩ <;> first | exact ht | omega

theorem halfStepEdge_seven_targets {r' : ℕ} (h : HalfStepEdge 7 r') :
    r' = 3 ∨ r' = 11 := by
  rcases h with ⟨hr, _⟩ | ⟨_, ht⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ <;> first | exact ht | omega

theorem halfStepEdge_fifteen_targets {r' : ℕ} (h : HalfStepEdge 15 r') :
    r' = 7 ∨ r' = 15 := by
  rcases h with ⟨_, ht⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ | ⟨hr, _⟩ <;> first | exact ht | omega

/-- Classes 3 and 11 are sinks out of the ascent subgraph. -/
theorem halfStepEdge_three_leaves_ascent {r' : ℕ} (h : HalfStepEdge 3 r') :
    IsDescentClass r' ∧ ¬ IsAscentClass r' := by
  have ht := halfStepEdge_three_targets h
  refine ⟨?_, ?_⟩
  · rcases ht with ht | ht <;> simp [IsDescentClass, ht]
  · exact not_ascent_of_descent (by rcases ht with ht | ht <;> simp [IsDescentClass, ht])

theorem halfStepEdge_eleven_leaves_ascent {r' : ℕ} (h : HalfStepEdge 11 r') :
    IsDescentClass r' ∧ ¬ IsAscentClass r' := by
  have ht := halfStepEdge_eleven_targets h
  refine ⟨?_, ?_⟩
  · rcases ht with ht | ht <;> simp [IsDescentClass, ht]
  · exact not_ascent_of_descent (by rcases ht with ht | ht <;> simp [IsDescentClass, ht])

/-! ## Cycle obstruction inside the ascent set [A] -/

/-- Successor on a length-`n` cycle (wrap-around). -/
def cycleSucc {n : ℕ} (hn : 0 < n) (i : Fin n) : Fin n :=
  ⟨(i.val + 1) % n, Nat.mod_lt _ hn⟩

/--
`[A]` Every directed cycle in the half-step digraph that stays inside the
ascent set `{3,7,11,15}` is constantly `15`.

In particular there is no ascent-only cycle through `7`, `3`, or `11`.
The residue self-loop `15 → 15` remains; it does not lift to a ℕ fixed point
(see `half_step_ne_self_of_mod16_fifteen`).
-/
theorem ascent_cycle_all_fifteen {n : ℕ} (hn : 0 < n)
    (ρ : Fin n → ℕ)
    (hasc : ∀ i, IsAscentClass (ρ i))
    (hedge : ∀ i, HalfStepEdge (ρ i) (ρ (cycleSucc hn i))) :
    ∀ i, ρ i = 15 := by
  -- no vertex equals 3
  have no3 : ∀ i, ρ i ≠ 3 := by
    intro i h3
    have hedge_i := hedge i
    have : HalfStepEdge 3 (ρ (cycleSucc hn i)) := by simpa [h3] using hedge_i
    exact (halfStepEdge_three_leaves_ascent this).2 (hasc (cycleSucc hn i))
  -- no vertex equals 11
  have no11 : ∀ i, ρ i ≠ 11 := by
    intro i h11
    have hedge_i := hedge i
    have : HalfStepEdge 11 (ρ (cycleSucc hn i)) := by simpa [h11] using hedge_i
    exact (halfStepEdge_eleven_leaves_ascent this).2 (hasc (cycleSucc hn i))
  -- no vertex equals 7 (successor would be 3 or 11)
  have no7 : ∀ i, ρ i ≠ 7 := by
    intro i h7
    have hedge_i := hedge i
    have : HalfStepEdge 7 (ρ (cycleSucc hn i)) := by simpa [h7] using hedge_i
    have ht := halfStepEdge_seven_targets this
    rcases ht with ht | ht
    · exact no3 (cycleSucc hn i) ht
    · exact no11 (cycleSucc hn i) ht
  intro i
  have hi := hasc i
  rcases hi with hi | hi | hi | hi
  · exact (no3 i hi).elim
  · exact (no7 i hi).elim
  · exact (no11 i hi).elim
  · exact hi

/--
`[A]` There is no ascent-only half-step cycle that visits a non-`15` residue.
-/
theorem no_ascent_cycle_with_non_fifteen {n : ℕ} (hn : 0 < n)
    (ρ : Fin n → ℕ)
    (hasc : ∀ i, IsAscentClass (ρ i))
    (hedge : ∀ i, HalfStepEdge (ρ i) (ρ (cycleSucc hn i)))
    {j : Fin n} (hj : ρ j ≠ 15) :
    False := by
  have := ascent_cycle_all_fifteen hn ρ hasc hedge j
  exact hj this

/-- Class 7 cannot lie on any ascent-only half-step cycle. -/
theorem seven_not_on_ascent_cycle {n : ℕ} (hn : 0 < n)
    (ρ : Fin n → ℕ)
    (hasc : ∀ i, IsAscentClass (ρ i))
    (hedge : ∀ i, HalfStepEdge (ρ i) (ρ (cycleSucc hn i)))
    {j : Fin n} (hj : ρ j = 7) :
    False := by
  have hall := ascent_cycle_all_fifteen hn ρ hasc hedge j
  omega

/-! ## Residue loop at 15 does not lift to a ℕ fixed point [A] -/

/--
`[A]` If `κ ≡ 15 (mod 16)`, the forced half-step image is never `κ` itself.
(Algebra: `(3κ+1)/2 = κ` ⇒ `κ = -1`, impossible in `ℕ`.)
-/
theorem half_step_ne_self_of_mod16_fifteen {κ : ℕ} (h : κ % 16 = 15) :
    (3 * κ + 1) / 2 ≠ κ := by
  intro heq
  have h2 : 2 ∣ 3 * κ + 1 := (two_dvd_not_four_of_mod16_fifteen h).1
  have : 3 * κ + 1 = κ * 2 := by
    have := congrArg (· * 2) heq
    -- (3κ+1)/2 * 2 = κ * 2
    have hmul := Nat.div_mul_cancel h2
    omega
  omega

/--
`[A under H]` A class-15 accelerated step with image residue 15 is still a
strict core ascent (hence not a fixed point).
-/
theorem mod16_fifteen_self_loop_not_fixed
    {κ κ' v : ℕ} (h16 : κ % 16 = 15)
    (H : CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hκ : 0 < κ) (_hres : κ' % 16 = 15) :
    κ < κ' ∧ κ' ≠ κ := by
  have ⟨_, hasc⟩ := mod16_fifteen_normHyp_ascent h16 H hκ
  exact ⟨hasc, ne_of_gt hasc⟩

/-! ## Exit in ≤2 half-steps from {3,7,11} [A] -/

/--
`[A]` From residue `7`, every length-2 `HalfStepEdge` walk lands in a descent
class. Path shape: `7 → {3,11} → {1,5,9,13}`.
-/
theorem seven_two_step_reaches_descent
    {r1 r2 : ℕ} (e01 : HalfStepEdge 7 r1) (e12 : HalfStepEdge r1 r2) :
    IsDescentClass r2 := by
  have ht := halfStepEdge_seven_targets e01
  rcases ht with h3 | h11
  · have : HalfStepEdge 3 r2 := by simpa [h3] using e12
    exact (halfStepEdge_three_leaves_ascent this).1
  · have : HalfStepEdge 11 r2 := by simpa [h11] using e12
    exact (halfStepEdge_eleven_leaves_ascent this).1

/--
`[A]` Digraph package: every ascent residue other than `15` reaches a descent
class in at most two `HalfStepEdge` steps.

* `3` / `11`: every outgoing edge lands in a descent class (1 step);
* `7`: every length-2 walk lands in a descent class (2 steps).

Class `15` is excluded on purpose: `15 → 15` may persist on the residue digraph.
-/
theorem ascent_non_fifteen_reaches_descent_within_two_edges
    {r : ℕ} (h : IsAscentClass r) (hne : r ≠ 15) :
    (∀ r', HalfStepEdge r r' → IsDescentClass r') ∨
      (∀ r' r'', HalfStepEdge r r' → HalfStepEdge r' r'' → IsDescentClass r'') := by
  rcases h with h | h | h | h
  · subst h; exact Or.inl fun _ e => (halfStepEdge_three_leaves_ascent e).1
  · subst h; exact Or.inr fun _ _ e1 e2 => seven_two_step_reaches_descent e1 e2
  · subst h; exact Or.inl fun _ e => (halfStepEdge_eleven_leaves_ascent e).1
  · exact (hne h).elim

/--
`[A]` Forced half-step image from class `3` lands in a descent residue
(via `mod16_three_half_image`).
-/
theorem half_step_residue_of_mod16_three_is_descent {κ : ℕ} (h : κ % 16 = 3) :
    IsDescentClass (((3 * κ + 1) / 2) % 16) := by
  have him := mod16_three_half_image h
  rcases him with ht | ht <;> simp [IsDescentClass, ht]

/--
`[A]` Forced half-step image from class `11` lands in a descent residue
(via `mod16_eleven_half_image`).
-/
theorem half_step_residue_of_mod16_eleven_is_descent {κ : ℕ} (h : κ % 16 = 11) :
    IsDescentClass (((3 * κ + 1) / 2) % 16) := by
  have him := mod16_eleven_half_image h
  rcases him with ht | ht <;> simp [IsDescentClass, ht]

/--
`[A]` Two forced half-steps from class `7` land in a descent residue
(`7 → {3,11} → {1,5,9,13}` via ModularV2 image lemmas).
-/
theorem two_half_steps_from_mod16_seven_reach_descent {κ : ℕ} (h : κ % 16 = 7) :
    IsDescentClass (((3 * ((3 * κ + 1) / 2) + 1) / 2) % 16) := by
  have h1 := mod16_seven_half_image h
  rcases h1 with h3 | h11
  · have h2 := mod16_three_half_image h3
    rcases h2 with ht | ht <;> simp [IsDescentClass, ht]
  · have h2 := mod16_eleven_half_image h11
    rcases h2 with ht | ht <;> simp [IsDescentClass, ht]

/--
`[A]` Package on ℕ residues: if `κ % 16 ∈ {3,7,11}`, then after at most two
forced half-steps (`ν₂ = 1` on these classes) the residue is in a descent class.

Does **not** apply to class `15` (self-loop on the digraph). Does **not** claim
that every ℕ-orbit eventually leaves the ascent set forever.
-/
theorem ascent_non_fifteen_exits_in_at_most_two_half_steps
    {κ : ℕ} (h : IsAscentClass (κ % 16)) (hne : κ % 16 ≠ 15) :
    IsDescentClass (((3 * κ + 1) / 2) % 16) ∨
      IsDescentClass (((3 * ((3 * κ + 1) / 2) + 1) / 2) % 16) := by
  rcases h with h3 | h7 | h11 | h15
  · exact Or.inl (half_step_residue_of_mod16_three_is_descent h3)
  · exact Or.inr (two_half_steps_from_mod16_seven_reach_descent h7)
  · exact Or.inl (half_step_residue_of_mod16_eleven_is_descent h11)
  · exact (hne h15).elim

/-! ## NON-CLAIM -/

/--
**NON-CLAIM:** No Baire / ℤ₂ / spectral-radius / Christol theorem; no proof that
every natural odd orbit eventually leaves the ascent residue set; Approach 1
alone does not yield ℕ avoidance.
-/
theorem ascent_avoidance_on_nat_not_claimed : True := trivial

end CollatzDigraph
end KeplerHurwitz.EABC
