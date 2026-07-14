import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.CollatzNetDescentMod8
import KeplerHurwitz.CollatzProofAttemptV28

/-!
# Kanal-7-Angriff V2.10 — geschlossene Restklasse `55 mod 128`

Valuationswort `[1, 1, 3]` auf drei Syracuse-Odd-Schritten (`oddCoreStep`).

**Governance:** `[A]` — kein `sorry`. Uniform für alle `k : ℕ` auf der Faser `128k + 55`.

Hinweis: `CollatzAttemptV2.T_odd` ist `(3n+1)/2` und stimmt hier nur bei `ν₂ = 1` mit
`oddCoreStep` überein; Schritt 3 benötigt die volle `2^ν₂`-Division.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAttackV210

open CollatzAttemptV2
open Collatz.Octonion
open CollatzNetDescentMod8
open CollatzNetDescentV28

/-- Syracuse-Odd-Schritt mit voller Valuation (`= oddCoreStep`). -/
abbrev syracuseOddStep (n : Nat) : Nat :=
  oddCoreStep n

/-- mod-128-Faser des Kanal-7-Angriffs: `n = 128k + 55`. -/
def channelSeven55Fiber (k : Nat) : Nat :=
  128 * k + 55

theorem channelSeven55Fiber_mod8_eq_seven (k : Nat) :
    channelSeven55Fiber k % 8 = 7 := by
  simp [channelSeven55Fiber]
  omega

theorem channelSeven55Fiber_mod4_eq_three (k : Nat) :
    channelSeven55Fiber k % 4 = 3 := by
  simp [channelSeven55Fiber]
  omega

theorem channelSeven55_residue_eq_thirtytwo_affine (m : Nat) :
    128 * m + 55 = 32 * (4 * m + 1) + 23 := by
  ring

/-!
## Arithmetische Zertifikate
-/

theorem channelSeven55_step1_certificate (k : Nat) :
    3 * (128 * k + 55) + 1 = 2 ^ 1 * (192 * k + 83) := by
  ring

theorem channelSeven55_step2_certificate (k : Nat) :
    3 * (192 * k + 83) + 1 = 2 ^ 1 * (288 * k + 125) := by
  ring

theorem channelSeven55_step3_certificate (k : Nat) :
    3 * (288 * k + 125) + 1 = 2 ^ 3 * (108 * k + 47) := by
  ring

theorem channelSeven55_step1_target_odd (k : Nat) : Odd (192 * k + 83) := by
  exact ⟨41 + 96 * k, by ring⟩

theorem channelSeven55_step2_target_odd (k : Nat) : Odd (288 * k + 125) := by
  exact ⟨62 + 144 * k, by ring⟩

theorem channelSeven55_step3_target_odd (k : Nat) : Odd (108 * k + 47) := by
  exact ⟨23 + 54 * k, by ring⟩

/-!
## Valuationen und Syracuse-Schritte
-/

theorem channelSeven55_step1_nu2 (k : Nat) :
    padicValNat 2 (3 * (channelSeven55Fiber k) + 1) = 1 := by
  have h7 : channelSeven55Fiber k % 8 = 7 := channelSeven55Fiber_mod8_eq_seven k
  simpa [channelSeven55Fiber] using
    nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem channelSeven55_step2_nu2 (k : Nat) :
    padicValNat 2 (3 * (192 * k + 83) + 1) = 1 := by
  have h3 : (192 * k + 83) % 8 = 3 := by omega
  exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3

theorem channelSeven55_step3_nu2 (k : Nat) :
    padicValNat 2 (3 * (288 * k + 125) + 1) = 3 := by
  have h5 : (288 * k + 125) % 8 = 5 := by omega
  exact nu2_three_mul_add_one_eq_three_of_mod8_eq5_quotient_odd h5
    (channelSeven55_step3_certificate k) (channelSeven55_step3_target_odd k)

theorem syracuseOdd_channelSeven55_step1 (k : Nat) :
    syracuseOddStep (channelSeven55Fiber k) = 192 * k + 83 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven55_step1_certificate k)
    (channelSeven55_step1_target_odd k)
    (channelSeven55_step1_nu2 k)

theorem syracuseOdd_channelSeven55_step2 (k : Nat) :
    syracuseOddStep (192 * k + 83) = 288 * k + 125 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven55_step2_certificate k)
    (channelSeven55_step2_target_odd k)
    (channelSeven55_step2_nu2 k)

theorem syracuseOdd_channelSeven55_step3 (k : Nat) :
    syracuseOddStep (288 * k + 125) = 108 * k + 47 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven55_step3_certificate k)
    (channelSeven55_step3_target_odd k)
    (channelSeven55_step3_nu2 k)

theorem syracuseOdd_iterate_three_channelSeven55 (k : Nat) :
    syracuseOddStep^[3] (channelSeven55Fiber k) = 108 * k + 47 := by
  rw [Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_one]
  rw [syracuseOdd_channelSeven55_step1, syracuseOdd_channelSeven55_step2,
    syracuseOdd_channelSeven55_step3]

theorem channelSeven55_strict_descent (k : Nat) :
    syracuseOddStep^[3] (channelSeven55Fiber k) < channelSeven55Fiber k := by
  rw [syracuseOdd_iterate_three_channelSeven55]
  simp [channelSeven55Fiber]
  omega

theorem channelSeven55_T_odd_steps_one_two (k : Nat) :
    T_odd (channelSeven55Fiber k) = 192 * k + 83 ∧
      T_odd (192 * k + 83) = 288 * k + 125 := by
  have ho1 : channelSeven55Fiber k % 2 = 1 := by simp [channelSeven55Fiber]; omega
  have ho2 : (192 * k + 83) % 2 = 1 := by omega
  have hmod1 : channelSeven55Fiber k % 4 = 3 := channelSeven55Fiber_mod4_eq_three k
  have hmod2 : (192 * k + 83) % 4 = 3 := by omega
  refine ⟨?_, ?_⟩
  · rw [T_odd_eq_oddCoreStep_of_mod4_eq_three ho1 hmod1]
    exact syracuseOdd_channelSeven55_step1 k
  · rw [T_odd_eq_oddCoreStep_of_mod4_eq_three ho2 hmod2]
    exact syracuseOdd_channelSeven55_step2 k

theorem channelSeven55_has_local_descent_witness (k : Nat) :
    ∃ t : Nat, t = 3 ∧
      syracuseOddStep^[t] (channelSeven55Fiber k) < channelSeven55Fiber k := by
  refine ⟨3, rfl, channelSeven55_strict_descent k⟩

/-- Valuationswort `[1, 1, 3]` als explizite `ν₂`-Folge. -/
theorem channelSeven55_valuation_word (k : Nat) :
    padicValNat 2 (3 * (channelSeven55Fiber k) + 1) = 1 ∧
      padicValNat 2 (3 * (192 * k + 83) + 1) = 1 ∧
        padicValNat 2 (3 * (288 * k + 125) + 1) = 3 :=
  ⟨channelSeven55_step1_nu2 k, channelSeven55_step2_nu2 k, channelSeven55_step3_nu2 k⟩

/-- Uniformer Abstand: `(128k+55) - (108k+47) = 20k+8`. -/
theorem channelSeven55_descent_margin (k : Nat) :
    channelSeven55Fiber k - syracuseOddStep^[3] (channelSeven55Fiber k) = 20 * k + 8 := by
  rw [syracuseOdd_iterate_three_channelSeven55]
  simp [channelSeven55Fiber]
  omega

/-!
## Net-Descent-Witness (lokales Interface, unabhängig vom Syracuse-Satz)
-/

theorem bad_run_net_descent_witness_mod8_channel_seven_mod128_fifty_five
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 55) :
    Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hnm⟩
  have hj : n = 32 * (4 * m + 1) + 23 := by
    rw [hnm]
    exact channelSeven55_residue_eq_thirtytwo_affine m
  exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 ⟨4 * m + 1, hj⟩

/--
Status der geschlossenen `55 mod 128`-Faser.

Metadaten (dokumentiert): Valuationswort `[1,1,3]`, Tiefe `3`, Terminal `108k+47`,
Abstand `20k+8`.
-/
structure ChannelSeven55Status : Prop where
  syracuse_three_step_descent :
    ∀ k : Nat, syracuseOddStep^[3] (channelSeven55Fiber k) < channelSeven55Fiber k
  mod128_net_descent_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 55) →
      Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
        CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7)

theorem channel_seven55_status : ChannelSeven55Status where
  syracuse_three_step_descent := channelSeven55_strict_descent
  mod128_net_descent_witness := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod128_fifty_five hn h7 hmod

end KeplerHurwitz.Collatz.ChannelSevenAttackV210
