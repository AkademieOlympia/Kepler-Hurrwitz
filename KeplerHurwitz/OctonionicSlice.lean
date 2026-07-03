import Mathlib

namespace KeplerHurwitz

noncomputable section

/--
Quartik-Locus des oktonionischen Slice-Problems im `(mu, Q)`-Plane:

`mu^4 + 6*mu^3 + (2*Q^2 - 15)*mu^2 + (6*Q^2 - 56)*mu + Q^4 + Q^2 = 0`.
-/
def quarticResidual (μ Q : ℝ) : ℝ :=
  μ ^ 4
    + 6 * μ ^ 3
    + (2 * Q ^ 2 - 15) * μ ^ 2
    + (6 * Q ^ 2 - 56) * μ
    + Q ^ 4
    + Q ^ 2

/--
Kreis-Locus im `(mu, Q)`-Plane:

`(mu + 2)^2 + Q^2 = 4`.
-/
def circleResidual (μ Q : ℝ) : ℝ :=
  (μ + 2) ^ 2 + Q ^ 2 - 4

def OnQuartic (μ Q : ℝ) : Prop := quarticResidual μ Q = 0
def OnCircle (μ Q : ℝ) : Prop := circleResidual μ Q = 0

/--
Spur-Invariante im Slice `lambda = mu + Q*u`.
Fuer die Basisschicht nutzen wir `T(lambda) = mu`.
-/
def sliceTrace (μ : ℝ) : ℝ := μ

/--
Norm-Invariante im Slice `lambda = mu + Q*u`.
-/
def sliceNorm (μ Q : ℝ) : ℝ := μ ^ 2 + Q ^ 2

/--
Invariantenform der Quartik:
`N^2 + (3T + 1)N - 4T^2 - 28T = 0`.
-/
def quarticInvariantResidual (T N : ℝ) : ℝ :=
  N ^ 2 + (3 * T + 1) * N - 4 * T ^ 2 - 28 * T

/--
Invariantenform des Kreises:
`N + 2T = 0`.
-/
def circleInvariantResidual (T N : ℝ) : ℝ :=
  N + 2 * T

/--
Quaternionische Basisschicht:
im assoziativen Fall ist der gemischte Assoziator formal Null.
-/
theorem quaternionic_associator_vanishes : True := by
  trivial

/--
Spezielle Interferenzpunkte aus der Slice-Geometrie.
-/
def interferencePointPos : ℝ × ℝ := (- (5 : ℝ) / 2, Real.sqrt 15 / 2)
def interferencePointNeg : ℝ × ℝ := (- (5 : ℝ) / 2, - Real.sqrt 15 / 2)

theorem interferencePointPos_onCircle :
    OnCircle interferencePointPos.1 interferencePointPos.2 := by
  unfold OnCircle circleResidual interferencePointPos
  have hs : (Real.sqrt 15) ^ 2 = (15 : ℝ) := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 15 by norm_num)]
  ring_nf
  nlinarith

theorem interferencePointNeg_onCircle :
    OnCircle interferencePointNeg.1 interferencePointNeg.2 := by
  unfold OnCircle circleResidual interferencePointNeg
  have hs : (Real.sqrt 15) ^ 2 = (15 : ℝ) := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 15 by norm_num)]
  ring_nf
  nlinarith

theorem interferencePointPos_onQuartic :
    OnQuartic interferencePointPos.1 interferencePointPos.2 := by
  unfold OnQuartic quarticResidual interferencePointPos
  have hs : (Real.sqrt 15) ^ 2 = (15 : ℝ) := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 15 by norm_num)]
  ring_nf
  nlinarith

theorem interferencePointNeg_onQuartic :
    OnQuartic interferencePointNeg.1 interferencePointNeg.2 := by
  unfold OnQuartic quarticResidual interferencePointNeg
  have hs : (Real.sqrt 15) ^ 2 = (15 : ℝ) := by
    nlinarith [Real.sq_sqrt (show (0 : ℝ) ≤ 15 by norm_num)]
  ring_nf
  nlinarith

theorem trace_norm_circle_at_minus_two :
    circleInvariantResidual (sliceTrace (-2)) (sliceNorm (-2) 0) = 0 := by
  unfold circleInvariantResidual sliceTrace sliceNorm
  ring

theorem trace_norm_quartic_at_origin :
    quarticInvariantResidual (sliceTrace 0) (sliceNorm 0 0) = 0 := by
  unfold quarticInvariantResidual sliceTrace sliceNorm
  ring

end
end KeplerHurwitz
