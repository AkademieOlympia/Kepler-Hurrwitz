import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.CollatzNetDescentMod8
import KeplerHurwitz.CollatzProofAttemptV28

/-!
# Kanal-7-Angriff V2.11 — geschlossene Restklasse `87 mod 128`

Valuationswort `[1, 1, 4]` auf drei Syracuse-Odd-Schritten (`oddCoreStep`).

**Governance:** `[A]` — kein `sorry`. Uniform für alle `k : ℕ` auf der Faser `128k + 87`.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAttackV211

open CollatzAttemptV2
open Collatz.Octonion
open CollatzNetDescentMod8
open CollatzNetDescentV28

/-- Syracuse-Odd-Schritt mit voller Valuation (`= oddCoreStep`). -/
abbrev syracuseOddStep (n : Nat) : Nat :=
  oddCoreStep n

/-- mod-128-Faser des Kanal-7-Angriffs: `n = 128k + 87`. -/
def channelSeven87Fiber (k : Nat) : Nat :=
  128 * k + 87

theorem channelSeven87Fiber_mod8_eq_seven (k : Nat) :
    channelSeven87Fiber k % 8 = 7 := by
  simp [channelSeven87Fiber]
  omega

theorem channelSeven87Fiber_mod4_eq_three (k : Nat) :
    channelSeven87Fiber k % 4 = 3 := by
  simp [channelSeven87Fiber]
  omega

theorem channelSeven87_residue_eq_thirtytwo_affine (m : Nat) :
    128 * m + 87 = 32 * (4 * m + 2) + 23 := by
  ring

/-!
## Arithmetische Zertifikate
-/

theorem channelSeven87_step1_certificate (k : Nat) :
    3 * (128 * k + 87) + 1 = 2 ^ 1 * (192 * k + 131) := by
  ring

theorem channelSeven87_step2_certificate (k : Nat) :
    3 * (192 * k + 131) + 1 = 2 ^ 1 * (288 * k + 197) := by
  ring

theorem channelSeven87_step3_certificate (k : Nat) :
    3 * (288 * k + 197) + 1 = 2 ^ 4 * (54 * k + 37) := by
  ring

theorem channelSeven87_step1_target_odd (k : Nat) : Odd (192 * k + 131) := by
  exact ⟨65 + 96 * k, by ring⟩

theorem channelSeven87_step2_target_odd (k : Nat) : Odd (288 * k + 197) := by
  exact ⟨98 + 144 * k, by ring⟩

theorem channelSeven87_step3_target_odd (k : Nat) : Odd (54 * k + 37) := by
  exact ⟨18 + 27 * k, by ring⟩

/-!
## Valuationen und Syracuse-Schritte
-/

theorem channelSeven87_step1_nu2 (k : Nat) :
    padicValNat 2 (3 * (channelSeven87Fiber k) + 1) = 1 := by
  have h7 : channelSeven87Fiber k % 8 = 7 := channelSeven87Fiber_mod8_eq_seven k
  simpa [channelSeven87Fiber] using
    nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem channelSeven87_step2_nu2 (k : Nat) :
    padicValNat 2 (3 * (192 * k + 131) + 1) = 1 := by
  have h3 : (192 * k + 131) % 8 = 3 := by omega
  exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3

theorem channelSeven87_step3_nu2 (k : Nat) :
    padicValNat 2 (3 * (288 * k + 197) + 1) = 4 := by
  have h5 : (288 * k + 197) % 8 = 5 := by omega
  exact nu2_three_mul_add_one_eq_four_of_mod8_eq5_quotient_odd h5
    (channelSeven87_step3_certificate k) (channelSeven87_step3_target_odd k)

theorem syracuseOdd_channelSeven87_step1 (k : Nat) :
    syracuseOddStep (channelSeven87Fiber k) = 192 * k + 131 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven87_step1_certificate k)
    (channelSeven87_step1_target_odd k)
    (channelSeven87_step1_nu2 k)

theorem syracuseOdd_channelSeven87_step2 (k : Nat) :
    syracuseOddStep (192 * k + 131) = 288 * k + 197 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven87_step2_certificate k)
    (channelSeven87_step2_target_odd k)
    (channelSeven87_step2_nu2 k)

theorem syracuseOdd_channelSeven87_step3 (k : Nat) :
    syracuseOddStep (288 * k + 197) = 54 * k + 37 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven87_step3_certificate k)
    (channelSeven87_step3_target_odd k)
    (channelSeven87_step3_nu2 k)

theorem syracuseOdd_iterate_three_channelSeven87 (k : Nat) :
    syracuseOddStep^[3] (channelSeven87Fiber k) = 54 * k + 37 := by
  rw [Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_one]
  rw [syracuseOdd_channelSeven87_step1, syracuseOdd_channelSeven87_step2,
    syracuseOdd_channelSeven87_step3]

theorem channelSeven87_strict_descent (k : Nat) :
    syracuseOddStep^[3] (channelSeven87Fiber k) < channelSeven87Fiber k := by
  rw [syracuseOdd_iterate_three_channelSeven87]
  simp [channelSeven87Fiber]
  omega

theorem channelSeven87_has_local_descent_witness (k : Nat) :
    ∃ t : Nat, t = 3 ∧
      syracuseOddStep^[t] (channelSeven87Fiber k) < channelSeven87Fiber k := by
  refine ⟨3, rfl, channelSeven87_strict_descent k⟩

/-- Valuationswort `[1, 1, 4]` als explizite `ν₂`-Folge. -/
theorem channelSeven87_valuation_word (k : Nat) :
    padicValNat 2 (3 * (channelSeven87Fiber k) + 1) = 1 ∧
      padicValNat 2 (3 * (192 * k + 131) + 1) = 1 ∧
        padicValNat 2 (3 * (288 * k + 197) + 1) = 4 :=
  ⟨channelSeven87_step1_nu2 k, channelSeven87_step2_nu2 k, channelSeven87_step3_nu2 k⟩

/-- Uniformer Abstand: `(128k+87) - (54k+37) = 74k+50`. -/
theorem channelSeven87_descent_margin (k : Nat) :
    channelSeven87Fiber k - syracuseOddStep^[3] (channelSeven87Fiber k) = 74 * k + 50 := by
  rw [syracuseOdd_iterate_three_channelSeven87]
  simp [channelSeven87Fiber]
  omega

/-!
## Net-Descent-Witness (lokales Interface, unabhängig vom Syracuse-Satz)
-/

theorem bad_run_net_descent_witness_mod8_channel_seven_mod128_eighty_seven
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 87) :
    Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hnm⟩
  have hj : n = 32 * (4 * m + 2) + 23 := by
    rw [hnm]
    exact channelSeven87_residue_eq_thirtytwo_affine m
  exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 ⟨4 * m + 2, hj⟩

/--
Status der geschlossenen `87 mod 128`-Faser.

Metadaten: Valuationswort `[1,1,4]`, Tiefe `3`, Terminal `54k+37`, Abstand `74k+50`.
-/
structure ChannelSeven87Status : Prop where
  syracuse_three_step_descent :
    ∀ k : Nat, syracuseOddStep^[3] (channelSeven87Fiber k) < channelSeven87Fiber k
  mod128_net_descent_witness :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 128 * m + 87) →
      Nonempty (CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
        CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7)

theorem channel_seven87_status : ChannelSeven87Status where
  syracuse_three_step_descent := channelSeven87_strict_descent
  mod128_net_descent_witness := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod128_eighty_seven hn h7 hmod

end KeplerHurwitz.Collatz.ChannelSevenAttackV211
