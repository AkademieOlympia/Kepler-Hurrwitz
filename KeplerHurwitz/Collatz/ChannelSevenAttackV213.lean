import Mathlib
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.CollatzProofAttemptV2

/-!
# Kanal-7-Angriff V2.13 — offene Progression `71 mod 128`

Uniformes Kurzpräfix-Nichtabstiegszertifikat bis Tiefe `4` mit Valuationspräfix `[1,1,2,2]`.

Governance: `[A]` für Orbitpräfix und strikten Nicht-Abstieg; Net-Descent bleibt `[C]`.
Alle Sätze gelten für alle `k : ℕ` ohne Nebenbedingung.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenAttackV213

open CollatzAttemptV2
open Collatz.Octonion

abbrev syracuseOddStep (n : Nat) : Nat :=
  oddCoreStep n

/-- mod-128-Progression der ersten offenen Kanal-7-Klasse: `n = 128k + 71`. -/
def channelSeven71Fiber (k : Nat) : Nat :=
  128 * k + 71

theorem channelSeven71Fiber_mod8_eq_seven (k : Nat) :
    channelSeven71Fiber k % 8 = 7 := by
  simp [channelSeven71Fiber]
  omega

/-!
## Tiefe 1–3: Valuationswort `[1, 1, 2]`, Terminal `216k + 121`
-/

theorem channelSeven71_step1_certificate (k : Nat) :
    3 * (128 * k + 71) + 1 = 2 ^ 1 * (192 * k + 107) := by
  ring

theorem channelSeven71_step2_certificate (k : Nat) :
    3 * (192 * k + 107) + 1 = 2 ^ 1 * (288 * k + 161) := by
  ring

theorem channelSeven71_step3_certificate (k : Nat) :
    3 * (288 * k + 161) + 1 = 2 ^ 2 * (216 * k + 121) := by
  ring

theorem channelSeven71_step1_target_odd (k : Nat) : Odd (192 * k + 107) := by
  exact ⟨53 + 96 * k, by ring⟩

theorem channelSeven71_step2_target_odd (k : Nat) : Odd (288 * k + 161) := by
  exact ⟨80 + 144 * k, by ring⟩

theorem channelSeven71_step3_target_odd (k : Nat) : Odd (216 * k + 121) := by
  exact ⟨60 + 108 * k, by ring⟩

theorem channelSeven71_step1_nu2 (k : Nat) :
    padicValNat 2 (3 * (channelSeven71Fiber k) + 1) = 1 := by
  have h7 : channelSeven71Fiber k % 8 = 7 := channelSeven71Fiber_mod8_eq_seven k
  simpa [channelSeven71Fiber] using
    nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem channelSeven71_step2_nu2 (k : Nat) :
    padicValNat 2 (3 * (192 * k + 107) + 1) = 1 := by
  have h3 : (192 * k + 107) % 8 = 3 := by omega
  exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3

theorem channelSeven71_step3_nu2 (k : Nat) :
    padicValNat 2 (3 * (288 * k + 161) + 1) = 2 := by
  have h1 : (288 * k + 161) % 8 = 1 := by omega
  exact nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1

theorem syracuseOdd_channelSeven71_step1 (k : Nat) :
    syracuseOddStep (channelSeven71Fiber k) = 192 * k + 107 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step1_certificate k)
    (channelSeven71_step1_target_odd k)
    (channelSeven71_step1_nu2 k)

theorem syracuseOdd_channelSeven71_step2 (k : Nat) :
    syracuseOddStep (192 * k + 107) = 288 * k + 161 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step2_certificate k)
    (channelSeven71_step2_target_odd k)
    (channelSeven71_step2_nu2 k)

theorem syracuseOdd_channelSeven71_step3 (k : Nat) :
    syracuseOddStep (288 * k + 161) = 216 * k + 121 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step3_certificate k)
    (channelSeven71_step3_target_odd k)
    (channelSeven71_step3_nu2 k)

theorem syracuseOdd_iterate_one_channelSeven71 (k : Nat) :
    syracuseOddStep^[1] (channelSeven71Fiber k) = 192 * k + 107 := by
  rw [Function.iterate_one]
  exact syracuseOdd_channelSeven71_step1 k

theorem syracuseOdd_iterate_two_channelSeven71 (k : Nat) :
    syracuseOddStep^[2] (channelSeven71Fiber k) = 288 * k + 161 := by
  rw [Function.iterate_succ_apply', Function.iterate_one]
  rw [syracuseOdd_channelSeven71_step1, syracuseOdd_channelSeven71_step2]

theorem syracuseOdd_iterate_three_channelSeven71 (k : Nat) :
    syracuseOddStep^[3] (channelSeven71Fiber k) = 216 * k + 121 := by
  rw [Function.iterate_succ_apply', Function.iterate_succ_apply', Function.iterate_one]
  rw [syracuseOdd_channelSeven71_step1, syracuseOdd_channelSeven71_step2,
    syracuseOdd_channelSeven71_step3]

/-!
## Kurzpräfix-Anstieg: Margins über dem Start `128k + 71`
-/

theorem channelSeven71_one_step_margin (k : Nat) :
    syracuseOddStep (channelSeven71Fiber k) - channelSeven71Fiber k = 64 * k + 36 := by
  rw [syracuseOdd_channelSeven71_step1]
  simp [channelSeven71Fiber]
  omega

theorem channelSeven71_two_step_margin (k : Nat) :
    syracuseOddStep^[2] (channelSeven71Fiber k) - channelSeven71Fiber k = 160 * k + 90 := by
  rw [syracuseOdd_iterate_two_channelSeven71]
  simp [channelSeven71Fiber]
  omega

theorem channelSeven71_three_step_margin (k : Nat) :
    syracuseOddStep^[3] (channelSeven71Fiber k) - channelSeven71Fiber k = 88 * k + 50 := by
  rw [syracuseOdd_iterate_three_channelSeven71]
  simp [channelSeven71Fiber]
  omega

theorem channelSeven71_one_step_strict_ascent (k : Nat) :
    channelSeven71Fiber k < syracuseOddStep (channelSeven71Fiber k) := by
  rw [syracuseOdd_channelSeven71_step1]
  simp [channelSeven71Fiber]
  omega

theorem channelSeven71_two_step_strict_ascent (k : Nat) :
    channelSeven71Fiber k < syracuseOddStep^[2] (channelSeven71Fiber k) := by
  rw [syracuseOdd_iterate_two_channelSeven71]
  simp [channelSeven71Fiber]
  omega

/-- In Tiefe `3` steigt die Progression strikt. -/
theorem channelSeven71_three_step_strict_ascent (k : Nat) :
    channelSeven71Fiber k < syracuseOddStep^[3] (channelSeven71Fiber k) := by
  rw [syracuseOdd_iterate_three_channelSeven71]
  simp [channelSeven71Fiber]
  omega

/-!
## Tiefe 4: Terminal `162k + 91`
-/

theorem channelSeven71_step4_certificate (k : Nat) :
    3 * (216 * k + 121) + 1 = 2 ^ 2 * (162 * k + 91) := by
  ring

theorem channelSeven71_step4_target_odd (k : Nat) : Odd (162 * k + 91) := by
  exact ⟨45 + 81 * k, by ring⟩

theorem channelSeven71_step4_nu2 (k : Nat) :
    padicValNat 2 (3 * (216 * k + 121) + 1) = 2 := by
  have h1 : (216 * k + 121) % 8 = 1 := by omega
  exact nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1

/-- Valuationspräfix `[1, 1, 2, 2]` als einheitliche Prop. -/
def ChannelSeven71ValuationPrefix (k : Nat) : Prop :=
  padicValNat 2 (3 * (channelSeven71Fiber k) + 1) = 1 ∧
    padicValNat 2 (3 * (192 * k + 107) + 1) = 1 ∧
      padicValNat 2 (3 * (288 * k + 161) + 1) = 2 ∧
        padicValNat 2 (3 * (216 * k + 121) + 1) = 2

/-- Valuationspräfix `[1, 1, 2, 2]` über die ersten vier Schritte. -/
theorem channelSeven71_valuation_prefix_holds (k : Nat) :
    ChannelSeven71ValuationPrefix k :=
  ⟨channelSeven71_step1_nu2 k, channelSeven71_step2_nu2 k,
    channelSeven71_step3_nu2 k, channelSeven71_step4_nu2 k⟩

theorem syracuseOdd_channelSeven71_step4 (k : Nat) :
    syracuseOddStep (216 * k + 121) = 162 * k + 91 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step4_certificate k)
    (channelSeven71_step4_target_odd k)
    (channelSeven71_step4_nu2 k)

theorem syracuseOdd_iterate_four_channelSeven71 (k : Nat) :
    syracuseOddStep^[4] (channelSeven71Fiber k) = 162 * k + 91 := by
  rw [Function.iterate_succ_apply', syracuseOdd_iterate_three_channelSeven71,
    syracuseOdd_channelSeven71_step4]

theorem channelSeven71_four_step_margin (k : Nat) :
    syracuseOddStep^[4] (channelSeven71Fiber k) - channelSeven71Fiber k = 34 * k + 20 := by
  rw [syracuseOdd_iterate_four_channelSeven71]
  simp [channelSeven71Fiber]
  omega

theorem channelSeven71_four_step_strict_ascent (k : Nat) :
    channelSeven71Fiber k < syracuseOddStep^[4] (channelSeven71Fiber k) := by
  rw [syracuseOdd_iterate_four_channelSeven71]
  simp [channelSeven71Fiber]
  omega

/--
Uniformes Kurzpräfix-Nichtabstiegszertifikat: für `t ∈ {1,2,3,4}` liegt
`S^t(128k+71)` strikt über `128k+71`.
-/
theorem channelSeven71_short_prefix_strict_ascent
    (k : Nat) (t : Nat) (ht : t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 4) :
    channelSeven71Fiber k < syracuseOddStep^[t] (channelSeven71Fiber k) := by
  rcases ht with rfl | rfl | rfl | rfl
  · exact channelSeven71_one_step_strict_ascent k
  · exact channelSeven71_two_step_strict_ascent k
  · exact channelSeven71_three_step_strict_ascent k
  · exact channelSeven71_four_step_strict_ascent k

theorem channelSeven71_no_short_prefix_descent
    (k : Nat) (t : Nat) (ht : t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 4) :
    ¬ syracuseOddStep^[t] (channelSeven71Fiber k) < channelSeven71Fiber k := by
  rcases ht with rfl | rfl | rfl | rfl
  · intro hlt
    rw [syracuseOdd_iterate_one_channelSeven71] at hlt
    simp [channelSeven71Fiber] at hlt; omega
  · intro hlt
    rw [syracuseOdd_iterate_two_channelSeven71] at hlt
    simp [channelSeven71Fiber] at hlt; omega
  · intro hlt
    rw [syracuseOdd_iterate_three_channelSeven71] at hlt
    simp [channelSeven71Fiber] at hlt; omega
  · intro hlt
    rw [syracuseOdd_iterate_four_channelSeven71] at hlt
    simp [channelSeven71Fiber] at hlt; omega

/-!
## Verzweigung nach Tiefe 4: kaskadierender 2-adischer Lift-Baum

Nach `S⁴(n_k)=162k+91` gilt `3(162k+91)+1 = 2(243k+137)` (ausgeklammertes `2`).

Das Bewertungsspektrum am fünften Schritt ist exakt `ν₂ ∈ {1, 2, ≥3}`:

| Zweig | Bedingung | Faser | `ν₂` | `S⁵` |
|---|---|---|---|---|
| gerade | `k=2q` | `256q+71` | `1` | `486q+137` |
| `≡3 mod 4` | `k=4r+3` | `512r+455` | `2` | `486r+433` |
| `≡1 mod 4` | `k=4r+1` | `512r+199` | `≥3` | `(243r+95)/2^ν₂` |

Governance: uniformes Valuationswort `[1,1,2,2]` endet bei Schritt `5`.
-/

theorem channelSeven71_residue_mod256_even (q : Nat) :
    channelSeven71Fiber (2 * q) = 256 * q + 71 := by
  simp [channelSeven71Fiber]
  ring

theorem channelSeven71_residue_mod512_mod4_three (r : Nat) :
    channelSeven71Fiber (4 * r + 3) = 512 * r + 455 := by
  simp [channelSeven71Fiber]
  ring

theorem channelSeven71_residue_mod512_mod4_one (r : Nat) :
    channelSeven71Fiber (4 * r + 1) = 512 * r + 199 := by
  simp [channelSeven71Fiber]
  ring

theorem channelSeven71_residue_mod256_odd (q : Nat) :
    channelSeven71Fiber (2 * q + 1) = 256 * q + 199 := by
  simp [channelSeven71Fiber]
  ring

theorem channelSeven71_k_step5_branch (k : Nat) :
    (∃ q, k = 2 * q) ∨ (∃ r, k = 4 * r + 1) ∨ (∃ r, k = 4 * r + 3) := by
  have h4 : k % 4 = 0 ∨ k % 4 = 1 ∨ k % 4 = 2 ∨ k % 4 = 3 := by omega
  rcases h4 with h0 | h1 | h2 | h3
  · exact Or.inl ⟨k / 2, by omega⟩
  · exact Or.inr (Or.inl ⟨(k - 1) / 4, by omega⟩)
  · exact Or.inl ⟨k / 2, by omega⟩
  · exact Or.inr (Or.inr ⟨(k - 3) / 4, by omega⟩)

theorem channelSeven71_step5_certificate (k : Nat) :
    3 * (162 * k + 91) + 1 = 2 ^ 1 * (243 * k + 137) := by
  ring

/-!
### Zweig `k = 2q` (`256q + 71`): `ν₂ = 1`, `S⁵ = 486q + 137`
-/

theorem channelSeven71_step5_certificate_even (q : Nat) :
    3 * (162 * (2 * q) + 91) + 1 = 2 ^ 1 * (486 * q + 137) := by
  ring

theorem channelSeven71_step5_target_odd_even (q : Nat) : Odd (486 * q + 137) := by
  exact ⟨68 + 243 * q, by ring⟩

theorem channelSeven71_step4_terminal_mod8_even (q : Nat) :
    (162 * (2 * q) + 91) % 8 = 3 ∨ (162 * (2 * q) + 91) % 8 = 7 := by
  omega

theorem channelSeven71_step5_nu2_eq_one_of_k_even (q : Nat) :
    padicValNat 2 (3 * (162 * (2 * q) + 91) + 1) = 1 := by
  rcases channelSeven71_step4_terminal_mod8_even q with h3 | h7
  · simpa using nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3
  · simpa using nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem syracuseOdd_channelSeven71_step5_even (q : Nat) :
    syracuseOddStep (162 * (2 * q) + 91) = 486 * q + 137 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step5_certificate_even q)
    (channelSeven71_step5_target_odd_even q)
    (channelSeven71_step5_nu2_eq_one_of_k_even q)

theorem syracuseOdd_iterate_five_channelSeven71_even (q : Nat) :
    syracuseOddStep^[5] (channelSeven71Fiber (2 * q)) = 486 * q + 137 := by
  calc
    syracuseOddStep^[5] (channelSeven71Fiber (2 * q))
        = syracuseOddStep (syracuseOddStep^[4] (channelSeven71Fiber (2 * q))) := by
            rw [Function.iterate_succ_apply']
    _ = syracuseOddStep (162 * (2 * q) + 91) := by rw [syracuseOdd_iterate_four_channelSeven71]
    _ = 486 * q + 137 := syracuseOdd_channelSeven71_step5_even q

/-!
### Zweig `k = 4r + 3` (`512r + 455`): `ν₂ = 2`, `S⁵ = 486r + 433`
-/

theorem channelSeven71_step5_certificate_mod4_three (r : Nat) :
    3 * (162 * (4 * r + 3) + 91) + 1 = 2 ^ 2 * (486 * r + 433) := by
  ring

theorem channelSeven71_step5_target_odd_mod4_three (r : Nat) : Odd (486 * r + 433) := by
  exact ⟨216 + 243 * r, by ring⟩

theorem channelSeven71_step4_terminal_mod8_mod4_three (r : Nat) :
    (162 * (4 * r + 3) + 91) % 8 = 1 := by
  omega

theorem channelSeven71_step5_nu2_eq_two_of_k_mod4_three (r : Nat) :
    padicValNat 2 (3 * (162 * (4 * r + 3) + 91) + 1) = 2 := by
  simpa using
    nu2_three_mul_add_one_eq_two_of_mod8_eq1 (channelSeven71_step4_terminal_mod8_mod4_three r)

theorem syracuseOdd_channelSeven71_step5_mod4_three (r : Nat) :
    syracuseOddStep (162 * (4 * r + 3) + 91) = 486 * r + 433 :=
  oddCoreStep_eq_of_two_pow_mul_odd
    (channelSeven71_step5_certificate_mod4_three r)
    (channelSeven71_step5_target_odd_mod4_three r)
    (channelSeven71_step5_nu2_eq_two_of_k_mod4_three r)

theorem syracuseOdd_iterate_five_channelSeven71_mod4_three (r : Nat) :
    syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 3)) = 486 * r + 433 := by
  calc
    syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 3))
        = syracuseOddStep (syracuseOddStep^[4] (channelSeven71Fiber (4 * r + 3))) := by
            rw [Function.iterate_succ_apply']
    _ = syracuseOddStep (162 * (4 * r + 3) + 91) := by rw [syracuseOdd_iterate_four_channelSeven71]
    _ = 486 * r + 433 := syracuseOdd_channelSeven71_step5_mod4_three r

/-!
### Zweig `k = 4r + 1` (`512r + 199`): `ν₂ ≥ 3`, `S⁵ = (243r+95)/2^ν₂`
-/

theorem channelSeven71_step5_certificate_mod4_one (r : Nat) :
    3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * (243 * r + 95) := by
  ring

theorem channelSeven71_step4_terminal_mod8_mod4_one (r : Nat) :
    (162 * (4 * r + 1) + 91) % 8 = 5 := by
  omega

theorem channelSeven71_step5_quotient_parity_mod4_one (r : Nat) :
    (243 * r + 95) % 2 = (r + 1) % 2 := by
  omega

theorem channelSeven71_step5_nu2_ge_three_of_k_mod4_one (r : Nat) :
    3 ≤ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1) := by
  simpa using
    nu2_three_mul_add_one_ge_three_of_mod8_eq5 (channelSeven71_step4_terminal_mod8_mod4_one r)

theorem syracuseOdd_channelSeven71_step5_mod4_one (r : Nat) :
    syracuseOddStep (162 * (4 * r + 1) + 91) =
      (3 * (162 * (4 * r + 1) + 91) + 1) /
        2 ^ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1) := by
  unfold syracuseOddStep
  rw [oddCoreStep_eq_div_padicVal]

theorem syracuseOdd_iterate_five_channelSeven71_mod4_one (r : Nat) :
    syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 1)) =
      (3 * (162 * (4 * r + 1) + 91) + 1) /
        2 ^ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1) := by
  calc
    syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 1))
        = syracuseOddStep (syracuseOddStep^[4] (channelSeven71Fiber (4 * r + 1))) := by
            rw [Function.iterate_succ_apply']
    _ = syracuseOddStep (162 * (4 * r + 1) + 91) := by rw [syracuseOdd_iterate_four_channelSeven71]
    _ = (3 * (162 * (4 * r + 1) + 91) + 1) /
          2 ^ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1) :=
        syracuseOdd_channelSeven71_step5_mod4_one r

/-!
### Bewertungsspektrum `ν₂ ∈ {1, 2, ≥3}` und mod-256-Split (Legacy-Zweig)
-/

theorem channelSeven71_step5_quotient_odd_of_k_even (q : Nat) :
    Odd (243 * (2 * q) + 137) := by
  exact ⟨68 + 243 * q, by ring⟩

theorem channelSeven71_step5_quotient_even_of_k_odd (q : Nat) :
    (243 * (2 * q + 1) + 137) % 2 = 0 := by
  omega

theorem channelSeven71_step5_nu2_ge_two_of_k_odd (q : Nat) :
    2 ≤ padicValNat 2 (3 * (162 * (2 * q + 1) + 91) + 1) := by
  have hn : 3 * (162 * (2 * q + 1) + 91) + 1 ≠ 0 := by omega
  have h4dvd : 4 ∣ 3 * (162 * (2 * q + 1) + 91) + 1 := by
    have hfactor :
        3 * (162 * (2 * q + 1) + 91) + 1 = 2 * (243 * (2 * q + 1) + 137) := by
      simpa using channelSeven71_step5_certificate (2 * q + 1)
    rw [hfactor]
    have h2 : (243 * (2 * q + 1) + 137) % 2 = 0 :=
      channelSeven71_step5_quotient_even_of_k_odd q
    omega
  exact (padicValNat_dvd_iff_le (p := 2) (a := 3 * (162 * (2 * q + 1) + 91) + 1) hn).1 h4dvd

/-- Vollständige Schritt-5-Kaskade: drei disjunkte Zweige mit Bewertungsspektrum. -/
structure ChannelSeven71Step5BranchingCascade where
  k_partition :
    ∀ k : Nat,
      (∃ q, k = 2 * q) ∨ (∃ r, k = 4 * r + 1) ∨ (∃ r, k = 4 * r + 3)
  residue_mod256_even : ∀ q : Nat, channelSeven71Fiber (2 * q) = 256 * q + 71
  residue_mod512_mod4_three : ∀ r : Nat, channelSeven71Fiber (4 * r + 3) = 512 * r + 455
  residue_mod512_mod4_one : ∀ r : Nat, channelSeven71Fiber (4 * r + 1) = 512 * r + 199
  nu2_eq_one_even :
    ∀ q : Nat, padicValNat 2 (3 * (162 * (2 * q) + 91) + 1) = 1
  nu2_eq_two_mod4_three :
    ∀ r : Nat, padicValNat 2 (3 * (162 * (4 * r + 3) + 91) + 1) = 2
  nu2_ge_three_mod4_one :
    ∀ r : Nat, 3 ≤ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1)
  iterate_five_even :
    ∀ q : Nat, syracuseOddStep^[5] (channelSeven71Fiber (2 * q)) = 486 * q + 137
  iterate_five_mod4_three :
    ∀ r : Nat, syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 3)) = 486 * r + 433
  iterate_five_mod4_one :
    ∀ r : Nat,
      syracuseOddStep^[5] (channelSeven71Fiber (4 * r + 1)) =
        (3 * (162 * (4 * r + 1) + 91) + 1) /
          2 ^ padicValNat 2 (3 * (162 * (4 * r + 1) + 91) + 1)
  step5_certificate_mod4_one :
    ∀ r : Nat, 3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * (243 * r + 95)
  quotient_parity_mod4_one :
    ∀ r : Nat, (243 * r + 95) % 2 = (r + 1) % 2

theorem channel_seven71_step5_branching_cascade : ChannelSeven71Step5BranchingCascade where
  k_partition := channelSeven71_k_step5_branch
  residue_mod256_even := channelSeven71_residue_mod256_even
  residue_mod512_mod4_three := channelSeven71_residue_mod512_mod4_three
  residue_mod512_mod4_one := channelSeven71_residue_mod512_mod4_one
  nu2_eq_one_even := channelSeven71_step5_nu2_eq_one_of_k_even
  nu2_eq_two_mod4_three := channelSeven71_step5_nu2_eq_two_of_k_mod4_three
  nu2_ge_three_mod4_one := channelSeven71_step5_nu2_ge_three_of_k_mod4_one
  iterate_five_even := syracuseOdd_iterate_five_channelSeven71_even
  iterate_five_mod4_three := syracuseOdd_iterate_five_channelSeven71_mod4_three
  iterate_five_mod4_one := syracuseOdd_iterate_five_channelSeven71_mod4_one
  step5_certificate_mod4_one := channelSeven71_step5_certificate_mod4_one
  quotient_parity_mod4_one := channelSeven71_step5_quotient_parity_mod4_one

/--
Status der offenen `71 mod 128`-Progression: uniformes Kurzpräfix-Nichtabstiegszertifikat
bis Tiefe `4`; Verzweigung ab Tiefe `5` via `mod 256`.
-/
structure ChannelSeven71OpenFiberStatus : Prop where
  has_valuation_prefix : ∀ (k : Nat), ChannelSeven71ValuationPrefix k
  has_one_step_form :
    ∀ k : Nat, syracuseOddStep^[1] (channelSeven71Fiber k) = 192 * k + 107
  has_two_step_form :
    ∀ k : Nat, syracuseOddStep^[2] (channelSeven71Fiber k) = 288 * k + 161
  has_three_step_form :
    ∀ k : Nat, syracuseOddStep^[3] (channelSeven71Fiber k) = 216 * k + 121
  has_four_step_form :
    ∀ k : Nat, syracuseOddStep^[4] (channelSeven71Fiber k) = 162 * k + 91
  short_prefix_strict_ascent :
    ∀ k : Nat, ∀ t : Nat, (t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 4) →
      channelSeven71Fiber k < syracuseOddStep^[t] (channelSeven71Fiber k)
  short_prefix_no_descent :
    ∀ k : Nat, ∀ t : Nat, (t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 4) →
      ¬ syracuseOddStep^[t] (channelSeven71Fiber k) < channelSeven71Fiber k
  /-- Schritt-5-Kaskade: `ν₂ ∈ {1,2,≥3}`, erste zwei Lift-Baum-Ebenen. -/
  step5_branching_cascade : ChannelSeven71Step5BranchingCascade
  mod256_even_residue : ∀ q : Nat, channelSeven71Fiber (2 * q) = 256 * q + 71
  mod256_odd_residue : ∀ q : Nat, channelSeven71Fiber (2 * q + 1) = 256 * q + 199
  step5_nu2_split :
    (∀ q : Nat, padicValNat 2 (3 * (162 * (2 * q) + 91) + 1) = 1) ∧
      (∀ q : Nat, 2 ≤ padicValNat 2 (3 * (162 * (2 * q + 1) + 91) + 1))

theorem channel_seven71_open_fiber_status : ChannelSeven71OpenFiberStatus where
  has_valuation_prefix := fun k => channelSeven71_valuation_prefix_holds k
  has_one_step_form := syracuseOdd_iterate_one_channelSeven71
  has_two_step_form := syracuseOdd_iterate_two_channelSeven71
  has_three_step_form := syracuseOdd_iterate_three_channelSeven71
  has_four_step_form := syracuseOdd_iterate_four_channelSeven71
  short_prefix_strict_ascent := fun k t ht =>
    channelSeven71_short_prefix_strict_ascent k t ht
  short_prefix_no_descent := fun k t ht =>
    channelSeven71_no_short_prefix_descent k t ht
  step5_branching_cascade := channel_seven71_step5_branching_cascade
  mod256_even_residue := channelSeven71_residue_mod256_even
  mod256_odd_residue := channelSeven71_residue_mod256_odd
  step5_nu2_split := ⟨channelSeven71_step5_nu2_eq_one_of_k_even,
    channelSeven71_step5_nu2_ge_two_of_k_odd⟩

end KeplerHurwitz.Collatz.ChannelSevenAttackV213
