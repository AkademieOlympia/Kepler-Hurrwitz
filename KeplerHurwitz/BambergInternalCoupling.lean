import Mathlib
import KeplerHurwitz.BambergQuadrupletAdmissibility

/-!
# Bamberg Modell: #Energiedoku — Baustein 2 (interne EABC-Kopplung)

Formales Gerüst für den internen Operator `D_int(n)` auf
`H_int ≅ C^2 ⊕ C^3 ⊕ C^3` und die U(1)-Ladungsregeln.

Governance:
* Scope: post-freeze / Energiedoku-Gerüst; kein Frozen-Dossier-Touch.
* Status: `[A]` (Dimensionen, Ladungserhaltung, Neutralfall).
* Nicht beansprucht: konkrete Spektren, Metrikauswahl, alpha_scale, Naturkonstanten.
* Sequenz: interne Kopplung → topologische Eichdynamik (Baustein 3).

Statusschranke:
  bewiesene Zell- und Spektralstruktur ist unabhaengig von Metrikauswahl und Naturkonstanten.
-/

namespace KeplerHurwitz

/-! ## 1. 2+3+3-Sektorzerlegung -/

/-- Interne Sektoren des Bamberger 8-Raums. -/
inductive InternalSector
  | EA
  | B
  | C
  deriving DecidableEq, Repr, Inhabited

namespace InternalSector

def dim : InternalSector → ℕ
  | .EA => 2
  | .B => 3
  | .C => 3

theorem dim_EA : dim .EA = 2 := rfl
theorem dim_B : dim .B = 3 := rfl
theorem dim_C : dim .C = 3 := rfl

/-- **[A]** Die 2+3+3-Schichtung summiert zu acht internen Freiheitsgraden. -/
theorem internal_dim_sum : dim .EA + dim .B + dim .C = 8 := by decide

/-- Sektor-Slices als explizite `Fin 8`-Mengen. -/
def indicesEA : Finset (Fin 8) := {0, 1}
def indicesB : Finset (Fin 8) := {2, 3, 4}
def indicesC : Finset (Fin 8) := {5, 6, 7}

def indices : InternalSector → Finset (Fin 8)
  | .EA => indicesEA
  | .B => indicesB
  | .C => indicesC

theorem indices_card (s : InternalSector) : (indices s).card = dim s := by
  cases s <;> decide

theorem indices_pairwiseDisjoint (s t : InternalSector) (hne : s ≠ t) :
    Disjoint (indices s) (indices t) := by
  cases s <;> cases t
  · exact absurd rfl hne
  · decide
  · decide
  · decide
  · exact absurd rfl hne
  · decide
  · decide
  · decide
  · exact absurd rfl hne

theorem indices_union :
    indices .EA ∪ indices .B ∪ indices .C = Finset.univ := by
  decide

/-- Sektorzugehoerigkeit eines `Fin 8`-Index. -/
def ofIndex (i : Fin 8) : InternalSector :=
  if (i : ℕ) < 2 then .EA
  else if (i : ℕ) < 5 then .B
  else .C

theorem ofIndex_mem_indices (s : InternalSector) (i : Fin 8) :
    ofIndex i = s ↔ i ∈ indices s := by
  fin_cases i <;>
    cases s <;>
    simp [ofIndex, indices, indicesEA, indicesB, indicesC, Finset.mem_insert, Finset.mem_singleton]

end InternalSector

/-! ## 2. U(1)-Ladungskonfiguration -/

/-- Ganzzahlige U(1)-Ladungen der drei internen Sektoren. -/
structure IntChargeConfig where
  qEA : ℤ
  qB : ℤ
  qC : ℤ

namespace IntChargeConfig

def sectorCharge (q : IntChargeConfig) (s : InternalSector) : ℤ :=
  match s with
  | .EA => q.qEA
  | .B => q.qB
  | .C => q.qC

/-- Ladungsneutraler Standardsektor: U(1) wirkt nur auf den geometrischen Faktor. -/
def neutral : IntChargeConfig := { qEA := 0, qB := 0, qC := 0 }

theorem neutral_qEA : neutral.qEA = 0 := rfl
theorem neutral_qB : neutral.qB = 0 := rfl
theorem neutral_qC : neutral.qC = 0 := rfl

theorem neutral_sectorCharge (s : InternalSector) :
    sectorCharge neutral s = 0 := by
  cases s <;> rfl

end IntChargeConfig

/-! ## 3. Ladungserhaltung für Off-Diagonal-Kopplungen -/

/-- Zwei Sektoren tragen dieselbe U(1)-Ladung. -/
def chargesEqual (q : IntChargeConfig) (s t : InternalSector) : Prop :=
  IntChargeConfig.sectorCharge q s = IntChargeConfig.sectorCharge q t

/-- Off-Diagonal-Kopplung zwischen zwei verschiedenen Sektoren ist genau dann
    eichinvariant erlaubt, wenn die Ladungen uebereinstimmen. Diagonal-Bloecke
    sind stets erlaubt. -/
def offDiagonalCouplingAllowed (q : IntChargeConfig) (s t : InternalSector) : Prop :=
  s = t ∨ chargesEqual q s t

theorem diagonalCouplingAllowed (q : IntChargeConfig) (s : InternalSector) :
    offDiagonalCouplingAllowed q s s := by
  simp [offDiagonalCouplingAllowed]

theorem ea_b_allowed_iff (q : IntChargeConfig) :
    offDiagonalCouplingAllowed q .EA .B ↔ q.qEA = q.qB := by
  simp [offDiagonalCouplingAllowed, chargesEqual, IntChargeConfig.sectorCharge]

theorem ea_c_allowed_iff (q : IntChargeConfig) :
    offDiagonalCouplingAllowed q .EA .C ↔ q.qEA = q.qC := by
  simp [offDiagonalCouplingAllowed, chargesEqual, IntChargeConfig.sectorCharge]

theorem b_c_allowed_iff (q : IntChargeConfig) :
    offDiagonalCouplingAllowed q .B .C ↔ q.qB = q.qC := by
  simp [offDiagonalCouplingAllowed, chargesEqual, IntChargeConfig.sectorCharge]

/-- **[A]** Neutralstart: alle Off-Diagonal-Kopplungen sind erlaubt. -/
theorem neutral_offDiagonalCouplingAllowed (q : IntChargeConfig) (s t : InternalSector)
    (hq : q = IntChargeConfig.neutral) :
    offDiagonalCouplingAllowed q s t := by
  subst hq
  cases s <;> cases t <;>
    simp [offDiagonalCouplingAllowed, chargesEqual, IntChargeConfig.neutral_sectorCharge]

/-! ## 4. Blockstruktur von D_int(n) -/

/-- Namen der erlaubten Kopplungsbloecke in der 3×3-Sektor-Matrix. -/
inductive CouplingBlock
  | D_EA
  | Y_B
  | Y_C
  | M_B
  | K
  | M_C
  deriving DecidableEq, Repr, Inhabited

namespace CouplingBlock

def source : CouplingBlock → InternalSector
  | .D_EA => .EA
  | .Y_B => .B
  | .Y_C => .C
  | .M_B => .B
  | .K => .B
  | .M_C => .C

def target : CouplingBlock → InternalSector
  | .D_EA => .EA
  | .Y_B => .EA
  | .Y_C => .EA
  | .M_B => .B
  | .K => .C
  | .M_C => .C

def isDiagonal : CouplingBlock → Bool
  | .D_EA | .M_B | .M_C => true
  | .Y_B | .Y_C | .K => false

theorem diagonal_blocks_always_allowed (q : IntChargeConfig) (b : CouplingBlock)
    (hb : isDiagonal b = true) :
    offDiagonalCouplingAllowed q (source b) (target b) := by
  cases b <;> simp [isDiagonal] at hb <;> exact diagonalCouplingAllowed q _

/-- **[A]** Eichkovarianz-Schnitt: ein Kopplungsblock ist zulaessig, wenn seine
    Sektoren die Ladungserhaltungsregel erfuellen. -/
def gaugeAllowed (q : IntChargeConfig) (b : CouplingBlock) : Prop :=
  offDiagonalCouplingAllowed q (source b) (target b)

theorem gaugeAllowed_diagonal (q : IntChargeConfig) (b : CouplingBlock)
    (hb : isDiagonal b = true) : gaugeAllowed q b :=
  diagonal_blocks_always_allowed q b hb

theorem gaugeAllowed_neutral (b : CouplingBlock) :
    gaugeAllowed IntChargeConfig.neutral b := by
  unfold gaugeAllowed
  exact neutral_offDiagonalCouplingAllowed _ _ _ rfl

end CouplingBlock

/-! ## 5. Interne U(1)-Wirkung (Diagonalphase) -/

open Matrix Complex

/-- Diagonale U(1)-Darstellung auf `C^8` zu gegebener Ladungskonfiguration. -/
noncomputable def internalGaugeMatrix (q : IntChargeConfig) (g : ℂ) :
    Matrix (Fin 8) (Fin 8) ℂ :=
  Matrix.diagonal fun i =>
    g ^ IntChargeConfig.sectorCharge q (InternalSector.ofIndex i)

/-- **[A]** Im Neutralfall ist die interne U(1)-Wirkung die Identitaet fuer jede Phase. -/
theorem neutral_internalGaugeMatrix (g : ℂ) :
    internalGaugeMatrix IntChargeConfig.neutral g = 1 := by
  ext i j
  by_cases h : i = j
  · subst h
    simp [internalGaugeMatrix, IntChargeConfig.neutral_sectorCharge,
      Matrix.one_apply, Matrix.diagonal_apply, zpow_zero]
  · simp [internalGaugeMatrix, IntChargeConfig.neutral_sectorCharge,
      Matrix.one_apply, Matrix.diagonal_apply, h]

/-! ## 6. Bruecke zu Baustein 1 -/

/-- Baustein 1 liefert die geometrische Zellstruktur; Baustein 2 die interne
    Kopplung. Der Gesamtoperator bleibt **[B]** bis zur Spektralrechnung. -/
structure BambergCouplingLayer where
  /-- Geometrische Dimension (Quadrat-Plakette ueber {1,p,q,pq}). -/
  geomDim : ℕ := 4
  /-- Interne Dimension (2+3+3). -/
  intDim : ℕ := 8
  /-- Standard-Ladungskonfiguration fuer den Neutralstart. -/
  charge : IntChargeConfig := IntChargeConfig.neutral
  deriving Inhabited

namespace BambergCouplingLayer

theorem default_intDim : (default : BambergCouplingLayer).intDim = 8 := rfl

theorem default_neutral : (default : BambergCouplingLayer).charge = IntChargeConfig.neutral := rfl

theorem default_charge_sum :
    InternalSector.dim .EA + InternalSector.dim .B + InternalSector.dim .C =
      (default : BambergCouplingLayer).intDim := by
  simp [default_intDim, InternalSector.internal_dim_sum]

end BambergCouplingLayer

end KeplerHurwitz
