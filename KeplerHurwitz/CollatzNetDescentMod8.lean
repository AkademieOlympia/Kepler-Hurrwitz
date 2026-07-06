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

end CollatzNetDescentMod8
end CollatzAttemptV2

end KeplerHurwitz
