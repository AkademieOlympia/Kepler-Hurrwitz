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
- **Option A (open):** channel `3` with `T_odd n % 8 = 1` and `k % 4 = 3` — `t_loc` is `k`-dependent (e.g. `n=27` ⇒ `t_loc=94`); subclass `n ≡ 59 (mod 128)` closes at `t_loc = 9`.
- **Option D (open):** channel `7` uniform witness via depth budget consumption.
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
`[C]` Channel-`3` odd-`k` with `k % 4 = 3` and `j % 4 ≠ 1`: `t_loc` is `j`-dependent
(e.g. `n = 27` needs `t_loc ≈ 94`; subclasses `n ≡ {27, 91, 123} (mod 128)` remain open).
-/
theorem bad_run_net_descent_witness_mod8_channel_three_k_mod4_three_j_not_mod4_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hj : ∃ j, n = 32 * j + 27 ∧ j % 4 ≠ 1) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  sorry

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
`[C]` Channel `7` uniform witness via depth-budget consumption + good-branch shrink.
Requires `BadRunTwoAdicBudgetExhaustionStatement` or an explicit `t_loc` bound.
-/
theorem bad_run_net_descent_witness_mod8_channel_seven_v28
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch7) := by
  sorry

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
odd-`k` `k%4=3` with `j%4=1` at `t_loc = 9`; other `k%4=3` subclasses and channel `7` open.
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
  channel_three_uniform_five_step_barrier :
    ∀ {k : Nat}, k % 2 = 1 → 0 < k →
      (8 * k + 3) ≤ (collatzStep^[5]) (T_odd (8 * k + 3))
  channel_three_eight_step_fails_mod128_fiftynine :
    ∀ {m : Nat}, (128 * m + 59) ≤ (collatzStep^[8]) (T_odd (128 * m + 59))
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
  channel_three_uniform_five_step_barrier := fun hk_odd hk_pos =>
    channel_three_uniform_five_step_fails_net hk_odd hk_pos
  channel_three_eight_step_fails_mod128_fiftynine := fun {m} =>
    channel_three_eight_step_fails_net_mod128_fiftynine (m := m)
  bad_run_two_adic_budget_ge_two := fun hmod =>
    bad_run_two_adic_budget_ge_two_of_mod4_eq_three hmod

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
