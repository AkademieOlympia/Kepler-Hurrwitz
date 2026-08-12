/-
  Boolean absorption for 2×2 OR-AND matrices (§5.19–§5.20 freeze).

  Terminology:
    M_abs  = {E00, E01, Z}     — Absorptionshalbgruppe (kein I)
    M_abs¹ = {I, E00, E01, Z} — Absorptionsmonoid (Monoidisierung)

  κ_loc = a_abs = 2: lokale zweistufige Absorption mit globalem Einheitsdefekt.
  NOT κ = ℓ.

  Claim wall: [A] boolean relations only; [C] no Collatz / Flip / ∀k.
  Focus F_k length instances: KeplerHurwitz.EABC.FocusCycleUnitDefect.
  Docs: docs/eabc_collatz_audit_grid.md §5.19–§5.20
-/

import Mathlib
import KeplerHurwitz.EABC.ModularSyracuseLift

namespace KeplerHurwitz.EABC
namespace BooleanRelationAbsorption

open ModularSyracuseLift

/-! ## Concrete 2×2 boolean matrices -/

structure BoolMat2 where
  a00 : Bool
  a01 : Bool
  a10 : Bool
  a11 : Bool
  deriving DecidableEq, Repr

namespace BoolMat2

def entry (M : BoolMat2) : Fin 2 → Fin 2 → Bool
  | 0, 0 => M.a00
  | 0, 1 => M.a01
  | 1, 0 => M.a10
  | 1, 1 => M.a11

/-- OR-AND product. -/
def mul (A B : BoolMat2) : BoolMat2 where
  a00 := (A.a00 && B.a00) || (A.a01 && B.a10)
  a01 := (A.a00 && B.a01) || (A.a01 && B.a11)
  a10 := (A.a10 && B.a00) || (A.a11 && B.a10)
  a11 := (A.a10 && B.a01) || (A.a11 && B.a11)

def trace (M : BoolMat2) : Bool := M.a00 || M.a11

def allows (M : BoolMat2) (a b : Fin 2) : Prop := M.entry a b = true

instance (M : BoolMat2) (a b : Fin 2) : Decidable (M.allows a b) :=
  inferInstanceAs (Decidable (M.entry a b = true))

def Nonempty (M : BoolMat2) : Prop := ∃ a b : Fin 2, M.allows a b

instance (M : BoolMat2) : Decidable M.Nonempty :=
  inferInstanceAs (Decidable (∃ a b : Fin 2, M.allows a b))

def identityRel : BoolMat2 := ⟨true, false, false, true⟩
def zeroRel : BoolMat2 := ⟨false, false, false, false⟩
def E00 : BoolMat2 := ⟨true, false, false, false⟩
def E01 : BoolMat2 := ⟨false, true, false, false⟩

/-- Associativity via exhaustive `cases` + `decide` (not `rfl`). -/
theorem mul_assoc (A B C : BoolMat2) :
    (A.mul B).mul C = A.mul (B.mul C) := by
  cases A; cases B; cases C
  decide +revert

/-- `tr(A⊙B)=tr(B⊙A)` via `cases` + `decide`. -/
theorem trace_mul_comm (A B : BoolMat2) :
    (A.mul B).trace = (B.mul A).trace := by
  cases A; cases B
  decide +revert

theorem identity_mul (A : BoolMat2) : identityRel.mul A = A := by
  cases A; decide +revert

theorem mul_identity (A : BoolMat2) : A.mul identityRel = A := by
  cases A; decide +revert

theorem zero_mul (A : BoolMat2) : zeroRel.mul A = zeroRel := by
  cases A; decide +revert

theorem mul_zero (A : BoolMat2) : A.mul zeroRel = zeroRel := by
  cases A; decide +revert

theorem E00_mul_E00 : E00.mul E00 = E00 := by decide
theorem E00_mul_E01 : E00.mul E01 = E01 := by decide
theorem E01_mul_E00 : E01.mul E00 = zeroRel := by decide
theorem E01_mul_E01 : E01.mul E01 = zeroRel := by decide

/-- Alias: local absorption witness. -/
theorem E01_E00_absorbs : E01.mul E00 = zeroRel := E01_mul_E00

theorem E00_nonempty : E00.Nonempty := ⟨0, 0, by decide⟩
theorem E01_nonempty : E01.Nonempty := ⟨0, 1, by decide⟩
theorem E00_ne_zero : E00 ≠ zeroRel := by decide
theorem E01_ne_zero : E01 ≠ zeroRel := by decide

/--
Nullprodukt = kein kompatibler Zwischenzustand:
`E01.mul E00 = 0` iff ¬∃ a b c, E01.allows a b ∧ E00.allows b c.
-/
theorem E01_then_E00_unsatisfiable :
    ¬ ∃ a b c : Fin 2, E01.allows a b ∧ E00.allows b c := by
  decide

/-- Upper bound κ_loc ≤ 2 / a_abs ≤ 2. -/
theorem kappa_loc_le_two : E01.mul E00 = zeroRel := E01_mul_E00

/-- Lower bound: generators nonempty ⇒ length-1 products ≠ zero. -/
theorem kappa_loc_ge_two :
    E00.Nonempty ∧ E01.Nonempty ∧ E00 ≠ zeroRel ∧ E01 ≠ zeroRel :=
  ⟨E00_nonempty, E01_nonempty, E00_ne_zero, E01_ne_zero⟩

theorem kappa_loc_eq_a_abs_two :
    (E01.mul E00 = zeroRel) ∧ E00.Nonempty ∧ E01.Nonempty ∧
      E00 ≠ zeroRel ∧ E01 ≠ zeroRel :=
  ⟨E01_mul_E00, E00_nonempty, E01_nonempty, E00_ne_zero, E01_ne_zero⟩

theorem trace_E01 : E01.trace = false := by decide
theorem trace_zero : zeroRel.trace = false := by decide

end BoolMat2

/-! ## Functional aliases (`Fin 2 → Fin 2 → Bool`) -/

def toFun (M : BoolMat2) : Fin 2 → Fin 2 → Bool := M.entry

def ofFun (f : Fin 2 → Fin 2 → Bool) : BoolMat2 :=
  ⟨f 0 0, f 0 1, f 1 0, f 1 1⟩

theorem toFun_ofFun (f : Fin 2 → Fin 2 → Bool) : toFun (ofFun f) = f := by
  funext i j; fin_cases i <;> fin_cases j <;> rfl

theorem ofFun_toFun (M : BoolMat2) : ofFun (toFun M) = M := by
  cases M; rfl

theorem toFun_mul (A B : BoolMat2) :
    boolMatMul (toFun A) (toFun B) = toFun (A.mul B) := by
  funext i j
  fin_cases i <;> fin_cases j <;> cases A <;> cases B <;> decide +revert

theorem ofFun_boolMatMul (A B : Fin 2 → Fin 2 → Bool) :
    ofFun (boolMatMul A B) = (ofFun A).mul (ofFun B) := rfl

/-- Associativity: functional form via `BoolMat2.mul_assoc` (cases+decide). -/
theorem boolMatMul_assoc (A B C : Fin 2 → Fin 2 → Bool) :
    boolMatMul (boolMatMul A B) C = boolMatMul A (boolMatMul B C) := by
  have h := BoolMat2.mul_assoc (ofFun A) (ofFun B) (ofFun C)
  have hL :
      ofFun (boolMatMul (boolMatMul A B) C) =
        ((ofFun A).mul (ofFun B)).mul (ofFun C) := by
    simp only [ofFun_boolMatMul]
  have hR :
      ofFun (boolMatMul A (boolMatMul B C)) =
        (ofFun A).mul ((ofFun B).mul (ofFun C)) := by
    simp only [ofFun_boolMatMul]
  have : ofFun (boolMatMul (boolMatMul A B) C) =
      ofFun (boolMatMul A (boolMatMul B C)) := by
    simp only [hL, hR, h]
  simpa [toFun_ofFun] using congrArg toFun this

theorem boolTrace_mul_comm (A B : Fin 2 → Fin 2 → Bool) :
    boolTrace (boolMatMul A B) = boolTrace (boolMatMul B A) := by
  have h := BoolMat2.trace_mul_comm (ofFun A) (ofFun B)
  have hL : boolTrace (boolMatMul A B) = ((ofFun A).mul (ofFun B)).trace := by
    simp [boolTrace, BoolMat2.trace, BoolMat2.mul, ofFun, boolMatMul]
  have hR : boolTrace (boolMatMul B A) = ((ofFun B).mul (ofFun A)).trace := by
    simp [boolTrace, BoolMat2.trace, BoolMat2.mul, ofFun, boolMatMul]
  exact hL.trans (h.trans hR.symm)

def E00 : Fin 2 → Fin 2 → Bool := toFun BoolMat2.E00
def E01 : Fin 2 → Fin 2 → Bool := toFun BoolMat2.E01
def zeroRel : Fin 2 → Fin 2 → Bool := toFun BoolMat2.zeroRel
def identityRel : Fin 2 → Fin 2 → Bool := toFun BoolMat2.identityRel

theorem E01_mul_E00 : boolMatMul E01 E00 = zeroRel := by
  funext i j; fin_cases i <;> fin_cases j <;> decide

/-- Alias: local absorption witness. -/
theorem E01_E00_absorbs : boolMatMul E01 E00 = zeroRel := E01_mul_E00

theorem identity_mul (A : Fin 2 → Fin 2 → Bool) :
    boolMatMul identityRel A = A := by
  funext i j
  fin_cases i <;> fin_cases j <;>
    simp [boolMatMul, identityRel, toFun, BoolMat2.identityRel, BoolMat2.entry]

theorem mul_identity (A : Fin 2 → Fin 2 → Bool) :
    boolMatMul A identityRel = A := by
  funext i j
  fin_cases i <;> fin_cases j <;>
    simp [boolMatMul, identityRel, toFun, BoolMat2.identityRel, BoolMat2.entry]

def Allows (M : Fin 2 → Fin 2 → Bool) (ε ε' : Fin 2) : Prop := M ε ε' = true

instance (M : Fin 2 → Fin 2 → Bool) (ε ε' : Fin 2) : Decidable (Allows M ε ε') :=
  inferInstanceAs (Decidable (M ε ε' = true))

/--
Semantische Unsat: Nullprodukt = kein kompatibler Zwischenzustand.
Reduktion auf `BoolMat2.E01_then_E00_unsatisfiable` (nicht falsches `exact h.1`).
-/
theorem E01_then_E00_unsatisfiable :
    ¬ ∃ a b c : Fin 2, Allows E01 a b ∧ Allows E00 b c := by
  intro h
  refine BoolMat2.E01_then_E00_unsatisfiable ?_
  rcases h with ⟨a, b, c, hab, hbc⟩
  exact ⟨a, b, c, hab, hbc⟩

def brokenCount2 (ε0 ε1 : Fin 2) : ℕ :=
  (if E01 ε0 ε1 then 0 else 1) + (if E00 ε1 ε0 then 0 else 1)

theorem brokenCount2_ge_one (ε0 ε1 : Fin 2) : 1 ≤ brokenCount2 ε0 ε1 := by
  fin_cases ε0 <;> fin_cases ε1 <;> decide

theorem defect_one_zero_assignment : brokenCount2 0 0 = 1 := by decide

/--
Einheitsdefekt-Muster für ℓ=2: eine E01-Kante + eine E00-Kante im 2-Zykel
ist unerfüllbar (`[A]` für ℓ=2; siehe generelles Theorem unten).
-/
theorem one_E01_rest_E00_len2_not_satisfiable :
    ¬ ∃ ε0 ε1 : Fin 2, Allows E01 ε0 ε1 ∧ Allows E00 ε1 ε0 := by
  intro h
  refine E01_then_E00_unsatisfiable ?_
  rcases h with ⟨ε0, ε1, h01, h10⟩
  exact ⟨ε0, ε1, ε0, h01, h10⟩

theorem delta_coh_one_E01_E00_len2 :
    (∀ ε0 ε1 : Fin 2, 1 ≤ brokenCount2 ε0 ε1) ∧
      (∃ ε0 ε1 : Fin 2, brokenCount2 ε0 ε1 = 1) :=
  ⟨brokenCount2_ge_one, ⟨0, 0, defect_one_zero_assignment⟩⟩

/-! ## List OR-AND products and word lemma [A] -/

/-- Left-associated OR-AND product; empty product = `identityRel`. -/
def listProduct : List BoolMat2 → BoolMat2
  | [] => BoolMat2.identityRel
  | A :: As => As.foldl BoolMat2.mul A

theorem foldl_mul_mul_left (A B : BoolMat2) (Bs : List BoolMat2) :
    Bs.foldl BoolMat2.mul (A.mul B) = A.mul (Bs.foldl BoolMat2.mul B) := by
  induction Bs generalizing B with
  | nil => rfl
  | cons C Cs ih =>
    simp only [List.foldl_cons]
    rw [BoolMat2.mul_assoc A B C]
    exact ih (B.mul C)

theorem listProduct_cons_mul (A : BoolMat2) (As : List BoolMat2) :
    listProduct (A :: As) = A.mul (listProduct As) := by
  induction As generalizing A with
  | nil => simp [listProduct, BoolMat2.mul_identity]
  | cons B Bs ih =>
    simp only [listProduct, List.foldl_cons]
    simpa [listProduct, List.foldl_cons] using foldl_mul_mul_left A B Bs

theorem listProduct_append (As Bs : List BoolMat2) :
    listProduct (As ++ Bs) = (listProduct As).mul (listProduct Bs) := by
  induction As with
  | nil => simp [listProduct, BoolMat2.identity_mul]
  | cons A As ih =>
    simp only [List.cons_append, listProduct_cons_mul, ih, BoolMat2.mul_assoc]

theorem listProduct_replicate_E00 (n : ℕ) :
    listProduct (List.replicate n BoolMat2.E00) =
      if n = 0 then BoolMat2.identityRel else BoolMat2.E00 := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rw [List.replicate_succ, listProduct_cons_mul]
    by_cases hn : n = 0
    · subst hn
      simp [listProduct, BoolMat2.mul_identity]
    · simp [ih, hn, BoolMat2.E00_mul_E00]

theorem listProduct_E01_replicate_E00 (b : ℕ) :
    listProduct (BoolMat2.E01 :: List.replicate b BoolMat2.E00) =
      if b = 0 then BoolMat2.E01 else BoolMat2.zeroRel := by
  cases b with
  | zero => simp [listProduct]
  | succ b =>
    rw [List.replicate_succ, listProduct_cons_mul, listProduct_cons_mul,
      listProduct_replicate_E00]
    have hE00 :
        BoolMat2.E00.mul (if b = 0 then BoolMat2.identityRel else BoolMat2.E00) =
          BoolMat2.E00 := by
      split_ifs <;> simp [BoolMat2.mul_identity, BoolMat2.E00_mul_E00]
    simp [hE00, BoolMat2.E01_mul_E00]

/--
Wortlemma: `E00^a ⊙ E01 ⊙ E00^b = E01` falls `b = 0`, sonst `Z`.
-/
theorem word_E00_E01_E00 (a b : ℕ) :
    listProduct
        (List.replicate a BoolMat2.E00 ++ BoolMat2.E01 :: List.replicate b BoolMat2.E00) =
      if b = 0 then BoolMat2.E01 else BoolMat2.zeroRel := by
  rw [listProduct_append, listProduct_replicate_E00, listProduct_E01_replicate_E00]
  by_cases hb : b = 0
  · subst hb
    by_cases ha : a = 0
    · simp [ha, BoolMat2.identity_mul]
    · simp [ha, BoolMat2.E00_mul_E01]
  · by_cases ha : a = 0
    · simp [hb, ha, BoolMat2.identity_mul]
    · simp [hb, ha, BoolMat2.mul_zero]

/-! ## Cyclic unit-defect pattern for general ℓ ≥ 2 [A] -/

/-- Cyclic successor on `Fin ℓ`. -/
def cycleSucc {ℓ : ℕ} (hℓ : 0 < ℓ) (i : Fin ℓ) : Fin ℓ :=
  ⟨(i.val + 1) % ℓ, Nat.mod_lt _ hℓ⟩

theorem cycleSucc_ne {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (i : Fin ℓ) :
    cycleSucc (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ) i ≠ i := by
  intro h
  have heq : (i.val + 1) % ℓ = i.val := congrArg Fin.val h
  have hi : i.val < ℓ := i.isLt
  by_cases hlt : i.val + 1 < ℓ
  · rw [Nat.mod_eq_of_lt hlt] at heq
    omega
  · have hi_eq : i.val = ℓ - 1 := by omega
    have hmod : (i.val + 1) % ℓ = 0 := by
      rw [hi_eq]
      have : ℓ - 1 + 1 = ℓ := by omega
      simp [this]
    omega

/-- Edge labels: exactly one `E01` at index `j`, else `E00`. -/
def unitDefectRel {ℓ : ℕ} (j i : Fin ℓ) : BoolMat2 :=
  if i = j then BoolMat2.E01 else BoolMat2.E00

def CycleSatisfiable {ℓ : ℕ} (hℓ : 0 < ℓ) (rel : Fin ℓ → BoolMat2) : Prop :=
  ∃ ε : Fin ℓ → Fin 2, ∀ i : Fin ℓ, (rel i).allows (ε i) (ε (cycleSucc hℓ i))

/--
Lokaler Kern: auf dem Zykel folgt auf `E01` stets eine `E00`-Kante (ℓ ≥ 2),
also lokal unerfüllbar — damit der ganze Zykel unerfüllbar.
-/
theorem one_E01_rest_E00_not_satisfiable {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (j : Fin ℓ) :
    ¬ CycleSatisfiable (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ)
        (unitDefectRel j) := by
  intro h
  rcases h with ⟨ε, hsat⟩
  let hℓpos : 0 < ℓ := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ
  let j' := cycleSucc hℓpos j
  have hj'ne : j' ≠ j := cycleSucc_ne hℓ j
  have hE01 : (unitDefectRel j j).allows (ε j) (ε j') := hsat j
  have hE00 : (unitDefectRel j j').allows (ε j') (ε (cycleSucc hℓpos j')) := hsat j'
  simp only [unitDefectRel, ↓reduceIte] at hE01
  simp only [unitDefectRel, if_neg hj'ne] at hE00
  exact BoolMat2.E01_then_E00_unsatisfiable ⟨ε j, ε j', ε (cycleSucc hℓpos j'), hE01, hE00⟩

/-- Number of violated cycle edges under assignment `ε`. -/
def brokenCount {ℓ : ℕ} (hℓ : 0 < ℓ) (rel : Fin ℓ → BoolMat2) (ε : Fin ℓ → Fin 2) : ℕ :=
  (Finset.univ.filter (fun i : Fin ℓ => ¬ (rel i).allows (ε i) (ε (cycleSucc hℓ i)))).card

def allFalse {ℓ : ℕ} : Fin ℓ → Fin 2 := fun _ => 0

theorem brokenCount_allFalse_unitDefect {ℓ : ℕ} (hℓ : 0 < ℓ) (j : Fin ℓ) :
    brokenCount hℓ (unitDefectRel j) allFalse = 1 := by
  simp only [brokenCount, allFalse]
  have hset :
      Finset.univ.filter (fun i : Fin ℓ => ¬ (unitDefectRel j i).allows 0 0) = {j} := by
    ext i
    simp only [Finset.mem_filter, Finset.mem_univ, Finset.mem_singleton, true_and]
    constructor
    · intro hbr
      by_cases hij : i = j
      · exact hij
      · have hok : (unitDefectRel j i).allows 0 0 := by
          simp only [unitDefectRel, if_neg hij, BoolMat2.allows, BoolMat2.entry]
          rfl
        exact absurd hok hbr
    · intro hij
      subst hij
      simp only [unitDefectRel, ↓reduceIte, BoolMat2.allows, BoolMat2.entry]
      decide
  simp [hset]

theorem brokenCount_pos_of_not_satisfiable {ℓ : ℕ} (hℓ : 0 < ℓ)
    (rel : Fin ℓ → BoolMat2) (hunsat : ¬ CycleSatisfiable hℓ rel) (ε : Fin ℓ → Fin 2) :
    1 ≤ brokenCount hℓ rel ε := by
  by_contra hle
  apply hunsat
  refine ⟨ε, ?_⟩
  intro i
  by_contra hbr
  have hin :
      i ∈ Finset.univ.filter
        (fun i : Fin ℓ => ¬ (rel i).allows (ε i) (ε (cycleSucc hℓ i))) := by
    simp [hbr]
  have hpos :
      0 <
        (Finset.univ.filter
          (fun i : Fin ℓ => ¬ (rel i).allows (ε i) (ε (cycleSucc hℓ i)))).card :=
    Finset.card_pos.mpr ⟨i, hin⟩
  have : 1 ≤ brokenCount hℓ rel ε := by
    simpa [brokenCount] using hpos
  exact hle this

/--
`δ_coh = 1` für das Muster „eine E01, Rest E00“ (ℓ ≥ 2):
unerfüllbar ⇒ Defekt ≥ 1; all-false Zeuge ⇒ Defekt ≤ 1.
-/
theorem delta_coh_one_E01_rest_E00 {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (j : Fin ℓ) :
    let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ
    (∀ ε : Fin ℓ → Fin 2, 1 ≤ brokenCount hℓpos (unitDefectRel j) ε) ∧
      (∃ ε : Fin ℓ → Fin 2, brokenCount hℓpos (unitDefectRel j) ε = 1) := by
  let hℓpos := Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ
  refine ⟨?_, ⟨allFalse, brokenCount_allFalse_unitDefect hℓpos j⟩⟩
  intro ε
  exact brokenCount_pos_of_not_satisfiable hℓpos _
    (one_E01_rest_E00_not_satisfiable hℓ j) ε

/-! ## Monodromy products under basepoint rotation [A] -/

/-- Linear word `E00^j ⊙ E01 ⊙ E00^{ℓ-j-1}`. -/
def unitDefectList (ℓ : ℕ) (j : Fin ℓ) : List BoolMat2 :=
  List.replicate j.val BoolMat2.E00 ++
    BoolMat2.E01 :: List.replicate (ℓ - j.val - 1) BoolMat2.E00

theorem unitDefectList_length (ℓ : ℕ) (j : Fin ℓ) :
    (unitDefectList ℓ j).length = ℓ := by
  simp [unitDefectList]
  have := j.isLt
  omega

/-- Monodromy product: `E01` iff E01 is last factor, else `Z`. -/
theorem unitDefect_product {ℓ : ℕ} (j : Fin ℓ) :
    listProduct (unitDefectList ℓ j) =
      if j.val + 1 = ℓ then BoolMat2.E01 else BoolMat2.zeroRel := by
  simp only [unitDefectList]
  rw [word_E00_E01_E00]
  by_cases hb : ℓ - j.val - 1 = 0
  · have : j.val + 1 = ℓ := by have := j.isLt; omega
    simp [hb, this]
  · have : j.val + 1 ≠ ℓ := by have := j.isLt; omega
    simp [hb, this]

theorem unitDefect_product_mem {ℓ : ℕ} (j : Fin ℓ) :
    listProduct (unitDefectList ℓ j) = BoolMat2.E01 ∨
      listProduct (unitDefectList ℓ j) = BoolMat2.zeroRel := by
  rw [unitDefect_product]
  split_ifs <;> simp

theorem unitDefect_boolTrace_false {ℓ : ℕ} (j : Fin ℓ) :
    (listProduct (unitDefectList ℓ j)).trace = false := by
  rcases unitDefect_product_mem j with h | h <;> simp [h, BoolMat2.trace_E01, BoolMat2.trace_zero]

/-- One-step left rotation of a matrix list. -/
def rotateLeftList : List BoolMat2 → List BoolMat2
  | [] => []
  | x :: xs => xs ++ [x]

theorem listProduct_rotateLeftList :
    ∀ As : List BoolMat2,
      (listProduct (rotateLeftList As)).trace = (listProduct As).trace
  | [] => rfl
  | A :: As => by
    simp only [rotateLeftList]
    have hL : listProduct (As ++ [A]) = (listProduct As).mul A := by
      simpa [listProduct, BoolMat2.mul_identity] using listProduct_append As [A]
    have hR : listProduct (A :: As) = A.mul (listProduct As) := listProduct_cons_mul A As
    rw [hL, hR, BoolMat2.trace_mul_comm]

/-- BoolTrace is invariant under any number of cyclic rotations (arbitrary lists). -/
theorem boolTrace_listProduct_rotate_iterate (As : List BoolMat2) (k : ℕ) :
    (listProduct (Nat.iterate rotateLeftList k As)).trace = (listProduct As).trace := by
  induction k with
  | zero => simp
  | succ k ih =>
    rw [Function.iterate_succ_apply', listProduct_rotateLeftList, ih]

theorem E00_ne_E01 : BoolMat2.E00 ≠ BoolMat2.E01 := by decide

theorem count_E01_cons_E00 (xs : List BoolMat2) :
    (BoolMat2.E00 :: xs).count BoolMat2.E01 = xs.count BoolMat2.E01 := by
  simp [List.count_cons, show (BoolMat2.E00 == BoolMat2.E01) = false from by decide]

theorem count_E01_cons_E01 (xs : List BoolMat2) :
    (BoolMat2.E01 :: xs).count BoolMat2.E01 = xs.count BoolMat2.E01 + 1 := by
  simp [List.count_cons]

theorem listProduct_all_E00 :
    ∀ L : List BoolMat2,
      (∀ x ∈ L, x = BoolMat2.E00) →
        listProduct L = if L.length = 0 then BoolMat2.identityRel else BoolMat2.E00
  | [], _ => rfl
  | x :: xs, h => by
    have hx : x = BoolMat2.E00 := h x List.mem_cons_self
    have hxs : ∀ y ∈ xs, y = BoolMat2.E00 := fun y hy => h y (List.mem_cons_of_mem _ hy)
    rw [listProduct_cons_mul, hx, listProduct_all_E00 xs hxs]
    by_cases hlen : xs.length = 0
    · simp [hlen, BoolMat2.mul_identity]
    · simp [hlen, BoolMat2.E00_mul_E00]

/--
Any list with entries in `{E00,E01}` and exactly one `E01` has
OR-AND product in `{E01,Z}`.
-/
theorem list_one_E01_rest_E00_product_mem :
    ∀ L : List BoolMat2,
      (∀ x ∈ L, x = BoolMat2.E00 ∨ x = BoolMat2.E01) →
      L.count BoolMat2.E01 = 1 →
        listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel
  | [], _, hc => by simp at hc
  | x :: xs, hmem, hc => by
    have hx : x = BoolMat2.E00 ∨ x = BoolMat2.E01 := hmem x List.mem_cons_self
    have hxs : ∀ y ∈ xs, y = BoolMat2.E00 ∨ y = BoolMat2.E01 := fun y hy =>
      hmem y (List.mem_cons_of_mem _ hy)
    rw [listProduct_cons_mul]
    rcases hx with hx | hx
    · have hc' : xs.count BoolMat2.E01 = 1 := by
        rw [hx, count_E01_cons_E00] at hc
        exact hc
      rcases list_one_E01_rest_E00_product_mem xs hxs hc' with h | h
      · simp [hx, h, BoolMat2.E00_mul_E01]
      · simp [hx, h, BoolMat2.mul_zero]
    · have hc' : xs.count BoolMat2.E01 = 0 := by
        rw [hx, count_E01_cons_E01] at hc
        omega
      have hall : ∀ y ∈ xs, y = BoolMat2.E00 := by
        intro y hy
        rcases hxs y hy with h | h
        · exact h
        · have hpos : 0 < xs.count BoolMat2.E01 :=
            List.count_pos_iff.mpr (h ▸ hy)
          omega
      have hprod := listProduct_all_E00 xs hall
      rw [hx, hprod]
      by_cases hlen : xs.length = 0
      · simp [hlen, BoolMat2.mul_identity]
      · simp [hlen, BoolMat2.E01_mul_E00]

theorem rotateLeftList_mem {L : List BoolMat2} {x : BoolMat2}
    (hx : x ∈ rotateLeftList L) : x ∈ L := by
  match L with
  | [] => cases hx
  | y :: ys =>
    simp only [rotateLeftList, List.mem_append, List.mem_singleton] at hx
    exact hx.elim (List.mem_cons_of_mem _) (fun h => h ▸ List.mem_cons_self)

theorem rotateLeftList_count_E01 (L : List BoolMat2) :
    (rotateLeftList L).count BoolMat2.E01 = L.count BoolMat2.E01 := by
  match L with
  | [] => rfl
  | x :: xs =>
    change (xs ++ [x]).count BoolMat2.E01 = (x :: xs).count BoolMat2.E01
    rw [List.count_append]
    simp [List.count_cons, List.count_nil, Nat.add_comm]

theorem rotateLeftList_preserves_unitDefect_shape
    (L : List BoolMat2)
    (hmem : ∀ x ∈ L, x = BoolMat2.E00 ∨ x = BoolMat2.E01)
    (hc : L.count BoolMat2.E01 = 1) :
    (∀ x ∈ rotateLeftList L, x = BoolMat2.E00 ∨ x = BoolMat2.E01) ∧
      (rotateLeftList L).count BoolMat2.E01 = 1 :=
  ⟨fun x hx => hmem x (rotateLeftList_mem hx), (rotateLeftList_count_E01 L).trans hc⟩

theorem unitDefectList_mem_alphabet {ℓ : ℕ} (j : Fin ℓ) :
    ∀ x ∈ unitDefectList ℓ j, x = BoolMat2.E00 ∨ x = BoolMat2.E01 := by
  intro x hx
  simp only [unitDefectList, List.mem_append, List.mem_cons] at hx
  rcases hx with h | h
  · left; exact (List.mem_replicate.mp h).2
  · rcases h with h | h
    · right; exact h
    · left; exact (List.mem_replicate.mp h).2

theorem unitDefectList_count_E01 {ℓ : ℕ} (j : Fin ℓ) :
    (unitDefectList ℓ j).count BoolMat2.E01 = 1 := by
  simp only [unitDefectList, List.count_append, List.count_cons]
  have hL : (List.replicate j.val BoolMat2.E00).count BoolMat2.E01 = 0 := by
    simp [List.count_replicate, show (BoolMat2.E00 == BoolMat2.E01) = false from by decide]
  have hR :
      (List.replicate (ℓ - j.val - 1) BoolMat2.E00).count BoolMat2.E01 = 0 := by
    simp [List.count_replicate, show (BoolMat2.E00 == BoolMat2.E01) = false from by decide]
  simp [hL, hR]

theorem iterate_rotate_preserves_unitDefect_shape
    (L : List BoolMat2)
    (hmem : ∀ x ∈ L, x = BoolMat2.E00 ∨ x = BoolMat2.E01)
    (hc : L.count BoolMat2.E01 = 1) :
    ∀ k : ℕ,
      (∀ x ∈ Nat.iterate rotateLeftList k L, x = BoolMat2.E00 ∨ x = BoolMat2.E01) ∧
        (Nat.iterate rotateLeftList k L).count BoolMat2.E01 = 1 := by
  intro k
  induction k with
  | zero => exact ⟨hmem, hc⟩
  | succ k ih =>
    rw [Function.iterate_succ_apply']
    exact rotateLeftList_preserves_unitDefect_shape _ ih.1 ih.2

/--
After `k` left rotations the list is again a unit-defect word,
hence monodromy ∈ `{E01,Z}` and BoolTrace = false.
-/
theorem unitDefect_rotate_product_mem_trace {ℓ : ℕ} (j : Fin ℓ) (k : ℕ) :
    let L := Nat.iterate rotateLeftList k (unitDefectList ℓ j)
    (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel) ∧
      (listProduct L).trace = false := by
  intro L
  have hshape :=
    iterate_rotate_preserves_unitDefect_shape (unitDefectList ℓ j)
      (unitDefectList_mem_alphabet j) (unitDefectList_count_E01 j) k
  have hmem := list_one_E01_rest_E00_product_mem L hshape.1 hshape.2
  refine ⟨hmem, ?_⟩
  rcases hmem with h | h <;> simp [h, BoolMat2.trace_E01, BoolMat2.trace_zero]

/-- Package: every basepoint rotation has BoolTrace false and product in `{E01,Z}`. -/
theorem unitDefect_all_rotations_trace_mem {ℓ : ℕ} (j : Fin ℓ) :
    ∀ k : ℕ,
      let L := Nat.iterate rotateLeftList k (unitDefectList ℓ j)
      (listProduct L).trace = false ∧
        (listProduct L = BoolMat2.E01 ∨ listProduct L = BoolMat2.zeroRel) := by
  intro k
  have h := unitDefect_rotate_product_mem_trace j k
  exact ⟨h.2, h.1⟩

/-- Circular length-2 product at the E01 edge is `Z` (⇒ `a_abs ≤ 2`). -/
theorem a_abs_le_two_unitDefect {ℓ : ℕ} (hℓ : 2 ≤ ℓ) (j : Fin ℓ) :
    (unitDefectRel j j).mul
        (unitDefectRel j (cycleSucc (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ) j)) =
      BoolMat2.zeroRel := by
  have hj'ne :
      cycleSucc (Nat.lt_of_lt_of_le (by decide : (0 : ℕ) < 2) hℓ) j ≠ j :=
    cycleSucc_ne hℓ j
  simp [unitDefectRel, hj'ne, BoolMat2.E01_mul_E00]

/-- Length-1 factors nonempty ⇒ `a_abs ≥ 2` (already in `kappa_loc_ge_two`). -/
theorem a_abs_ge_two_unitDefect :
    BoolMat2.E00 ≠ BoolMat2.zeroRel ∧ BoolMat2.E01 ≠ BoolMat2.zeroRel :=
  ⟨BoolMat2.E00_ne_zero, BoolMat2.E01_ne_zero⟩

/-- `[C]` Non-claim: no ∀k over F_k. -/
theorem absorption_forall_k_not_claimed : True := trivial

end BooleanRelationAbsorption
end KeplerHurwitz.EABC
