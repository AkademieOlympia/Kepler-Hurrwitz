import Mathlib

namespace KeplerHurwitz

open Polynomial

noncomputable section

/--
Das in Sage berechnete Resultanten-Polynom in `mu`:

`-24*mu^2 - 60*mu`.
-/
def resultantMu : Polynomial ℚ :=
  C (-24) * X ^ 2 + C (-60) * X

/--
Das in Sage berechnete Resultanten-Polynom in `Q`:

`576*Q^4 - 2160*Q^2`.
-/
def resultantQ : Polynomial ℚ :=
  C 576 * X ^ 4 + C (-2160) * X ^ 2

/--
Reduzierte Resultante in `S = Q^2`:

`576*S^2 - 2160*S`.
-/
def resultantS : Polynomial ℚ :=
  C 576 * X ^ 2 + C (-2160) * X

theorem resultantMu_zero_at_interference :
    eval (-((5 : ℚ) / 2)) resultantMu = 0 := by
  simp [resultantMu]
  ring

theorem resultantS_zero_at_interference :
    eval ((15 : ℚ) / 4) resultantS = 0 := by
  simp [resultantS]
  ring

/--
Die geometrischen Interferenzwerte `Q = ±sqrt(15)/2` entsprechen
algebraisch exakt der rationalen Bedingung `S = Q^2 = 15/4`.
-/
theorem resultantQ_eval_via_square (q : ℚ) :
    eval q resultantQ = eval (q ^ 2) resultantS := by
  simp [resultantQ, resultantS]
  ring

/--
Das kombinierte Interferenz-Prädikat:
`(mu, S) = (-5/2, 15/4)` ist simultane Nullstelle beider Resultanten.
-/
theorem interference_point_simultaneous_zero :
    eval (-((5 : ℚ) / 2)) resultantMu = 0 ∧
      eval ((15 : ℚ) / 4) resultantS = 0 := by
  exact ⟨resultantMu_zero_at_interference, resultantS_zero_at_interference⟩

/--
Formaler, zertifizierter Interferenzpunkt im `(mu,S)`-Raum.
Gueltigkeit ist durch die simultanen Resultanten-Nullstellen erzwungen.
-/
structure InterferencePoint where
  mu : ℚ
  s : ℚ
  h_mu_zero : eval mu resultantMu = 0
  h_s_zero : eval s resultantS = 0

/--
Kanonischer Interferenzpunkt der Grigorian-Slice-Geometrie.
-/
def canonicalInterferencePoint : InterferencePoint where
  mu := -((5 : ℚ) / 2)
  s := (15 : ℚ) / 4
  h_mu_zero := resultantMu_zero_at_interference
  h_s_zero := resultantS_zero_at_interference

end
end KeplerHurwitz
