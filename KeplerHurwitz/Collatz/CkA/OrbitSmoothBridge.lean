import Mathlib
import KeplerHurwitz.CyclicWordOrbit
import KeplerHurwitz.SmoothAttraktor

namespace KeplerHurwitz.CkA

/--
Defensiver Orbit-Traeger fuer die Brueckenschicht:
ein Startwort und eine endliche Orbit-Approximation.
-/
structure CyclicWordOrbit where
  seed : List Nat
  steps : Nat
  carrier : List (List Nat) := KeplerHurwitz.orbitPrefix seed steps

/--
Ein Orbit hat einen `B`-glatten Repraesentanten, bezogen auf eine Kodierung
vom Wortraum in natuerliche Werte.
-/
def OrbitHasSmoothRepresentative
    (encode : List Nat → Nat)
    (B : Nat)
    (O : CyclicWordOrbit) : Prop :=
  ∃ x ∈ O.carrier, IsBSmooth B (encode x)

/--
Alle repraesentierten Orbitwerte sind `B`-glatt.
-/
def OrbitAllSmooth
    (encode : List Nat → Nat)
    (B : Nat)
    (O : CyclicWordOrbit) : Prop :=
  ∀ x, x ∈ O.carrier → IsBSmooth B (encode x)

/--
Konkretes Profil fuer bereits extrahierte numerische Orbitwerte.
-/
structure OrbitSmoothProfile where
  orbit : CyclicWordOrbit
  B : Nat
  values : List Nat
  all_smooth : ∀ x, x ∈ values → IsBSmooth B x

/--
Optionale Hypothesen-Schnittstelle fuer spaetere statistische Bias-Saetze.
Noch bewusst ohne inhaltliche Last.
-/
def OrbitSmoothBiasHypothesis : Prop := True

theorem orbit_has_smooth_rep_mono
    {encode : List Nat → Nat}
    {B B' : Nat}
    {O : CyclicWordOrbit}
    (hB : B ≤ B')
    (h : OrbitHasSmoothRepresentative encode B O) :
    OrbitHasSmoothRepresentative encode B' O := by
  rcases h with ⟨x, hx, hs⟩
  exact ⟨x, hx, IsBSmooth_mono hB hs⟩

theorem profile_member_smooth_of_dvd
    {P : OrbitSmoothProfile}
    {x d : Nat}
    (hx : x ∈ P.values)
    (hd : d ∣ x) :
    IsBSmooth P.B d := by
  exact IsBSmooth_of_dvd (P.all_smooth x hx) hd

theorem profile_member_mul_smooth
    {P : OrbitSmoothProfile}
    {x y : Nat}
    (hx : x ∈ P.values)
    (hy : y ∈ P.values) :
    IsBSmooth P.B (x * y) := by
  exact IsBSmooth_mul (P.all_smooth x hx) (P.all_smooth y hy)

end KeplerHurwitz.CkA
