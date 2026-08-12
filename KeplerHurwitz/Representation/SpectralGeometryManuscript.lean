/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Thomas Hoffbauer, Kepler-Hurrwitz Team
-/

import Mathlib.Data.Real.Basic
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import KeplerHurwitz.Representation.PrimvierlingNichtUeberlappung

/-!
# Formaler Beweis der Spektralgeometrie von Primzahlkonfigurationen

Autor: Thomas Hoffbauer
Datum: 19. Juli 2026

Geschlossenes Lean-4-Dokument mit:

1. Vierdimensionaler Phasenraum unter \(V_4\) und erzwungene Spiegel-Symmetrie
   sowie die bedingte \(2:1\)-Geometrie (unter Hypothese `A = 2B`).
2. Exakter Zerfall des lokalen Hardy–Littlewood-Faktors für Primzahlzwillinge
   (quadratischer Dämpfungsterm \(-1\)).
3. Exakter Zerfall des Faktors für Primzahlvierlinge
   (quadratischer Dämpfungsterm \(-6\)).

**Korrektur:** Die Vierling-Restgliedform ist `(8p - 5)/(p - 1)^4`,
nicht `(4 · (2p - 1))/(p - 1)^4 = (8p - 4)/(p - 1)^4`.
-/

namespace KeplerHurwitz

/-! ## Teil 1: Phasenraum, \(V_4\)-Projektoren und 2:1-Geometrie -/

/-- Zustand eines beliebigen 4D-Vektors `(A, B, C, E)`. -/
structure V4Raum where
  A : ℝ
  B : ℝ
  C : ℝ
  E : ℝ

namespace V4Raum

/-- Projektor `P0` auf die triviale (vollsymmetrische) Mode `h0`. -/
noncomputable def P0 (v : V4Raum) : V4Raum :=
  let sum := (v.A + v.B + v.C + v.E) / 4
  ⟨sum, sum, sum, sum⟩

/-- Projektor `P1` auf die paritätische Mode `h1`. -/
noncomputable def P1 (v : V4Raum) : V4Raum :=
  let val := (v.A - v.B - v.C + v.E) / 4
  ⟨val, -val, -val, val⟩

/--
Lemma: Liegt ein Vektor im gemeinsamen Kern von `P0` und `P1`, so folgen
Translationsfreiheit und Spiegel-Symmetrie.
-/
theorem darstellung_erzwingt_symmetrie (v : V4Raum)
    (hP0 : P0 v = ⟨0, 0, 0, 0⟩)
    (hP1 : P1 v = ⟨0, 0, 0, 0⟩) :
    v.A + v.B + v.C + v.E = 0 ∧ v.A = -v.E ∧ v.B = -v.C := by
  dsimp [P0, P1] at hP0 hP1
  injection hP0 with hP0_A _ _ _
  injection hP1 with hP1_A _ _ _
  have h_schwerpunkt : v.A + v.B + v.C + v.E = 0 := by
    linarith [hP0_A]
  have h_balance : v.A - v.B - v.C + v.E = 0 := by
    linarith [hP1_A]
  refine ⟨h_schwerpunkt, ?_, ?_⟩
  · linarith [h_schwerpunkt, h_balance]
  · linarith [h_schwerpunkt, h_balance]

/--
Hauptsatz: Unter den Gruppenbedingungen und der Hypothese `A = 2B`
kollabiert das Koordinatenverhältnis im invarianten Raum auf exakt `2`.
-/
theorem primzahl_vierling_geometrie (v : V4Raum)
    (hP0 : P0 v = ⟨0, 0, 0, 0⟩)
    (hP1 : P1 v = ⟨0, 0, 0, 0⟩)
    (h_prim : v.A = 2 * v.B)
    (h_innen : v.B - v.C ≠ 0) :
    (v.A - v.E) / (v.B - v.C) = 2 := by
  have ⟨_, h_symm_AE, h_symm_BC⟩ := darstellung_erzwingt_symmetrie v hP0 hP1
  rw [div_eq_iff h_innen]
  linarith [h_symm_AE, h_symm_BC, h_prim]

end V4Raum

/-! ## Teil 2: Rationale Spektralzerlegung der Hardy–Littlewood-Faktoren -/

/--
Lokaler Hardy–Littlewood-Faktor für Primzahlzwillinge (`d = 2`):
exakte Zerlegung mit quadratischem Dämpfungsterm `-1`.
-/
theorem hardy_littlewood_zwilling_struktur (p : ℝ) (hp : p ≠ 1) :
    (p * (p - 2)) / (p - 1) ^ 2 = 1 - 1 / (p - 1) ^ 2 := by
  have hne : p - 1 ≠ 0 := sub_ne_zero.mpr hp
  field_simp [hne]
  ring

/--
Lokaler Hardy–Littlewood-Faktor für Primzahlvierlinge (`d = 4`):
exakte Zerlegung mit führendem quadratischem Kopplungsterm `-6`.
-/
theorem hardy_littlewood_vierling_struktur (p : ℝ) (hp : p ≠ 1) :
    (p ^ 3 * (p - 4)) / (p - 1) ^ 4 =
      1 - 6 / (p - 1) ^ 2 - (8 * p - 5) / (p - 1) ^ 4 := by
  have hne : p - 1 ≠ 0 := sub_ne_zero.mpr hp
  field_simp [hne]
  ring

end KeplerHurwitz
