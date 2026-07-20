import Mathlib
import KeplerHurwitz.KeplerInvariants

namespace KeplerHurwitz

noncomputable section

/--
Vierkanalige EABC-Signatur als additive Zaehlschicht.
-/
structure EABCSignature4 where
  E : Nat
  A : Nat
  B : Nat
  C : Nat

namespace EABCSignature4

def totalWeight (h : EABCSignature4) : Nat :=
  h.E + h.A + h.B + h.C

def maxChannel (h : EABCSignature4) : Nat :=
  max (max h.E h.A) (max h.B h.C)

def minChannel (h : EABCSignature4) : Nat :=
  min (min h.E h.A) (min h.B h.C)

def spread (h : EABCSignature4) : Nat :=
  h.maxChannel - h.minChannel

/--
Kanonische Kepler-Exzentrizitaet `e_kep` (spread-basiert):
`spread / (totalWeight + 1)` garantiert immer `0 ≤ e_kep < 1`.

Nomenklatur: dies ist **nicht** der Normalform-E-Faktor `e` in `n = 2^α 3^β r e`
und **nicht** der Kanalzaehler `E` in `H(n) = (E,A,B,C)`.
Siehe `docs/eabc_normal_form.md` §7.
-/
def eccentricity (h : EABCSignature4) : ℝ :=
  (h.spread : ℝ) / ((h.totalWeight : ℝ) + 1)

/--
Defensive Semimajor-Achse aus dem Gesamtgewicht: `a = totalWeight / 4`.
-/
def semimajorAxis (h : EABCSignature4) : ℝ :=
  (h.totalWeight : ℝ) / 4

theorem spread_le_totalWeight (h : EABCSignature4) :
    h.spread ≤ h.totalWeight := by
  unfold spread maxChannel minChannel totalWeight
  omega

theorem eccentricity_nonneg (h : EABCSignature4) :
    0 ≤ h.eccentricity := by
  unfold eccentricity
  exact div_nonneg (Nat.cast_nonneg h.spread) (by positivity)

theorem eccentricity_lt_one (h : EABCSignature4) :
    h.eccentricity < 1 := by
  unfold eccentricity
  have hle : (h.spread : ℝ) ≤ (h.totalWeight : ℝ) := by
    exact_mod_cast h.spread_le_totalWeight
  have hlt : (h.spread : ℝ) < (h.totalWeight : ℝ) + 1 := by
    linarith
  have hden : 0 < (h.totalWeight : ℝ) + 1 := by positivity
  exact (div_lt_one hden).2 hlt

end EABCSignature4

/--
Zielsignatur der geometrischen Projektion `H → (a, e_kep, R_v)`.

Das Feld `e` ist semantisch die Kepler-Exzentrizitaet `e_kep` (nicht der E-Faktor).
-/
structure EABCKeplerProjection where
  a : ℝ
  /-- Kepler-Exzentrizitaet `e_kep` (spread / (M+1)); nicht Normalform-E-Faktor. -/
  e : ℝ
  Rv : ℝ

/--
Formale API-Projektion vom EABC-Kanalvektor auf Kepler-Groessen `(a, e_kep, R_v)`.
Kanonische Formel: `a = M/4`, `e_kep = spread/(M+1)`, `R_v = (1+e_kep)/(1-e_kep)`.
-/
def projectToKepler (h : EABCSignature4) : EABCKeplerProjection :=
  { a := h.semimajorAxis
    e := h.eccentricity
    Rv := radiusRatio h.eccentricity }

theorem projectToKepler_Rv_eq_radiusRatio (h : EABCSignature4) :
    (projectToKepler h).Rv = radiusRatio (projectToKepler h).e := by
  rfl

theorem projectToKepler_e_bounds (h : EABCSignature4) :
    0 ≤ (projectToKepler h).e ∧ (projectToKepler h).e < 1 := by
  exact ⟨h.eccentricity_nonneg, h.eccentricity_lt_one⟩

end
end KeplerHurwitz
