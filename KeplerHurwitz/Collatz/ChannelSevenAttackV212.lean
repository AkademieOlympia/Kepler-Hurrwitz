import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.CollatzNetDescentMod8
import KeplerHurwitz.CollatzProofAttemptV28

/-!
# Kanal-7-Angriff V2.12 — geschlossene Restklasse `119 mod 128`

Valuationswort `[1, 1, 3]` auf drei Syracuse-Odd-Schritten (`oddCoreStep`).

**Governance:** `[A]` — kein `sorry`. Uniform für alle `k : ℕ`; keine Nebenbedingung.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAttackV212

open CollatzAttemptV2
open Collatz.Octonion
open CollatzNetDescentMod8
open CollatzNetDescentV28

/-- Syracuse-Odd-Schritt mit voller Valuation (`= oddCoreStep`). -/
abbrev syracuseOddStep (n : Nat) : Nat :=
  oddCoreStep n

/-- mod-128-Faser: `n = 128k + 119`. -/
def channelSeven119Fiber (k : Nat) : Nat :=
  128 * k + 119

theorem channelSeven119Fiber_mod8_eq_seven (k : Nat) :
    channelSeven119Fiber k % 8 = 7 := by
  simp [channelSeven119Fiber]
  omega

theorem channelSeven119Fiber_mod4_eq_three (k : Nat) :
    channelSeven119Fiber k % 4 = 3 := by
  simp [channelSeven119Fiber]
  omega

theorem channelSeven119_residue_eq_thirtytwo_affine (m : Nat) :
    128 * m + 119 = 32 * (4 * m + 3) + 23 := by
  ring

/-!
## Arithmetische Zertifikate
-/

theorem channelSeven119_step1_certificate (k : Nat) :
    3 * (128 * k + 119) + 1 = 2 ^ 1 * (192 * k + 179) := by
  ring

theorem channelSeven119_step2_certificate (k : Nat) :
    3 * (192 * k + 179) + 1 = 2 ^ 1 * (288 * k + 269) := by
  ring

theorem channelSeven119_step3_certificate (k : Nat) :
    3 * (288 * k + 269) + 1 = 2 ^ 3 * (108 * k + 101) := by
  ring

theorem channelSeven119_step1_target_odd (k : Nat) : Odd (192 * k + 179) := by
  exact ⟨89 + 96 * k, by ring⟩

theorem channelSeven119_step2_target_odd (k : Nat) : Odd (288 * k + 269) := by
  exact ⟨134 + 144 * k, by ring⟩

theorem channelSeven119_step3_target_odd (k : Nat) : Odd (108 * k + 101) := by
  exact ⟨50 + 54 * k, by ring⟩

/-!
## Valuationen und Syracuse-Schritte
-/

theorem channelSeven119_step1_nu2 (k : Nat) :
    padicValNat 2 (3 * (channelSeven119Fiber k) + 1) = 1 := by
  have h7 : channelSeven119Fiber k % 8 = 7 := channelSeven119Fiber_mod8_eq_seven k
  simpa [channelSeven119Fiber] using
    nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem channelSeven119_step2_nu2 (k : Nat) :
    padicValNat 2 (3 * (192 * k + 179) + 1) = 1 := by
  have h3 : (192 * k + 179) % 8 = 3 := by omega
  exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3

theorem channelSeven119_step3_nu2 (k : Nat) :
    padicValNat 2 (3 * (288 * k + 269) + 1) = 3 := by
  have h5 : (288 * k + 269) % 8 = 5 := by omega
  exact nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd h5
    (channelSeven119_step3_certificate k) (channelSeven119_step3_target_odd k)

theorem syracuseOdd_channelSeven119_step1 (k : Nat) :
    syracuseOddStep (channelSeven119Fiber k) = 192 * k + 179 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven119_step1_certificate k)
    (channelSeven119_step1_target_odd k)
    (channelSeven119_step1_nu2 k)

theorem syracuseOdd_channelSeven119_step2 (k : Nat) :
    syracuseOddStep (192 * k + 179) = 288 * k + 269 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven119_step2_certificate k)
    (channelSeven119_step2_target_odd k)
    (channelSeven119_step2_nu2 k)

theorem syracuseOdd_channelSeven119_step3 (k : Nat) :
    syracuseOddStep (288 * k + 269) = 108 * k + 101 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven119_step3_certificate k)
    (channelSeven119_step3_target_odd k)
    (channelSeven119_step3_nu2 k)

theorem syracuseOdd_iterate_three_channelSeven119 (k : Nat) :
    syracuseOddStep^[3] (channelSeven119Fiber k) = 108 * k + 101 := by
  rw [Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_one]
  rw [syracuseOdd_channelSeven119_step1, syracuseOdd_channelSeven119_step2,
    syracuseOdd_channelSeven119_step3]

theorem channelSeven119_strict_descent (k : Nat) :
    syracuseOddStep^[3] (channelSeven119Fiber k) < channelSeven119Fiber k := by
  rw [syracuseOdd_iterate_three_channelSeven119]
  simp [channelSeven119Fiber]
  omega

theorem channelSeven119_has_local_descent_witness (k : Nat) :
    ∃ t : Nat, t = 3 ∧
      syracuseOddStep^[t] (channelSeven119Fiber k) < channelSeven119Fiber k := by
  refine ⟨3, rfl, channelSeven119_strict_descent k⟩

/-- Valuationswort `[1, 1, 3]` als explizite `ν₂`-Folge. -/
theorem channelSeven119_valuation_word (k : Nat) :
    padicValNat 2 (3 * (channelSeven119Fiber k) + 1) = 1 ∧
      padicValNat 2 (3 * (192 * k + 179) + 1) = 1 ∧
        padicValNat 2 (3 * (288 * k + 269) + 1) = 3 :=
  ⟨channelSeven119_step1_nu2 k, channelSeven119_step2_nu2 k, channelSeven119_step3_nu2 k⟩

/-- Uniformer Abstand: `(128k+119) - (108k+101) = 20k+18`. -/
theorem channelSeven119_descent_margin (k : Nat) :
    channelSeven119Fiber k - syracuseOddStep^[3] (channelSeven119Fiber k) = 20 * k + 18 := by
  rw [syracuseOdd_iterate_three_channelSeven119]
  simp [channelSeven119Fiber]
  omega

/-!
## Net-Descent-Witness (lokales Interface, unabhängig vom Syracuse-Satz)
-/

theorem bad_run_net_descent_witness_mod8_channel_seven_mod128_one_nineteen
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 119) :
    Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hnm⟩
  have hj : n = 32 * (4 * m + 3) + 23 := by
    rw [hnm]
    exact channelSeven119_residue_eq_thirtytwo_affine m
  exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 ⟨4 * m + 3, hj⟩

structure ChannelSeven119Status : Prop where
  syracuse_three_step_descent :
    ∀ k : Nat, syracuseOddStep^[3] (channelSeven119Fiber k) < channelSeven119Fiber k
  mod128_net_descent_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 119) →
      Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
        CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7)

theorem channel_seven119_status : ChannelSeven119Status where
  syracuse_three_step_descent := channelSeven119_strict_descent
  mod128_net_descent_witness := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod128_one_nineteen hn h7 hmod

end KeplerHurwitz.Collatz.ChannelSevenAttackV212
