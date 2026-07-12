import Mathlib
import KeplerHurwitz.CollatzProofAttemptV27

namespace KeplerHurwitz

namespace CollatzAttemptV2

/-!
## V2.8 — mod-8 channel-3 half-case + 2-adic budget scaffold

Attack vectors (see `docs/collatz_v27_net_descent.md`):
- **Option A (partial):** channel `3` with `T_odd n % 8 = 5` (`k` even) closes at uniform `t_loc = 4`.
- **Option A (partial):** channel `3` with `T_odd n % 8 = 1` and `k % 4 = 1` closes at uniform `t_loc = 6`.
- **Option B (scaffold):** `badRunTwoAdicBudget = ν₂(n+1)` budgets bad-run chains; channel `7` reduction.
- **Option A (open):** channel `3` with `T_odd n % 8 = 1` and `k % 4 = 3` — mod-256 subclasses
  `{27, 91, 155, 251}` remain open; `{123, 219}` close at uniform `t_loc = 11`.
- **Option A (partial):** channel `7` with `k % 4 = 2` (`n = 32j+23`) closes at uniform `t_loc = 6`.
- **Option D (open):** channel `7` other `k % 4` classes via depth-budget consumption.
-/

namespace CollatzNetDescentV28

open CollatzNetDescent
open CollatzNetDescentMod8
open CollatzNetDescentMod8Witness
open CollatzBridge
open ProofAttempt
open ExitDepth

/-!
### 2-adic budget interface (Option B scaffold)

For `n ≡ 3 (mod 4)`, `ν₂(n+1) ≥ 2` is exact bad-run depth data from V2.5.
An infinite bad run without net descent would need to consume unbounded budget;
this layer names the budget and records the intended contradiction template.
-/

/-- 2-adic tail budget at a `mod 4 = 3` start: `ν₂(n+1)`. -/
def badRunTwoAdicBudget (n : Nat) : Nat :=
  padicValNat 2 (n + 1)

theorem bad_run_two_adic_budget_ge_two_of_mod4_eq_three
    {n : Nat} (hmod : n % 4 = 3) :
    2 ≤ badRunTwoAdicBudget n := by
  unfold badRunTwoAdicBudget
  exact two_le_padicValNat_two_of_mod4_eq_three hmod

/--
`[A]` Channel `7` inherits the same `ν₂(n+1) ≥ 2` budget lower bound.
-/
theorem channel_seven_bad_run_budget_ge_two
    {n : Nat} (h7 : n % 8 = 7) :
    2 ≤ badRunTwoAdicBudget n := by
  unfold badRunTwoAdicBudget
  exact two_le_padicValNat_two_of_mod4_eq_three (by omega : n % 4 = 3)

/--
`[C]` Intended contradiction: a bad run without net descent cannot outlive its `ν₂(n+1)` budget.
-/
def BadRunTwoAdicBudgetExhaustionStatement : Prop :=
  ∀ {n : Nat}, 1 < n → n % 4 = 3 →
    BadRunNetDescentStatement →
    True

/-!
### Channel `3` — even-`k` / `T_odd % 8 = 5` half-case (Option A/C, proved)
-/

/--
`[A]` Uniform `t_loc = 4` net descent for channel `3` when `T_odd n % 8 = 5` (i.e. `k` even).
-/
theorem bad_run_net_descent_witness_mod8_channel_three_mod8_five
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hfive : T_odd n % 8 = 5) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three h8 with ⟨k, rfl⟩
  have hk_even : k % 2 = 0 := (T_odd_mod8_eq_five_iff_k_even_of_mod8_eq_three (n := 8 * k + 3) rfl).mp hfive
  refine ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 4 ?_⟩
  exact channel_three_collatz_net_descent_mod8_five_at_four hn h8 ⟨k, rfl, hk_even⟩

/--
`[A]` Channel-`3` witness from the even-`k` subcase alone.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_even_k
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (heven : ∃ k, n = 8 * k + 3 ∧ k % 2 = 0) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases heven with ⟨k, hk, hk_even⟩
  have hfive : T_odd n % 8 = 5 :=
    (T_odd_mod8_eq_five_iff_k_even_of_mod8_eq_three hk).mpr hk_even
  exact bad_run_net_descent_witness_mod8_channel_three_mod8_five hn h8 hfive

/-!
### Channel `3` — odd-`k` / `T_odd % 8 = 1` half-case (Option A/C, partial)

Uniform `t_loc ≤ 5` is impossible (`channel_three_uniform_five_step_fails_net_odd_k`).
Uniform `t_loc = 6` works iff `k % 4 = 1`; the subcase `k % 4 = 3` remains open.
-/

/--
`[A]` Uniform five-step barrier for odd `k`: `(collatzStep^[5]) (T_odd n) ≥ n` whenever `k > 0`.
-/
theorem channel_three_uniform_five_step_fails_net
    {k : Nat} (hk_odd : k % 2 = 1) (hk_pos : 0 < k) :
    (8 * k + 3) ≤ (collatzStep^[5]) (T_odd (8 * k + 3)) :=
  channel_three_uniform_five_step_fails_net_odd_k hk_odd hk_pos

/--
`[A]` Uniform six-step barrier at `k % 4 = 3`: six steps still do not beat `n`.
-/
theorem channel_three_uniform_six_step_fails_k_mod4_three
    {j : Nat} :
    (32 * j + 27) ≤ (collatzStep^[6]) (T_odd (32 * j + 27)) :=
  channel_three_six_step_fails_net_k_mod4_three

/--
`[A]` Channel-`3` odd-`k` with `k % 4 = 1`: full witness at uniform `t_loc = 6`.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hk1 : ∃ j, n = 32 * j + 11) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  refine ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 6 ?_⟩
  exact channel_three_collatz_net_descent_mod8_one_at_six_k_mod4_one hn h8 hk1

/--
`[A]` Channel-`3` odd-`k` with `k % 4 = 3` and `j % 4 = 1` (`n ≡ 59 mod 128`): full witness at `t_loc = 9`.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_mod4_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (h59 : ∃ m, n = 128 * m + 59) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  refine ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 9 ?_⟩
  exact channel_three_collatz_net_descent_mod128_fiftynine_at_nine hn h8 h59

/--
`[A]` Channel-`3` odd-`k` with `k % 4 = 3` and `j % 8 = 3` (`n ≡ 123 mod 256`): full witness at `t_loc = 11`.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_j_mod8_three
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (h123 : ∃ m, n = 256 * m + 123) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  refine ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 11 ?_⟩
  exact channel_three_collatz_net_descent_mod256_one_hundred_twenty_three_at_eleven hn h8 h123

/--
`[A]` Channel-`3` odd-`k` with `k % 4 = 3` and `j % 8 = 6` (`n ≡ 219 mod 256`): full witness at `t_loc = 11`.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_j_mod8_six
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (h219 : ∃ m, n = 256 * m + 219) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  refine ⟨bad_run_net_descent_witness_mod8_channel_three_of_local_shrink h8 11 ?_⟩
  exact channel_three_collatz_net_descent_mod256_two_hundred_nineteen_at_eleven hn h8 h219

/--
`[C]` Channel-`3` odd-`k` with `k % 4 = 3` and `j % 8 ∉ {1, 3, 6}`: mod-256 subclasses
`n ≡ {27, 91, 155, 251} (mod 256)` remain open (e.g. `n = 27` needs `t_loc ≈ 94`).
-/
theorem bad_run_net_descent_witness_mod8_channel_three_j_mod8_open
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hj : ∃ j, n = 32 * j + 27 ∧ j % 8 ≠ 1 ∧ j % 8 ≠ 3 ∧ j % 8 ≠ 6) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  sorry

/--
`[C]` Channel-`3` odd-`k` with `k % 4 = 3`: `j % 8 = 1` at `t_loc = 9`, `{3,6}` at `t_loc = 11`;
other mod-256 subclasses open.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_not_mod4_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hj : ∃ j, n = 32 * j + 27 ∧ j % 4 ≠ 1) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases hj with ⟨j, hnj, hj1⟩
  rcases (show j % 8 = 0 ∨ j % 8 = 2 ∨ j % 8 = 3 ∨ j % 8 = 4 ∨ j % 8 = 6 ∨ j % 8 = 7 from by omega) with
      h0 | h2 | h3 | h4 | h6 | h7
  · exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_open
      hn h8 ⟨j, hnj, by omega, by omega, by omega⟩
  · exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_open
      hn h8 ⟨j, hnj, by omega, by omega, by omega⟩
  · rcases exists_eq_two_hundred_fifty_six_mul_add_one_hundred_twenty_three_of_j_mod8_three
      hnj h3 with ⟨m, hnm, _⟩
    exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_three hn h8 ⟨m, hnm⟩
  · exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_open
      hn h8 ⟨j, hnj, by omega, by omega, by omega⟩
  · rcases exists_eq_two_hundred_fifty_six_mul_add_two_hundred_nineteen_of_j_mod8_six
      hnj h6 with ⟨m, hnm, _⟩
    exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_six hn h8 ⟨m, hnm⟩
  · exact bad_run_net_descent_witness_mod8_channel_three_j_mod8_open
      hn h8 ⟨j, hnj, by omega, by omega, by omega⟩

/--
`[C]` Channel-`3` odd-`k` with `k % 4 = 3`: `j % 4 = 1` closed at `t_loc = 9`; other mod-128 subclasses open.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_three
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hk3 : ∃ j, n = 32 * j + 27) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases hk3 with ⟨j, hnj⟩
  rcases (show j % 4 = 0 ∨ j % 4 = 1 ∨ j % 4 = 2 ∨ j % 4 = 3 from by omega) with
      h0 | h1 | h2 | h3
  · exact bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_not_mod4_one
      hn h8 ⟨j, hnj, by omega⟩
  · have hj1 : j % 4 = 1 := h1
    rcases exists_eq_one_hundred_twenty_eight_mul_add_fiftynine_of_mod8_eq_three_and_j_mod4_one
      hnj hj1 with ⟨m, hnm, _⟩
    exact bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_mod4_one hn h8 ⟨m, hnm⟩
  · exact bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_not_mod4_one
      hn h8 ⟨j, hnj, by omega⟩
  · exact bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_not_mod4_one
      hn h8 ⟨j, hnj, by omega⟩

/--
`[C]` Channel-`3` odd-`k` subcase (`T_odd n % 8 = 1`): `k % 4 = 1` closed at `t_loc = 6`;
`k % 4 = 3` with `j % 4 = 1` closed at `t_loc = 9`; remaining mod-128 subclasses open.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_mod8_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hone : T_odd n % 8 = 1) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three h8 with ⟨k, rfl⟩
  have hk_odd : k % 2 = 1 :=
    (T_odd_mod8_eq_one_iff_k_odd_of_mod8_eq_three rfl).mp hone
  rcases (show k % 4 = 1 ∨ k % 4 = 3 from by omega) with hk1 | hk3
  · have hk1' : k % 4 = 1 := hk1
    rcases exists_eq_thirty_two_mul_add_eleven_of_mod8_eq_three_and_k_mod4_one rfl hk1' with
      ⟨j, hnj, _⟩
    exact bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one hn h8 ⟨j, hnj⟩
  · have hk3' : k % 4 = 3 := hk3
    rcases exists_eq_thirty_two_mul_add_twentyseven_of_mod8_eq_three_and_k_mod4_three rfl hk3' with
      ⟨j, hnj, _⟩
    exact bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_three hn h8 ⟨j, hnj⟩

/--
`[C]` Channel `3` uniform witness: even-`k` case is `[A]`; odd-`k` subcase remains open.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_v28
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three h8 with ⟨k, rfl⟩
  rcases Nat.even_or_odd k with ⟨j, hj⟩ | ⟨j, hj⟩
  · have hk_even : k % 2 = 0 := by simpa [hj] using Nat.even_iff.mp ⟨j, hj⟩
    have hfive : T_odd (8 * k + 3) % 8 = 5 :=
      (T_odd_mod8_eq_five_iff_k_even_of_mod8_eq_three rfl).mpr hk_even
    exact bad_run_net_descent_witness_mod8_channel_three_mod8_five hn h8 hfive
  · have hk_odd : k % 2 = 1 := by simpa [hj] using Nat.odd_iff.mp ⟨j, hj⟩
    have hone : T_odd (8 * k + 3) % 8 = 1 :=
      (T_odd_mod8_eq_one_iff_k_odd_of_mod8_eq_three rfl).mpr hk_odd
    exact bad_run_net_descent_witness_mod8_channel_three_mod8_one hn h8 hone

/-!
### Channel `7` — bad-run depth reduction (Option D scaffold)
-/

/--
`[A]` Channel `7` starts in the bad tail: `T_odd n % 4 = 3`.
-/
theorem channel_seven_T_odd_mod4_eq_three
    {n : Nat} (h7 : n % 8 = 7) :
    T_odd n % 4 = 3 :=
  T_odd_mod4_eq_three_of_mod8_eq_seven h7

/--
`[A]` Channel `7` with `k % 4 = 2` (`n = 32j+23`): full witness at `t_good = 4`, `t_loc = 4`.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases channel_seven_net_descent_from_good_at_four_k_mod4_two hn h7 hk2 with
    ⟨j, hnj, hnet⟩
  refine ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 4 (72 * j + 53)
          (by rw [hnj]; exact channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three j)
          (channel_seven_four_step_good_mod4_one_of_thirty_two_mul_add_twenty_three j))
        4 hnet
    input_mod8 := h7 }⟩

/--
`[A]` Channel `7` subclass `n ≡ 7 (mod 128)`: witness at `t_good = 4`, `t_loc = 7`.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_mod128_seven
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 7) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hn⟩
  have hreach :
      (collatzStep^[4]) n = 288 * m + 17 := by
    rw [hn]; exact channel_seven_four_step_value_of_one_hundred_twenty_eight_mul_add_seven m
  have hgood : (288 * m + 17) % 4 = 1 :=
    channel_seven_four_step_good_mod4_one_of_one_hundred_twenty_eight_mul_add_seven m
  have hnet : (collatzStep^[7]) (288 * m + 17) < n := by
    have hshrink :
        (collatzStep^[7]) (288 * m + 17) = 81 * m + 5 :=
      channel_seven_seven_step_shrink_value_of_two_hundred_eighty_eight_mul_add_seventeen m
    rw [hshrink, hn]
    rcases m with _ | m
    · norm_num
    · omega
  exact ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 4 (288 * m + 17) hreach hgood)
        7 hnet
    input_mod8 := h7 }⟩

/--
`[A]` Channel `7` subclass `n ≡ 15 (mod 128)`: witness at `t_good = 6`, `t_loc = 5`.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_mod128_fifteen
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 15) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hn⟩
  have hreach :
      (collatzStep^[6]) n = 432 * m + 53 := by
    rw [hn]; exact channel_seven_six_step_value_of_one_hundred_twenty_eight_mul_add_fifteen m
  have hgood : (432 * m + 53) % 4 = 1 :=
    channel_seven_six_step_good_mod4_one_of_one_hundred_twenty_eight_mul_add_fifteen m
  have hnet : (collatzStep^[5]) (432 * m + 53) < n := by
    have hshrink :
        (collatzStep^[5]) (432 * m + 53) = 81 * m + 10 :=
      channel_seven_five_step_shrink_value_of_four_hundred_thirty_two_mul_add_fiftythree m
    rw [hshrink, hn]
    rcases m with _ | m
    · norm_num
    · omega
  exact ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 6 (432 * m + 53) hreach hgood)
        5 hnet
    input_mod8 := h7 }⟩

/--
`[A]` Channel `7` subclass `n ≡ 79 (mod 256)` (`j % 8 = 2` within `k % 4 = 1`):
witness at `t_good = 6`, `t_loc = 7`. Mod-128 class `79` requires this 2-adic split.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_mod256_seventy_nine
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 79) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hn⟩
  have hreach :
      (collatzStep^[6]) n = 864 * m + 269 := by
    rw [hn]; exact channel_seven_six_step_value_of_two_hundred_fifty_six_mul_add_seventy_nine m
  have hgood : (864 * m + 269) % 4 = 1 :=
    channel_seven_six_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_seventy_nine m
  have hnet : (collatzStep^[7]) (864 * m + 269) < n := by
    have hshrink :
        (collatzStep^[7]) (864 * m + 269) = 243 * m + 76 :=
      channel_seven_seven_step_shrink_value_of_eight_hundred_sixty_four_mul_add_two_sixtynine m
    rw [hshrink, hn]
    rcases m with _ | m
    · norm_num
    · omega
  exact ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 6 (864 * m + 269) hreach hgood)
        7 hnet
    input_mod8 := h7 }⟩

/--
`[A]` Channel `7` subclass `n ≡ 95 (mod 256)` (`j % 8 = 2` within `k % 4 = 3`):
witness at `t_good = 8`, `t_loc = 5`. Mod-128 class `95` requires this 2-adic split.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_mod256_ninety_five
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 95) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hn⟩
  have hreach :
      (collatzStep^[8]) n = 1296 * m + 485 := by
    rw [hn]; exact channel_seven_eight_step_value_of_two_hundred_fifty_six_mul_add_ninety_five m
  have hgood : (1296 * m + 485) % 4 = 1 :=
    channel_seven_eight_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_ninety_five m
  have hnet : (collatzStep^[5]) (1296 * m + 485) < n := by
    have hshrink :
        (collatzStep^[5]) (1296 * m + 485) = 243 * m + 91 :=
      channel_seven_five_step_shrink_value_of_twelve_hundred_ninety_six_mul_add_four_eightyfive m
    rw [hshrink, hn]
    rcases m with _ | m
    · norm_num
    · omega
  exact ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 8 (1296 * m + 485) hreach hgood)
        5 hnet
    input_mod8 := h7 }⟩

/--
`[A]` Channel `7` subclass `n ≡ 39 (mod 256)` (`j % 8 = 1` within `k % 4 = 0`):
witness at `t_good = 4`, `t_loc = 9`. Mod-128 class `39` requires this 2-adic split.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_mod256_thirty_nine
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 39) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases hmod with ⟨m, hn⟩
  have hreach :
      (collatzStep^[4]) n = 576 * m + 89 := by
    rw [hn]; exact channel_seven_four_step_value_of_two_hundred_fifty_six_mul_add_thirty_nine m
  have hgood : (576 * m + 89) % 4 = 1 :=
    channel_seven_four_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_thirty_nine m
  have hnet : (collatzStep^[9]) (576 * m + 89) < n := by
    have hshrink :
        (collatzStep^[9]) (576 * m + 89) = 243 * m + 38 :=
      channel_seven_nine_step_shrink_value_of_five_hundred_seventy_six_mul_add_eightynine m
    rw [hshrink, hn]
    rcases m with _ | m
    · norm_num
    · omega
  exact ⟨{
    toBadRunNetDescentWitness :=
      BadRunNetDescentWitness.ofGoodBranchEntry
        (BadRunGoodBranchEntryWitness.ofMod4Three 4 (576 * m + 89) hreach hgood)
        9 hnet
    input_mod8 := h7 }⟩

/--
`[C]` Channel `7` with `k % 4 ≠ 2`: uniform witness via depth-budget consumption.
Requires `BadRunTwoAdicBudgetExhaustionStatement` or explicit `t_loc` bounds.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hk : ∃ k, n = 8 * k + 7 ∧ k % 4 ≠ 2) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  sorry

/--
`[C]` Channel `7` uniform witness: `k % 4 = 2` subcase is `[A]`; other classes remain open.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_v28
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  rcases exists_eq_eight_mul_add_seven_of_mod8_eq_seven h7 with ⟨k, rfl⟩
  rcases (show k % 4 = 0 ∨ k % 4 = 1 ∨ k % 4 = 2 ∨ k % 4 = 3 from by omega) with
      h0 | h1 | h2 | h3
  · exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two
      hn h7 ⟨k, rfl, by omega⟩
  · exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two
      hn h7 ⟨k, rfl, by omega⟩
  · have hk2 : k % 4 = 2 := h2
    rcases exists_eq_thirty_two_mul_add_twenty_three_of_mod8_eq_seven_and_k_mod4_two rfl hk2 with
      ⟨j, hnj, _⟩
    exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 ⟨j, hnj⟩
  · exact bad_run_net_descent_witness_mod8_channel_seven_k_mod4_not_two
      hn h7 ⟨k, rfl, by omega⟩

/--
`[C]` V2.8 assembly: channel `3` even-`k` subcase proved; odd-`k` and channel `7` remain open.
-/
theorem bad_run_net_descent_witness_of_mod4_three_v28
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3) :
    Nonempty (BadRunNetDescentWitness n) := by
  have ho : n % 2 = 1 := by omega
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · rcases bad_run_net_descent_witness_mod8_channel_three_v28 hn h3 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩
  · rcases bad_run_net_descent_witness_mod8_channel_seven_v28 hn h7 with ⟨w⟩
    exact ⟨bad_run_net_descent_witness_of_mod8_channel w⟩

end CollatzNetDescentV28

namespace ProofAttempt

open CollatzNetDescent
open CollatzNetDescentV28
open CollatzNetDescentMod8
open CollatzNetDescentMod8Witness

/--
V2.8 status: channel-`3` even-`k` net descent at `t_loc = 4`; odd-`k` `k%4=1` at `t_loc = 6`;
odd-`k` `k%4=3` with `j%4=1` at `t_loc = 9`; mod-256 `{123,219}` at `t_loc = 11`;
channel `7` `k%4=2` at `t_good=4`, `t_loc=4`; remaining subclasses open.
-/
structure CollatzProofAttemptStatusV28 : Prop where
  base_v27 : CollatzProofAttemptStatusV27
  channel_three_mod8_five_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → T_odd n % 8 = 5 →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  channel_three_mod8_one_k_mod4_one_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → (∃ j, n = 32 * j + 11) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  channel_three_k_mod4_three_j_mod4_one_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → (∃ m, n = 128 * m + 59) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  channel_three_mod256_one_hundred_twenty_three_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → (∃ m, n = 256 * m + 123) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  channel_three_mod256_two_hundred_nineteen_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → (∃ m, n = 256 * m + 219) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  channel_seven_k_mod4_two_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ j, n = 32 * j + 23) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7)
  channel_seven_mod256_seventy_nine_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 79) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7)
  channel_seven_mod256_ninety_five_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 95) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7)
  channel_seven_mod256_thirty_nine_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 7 → (∃ m, n = 256 * m + 39) →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7)
  channel_three_uniform_five_step_barrier :
    ∀ {k : Nat}, k % 2 = 1 → 0 < k →
      (8 * k + 3) ≤ (collatzStep^[5]) (T_odd (8 * k + 3))
  channel_three_ten_step_fails_mod256_one_hundred_twenty_three :
    ∀ {m : Nat}, (256 * m + 123) ≤ (collatzStep^[10]) (T_odd (256 * m + 123))
  channel_three_ten_step_fails_mod256_two_hundred_nineteen :
    ∀ {m : Nat}, (256 * m + 219) ≤ (collatzStep^[10]) (T_odd (256 * m + 219))
  channel_seven_five_step_fails_k_mod4_two :
    ∀ {j : Nat}, (32 * j + 23) ≤ (collatzStep^[5]) (T_odd (32 * j + 23))
  bad_run_two_adic_budget_ge_two :
    ∀ {n : Nat}, n % 4 = 3 → 2 ≤ badRunTwoAdicBudget n

theorem collatz_proof_attempt_status_v28 : CollatzProofAttemptStatusV28 where
  base_v27 := collatz_proof_attempt_status_v27
  channel_three_mod8_five_net_descent := fun hn h8 hfive =>
    bad_run_net_descent_witness_mod8_channel_three_mod8_five hn h8 hfive
  channel_three_mod8_one_k_mod4_one_net_descent := fun hn h8 hk1 =>
    bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one hn h8 hk1
  channel_three_k_mod4_three_j_mod4_one_net_descent := fun hn h8 h59 =>
    bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_mod4_one hn h8 h59
  channel_three_mod256_one_hundred_twenty_three_net_descent := fun hn h8 h123 =>
    bad_run_net_descent_witness_mod8_channel_three_j_mod8_three hn h8 h123
  channel_three_mod256_two_hundred_nineteen_net_descent := fun hn h8 h219 =>
    bad_run_net_descent_witness_mod8_channel_three_j_mod8_six hn h8 h219
  channel_seven_k_mod4_two_net_descent := fun hn h7 hk2 =>
    bad_run_net_descent_witness_mod8_channel_seven_k_mod4_two hn h7 hk2
  channel_seven_mod256_seventy_nine_net_descent := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod256_seventy_nine hn h7 hmod
  channel_seven_mod256_ninety_five_net_descent := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod256_ninety_five hn h7 hmod
  channel_seven_mod256_thirty_nine_net_descent := fun hn h7 hmod =>
    bad_run_net_descent_witness_mod8_channel_seven_mod256_thirty_nine hn h7 hmod
  channel_three_uniform_five_step_barrier := fun hk_odd hk_pos =>
    channel_three_uniform_five_step_fails_net hk_odd hk_pos
  channel_three_ten_step_fails_mod256_one_hundred_twenty_three := fun {m} =>
    channel_three_ten_step_fails_net_mod256_one_hundred_twenty_three (m := m)
  channel_three_ten_step_fails_mod256_two_hundred_nineteen := fun {m} =>
    channel_three_ten_step_fails_net_mod256_two_hundred_nineteen (m := m)
  channel_seven_five_step_fails_k_mod4_two := fun {j} =>
    channel_seven_five_step_fails_net_k_mod4_two (j := j)
  bad_run_two_adic_budget_ge_two := fun hmod =>
    bad_run_two_adic_budget_ge_two_of_mod4_eq_three hmod

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
