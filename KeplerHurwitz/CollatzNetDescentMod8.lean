import Mathlib
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.Nu2Bounds
import KeplerHurwitz.ResidueFilters
import KeplerHurwitz.SchalenDynamik
import KeplerHurwitz.OddCoreDynamics

namespace KeplerHurwitz

namespace CollatzAttemptV2

namespace CollatzNetDescentMod8

/-!
## Mod-8 stratification for the open net-descent witness

Proof axis: for `n ≡ 3 (mod 4)`, `ν₂(3n+1)=1` and the first odd station splits by input
mod-8 channel. Bad runs without net descent target a 2-adic budget contradiction per channel.
-/

/--
`[A]` Every `mod 4 = 3` odd start splits into the two Klein input channels `3` and `7` mod `8`.
-/
theorem mod4_eq_three_implies_mod8_three_or_seven
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    n % 8 = 3 ∨ n % 8 = 7 := by
  omega

/--
`[A]` For `n ≡ 3 (mod 4)`: `3n+1 = 2(6k+5)`, hence `ν₂(3n+1) = 1` exactly.
Reuses the mod-8 table from `Nu2Bounds` / `SchalenDynamik`.
-/
theorem nu2_three_mul_add_one_eq_one_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    padicValNat 2 (3 * n + 1) = 1 := by
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · exact nu2_three_mul_add_one_eq_one_of_mod8_eq3 h3
  · exact nu2_three_mul_add_one_eq_one_of_mod8_eq7 h7

theorem eSchalenSprung_eq_one_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    eSchalenSprung n = 1 := by
  simpa [eSchalenSprung] using nu2_three_mul_add_one_eq_one_of_mod4_eq_three ho hmod

/--
`[A]` First Syracuse odd step from `mod 4 = 3`: `T_odd n = (3n+1)/2 = oddCoreStep n`.
-/
theorem T_odd_eq_oddCoreStep_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    T_odd n = oddCoreStep n := by
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · unfold T_odd
    exact (oddCoreStep_eq_div2_of_mod8_eq3 h3).symm
  · unfold T_odd
    exact (oddCoreStep_eq_div2_of_mod8_eq7 h7).symm

/--
`[A]` Input channel `n % 8 = 3`: next odd is `6k+5`, hence `≡ 1` or `≡ 5 (mod 8)`.
-/
theorem T_odd_mod8_one_or_five_of_mod8_eq_three
    {n : Nat} (hmod : n % 8 = 3) :
    T_odd n % 8 = 1 ∨ T_odd n % 8 = 5 := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three hmod with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_three]
  omega

/--
`[A]` Input channel `n % 8 = 7`: next odd lands in `{3, 7}` mod `8` (bad-run tail channel).
-/
theorem T_odd_mod8_three_or_seven_of_mod8_eq_seven
    {n : Nat} (hmod : n % 8 = 7) :
    T_odd n % 8 = 3 ∨ T_odd n % 8 = 7 := by
  rcases exists_eq_eight_mul_add_seven_of_mod8_eq_seven hmod with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_seven]
  omega

/--
`[A]` After one Syracuse step from `mod 4 = 3`, the next odd mod-8 class is channel-dependent.
-/
theorem first_syracuse_mod8_subcases_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    (n % 8 = 3 ∧ (T_odd n % 8 = 1 ∨ T_odd n % 8 = 5)) ∨
      (n % 8 = 7 ∧ (T_odd n % 8 = 3 ∨ T_odd n % 8 = 7)) := by
  rcases mod4_eq_three_implies_mod8_three_or_seven ho hmod with h3 | h7
  · exact Or.inl ⟨h3, T_odd_mod8_one_or_five_of_mod8_eq_three h3⟩
  · exact Or.inr ⟨h7, T_odd_mod8_three_or_seven_of_mod8_eq_seven h7⟩

/--
Mod-8 input channel for `n ≡ 3 (mod 4)` starts (Klein classes `{3,7}`).
-/
inductive Mod4ThreeInputChannel
  | ch3 : Mod4ThreeInputChannel
  | ch7 : Mod4ThreeInputChannel

def Mod4ThreeInputChannel.ofMod8
    (h8 : Nat → Prop) (h3 : h8 3) (h7 : h8 7) (n : Nat) (hn : h8 (n % 8)) :
    Mod4ThreeInputChannel :=
  if h : n % 8 = 3 then
    Mod4ThreeInputChannel.ch3
  else
    Mod4ThreeInputChannel.ch7

theorem Mod4ThreeInputChannel.ofMod8_eq_ch3
    {n : Nat} (h8 : n % 8 = 3) :
    Mod4ThreeInputChannel.ofMod8 (fun r => r = 3 ∨ r = 7) (Or.inl rfl) (Or.inr rfl) n
      (Or.inl h8) = Mod4ThreeInputChannel.ch3 := by
  unfold Mod4ThreeInputChannel.ofMod8
  simp [h8]

theorem Mod4ThreeInputChannel.ofMod8_eq_ch7
    {n : Nat} (h8 : n % 8 = 7) :
    Mod4ThreeInputChannel.ofMod8 (fun r => r = 3 ∨ r = 7) (Or.inl rfl) (Or.inr rfl) n
      (Or.inr h8) = Mod4ThreeInputChannel.ch7 := by
  unfold Mod4ThreeInputChannel.ofMod8
  have hnot : n % 8 ≠ 3 := by omega
  simp [hnot, h8]

/-!
### Channel `3` arithmetic (`n % 8 = 3`)

`T_odd n` is the minimal good-branch odd (`≡ 1 mod 4`) reachable in two `collatzStep`s.
The canonical three-step good-branch shrink value `(3·T_odd n+1)/4` still exceeds `n` by `k+1`
when `n = 8k+3`; net descent needs a longer `local_shrink_time`.
-/

/--
`[A]` Input channel `n % 8 = 3`: the first Syracuse odd strictly exceeds the start.
-/
theorem T_odd_gt_of_mod8_eq_three
    {n : Nat} (h8 : n % 8 = 3) :
    n < T_odd n := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three h8 with ⟨k, rfl⟩
  rw [T_odd_of_eight_mul_add_three]
  omega

/--
`[A]` Closed form for the canonical good-branch shrink value at `T_odd n`.
-/
theorem three_step_shrink_value_of_mod8_eq_three
    {n : Nat} (h8 : n % 8 = 3) :
    ∃ k, n = 8 * k + 3 ∧ (3 * T_odd n + 1) / 4 = 9 * k + 4 := by
  rcases exists_eq_eight_mul_add_three_of_mod8_eq_three h8 with ⟨k, rfl⟩
  refine ⟨k, rfl, ?_⟩
  rw [T_odd_of_eight_mul_add_three]
  omega

/--
`[A]` Canonical three-step good-branch shrink stays above the original start.
Gap: `(3·T_odd n+1)/4 - n = k+1` when `n = 8k+3`.
-/
theorem three_step_shrink_gt_start_of_mod8_eq_three
    {n : Nat} (h8 : n % 8 = 3) :
    n < (3 * T_odd n + 1) / 4 := by
  rcases three_step_shrink_value_of_mod8_eq_three h8 with ⟨k, rfl, hval⟩
  rw [hval]
  omega

/--
`[A]` Channel `3` always lands in the good `mod 4 = 1` branch after one `T_odd` step.
-/
theorem channel_three_T_odd_mod4_eq_one
    {n : Nat} (h8 : n % 8 = 3) :
    T_odd n % 4 = 1 :=
  T_odd_mod4_eq_one_of_mod8_eq_three h8

/-!
### Channel `3` parity split (`T_odd n % 8 ∈ {1, 5}`)

For `n = 8k+3`, the next odd lands in `mod 8 = 5` iff `k` is even, and in `mod 8 = 1` iff `k` is odd.
V2.8 closes the even-`k` / `mod 8 = 5` subcase at `t_loc = 4`.
-/

/--
`[A]` Parity split: `T_odd(8k+3) % 8 = 5` exactly when `k` is even.
-/
theorem T_odd_mod8_eq_five_iff_k_even_of_mod8_eq_three
    {n k : Nat} (hk : n = 8 * k + 3) :
    T_odd n % 8 = 5 ↔ k % 2 = 0 := by
  rw [hk, T_odd_of_eight_mul_add_three]
  constructor
  · intro h
    omega
  · intro h
    omega

/--
`[A]` Parity split: `T_odd(8k+3) % 8 = 1` exactly when `k` is odd.
-/
theorem T_odd_mod8_eq_one_iff_k_odd_of_mod8_eq_three
    {n k : Nat} (hk : n = 8 * k + 3) :
    T_odd n % 8 = 1 ↔ k % 2 = 1 := by
  rw [hk, T_odd_of_eight_mul_add_three]
  constructor
  · intro h
    omega
  · intro h
    omega

/--
`[A]` Even `k = 2j` reparametrisation for channel `3` inputs.
-/
theorem exists_eq_sixteen_mul_add_three_of_mod8_eq_three_and_k_even
    {n k : Nat} (h8 : n % 8 = 3) (hk : n = 8 * k + 3) (heven : k % 2 = 0) :
    ∃ j, n = 16 * j + 3 ∧ k = 2 * j := by
  refine ⟨k / 2, ?_, ?_⟩
  · have : 8 * k + 3 = 16 * (k / 2) + 3 := by omega
    simpa [hk] using this
  · omega

private theorem collatz_step_odd {m : Nat} (ho : m % 2 = 1) :
    collatzStep m = 3 * m + 1 := by
  simp [collatzStep, show m % 2 ≠ 0 from by omega]

private theorem collatz_step_even {m : Nat} (he : m % 2 = 0) :
    collatzStep m = m / 2 := by
  simp [collatzStep, he]

/--
`[A]` From an odd `mod 8 = 5` input, four `collatzStep`s equal `(3m+1)/8`.
Uses `ν₂(3m+1) ≥ 3` and three forced halvings after the odd kick.
-/
theorem collatz_four_steps_mod8_five_eq_three_mul_add_one_div8
    {m : Nat} (ho : m % 2 = 1) (h5 : m % 8 = 5) :
    (collatzStep^[4]) m = (3 * m + 1) / 8 := by
  have _he3 : 3 ≤ padicValNat 2 (3 * m + 1) :=
    nu2_three_mul_add_one_ge_three_of_mod8_eq5 h5
  have he1 : (3 * m + 1) % 2 = 0 := by omega
  have he2 : ((3 * m + 1) / 2) % 2 = 0 := by omega
  have he3' : ((3 * m + 1) / 4) % 2 = 0 := by omega
  have hdiv2 : (3 * m + 1) / 2 / 2 = (3 * m + 1) / 4 := by omega
  have hdiv4 : (3 * m + 1) / 4 / 2 = (3 * m + 1) / 8 := by omega
  calc
    (collatzStep^[4]) m
        = (collatzStep^[3]) (collatzStep m) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[3]) (3 * m + 1) := by rw [collatz_step_odd ho]
    _ = (collatzStep^[2]) ((3 * m + 1) / 2) := by
          simp [Function.iterate_succ_apply', collatz_step_even he1]
    _ = (collatzStep^[1]) ((3 * m + 1) / 4) := by
          simp [Function.iterate_succ_apply', collatz_step_even he2, hdiv2]
    _ = (3 * m + 1) / 8 := by
          simp [Function.iterate_succ_apply', collatz_step_even he3', hdiv4]

/--
`[A]` Four-step value at `T_odd(16j+3) = 24j+5` is exactly `9j+2`.
-/
theorem channel_three_four_step_value_of_sixteen_mul_add_three (j : Nat) :
    (collatzStep^[4]) (T_odd (16 * j + 3)) = 9 * j + 2 := by
  have hform : 16 * j + 3 = 8 * (2 * j) + 3 := by ring
  have hm : T_odd (16 * j + 3) = 24 * j + 5 := by
    calc
      T_odd (16 * j + 3) = T_odd (8 * (2 * j) + 3) := by rw [hform]
      _ = 12 * (2 * j) + 5 := T_odd_of_eight_mul_add_three (k := 2 * j)
      _ = 24 * j + 5 := by ring
  have ho : (24 * j + 5) % 2 = 1 := by omega
  have h5 : (24 * j + 5) % 8 = 5 := by omega
  rw [hm, collatz_four_steps_mod8_five_eq_three_mul_add_one_div8 ho h5]
  have : 3 * (24 * j + 5) + 1 = 72 * j + 16 := by ring
  rw [this]
  omega

/--
`[A]` Channel-`3` even-`k` subcase: four steps from `T_odd n` descend strictly below `n`.
-/
theorem channel_three_collatz_net_descent_mod8_five_at_four
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3) (heven : ∃ k, n = 8 * k + 3 ∧ k % 2 = 0) :
    (collatzStep^[4]) (T_odd n) < n := by
  rcases heven with ⟨k, hk, hk_even⟩
  rcases exists_eq_sixteen_mul_add_three_of_mod8_eq_three_and_k_even h8 hk hk_even with ⟨j, hnj, _⟩
  rw [hnj, channel_three_four_step_value_of_sixteen_mul_add_three]
  rcases j with _ | j
  · norm_num
  · omega

/-!
### Channel `3` odd-`k` / `T_odd n % 8 = 1` branch

`ν₂(3m+1) = 2` at `m % 8 = 1`. Canonical three-step shrink lands at `9k+4`, still `k+1` above `n`.
Uniform `t_loc ≤ 5` is impossible for any odd `k`; uniform `t_loc = 6` works iff `k % 4 = 1`.
The subcase `k % 4 = 3` needs larger, `k`-dependent `t_loc` (e.g. `n = 27` ⇒ `t_loc = 94`).
-/

/--
`[A]` From an odd `mod 8 = 1` input, three `collatzStep`s equal `(3m+1)/4`.
Uses `ν₂(3m+1) = 2` and one forced halving after the odd kick.
-/
theorem collatz_three_steps_mod8_one_eq_three_mul_add_one_div4
    {m : Nat} (ho : m % 2 = 1) (h1 : m % 8 = 1) :
    (collatzStep^[3]) m = (3 * m + 1) / 4 := by
  have _he2 : padicValNat 2 (3 * m + 1) = 2 :=
    nu2_three_mul_add_one_eq_two_of_mod8_eq1 h1
  have he1 : (3 * m + 1) % 2 = 0 := by omega
  have he2 : ((3 * m + 1) / 2) % 2 = 0 := by omega
  have hdiv2 : (3 * m + 1) / 2 / 2 = (3 * m + 1) / 4 := by omega
  calc
    (collatzStep^[3]) m
        = (collatzStep^[2]) (collatzStep m) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[2]) (3 * m + 1) := by rw [collatz_step_odd ho]
    _ = (collatzStep^[1]) ((3 * m + 1) / 2) := by
          simp [Function.iterate_succ_apply', collatz_step_even he1]
    _ = (3 * m + 1) / 4 := by
          simp [Function.iterate_succ_apply', collatz_step_even he2, hdiv2]

/--
`[A]` Four `collatzStep`s from `mod 8 = 1` equal `3·((3m+1)/4)+1`.
-/
theorem collatz_four_steps_mod8_one_eq_three_mul_quarter_plus_one
    {m : Nat} (ho : m % 2 = 1) (h1 : m % 8 = 1) :
    (collatzStep^[4]) m = 3 * ((3 * m + 1) / 4) + 1 := by
  have hodd : ((3 * m + 1) / 4) % 2 = 1 := by omega
  calc
    (collatzStep^[4]) m
        = collatzStep ((collatzStep^[3]) m) := by simp [Function.iterate_succ_apply']
    _ = collatzStep ((3 * m + 1) / 4) := by
          rw [collatz_three_steps_mod8_one_eq_three_mul_add_one_div4 ho h1]
    _ = 3 * ((3 * m + 1) / 4) + 1 := collatz_step_odd hodd

/--
`[A]` Three-step value at `T_odd(8k+3)` with odd `k` is exactly `9k+4`.
-/
theorem channel_three_three_step_value_of_odd_k (k : Nat) (hk_odd : k % 2 = 1) :
    (collatzStep^[3]) (T_odd (8 * k + 3)) = 9 * k + 4 := by
  have hm : T_odd (8 * k + 3) = 12 * k + 5 := T_odd_of_eight_mul_add_three k
  have ho : (12 * k + 5) % 2 = 1 := by omega
  have h1 : (12 * k + 5) % 8 = 1 := by omega
  rw [hm, collatz_three_steps_mod8_one_eq_three_mul_add_one_div4 ho h1]
  have : 3 * (12 * k + 5) + 1 = 36 * k + 16 := by ring
  rw [this]
  omega

/--
`[A]` Four-step value at `T_odd(8k+3)` with odd `k` is exactly `27k+13`.
-/
theorem channel_three_four_step_value_of_odd_k (k : Nat) (hk_odd : k % 2 = 1) :
    (collatzStep^[4]) (T_odd (8 * k + 3)) = 27 * k + 13 := by
  have hm : T_odd (8 * k + 3) = 12 * k + 5 := T_odd_of_eight_mul_add_three k
  have ho : (12 * k + 5) % 2 = 1 := by omega
  have h1 : (12 * k + 5) % 8 = 1 := by omega
  have h3 : (collatzStep^[3]) (12 * k + 5) = 9 * k + 4 := by
    rw [← hm, channel_three_three_step_value_of_odd_k k hk_odd]
  have hodd : (9 * k + 4) % 2 = 1 := by omega
  rw [show (collatzStep^[4]) (T_odd (8 * k + 3)) =
        collatzStep ((collatzStep^[3]) (T_odd (8 * k + 3))) from by
        simp [Function.iterate_succ_apply']]
  rw [show (collatzStep^[3]) (T_odd (8 * k + 3)) = 9 * k + 4 from by simpa [hm] using h3]
  simp [collatz_step_odd hodd]
  ring_nf

/--
`[A]` Five-step value at `T_odd(8k+3)` with odd `k` is exactly `(27k+13)/2`.
-/
theorem channel_three_five_step_value_of_odd_k (k : Nat) (hk_odd : k % 2 = 1) :
    (collatzStep^[5]) (T_odd (8 * k + 3)) = (27 * k + 13) / 2 := by
  have h4 := channel_three_four_step_value_of_odd_k k hk_odd
  have he : (27 * k + 13) % 2 = 0 := by omega
  rw [show (collatzStep^[5]) (T_odd (8 * k + 3)) =
        collatzStep ((collatzStep^[4]) (T_odd (8 * k + 3))) from by
        simp [Function.iterate_succ_apply']]
  rw [h4, collatz_step_even he]

/--
`[A]` Odd `k` split: `k % 4 = 1` iff `n = 32j+11`.
-/
theorem exists_eq_thirty_two_mul_add_eleven_of_mod8_eq_three_and_k_mod4_one
    {n k : Nat} (hk : n = 8 * k + 3) (hk_one : k % 4 = 1) :
    ∃ j, n = 32 * j + 11 ∧ k = 4 * j + 1 := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 3 = 32 * (k / 4) + 11 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` Odd `k` split: `k % 4 = 3` iff `n = 32j+27`.
-/
theorem exists_eq_thirty_two_mul_add_twentyseven_of_mod8_eq_three_and_k_mod4_three
    {n k : Nat} (hk : n = 8 * k + 3) (hk_three : k % 4 = 3) :
    ∃ j, n = 32 * j + 27 ∧ k = 4 * j + 3 := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 3 = 32 * (k / 4) + 27 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` Six-step value at `T_odd(32j+11)` (`k = 4j+1`) is exactly `27j+10`.
-/
theorem channel_three_six_step_value_of_thirty_two_mul_add_eleven (j : Nat) :
    (collatzStep^[6]) (T_odd (32 * j + 11)) = 27 * j + 10 := by
  have hform : 32 * j + 11 = 8 * (4 * j + 1) + 3 := by ring
  have hk_odd : (4 * j + 1) % 2 = 1 := by omega
  have h5 := channel_three_five_step_value_of_odd_k (4 * j + 1) hk_odd
  have hval : (27 * (4 * j + 1) + 13) / 2 = 54 * j + 20 := by omega
  have he : (54 * j + 20) % 2 = 0 := by omega
  have hT : T_odd (32 * j + 11) = T_odd (8 * (4 * j + 1) + 3) := by rw [hform]
  rw [hT, Function.iterate_succ_apply', h5, hval, collatz_step_even he]
  omega

/--
`[A]` Six-step value at `T_odd(32j+27)` (`k = 4j+3`) is exactly `162j+142` — still above `n`.
-/
theorem channel_three_six_step_value_of_thirty_two_mul_add_twentyseven (j : Nat) :
    (collatzStep^[6]) (T_odd (32 * j + 27)) = 162 * j + 142 := by
  have hform : 32 * j + 27 = 8 * (4 * j + 3) + 3 := by ring
  have hk_odd : (4 * j + 3) % 2 = 1 := by omega
  have h5 := channel_three_five_step_value_of_odd_k (4 * j + 3) hk_odd
  have hval : (27 * (4 * j + 3) + 13) / 2 = 54 * j + 47 := by omega
  have hodd : (54 * j + 47) % 2 = 1 := by omega
  have hT : T_odd (32 * j + 27) = T_odd (8 * (4 * j + 3) + 3) := by rw [hform]
  rw [hT, Function.iterate_succ_apply', h5, hval, collatz_step_odd hodd]
  ring

/--
`[A]` Uniform `t_loc ≤ 5` barrier: five steps from `T_odd n` never descend below `n` when `k` is odd.
-/
theorem channel_three_uniform_five_step_fails_net_odd_k
    {k : Nat} (hk_odd : k % 2 = 1) (hk_pos : 0 < k) :
    (8 * k + 3) ≤ (collatzStep^[5]) (T_odd (8 * k + 3)) := by
  rw [channel_three_five_step_value_of_odd_k k hk_odd]
  omega

/--
`[A]` Uniform `t_loc = 6` barrier: at `k % 4 = 3` the six-step value still exceeds `n`.
-/
theorem channel_three_six_step_fails_net_k_mod4_three
    {j : Nat} :
    (32 * j + 27) ≤ (collatzStep^[6]) (T_odd (32 * j + 27)) := by
  rw [channel_three_six_step_value_of_thirty_two_mul_add_twentyseven]
  omega

/--
`[A]` Channel-`3` odd-`k` with `k % 4 = 1`: six steps from `T_odd n` descend strictly below `n`.
-/
theorem channel_three_collatz_net_descent_mod8_one_at_six_k_mod4_one
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3)
    (hk1 : ∃ j, n = 32 * j + 11) :
    (collatzStep^[6]) (T_odd n) < n := by
  rcases hk1 with ⟨j, hnj⟩
  rw [hnj, channel_three_six_step_value_of_thirty_two_mul_add_eleven]
  rcases j with _ | j
  · norm_num at hn ⊢
  · omega

/-!
### Channel `3` odd-`k` / `k % 4 = 3` — mod-128 refinement

Within `n = 32j+27` (`k = 4j+3`), uniform small `t_loc` fails (`≤ 6` barriers above).
Numerically `t_loc` is `j`-dependent; mod-128 subclass `n ≡ 59` (`j ≡ 1 mod 4`) closes at
uniform `t_loc = 9`. Remaining subclasses `n ≡ {27, 91, 123} (mod 128)` stay open.
-/

/--
`[A]` `k % 4 = 3` with `j % 4 = 1` iff `n = 128m + 59`.
-/
theorem exists_eq_one_hundred_twenty_eight_mul_add_fiftynine_of_mod8_eq_three_and_j_mod4_one
    {n j : Nat} (hj : n = 32 * j + 27) (hj_one : j % 4 = 1) :
    ∃ m, n = 128 * m + 59 ∧ j = 4 * m + 1 := by
  refine ⟨j / 4, ?_, ?_⟩
  · have : 32 * j + 27 = 128 * (j / 4) + 59 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` `k % 4 = 3` with `j % 4 = r` determines `n % 128` among `{27, 59, 91, 123}`.
-/
theorem mod128_residue_of_thirty_two_mul_add_twentyseven_j_mod4
    {j : Nat} :
    (j % 4 = 0 → (32 * j + 27) % 128 = 27) ∧
      (j % 4 = 1 → (32 * j + 27) % 128 = 59) ∧
        (j % 4 = 2 → (32 * j + 27) % 128 = 91) ∧
          (j % 4 = 3 → (32 * j + 27) % 128 = 123) := by
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  · intro h; omega

/--
`[A]` Six-step value at `T_odd(128m+59)` (`k = 16m+7`) is exactly `648m+304`.
-/
theorem channel_three_six_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine (m : Nat) :
    (collatzStep^[6]) (T_odd (128 * m + 59)) = 648 * m + 304 := by
  have hform : 128 * m + 59 = 8 * (16 * m + 7) + 3 := by ring
  have hk_odd : (16 * m + 7) % 2 = 1 := by omega
  have h5 := channel_three_five_step_value_of_odd_k (16 * m + 7) hk_odd
  have hval : (27 * (16 * m + 7) + 13) / 2 = 216 * m + 101 := by omega
  have hodd : (216 * m + 101) % 2 = 1 := by omega
  have hT : T_odd (128 * m + 59) = T_odd (8 * (16 * m + 7) + 3) := by rw [hform]
  rw [hT, Function.iterate_succ_apply', h5, hval, collatz_step_odd hodd]
  ring

/--
`[A]` Seven-step value at `T_odd(128m+59)` is exactly `324m+152`.
-/
theorem channel_three_seven_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine (m : Nat) :
    (collatzStep^[7]) (T_odd (128 * m + 59)) = 324 * m + 152 := by
  have h6 := channel_three_six_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine m
  have he : (648 * m + 304) % 2 = 0 := by omega
  rw [show (collatzStep^[7]) (T_odd (128 * m + 59)) =
        collatzStep ((collatzStep^[6]) (T_odd (128 * m + 59))) from by
        simp [Function.iterate_succ_apply']]
  rw [h6, collatz_step_even he]
  omega

/--
`[A]` Eight-step value at `T_odd(128m+59)` is exactly `162m+76` — still at or above `n`.
-/
theorem channel_three_eight_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine (m : Nat) :
    (collatzStep^[8]) (T_odd (128 * m + 59)) = 162 * m + 76 := by
  have h7 := channel_three_seven_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine m
  have he : (324 * m + 152) % 2 = 0 := by omega
  rw [show (collatzStep^[8]) (T_odd (128 * m + 59)) =
        collatzStep ((collatzStep^[7]) (T_odd (128 * m + 59))) from by
        simp [Function.iterate_succ_apply']]
  rw [h7, collatz_step_even he]
  omega

/--
`[A]` Nine-step value at `T_odd(128m+59)` is exactly `81m+38`.
-/
theorem channel_three_nine_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine (m : Nat) :
    (collatzStep^[9]) (T_odd (128 * m + 59)) = 81 * m + 38 := by
  have h8 := channel_three_eight_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine m
  have he : (162 * m + 76) % 2 = 0 := by omega
  rw [show (collatzStep^[9]) (T_odd (128 * m + 59)) =
        collatzStep ((collatzStep^[8]) (T_odd (128 * m + 59))) from by
        simp [Function.iterate_succ_apply']]
  rw [h8, collatz_step_even he]
  omega

/--
`[A]` Uniform `t_loc = 8` barrier on subclass `n ≡ 59 (mod 128)`: eight steps still do not beat `n`.
-/
theorem channel_three_eight_step_fails_net_mod128_fiftynine
    {m : Nat} :
    (128 * m + 59) ≤ (collatzStep^[8]) (T_odd (128 * m + 59)) := by
  rw [channel_three_eight_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine]
  omega

/--
`[A]` Channel-`3` subclass `n ≡ 59 (mod 128)` (`j ≡ 1 mod 4` within `k % 4 = 3`):
nine steps from `T_odd n` descend strictly below `n`.
-/
theorem channel_three_collatz_net_descent_mod128_fiftynine_at_nine
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3)
    (h59 : ∃ m, n = 128 * m + 59) :
    (collatzStep^[9]) (T_odd n) < n := by
  rcases h59 with ⟨m, hn⟩
  rw [hn, channel_three_nine_step_value_of_one_hundred_twenty_eight_mul_add_fiftynine]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

end CollatzNetDescentMod8
end CollatzAttemptV2

end KeplerHurwitz
