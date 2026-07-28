/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team

Gap-Hurwitz-Rotor, Period-3-Perturbation — Klassenlemma auf G_{2,4,6}.

Numerischer Kontext: Desktop `DrillingsTest.py` (`--eg-bound`).
Epistemik: Lemma 1 ist reine rationale Ungleichung (hier bewiesen).
Lemma 2–3 brauchen `Mathlib.Quaternion` / Ad_u-Dynamik (noch Scaffold).
-/

import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace KeplerHurwitz.GapRotorPeriod3

/-! ## Gap-Klasse \(G_{2,4,6}\)

Zustand \(q_n = (n, n+2, n+6, 6)\) mit festen Gaps \(2,4,6\).
Antrieb \(B(q) = R_g(q)/\sqrt{N(q)}\).
-/

/-- Vektorkomponenten von \(R_g(q_n)\) bei Gaps \((2,4,6)\). -/
noncomputable def gap246_w (n : ℝ) : ℝ × ℝ × ℝ :=
  ( (2 / 3) * n + 2
  , (3 / 4) * n + 3 / 2
  , (5 / 12) * n + 1 / 2 )

/-- Quaternion-Normquadrat \(N(q_n) = 3n^2 + 16n + 76\). -/
def gap246_normSq (n : ℝ) : ℝ :=
  3 * n ^ 2 + 16 * n + 76

/-- \(|w(n)|^2\). -/
noncomputable def gap246_wSq (n : ℝ) : ℝ :=
  let w := gap246_w n
  w.1 ^ 2 + w.2.1 ^ 2 + w.2.2 ^ 2

/--
Lemma 1 (algebraische Identität):
\(85\,N(n) - 216\,|w(n)|^2 = 16(13n + 316)\).
-/
theorem gap246_B_slack_identity (n : ℝ) :
    (85 : ℝ) * gap246_normSq n - 216 * gap246_wSq n = 16 * (13 * n + 316) := by
  unfold gap246_normSq gap246_wSq gap246_w
  ring

/--
Lemma 1: Auf \(G_{2,4,6}\) gilt
\(|B(q_n)|^2 = |w|^2 / N \le 85/216\) für alle \(n \ge 0\).

Scharf im Leading-Term: \(85N - 216|w|^2 = 16(13n+316) \ge 0\),
Asymptotik \(|B|\nearrow\sqrt{85/216}\).
-/
theorem gap246_B_sq_le (n : ℝ) (hn : 0 ≤ n) :
    gap246_wSq n / gap246_normSq n ≤ (85 : ℝ) / 216 := by
  have hNpos : 0 < gap246_normSq n := by
    unfold gap246_normSq
    nlinarith [sq_nonneg n]
  have hslack : 0 ≤ (85 : ℝ) * gap246_normSq n - 216 * gap246_wSq n := by
    rw [gap246_B_slack_identity]
    nlinarith
  have hwle : 216 * gap246_wSq n ≤ 85 * gap246_normSq n := by linarith
  have hNne : gap246_normSq n ≠ 0 := ne_of_gt hNpos
  rw [div_le_iff₀ hNpos]
  -- |w|² ≤ (85/216) N  ⇔  216 |w|² ≤ 85 N
  have : gap246_wSq n ≤ ((85 : ℝ) / 216) * gap246_normSq n := by
    have h216 : (0 : ℝ) < 216 := by norm_num
    calc
      gap246_wSq n = (216 * gap246_wSq n) / 216 := by field_simp
      _ ≤ (85 * gap246_normSq n) / 216 := by
            exact div_le_div_of_nonneg_right hwle (le_of_lt h216)
      _ = (85 / 216) * gap246_normSq n := by ring
  simpa [mul_comm] using this

/-- Asymptotische Dreiecksschranken-Konstante \(3\sqrt{85/216}\). -/
noncomputable def triangleBound : ℝ :=
  3 * Real.sqrt (85 / 216)

/-- Scharfe Asymptotik-Konstante \(\sqrt{29/24}\) (Kettenregel, n→∞; numerisch gestützt). -/
noncomputable def sharpAsympBound : ℝ :=
  Real.sqrt (29 / 24)

/-- \(C_g^\triangle = \sqrt{29/85}\) — Verhältnis scharf / Dreieck im Limit. -/
noncomputable def C_g_triangle_asymp : ℝ :=
  Real.sqrt (29 / 85)

/--
Identität der scharfen Asymptotik-Konstanten:
\(\sqrt{29/85}\cdot 3\sqrt{85/216} = \sqrt{29/24}\).
-/
theorem C_g_triangle_mul_triangle_eq_sharp :
    C_g_triangle_asymp * triangleBound = sharpAsympBound := by
  unfold C_g_triangle_asymp triangleBound sharpAsympBound
  have hL : 0 ≤ Real.sqrt (29 / 85) * (3 * Real.sqrt (85 / 216)) := by positivity
  have hR : 0 ≤ Real.sqrt (29 / 24) := by positivity
  refine (sq_eq_sq₀ hL hR).mp ?_
  have hL2 : (Real.sqrt (29 / 85) * (3 * Real.sqrt (85 / 216))) ^ 2
      = (29 : ℝ) / 24 := by
    rw [mul_pow, mul_pow, Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 29 / 85),
      Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 85 / 216)]
    field_simp
    ring
  have hR2 : (Real.sqrt (29 / 24)) ^ 2 = (29 : ℝ) / 24 :=
    Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 29 / 24)
  rw [hL2, hR2]

/-! ## Scaffold: Lemma 2–3 (noch nicht formalisiert)

Benötigt:
* `Mathlib.LinearAlgebra.Quaternion` bzw. Einheitsquaternion \(u=(1+i+j+k)/2\)
* Nachweis \(u^3 = -1\) und \(\mathrm{Ad}_u^3 = \mathrm{id}\)
* Formabbildung \(\Phi_\alpha\) und Kettenregel für \(\Phi_\alpha^3\)

Anschlüsse in bestehenden Repos:
* `eabc-renorm` / `HolonomySpin.lean`: nur Hurwitz-Schatten `{-2, 2i}`, keine \(\mathbb{H}\)-Dynamik
* `KeplerHurwitz/OctonionicSlice.lean`: `quaternionic_associator_vanishes` ist `True`-Marker
* Desktop-Numerik: `DrillingsTest.py --eg-bound` (Kettenregel \(|E_g|\to\sqrt{29/24}\))
-/

/-- Platzhalter: Orthogonalität von \(\mathrm{Ad}_u\) auf \(T S^3\). -/
def AdUOrthogonalHypothesis : Prop := True

/-- Platzhalter: \(\Phi_\alpha^3(x) = x + \alpha E_g(x) + O(\alpha^2)\) auf \(G_{2,4,6}\). -/
def Period3PerturbationHypothesis : Prop := True

/-!
Anschluss: rationale Spektralkoordination der Triplet-Gaps —
siehe `KeplerHurwitz.GapResonanceTriplet` (`F`-Injektivität auf dem Kegel).
-/

end KeplerHurwitz.GapRotorPeriod3
