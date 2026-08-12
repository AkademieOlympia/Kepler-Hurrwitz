import Mathlib
import KeplerHurwitz.OddCore
import KeplerHurwitz.OddCoreDynamics

/-!
Post-freeze oktonionischer Collatz-Beweisversuch — Basisschicht.

Governance: außerhalb `audit-freeze-2026`; keine Änderung an ι_n, ε_n oder frozen dossier.
Status-Tags: `[A]` bewiesen, `[B]` empirisch, `[C]` offen.

Modul O3 trägt den diskreten EABC/Fano-Zustandsraum; die echte oktonionische
Rotationsdynamik der Fano-Knoten bleibt Frontier für O4/O5.
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
### Modul O3 — Der Oktonionische Lift `[A/C]` scaffold

Zustandsraum: zahlentheoretische Restklassen (Schicht 2–3) plus chirale
Orientierung auf der Fano-Ebene (Schicht 4). Die Projektion `projectOdd`
bildet ein kommutatives Diagramm mit `oddCoreStep`; die Fano-Rotation selbst
ist vorerst Identitäts-Transport (O4).
-/

/-- Die diskreten Modulo-12-Klassen des EABC-Modells. -/
inductive EABCClass
  | E  -- p ≡ 11 (mod 12)
  | A  -- p ≡ 1  (mod 12)
  | B  -- p ≡ 5  (mod 12)
  | C  -- p ≡ 7  (mod 12) und übrige ungerade Reste
  deriving DecidableEq, Repr

/-- Dummy-Struktur für die ganzzahligen Hurwitz-Oktonionen (Fano-Schnittstelle). -/
structure IntegralOctonion where
  real : ℤ
  imag : Fin 7 → ℤ
  deriving Repr

/-- Standard-Nulloktonion (keine ausgezeichnete Fano-Achse). -/
def IntegralOctonion.zero : IntegralOctonion where
  real := 0
  imag := fun _ => 0

/-- EABC-Klasse aus der Restklasse modulo 12. -/
def eabcClassOf (n : Nat) : EABCClass :=
  if n % 12 = 11 then EABCClass.E
  else if n % 12 = 1 then EABCClass.A
  else if n % 12 = 5 then EABCClass.B
  else EABCClass.C

/--
Ungerade Zahlen `n` haben `n % 8 ∈ {1,3,5,7}`; die Abbildung `(n % 8) / 2`
landet in `Fin 4` und steuert die 2-adische Verzweigung.
-/
def residue8OfOdd (n : Nat) (_h_odd : n % 2 = 1) : Fin 4 :=
  ⟨(n % 8) / 2, by
    have hlt : n % 8 < 8 := Nat.mod_lt n (by decide : 0 < 8)
    exact Nat.div_lt_of_lt_mul hlt⟩

/--
Der vollständige, erweiterte Zustandsraum des Lifts.
Er trägt sowohl die rein zahlentheoretischen Restklassen (Schicht 2–3)
als auch die chirale Positionierung auf der Fano-Ebene (Schicht 4).
-/
structure OctCollatzState where
  value : Nat
  is_odd : value % 2 = 1
  residue8 : Fin 4             -- Verzweigungssteuerung via (n mod 8)/2
  residue12 : EABCClass         -- EABC-Phase mod 12
  valuation : Nat               -- padicValNat 2 (3*n + 1) am aktuellen Kern
  shell : Nat                   -- lokaler Schalenindex im Gitter (n / 12)
  octDirection : IntegralOctonion  -- Achsen-Orientierung auf der Fano-Ebene
  deriving Repr

/-- Einbettung einer ungeraden Zahl in den erweiterten oktonionischen Zustand. -/
def liftOdd (n : Nat) (h_odd : n % 2 = 1)
    (oct_init : IntegralOctonion := .zero) : OctCollatzState where
  value := n
  is_odd := h_odd
  residue8 := residue8OfOdd n h_odd
  residue12 := eabcClassOf n
  valuation := padicValNat 2 (3 * n + 1)
  shell := n / 12
  octDirection := oct_init

/-- Projektion zurück auf die natürlichen Zahlen (ungerader Kern). -/
def projectOdd (state : OctCollatzState) : Nat :=
  state.value

/--
Oktonionische Zustands-Schrittfunktion.

Arithmetischer Kern: voller `oddCoreStep` plus Restklassen- und Valuations-Refresh.
Fano-Richtung: Identitäts-Transport — echte Multiplikationsregeln der sieben
imaginären Einheiten e₁ … e₇ sind Modul-O4-Frontier.
-/
def octOddStep (state : OctCollatzState) : OctCollatzState :=
  let n' := oddCoreStep state.value
  let h' : n' % 2 = 1 := oddCoreStep_mod2_eq_one state.value
  { value := n'
    is_odd := h'
    residue8 := residue8OfOdd n' h'
    residue12 := eabcClassOf n'
    valuation := padicValNat 2 (3 * n' + 1)
    shell := n' / 12
    octDirection := state.octDirection }

/-- `[A]` Der Lift respektiert den ungeraden Kern. -/
theorem liftOdd_project (n : Nat) (h_odd : n % 2 = 1)
    (oct_init : IntegralOctonion := .zero) :
    projectOdd (liftOdd n h_odd oct_init) = n := by
  rfl

/--
`[A]` Theorem (`octOddStep_intertwines`):
Der oktonionische Lift bildet ein kommutatives Diagramm mit dem Collatz-Fluss.
Die Projektion des Lifts ist exakt der reine Odd-Core-Schritt.
-/
theorem octOddStep_intertwines (state : OctCollatzState) :
    projectOdd (octOddStep state) = oddCoreStep (projectOdd state) := by
  rfl

/--
`[A]` Spezialform: Lift eines ungeraden Kerns, ein oktonionischer Schritt,
dann Projektion — identisch zu `oddCoreStep n`.
-/
theorem octOddStep_intertwines_lift (n : Nat) (h_odd : n % 2 = 1)
    (oct_init : IntegralOctonion := .zero) :
    projectOdd (octOddStep (liftOdd n h_odd oct_init)) = oddCoreStep n := by
  rfl

end

end KeplerHurwitz.Collatz.Octonion
