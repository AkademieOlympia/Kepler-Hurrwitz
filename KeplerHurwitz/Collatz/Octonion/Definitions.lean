import Mathlib
import KeplerHurwitz.OddCore
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.OctonionicSlice

/-!
Post-freeze oktonionischer Collatz-Beweisversuch — Basisschicht.

Governance: außerhalb `audit-freeze-2026`; keine Änderung an ι_n, ε_n oder frozen dossier.
Status-Tags: `[A]` bewiesen, `[B]` empirisch, `[C]` offen.
-/

namespace KeplerHurwitz.Collatz.Octonion

noncomputable section

open Real

/-- Iteration des ungeraden Kern-Schritts `S`. -/
def oddCoreIterate (k : Nat) (n : Nat) : Nat :=
  oddCoreStep^[k] n

/-!
### Witness-Parametrisierung (arithmetisch transparent, Beweiskette O2)

Primäre Familie für die geschlossene Bahnform und beliebig lange `ν₂ = 1`-Läufe:
`m(L) = 2L + 1` (stets ungerade, `L < m(L)`).
Start `n₀(L) = 2^m(L) - 1`; Bahn `3^j · 2^{m(L)-j} - 1`.

Legacy-Parametrisierung `mersenneOddExponent` / `mersenneOdd` (mod-6-robuste Verschiebung)
bleibt für ältere Skizzen erhalten; für die Witness-Kette wird `witnessStart` verwendet.
-/

/-- Ungerader Witness-Exponent `m(L) = 2L + 1`. -/
def witnessExponent (L : Nat) : Nat := 2 * L + 1

/-- Mersenne-artiger Witness-Start `2^m(L) - 1`. -/
def witnessStart (L : Nat) : Nat := 2 ^ witnessExponent L - 1

/-- Geschlossener Bahnwert `S^j(n₀(L)) = 3^j · 2^{m(L)-j} - 1`. -/
def closedWitnessValue (L j : Nat) : Nat :=
  3 ^ j * 2 ^ (witnessExponent L - j) - 1

/-- Syracuse-Odd-Schritt (Alias für `oddCoreStep`). -/
abbrev tOdd (n : Nat) : Nat := oddCoreStep n

/-- `[A]` Der Witness-Exponent ist stets ungerade. -/
theorem witnessExponent_odd (L : Nat) : witnessExponent L % 2 = 1 := by
  dsimp [witnessExponent]
  omega

/-- `[A]` Lange Läufe brauchen strikt größeren Exponenten: `L < m(L)`. -/
theorem witnessExponent_gt (L : Nat) : L < witnessExponent L := by
  dsimp [witnessExponent]
  omega

/--
Robuste mod-6-Witness-Exponentenfunktion (Legacy):
`m(L) = L+1` bei geradem `L`, sonst `L+2`. Stets ungerade, `2^m(L)-1 ≡ 1 (mod 6)`.
Abweichend von `witnessExponent` bei geradem `L ≥ 2`; nur noch für mod-6-Skizzen.
-/
def mersenneOddExponent (L : Nat) : Nat :=
  if L % 2 = 0 then L + 1 else L + 2

/-- Legacy-Mersenne-Start `2^m(L) - 1` (mod-6-robust, siehe `witnessStart`). -/
def mersenneOdd (L : Nat) : Nat :=
  2 ^ mersenneOddExponent L - 1

theorem mersenneOdd_eq_witnessStart_zero (L : Nat) (hL : L = 0) :
    mersenneOdd L = witnessStart L := by
  subst hL
  rfl

theorem mersenneOdd_eq_witnessStart_one (L : Nat) (hL : L = 1) :
    mersenneOdd L = witnessStart L := by
  subst hL
  rfl

/-- Restklasse `U_6`: ungerade Starts mit `n ≡ 1 (mod 6)` (äquivalent `Nat.Coprime n 6`). -/
def collatzMod6U6 (n : Nat) : Prop :=
  n % 6 = 1

/-- Log-Verhältnis eines Odd-Core-Schritts: `log(S(n)/n)`. -/
def oddCoreStepLogRatio (n : Nat) : ℝ :=
  Real.log ((oddCoreStep n : ℝ) / n)

/-- Kumulatives Log-Verhältnis über `k` Odd-Core-Schritte. -/
def oddCoreIterate_log_ratio (k : Nat) (n : Nat) : ℝ :=
  Real.log ((oddCoreIterate k n : ℝ) / n)

/-- `[A]` Odd-Core-Schritt als Division durch `2^ν₂(3n+1)`. -/
theorem oddCoreStep_eq_div_padicVal (m : Nat) :
    oddCoreStep m =
      (3 * m + 1) / 2 ^ padicValNat 2 (3 * m + 1) := by
  unfold oddCoreStep oddCore
  simp only [Nat.factorization_def (3 * m + 1) Nat.prime_two]

/-- `[A]` Odd-Core-Schritt als Bruch `n ↦ (3n+1) / (2^ν₂ · n)` (für `n > 0`). -/
theorem oddCoreStep_div_eq (n : Nat) (hn : 0 < n) :
    (oddCoreStep n : ℝ) / n =
      (3 * n + 1 : ℝ) /
        ((2 ^ padicValNat 2 (3 * n + 1) : ℝ) * n) := by
  have hkick : 0 < 3 * n + 1 := by omega
  have hν_dvd : 2 ^ padicValNat 2 (3 * n + 1) ∣ 3 * n + 1 := pow_padicValNat_dvd
  rw [oddCoreStep_eq_div_padicVal n]
  rw [Nat.cast_div hν_dvd]
  · have hn0 : (n : ℝ) ≠ 0 := by exact_mod_cast hn.ne'
    have hk0 : (2 ^ padicValNat 2 (3 * n + 1) : ℝ) ≠ 0 := by positivity
    field_simp [hn0, hk0]
    ring_nf
    push_cast
    ring
  · positivity

/-!
### Modul O3 — Oktonionischer Lift `[A/B]` scaffold
-/

/-- Oktonionischer Collatz-Zustand: ungerader Kern plus Slice-Koordinaten `(μ, Q)`. -/
structure OctCollatzState where
  odd : Nat
  mu : ℝ
  Q : ℝ

/-- Hebt einen positiven ungeraden Kern in den Slice-Raum. -/
def liftOdd (n : Nat) : OctCollatzState where
  odd := n
  mu := sliceTrace ((n : ℝ) / 3)
  Q := Real.sqrt ((n : ℝ) / 3)

/-- Projektion auf den ungeraden Kern. -/
def projectOdd (s : OctCollatzState) : Nat :=
  s.odd

/-- Ein Odd-Core-Schritt im oktonionischen Zustandsraum. -/
def octOddStep (s : OctCollatzState) : OctCollatzState :=
  let n' := oddCoreStep s.odd
  { odd := n'
    mu := sliceTrace ((n' : ℝ) / 3)
    Q := Real.sqrt ((n' : ℝ) / 3) }

/-- `[A]` Der Lift respektiert den ungeraden Kern. -/
theorem liftOdd_project (n : Nat) :
    projectOdd (liftOdd n) = n := by
  rfl

/-- `[A]` Oktonionischer Schritt fällt mit `oddCoreStep` zusammen. -/
theorem octOddStep_intertwines (s : OctCollatzState) :
    projectOdd (octOddStep s) = oddCoreStep (projectOdd s) := by
  rfl

end

end KeplerHurwitz.Collatz.Octonion
