import Mathlib
import KeplerHurwitz.CollatzProofAttemptV27

namespace KeplerHurwitz

namespace CollatzAttemptV2

/-!
## V2.8 — mod-8 channel-3 half-case + 2-adic budget scaffold

Attack vectors (see `docs/collatz_v27_net_descent.md`):
- **Option A/C (partial):** channel `3` with `T_odd n % 8 = 5` (`k` even) closes at uniform `t_loc = 4`.
- **Option B (scaffold):** `badRunTwoAdicBudget = ν₂(n+1)` budgets bad-run chains; channel `7` reduction.
- **Option A (open):** channel `3` with `T_odd n % 8 = 1` (`k` odd) — `t_loc` is `k`-dependent, no uniform bound yet.
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

/--
`[C]` Channel-`3` odd-`k` subcase (`T_odd n % 8 = 1`): `t_loc` is `k`-dependent.
Diagnostics show minima in `{6, 9, 11, …}` with no closed form uniform bound yet.
-/
theorem bad_run_net_descent_witness_mod8_channel_three_mod8_one
    {n : Nat}
    (hn : 1 < n)
    (h8 : n % 8 = 3)
    (hone : T_odd n % 8 = 1) :
    Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3) := by
  sorry

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
V2.8 status: channel-`3` even-`k` net descent at `t_loc = 4`; odd-`k` and channel `7` open.
-/
structure CollatzProofAttemptStatusV28 : Prop where
  base_v27 : CollatzProofAttemptStatusV27
  channel_three_mod8_five_net_descent :
    ∀ {n : Nat}, 1 < n → n % 8 = 3 → T_odd n % 8 = 5 →
      Nonempty (BadRunNetDescentWitnessMod8 n Mod4ThreeInputChannel.ch3)
  bad_run_two_adic_budget_ge_two :
    ∀ {n : Nat}, n % 4 = 3 → 2 ≤ badRunTwoAdicBudget n

theorem collatz_proof_attempt_status_v28 : CollatzProofAttemptStatusV28 where
  base_v27 := collatz_proof_attempt_status_v27
  channel_three_mod8_five_net_descent := fun hn h8 hfive =>
    bad_run_net_descent_witness_mod8_channel_three_mod8_five hn h8 hfive
  bad_run_two_adic_budget_ge_two := fun hmod =>
    bad_run_two_adic_budget_ge_two_of_mod4_eq_three hmod

end ProofAttempt
end CollatzAttemptV2

end KeplerHurwitz
