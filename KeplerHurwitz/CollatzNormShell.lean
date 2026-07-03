import Mathlib
import KeplerHurwitz.OddCore

namespace KeplerHurwitz

/-- Ein Collatz-Einzelschritt auf `Nat`. -/
def collatzStep (n : Nat) : Nat :=
  if n % 2 = 0 then n / 2 else 3 * n + 1

/-- Nüchterne Normschalen-Energie: aktuell einfach die natürliche Größe. -/
def shellEnergy (n : Nat) : Nat := n

/--
Beschleunigter ungerader Schritt:
nach dem ungeraden `3n+1`-Kick wird einmal durch `2` geteilt.
-/
def oddKick (n : Nat) : Nat := (3 * n + 1) / 2

/--
Ein einfacher beschleunigter Collatz-Schritt:
- gerade Zahlen: `n/2`
- ungerade Zahlen: `(3n+1)/2`
-/
def collatzAccelerated (n : Nat) : Nat :=
  if n % 2 = 0 then n / 2 else oddKick n

theorem collatz_even_step_lt (hn : 0 < n) (he : n % 2 = 0) :
    collatzStep n < n := by
  simpa [collatzStep, he] using (Nat.div_lt_self hn (by decide : 1 < 2))

theorem collatz_odd_step_gt (ho : n % 2 = 1) :
    n < collatzStep n := by
  have hne : n % 2 ≠ 0 := by omega
  simp [collatzStep, hne]
  omega

theorem shellEnergy_even_drop (hn : 0 < n) (he : n % 2 = 0) :
    shellEnergy (collatzStep n) < shellEnergy n := by
  simpa [shellEnergy] using collatz_even_step_lt hn he

theorem shellEnergy_odd_rise (ho : n % 2 = 1) :
    shellEnergy n < shellEnergy (collatzStep n) := by
  simpa [shellEnergy] using collatz_odd_step_gt ho

theorem three_mul_add_one_even_of_odd (ho : n % 2 = 1) :
    (3 * n + 1) % 2 = 0 := by
  omega

theorem oddKick_eq_collatz_half (ho : n % 2 = 1) :
    oddKick n = collatzStep n / 2 := by
  have hne : n % 2 ≠ 0 := by omega
  simp [oddKick, collatzStep, hne]

theorem collatzAccelerated_even (he : n % 2 = 0) :
    collatzAccelerated n = n / 2 := by
  simp [collatzAccelerated, he]

theorem collatzAccelerated_odd (ho : n % 2 = 1) :
    collatzAccelerated n = oddKick n := by
  have hne : n % 2 ≠ 0 := by omega
  simp [collatzAccelerated, hne]

theorem collatz_even_collapse (n : Nat) :
    collatzStep (2 * n) = n := by
  simp [collatzStep]

theorem collatz_step_pow_two (k : Nat) :
    collatzStep (2 ^ (k + 1)) = 2 ^ k := by
  calc
    collatzStep (2 ^ (k + 1))
        = collatzStep (2 * 2 ^ k) := by
            simp [Nat.pow_succ, Nat.mul_comm]
    _ = 2 ^ k := by simpa [Nat.mul_comm] using collatz_even_collapse (2 ^ k)

theorem collatz_step_pow_two_mul (k m : Nat) :
    collatzStep (2 ^ (k + 1) * m) = 2 ^ k * m := by
  calc
    collatzStep (2 ^ (k + 1) * m)
        = collatzStep (2 * (2 ^ k * m)) := by
            simp [Nat.pow_succ, Nat.mul_comm, Nat.mul_left_comm]
    _ = 2 ^ k * m := by
          simpa [Nat.mul_comm] using collatz_even_collapse (2 ^ k * m)

/--
Für jede Zweierpotenz `2^k` ist nach genau `k` Collatz-Schritten der Wert `1` erreicht.
Das ist ein vollständig formalisierter Normschalen-Basisfall.
-/
theorem collatz_iterate_pow_two_to_one (k : Nat) :
    Nat.iterate collatzStep k (2 ^ k) = 1 := by
  induction k with
  | zero =>
      simp
  | succ k ih =>
      calc
        Nat.iterate collatzStep (k + 1) (2 ^ (k + 1))
            = Nat.iterate collatzStep k (collatzStep (2 ^ (k + 1))) := by
                simp
        _ = Nat.iterate collatzStep k (2 ^ k) := by
              simp [collatz_step_pow_two]
        _ = 1 := ih

/--
Normschalen-Deszentsatz:
Für jede Zahl der Form `2^k * m` führt genau `k`-maliges Halbieren
unter Collatz auf den Kern `m`.
-/
theorem collatz_iterate_pow_two_mul (k m : Nat) :
    Nat.iterate collatzStep k (2 ^ k * m) = m := by
  induction k generalizing m with
  | zero =>
      simp
  | succ k ih =>
      calc
        Nat.iterate collatzStep (k + 1) (2 ^ (k + 1) * m)
            = Nat.iterate collatzStep k (collatzStep (2 ^ (k + 1) * m)) := by
                simp
        _ = Nat.iterate collatzStep k (2 ^ k * m) := by
              simp [collatz_step_pow_two_mul]
        _ = m := ih m

/--
Normschalen-Retraktion auf den ungeraden Kern:
Ist `m` ungerade, dann fällt `2^k * m` nach genau `k` Schritten auf `m`.
-/
theorem collatz_iterate_pow_two_mul_odd_to_odd_core
    (k m : Nat) (hm : m % 2 = 1) :
    Nat.iterate collatzStep k (2 ^ k * m) = m ∧ m % 2 = 1 := by
  constructor
  · exact collatz_iterate_pow_two_mul k m
  · exact hm

theorem collatz_iterate_of_oddCoreDecomposition
    {n k m : Nat}
    (hm : m % 2 = 1)
    (h : n = 2 ^ k * m) :
    Nat.iterate collatzStep k n = m := by
  subst n
  exact (collatz_iterate_pow_two_mul_odd_to_odd_core k m hm).1

theorem collatz_iterate_of_decomposition
    {n : Nat}
    (d : OddCoreDecomposition n) :
    Nat.iterate collatzStep d.k n = d.m := by
  exact collatz_iterate_of_oddCoreDecomposition d.hm_odd d.hdecomp

/--
Normschalen-Angriff: Bei ungeradem Startwert führt ein ungerader Kick (`3m+1`)
plus endlich viele Halbierungen exakt zum ungeraden Kern `oddCore (3m+1)`.
-/
theorem odd_kick_reaches_oddCore (hm : m % 2 = 1) :
    ∃ t, Nat.iterate collatzStep t m = oddCore (3 * m + 1) := by
  let d : OddCoreDecomposition (3 * m + 1) :=
    oddCoreDecompositionOfPos (by omega)
  refine ⟨d.k + 1, ?_⟩
  have hm_ne : m % 2 ≠ 0 := by omega
  have hstep : collatzStep m = 3 * m + 1 := by
    simp [collatzStep, hm_ne]
  calc
    Nat.iterate collatzStep (d.k + 1) m
        = Nat.iterate collatzStep d.k (collatzStep m) := by simp
    _ = Nat.iterate collatzStep d.k (3 * m + 1) := by simp [hstep]
    _ = Nat.iterate collatzStep d.k (2 ^ d.k * d.m) := by simp [d.hdecomp]
    _ = d.m := by simpa using collatz_iterate_pow_two_mul d.k d.m
    _ = oddCore (3 * m + 1) := by rfl

/--
Konjekturale Vollaussage der Collatz-Dynamik (noch unbewiesen):
Jede positive natürliche Zahl erreicht unter Iteration `1`.
-/
def ClassicalCollatzConjecture : Prop :=
  ∀ n > 0, ∃ k, Nat.iterate collatzStep k n = 1

/--
Normschalen-Fassung: Es genügt, die Dynamik auf positiven ungeraden Kernen zu zeigen.
-/
def OddCoreCollatzConjecture : Prop :=
  ∀ m > 0, m % 2 = 1 → ∃ t, Nat.iterate collatzStep t m = 1

theorem classicalCollatz_implies_oddCoreCollatz :
    ClassicalCollatzConjecture → OddCoreCollatzConjecture := by
  intro h m hm_pos hm_odd
  exact h m hm_pos

theorem oddCoreCollatz_implies_classicalCollatz :
    OddCoreCollatzConjecture → ClassicalCollatzConjecture := by
  intro h n hn_pos
  let d : OddCoreDecomposition n := oddCoreDecompositionOfPos hn_pos
  have hm_pos : 0 < d.m := (Nat.odd_iff.mpr d.hm_odd).pos
  rcases h d.m hm_pos d.hm_odd with ⟨t, ht⟩
  refine ⟨t + d.k, ?_⟩
  calc
    Nat.iterate collatzStep (t + d.k) n
        = Nat.iterate collatzStep t (Nat.iterate collatzStep d.k n) := by
            simpa [Nat.iterate] using
              (Function.iterate_add_apply collatzStep t d.k n)
    _ = Nat.iterate collatzStep t d.m := by
          simp [collatz_iterate_of_decomposition d]
    _ = 1 := ht

theorem classicalCollatz_iff_oddCoreCollatz :
    ClassicalCollatzConjecture ↔ OddCoreCollatzConjecture := by
  constructor
  · exact classicalCollatz_implies_oddCoreCollatz
  · exact oddCoreCollatz_implies_classicalCollatz

/--
Alias im EABC/Hurwitz-Sprachraum.
-/
def HurwitzCollatzNormshellConjecture : Prop :=
  ClassicalCollatzConjecture

end KeplerHurwitz
