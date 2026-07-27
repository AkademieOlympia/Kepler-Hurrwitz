import Mathlib
import KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-!
# Pre119Draft — FiberWordAffine

Affine remainder `wordC`, division form of `nextOdd`, one-step congruence
stability of Syracuse valuations, and inductive word-level lifting of
`RealizesWord` / `realizedImage` along `n ↦ n + k·2^{S+1}`.

Governance: `[A]` formal, `[B]` diagnostic, `[C]` open.
No Collatz claim; `ClaimsFreeze` remains false. 0 sorry.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine

open KeplerHurwitz
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

/-- Affine numerator remainder of a valuation word. -/
def wordC : List Nat → Nat
  | [] => 0
  | e :: es => 3 ^ es.length + 2 ^ e * wordC es

theorem wordC_nil : wordC [] = 0 := rfl

theorem wordC_cons (e : Nat) (es : List Nat) :
    wordC (e :: es) = 3 ^ es.length + 2 ^ e * wordC es := rfl

theorem factorization_two_eq_padicValNat (n : Nat) :
    n.factorization 2 = padicValNat 2 n :=
  Nat.factorization_def n Nat.prime_two

theorem nextOdd_eq_div (n : Nat) :
    nextOdd n = (3 * n + 1) / 2 ^ valuationStep n := by
  simp only [nextOdd, oddCore, valuationStep]
  rw [factorization_two_eq_padicValNat]

theorem nextOdd_eq_div_of_val {n e : Nat} (hv : valuationStep n = e) :
    nextOdd n = (3 * n + 1) / 2 ^ e := by
  simpa [hv] using nextOdd_eq_div n

private theorem padicValNat_two_pow (e : Nat) : padicValNat 2 (2 ^ e) = e := by
  induction e with
  | zero => simp
  | succ e ih =>
    rw [pow_succ]
    have hpow : 2 ^ e ≠ 0 := pow_ne_zero e (by decide : (2 : Nat) ≠ 0)
    have h2 : (2 : Nat) ≠ 0 := by decide
    rw [padicValNat.mul (p := 2) hpow h2, ih]
    simp

/--
One-step stability: if `valuationStep n = e` and `t ≥ 1`, then
`valuationStep (n + k·2^{e+t}) = e` and
`nextOdd (n + k·2^{e+t}) = nextOdd n + k·3·2^t`.
-/
theorem valuation_nextOdd_add_pow {n e t k : Nat}
    (hv : valuationStep n = e) (ht : 1 ≤ t) :
    valuationStep (n + k * 2 ^ (e + t)) = e ∧
      nextOdd (n + k * 2 ^ (e + t)) =
        nextOdd n + k * 3 * 2 ^ t := by
  have hdiv : 2 ^ e ∣ 3 * n + 1 := by
    have h : 2 ^ valuationStep n ∣ 3 * n + 1 := by
      simpa [valuationStep] using pow_padicValNat_dvd (p := 2) (n := 3 * n + 1)
    rwa [hv] at h
  obtain ⟨m, hm⟩ := hdiv
  have hnext : nextOdd n = m := by
    rw [nextOdd_eq_div_of_val hv, hm,
      Nat.mul_div_cancel_left _ (Nat.pow_pos (by decide : 0 < 2))]
  have hpos : 0 < 3 * n + 1 := by omega
  have hm_odd : Odd m := by
    have hodd : Odd (oddCore (3 * n + 1)) := oddCore_odd_of_pos hpos
    rw [← hnext, nextOdd]
    exact hodd
  have hform :
      3 * (n + k * 2 ^ (e + t)) + 1 = 2 ^ e * (m + k * 3 * 2 ^ t) := by
    have hpow : 2 ^ (e + t) = 2 ^ e * 2 ^ t := Nat.pow_add 2 e t
    calc
      3 * (n + k * 2 ^ (e + t)) + 1
          = 3 * n + 1 + 3 * k * 2 ^ (e + t) := by ring
      _ = 2 ^ e * m + 3 * k * (2 ^ e * 2 ^ t) := by rw [hm, hpow]
      _ = 2 ^ e * (m + k * 3 * 2 ^ t) := by ring
  have hsum_odd : Odd (m + k * 3 * 2 ^ t) := by
    have heven : Even (2 ^ t) := (Nat.even_pow' (by omega : t ≠ 0)).2 (by decide)
    have : Even (k * 3 * 2 ^ t) := heven.mul_left _
    exact hm_odd.add_even this
  have hsum_ne : m + k * 3 * 2 ^ t ≠ 0 := by
    intro h0
    have : ¬ Odd (0 : Nat) := by decide
    exact this (h0 ▸ hsum_odd)
  have hnot2 : ¬ 2 ∣ (m + k * 3 * 2 ^ t) := by
    intro hdvd
    exact (Nat.not_even_iff_odd.mpr hsum_odd) (even_iff_two_dvd.mpr hdvd)
  have hval :
      padicValNat 2 (3 * (n + k * 2 ^ (e + t)) + 1) = e := by
    have hpowne : 2 ^ e ≠ 0 := pow_ne_zero e (by decide : (2 : Nat) ≠ 0)
    rw [hform, padicValNat.mul (p := 2) hpowne hsum_ne, padicValNat_two_pow,
      padicValNat.eq_zero_of_not_dvd hnot2]
    omega
  refine ⟨?_, ?_⟩
  · simpa [valuationStep] using hval
  · have hv' : valuationStep (n + k * 2 ^ (e + t)) = e := by
      simpa [valuationStep] using hval
    have hdiv' : nextOdd (n + k * 2 ^ (e + t)) = m + k * 3 * 2 ^ t := by
      rw [nextOdd_eq_div_of_val hv', hform,
        Nat.mul_div_cancel_left _ (Nat.pow_pos (by decide : 0 < 2))]
    rw [hdiv', hnext]

/-- Oddness is preserved under adding a multiple of `2^{e+t}` with `e+t ≥ 1`. -/
theorem odd_mod_add_pow {n e t k : Nat} (hodd : n % 2 = 1) (hpow : 1 ≤ e + t) :
    (n + k * 2 ^ (e + t)) % 2 = 1 := by
  have heven : Even (2 ^ (e + t)) :=
    (Nat.even_pow' (by omega : e + t ≠ 0)).2 (by decide)
  have : (k * 2 ^ (e + t)) % 2 = 0 := by
    rw [← Nat.dvd_iff_mod_eq_zero, ← even_iff_two_dvd]
    exact heven.mul_left k
  omega

/--
`[A]` Word-level lifting: realizing `E` is stable under
`n ↦ n + k · 2^{sum(E)+1}`.
-/
theorem realizesWord_add_pow {E : List Nat} {n k : Nat}
    (h : RealizesWord E n) :
    RealizesWord E (n + k * 2 ^ (E.sum + 1)) := by
  induction E generalizing n k with
  | nil =>
    trivial
  | cons e es ih =>
    obtain ⟨hodd, hval, hrest⟩ := h
    have ht : 1 ≤ es.sum + 1 := Nat.succ_le_succ (Nat.zero_le _)
    have hsumE : (e :: es).sum + 1 = e + (es.sum + 1) := by
      simp [List.sum_cons]
      omega
    rw [hsumE]
    have hstep := valuation_nextOdd_add_pow (n := n) (e := e) (t := es.sum + 1) (k := k)
      hval ht
    refine ⟨?_, hstep.1, ?_⟩
    · exact odd_mod_add_pow hodd (by omega)
    · have hnext :
          nextOdd (n + k * 2 ^ (e + (es.sum + 1))) =
            nextOdd n + k * 3 * 2 ^ (es.sum + 1) := hstep.2
      rw [hnext]
      simpa [Nat.mul_assoc] using
        ih (n := nextOdd n) (k := k * 3) hrest

/-- Exact affine identity for the realized image (numerator form). -/
theorem realizedImage_mul_pow {E : List Nat} {n : Nat}
    (h : RealizesWord E n) :
    realizedImage n E * 2 ^ E.sum = 3 ^ E.length * n + wordC E := by
  induction E generalizing n with
  | nil =>
    simp [realizedImage, wordC]
  | cons e es ih =>
    obtain ⟨_hodd, hval, hrest⟩ := h
    have ih' := ih hrest
    have hnext : nextOdd n = (3 * n + 1) / 2 ^ e := nextOdd_eq_div_of_val hval
    have hdiv : 2 ^ e ∣ 3 * n + 1 := by
      have hp : 2 ^ valuationStep n ∣ 3 * n + 1 := by
        simpa [valuationStep] using pow_padicValNat_dvd (p := 2) (n := 3 * n + 1)
      rwa [hval] at hp
    obtain ⟨m, hm⟩ := hdiv
    have hm_eq : nextOdd n = m := by
      rw [hnext, hm, Nat.mul_div_cancel_left _ (Nat.pow_pos (by decide : 0 < 2))]
    have hdecomp : nextOdd n * 2 ^ e = 3 * n + 1 := by
      rw [hm_eq, hm]
      ring
    calc
      realizedImage n (e :: es) * 2 ^ (e :: es).sum
          = realizedImage (nextOdd n) es * 2 ^ (e + es.sum) := by
              simp [realizedImage, List.sum_cons]
      _ = realizedImage (nextOdd n) es * (2 ^ es.sum * 2 ^ e) := by
              rw [pow_add, Nat.mul_comm (2 ^ e)]
      _ = (realizedImage (nextOdd n) es * 2 ^ es.sum) * 2 ^ e := by ring
      _ = (3 ^ es.length * nextOdd n + wordC es) * 2 ^ e := by rw [ih']
      _ = 3 ^ es.length * (nextOdd n * 2 ^ e) + wordC es * 2 ^ e := by ring
      _ = 3 ^ es.length * (3 * n + 1) + 2 ^ e * wordC es := by
              rw [hdecomp]; ring
      _ = 3 ^ (es.length + 1) * n + (3 ^ es.length + 2 ^ e * wordC es) := by ring
      _ = 3 ^ (e :: es).length * n + wordC (e :: es) := by
              simp [wordC, List.length_cons]

theorem realizedImage_eq_div {E : List Nat} {n : Nat}
    (h : RealizesWord E n) :
    realizedImage n E = (3 ^ E.length * n + wordC E) / 2 ^ E.sum := by
  have hmul := realizedImage_mul_pow h
  have hpos : 0 < 2 ^ E.sum := Nat.pow_pos (by decide : 0 < 2)
  calc
    realizedImage n E
        = realizedImage n E * 2 ^ E.sum / 2 ^ E.sum :=
          (Nat.mul_div_cancel _ hpos).symm
    _ = (3 ^ E.length * n + wordC E) / 2 ^ E.sum := by rw [hmul]

/--
Contracts from the affine margin: if `wordC E < n · (2^S − 3^m)` and
`3^m ≤ 2^S`, then the realized image is strictly smaller than `n`.
-/
theorem contracts_of_wordC_lt {E : List Nat} {n : Nat}
    (h : RealizesWord E n)
    (hgood : 3 ^ E.length ≤ 2 ^ E.sum)
    (hc : wordC E < n * (2 ^ E.sum - 3 ^ E.length)) :
    realizedImage n E < n := by
  have hmul := realizedImage_mul_pow h
  have hpos : 0 < 2 ^ E.sum := Nat.pow_pos (by decide : 0 < 2)
  have hsub :
      n * (2 ^ E.sum - 3 ^ E.length) = n * 2 ^ E.sum - n * 3 ^ E.length :=
    Nat.mul_sub_left_distrib n _ _
  have hlt : 3 ^ E.length * n + wordC E < n * 2 ^ E.sum := by
    have hc' : wordC E < n * 2 ^ E.sum - n * 3 ^ E.length := by
      rwa [hsub] at hc
    have hle : n * 3 ^ E.length ≤ n * 2 ^ E.sum :=
      Nat.mul_le_mul_left n hgood
    calc
      3 ^ E.length * n + wordC E
          = n * 3 ^ E.length + wordC E := by ring
      _ < n * 3 ^ E.length + (n * 2 ^ E.sum - n * 3 ^ E.length) := by
            exact Nat.add_lt_add_left hc' _
      _ = n * 2 ^ E.sum := Nat.add_sub_of_le hle
  have hlt' : realizedImage n E * 2 ^ E.sum < n * 2 ^ E.sum := by
    rwa [← hmul] at hlt
  have : 2 ^ E.sum * realizedImage n E < 2 ^ E.sum * n := by
    simpa [Nat.mul_comm] using hlt'
  exact (Nat.mul_lt_mul_left hpos).mp this

/-- Margin form specialized to a fixed base that already contracts. -/
theorem contracts_of_le_base {E : List Nat} {n₀ n : Nat}
    (h : RealizesWord E n)
    (hgood : 3 ^ E.length ≤ 2 ^ E.sum)
    (hbase : wordC E < n₀ * (2 ^ E.sum - 3 ^ E.length))
    (hle : n₀ ≤ n) :
    realizedImage n E < n := by
  refine contracts_of_wordC_lt h hgood ?_
  have hmono :
      n₀ * (2 ^ E.sum - 3 ^ E.length) ≤ n * (2 ^ E.sum - 3 ^ E.length) :=
    Nat.mul_le_mul_right _ hle
  exact Nat.lt_of_lt_of_le hbase hmono

end KeplerHurwitz.Collatz.Pre119Draft.FiberWordAffine
