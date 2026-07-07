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

end CollatzNetDescentMod8
end CollatzAttemptV2

end KeplerHurwitz
