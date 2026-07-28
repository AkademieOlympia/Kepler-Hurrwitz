/-
  Collatz ↔ EABC bridges (claim-walled, no termination claim).

  Three thin formal wires:
    1. odd core residue → mod-12 V₄ channel → pure-axis EABCCoord
    2. Lipschitz unit as conjugation-inverse / reine-E witness
    3. norm multiplicativity along a finite product (bahn certificate)

  Conditional Syracuse norm relations (Bridge 4) live in
  `KeplerHurwitz.EABC.CollatzSyracuseNorm` (imported from `Core`).

  Claim wall:
    [A] axis embedding consistency; Lipschitz unit ↔ conj inverse;
        normSq of list products via `normSq_mul`
    [B] audit-grid reading of Syracuse half-step residues (via CollatzAuditGrid)
    [C] interpretive Collatz association of embeddings / “bahn”; no Collatz proof

  Layer note: channel here is **mod-12** `V₄` (`toV4`), not mod-8 `EABCClass`.
  See `CollatzAuditGrid.mod8_class_not_equal_v4_class_witness_seven`.
-/

import KeplerHurwitz.EABC.Algebra
import KeplerHurwitz.EABC.DiscreteDarboux
import KeplerHurwitz.EABC.V4
import KeplerHurwitz.EABC.NormalForm
import KeplerHurwitz.EABC.QuaternionBridge
import KeplerHurwitz.EABC.CollatzAuditGrid

namespace KeplerHurwitz.EABC
namespace CollatzBridge

open EABCCoord

/-! ## Bridge 1 — odd core → V₄ channel → pure axis [A] / [C] -/

/--
Pure channel axis on the portable `EABCCoord ℤ` carrier
(matches `axisPure` under `toQuaternion`).
-/
def axisPureCoord : V4 → ℤ → EABCCoord ℤ
  | .E, x => ⟨x, 0, 0, 0⟩
  | .A, x => ⟨0, x, 0, 0⟩
  | .B, x => ⟨0, 0, x, 0⟩
  | .C, x => ⟨0, 0, 0, x⟩

@[simp] theorem toQuaternion_axisPureCoord (ch : V4) (x : ℤ) :
    toQuaternion (axisPureCoord ch x) = axisPure ch x := by
  cases ch <;> rfl

theorem normSq_axisPureCoord (ch : V4) (x : ℤ) :
    normSq (axisPureCoord ch x) = x ^ 2 := by
  rw [normSq_eq_Quaternion_normSq, toQuaternion_axisPureCoord]
  exact normSq_axisPure ch x

/--
**[C]** Interpretive label: odd Collatz / Syracuse core `κ` (coprime to 6)
selects the mod-12 \(V_4\) channel. Not a dynamical theorem.
-/
def channelOfOddCore (κ : ℕ) (h : Nat.Coprime κ 6) : V4 :=
  toV4 κ h

/--
**[A]** Embed an odd core residue on the pure axis of its mod-12 \(V_4\) class.
-/
def embedOddCore (κ : ℕ) (h : Nat.Coprime κ 6) : EABCCoord ℤ :=
  axisPureCoord (toV4 κ h) (κ : ℤ)

/-- Embedding lands on the Lipschitz `axisPure` image. -/
theorem toQuaternion_embedOddCore (κ : ℕ) (h : Nat.Coprime κ 6) :
    toQuaternion (embedOddCore κ h) = axisPure (toV4 κ h) κ := by
  simp [embedOddCore, toQuaternion_axisPureCoord]

/--
**[A]** Pure-axis embedding is consistent with the mod-12 residue table
(reuse of `axisPure_toV4_consistent` via `toQuaternion`).
-/
theorem embedOddCore_toV4_consistent {κ : ℕ} (h : Nat.Coprime κ 6) :
    embedOddCore κ h =
      match κ % 12 with
      | 1 => axisPureCoord .E κ
      | 5 => axisPureCoord .A κ
      | 7 => axisPureCoord .B κ
      | _ => axisPureCoord .C κ := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternion_embedOddCore]
  rcases toV4_eq_of_mod12 h with ⟨h1, hE⟩ | ⟨h5, hA⟩ | ⟨h7, hB⟩ | ⟨h11, hC⟩
  · simp [hE, h1, toQuaternion_axisPureCoord, axisPure]
  · simp [hA, h5, toQuaternion_axisPureCoord, axisPure]
  · simp [hB, h7, toQuaternion_axisPureCoord, axisPure]
  · simp [hC, h11, toQuaternion_axisPureCoord, axisPure]

/-- Squared norm of the odd-core embedding is `κ²`. -/
theorem normSq_embedOddCore (κ : ℕ) (h : Nat.Coprime κ 6) :
    normSq (embedOddCore κ h) = (κ : ℤ) ^ 2 := by
  simpa [embedOddCore] using normSq_axisPureCoord (toV4 κ h) κ

/-! ### Audit-grid Syracuse witnesses (reuse CollatzAuditGrid) [B]/[A] -/

theorem embed_after_syracuse_7 :
    embedOddCore ((3 * 7 + 1) / 2) (by decide) = axisPureCoord .C 11 := by
  simp [embedOddCore, syracuse_witness_7_to_11, toV4, axisPureCoord]

theorem embed_after_syracuse_19 :
    embedOddCore ((3 * 19 + 1) / 2) (by decide) = axisPureCoord .A 29 := by
  simp [embedOddCore, syracuse_witness_19_to_29, toV4, axisPureCoord]

theorem embed_after_syracuse_11 :
    embedOddCore ((3 * 11 + 1) / 2) (by decide) = axisPureCoord .A 17 := by
  simp [embedOddCore, syracuse_witness_11_to_17, toV4, axisPureCoord]

/-- Reaffirm: Bridge 1 uses mod-12 \(V_4\), not mod-8 `EABCClass`. -/
theorem bridge_uses_mod12_not_mod8_witness :
    classify 7 (by decide) = EABCClass.C ∧ channelOfOddCore 7 (by decide) = V4.B :=
  mod8_class_not_equal_v4_class_witness_seven

/-! ## Bridge 2 — Lipschitz unit as reduction / normal-form witness [A]/[C] -/

/-- **[A]** The multiplicative identity is a Lipschitz unit. -/
theorem isLipschitzUnit_one : IsLipschitzUnit (1 : EABCCoord ℤ) := by
  simp [IsLipschitzUnit, normSq, one_def]

/-- **[A]** Pure real axis units `±1`. -/
theorem isLipschitzUnit_axisPureCoord_E_of_abs_one {x : ℤ} (hx : x = 1 ∨ x = -1) :
    IsLipschitzUnit (axisPureCoord .E x) := by
  rcases hx with rfl | rfl <;> simp [IsLipschitzUnit, axisPureCoord, normSq]

/--
**[A]** Reine-E γ with `eFactor = 1` is a Lipschitz unit on `EABCCoord ℤ`
(`residual = 1` ⇒ fully collapsed imaginary residual).
-/
theorem isLipschitzUnit_gamma_reineE_one :
    IsLipschitzUnit (ofQuaternion (gammaFromResidual 1 1 (by decide))) := by
  simp [IsLipschitzUnit, ofQuaternion, gammaFromResidual, toV4, normSq]

/--
**[A]** For reine-E γ (`residual = 1`), squared norm is exactly `eFactor²`.
-/
theorem normSq_gammaFromResidual_reineE (eFactor : ℕ) :
    Quaternion.normSq (gammaFromResidual 1 eFactor (by decide)) = (eFactor : ℤ) ^ 2 := by
  simp [gammaFromResidual, toV4, Quaternion.normSq_def', sq]

/--
**[A]** Reine-E γ is a Lipschitz unit iff `eFactor = 1`.
-/
theorem isLipschitzUnit_gamma_reineE_iff_eFactor_one {eFactor : ℕ} :
    IsLipschitzUnit (ofQuaternion (gammaFromResidual 1 eFactor (by decide))) ↔
      eFactor = 1 := by
  constructor
  · intro h
    have hn :
        Quaternion.normSq (gammaFromResidual 1 eFactor (by decide)) = 1 := by
      have h' : normSq (ofQuaternion (gammaFromResidual 1 eFactor (by decide))) = 1 := h
      rwa [normSq_eq_Quaternion_normSq, toQuaternion_ofQuaternion] at h'
    have hsq : (eFactor : ℤ) ^ 2 = 1 := by
      rwa [normSq_gammaFromResidual_reineE] at hn
    have hx : (eFactor : ℤ) = 1 ∨ (eFactor : ℤ) = -1 :=
      (sq_eq_one_iff (a := (eFactor : ℤ))).mp hsq
    rcases hx with h1 | hm1
    · exact Nat.cast_injective h1
    · have : (0 : ℤ) ≤ eFactor := Nat.cast_nonneg eFactor
      linarith
  · intro he
    subst he
    exact isLipschitzUnit_gamma_reineE_one

/--
**[A]** Lipschitz units are two-sided units via conjugation
(already in `DiscreteDarboux`; restated as the reduction witness).
-/
theorem lipschitzUnit_conj_is_inv (q : EABCCoord ℤ) (h : IsLipschitzUnit q) :
    q * conj q = 1 ∧ conj q * q = 1 :=
  ⟨mul_conj_of_isLipschitzUnit q h, conj_mul_of_isLipschitzUnit q h⟩

/--
**[C]** Interpretive reading only: a Lipschitz unit is a “fully reduced”
quaternion witness (`conj` = inverse). This does **not** assert Collatz
termination, nor that every Collatz step yields a unit.
-/
theorem lipschitzUnit_as_normal_form_witness_marker : True := trivial

/-! ## Bridge 3 — orbit / bahn certificate via norm multiplicativity [A]/[C] -/

theorem one_mul_coord (q : EABCCoord ℤ) : (1 : EABCCoord ℤ) * q = q := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply, toQuaternion_mul, toQuaternion_one,
    one_mul]

theorem mul_one_coord (q : EABCCoord ℤ) : q * (1 : EABCCoord ℤ) = q := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply, toQuaternion_mul, toQuaternion_one,
    mul_one]

theorem mul_assoc_coord (a b c : EABCCoord ℤ) : a * b * c = a * (b * c) := by
  refine (RingEquiv.injective (toQuaternionEquiv (R := ℤ))) ?_
  rw [toQuaternionEquiv_apply, toQuaternionEquiv_apply]
  rw [toQuaternion_mul, toQuaternion_mul, toQuaternion_mul, toQuaternion_mul, mul_assoc]

/-- `foldl (·*·) a xs = a * foldl (·*·) 1 xs`. -/
theorem foldl_mul_eq_mul_foldl (a : EABCCoord ℤ) (xs : List (EABCCoord ℤ)) :
    xs.foldl (· * ·) a = a * xs.foldl (· * ·) 1 := by
  induction xs generalizing a with
  | nil =>
    rw [List.foldl_nil, List.foldl_nil, mul_one_coord]
  | cons x xs ih =>
    rw [List.foldl_cons, ih (a * x), List.foldl_cons, one_mul_coord x, ih x, mul_assoc_coord]

/-- Left-fold product of `EABCCoord` factors (empty product = `1`). -/
def prodCoord (qs : List (EABCCoord ℤ)) : EABCCoord ℤ :=
  qs.foldl (· * ·) 1

theorem prodCoord_nil : prodCoord ([] : List (EABCCoord ℤ)) = 1 := rfl

theorem prodCoord_cons (q : EABCCoord ℤ) (qs : List (EABCCoord ℤ)) :
    prodCoord (q :: qs) = q * prodCoord qs := by
  change (q :: qs).foldl (· * ·) 1 = q * qs.foldl (· * ·) 1
  rw [List.foldl_cons, one_mul_coord q, foldl_mul_eq_mul_foldl]

/-- Product of squared norms along a list. -/
def prodNormSq : List (EABCCoord ℤ) → ℤ
  | [] => 1
  | q :: qs => normSq q * prodNormSq qs

theorem prodNormSq_nil : prodNormSq ([] : List (EABCCoord ℤ)) = 1 := rfl

theorem prodNormSq_cons (q : EABCCoord ℤ) (qs : List (EABCCoord ℤ)) :
    prodNormSq (q :: qs) = normSq q * prodNormSq qs := rfl

/--
**[A]** Norm multiplicativity along a finite product:
`normSq (∏ qᵢ) = ∏ normSq qᵢ`.
-/
theorem normSq_prodCoord (qs : List (EABCCoord ℤ)) :
    normSq (prodCoord qs) = prodNormSq qs := by
  induction qs with
  | nil =>
    simp only [prodCoord_nil, prodNormSq_nil, normSq, one_def]
    norm_num
  | cons q qs ih =>
    rw [prodCoord_cons, prodNormSq_cons, EABCCoord.normSq_mul, ih]

/-- Odd core packaged with its coprimality-to-6 witness. -/
abbrev OddCore := {κ : ℕ // Nat.Coprime κ 6}

/--
**[C]** Thin Collatz association: map a finite list of odd cores
(coprime to 6) to axis embeddings. Audit / certificate carrier only.
-/
def bahnAxisFactors (cores : List OddCore) : List (EABCCoord ℤ) :=
  cores.map fun p => embedOddCore p.1 p.2

/--
**[A]** Bahn certificate: squared norm of the product of axis embeddings
equals the product of the individual squared norms.
-/
theorem normSq_bahnAxisFactors (cores : List OddCore) :
    normSq (prodCoord (bahnAxisFactors cores)) =
      prodNormSq (bahnAxisFactors cores) :=
  normSq_prodCoord _

/-- Concrete two-step witness product on cores 7 and 11. -/
theorem bahn_witness_7_then_11 :
    let cores : List OddCore := [⟨7, by decide⟩, ⟨11, by decide⟩]
    normSq (prodCoord (bahnAxisFactors cores)) =
      (7 : ℤ) ^ 2 * (11 : ℤ) ^ 2 := by
  -- expand embeddings and use norm multiplicativity + axis norms
  simp only [bahnAxisFactors, List.map]
  have h7 : normSq (embedOddCore 7 (by decide)) = (7 : ℤ) ^ 2 :=
    normSq_embedOddCore 7 (by decide)
  have h11 : normSq (embedOddCore 11 (by decide)) = (11 : ℤ) ^ 2 :=
    normSq_embedOddCore 11 (by decide)
  rw [normSq_prodCoord, prodNormSq_cons, prodNormSq_cons, prodNormSq_nil, h7, h11, mul_one]

/-! ## Bridge 4 pointer — conditional Syracuse norm [A under H] -/

/--
Further conditional `normSq` relations under explicit Syracuse hypotheses live in
`KeplerHurwitz.EABC.CollatzSyracuseNorm` (imported from `Core`).
Global Syracuse→descent remains **[OFFEN / NON-CLAIM]**.
-/
theorem syracuse_norm_module_pointer : True := trivial

/-! ## Explicit non-claims -/

/-- This module does not prove the Collatz conjecture. -/
theorem collatz_not_proved_by_eabc_collatz_bridge : True := trivial

end CollatzBridge
end KeplerHurwitz.EABC
