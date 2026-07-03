import Mathlib

namespace KeplerHurwitz

noncomputable section

/-- Kepler-Radialverhältnis aus der Exzentrizität. -/
def radiusRatio (e : ℝ) : ℝ := (1 + e) / (1 - e)

/-- Normierte Perihel-Geschwindigkeit. -/
def perihelionSpeed (a e : ℝ) : ℝ :=
  Real.sqrt ((1 + e) / (a * (1 - e)))

/-- Normierte Aphel-Geschwindigkeit. -/
def aphelionSpeed (a e : ℝ) : ℝ :=
  Real.sqrt ((1 - e) / (a * (1 + e)))

/--
Kepler-Hauptrelation:
Unter den Standardannahmen `0 < a`, `0 ≤ e < 1` ist das Radialverhältnis
gleich dem Geschwindigkeitsverhältnis.
-/
theorem radiusRatio_eq_speedRatio (ha : 0 < a) (he0 : 0 ≤ e) (he1 : e < 1) :
    radiusRatio e = perihelionSpeed a e / aphelionSpeed a e := by
  have ha0 : a ≠ 0 := ne_of_gt ha
  have hsub : 1 - e ≠ 0 := by linarith
  have hadd : 1 + e ≠ 0 := by linarith
  have hden_pos : 0 < a * (1 - e) := by
    apply mul_pos ha
    linarith
  have hnum_nonneg : 0 ≤ (1 + e) / (a * (1 - e)) := by
    exact div_nonneg (by linarith) hden_pos.le
  unfold radiusRatio perihelionSpeed aphelionSpeed
  rw [← Real.sqrt_div hnum_nonneg]
  have hinside :
      ((1 + e) / (a * (1 - e))) / ((1 - e) / (a * (1 + e))) =
        ((1 + e) / (1 - e)) ^ 2 := by
    field_simp [ha0, hsub, hadd]
  rw [hinside, Real.sqrt_sq_eq_abs]
  have hratio_nonneg : 0 ≤ (1 + e) / (1 - e) := by
    apply div_nonneg <;> linarith
  simp [abs_of_nonneg hratio_nonneg]

end
end KeplerHurwitz
