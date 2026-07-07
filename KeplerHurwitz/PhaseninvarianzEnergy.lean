import Mathlib
import KeplerHurwitz.PhaseninvarianzInterface

namespace KeplerHurwitz

/-!
## Phaseninvarianz — quadratische/quartische Energieterme [A]

Algebraische Fakten zu `E_a = ax^2 + ay^2`, `E_bc = (bx^2+by^2)(cx^2+cy^2)` und
`E_pair = vx^2 + vy^2` unter Pauli-Z/X/Y auf Amplitudenpaaren.

Defensiv: keine QM- oder QEC-Identifikation; nur Invarianz unter Vorzeichen- und
Permutationsoperatoren.
Python-Parität: `phaseninvarianz_pauli_energy.py`, `phaseninvarianz_tensor_invariants.py`
(under `src/kepler_hurwitz/`).
-/

/--
Quadratische Energie auf der a-Achse: `E_a = ax^2 + ay^2`.
-/
def axisAEnergy (ax ay : ℝ) : ℝ :=
  ax ^ 2 + ay ^ 2

/--
Quartische bc-Energie: `E_bc = (bx^2 + by^2)(cx^2 + cy^2)`.
-/
def axisBCEnergy (bx b_y cx cy : ℝ) : ℝ :=
  (bx ^ 2 + b_y ^ 2) * (cx ^ 2 + cy ^ 2)

/--
Energie eines einzelnen Amplitudenpaars: `E_pair = vx^2 + vy^2`.
-/
def pairEnergy (vx vy : ℝ) : ℝ :=
  vx ^ 2 + vy ^ 2

theorem axisAEnergy_nonneg (ax ay : ℝ) : 0 ≤ axisAEnergy ax ay := by
  unfold axisAEnergy
  exact add_nonneg (sq_nonneg ax) (sq_nonneg ay)

theorem axisBCEnergy_nonneg (bx b_y cx cy : ℝ) : 0 ≤ axisBCEnergy bx b_y cx cy := by
  unfold axisBCEnergy
  exact mul_nonneg (add_nonneg (sq_nonneg bx) (sq_nonneg b_y))
    (add_nonneg (sq_nonneg cx) (sq_nonneg cy))

theorem pairEnergy_nonneg (vx vy : ℝ) : 0 ≤ pairEnergy vx vy := by
  unfold pairEnergy
  exact add_nonneg (sq_nonneg vx) (sq_nonneg vy)

theorem axisAEnergy_eq_energyA (ax ay : ℝ) :
    axisAEnergy ax ay = energyA ⟨ax, ay⟩ := rfl

theorem axisBCEnergy_eq_energyBc (bx b_y cx cy : ℝ) :
    axisBCEnergy bx b_y cx cy = energyBc ⟨bx, b_y⟩ ⟨cx, cy⟩ := rfl

/-- Pauli Z auf ax: Vorzeichenflip `ax ↦ -ax`. -/
theorem axisAEnergy_pauliZ_x (ax ay : ℝ) :
    axisAEnergy (-ax) ay = axisAEnergy ax ay := by
  unfold axisAEnergy
  ring

/-- Pauli Z auf ay: Vorzeichenflip `ay ↦ -ay`. -/
theorem axisAEnergy_pauliZ_y (ax ay : ℝ) :
    axisAEnergy ax (-ay) = axisAEnergy ax ay := by
  unfold axisAEnergy
  ring

/-- Pauli X: Bitflip `ax ↔ ay`. -/
theorem axisAEnergy_pauliX (ax ay : ℝ) :
    axisAEnergy ay ax = axisAEnergy ax ay := by
  unfold axisAEnergy
  ring

theorem pairEnergy_pauliZ_x (vx vy : ℝ) :
    pairEnergy (-vx) vy = pairEnergy vx vy := by
  unfold pairEnergy
  ring

theorem pairEnergy_pauliZ_y (vx vy : ℝ) :
    pairEnergy vx (-vy) = pairEnergy vx vy := by
  unfold pairEnergy
  ring

theorem pairEnergy_pauliX (vx vy : ℝ) :
    pairEnergy vy vx = pairEnergy vx vy := by
  unfold pairEnergy
  ring

/-- Pauli Y: `(-vy, vx)` — `(-vy)^2 + vx^2 = vy^2 + vx^2`. -/
theorem pairEnergy_pauliY (vx vy : ℝ) :
    pairEnergy (-vy) vx = pairEnergy vx vy := by
  unfold pairEnergy
  ring

end KeplerHurwitz
