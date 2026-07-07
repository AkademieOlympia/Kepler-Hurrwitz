import Mathlib
import KeplerHurwitz.PhaseninvarianzEnergy

namespace KeplerHurwitz

/-!
## Phaseninvarianz — Kreuzfeld-Crosstalk [A]

Algebraische Fakten zur Energiedifferenz unter partiellem bx↔cx-Tausch:
`ΔE = (bx^2 - cx^2)(cy^2 - by^2)`.

Defensiv: keine Primzahl- oder QEC-Lesesprache; nur Faktorisierung und Nullfaelle.
Python-Parität: `src/kepler_hurwitz/phaseninvarianz_crosstalk.py`.
-/

/--
Faktorisierte Crosstalk-Energiedifferenz (bx↔cx Partial-Swap).
-/
def crosstalkDelta (bx b_y cx cy : ℝ) : ℝ :=
  (bx ^ 2 - cx ^ 2) * (cy ^ 2 - b_y ^ 2)

/--
Vier-Term-Expansion von `ΔE` (Kreuzterme von `E_b · E_c` nach Partial-Swap).
-/
def crosstalkDeltaExpanded (bx b_y cx cy : ℝ) : ℝ :=
  bx ^ 2 * cy ^ 2 + b_y ^ 2 * cx ^ 2 - cx ^ 2 * cy ^ 2 - bx ^ 2 * b_y ^ 2

theorem crosstalkDelta_eq_expanded (bx b_y cx cy : ℝ) :
    crosstalkDelta bx b_y cx cy = crosstalkDeltaExpanded bx b_y cx cy := by
  unfold crosstalkDelta crosstalkDeltaExpanded
  ring

theorem crosstalkDelta_eq_zero_of_bx_eq_cx (bx b_y cx cy : ℝ) (h : bx = cx) :
    crosstalkDelta bx b_y cx cy = 0 := by
  unfold crosstalkDelta
  simp [h, sub_self]

theorem crosstalkDelta_eq_zero_of_b_y_eq_cy (bx b_y cx cy : ℝ) (h : b_y = cy) :
    crosstalkDelta bx b_y cx cy = 0 := by
  unfold crosstalkDelta
  simp [h, sub_self]

/--
Fermat-Faktorisierung: `bx^2 - cx^2 = (bx - cx)(bx + cx)`.
-/
theorem sq_sub_sq_bx_cx (bx cx : ℝ) :
    bx ^ 2 - cx ^ 2 = (bx - cx) * (bx + cx) := by
  rw [sq_sub_sq bx cx]
  ring

theorem sq_sub_sq_cy_b_y (cy b_y : ℝ) :
    cy ^ 2 - b_y ^ 2 = (cy - b_y) * (cy + b_y) := by
  rw [sq_sub_sq cy b_y]
  ring

/--
Crosstalk-Delta als Produkt der Fermat-Faktoren.
-/
theorem crosstalkDelta_fermat_factorization (bx b_y cx cy : ℝ) :
    crosstalkDelta bx b_y cx cy =
      (bx - cx) * (bx + cx) * (cy - b_y) * (cy + b_y) := by
  unfold crosstalkDelta
  rw [sq_sub_sq_bx_cx, sq_sub_sq_cy_b_y]
  ring

end KeplerHurwitz
