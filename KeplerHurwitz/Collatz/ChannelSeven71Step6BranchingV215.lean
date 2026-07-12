import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCore

/-!
# Kanal-7 V2.15 — Schritt-6-Verzweigung auf Schale `486u + 103`

Governance:
> Schritt-6-Verzweigung klassifiziert ≠ dynamischer Deszent bewiesen
> 2-adische Struktur ≠ dynamischer Deszent

Terminal `S⁵ = 243t + 103` mit geradem `t` (H4, exakte Schale `j = 3`, `c₃ = 103`).
Parametrisierung `t = 2u` liefert `S⁵ = 486u + 103`.

**Nicht behauptet:** globaler Deszent, Kanal-7-Schließung, ε₀-Rang.
-/

namespace KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215

open KeplerHurwitz
open KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.Octonion

abbrev syracuseOddStep (n : Nat) : Nat :=
  ChannelSevenDynamicsV215.syracuseOddStep n

/-- Schritt-5-Terminal auf H4-Schale `j = 3` nach Reparametrisierung `t = 2u`. -/
def step5Terminal (u : Nat) : Nat :=
  486 * u + 103

theorem step5Terminal_eq_deepLiftFiber_j3 (u : Nat) :
    step5Terminal u = deepLiftFiber 3 (2 * u) := by
  rw [step5Terminal, deepLiftFiber_j3_reparam_even]

theorem step5Terminal_constant_j3 :
    step5Terminal 0 = deepLiftConstant 3 := by
  rw [step5Terminal_eq_deepLiftFiber_j3, deepLiftFiber_t_zero]

theorem step5Terminal_odd (u : Nat) : Odd (step5Terminal u) := by
  have h1 : (step5Terminal u) % 2 = 1 := by
    unfold step5Terminal
    omega
  exact Nat.odd_iff.mpr h1

theorem step6_kick_factorization (u : Nat) :
    3 * step5Terminal u + 1 = 2 * (729 * u + 155) := by
  unfold step5Terminal
  ring

theorem step6_quotient_parity (u : Nat) :
    (729 * u + 155) % 2 = (u + 1) % 2 := by
  omega

/-!
## Zweig `u` gerade (`u = 2v`): `ν₂ = 1`, `S⁶ = 1458v + 155`
-/

theorem step6_even_u_val_eq_one (v : Nat) :
    padicValNat 2 (3 * step5Terminal (2 * v) + 1) = 1 := by
  unfold step5Terminal
  exact deepLiftFiber_j3_step6_nu2_eq_one_u_even (2 * v) (by omega)

theorem step6_even_u_terminal (v : Nat) :
    syracuseOddStep (step5Terminal (2 * v)) = 1458 * v + 155 := by
  rw [step5Terminal_eq_deepLiftFiber_j3]
  have h := syracuseOdd_deepLiftFiber_j3_step6_u_even (2 * v) (by omega)
  calc
    syracuseOddStep (deepLiftFiber 3 (2 * (2 * v))) = 729 * (2 * v) + 155 := h
    _ = 1458 * v + 155 := by ring

/-!
## Zweig `u` ungerade (`u = 2v + 1`): `3S⁵+1 = 4(729v + 442)`
-/

theorem step6_odd_u_certificate (v : Nat) :
    3 * step5Terminal (2 * v + 1) + 1 = 4 * (729 * v + 442) := by
  unfold step5Terminal
  ring

private theorem step6_odd_u_quotient_odd_v (v : Nat) (hv : v % 2 = 1) :
    Odd (729 * v + 442) := by
  have h1 : (729 * v + 442) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

private theorem step6_odd_u_quotient_even_v (v : Nat) (hv : v % 2 = 0) :
    (729 * v + 442) % 2 = 0 := by
  omega

theorem step6_odd_u_val_eq_two_v_odd (v : Nat) (hv : v % 2 = 1) :
    padicValNat 2 (3 * step5Terminal (2 * v + 1) + 1) = 2 := by
  rw [step6_odd_u_certificate v]
  have hn : 4 * (729 * v + 442) ≠ 0 := by omega
  have h4dvd : 4 ∣ 4 * (729 * v + 442) := dvd_mul_right 4 _
  have h8not : ¬8 ∣ 4 * (729 * v + 442) := by
    intro h8
    rcases h8 with ⟨t, ht⟩
    have hq_even : 2 ∣ 729 * v + 442 := by omega
    exact (step6_odd_u_quotient_odd_v v hv).not_two_dvd_nat hq_even
  have h2le : 2 ≤ padicValNat 2 (4 * (729 * v + 442)) := by
    exact (padicValNat_dvd_iff_le (p := 2) (a := 4 * (729 * v + 442)) hn).1
      (by simpa using h4dvd)
  have hnot3le : ¬3 ≤ padicValNat 2 (4 * (729 * v + 442)) := by
    intro h3le
    exact h8not ((padicValNat_dvd_iff_le (p := 2) (a := 4 * (729 * v + 442)) hn).2
      (by simpa using h3le))
  omega

theorem step6_odd_u_odd_v_val_eq_two (w : Nat) :
    padicValNat 2 (3 * step5Terminal (2 * (2 * w + 1) + 1) + 1) = 2 := by
  have hv : (2 * w + 1) % 2 = 1 := by omega
  simpa [mul_assoc, two_mul, add_assoc, add_comm, add_left_comm] using
    step6_odd_u_val_eq_two_v_odd (2 * w + 1) hv

theorem step6_odd_u_odd_v_terminal (w : Nat) :
    syracuseOddStep (step5Terminal (2 * (2 * w + 1) + 1)) = 1458 * w + 1171 := by
  set v := 2 * w + 1
  have hv : v % 2 = 1 := by omega
  have hquotient : 729 * v + 442 = 1458 * w + 1171 := by
    dsimp [v]
    ring
  dsimp [syracuseOddStep, ChannelSevenDynamicsV215.syracuseOddStep]
  rw [oddCoreStep_eq_of_two_pow_mul_odd
    (by simpa [v] using step6_odd_u_certificate v)
    (step6_odd_u_quotient_odd_v v hv)
    (step6_odd_u_val_eq_two_v_odd v hv),
    hquotient]

/-!
## Unterzweig `v` gerade (`v = 2w`) im ungeraden-`u`-Zweig: `ν₂ ≥ 3`, `S⁶ = oddCore(729w + 221)`
-/

theorem step6_odd_u_even_v_certificate (w : Nat) :
    3 * step5Terminal (2 * (2 * w) + 1) + 1 = 8 * (729 * w + 221) := by
  unfold step5Terminal
  ring

private theorem step6_odd_u_quotient_w_odd (w : Nat) (hw : w % 2 = 0) :
    Odd (729 * w + 221) := by
  have h1 : (729 * w + 221) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

private theorem step6_odd_u_even_param_mod8_eq5 (w : Nat) :
    step5Terminal (2 * (2 * w) + 1) % 8 = 5 := by
  unfold step5Terminal
  omega

theorem step6_odd_u_even_v_val_ge_three (w : Nat) :
    3 ≤ padicValNat 2 (3 * step5Terminal (2 * (2 * w) + 1) + 1) := by
  unfold step5Terminal at *
  exact nu2_three_mul_add_one_ge_three_of_mod8_eq5 (step6_odd_u_even_param_mod8_eq5 w)

theorem step6_odd_u_even_w_even_val_eq_three (w : Nat) (hw : w % 2 = 0) :
    padicValNat 2 (3 * step5Terminal (2 * (2 * w) + 1) + 1) = 3 := by
  have h8factor := step6_odd_u_even_v_certificate w
  have hodd := step6_odd_u_quotient_w_odd w hw
  have hmod8 := step6_odd_u_even_param_mod8_eq5 w
  exact nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd
    hmod8 h8factor hodd

private theorem oddCore_eight_mul (q : Nat) (hq : 0 < q) :
    oddCore (8 * q) = oddCore q := by
  obtain ⟨k, hk⟩ := exists_pow_two_mul_oddCore q
  have hodd : Odd (oddCore q) := oddCore_odd_of_pos hq
  have heq : 8 * q = 2 ^ (3 + k) * oddCore q := by
    conv_lhs => arg 2; rw [hk]
    rw [show (8 : Nat) = 2 ^ 3 from by decide, pow_add, mul_assoc]
  rw [heq, oddCore_two_pow_mul (3 + k) (oddCore q) hodd]

theorem step6_odd_u_even_v_terminal (w : Nat) :
    syracuseOddStep (step5Terminal (2 * (2 * w) + 1)) = oddCore (729 * w + 221) := by
  set q := 729 * w + 221
  have hqpos : 0 < q := by dsimp [q]; omega
  have hfactor := step6_odd_u_even_v_certificate w
  dsimp [syracuseOddStep, ChannelSevenDynamicsV215.syracuseOddStep, oddCoreStep]
  rw [hfactor, oddCore_eight_mul q hqpos]

/-!
## Gesamtverzweigung: `t` gerade ⇒ `ν₂(S⁶-Kick) ∈ {1, 2, ≥3}`
-/

theorem step6_nu2_trichotomy (u : Nat) :
    padicValNat 2 (3 * step5Terminal u + 1) = 1 ∨
      padicValNat 2 (3 * step5Terminal u + 1) = 2 ∨
        3 ≤ padicValNat 2 (3 * step5Terminal u + 1) := by
  unfold step5Terminal
  rcases Nat.even_or_odd u with hEven | hOdd
  · rcases hEven with ⟨v, rfl⟩
    exact Or.inl (by simpa [two_mul] using deepLiftFiber_j3_step6_nu2_eq_one_u_even (2 * v) (by omega))
  · rcases hOdd with ⟨v, rfl⟩
    rcases deepLiftFiber_j3_step6_nu2_u_odd (2 * v + 1) (by omega) with h2 | h3
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr h3)

structure ChannelSeven71Step6BranchingV215Scaffold : Prop where
  terminal_odd :
    ∀ u : Nat, Odd (step5Terminal u)
  kick_factorization :
    ∀ u : Nat, 3 * step5Terminal u + 1 = 2 * (729 * u + 155)
  even_u_val_one :
    ∀ v : Nat, padicValNat 2 (3 * step5Terminal (2 * v) + 1) = 1
  even_u_terminal :
    ∀ v : Nat, syracuseOddStep (step5Terminal (2 * v)) = 1458 * v + 155
  odd_u_certificate :
    ∀ v : Nat, 3 * step5Terminal (2 * v + 1) + 1 = 4 * (729 * v + 442)
  odd_u_odd_v_val_two :
    ∀ w : Nat,
      padicValNat 2 (3 * step5Terminal (2 * (2 * w + 1) + 1) + 1) = 2
  odd_u_odd_v_terminal :
    ∀ w : Nat,
      syracuseOddStep (step5Terminal (2 * (2 * w + 1) + 1)) = 1458 * w + 1171
  odd_u_even_v_certificate :
    ∀ w : Nat,
      3 * step5Terminal (2 * (2 * w) + 1) + 1 = 8 * (729 * w + 221)
  odd_u_even_v_val_ge_three :
    ∀ w : Nat,
      3 ≤ padicValNat 2 (3 * step5Terminal (2 * (2 * w) + 1) + 1)
  odd_u_even_v_terminal :
    ∀ w : Nat,
      syracuseOddStep (step5Terminal (2 * (2 * w) + 1)) = oddCore (729 * w + 221)
  nu2_trichotomy :
    ∀ u : Nat,
      padicValNat 2 (3 * step5Terminal u + 1) = 1 ∨
        padicValNat 2 (3 * step5Terminal u + 1) = 2 ∨
          3 ≤ padicValNat 2 (3 * step5Terminal u + 1)
  constant_j3 :
    step5Terminal 0 = deepLiftConstant 3

theorem channel_seven71_step6_branching_v215_scaffold :
    ChannelSeven71Step6BranchingV215Scaffold where
  terminal_odd := step5Terminal_odd
  kick_factorization := step6_kick_factorization
  even_u_val_one := step6_even_u_val_eq_one
  even_u_terminal := step6_even_u_terminal
  odd_u_certificate := step6_odd_u_certificate
  odd_u_odd_v_val_two := step6_odd_u_odd_v_val_eq_two
  odd_u_odd_v_terminal := step6_odd_u_odd_v_terminal
  odd_u_even_v_certificate := step6_odd_u_even_v_certificate
  odd_u_even_v_val_ge_three := step6_odd_u_even_v_val_ge_three
  odd_u_even_v_terminal := step6_odd_u_even_v_terminal
  nu2_trichotomy := step6_nu2_trichotomy
  constant_j3 := step5Terminal_constant_j3

end KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
