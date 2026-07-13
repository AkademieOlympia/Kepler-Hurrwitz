import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCore

/-!
# Kanal-7 V2.15 — Schritt-7-Verzweigung auf Terminalfamilie `1458v + 155`

Governance:
> Schritt-7-Verzweigung klassifiziert ≠ dynamischer Deszent bewiesen
> 2-adische Struktur ≠ dynamischer Deszent

Eingang: Schritt-6-Terminal des `ν₂ = 1`-Zweigs (`u` gerade),
`S⁶ = 1458v + 155` (siehe `ChannelSeven71Step6BranchingV215.step6_even_u_terminal`).

Kick: `3·S⁶ + 1 = 2·(2187v + 233)`; Verzweigung nach Parität von `v`:

- `v = 2s` (gerade): `ν₂ = 1`, Terminal `S⁷ = 4374s + 233`
- `v = 2s + 1`, `s = 2w + 1` (ungerade/ungerade): `ν₂ = 2`, Terminal `S⁷ = 4374w + 3397`
- `v = 2s + 1`, `s = 2w` (ungerade/gerade): `ν₂ ≥ 3`, Terminal `S⁷ = oddCore(2187w + 605)`
  (exakt `ν₂ = 3` bei geradem `w`)

**Nicht behauptet:** globaler Deszent, Kanal-7-Schließung, ε₀-Rang,
dynamischer Eintritt in kontrollierte mod-128-Fasern.
-/

namespace KeplerHurwitz.Collatz.ChannelSeven71Step7BranchingV215

open KeplerHurwitz
open KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.Octonion

abbrev syracuseOddStep (n : Nat) : Nat :=
  ChannelSevenDynamicsV215.syracuseOddStep n

/-- Schritt-6-Terminal des `ν₂ = 1`-Zweigs: `S⁶ = 1458v + 155`. -/
def step6Terminal (v : Nat) : Nat :=
  1458 * v + 155

/-- Anschluss an Schritt 6: `S⁶` auf dem geraden `u`-Zweig ist genau `step6Terminal`. -/
theorem step6Terminal_eq_step6_even_branch (v : Nat) :
    ChannelSeven71Step6BranchingV215.syracuseOddStep
      (ChannelSeven71Step6BranchingV215.step5Terminal (2 * v)) = step6Terminal v := by
  rw [ChannelSeven71Step6BranchingV215.step6_even_u_terminal v]
  rfl

theorem step6Terminal_odd (v : Nat) : Odd (step6Terminal v) := by
  have h1 : (step6Terminal v) % 2 = 1 := by
    unfold step6Terminal
    omega
  exact Nat.odd_iff.mpr h1

theorem step7_kick_factorization (v : Nat) :
    3 * step6Terminal v + 1 = 2 * (2187 * v + 233) := by
  unfold step6Terminal
  ring

theorem step7_quotient_parity (v : Nat) :
    (2187 * v + 233) % 2 = (v + 1) % 2 := by
  omega

/-!
## Zweig `v` gerade (`v = 2s`): `ν₂ = 1`, `S⁷ = 4374s + 233`
-/

theorem step7_even_v_certificate (s : Nat) :
    3 * step6Terminal (2 * s) + 1 = 2 * (4374 * s + 233) := by
  unfold step6Terminal
  ring

private theorem step7_even_v_quotient_odd (s : Nat) :
    Odd (4374 * s + 233) := by
  have h1 : (4374 * s + 233) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

theorem step7_even_v_val_eq_one (s : Nat) :
    padicValNat 2 (3 * step6Terminal (2 * s) + 1) = 1 := by
  rw [step7_even_v_certificate s]
  have hn : 2 * (4374 * s + 233) ≠ 0 := by omega
  have h2dvd : 2 ∣ 2 * (4374 * s + 233) := dvd_mul_right 2 _
  have h4not : ¬4 ∣ 2 * (4374 * s + 233) := by
    intro h4
    rcases h4 with ⟨t, ht⟩
    have hq_even : 2 ∣ 4374 * s + 233 := by omega
    exact (step7_even_v_quotient_odd s).not_two_dvd_nat hq_even
  have h1le : 1 ≤ padicValNat 2 (2 * (4374 * s + 233)) :=
    (padicValNat_dvd_iff_le (p := 2) (a := 2 * (4374 * s + 233)) hn).1
      (by rw [pow_one]; exact h2dvd)
  have hnot2le : ¬2 ≤ padicValNat 2 (2 * (4374 * s + 233)) := by
    intro h2le
    have hdvd : (2 : Nat) ^ 2 ∣ 2 * (4374 * s + 233) :=
      (padicValNat_dvd_iff_le (p := 2) (a := 2 * (4374 * s + 233)) hn).2 h2le
    exact h4not (by rw [show (4 : Nat) = 2 ^ 2 from rfl]; exact hdvd)
  omega

theorem step7_even_v_terminal (s : Nat) :
    syracuseOddStep (step6Terminal (2 * s)) = 4374 * s + 233 := by
  dsimp [syracuseOddStep, ChannelSevenDynamicsV215.syracuseOddStep]
  exact oddCoreStep_eq_of_two_pow_mul_odd
    (by simpa [pow_one] using step7_even_v_certificate s)
    (step7_even_v_quotient_odd s)
    (step7_even_v_val_eq_one s)

/-!
## Zweig `v` ungerade (`v = 2s + 1`): `3S⁶+1 = 4(2187s + 1210)`
-/

theorem step7_odd_v_certificate (s : Nat) :
    3 * step6Terminal (2 * s + 1) + 1 = 4 * (2187 * s + 1210) := by
  unfold step6Terminal
  ring

theorem step7_odd_v_quotient_parity (s : Nat) :
    (2187 * s + 1210) % 2 = s % 2 := by
  omega

/-!
## Unterzweig `s` ungerade (`s = 2w + 1`): `ν₂ = 2`, `S⁷ = 4374w + 3397`
-/

theorem step7_odd_v_odd_s_certificate (w : Nat) :
    3 * step6Terminal (2 * (2 * w + 1) + 1) + 1 = 4 * (4374 * w + 3397) := by
  unfold step6Terminal
  ring

private theorem step7_odd_v_odd_s_quotient_odd (w : Nat) :
    Odd (4374 * w + 3397) := by
  have h1 : (4374 * w + 3397) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

private theorem step7_odd_v_odd_s_mod8_eq1 (w : Nat) :
    step6Terminal (2 * (2 * w + 1) + 1) % 8 = 1 := by
  unfold step6Terminal
  omega

theorem step7_odd_v_odd_s_val_eq_two (w : Nat) :
    padicValNat 2 (3 * step6Terminal (2 * (2 * w + 1) + 1) + 1) = 2 :=
  nu2_three_mul_add_one_eq_two_of_mod8_eq1 (step7_odd_v_odd_s_mod8_eq1 w)

theorem step7_odd_v_odd_s_terminal (w : Nat) :
    syracuseOddStep (step6Terminal (2 * (2 * w + 1) + 1)) = 4374 * w + 3397 := by
  dsimp [syracuseOddStep, ChannelSevenDynamicsV215.syracuseOddStep]
  exact oddCoreStep_eq_of_two_pow_mul_odd
    (by simpa [show (2 : Nat) ^ 2 = 4 from by norm_num] using step7_odd_v_odd_s_certificate w)
    (step7_odd_v_odd_s_quotient_odd w)
    (step7_odd_v_odd_s_val_eq_two w)

/-!
## Unterzweig `s` gerade (`s = 2w`): `ν₂ ≥ 3`, `S⁷ = oddCore(2187w + 605)`
-/

theorem step7_odd_v_even_s_certificate (w : Nat) :
    3 * step6Terminal (2 * (2 * w) + 1) + 1 = 8 * (2187 * w + 605) := by
  unfold step6Terminal
  ring

private theorem step7_odd_v_even_s_mod8_eq5 (w : Nat) :
    step6Terminal (2 * (2 * w) + 1) % 8 = 5 := by
  unfold step6Terminal
  omega

theorem step7_odd_v_even_s_val_ge_three (w : Nat) :
    3 ≤ padicValNat 2 (3 * step6Terminal (2 * (2 * w) + 1) + 1) :=
  nu2_three_mul_add_one_ge_three_of_mod8_eq5 (step7_odd_v_even_s_mod8_eq5 w)

private theorem step7_odd_v_even_s_quotient_odd_w_even (w : Nat) (hw : w % 2 = 0) :
    Odd (2187 * w + 605) := by
  have h1 : (2187 * w + 605) % 2 = 1 := by omega
  exact Nat.odd_iff.mpr h1

theorem step7_odd_v_even_s_w_even_val_eq_three (w : Nat) (hw : w % 2 = 0) :
    padicValNat 2 (3 * step6Terminal (2 * (2 * w) + 1) + 1) = 3 :=
  nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd
    (step7_odd_v_even_s_mod8_eq5 w)
    (step7_odd_v_even_s_certificate w)
    (step7_odd_v_even_s_quotient_odd_w_even w hw)

private theorem oddCore_eight_mul (q : Nat) (hq : 0 < q) :
    oddCore (8 * q) = oddCore q := by
  obtain ⟨k, hk⟩ := exists_pow_two_mul_oddCore q
  have hodd : Odd (oddCore q) := oddCore_odd_of_pos hq
  have heq : 8 * q = 2 ^ (3 + k) * oddCore q := by
    conv_lhs => arg 2; rw [hk]
    rw [show (8 : Nat) = 2 ^ 3 from by decide, pow_add, mul_assoc]
  rw [heq, oddCore_two_pow_mul (3 + k) (oddCore q) hodd]

theorem step7_odd_v_even_s_terminal (w : Nat) :
    syracuseOddStep (step6Terminal (2 * (2 * w) + 1)) = oddCore (2187 * w + 605) := by
  set q := 2187 * w + 605
  have hqpos : 0 < q := by dsimp [q]; omega
  have hfactor := step7_odd_v_even_s_certificate w
  dsimp [syracuseOddStep, ChannelSevenDynamicsV215.syracuseOddStep, oddCoreStep]
  rw [hfactor, oddCore_eight_mul q hqpos]

/-!
## Gesamtverzweigung: `ν₂(S⁷-Kick) ∈ {1, 2, ≥3}` über alle `v`
-/

theorem step7_nu2_trichotomy (v : Nat) :
    padicValNat 2 (3 * step6Terminal v + 1) = 1 ∨
      padicValNat 2 (3 * step6Terminal v + 1) = 2 ∨
        3 ≤ padicValNat 2 (3 * step6Terminal v + 1) := by
  rcases Nat.even_or_odd v with hEven | hOdd
  · rcases hEven with ⟨s, rfl⟩
    exact Or.inl (by simpa [two_mul] using step7_even_v_val_eq_one s)
  · rcases hOdd with ⟨s, rfl⟩
    rcases Nat.even_or_odd s with hsEven | hsOdd
    · rcases hsEven with ⟨w, rfl⟩
      exact Or.inr (Or.inr (by
        simpa [two_mul] using step7_odd_v_even_s_val_ge_three w))
    · rcases hsOdd with ⟨w, rfl⟩
      exact Or.inr (Or.inl (by
        simpa [two_mul] using step7_odd_v_odd_s_val_eq_two w))

/-!
## H7-Anschluss: mod-128-Reduktion der Familien (`[A]`, statisch)

Restklassen-Parametrisierung für den H7-Zustandsgraphen — **keine** dynamische Aussage.
-/

theorem step6Terminal_mod128 (v : Nat) :
    step6Terminal v % 128 = (50 * v + 27) % 128 := by
  unfold step6Terminal
  omega

theorem step7_even_v_terminal_mod128 (s : Nat) :
    (4374 * s + 233) % 128 = (22 * s + 105) % 128 := by
  omega

theorem step7_odd_v_odd_s_terminal_mod128 (w : Nat) :
    (4374 * w + 3397) % 128 = (22 * w + 69) % 128 := by
  omega

structure ChannelSeven71Step7BranchingV215Scaffold : Prop where
  step6_link :
    ∀ v : Nat,
      ChannelSeven71Step6BranchingV215.syracuseOddStep
        (ChannelSeven71Step6BranchingV215.step5Terminal (2 * v)) = step6Terminal v
  terminal_odd :
    ∀ v : Nat, Odd (step6Terminal v)
  kick_factorization :
    ∀ v : Nat, 3 * step6Terminal v + 1 = 2 * (2187 * v + 233)
  even_v_val_one :
    ∀ s : Nat, padicValNat 2 (3 * step6Terminal (2 * s) + 1) = 1
  even_v_terminal :
    ∀ s : Nat, syracuseOddStep (step6Terminal (2 * s)) = 4374 * s + 233
  odd_v_certificate :
    ∀ s : Nat, 3 * step6Terminal (2 * s + 1) + 1 = 4 * (2187 * s + 1210)
  odd_v_odd_s_val_two :
    ∀ w : Nat,
      padicValNat 2 (3 * step6Terminal (2 * (2 * w + 1) + 1) + 1) = 2
  odd_v_odd_s_terminal :
    ∀ w : Nat,
      syracuseOddStep (step6Terminal (2 * (2 * w + 1) + 1)) = 4374 * w + 3397
  odd_v_even_s_certificate :
    ∀ w : Nat,
      3 * step6Terminal (2 * (2 * w) + 1) + 1 = 8 * (2187 * w + 605)
  odd_v_even_s_val_ge_three :
    ∀ w : Nat,
      3 ≤ padicValNat 2 (3 * step6Terminal (2 * (2 * w) + 1) + 1)
  odd_v_even_s_w_even_val_three :
    ∀ w : Nat, w % 2 = 0 →
      padicValNat 2 (3 * step6Terminal (2 * (2 * w) + 1) + 1) = 3
  odd_v_even_s_terminal :
    ∀ w : Nat,
      syracuseOddStep (step6Terminal (2 * (2 * w) + 1)) = oddCore (2187 * w + 605)
  nu2_trichotomy :
    ∀ v : Nat,
      padicValNat 2 (3 * step6Terminal v + 1) = 1 ∨
        padicValNat 2 (3 * step6Terminal v + 1) = 2 ∨
          3 ≤ padicValNat 2 (3 * step6Terminal v + 1)
  mod128_family :
    ∀ v : Nat, step6Terminal v % 128 = (50 * v + 27) % 128

theorem channel_seven71_step7_branching_v215_scaffold :
    ChannelSeven71Step7BranchingV215Scaffold where
  step6_link := step6Terminal_eq_step6_even_branch
  terminal_odd := step6Terminal_odd
  kick_factorization := step7_kick_factorization
  even_v_val_one := step7_even_v_val_eq_one
  even_v_terminal := step7_even_v_terminal
  odd_v_certificate := step7_odd_v_certificate
  odd_v_odd_s_val_two := step7_odd_v_odd_s_val_eq_two
  odd_v_odd_s_terminal := step7_odd_v_odd_s_terminal
  odd_v_even_s_certificate := step7_odd_v_even_s_certificate
  odd_v_even_s_val_ge_three := step7_odd_v_even_s_val_ge_three
  odd_v_even_s_w_even_val_three := step7_odd_v_even_s_w_even_val_eq_three
  odd_v_even_s_terminal := step7_odd_v_even_s_terminal
  nu2_trichotomy := step7_nu2_trichotomy
  mod128_family := step6Terminal_mod128

end KeplerHurwitz.Collatz.ChannelSeven71Step7BranchingV215
