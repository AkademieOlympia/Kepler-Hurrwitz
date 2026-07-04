import Mathlib
import KeplerHurwitz.PrimvierlingSymmetry

namespace KeplerHurwitz

open Filter EABCChannel

/-!
## Chebyshev mod-4 bias interface (E-050)

Rubinstein–Sarnak-Stil: globales Dirichlet-Rennen `π(x;4,3)` vs. `π(x;4,1)`.
Schicht `[C]` — getrennt von der endlichen Kombinatorik des Dumas-Lemmas (E-048).

Dokumentation: `docs/chebyshev_bias_interface.md`.
-/

/-- Ungerade Primzahlen `p` mit `2 < p ≤ x`. -/
def oddPrimesBelow (x : Nat) : Finset Nat :=
  (Finset.Ioc (2 : Nat) x).filter Nat.Prime

/--
Anzahl ungerader Primzahlen `p ≤ x` mit `p ≡ a (mod 4)` (`a = 1` oder `3`).
Der einzige Primteiler `2` wird ausgeschlossen.
-/
def pi_mod4 (a : Nat) (x : Nat) : Nat :=
  ((oddPrimesBelow x).filter (fun p => p % 4 = a)).card

/-- Chebyshev-Bias-Differenz `π(x;4,3) − π(x;4,1)` als `Int`. -/
def chebyshevBiasDifference (x : Nat) : Int :=
  (pi_mod4 3 x : Int) - (pi_mod4 1 x : Int)

def chebyshevBiasStrictlyPositive (x : Nat) : Prop :=
  0 < chebyshevBiasDifference x

def chebyshevBiasStrictlyNegative (x : Nat) : Prop :=
  chebyshevBiasDifference x < 0

/-- Vorzeichen der Bias-Differenz (`−1`, `0`, `1`). -/
def chebyshevBiasSign (x : Nat) : Int :=
  Int.sign (chebyshevBiasDifference x)

def chebyshevBiasSignChangeBetween (x y : Nat) : Prop :=
  x < y ∧
    ((chebyshevBiasStrictlyPositive x ∧ chebyshevBiasStrictlyNegative y) ∨
      (chebyshevBiasStrictlyNegative x ∧ chebyshevBiasStrictlyPositive y))

/-!
### [C] Hypothesen-Schicht (nicht bewiesen in diesem Repo)
-/

/--
[C] Klassischer Chebyshev-Bias: fuer fast alle grossen `x` gilt `π(x;4,3) > π(x;4,1)`.
Rubinstein–Sarnak (mod `GRH`): asymptotische Ueberlegenheit der Residuenklasse `3 mod 4`.
-/
def ChebyshevBiasMostlyThreeModFour : Prop :=
  ∀ᶠ x in atTop, chebyshevBiasStrictlyPositive x

/--
[C] Unendlich oft Vorzeichenwechsel der mod-4-Differenz entlang `x`.
Unter `GRH` klassisch; hier nur als offene Schnittstelle.
-/
def ChebyshevBiasSignChangesInfinitelyOften : Prop :=
  ∀ N, ∃ x y, chebyshevBiasSignChangeBetween x y ∧ N < x

/--
[C] Generalized Riemann Hypothesis — reiner Schnittstellenmarker (nicht formalisiert).
-/
def GeneralizedRiemannHypothesis : Prop :=
  True

/--
[C] Dokumentierte Implikationsschnittstelle: `GRH` → unendlich oft Vorzeichenwechsel.
Nicht bewiesen; verweist auf die analytische Zahlentheorie-Literatur.
-/
def GRHImpliesChebyshevBiasSignChanges : Prop :=
  GeneralizedRiemannHypothesis → ChebyshevBiasSignChangesInfinitelyOften

/--
[C] Dokumentierte Implikationsschnittstelle: `GRH` → Bias + Vorzeichenwechsel.
-/
def GRHImpliesChebyshevBias : Prop :=
  GeneralizedRiemannHypothesis →
    ChebyshevBiasSignChangesInfinitelyOften ∧ ChebyshevBiasMostlyThreeModFour

/-!
### [C] Bruecke zu Dumas / Primquadruplet (offen, kein Beweis)
-/

def primeQuadrupletMod4Residue (q : PrimeQuadruplet) : Finset Nat :=
  {q.p % 4, (q.p + 2) % 4, (q.p + 6) % 4, (q.p + 8) % 4}

def primvierlingMod4Residues (v : Primvierling) : Finset Nat :=
  let (a, b, c, e) := v
  {a % 4, b % 4, c % 4, e % 4}

/--
[C] Offene Brueckenschnittstelle Dumas ↔ globales mod-4-Rennen.

Eine kuenftige Bruecke muesste Host-Komponenten-Rollen (`hostComponent`) und
lokale mod-4-Profile kanonischer Primquadruplet `(p,p+2,p+6,p+8)` mit der
kumulativen Chebyshev-Differenz entlang `x` in Beziehung setzen.
Kein Bestandteil von E-048; kein Beweis der Primquadruplet-Unendlichkeit.
-/
def ChebyshevDumasInterface : Prop :=
  ∀ (_q : PrimeQuadruplet) (_hp : _q.p > 3) (host : EABCChannel),
    let v := _q.toPrimvierling
    hostComponent host v % 4 = 1 ∨ hostComponent host v % 4 = 3

/-!
### Bewiesene endliche Kombinatorik (ohne analytische Zahlentheorie)
-/

theorem oddPrimesBelow_subset (x : Nat) : oddPrimesBelow x ⊆ Finset.Ioc (2 : Nat) x := by
  intro p hp
  exact (Finset.mem_filter.mp hp).1

theorem pi_mod4_le_oddPrimesBelow (a x : Nat) :
    pi_mod4 a x ≤ (oddPrimesBelow x).card := by
  unfold pi_mod4
  exact Finset.card_filter_le _ _

theorem chebyshevBiasDifference_self (x : Nat) :
    chebyshevBiasDifference x = (pi_mod4 3 x : Int) - (pi_mod4 1 x : Int) := rfl

theorem chebyshevBiasDifference_eq_zero_of_small (x : Nat) (hx : x ≤ 2) :
    chebyshevBiasDifference x = 0 := by
  unfold chebyshevBiasDifference pi_mod4 oddPrimesBelow
  have hem : (Finset.Ioc (2 : Nat) x) = ∅ := by
    ext p
    simp only [Finset.mem_Ioc, Finset.notMem_empty, iff_false]
    intro hp
    omega
  simp [hem]

private theorem odd_prime_mod4_one_or_three {p : Nat} (hp : Nat.Prime p) (hgt : 2 < p) :
    p % 4 = 1 ∨ p % 4 = 3 := by
  have hodd : p % 2 = 1 := by
    rcases hp.eq_two_or_odd with h2 | hodd
    · omega
    · exact hodd
  exact Nat.odd_mod_four_iff.mp hodd

theorem pi_mod4_residue_one_or_three (x : Nat) {p : Nat} (hp : p ∈ oddPrimesBelow x) :
    p % 4 = 1 ∨ p % 4 = 3 := by
  simp only [oddPrimesBelow, Finset.mem_filter, Finset.mem_Ioc] at hp
  exact odd_prime_mod4_one_or_three hp.2 hp.1.1

theorem primeQuadruplet_mod4_residue_subset (q : PrimeQuadruplet) (hp : q.p > 3) :
    primeQuadrupletMod4Residue q ⊆ ({1, 3} : Finset Nat) := by
  have hgt : 2 < q.p := by omega
  have hmod := odd_prime_mod4_one_or_three q.is_prime_p hgt
  intro r hr
  simp only [primeQuadrupletMod4Residue, Finset.mem_insert, Finset.mem_singleton] at hr ⊢
  rcases hr with hr | hr | hr | hr
  all_goals rw [hr]; rcases hmod with h1 | h3 <;> omega

theorem primvierlingMod4Residues_eq_quadruplet (q : PrimeQuadruplet) :
    primvierlingMod4Residues q.toPrimvierling = primeQuadrupletMod4Residue q := by
  ext r
  simp [primvierlingMod4Residues, primeQuadrupletMod4Residue, PrimeQuadruplet.toPrimvierling]

theorem hostComponent_mod4_one_or_three (q : PrimeQuadruplet) (hp : q.p > 3) (host : EABCChannel) :
    hostComponent host q.toPrimvierling % 4 = 1 ∨ hostComponent host q.toPrimvierling % 4 = 3 := by
  have hsub := primeQuadruplet_mod4_residue_subset q hp
  have hmem :
      hostComponent host q.toPrimvierling % 4 ∈ primeQuadrupletMod4Residue q := by
    simp only [primeQuadrupletMod4Residue, Finset.mem_insert, Finset.mem_singleton]
    rcases host with _ | _ | _ | _ <;> simp [hostComponent, PrimeQuadruplet.toPrimvierling]
  simpa using hsub hmem

theorem chebyshevDumasInterface_of_local (q : PrimeQuadruplet) (hp : q.p > 3) (host : EABCChannel) :
    hostComponent host q.toPrimvierling % 4 = 1 ∨ hostComponent host q.toPrimvierling % 4 = 3 :=
  hostComponent_mod4_one_or_three q hp host

example : chebyshevBiasDifference 2 = 0 := by
  exact chebyshevBiasDifference_eq_zero_of_small 2 (by decide)

example : primeQuadrupletMod4Residue ⟨5, by decide, by decide, by decide, by decide⟩ = {1, 3} := by
  decide

end KeplerHurwitz
