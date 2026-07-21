import Mathlib
import KeplerHurwitz.OddCore
import KeplerHurwitz.Collatz.CollatzChirurgeryBridge

/-!
# Affine cylinder block-descent — arithmetic core

**Collatz?** **NEIN.** This module does **not** prove Collatz.

## Status

| Claim | Tag |
|---|---|
| Affine multiply formula `2^{A_k} T^k(n) = 3^k n + B_k` | `[A]` |
| Exact margin descent / growth under realizing words | `[A]` |
| `2^A ≠ 3^k` for `k > 0` (no zero-margin equality case) | `[A]` |
| Strong cylinder uniform descent via residue `r_a` | `[B]/[C]` stub |
| Adaptive certificate tree well-founded ⇒ Collatz | `[C]` open |
| Fixed universal block length `L` | impossible note `[B]` / easy growth lemma `[A]` |

Naming aligns with `CollatzChirurgeryBridge.oddCoreSyracuse` /
`oddCoreSyracuseIter` / `OddNetDescentStatement`.
-/

namespace KeplerHurwitz.Collatz.AffineCylinderBlockDescent

open KeplerHurwitz
open KeplerHurwitz.Collatz.CollatzChirurgeryBridge

/-! #########################################################################
## Definitions
######################################################################### -/

/--
Valuation word of length `k`: each letter is a positive 2-adic valuation
`a_j = ν₂(3 T^j(n) + 1)`.
-/
structure ValuationWord (k : Nat) where
  a : Fin k → Nat
  ha : ∀ i, 0 < a i

/-- Cumulative valuation `A_j = ∑_{i < j} a_i` (stabilizes for `j ≥ k`). -/
def cumulativeValuation {k : Nat} (a : Fin k → Nat) : Nat → Nat
  | 0 => 0
  | j + 1 =>
      cumulativeValuation a j + if h : j < k then a ⟨j, h⟩ else 0

/-- Block constant `B_k = ∑_{j < k} 3^{k-1-j} · 2^{A_j}`. -/
def blockConstant {k : Nat} (a : Fin k → Nat) : Nat :=
  ∑ j ∈ Finset.range k, 3 ^ (k - 1 - j) * 2 ^ cumulativeValuation a j

/-- Integer block margin `2^{A_k} - 3^k`. -/
def blockMargin {k : Nat} (a : Fin k → Nat) : ℤ :=
  (2 ^ cumulativeValuation a k : ℤ) - (3 ^ k : ℤ)

/--
`n` realizes valuation word `a` under accelerated Syracuse
`T = oddCoreSyracuse`: `n` odd and `ν₂(3 T^j(n)+1) = a_j` for all `j < k`.
-/
def RealizesValuationWord {k : Nat} (n : Nat) (a : Fin k → Nat) : Prop :=
  n % 2 = 1 ∧
    ∀ j : Fin k, padicValNat 2 (3 * oddCoreSyracuseIter j n + 1) = a j

/-! #########################################################################
## Cumulative / block-constant lemmas
######################################################################### -/

lemma cumulativeValuation_zero {k : Nat} (a : Fin k → Nat) :
    cumulativeValuation a 0 = 0 :=
  rfl

lemma cumulativeValuation_succ_of_lt {k j : Nat} (a : Fin k → Nat) (hj : j < k) :
    cumulativeValuation a (j + 1) = cumulativeValuation a j + a ⟨j, hj⟩ := by
  simp [cumulativeValuation, hj]

lemma cumulativeValuation_succ_of_ge {k j : Nat} (a : Fin k → Nat) (hj : k ≤ j) :
    cumulativeValuation a (j + 1) = cumulativeValuation a j := by
  simp [cumulativeValuation, show ¬ j < k by omega]

lemma cumulativeValuation_eq_of_ge {k j : Nat} (a : Fin k → Nat) (hj : k ≤ j) :
    cumulativeValuation a j = cumulativeValuation a k := by
  induction j, hj using Nat.le_induction with
  | base => rfl
  | succ j hjk ih =>
      simp [cumulativeValuation_succ_of_ge a hjk, ih]

lemma cumulativeValuation_prefix {k j : Nat} (a : Fin (k + 1) → Nat) (hj : j ≤ k) :
    cumulativeValuation a j =
      cumulativeValuation (fun i : Fin k => a i.castSucc) j := by
  induction j with
  | zero => rfl
  | succ j ih =>
      have hj' : j < k := by omega
      have hjle : j ≤ k := by omega
      rw [cumulativeValuation_succ_of_lt a (by omega : j < k + 1)]
      rw [cumulativeValuation_succ_of_lt (fun i : Fin k => a i.castSucc) hj']
      simp [ih hjle, Fin.castSucc_mk]

lemma cumulativeValuation_succ_last {k : Nat} (a : Fin (k + 1) → Nat) :
    cumulativeValuation a (k + 1) =
      cumulativeValuation (fun i : Fin k => a i.castSucc) k + a (Fin.last k) := by
  rw [cumulativeValuation_succ_of_lt a (Nat.lt_succ_self k)]
  rw [cumulativeValuation_prefix a (Nat.le_refl k)]
  simp [Fin.last]

lemma blockConstant_zero (a : Fin 0 → Nat) : blockConstant a = 0 := by
  simp [blockConstant]

lemma blockConstant_succ {k : Nat} (a : Fin (k + 1) → Nat) :
    blockConstant a =
      3 * blockConstant (fun i : Fin k => a i.castSucc) +
        2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k := by
  unfold blockConstant
  rw [Finset.sum_range_succ]
  have hleft :
      ∑ j ∈ Finset.range k, 3 ^ (k + 1 - 1 - j) * 2 ^ cumulativeValuation a j =
        ∑ j ∈ Finset.range k, 3 ^ (k - j) * 2 ^ cumulativeValuation a j := by
    refine Finset.sum_congr rfl fun j hj => ?_
    have : j < k := Finset.mem_range.mp hj
    rw [show k + 1 - 1 - j = k - j by omega]
  have hsum :
      ∑ j ∈ Finset.range k, 3 ^ (k - j) * 2 ^ cumulativeValuation a j =
        3 * ∑ j ∈ Finset.range k, 3 ^ (k - 1 - j) * 2 ^ cumulativeValuation a j := by
    rw [Finset.mul_sum]
    refine Finset.sum_congr rfl fun j hj => ?_
    have : j < k := Finset.mem_range.mp hj
    have hsub : k - j = k - 1 - j + 1 := by omega
    rw [hsub, pow_succ]
    ring
  have hpref :
      ∑ j ∈ Finset.range k, 3 ^ (k - 1 - j) * 2 ^ cumulativeValuation a j =
        ∑ j ∈ Finset.range k,
          3 ^ (k - 1 - j) *
            2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) j := by
    refine Finset.sum_congr rfl fun j hj => ?_
    have : j < k := Finset.mem_range.mp hj
    rw [cumulativeValuation_prefix a (Nat.le_of_lt_succ (Nat.lt_succ_of_lt this))]
  have hlast :
      3 ^ (k + 1 - 1 - k) * 2 ^ cumulativeValuation a k =
        2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k := by
    have hexp : k + 1 - 1 - k = 0 := by omega
    rw [hexp, pow_zero, one_mul, cumulativeValuation_prefix a (Nat.le_refl k)]
  rw [hleft, hsum, hpref, hlast]

lemma blockConstant_pos_of_pos {k : Nat} (a : Fin k → Nat) (hk : 0 < k) :
    0 < blockConstant a := by
  have hmem : 0 ∈ Finset.range k := by simp [hk]
  have hterm :
      0 < 3 ^ (k - 1 - 0) * 2 ^ cumulativeValuation a 0 := by
    simp [cumulativeValuation_zero]
  exact Finset.sum_pos' (fun _ _ => Nat.zero_le _) ⟨0, hmem, hterm⟩

/-! #########################################################################
## One-step multiply form
######################################################################### -/

/--
`[A]` One accelerated step in multiply form:
`2^{ν₂(3n+1)} · T(n) = 3n + 1`.
-/
theorem oddCoreSyracuse_mul_twoPow (n : Nat) :
    2 ^ padicValNat 2 (3 * n + 1) * oddCoreSyracuse n = 3 * n + 1 := by
  have hpos : 0 < 3 * n + 1 := by omega
  let h := oddCoreDecompositionOfPos (n := 3 * n + 1) hpos
  have hk : h.k = padicValNat 2 (3 * n + 1) :=
    oddCoreDecomposition_k_eq_nu2 (3 * n + 1) hpos
  have hm : h.m = oddCore (3 * n + 1) := rfl
  simp only [oddCoreSyracuse, oddCoreStep]
  rw [← hk, ← hm, h.hdecomp.symm]

/-! #########################################################################
## Affine block formula `[A]`
######################################################################### -/

lemma realizes_prefix {k : Nat} {n : Nat} {a : Fin (k + 1) → Nat}
    (h : RealizesValuationWord n a) :
    RealizesValuationWord n (fun i : Fin k => a i.castSucc) := by
  refine ⟨h.1, ?_⟩
  intro j
  simpa [Fin.castSucc_mk] using h.2 j.castSucc

lemma realizes_last {k : Nat} {n : Nat} {a : Fin (k + 1) → Nat}
    (h : RealizesValuationWord n a) :
    padicValNat 2 (3 * oddCoreSyracuseIter k n + 1) = a (Fin.last k) := by
  simpa [Fin.last] using h.2 (Fin.last k)

/--
`[A]` Affine cylinder formula (multiply form, no ℕ-division):

`2^{A_k} · T^k(n) = 3^k · n + B_k`

under `RealizesValuationWord n a`.
-/
theorem accelerated_iterate_mul_twoPow {k : Nat} {n : Nat} {a : Fin k → Nat}
    (h : RealizesValuationWord n a) :
    2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n =
      3 ^ k * n + blockConstant a := by
  induction k with
  | zero =>
      simp [cumulativeValuation_zero, oddCoreSyracuseIter, blockConstant_zero]
  | succ k ih =>
      have hpre := realizes_prefix h
      have ih' := ih hpre
      have hν := realizes_last h
      have hstep :
          2 ^ a (Fin.last k) * oddCoreSyracuseIter (k + 1) n =
            3 * oddCoreSyracuseIter k n + 1 := by
        rw [oddCoreSyracuseIter_succ, ← hν, oddCoreSyracuse_mul_twoPow]
      -- multiply the one-step identity by `2^{A_k}`
      have hAk :
          cumulativeValuation a (k + 1) =
            cumulativeValuation (fun i : Fin k => a i.castSucc) k + a (Fin.last k) :=
        cumulativeValuation_succ_last a
      have hmul :
          2 ^ cumulativeValuation a (k + 1) * oddCoreSyracuseIter (k + 1) n =
            2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k *
              (3 * oddCoreSyracuseIter k n + 1) := by
        rw [hAk, pow_add, Nat.mul_assoc, hstep]
      calc
        2 ^ cumulativeValuation a (k + 1) * oddCoreSyracuseIter (k + 1) n
            = 2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k *
                (3 * oddCoreSyracuseIter k n + 1) := hmul
        _ = 3 * (2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k *
                oddCoreSyracuseIter k n) +
              2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k := by
                ring
        _ = 3 * (3 ^ k * n + blockConstant (fun i : Fin k => a i.castSucc)) +
              2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k := by
                rw [ih']
        _ = 3 ^ (k + 1) * n +
              (3 * blockConstant (fun i : Fin k => a i.castSucc) +
                2 ^ cumulativeValuation (fun i : Fin k => a i.castSucc) k) := by
                ring
        _ = 3 ^ (k + 1) * n + blockConstant a := by
              rw [← blockConstant_succ]

/-! #########################################################################
## Margin descent / growth `[A]`
######################################################################### -/

/--
`[A]` Exact descent criterion under positive margin
`3^k < 2^{A_k}`:

`T^k(n) < n` ↔ `B_k < (2^{A_k} - 3^k) · n`.
-/
theorem block_descent_iff {k n : Nat} {a : Fin k → Nat}
    (h : RealizesValuationWord n a)
    (hmargin : 3 ^ k < 2 ^ cumulativeValuation a k) :
    oddCoreSyracuseIter k n < n ↔
      blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n := by
  have hform := accelerated_iterate_mul_twoPow h
  have hpow : 0 < 2 ^ cumulativeValuation a k := Nat.pow_pos (by decide : 0 < 2)
  -- `2^A * T < 2^A * n` ↔ `T < n`
  have hiff_T :
      oddCoreSyracuseIter k n < n ↔
        2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n <
          2 ^ cumulativeValuation a k * n :=
    (Nat.mul_lt_mul_left hpow).symm
  -- rewrite LHS via affine formula
  have hrewrite :
      2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n <
          2 ^ cumulativeValuation a k * n ↔
        3 ^ k * n + blockConstant a < 2 ^ cumulativeValuation a k * n := by
    rw [hform]
  -- rearrange: `3^k n + B < 2^A n` ↔ `B < (2^A - 3^k) n`
  have harr :
      3 ^ k * n + blockConstant a < 2 ^ cumulativeValuation a k * n ↔
        blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n := by
    have hle : 3 ^ k ≤ 2 ^ cumulativeValuation a k := Nat.le_of_lt hmargin
    constructor
    · intro hlt
      rw [Nat.mul_sub_right_distrib]
      omega
    · intro hlt
      rw [Nat.mul_sub_right_distrib] at hlt
      omega
  exact hiff_T.trans (hrewrite.trans harr)

/--
`[A]` Safer one-direction packing: positive margin + `B_k`-bound ⇒ block descent.
-/
theorem block_descent_of_margin {k n : Nat} {a : Fin k → Nat}
    (h : RealizesValuationWord n a)
    (hmargin : 3 ^ k < 2 ^ cumulativeValuation a k)
    (hB : blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n) :
    oddCoreSyracuseIter k n < n :=
  (block_descent_iff h hmargin).mpr hB

/--
`[A]` Growth case: if `2^{A_k} < 3^k` and `B_k > 0` (automatic for `k > 0`),
then `T^k(n) > n` on the realizing cylinder.
-/
theorem block_growth_of_neg_margin {k n : Nat} {a : Fin k → Nat}
    (h : RealizesValuationWord n a)
    (hn : 0 < n)
    (hmargin : 2 ^ cumulativeValuation a k < 3 ^ k)
    (hB : 0 < blockConstant a) :
    n < oddCoreSyracuseIter k n := by
  have hform := accelerated_iterate_mul_twoPow h
  have hpow : 0 < 2 ^ cumulativeValuation a k := Nat.pow_pos (by decide : 0 < 2)
  have hlt :
      2 ^ cumulativeValuation a k * n <
        2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n := by
    calc
      2 ^ cumulativeValuation a k * n
          < 3 ^ k * n := Nat.mul_lt_mul_of_pos_right hmargin hn
      _ ≤ 3 ^ k * n + blockConstant a := Nat.le_add_right _ _
      _ = 2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n := hform.symm
  -- strict because B > 0
  have hlt' :
      2 ^ cumulativeValuation a k * n <
        2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n := by
    have : 3 ^ k * n < 3 ^ k * n + blockConstant a := Nat.lt_add_of_pos_right hB
    calc
      2 ^ cumulativeValuation a k * n
          < 3 ^ k * n := Nat.mul_lt_mul_of_pos_right hmargin hn
      _ < 3 ^ k * n + blockConstant a := this
      _ = 2 ^ cumulativeValuation a k * oddCoreSyracuseIter k n := hform.symm
  exact (Nat.mul_lt_mul_left hpow).mp hlt'

/-- Convenience: growth for nonempty words (uses `B_k > 0`). -/
theorem block_growth_of_neg_margin' {k n : Nat} {a : Fin k → Nat}
    (h : RealizesValuationWord n a)
    (hn : 0 < n)
    (hk : 0 < k)
    (hmargin : 2 ^ cumulativeValuation a k < 3 ^ k) :
    n < oddCoreSyracuseIter k n :=
  block_growth_of_neg_margin h hn hmargin (blockConstant_pos_of_pos a hk)

/-! #########################################################################
## Margin cases: impossibility of `2^A = 3^k` for `k > 0` `[A]`
######################################################################### -/

/--
`[A]` Cases I/II/III zero-margin equality is impossible for `k > 0`:
powers of `2` and `3` never coincide.
-/
theorem two_pow_ne_three_pow {A k : Nat} (hk : 0 < k) : 2 ^ A ≠ 3 ^ k := by
  intro heq
  cases A with
  | zero =>
      have h1 : (1 : Nat) = 3 ^ k := by simpa using heq
      have hlt : 1 < 3 ^ k := Nat.one_lt_pow (Nat.ne_of_gt hk) (by decide : 1 < 3)
      omega
  | succ A =>
      have heven : Even (2 ^ (A + 1)) := by
        refine (Nat.even_pow).2 ⟨by decide, Nat.succ_ne_zero A⟩
      have hodd : Odd (3 ^ k) := Odd.pow (by decide : Odd 3)
      exact Nat.not_even_iff_odd.2 hodd (by simpa [heq] using heven)

/-- Same statement on the block margin: for `k > 0`, `blockMargin ≠ 0`. -/
theorem blockMargin_ne_zero {k : Nat} (a : Fin k → Nat) (hk : 0 < k) :
    blockMargin a ≠ 0 := by
  intro h0
  have heq : (2 ^ cumulativeValuation a k : ℤ) = (3 ^ k : ℤ) := by
    simpa [blockMargin, sub_eq_zero] using h0
  have heqN : 2 ^ cumulativeValuation a k = 3 ^ k := by
    exact_mod_cast heq
  exact two_pow_ne_three_pow hk heqN

/-! #########################################################################
## Optional concrete checks `(1,2)` growth / `(2,2)` descent
######################################################################### -/

/-- Word `(1,2)`. -/
def word_1_2 : Fin 2 → Nat
  | ⟨0, _⟩ => 1
  | ⟨1, _⟩ => 2

/-- Word `(2,2)`. -/
def word_2_2 : Fin 2 → Nat
  | ⟨0, _⟩ => 2
  | ⟨1, _⟩ => 2

theorem cumulativeValuation_word_1_2 :
    cumulativeValuation word_1_2 2 = 3 := by
  decide

theorem blockConstant_word_1_2 : blockConstant word_1_2 = 5 := by
  decide

theorem margin_word_1_2_neg : 2 ^ cumulativeValuation word_1_2 2 < 3 ^ 2 := by
  rw [cumulativeValuation_word_1_2]
  decide

theorem cumulativeValuation_word_2_2 :
    cumulativeValuation word_2_2 2 = 4 := by
  decide

theorem blockConstant_word_2_2 : blockConstant word_2_2 = 7 := by
  decide

theorem margin_word_2_2_pos : 3 ^ 2 < 2 ^ cumulativeValuation word_2_2 2 := by
  rw [cumulativeValuation_word_2_2]
  decide

-- Concrete `ν₂`-checks for the optional examples (compiler-backed).
set_option linter.style.nativeDecide false

/-- `[A]` Concrete growth witness: `n = 11` realizes `(1,2)` and grows. -/
theorem example_word_1_2_growth :
    RealizesValuationWord 11 word_1_2 ∧
      11 < oddCoreSyracuseIter 2 11 := by
  have hν0 : padicValNat 2 (3 * 11 + 1) = 1 := by native_decide
  have hT1 : oddCoreSyracuse 11 = 17 := by
    have hmul := oddCoreSyracuse_mul_twoPow 11
    rw [hν0] at hmul
    omega
  have hν1 : padicValNat 2 (3 * 17 + 1) = 2 := by native_decide
  have hT2 : oddCoreSyracuse 17 = 13 := by
    have hmul := oddCoreSyracuse_mul_twoPow 17
    rw [hν1] at hmul
    omega
  refine ⟨⟨by decide, ?_⟩, ?_⟩
  · intro j
    fin_cases j
    · simpa [word_1_2, oddCoreSyracuseIter] using hν0
    · simpa [word_1_2, oddCoreSyracuseIter, hT1] using hν1
  · simp [oddCoreSyracuseIter, hT1, hT2]

/-- `[A]` Concrete descent witness: `n = 33` realizes `(2,2)` and descends. -/
theorem example_word_2_2_descent :
    RealizesValuationWord 33 word_2_2 ∧
      oddCoreSyracuseIter 2 33 < 33 := by
  have hν0 : padicValNat 2 (3 * 33 + 1) = 2 := by native_decide
  have hT1 : oddCoreSyracuse 33 = 25 := by
    have hmul := oddCoreSyracuse_mul_twoPow 33
    rw [hν0] at hmul
    omega
  have hν1 : padicValNat 2 (3 * 25 + 1) = 2 := by native_decide
  have hT2 : oddCoreSyracuse 25 = 19 := by
    have hmul := oddCoreSyracuse_mul_twoPow 25
    rw [hν1] at hmul
    omega
  refine ⟨⟨by decide, ?_⟩, ?_⟩
  · intro j
    fin_cases j
    · simpa [word_2_2, oddCoreSyracuseIter] using hν0
    · simpa [word_2_2, oddCoreSyracuseIter, hT1] using hν1
  · simp [oddCoreSyracuseIter, hT1, hT2]

/-! #########################################################################
## Fixed-`L` note / easy growth for the all-ones word
######################################################################### -/

/--
All-ones valuation word of length `L` (each step has `ν₂ = 1`).
For `L ≥ 2` one has `2^L < 3^L`, so every realizing odd `n` *grows*
under `T^L` (`block_growth_of_neg_margin'`).

Consequently there is **no** uniform fixed block length `L ≥ 2` that
forces descent on every odd cylinder of that length — any such cover must
be adaptive in the valuation word (and typically in `L`).

Related Mersenne probe: `n_L = 2^{L+1} - 1` is the classical all-ones
start for length-`L` runs of valuation `1` (cf. octonion `witnessStart`).
-/
def allOnesWord (L : Nat) : Fin L → Nat := fun _ => 1

theorem cumulativeValuation_allOnes (L : Nat) :
    cumulativeValuation (allOnesWord L) L = L := by
  induction L with
  | zero => rfl
  | succ L ih =>
      rw [cumulativeValuation_succ_of_lt (allOnesWord (L + 1)) (Nat.lt_succ_self L)]
      have hpref :
          cumulativeValuation (allOnesWord (L + 1)) L =
            cumulativeValuation (allOnesWord L) L := by
        rw [cumulativeValuation_prefix (allOnesWord (L + 1)) (Nat.le_refl L)]
        rfl
      rw [hpref, ih]
      simp [allOnesWord]

/--
`[A]` Fixed length-`L≥2` all-ones blocks are growth blocks whenever realized.
No universal fixed-`L` descent cover via the minimal word.
-/
theorem allOnes_block_growth {L n : Nat}
    (hL : 2 ≤ L)
    (hn : 0 < n)
    (h : RealizesValuationWord n (allOnesWord L)) :
    n < oddCoreSyracuseIter L n := by
  have hk : 0 < L := by omega
  have hmargin : 2 ^ cumulativeValuation (allOnesWord L) L < 3 ^ L := by
    rw [cumulativeValuation_allOnes]
    -- `2^L < 3^L` for `L ≥ 1`, hence for `L ≥ 2`
    exact Nat.pow_lt_pow_left (by decide : 2 < 3) (by omega : L ≠ 0)
  exact block_growth_of_neg_margin' h hn hk hmargin

/-! #########################################################################
## Strong cylinder `[B]/[C]` stub
######################################################################### -/

/--
`[B]/[C]` **Stub** — strong cylinder uniform descent.

Intended reading: there exists a residue `r_a (mod 2^{A_k})` such that every
odd `n ≡ r_a` realizes `a` and, under positive margin + the uniform `B_k`-bound
(automatic for all `n` past a finite threshold when margin `> 0`), the whole
cylinder descends in exactly `k` accelerated steps.

Residue / Hensel cylinder structure is **not** formalized here; affine margin
arithmetic is the proved core above.
-/
def StrongCylinderUniformDescent {k : Nat} (a : Fin k → Nat) : Prop :=
  ∃ r : Nat,
    ∀ n : Nat, n % 2 = 1 → n % (2 ^ cumulativeValuation a k) = r →
      RealizesValuationWord n a ∧
        (3 ^ k < 2 ^ cumulativeValuation a k →
          blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n →
            oddCoreSyracuseIter k n < n)

/-! #########################################################################
## Packaging → OddNetDescent `[A]` conditional / cover `[C]`
######################################################################### -/

/--
Positive-margin affine cylinder cover of all odd `n > 1`.

**Not claimed.** This is the arithmetic packaging of an adaptive certificate
search; existence for every odd `n > 1` is open.
-/
def AffineCylinderPositiveMarginCover : Prop :=
  ∀ n, 1 < n → n % 2 = 1 →
    ∃ (k : Nat) (a : Fin k → Nat),
      0 < k ∧
        RealizesValuationWord n a ∧
          3 ^ k < 2 ^ cumulativeValuation a k ∧
            blockConstant a < (2 ^ cumulativeValuation a k - 3 ^ k) * n

/--
`[A]` Packaging only: a positive-margin affine cover implies
`OddNetDescentStatement` (hence, via `CollatzChirurgeryBridge`, odd-core
termination / OddCore Collatz — still conditional on the cover).
-/
theorem OddNetDescent_of_affine_cylinder_cover
    (h : AffineCylinderPositiveMarginCover) :
    OddNetDescentStatement := by
  intro n hn ho
  rcases h n hn ho with ⟨k, a, hk, hreal, hmargin, hB⟩
  exact ⟨k, hk, block_descent_of_margin hreal hmargin hB⟩

/--
`[A]` Conditional chain into the ChirurgeryBridge termination arrow.
Still **not** Collatz: depends on the open cover hypothesis.
-/
theorem odd_descent_reaches_one_of_affine_cylinder_cover
    (h : AffineCylinderPositiveMarginCover) :
    ∀ n, 0 < n → n % 2 = 1 → ∃ t, oddCoreSyracuseIter t n = 1 :=
  odd_descent_implies_reaches_one (OddNetDescent_of_affine_cylinder_cover h)

/-! #########################################################################
## Open `[C]` — adaptive certificate tree
######################################################################### -/

/--
Open `[C]`: well-founded adaptive cylinder certificate tree ⇒ Collatz.

An adaptive tree assigns to each odd `n > 1` a realizing valuation word with
positive-margin descent (or a finite search that finds one), and well-foundedness
of the resulting shrink relation yields termination via
`odd_descent_implies_reaches_one` / `descent_implies_reaches_one`.

**Not claimed proved.** Named hypothesis only — no `axiom`, no fake `exact`.
-/
def AdaptiveCylinderCertificateTreeWellFounded : Prop :=
  AffineCylinderPositiveMarginCover

/-- Status marker: Collatz via adaptive cylinder certificates remains open. -/
def AdaptiveCylinderCollatzGap : Prop :=
  AdaptiveCylinderCertificateTreeWellFounded

end KeplerHurwitz.Collatz.AffineCylinderBlockDescent
