import Mathlib
import KeplerHurwitz.KeplerInvariants
import KeplerHurwitz.PhotonModel

namespace KeplerHurwitz

/--
Monotonie des Kepler-Radialverhaeltnisses in der Exzentrizitaet
auf dem physikalisch relevanten Bereich `0 <= e < 1`.
-/
theorem radiusRatio_lt_of_e_lt
    {e1 e2 : ℝ}
    (he2_1 : e2 < 1)
    (h12 : e1 < e2) :
    radiusRatio e1 < radiusRatio e2 := by
  unfold radiusRatio
  have hd1 : 0 < 1 - e1 := by linarith
  have hd2 : 0 < 1 - e2 := by linarith
  refine (div_lt_div_iff₀ hd1 hd2).2 ?_
  nlinarith

/--
Bei fixer positiver Wellenlaenge steigt die Frequenz mit `c`
in der Dispersionsbeziehung `nu * lambda = c`.
-/
theorem frequency_lt_of_c_lt_fixed_wavelength
    {nu1 nu2 l c1 c2 : ℝ}
    (hl : 0 < l)
    (h1 : nu1 * l = c1) (h2 : nu2 * l = c2)
    (hc : c1 < c2) :
    nu1 < nu2 := by
  have hmul : nu1 * l < nu2 * l := by simpa [h1, h2] using hc
  exact lt_of_mul_lt_mul_right hmul hl.le

/--
Bei fixer positiver Frequenz steigt die Wellenlaenge mit `c`
in der Dispersionsbeziehung `nu * lambda = c`.
-/
theorem wavelength_lt_of_c_lt_fixed_frequency
    {nu l1 l2 c1 c2 : ℝ}
    (hnu : 0 < nu)
    (h1 : nu * l1 = c1) (h2 : nu * l2 = c2)
    (hc : c1 < c2) :
    l1 < l2 := by
  have hmul : nu * l1 < nu * l2 := by simpa [h1, h2] using hc
  exact lt_of_mul_lt_mul_left hmul hnu.le

/--
Geometrie-Rotverschiebung (Frequenzseite):
Wenn `e1 < e2` und die Wellenlaenge fix ist, steigt die Frequenz.
-/
theorem frequency_lt_of_e_lt_fixed_wavelength
    {e1 e2 nu1 nu2 l : ℝ}
    (he2_1 : e2 < 1)
    (h12 : e1 < e2)
    (hl : 0 < l)
    (h1 : nu1 * l = radiusRatio e1)
    (h2 : nu2 * l = radiusRatio e2) :
    nu1 < nu2 := by
  apply frequency_lt_of_c_lt_fixed_wavelength hl h1 h2
  exact radiusRatio_lt_of_e_lt he2_1 h12

/--
Geometrie-Rotverschiebung (Wellenlaengenseite):
Wenn `e1 < e2` und die Frequenz fix ist, steigt die Wellenlaenge.
-/
theorem wavelength_lt_of_e_lt_fixed_frequency
    {e1 e2 nu l1 l2 : ℝ}
    (he2_1 : e2 < 1)
    (h12 : e1 < e2)
    (hnu : 0 < nu)
    (h1 : nu * l1 = radiusRatio e1)
    (h2 : nu * l2 = radiusRatio e2) :
    l1 < l2 := by
  apply wavelength_lt_of_c_lt_fixed_frequency hnu h1 h2
  exact radiusRatio_lt_of_e_lt he2_1 h12

end KeplerHurwitz
