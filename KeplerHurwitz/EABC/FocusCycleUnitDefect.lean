/-
  Focus-cycle specialization bridge (§5.20).

  Couples concrete frozen F_k focus lengths (Python [B]) to the general
  BooleanRelationAbsorption unit-defect law for ℓ ≥ 2 (Lean [A]).

  Claim wall:
    [A] instances / specializations of Unsat, δ_coh=1, BoolTrace/P_j∈{E01,Z},
        a_abs-edge = Z at each frozen focus length
    [B] Python `focus_cycle_matrices` witnesses that each frozen F_k cycle
        realizes `MatchesUnitDefectPattern` (type histogram (ℓ−1)×E00 + 1×E01)
    [C] NON-CLAIM: no Collatz; no ∀k over F_k; Lean does not reconstruct
        modular F_k arithmetic — only the combinatorial pattern after [B]
        has classified edge matrices

  Docs: docs/eabc_collatz_audit_grid.md §5.19–§5.20
-/

import Mathlib
import KeplerHurwitz.EABC.BooleanRelationAbsorption

namespace KeplerHurwitz.EABC
namespace FocusCycleUnitDefect

open BooleanRelationAbsorption

/-! ## [B→A] Pattern hypothesis -/

/--
Edge labeling matches the combinatorial unit-defect pattern
(exactly one `E01` at index `j`, else `E00`).

Python [B] verifies this for the four frozen focus cycles via type histograms.
When it holds, the [A] conclusions below apply by rewriting to `unitDefectRel`.
-/
def MatchesUnitDefectPattern {ℓ : ℕ} (rel : Fin ℓ → BoolMat2) (j : Fin ℓ) : Prop :=
  rel = unitDefectRel j

/-- Bundled [A] conclusions for one unit-defect basepoint on length `ℓ ≥ 2`. -/
theorem unitDefect_bundle {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (j : Fin ℓ) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ
    ¬ CycleSatisfiable hℓpos (unitDefectRel j) ∧
      (∀ ε : Fin ℓ → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
        (∃ ε : Fin ℓ → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) ∧
          (∀ k : ℕ,
            let L := Nat.iterate rotateLeftList k (unitDefectList ℓ j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (unitDefectRel j j).mul
                (unitDefectRel j (cycleSucc hℓpos j)) =
              BoolMat2.zeroRel := by
  refine ⟨one_E01_rest_E00_not_satisfiable hℓ j,
    (delta_coh_one_E01_rest_E00 hℓ j).1,
    (delta_coh_one_E01_rest_E00 hℓ j).2,
    unitDefect_all_rotations_trace_mem j,
    a_abs_le_two_unitDefect hℓ j⟩

/--
If a concrete cycle labeling matches the unit-defect pattern, it inherits
the full [A] bundle (Unsat, δ_coh=1, BoolTrace under rotation, a_abs-edge).
-/
theorem conclusions_of_matchesUnitDefect {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (j : Fin ℓ)
    (rel : Fin ℓ → BoolMat2) (h : MatchesUnitDefectPattern rel j) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ
    ¬ CycleSatisfiable hℓpos rel ∧
      (∀ ε : Fin ℓ → Fin 2, 1 ≤ brokenCount hℓpos rel ε) ∧
        (∃ ε : Fin ℓ → Fin 2, brokenCount hℓpos rel ε = 1) ∧
          (∀ k : ℕ,
            let L := Nat.iterate rotateLeftList k (unitDefectList ℓ j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (rel j).mul (rel (cycleSucc hℓpos j)) = BoolMat2.zeroRel := by
  subst h
  exact unitDefect_bundle hℓ j

/-! ## Frozen F_k focus lengths (Python `focus_cycle_matrices`) -/

/--
Canonical frozen focus cycles:
`(k, ℓ) ∈ {(10,26), (11,25), (12,7), (12,6)}`.
Lengths only — modular node lists stay in Python [B].
-/
inductive FrozenFocus where
  | k10_ell26
  | k11_ell25
  | k12_ell7
  | k12_ell6
  deriving DecidableEq, Repr

namespace FrozenFocus

def k : FrozenFocus → ℕ
  | .k10_ell26 => 10
  | .k11_ell25 => 11
  | .k12_ell7 => 12
  | .k12_ell6 => 12

def ell : FrozenFocus → ℕ
  | .k10_ell26 => 26
  | .k11_ell25 => 25
  | .k12_ell7 => 7
  | .k12_ell6 => 6

theorem ell_ge_two (f : FrozenFocus) : 2 ≤ f.ell := by
  cases f <;> decide

end FrozenFocus

/-! ## [A] Specializations at each frozen focus length -/

theorem focus_ell26_unitDefect (j : Fin 26) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 26)
    ¬ CycleSatisfiable hℓpos (unitDefectRel j) ∧
      (∀ ε : Fin 26 → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
        (∃ ε : Fin 26 → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) ∧
          (∀ r : ℕ,
            let L := Nat.iterate rotateLeftList r (unitDefectList 26 j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (unitDefectRel j j).mul
                (unitDefectRel j (cycleSucc hℓpos j)) =
              BoolMat2.zeroRel :=
  unitDefect_bundle (by decide : 2 ≤ 26) j

theorem focus_ell25_unitDefect (j : Fin 25) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 25)
    ¬ CycleSatisfiable hℓpos (unitDefectRel j) ∧
      (∀ ε : Fin 25 → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
        (∃ ε : Fin 25 → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) ∧
          (∀ r : ℕ,
            let L := Nat.iterate rotateLeftList r (unitDefectList 25 j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (unitDefectRel j j).mul
                (unitDefectRel j (cycleSucc hℓpos j)) =
              BoolMat2.zeroRel :=
  unitDefect_bundle (by decide : 2 ≤ 25) j

theorem focus_ell7_unitDefect (j : Fin 7) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 7)
    ¬ CycleSatisfiable hℓpos (unitDefectRel j) ∧
      (∀ ε : Fin 7 → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
        (∃ ε : Fin 7 → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) ∧
          (∀ r : ℕ,
            let L := Nat.iterate rotateLeftList r (unitDefectList 7 j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (unitDefectRel j j).mul
                (unitDefectRel j (cycleSucc hℓpos j)) =
              BoolMat2.zeroRel :=
  unitDefect_bundle (by decide : 2 ≤ 7) j

theorem focus_ell6_unitDefect (j : Fin 6) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 6)
    ¬ CycleSatisfiable hℓpos (unitDefectRel j) ∧
      (∀ ε : Fin 6 → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
        (∃ ε : Fin 6 → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) ∧
          (∀ r : ℕ,
            let L := Nat.iterate rotateLeftList r (unitDefectList 6 j)
            (listProduct L).trace = false ∧
              (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel)) ∧
            (unitDefectRel j j).mul
                (unitDefectRel j (cycleSucc hℓpos j)) =
              BoolMat2.zeroRel :=
  unitDefect_bundle (by decide : 2 ≤ 6) j

/--
Dispatch: each frozen focus length is an instance of `unitDefect_bundle`.
Concrete F_k node lists / edge matrices remain Python [B]; this only
specializes the combinatorial ℓ-law at those lengths.
-/
theorem frozenFocus_unitDefect_unsat :
    (∀ j : Fin 26, ¬ CycleSatisfiable
      (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 26))
      (unitDefectRel j)) ∧
    (∀ j : Fin 25, ¬ CycleSatisfiable
      (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 25))
      (unitDefectRel j)) ∧
    (∀ j : Fin 7, ¬ CycleSatisfiable
      (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 7))
      (unitDefectRel j)) ∧
    (∀ j : Fin 6, ¬ CycleSatisfiable
      (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) (by decide : 2 ≤ 6))
      (unitDefectRel j)) :=
  ⟨fun j => (unitDefect_bundle (by decide : 2 ≤ 26) j).1,
    fun j => (unitDefect_bundle (by decide : 2 ≤ 25) j).1,
    fun j => (unitDefect_bundle (by decide : 2 ≤ 7) j).1,
    fun j => (unitDefect_bundle (by decide : 2 ≤ 6) j).1⟩

/-- `[C]` Non-claim: no ∀k over F_k; no Collatz descent. -/
theorem focus_forall_k_not_claimed : True := trivial

end FocusCycleUnitDefect
end KeplerHurwitz.EABC
