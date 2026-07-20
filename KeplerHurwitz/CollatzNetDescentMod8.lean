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

/-!
### Channel `3` odd-`k` / `k % 4 = 3` — mod-256 refinement

Within `n = 32j+27`, `j % 8` splits mod-128 classes into mod-256 subclasses.
Uniform `t_loc = 11` closes `j % 8 = 3` (`n ≡ 123 mod 256`) and `j % 8 = 6` (`n ≡ 219 mod 256`).
Remaining subclasses `{27, 91, 155, 251} mod 256` stay open.
-/

/--
`[A]` `j % 8 = 3` within `n = 32j+27` iff `n = 256m + 123`.
-/
theorem exists_eq_two_hundred_fifty_six_mul_add_one_hundred_twenty_three_of_j_mod8_three
    {n j : Nat} (hj : n = 32 * j + 27) (hj_three : j % 8 = 3) :
    ∃ m, n = 256 * m + 123 ∧ j = 8 * m + 3 := by
  refine ⟨j / 8, ?_, ?_⟩
  · have : 32 * j + 27 = 256 * (j / 8) + 123 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` `j % 8 = 6` within `n = 32j+27` iff `n = 256m + 219`.
-/
theorem exists_eq_two_hundred_fifty_six_mul_add_two_hundred_nineteen_of_j_mod8_six
    {n j : Nat} (hj : n = 32 * j + 27) (hj_six : j % 8 = 6) :
    ∃ m, n = 256 * m + 219 ∧ j = 8 * m + 6 := by
  refine ⟨j / 8, ?_, ?_⟩
  · have : 32 * j + 27 = 256 * (j / 8) + 219 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` `j % 8` determines `n % 256` among `{27, 59, 91, 123, 155, 219, 251}`.
-/
theorem mod256_residue_of_thirty_two_mul_add_twentyseven_j_mod8
    {j : Nat} :
    (j % 8 = 0 → (32 * j + 27) % 256 = 27) ∧
      (j % 8 = 1 → (32 * j + 27) % 256 = 59) ∧
        (j % 8 = 2 → (32 * j + 27) % 256 = 91) ∧
          (j % 8 = 3 → (32 * j + 27) % 256 = 123) ∧
            (j % 8 = 4 → (32 * j + 27) % 256 = 155) ∧
              (j % 8 = 5 → (32 * j + 27) % 256 = 187) ∧
                (j % 8 = 6 → (32 * j + 27) % 256 = 219) ∧
                  (j % 8 = 7 → (32 * j + 27) % 256 = 251) := by
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  · intro h; omega

/--
`[A]` Six-step value at `T_odd(256m+123)` (`j = 8m+3`) is exactly `1296m+628`.
-/
theorem channel_three_six_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[6]) (T_odd (256 * m + 123)) = 1296 * m + 628 := by
  have hj : 256 * m + 123 = 32 * (8 * m + 3) + 27 := by ring
  rw [hj, channel_three_six_step_value_of_thirty_two_mul_add_twentyseven (8 * m + 3)]
  ring

/--
`[A]` Seven-step value at `T_odd(256m+123)` is exactly `648m+314`.
-/
theorem channel_three_seven_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[7]) (T_odd (256 * m + 123)) = 648 * m + 314 := by
  have h6 := channel_three_six_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three m
  have he : (1296 * m + 628) % 2 = 0 := by omega
  rw [show (collatzStep^[7]) (T_odd (256 * m + 123)) =
        collatzStep ((collatzStep^[6]) (T_odd (256 * m + 123))) from by
        simp [Function.iterate_succ_apply']]
  rw [h6, collatz_step_even he]
  omega

/--
`[A]` Eight-step value at `T_odd(256m+123)` is exactly `324m+157`.
-/
theorem channel_three_eight_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[8]) (T_odd (256 * m + 123)) = 324 * m + 157 := by
  have h7 := channel_three_seven_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three m
  have he : (648 * m + 314) % 2 = 0 := by omega
  rw [show (collatzStep^[8]) (T_odd (256 * m + 123)) =
        collatzStep ((collatzStep^[7]) (T_odd (256 * m + 123))) from by
        simp [Function.iterate_succ_apply']]
  rw [h7, collatz_step_even he]
  omega

/--
`[A]` Nine-step value at `T_odd(256m+123)` is exactly `972m+472`.
-/
theorem channel_three_nine_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[9]) (T_odd (256 * m + 123)) = 972 * m + 472 := by
  have h8 := channel_three_eight_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three m
  have hodd : (324 * m + 157) % 2 = 1 := by omega
  rw [show (collatzStep^[9]) (T_odd (256 * m + 123)) =
        collatzStep ((collatzStep^[8]) (T_odd (256 * m + 123))) from by
        simp [Function.iterate_succ_apply']]
  rw [h8, collatz_step_odd hodd]
  ring

/--
`[A]` Ten-step value at `T_odd(256m+123)` is exactly `486m+236` — still at or above `n`.
-/
theorem channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[10]) (T_odd (256 * m + 123)) = 486 * m + 236 := by
  have h9 := channel_three_nine_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three m
  have he : (972 * m + 472) % 2 = 0 := by omega
  rw [show (collatzStep^[10]) (T_odd (256 * m + 123)) =
        collatzStep ((collatzStep^[9]) (T_odd (256 * m + 123))) from by
        simp [Function.iterate_succ_apply']]
  rw [h9, collatz_step_even he]
  omega

/--
`[A]` Eleven-step value at `T_odd(256m+123)` is exactly `243m+118`.
-/
theorem channel_three_eleven_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three
    (m : Nat) :
    (collatzStep^[11]) (T_odd (256 * m + 123)) = 243 * m + 118 := by
  have h10 := channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three m
  have he : (486 * m + 236) % 2 = 0 := by omega
  rw [show (collatzStep^[11]) (T_odd (256 * m + 123)) =
        collatzStep ((collatzStep^[10]) (T_odd (256 * m + 123))) from by
        simp [Function.iterate_succ_apply']]
  rw [h10, collatz_step_even he]
  omega

/--
`[A]` Uniform `t_loc = 10` barrier on subclass `n ≡ 123 (mod 256)`.
-/
theorem channel_three_ten_step_fails_net_mod256_one_hundred_twenty_three
    {m : Nat} :
    (256 * m + 123) ≤ (collatzStep^[10]) (T_odd (256 * m + 123)) := by
  rw [channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three]
  omega

/--
`[A]` Channel-`3` subclass `n ≡ 123 (mod 256)` (`j % 8 = 3`): eleven steps descend below `n`.
-/
theorem channel_three_collatz_net_descent_mod256_one_hundred_twenty_three_at_eleven
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3)
    (h123 : ∃ m, n = 256 * m + 123) :
    (collatzStep^[11]) (T_odd n) < n := by
  rcases h123 with ⟨m, hn⟩
  rw [hn, channel_three_eleven_step_value_of_two_hundred_fifty_six_mul_add_one_hundred_twenty_three]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/--
`[A]` Six-step value at `T_odd(256m+219)` (`j = 8m+6`) is exactly `1296m+1114`.
-/
theorem channel_three_six_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[6]) (T_odd (256 * m + 219)) = 1296 * m + 1114 := by
  have hj : 256 * m + 219 = 32 * (8 * m + 6) + 27 := by ring
  rw [hj, channel_three_six_step_value_of_thirty_two_mul_add_twentyseven (8 * m + 6)]
  ring

/--
`[A]` Seven-step value at `T_odd(256m+219)` is exactly `648m+557`.
-/
theorem channel_three_seven_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[7]) (T_odd (256 * m + 219)) = 648 * m + 557 := by
  have h6 := channel_three_six_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen m
  have he : (1296 * m + 1114) % 2 = 0 := by omega
  rw [show (collatzStep^[7]) (T_odd (256 * m + 219)) =
        collatzStep ((collatzStep^[6]) (T_odd (256 * m + 219))) from by
        simp [Function.iterate_succ_apply']]
  rw [h6, collatz_step_even he]
  omega

/--
`[A]` Eight-step value at `T_odd(256m+219)` is exactly `1944m+1672`.
-/
theorem channel_three_eight_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[8]) (T_odd (256 * m + 219)) = 1944 * m + 1672 := by
  have h7 := channel_three_seven_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen m
  have hodd : (648 * m + 557) % 2 = 1 := by omega
  rw [show (collatzStep^[8]) (T_odd (256 * m + 219)) =
        collatzStep ((collatzStep^[7]) (T_odd (256 * m + 219))) from by
        simp [Function.iterate_succ_apply']]
  rw [h7, collatz_step_odd hodd]
  ring

/--
`[A]` Nine-step value at `T_odd(256m+219)` is exactly `972m+836`.
-/
theorem channel_three_nine_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[9]) (T_odd (256 * m + 219)) = 972 * m + 836 := by
  have h8 := channel_three_eight_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen m
  have he : (1944 * m + 1672) % 2 = 0 := by omega
  rw [show (collatzStep^[9]) (T_odd (256 * m + 219)) =
        collatzStep ((collatzStep^[8]) (T_odd (256 * m + 219))) from by
        simp [Function.iterate_succ_apply']]
  rw [h8, collatz_step_even he]
  omega

/--
`[A]` Ten-step value at `T_odd(256m+219)` is exactly `486m+418` — still at or above `n`.
-/
theorem channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[10]) (T_odd (256 * m + 219)) = 486 * m + 418 := by
  have h9 := channel_three_nine_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen m
  have he : (972 * m + 836) % 2 = 0 := by omega
  rw [show (collatzStep^[10]) (T_odd (256 * m + 219)) =
        collatzStep ((collatzStep^[9]) (T_odd (256 * m + 219))) from by
        simp [Function.iterate_succ_apply']]
  rw [h9, collatz_step_even he]
  omega

/--
`[A]` Eleven-step value at `T_odd(256m+219)` is exactly `243m+209`.
-/
theorem channel_three_eleven_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen
    (m : Nat) :
    (collatzStep^[11]) (T_odd (256 * m + 219)) = 243 * m + 209 := by
  have h10 := channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen m
  have he : (486 * m + 418) % 2 = 0 := by omega
  rw [show (collatzStep^[11]) (T_odd (256 * m + 219)) =
        collatzStep ((collatzStep^[10]) (T_odd (256 * m + 219))) from by
        simp [Function.iterate_succ_apply']]
  rw [h10, collatz_step_even he]
  omega

/--
`[A]` Uniform `t_loc = 10` barrier on subclass `n ≡ 219 (mod 256)`.
-/
theorem channel_three_ten_step_fails_net_mod256_two_hundred_nineteen
    {m : Nat} :
    (256 * m + 219) ≤ (collatzStep^[10]) (T_odd (256 * m + 219)) := by
  rw [channel_three_ten_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen]
  omega

/--
`[A]` Channel-`3` subclass `n ≡ 219 (mod 256)` (`j % 8 = 6`): eleven steps descend below `n`.
-/
theorem channel_three_collatz_net_descent_mod256_two_hundred_nineteen_at_eleven
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3)
    (h219 : ∃ m, n = 256 * m + 219) :
    (collatzStep^[11]) (T_odd n) < n := by
  rcases h219 with ⟨m, hn⟩
  rw [hn, channel_three_eleven_step_value_of_two_hundred_fifty_six_mul_add_two_hundred_nineteen]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` arithmetic (`n % 8 = 7`)

`T_odd n % 8 = 3` when `k` is even, `7` when `k` is odd. The subcase `k % 4 = 2`
(`n = 32j+23`) closes at uniform `t_loc = 6`; other `k % 4` classes remain open.
-/

/--
`[A]` Parity split: `T_odd(8k+7) % 8 = 3` exactly when `k` is even.
-/
theorem T_odd_mod8_eq_three_iff_k_even_of_mod8_eq_seven
    {n k : Nat} (hk : n = 8 * k + 7) :
    T_odd n % 8 = 3 ↔ k % 2 = 0 := by
  rw [hk, T_odd_of_eight_mul_add_seven]
  constructor
  · intro h
    omega
  · intro h
    omega

/--
`[A]` Parity split: `T_odd(8k+7) % 8 = 7` exactly when `k` is odd.
-/
theorem T_odd_mod8_eq_seven_iff_k_odd_of_mod8_eq_seven
    {n k : Nat} (hk : n = 8 * k + 7) :
    T_odd n % 8 = 7 ↔ k % 2 = 1 := by
  rw [hk, T_odd_of_eight_mul_add_seven]
  constructor
  · intro h
    omega
  · intro h
    omega

/--
`[A]` `k % 4 = 2` within channel `7` iff `n = 32j + 23`.
-/
theorem exists_eq_thirty_two_mul_add_twenty_three_of_mod8_eq_seven_and_k_mod4_two
    {n k : Nat} (hk : n = 8 * k + 7) (hk_two : k % 4 = 2) :
    ∃ j, n = 32 * j + 23 ∧ k = 4 * j + 2 := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 7 = 32 * (k / 4) + 23 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` Two-step value at `T_odd(32j+23)` (`k = 4j+2`) is exactly `72j+53`.
-/
theorem channel_seven_two_step_value_of_thirty_two_mul_add_twenty_three (j : Nat) :
    (collatzStep^[2]) (T_odd (32 * j + 23)) = 72 * j + 53 := by
  have hform : 32 * j + 23 = 8 * (4 * j + 2) + 7 := by ring
  have hm : T_odd (32 * j + 23) = 48 * j + 35 := by
    calc
      T_odd (32 * j + 23) = T_odd (8 * (4 * j + 2) + 7) := by rw [hform]
      _ = 12 * (4 * j + 2) + 11 := T_odd_of_eight_mul_add_seven (4 * j + 2)
      _ = 48 * j + 35 := by ring
  have ho : (48 * j + 35) % 2 = 1 := by omega
  have he1 : (3 * (48 * j + 35) + 1) % 2 = 0 := by omega
  calc
    (collatzStep^[2]) (T_odd (32 * j + 23))
        = (collatzStep^[2]) (48 * j + 35) := by rw [hm]
    _ = collatzStep (collatzStep (48 * j + 35)) := by simp [Function.iterate_succ_apply']
    _ = collatzStep (3 * (48 * j + 35) + 1) := by rw [collatz_step_odd ho]
    _ = (3 * (48 * j + 35) + 1) / 2 := by rw [collatz_step_even he1]
    _ = 72 * j + 53 := by omega

/--
`[A]` Four-step shrink from `m = 72j+53` (`mod 8 = 5`) is exactly `27j+20`.
-/
theorem channel_seven_four_step_shrink_value_of_seventy_two_mul_add_fiftythree (j : Nat) :
    (collatzStep^[4]) (72 * j + 53) = 27 * j + 20 := by
  have ho : (72 * j + 53) % 2 = 1 := by omega
  have h5 : (72 * j + 53) % 8 = 5 := by omega
  calc
    (collatzStep^[4]) (72 * j + 53)
        = (3 * (72 * j + 53) + 1) / 8 :=
          collatz_four_steps_mod8_five_eq_three_mul_add_one_div8 ho h5
    _ = 27 * j + 20 := by omega

/--
`[A]` Six-step value at `T_odd(32j+23)` is exactly `27j+20`.
-/
theorem channel_seven_six_step_value_of_thirty_two_mul_add_twenty_three (j : Nat) :
    (collatzStep^[6]) (T_odd (32 * j + 23)) = 27 * j + 20 := by
  have h2 := channel_seven_two_step_value_of_thirty_two_mul_add_twenty_three j
  have h4 := channel_seven_four_step_shrink_value_of_seventy_two_mul_add_fiftythree j
  calc
    (collatzStep^[6]) (T_odd (32 * j + 23))
        = (collatzStep^[4]) ((collatzStep^[2]) (T_odd (32 * j + 23))) := by
            rw [Function.iterate_add_apply collatzStep 4 2 (T_odd (32 * j + 23))]
    _ = (collatzStep^[4]) (72 * j + 53) := by rw [h2]
    _ = 27 * j + 20 := h4

/--
`[A]` Three-step value from `m = 72j+53` is exactly `54j+40`.
-/
theorem channel_seven_three_step_value_of_seventy_two_mul_add_fiftythree (j : Nat) :
    (collatzStep^[3]) (72 * j + 53) = 54 * j + 40 := by
  have ho : (72 * j + 53) % 2 = 1 := by omega
  have he160 : (216 * j + 160) % 2 = 0 := by omega
  have he80 : (108 * j + 80) % 2 = 0 := by omega
  have hval : 3 * (72 * j + 53) + 1 = 216 * j + 160 := by ring
  calc
    (collatzStep^[3]) (72 * j + 53)
        = collatzStep (collatzStep (collatzStep (72 * j + 53))) := by
            simp [Function.iterate_succ_apply']
    _ = collatzStep (collatzStep (216 * j + 160)) := by
          rw [collatz_step_odd ho, hval]
    _ = collatzStep (108 * j + 80) := by
          rw [collatz_step_even he160]; congr 1; omega
    _ = 54 * j + 40 := by rw [collatz_step_even he80]; omega

/--
`[A]` Uniform `t_loc = 5` barrier on channel `7` with `k % 4 = 2`.
-/
theorem channel_seven_five_step_fails_net_k_mod4_two
    {j : Nat} :
    (32 * j + 23) ≤ (collatzStep^[5]) (T_odd (32 * j + 23)) := by
  have h2 := channel_seven_two_step_value_of_thirty_two_mul_add_twenty_three j
  have h3 := channel_seven_three_step_value_of_seventy_two_mul_add_fiftythree j
  calc
    (collatzStep^[5]) (T_odd (32 * j + 23))
        = (collatzStep^[3]) ((collatzStep^[2]) (T_odd (32 * j + 23))) := by
            rw [Function.iterate_add_apply collatzStep 3 2 (T_odd (32 * j + 23))]
    _ = (collatzStep^[3]) (72 * j + 53) := by rw [h2]
    _ = 54 * j + 40 := h3
    _ ≥ 32 * j + 23 := by omega

/--
`[A]` Four-step value from `n = 32j+23` is exactly `72j+53` (first `mod 4 = 1` state).
-/
theorem channel_seven_four_step_value_of_thirty_two_mul_add_twenty_three (j : Nat) :
    (collatzStep^[4]) (32 * j + 23) = 72 * j + 53 := by
  have hm : T_odd (32 * j + 23) = 48 * j + 35 := by
    have hform : 32 * j + 23 = 8 * (4 * j + 2) + 7 := by ring
    calc
      T_odd (32 * j + 23) = T_odd (8 * (4 * j + 2) + 7) := by rw [hform]
      _ = 12 * (4 * j + 2) + 11 := T_odd_of_eight_mul_add_seven (4 * j + 2)
      _ = 48 * j + 35 := by ring
  have ho : (32 * j + 23) % 2 = 1 := by omega
  have he1 : (96 * j + 70) % 2 = 0 := by omega
  have h2 := channel_seven_two_step_value_of_thirty_two_mul_add_twenty_three j
  calc
    (collatzStep^[4]) (32 * j + 23)
        = (collatzStep^[2]) ((collatzStep^[2]) (32 * j + 23)) := by
            rw [Function.iterate_add_apply collatzStep 2 2 (32 * j + 23)]
    _ = (collatzStep^[2]) (T_odd (32 * j + 23)) := by
          congr 1
          calc
            (collatzStep^[2]) (32 * j + 23)
                = collatzStep (collatzStep (32 * j + 23)) := by
                    simp [Function.iterate_succ_apply']
            _ = collatzStep (3 * (32 * j + 23) + 1) := by rw [collatz_step_odd ho]
            _ = collatzStep (96 * j + 70) := by congr 1; ring
            _ = 48 * j + 35 := by rw [collatz_step_even he1]; omega
            _ = T_odd (32 * j + 23) := hm.symm
    _ = 72 * j + 53 := h2

/--
`[A]` Good-branch state at four steps from `n = 32j+23` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_thirty_two_mul_add_twenty_three
    (j : Nat) :
    (72 * j + 53) % 4 = 1 := by omega

/--
`[A]` Uniform `t_loc = 3` barrier from good branch on channel `7` with `k % 4 = 2`.
-/
theorem channel_seven_three_step_shrink_fails_net_k_mod4_two
    {j : Nat} :
    (32 * j + 23) ≤ (collatzStep^[3]) (72 * j + 53) := by
  rw [channel_seven_three_step_value_of_seventy_two_mul_add_fiftythree]
  omega

/--
`[A]` Channel `7` with `k % 4 = 2`: four steps from good branch descend below `n`.
-/
theorem channel_seven_net_descent_from_good_at_four_k_mod4_two
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    ∃ j, n = 32 * j + 23 ∧
      (collatzStep^[4]) (72 * j + 53) < n := by
  rcases hk2 with ⟨j, hnj⟩
  refine ⟨j, hnj, ?_⟩
  rw [channel_seven_four_step_shrink_value_of_seventy_two_mul_add_fiftythree]
  rcases j with _ | j
  · rw [hnj]; norm_num at hn ⊢
  · omega

/--
`[A]` Channel `7` with `k % 4 = 2`: six steps from `T_odd n` descend strictly below `n`.
-/
theorem channel_seven_collatz_net_descent_mod8_three_at_six_k_mod4_two
    {n : Nat} (hn : 1 < n) (h7 : n % 8 = 7)
    (hk2 : ∃ j, n = 32 * j + 23) :
    (collatzStep^[6]) (T_odd n) < n := by
  rcases hk2 with ⟨j, hnj⟩
  rw [hnj, channel_seven_six_step_value_of_thirty_two_mul_add_twenty_three]
  rcases j with _ | j
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` — `k % 4 = 0` / `k % 4 = 1` mod-128 lifts

Within `n = 32j+7` (`k = 4j`), uniform `t_good = 4` and `m_good = 72j+17`.
Subclass `j % 4 = 0` (`n ≡ 7 mod 128`) closes at uniform `t_loc = 7`.

Within `n = 32j+15` (`k = 4j+1`), uniform `t_good = 6` and `m_good = 108j+53`.
Subclass `j % 4 = 0` (`n ≡ 15 mod 128`) closes at uniform `t_loc = 5`.
-/

/--
`[A]` `k % 4 = 0` within channel `7` iff `n = 32j + 7`.
-/
theorem exists_eq_thirty_two_mul_add_seven_of_mod8_eq_seven_and_k_mod4_zero
    {n k : Nat} (hk : n = 8 * k + 7) (hk_zero : k % 4 = 0) :
    ∃ j, n = 32 * j + 7 ∧ k = 4 * j := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 7 = 32 * (k / 4) + 7 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` `k % 4 = 1` within channel `7` iff `n = 32j + 15`.
-/
theorem exists_eq_thirty_two_mul_add_fifteen_of_mod8_eq_seven_and_k_mod4_one
    {n k : Nat} (hk : n = 8 * k + 7) (hk_one : k % 4 = 1) :
    ∃ j, n = 32 * j + 15 ∧ k = 4 * j + 1 := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 7 = 32 * (k / 4) + 15 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` `j % 4 = 0` within `n = 32j+7` iff `n = 128m + 7`.
-/
theorem exists_eq_one_hundred_twenty_eight_mul_add_seven_of_thirty_two_mul_add_seven_j_mod4_zero
    {n j : Nat} (hj : n = 32 * j + 7) (hj_zero : j % 4 = 0) :
    ∃ m, n = 128 * m + 7 ∧ j = 4 * m := by
  refine ⟨j / 4, ?_, ?_⟩
  · have : 32 * j + 7 = 128 * (j / 4) + 7 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` `j % 4 = 0` within `n = 32j+15` iff `n = 128m + 15`.
-/
theorem exists_eq_one_hundred_twenty_eight_mul_add_fifteen_of_thirty_two_mul_add_fifteen_j_mod4_zero
    {n j : Nat} (hj : n = 32 * j + 15) (hj_zero : j % 4 = 0) :
    ∃ m, n = 128 * m + 15 ∧ j = 4 * m := by
  refine ⟨j / 4, ?_, ?_⟩
  · have : 32 * j + 15 = 128 * (j / 4) + 15 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` Four-step value at `n = 32j+7` (`k = 4j`) is exactly `72j+17`.
-/
theorem channel_seven_four_step_value_of_thirty_two_mul_add_seven (j : Nat) :
    (collatzStep^[4]) (32 * j + 7) = 72 * j + 17 := by
  have hform : 32 * j + 7 = 8 * (4 * j) + 7 := by ring
  have hm : T_odd (32 * j + 7) = 48 * j + 11 := by
    calc
      T_odd (32 * j + 7) = T_odd (8 * (4 * j) + 7) := by rw [hform]
      _ = 12 * (4 * j) + 11 := T_odd_of_eight_mul_add_seven (4 * j)
      _ = 48 * j + 11 := by ring
  have ho : (32 * j + 7) % 2 = 1 := by omega
  have he1 : (96 * j + 22) % 2 = 0 := by omega
  have hoT : (48 * j + 11) % 2 = 1 := by omega
  have he2 : (144 * j + 34) % 2 = 0 := by omega
  calc
    (collatzStep^[4]) (32 * j + 7)
        = (collatzStep^[2]) ((collatzStep^[2]) (32 * j + 7)) := by
            rw [Function.iterate_add_apply collatzStep 2 2 (32 * j + 7)]
    _ = (collatzStep^[2]) (T_odd (32 * j + 7)) := by
          congr 1
          calc
            (collatzStep^[2]) (32 * j + 7)
                = collatzStep (collatzStep (32 * j + 7)) := by
                    simp [Function.iterate_succ_apply']
            _ = collatzStep (3 * (32 * j + 7) + 1) := by rw [collatz_step_odd ho]
            _ = collatzStep (96 * j + 22) := by congr 1; ring
            _ = 48 * j + 11 := by rw [collatz_step_even he1]; omega
            _ = T_odd (32 * j + 7) := hm.symm
    _ = (collatzStep^[2]) (48 * j + 11) := by rw [hm]
    _ = collatzStep (collatzStep (48 * j + 11)) := by simp [Function.iterate_succ_apply']
    _ = collatzStep (144 * j + 34) := by rw [collatz_step_odd hoT]; congr 1; ring
    _ = 72 * j + 17 := by rw [collatz_step_even he2]; omega

/--
`[A]` Good-branch state at four steps from `n = 32j+7` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_thirty_two_mul_add_seven
    (j : Nat) :
    (72 * j + 17) % 4 = 1 := by omega

/--
`[A]` Six-step value at `n = 32j+15` (`k = 4j+1`) is exactly `108j+53`.
-/
theorem channel_seven_six_step_value_of_thirty_two_mul_add_fifteen (j : Nat) :
    (collatzStep^[6]) (32 * j + 15) = 108 * j + 53 := by
  have hform : 32 * j + 15 = 8 * (4 * j + 1) + 7 := by ring
  have hm : T_odd (32 * j + 15) = 48 * j + 23 := by
    calc
      T_odd (32 * j + 15) = T_odd (8 * (4 * j + 1) + 7) := by rw [hform]
      _ = 12 * (4 * j + 1) + 11 := T_odd_of_eight_mul_add_seven (4 * j + 1)
      _ = 48 * j + 23 := by ring
  have ho : (32 * j + 15) % 2 = 1 := by omega
  have he1 : (96 * j + 46) % 2 = 0 := by omega
  have hoT : (48 * j + 23) % 2 = 1 := by omega
  have he2 : (144 * j + 70) % 2 = 0 := by omega
  have ho3 : (72 * j + 35) % 2 = 1 := by omega
  have he4 : (216 * j + 106) % 2 = 0 := by omega
  have hT2 :
      (collatzStep^[2]) (48 * j + 23) = 72 * j + 35 := by
    calc
      (collatzStep^[2]) (48 * j + 23)
          = collatzStep (collatzStep (48 * j + 23)) := by simp [Function.iterate_succ_apply']
      _ = collatzStep (144 * j + 70) := by rw [collatz_step_odd hoT]; congr 1; ring
      _ = 72 * j + 35 := by rw [collatz_step_even he2]; omega
  calc
    (collatzStep^[6]) (32 * j + 15)
        = (collatzStep^[4]) ((collatzStep^[2]) (32 * j + 15)) := by
            rw [Function.iterate_add_apply collatzStep 4 2 (32 * j + 15)]
    _ = (collatzStep^[4]) (T_odd (32 * j + 15)) := by
          congr 1
          calc
            (collatzStep^[2]) (32 * j + 15)
                = collatzStep (collatzStep (32 * j + 15)) := by
                    simp [Function.iterate_succ_apply']
            _ = collatzStep (3 * (32 * j + 15) + 1) := by rw [collatz_step_odd ho]
            _ = collatzStep (96 * j + 46) := by congr 1; ring
            _ = 48 * j + 23 := by rw [collatz_step_even he1]; omega
            _ = T_odd (32 * j + 15) := hm.symm
    _ = (collatzStep^[4]) (48 * j + 23) := by rw [hm]
    _ = (collatzStep^[2]) ((collatzStep^[2]) (48 * j + 23)) := by
          rw [Function.iterate_add_apply collatzStep 2 2 (48 * j + 23)]
    _ = (collatzStep^[2]) (72 * j + 35) := by rw [hT2]
    _ = collatzStep (collatzStep (72 * j + 35)) := by simp [Function.iterate_succ_apply']
    _ = collatzStep (216 * j + 106) := by rw [collatz_step_odd ho3]; congr 1; ring
    _ = 108 * j + 53 := by rw [collatz_step_even he4]; omega

/--
`[A]` Good-branch state at six steps from `n = 32j+15` lands in `mod 4 = 1`.
-/
theorem channel_seven_six_step_good_mod4_one_of_thirty_two_mul_add_fifteen
    (j : Nat) :
    (108 * j + 53) % 4 = 1 := by omega

/--
`[A]` Four-step value at `n = 128m+7` (`n ≡ 7 mod 128`) is exactly `288m+17`.
-/
theorem channel_seven_four_step_value_of_one_hundred_twenty_eight_mul_add_seven
    (m : Nat) :
    (collatzStep^[4]) (128 * m + 7) = 288 * m + 17 := by
  have hreparam : 128 * m + 7 = 32 * (4 * m) + 7 := by ring
  calc
    (collatzStep^[4]) (128 * m + 7)
        = (collatzStep^[4]) (32 * (4 * m) + 7) := by rw [hreparam]
    _ = 72 * (4 * m) + 17 := channel_seven_four_step_value_of_thirty_two_mul_add_seven (4 * m)
    _ = 288 * m + 17 := by ring

/--
`[A]` Six-step value at `n = 128m+15` (`n ≡ 15 mod 128`) is exactly `432m+53`.
-/
theorem channel_seven_six_step_value_of_one_hundred_twenty_eight_mul_add_fifteen
    (m : Nat) :
    (collatzStep^[6]) (128 * m + 15) = 432 * m + 53 := by
  have hreparam : 128 * m + 15 = 32 * (4 * m) + 15 := by ring
  calc
    (collatzStep^[6]) (128 * m + 15)
        = (collatzStep^[6]) (32 * (4 * m) + 15) := by rw [hreparam]
    _ = 108 * (4 * m) + 53 := channel_seven_six_step_value_of_thirty_two_mul_add_fifteen (4 * m)
    _ = 432 * m + 53 := by ring

/--
`[A]` Good-branch state at four steps from `n = 128m+7` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_one_hundred_twenty_eight_mul_add_seven
    (m : Nat) :
    (288 * m + 17) % 4 = 1 := by omega

/--
`[A]` Good-branch state at six steps from `n = 128m+15` lands in `mod 4 = 1`.
-/
theorem channel_seven_six_step_good_mod4_one_of_one_hundred_twenty_eight_mul_add_fifteen
    (m : Nat) :
    (432 * m + 53) % 4 = 1 := by omega

/--
`[A]` Seven-step shrink from `m = 288m₀+17` (`n ≡ 7 mod 128`) is exactly `81m₀+5`.
-/
theorem channel_seven_seven_step_shrink_value_of_two_hundred_eighty_eight_mul_add_seventeen
    (m : Nat) :
    (collatzStep^[7]) (288 * m + 17) = 81 * m + 5 := by
  have ho0 : (288 * m + 17) % 2 = 1 := by omega
  have hs1 : collatzStep (288 * m + 17) = 864 * m + 52 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (864 * m + 52) % 2 = 0 := by omega
  have hs2 : collatzStep (864 * m + 52) = 432 * m + 26 := by
    rw [collatz_step_even he1]; omega
  have he2 : (432 * m + 26) % 2 = 0 := by omega
  have hs3 : collatzStep (432 * m + 26) = 216 * m + 13 := by
    rw [collatz_step_even he2]; omega
  have ho3 : (216 * m + 13) % 2 = 1 := by omega
  have hs4 : collatzStep (216 * m + 13) = 648 * m + 40 := by
    rw [collatz_step_odd ho3]; ring
  have he4 : (648 * m + 40) % 2 = 0 := by omega
  have hs5 : collatzStep (648 * m + 40) = 324 * m + 20 := by
    rw [collatz_step_even he4]; omega
  have he5 : (324 * m + 20) % 2 = 0 := by omega
  have hs6 : collatzStep (324 * m + 20) = 162 * m + 10 := by
    rw [collatz_step_even he5]; omega
  have he6 : (162 * m + 10) % 2 = 0 := by omega
  have hs7 : collatzStep (162 * m + 10) = 81 * m + 5 := by
    rw [collatz_step_even he6]; omega
  calc
    (collatzStep^[7]) (288 * m + 17)
        = (collatzStep^[6]) (collatzStep (288 * m + 17)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[5]) (432 * m + 26) := by
          simp [Function.iterate_succ_apply', hs1, hs2]
    _ = (collatzStep^[4]) (216 * m + 13) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[3]) (648 * m + 40) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = (collatzStep^[2]) (324 * m + 20) := by
          simp [Function.iterate_succ_apply', hs5]
    _ = (collatzStep^[1]) (162 * m + 10) := by
          simp [Function.iterate_succ_apply', hs6]
    _ = 81 * m + 5 := by simp [Function.iterate_succ_apply', hs7]

/--
`[A]` Five-step shrink from `m = 432m₀+53` (`n ≡ 15 mod 128`) is exactly `81m₀+10`.
-/
theorem channel_seven_five_step_shrink_value_of_four_hundred_thirty_two_mul_add_fiftythree
    (m : Nat) :
    (collatzStep^[5]) (432 * m + 53) = 81 * m + 10 := by
  have ho0 : (432 * m + 53) % 2 = 1 := by omega
  have hs1 : collatzStep (432 * m + 53) = 1296 * m + 160 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (1296 * m + 160) % 2 = 0 := by omega
  have hs2 : collatzStep (1296 * m + 160) = 648 * m + 80 := by
    rw [collatz_step_even he1]; omega
  have he2 : (648 * m + 80) % 2 = 0 := by omega
  have hs3 : collatzStep (648 * m + 80) = 324 * m + 40 := by
    rw [collatz_step_even he2]; omega
  have he3 : (324 * m + 40) % 2 = 0 := by omega
  have hs4 : collatzStep (324 * m + 40) = 162 * m + 20 := by
    rw [collatz_step_even he3]; omega
  have he4 : (162 * m + 20) % 2 = 0 := by omega
  have hs5 : collatzStep (162 * m + 20) = 81 * m + 10 := by
    rw [collatz_step_even he4]; omega
  calc
    (collatzStep^[5]) (432 * m + 53)
        = (collatzStep^[4]) (collatzStep (432 * m + 53)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[3]) (648 * m + 80) := by
          simp [Function.iterate_succ_apply', hs1, hs2]
    _ = (collatzStep^[2]) (324 * m + 40) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[1]) (162 * m + 20) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = 81 * m + 10 := by simp [Function.iterate_succ_apply', hs5]

/--
`[A]` Channel `7` subclass `n ≡ 7 (mod 128)`: net descent at `t_good = 4`, `t_loc = 7`.
-/
theorem channel_seven_net_descent_from_good_at_seven_mod128_seven
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 7) :
    ∃ m, n = 128 * m + 7 ∧
      (collatzStep^[7]) (72 * (4 * m) + 17) < n := by
  rcases hmod with ⟨m, hn⟩
  refine ⟨m, hn, ?_⟩
  have hj : n = 32 * (4 * m) + 7 := by rw [hn]; ring_nf
  have hm_good :
      (collatzStep^[4]) (32 * (4 * m) + 7) = 72 * (4 * m) + 17 := by
    simpa using channel_seven_four_step_value_of_thirty_two_mul_add_seven (4 * m)
  have hshrink :
      (collatzStep^[7]) (288 * m + 17) = 81 * m + 5 :=
    channel_seven_seven_step_shrink_value_of_two_hundred_eighty_eight_mul_add_seventeen m
  rw [show 72 * (4 * m) + 17 = 288 * m + 17 from by ring, hshrink, hn]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/--
`[A]` Channel `7` subclass `n ≡ 15 (mod 128)`: net descent at `t_good = 6`, `t_loc = 5`.
-/
theorem channel_seven_net_descent_from_good_at_five_mod128_fifteen
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 15) :
    ∃ m, n = 128 * m + 15 ∧
      (collatzStep^[5]) (108 * (4 * m) + 53) < n := by
  rcases hmod with ⟨m, hn⟩
  refine ⟨m, hn, ?_⟩
  have hshrink :
      (collatzStep^[5]) (432 * m + 53) = 81 * m + 10 :=
    channel_seven_five_step_shrink_value_of_four_hundred_thirty_two_mul_add_fiftythree m
  rw [show 108 * (4 * m) + 53 = 432 * m + 53 from by ring, hshrink, hn]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` — `k % 4 = 1`, `j % 4 = 2` mod-256 lift

Within `n = 32j+15` (`k = 4j+1`), `j % 4 = 2` gives mod-128 class `79`.
The bit `j % 8` splits mod-128 class `79` into mod-256 subclasses `{79, 207}`.
Subclass `j % 8 = 2` (`n ≡ 79 mod 256`) closes uniformly at `t_good = 6`, `t_loc = 7`;
`j % 8 = 6` (`n ≡ 207 mod 256`) remains open (non-uniform `t_loc`).
-/

/--
`[A]` `k % 4 = 1` with `j % 4 = r` determines `n % 128` among `{15, 47, 79, 111}`.
-/
theorem mod128_residue_of_thirty_two_mul_add_fifteen_j_mod4
    {j : Nat} :
    (j % 4 = 0 → (32 * j + 15) % 128 = 15) ∧
      (j % 4 = 1 → (32 * j + 15) % 128 = 47) ∧
        (j % 4 = 2 → (32 * j + 15) % 128 = 79) ∧
          (j % 4 = 3 → (32 * j + 15) % 128 = 111) := by
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  · intro h; omega

/--
`[A]` `k % 4 = 1` with `j % 8 = 2` iff `n = 256m + 79`.
-/
theorem exists_eq_two_hundred_fifty_six_mul_add_seventy_nine_of_thirty_two_mul_add_fifteen_j_mod8_two
    {n j : Nat} (hj : n = 32 * j + 15) (hj_two : j % 8 = 2) :
    ∃ m, n = 256 * m + 79 ∧ j = 8 * m + 2 := by
  refine ⟨j / 8, ?_, ?_⟩
  · have : 32 * j + 15 = 256 * (j / 8) + 79 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` Six-step value at `n = 256m+79` (`j % 8 = 2` within `k % 4 = 1`) is exactly `864m+269`.
-/
theorem channel_seven_six_step_value_of_two_hundred_fifty_six_mul_add_seventy_nine
    (m : Nat) :
    (collatzStep^[6]) (256 * m + 79) = 864 * m + 269 := by
  have hreparam : 256 * m + 79 = 32 * (8 * m + 2) + 15 := by ring
  calc
    (collatzStep^[6]) (256 * m + 79)
        = (collatzStep^[6]) (32 * (8 * m + 2) + 15) := by rw [hreparam]
    _ = 108 * (8 * m + 2) + 53 :=
          channel_seven_six_step_value_of_thirty_two_mul_add_fifteen (8 * m + 2)
    _ = 864 * m + 269 := by ring

/--
`[A]` Good-branch state at six steps from `n = 256m+79` lands in `mod 4 = 1`.
-/
theorem channel_seven_six_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_seventy_nine
    (m : Nat) :
    (864 * m + 269) % 4 = 1 := by omega

/--
`[A]` Seven-step shrink from `m = 864m₀+269` (`n ≡ 79 mod 256`) is exactly `243m₀+76`.
-/
theorem channel_seven_seven_step_shrink_value_of_eight_hundred_sixty_four_mul_add_two_sixtynine
    (m : Nat) :
    (collatzStep^[7]) (864 * m + 269) = 243 * m + 76 := by
  have ho0 : (864 * m + 269) % 2 = 1 := by omega
  have hs1 : collatzStep (864 * m + 269) = 2592 * m + 808 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (2592 * m + 808) % 2 = 0 := by omega
  have hs2 : collatzStep (2592 * m + 808) = 1296 * m + 404 := by
    rw [collatz_step_even he1]; omega
  have he2 : (1296 * m + 404) % 2 = 0 := by omega
  have hs3 : collatzStep (1296 * m + 404) = 648 * m + 202 := by
    rw [collatz_step_even he2]; omega
  have he3 : (648 * m + 202) % 2 = 0 := by omega
  have hs4 : collatzStep (648 * m + 202) = 324 * m + 101 := by
    rw [collatz_step_even he3]; omega
  have ho4 : (324 * m + 101) % 2 = 1 := by omega
  have hs5 : collatzStep (324 * m + 101) = 972 * m + 304 := by
    rw [collatz_step_odd ho4]; ring
  have he5 : (972 * m + 304) % 2 = 0 := by omega
  have hs6 : collatzStep (972 * m + 304) = 486 * m + 152 := by
    rw [collatz_step_even he5]; omega
  have he6 : (486 * m + 152) % 2 = 0 := by omega
  have hs7 : collatzStep (486 * m + 152) = 243 * m + 76 := by
    rw [collatz_step_even he6]; omega
  calc
    (collatzStep^[7]) (864 * m + 269)
        = (collatzStep^[6]) (collatzStep (864 * m + 269)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[5]) (1296 * m + 404) := by
          simp [Function.iterate_succ_apply', hs1, hs2]
    _ = (collatzStep^[4]) (648 * m + 202) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[3]) (324 * m + 101) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = (collatzStep^[2]) (972 * m + 304) := by
          simp [Function.iterate_succ_apply', hs5]
    _ = (collatzStep^[1]) (486 * m + 152) := by
          simp [Function.iterate_succ_apply', hs6]
    _ = 243 * m + 76 := by simp [Function.iterate_succ_apply', hs7]

/--
`[A]` Channel `7` subclass `n ≡ 79 (mod 256)`: net descent at `t_good = 6`, `t_loc = 7`.
-/
theorem channel_seven_net_descent_from_good_at_seven_mod256_seventy_nine
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 79) :
    ∃ m, n = 256 * m + 79 ∧
      (collatzStep^[7]) (864 * m + 269) < n := by
  rcases hmod with ⟨m, hn⟩
  refine ⟨m, hn, ?_⟩
  have hshrink :
      (collatzStep^[7]) (864 * m + 269) = 243 * m + 76 :=
    channel_seven_seven_step_shrink_value_of_eight_hundred_sixty_four_mul_add_two_sixtynine m
  rw [hshrink, hn]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` — `k % 4 = 3`, `j % 8 = 2` mod-256 lift

Within `n = 32j+31` (`k = 4j+3`), `j % 8 = 2` gives mod-128 class `95`.
The bit `j % 8` splits mod-128 class `95` into mod-256 subclasses `{95, 223}`.
Subclass `j % 8 = 2` (`n ≡ 95 mod 256`) closes at uniform `t_good = 8`, `t_loc = 5`;
`j % 8 = 6` (`n ≡ 223 mod 256`) remains open (non-uniform `t_loc`).
-/

/--
`[A]` `k % 4 = 3` within channel `7` iff `n = 32j + 31`.
-/
theorem exists_eq_thirty_two_mul_add_thirtyone_of_mod8_eq_seven_and_k_mod4_three
    {n k : Nat} (hk : n = 8 * k + 7) (hk_three : k % 4 = 3) :
    ∃ j, n = 32 * j + 31 ∧ k = 4 * j + 3 := by
  refine ⟨k / 4, ?_, ?_⟩
  · have : 8 * k + 7 = 32 * (k / 4) + 31 := by omega
    simpa [hk] using this
  · omega

/--
`[A]` `k % 4 = 3` with `j % 4 = r` determines `n % 128` among `{31, 63, 95, 127}`.
-/
theorem mod128_residue_of_thirty_two_mul_add_thirtyone_j_mod4
    {j : Nat} :
    (j % 4 = 0 → (32 * j + 31) % 128 = 31) ∧
      (j % 4 = 1 → (32 * j + 31) % 128 = 63) ∧
        (j % 4 = 2 → (32 * j + 31) % 128 = 95) ∧
          (j % 4 = 3 → (32 * j + 31) % 128 = 127) := by
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  · intro h; omega

/--
`[A]` `k % 4 = 3` with `j % 8 = 2` iff `n = 256m + 95`.
-/
theorem exists_eq_two_hundred_fifty_six_mul_add_ninety_five_of_thirty_two_mul_add_thirtyone_j_mod8_two
    {n j : Nat} (hj : n = 32 * j + 31) (hj_two : j % 8 = 2) :
    ∃ m, n = 256 * m + 95 ∧ j = 8 * m + 2 := by
  refine ⟨j / 8, ?_, ?_⟩
  · have : 32 * j + 31 = 256 * (j / 8) + 95 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` Four-step value at `n = 32j+31` (`k = 4j+3`) is exactly `72j+71`.
-/
theorem channel_seven_four_step_value_of_thirty_two_mul_add_thirtyone (j : Nat) :
    (collatzStep^[4]) (32 * j + 31) = 72 * j + 71 := by
  have hform : 32 * j + 31 = 8 * (4 * j + 3) + 7 := by ring
  have hm : T_odd (32 * j + 31) = 48 * j + 47 := by
    calc
      T_odd (32 * j + 31) = T_odd (8 * (4 * j + 3) + 7) := by rw [hform]
      _ = 12 * (4 * j + 3) + 11 := T_odd_of_eight_mul_add_seven (4 * j + 3)
      _ = 48 * j + 47 := by ring
  have ho : (32 * j + 31) % 2 = 1 := by omega
  have he1 : (96 * j + 94) % 2 = 0 := by omega
  have hoT : (48 * j + 47) % 2 = 1 := by omega
  have he2 : (144 * j + 142) % 2 = 0 := by omega
  have ho3 : (72 * j + 71) % 2 = 1 := by omega
  have he3 : (216 * j + 214) % 2 = 0 := by omega
  calc
    (collatzStep^[4]) (32 * j + 31)
        = (collatzStep^[2]) ((collatzStep^[2]) (32 * j + 31)) := by
            rw [Function.iterate_add_apply collatzStep 2 2 (32 * j + 31)]
    _ = (collatzStep^[2]) (T_odd (32 * j + 31)) := by
          congr 1
          calc
            (collatzStep^[2]) (32 * j + 31)
                = collatzStep (collatzStep (32 * j + 31)) := by
                    simp [Function.iterate_succ_apply']
            _ = collatzStep (3 * (32 * j + 31) + 1) := by rw [collatz_step_odd ho]
            _ = collatzStep (96 * j + 94) := by congr 1; ring
            _ = 48 * j + 47 := by rw [collatz_step_even he1]; omega
            _ = T_odd (32 * j + 31) := hm.symm
    _ = (collatzStep^[2]) (48 * j + 47) := by rw [hm]
    _ = collatzStep (collatzStep (48 * j + 47)) := by simp [Function.iterate_succ_apply']
    _ = collatzStep (144 * j + 142) := by rw [collatz_step_odd hoT]; congr 1; ring
    _ = 72 * j + 71 := by rw [collatz_step_even he2]; omega

/--
`[A]` Four-step shrink from `m = 72j+71` is exactly `162j+161`.
-/
theorem channel_seven_four_step_shrink_value_of_seventy_two_mul_add_seventyone (j : Nat) :
    (collatzStep^[4]) (72 * j + 71) = 162 * j + 161 := by
  have ho0 : (72 * j + 71) % 2 = 1 := by omega
  have hs1 : collatzStep (72 * j + 71) = 216 * j + 214 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (216 * j + 214) % 2 = 0 := by omega
  have hs2 : collatzStep (216 * j + 214) = 108 * j + 107 := by
    rw [collatz_step_even he1]; omega
  have ho2 : (108 * j + 107) % 2 = 1 := by omega
  have hs3 : collatzStep (108 * j + 107) = 324 * j + 322 := by
    rw [collatz_step_odd ho2]; ring
  have he3 : (324 * j + 322) % 2 = 0 := by omega
  have hs4 : collatzStep (324 * j + 322) = 162 * j + 161 := by
    rw [collatz_step_even he3]; omega
  calc
    (collatzStep^[4]) (72 * j + 71)
        = (collatzStep^[3]) (collatzStep (72 * j + 71)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[2]) (108 * j + 107) := by
          simp [Function.iterate_succ_apply', hs1, hs2]
    _ = (collatzStep^[1]) (324 * j + 322) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = 162 * j + 161 := by simp [Function.iterate_succ_apply', hs4]

/--
`[A]` Eight-step value at `n = 32j+31` (`k = 4j+3`) is exactly `162j+161`.
-/
theorem channel_seven_eight_step_value_of_thirty_two_mul_add_thirtyone (j : Nat) :
    (collatzStep^[8]) (32 * j + 31) = 162 * j + 161 := by
  have h4 := channel_seven_four_step_value_of_thirty_two_mul_add_thirtyone j
  have hsh := channel_seven_four_step_shrink_value_of_seventy_two_mul_add_seventyone j
  calc
    (collatzStep^[8]) (32 * j + 31)
        = (collatzStep^[4]) ((collatzStep^[4]) (32 * j + 31)) := by
            rw [Function.iterate_add_apply collatzStep 4 4 (32 * j + 31)]
    _ = (collatzStep^[4]) (72 * j + 71) := by rw [h4]
    _ = 162 * j + 161 := hsh

/--
`[A]` Eight-step value at `n = 256m+95` (`j % 8 = 2` within `k % 4 = 3`) is exactly `1296m+485`.
-/
theorem channel_seven_eight_step_value_of_two_hundred_fifty_six_mul_add_ninety_five
    (m : Nat) :
    (collatzStep^[8]) (256 * m + 95) = 1296 * m + 485 := by
  have hreparam : 256 * m + 95 = 32 * (8 * m + 2) + 31 := by ring
  calc
    (collatzStep^[8]) (256 * m + 95)
        = (collatzStep^[8]) (32 * (8 * m + 2) + 31) := by rw [hreparam]
    _ = 162 * (8 * m + 2) + 161 :=
          channel_seven_eight_step_value_of_thirty_two_mul_add_thirtyone (8 * m + 2)
    _ = 1296 * m + 485 := by ring

/--
`[A]` Good-branch state at eight steps from `n = 256m+95` lands in `mod 4 = 1`.
-/
theorem channel_seven_eight_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_ninety_five
    (m : Nat) :
    (1296 * m + 485) % 4 = 1 := by omega

/--
`[A]` Five-step shrink from `m = 1296m₀+485` (`n ≡ 95 mod 256`) is exactly `243m₀+91`.
-/
theorem channel_seven_five_step_shrink_value_of_twelve_hundred_ninety_six_mul_add_four_eightyfive
    (m : Nat) :
    (collatzStep^[5]) (1296 * m + 485) = 243 * m + 91 := by
  have ho0 : (1296 * m + 485) % 2 = 1 := by omega
  have hs1 : collatzStep (1296 * m + 485) = 3888 * m + 1456 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (3888 * m + 1456) % 2 = 0 := by omega
  have hs2 : collatzStep (3888 * m + 1456) = 1944 * m + 728 := by
    rw [collatz_step_even he1]; omega
  have he2 : (1944 * m + 728) % 2 = 0 := by omega
  have hs3 : collatzStep (1944 * m + 728) = 972 * m + 364 := by
    rw [collatz_step_even he2]; omega
  have he3 : (972 * m + 364) % 2 = 0 := by omega
  have hs4 : collatzStep (972 * m + 364) = 486 * m + 182 := by
    rw [collatz_step_even he3]; omega
  have he4 : (486 * m + 182) % 2 = 0 := by omega
  have hs5 : collatzStep (486 * m + 182) = 243 * m + 91 := by
    rw [collatz_step_even he4]; omega
  calc
    (collatzStep^[5]) (1296 * m + 485)
        = (collatzStep^[4]) (collatzStep (1296 * m + 485)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[3]) (1944 * m + 728) := by
          simp [Function.iterate_succ_apply', hs1, hs2]
    _ = (collatzStep^[2]) (972 * m + 364) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[1]) (486 * m + 182) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = 243 * m + 91 := by simp [Function.iterate_succ_apply', hs5]

/--
`[A]` Channel `7` subclass `n ≡ 95 (mod 256)`: net descent at `t_good = 8`, `t_loc = 5`.
-/
theorem channel_seven_net_descent_from_good_at_five_mod256_ninety_five
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 95) :
    ∃ m, n = 256 * m + 95 ∧
      (collatzStep^[5]) (1296 * m + 485) < n := by
  rcases hmod with ⟨m, hn⟩
  refine ⟨m, hn, ?_⟩
  have hshrink :
      (collatzStep^[5]) (1296 * m + 485) = 243 * m + 91 :=
    channel_seven_five_step_shrink_value_of_twelve_hundred_ninety_six_mul_add_four_eightyfive m
  rw [hshrink, hn]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` — `k % 4 = 0`, `j % 8 = 1` mod-256 lift

Within `n = 32j+7` (`k = 4j`), `j % 8 = 1` gives mod-128 class `39`.
The bit `j % 8` splits mod-128 class `39` into mod-256 subclasses `{39, 167}`.
Subclass `j % 8 = 1` (`n ≡ 39 mod 256`) closes at uniform `t_good = 4`, `t_loc = 9`;
`j % 8 = 5` (`n ≡ 167 mod 256`) remains open (non-uniform `t_loc`).
-/

/--
`[A]` `k % 4 = 0` with `j % 4 = r` determines `n % 128` among `{7, 39, 71, 103}`.
-/
theorem mod128_residue_of_thirty_two_mul_add_seven_j_mod4
    {j : Nat} :
    (j % 4 = 0 → (32 * j + 7) % 128 = 7) ∧
      (j % 4 = 1 → (32 * j + 7) % 128 = 39) ∧
        (j % 4 = 2 → (32 * j + 7) % 128 = 71) ∧
          (j % 4 = 3 → (32 * j + 7) % 128 = 103) := by
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  constructor
  · intro h; omega
  · intro h; omega

/--
`[A]` `k % 4 = 0` with `j % 8 = 1` iff `n = 256m + 39`.
-/
theorem exists_eq_two_hundred_fifty_six_mul_add_thirty_nine_of_thirty_two_mul_add_seven_j_mod8_one
    {n j : Nat} (hj : n = 32 * j + 7) (hj_one : j % 8 = 1) :
    ∃ m, n = 256 * m + 39 ∧ j = 8 * m + 1 := by
  refine ⟨j / 8, ?_, ?_⟩
  · have : 32 * j + 7 = 256 * (j / 8) + 39 := by omega
    simpa [hj] using this
  · omega

/--
`[A]` Four-step value at `n = 256m+39` (`j % 8 = 1` within `k % 4 = 0`) is exactly `576m+89`.
-/
theorem channel_seven_four_step_value_of_two_hundred_fifty_six_mul_add_thirty_nine
    (m : Nat) :
    (collatzStep^[4]) (256 * m + 39) = 576 * m + 89 := by
  have hreparam : 256 * m + 39 = 32 * (8 * m + 1) + 7 := by ring
  calc
    (collatzStep^[4]) (256 * m + 39)
        = (collatzStep^[4]) (32 * (8 * m + 1) + 7) := by rw [hreparam]
    _ = 72 * (8 * m + 1) + 17 :=
          channel_seven_four_step_value_of_thirty_two_mul_add_seven (8 * m + 1)
    _ = 576 * m + 89 := by ring

/--
`[A]` Good-branch state at four steps from `n = 256m+39` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_thirty_nine
    (m : Nat) :
    (576 * m + 89) % 4 = 1 := by omega

/--
`[A]` Nine-step shrink from `m = 576m₀+89` (`n ≡ 39 mod 256`) is exactly `243m₀+38`.
-/
theorem channel_seven_nine_step_shrink_value_of_five_hundred_seventy_six_mul_add_eightynine
    (m : Nat) :
    (collatzStep^[9]) (576 * m + 89) = 243 * m + 38 := by
  have ho0 : (576 * m + 89) % 2 = 1 := by omega
  have hs1 : collatzStep (576 * m + 89) = 1728 * m + 268 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (1728 * m + 268) % 2 = 0 := by omega
  have hs2 : collatzStep (1728 * m + 268) = 864 * m + 134 := by
    rw [collatz_step_even he1]; omega
  have he2 : (864 * m + 134) % 2 = 0 := by omega
  have hs3 : collatzStep (864 * m + 134) = 432 * m + 67 := by
    rw [collatz_step_even he2]; omega
  have ho3 : (432 * m + 67) % 2 = 1 := by omega
  have hs4 : collatzStep (432 * m + 67) = 1296 * m + 202 := by
    rw [collatz_step_odd ho3]; ring
  have he4 : (1296 * m + 202) % 2 = 0 := by omega
  have hs5 : collatzStep (1296 * m + 202) = 648 * m + 101 := by
    rw [collatz_step_even he4]; omega
  have ho5 : (648 * m + 101) % 2 = 1 := by omega
  have hs6 : collatzStep (648 * m + 101) = 1944 * m + 304 := by
    rw [collatz_step_odd ho5]; ring
  have he6 : (1944 * m + 304) % 2 = 0 := by omega
  have hs7 : collatzStep (1944 * m + 304) = 972 * m + 152 := by
    rw [collatz_step_even he6]; omega
  have he7 : (972 * m + 152) % 2 = 0 := by omega
  have hs8 : collatzStep (972 * m + 152) = 486 * m + 76 := by
    rw [collatz_step_even he7]; omega
  have he8 : (486 * m + 76) % 2 = 0 := by omega
  have hs9 : collatzStep (486 * m + 76) = 243 * m + 38 := by
    rw [collatz_step_even he8]; omega
  calc
    (collatzStep^[9]) (576 * m + 89)
        = (collatzStep^[8]) (collatzStep (576 * m + 89)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[8]) (1728 * m + 268) := by
          simp [Function.iterate_succ_apply', hs1]
    _ = (collatzStep^[7]) (864 * m + 134) := by
          simp [Function.iterate_succ_apply', hs2]
    _ = (collatzStep^[6]) (432 * m + 67) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[5]) (1296 * m + 202) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = (collatzStep^[4]) (648 * m + 101) := by
          simp [Function.iterate_succ_apply', hs5]
    _ = (collatzStep^[3]) (1944 * m + 304) := by
          simp [Function.iterate_succ_apply', hs6]
    _ = (collatzStep^[2]) (972 * m + 152) := by
          simp [Function.iterate_succ_apply', hs7]
    _ = (collatzStep^[1]) (486 * m + 76) := by
          simp [Function.iterate_succ_apply', hs8]
    _ = 243 * m + 38 := hs9

/--
`[A]` Channel `7` subclass `n ≡ 39 (mod 256)`: net descent at `t_good = 4`, `t_loc = 9`.
-/
theorem channel_seven_net_descent_from_good_at_nine_mod256_thirty_nine
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ m, n = 256 * m + 39) :
    ∃ m, n = 256 * m + 39 ∧
      (collatzStep^[9]) (576 * m + 89) < n := by
  rcases hmod with ⟨m, hn⟩
  refine ⟨m, hn, ?_⟩
  have hshrink :
      (collatzStep^[9]) (576 * m + 89) = 243 * m + 38 :=
    channel_seven_nine_step_shrink_value_of_five_hundred_seventy_six_mul_add_eightynine m
  rw [hshrink, hn]
  rcases m with _ | m
  · norm_num at hn ⊢
  · omega

/-!
### Channel `7` — deep-tail lift of `71 mod 128` / obstruction for full `71 mod 256`

The even mod-256 child of deep-tail class `71 mod 128` is `n ≡ 71 (mod 256)`
(`n = 256m + 71`). It has uniform good-branch entry
`t_good = 4`, `m_good = 576m + 161`, but after ten further steps the affine state
`729m + 206` has odd leading coefficient, so the Collatz parity branches on `m`.
Consequently there is **no** uniform `t_loc` for the whole class `71 mod 256`
(same obstruction pattern as open siblings `{167, 207, 223}`).

The 2-adic refinement `m ≡ 2 (mod 4)` restores uniformity:
`n = 1024k + 583` closes at `t_good = 4`, `t_loc = 12`, shrink `729k + 416`.
-/

/--
`[A]` Four-step value at `n = 256m+71` (even child of deep-tail `71 mod 128`)
is exactly `576m+161`.
-/
theorem channel_seven_four_step_value_of_two_hundred_fifty_six_mul_add_seventy_one
    (m : Nat) :
    (collatzStep^[4]) (256 * m + 71) = 576 * m + 161 := by
  have hreparam : 256 * m + 71 = 32 * (8 * m + 2) + 7 := by ring
  calc
    (collatzStep^[4]) (256 * m + 71)
        = (collatzStep^[4]) (32 * (8 * m + 2) + 7) := by rw [hreparam]
    _ = 72 * (8 * m + 2) + 17 :=
          channel_seven_four_step_value_of_thirty_two_mul_add_seven (8 * m + 2)
    _ = 576 * m + 161 := by ring

/--
`[A]` Good-branch state at four steps from `n = 256m+71` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_two_hundred_fifty_six_mul_add_seventy_one
    (m : Nat) :
    (576 * m + 161) % 4 = 1 := by omega

/--
`[A]` Four-step value at `n = 1024k+583` (`m ≡ 2 (mod 4)` inside `71 mod 256`)
is exactly `2304k+1313`.
-/
theorem channel_seven_four_step_value_of_one_thousand_twenty_four_mul_add_five_eighty_three
    (k : Nat) :
    (collatzStep^[4]) (1024 * k + 583) = 2304 * k + 1313 := by
  have hreparam : 1024 * k + 583 = 256 * (4 * k + 2) + 71 := by ring
  calc
    (collatzStep^[4]) (1024 * k + 583)
        = (collatzStep^[4]) (256 * (4 * k + 2) + 71) := by rw [hreparam]
    _ = 576 * (4 * k + 2) + 161 :=
          channel_seven_four_step_value_of_two_hundred_fifty_six_mul_add_seventy_one
            (4 * k + 2)
    _ = 2304 * k + 1313 := by ring

/--
`[A]` Good-branch state at four steps from `n = 1024k+583` lands in `mod 4 = 1`.
-/
theorem channel_seven_four_step_good_mod4_one_of_one_thousand_twenty_four_mul_add_five_eighty_three
    (k : Nat) :
    (2304 * k + 1313) % 4 = 1 := by omega

/--
`[A]` Twelve-step shrink from `m_good = 2304k+1313` (`n ≡ 583 mod 1024`)
is exactly `729k+416`.
-/
theorem channel_seven_twelve_step_shrink_value_of_two_thousand_three_hundred_four_mul_add_thirteen_thirteen
    (k : Nat) :
    (collatzStep^[12]) (2304 * k + 1313) = 729 * k + 416 := by
  have ho0 : (2304 * k + 1313) % 2 = 1 := by omega
  have hs1 : collatzStep (2304 * k + 1313) = 6912 * k + 3940 := by
    rw [collatz_step_odd ho0]; ring
  have he1 : (6912 * k + 3940) % 2 = 0 := by omega
  have hs2 : collatzStep (6912 * k + 3940) = 3456 * k + 1970 := by
    rw [collatz_step_even he1]; omega
  have he2 : (3456 * k + 1970) % 2 = 0 := by omega
  have hs3 : collatzStep (3456 * k + 1970) = 1728 * k + 985 := by
    rw [collatz_step_even he2]; omega
  have ho3 : (1728 * k + 985) % 2 = 1 := by omega
  have hs4 : collatzStep (1728 * k + 985) = 5184 * k + 2956 := by
    rw [collatz_step_odd ho3]; ring
  have he4 : (5184 * k + 2956) % 2 = 0 := by omega
  have hs5 : collatzStep (5184 * k + 2956) = 2592 * k + 1478 := by
    rw [collatz_step_even he4]; omega
  have he5 : (2592 * k + 1478) % 2 = 0 := by omega
  have hs6 : collatzStep (2592 * k + 1478) = 1296 * k + 739 := by
    rw [collatz_step_even he5]; omega
  have ho6 : (1296 * k + 739) % 2 = 1 := by omega
  have hs7 : collatzStep (1296 * k + 739) = 3888 * k + 2218 := by
    rw [collatz_step_odd ho6]; ring
  have he7 : (3888 * k + 2218) % 2 = 0 := by omega
  have hs8 : collatzStep (3888 * k + 2218) = 1944 * k + 1109 := by
    rw [collatz_step_even he7]; omega
  have ho8 : (1944 * k + 1109) % 2 = 1 := by omega
  have hs9 : collatzStep (1944 * k + 1109) = 5832 * k + 3328 := by
    rw [collatz_step_odd ho8]; ring
  have he9 : (5832 * k + 3328) % 2 = 0 := by omega
  have hs10 : collatzStep (5832 * k + 3328) = 2916 * k + 1664 := by
    rw [collatz_step_even he9]; omega
  have he10 : (2916 * k + 1664) % 2 = 0 := by omega
  have hs11 : collatzStep (2916 * k + 1664) = 1458 * k + 832 := by
    rw [collatz_step_even he10]; omega
  have he11 : (1458 * k + 832) % 2 = 0 := by omega
  have hs12 : collatzStep (1458 * k + 832) = 729 * k + 416 := by
    rw [collatz_step_even he11]; omega
  calc
    (collatzStep^[12]) (2304 * k + 1313)
        = (collatzStep^[11]) (collatzStep (2304 * k + 1313)) := by
            simp [Function.iterate_succ_apply']
    _ = (collatzStep^[11]) (6912 * k + 3940) := by
          simp [Function.iterate_succ_apply', hs1]
    _ = (collatzStep^[10]) (3456 * k + 1970) := by
          simp [Function.iterate_succ_apply', hs2]
    _ = (collatzStep^[9]) (1728 * k + 985) := by
          simp [Function.iterate_succ_apply', hs3]
    _ = (collatzStep^[8]) (5184 * k + 2956) := by
          simp [Function.iterate_succ_apply', hs4]
    _ = (collatzStep^[7]) (2592 * k + 1478) := by
          simp [Function.iterate_succ_apply', hs5]
    _ = (collatzStep^[6]) (1296 * k + 739) := by
          simp [Function.iterate_succ_apply', hs6]
    _ = (collatzStep^[5]) (3888 * k + 2218) := by
          simp [Function.iterate_succ_apply', hs7]
    _ = (collatzStep^[4]) (1944 * k + 1109) := by
          simp [Function.iterate_succ_apply', hs8]
    _ = (collatzStep^[3]) (5832 * k + 3328) := by
          simp [Function.iterate_succ_apply', hs9]
    _ = (collatzStep^[2]) (2916 * k + 1664) := by
          simp [Function.iterate_succ_apply', hs10]
    _ = (collatzStep^[1]) (1458 * k + 832) := by
          simp [Function.iterate_succ_apply', hs11]
    _ = 729 * k + 416 := hs12

/--
`[A]` Channel `7` subclass `n ≡ 583 (mod 1024)`: net descent at `t_good = 4`, `t_loc = 12`.
This is the maximal uniform 2-adic child of deep-tail `71 mod 256` with short affine
shrink; the residual children of `71 mod 256` remain open.
-/
theorem channel_seven_net_descent_from_good_at_twelve_mod1024_five_eighty_three
    {n : Nat} (hn : 1 < n) (_h7 : n % 8 = 7)
    (hmod : ∃ k, n = 1024 * k + 583) :
    ∃ k, n = 1024 * k + 583 ∧
      (collatzStep^[12]) (2304 * k + 1313) < n := by
  rcases hmod with ⟨k, hn⟩
  refine ⟨k, hn, ?_⟩
  have hshrink :
      (collatzStep^[12]) (2304 * k + 1313) = 729 * k + 416 :=
    channel_seven_twelve_step_shrink_value_of_two_thousand_three_hundred_four_mul_add_thirteen_thirteen k
  rw [hshrink, hn]
  rcases k with _ | k
  · norm_num
  · omega

end CollatzNetDescentMod8
end CollatzAttemptV2

end KeplerHurwitz
