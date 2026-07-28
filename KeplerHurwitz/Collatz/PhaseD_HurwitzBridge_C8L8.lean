/-
Copyright (c) 2026 Kepler-Hurrwitz contributors.

Phase D — schmaler Einstieg: Hurwitz/Primvierling-Brücke ab der Lean-Kernzelle `(C,L)=(8,8)`.

Handoff aus Phase C:
* Golden Lean-Anker: `CompositeGapAudit.phaseC_C8_L8_consolidated`
  (`M₃M₂` θ=1/2 strict, `M₃M₅` θ=477/500 weak).
* Atlas: einzige Resonanz-Insel `(8,11)` (chirurgisch gekapselt); sonst stabil.
* Claim-Rand: endliche Clog-Komposite ≠ globale Spektrallücke in `ℋ_q`.

Dieses Modul definiert nur das **Operator-Dictionary** und den Startanker.
Keine Induktion in C/L, kein Collatz-Beweis, kein Core-Filter-Patch.
-/

import Mathlib.Data.Rat.Defs
import Mathlib.Tactic
import KeplerHurwitz.Collatz.CompositeGapAudit
import KeplerHurwitz.Collatz.CompositePhaseCAuditReport
import KeplerHurwitz.Collatz.ResonanzOperator
import KeplerHurwitz.PrimvierlingSymmetry

set_option linter.style.nativeDecide false

namespace KeplerHurwitz.Collatz.PhaseD_HurwitzBridge_C8L8

open KeplerHurwitz
open KeplerHurwitz.Collatz.CompositeGapAudit
open KeplerHurwitz.Collatz.CompositePhaseCAuditReport
open KeplerHurwitz.Collatz.ResonanzOperator

/-! ## Parameterzelle -/

def phaseD_C : Nat := 8
def phaseD_L : Nat := 8

/-- Phase-D Startzelle: identisch mit dem Phase-C Kernanker. -/
def phaseD_start_cell : Prop := phaseD_C = 8 ∧ phaseD_L = 8

theorem phaseD_start_cell_holds : phaseD_start_cell := by
  simp [phaseD_start_cell, phaseD_C, phaseD_L]

/-- Lean-zertifizierter Composite-Gap an der Startzelle. -/
theorem phaseD_inherits_phaseC_core :
    PhaseC_C8_L8_Consolidated :=
  phaseC_C8_L8_consolidated

/-- Archiv: Phase C inkl. Surgical Boundary geschlossen (Anker, keine ∀-Aussage). -/
theorem phaseD_inherits_phaseC_archive :
    PhaseC_WithSurgicalBoundary_Closed :=
  phaseC_with_surgical_boundary_closed

/-! ## Dictionary: Clog-Gewichte ↔ Hurwitz-Normsprache -/

/--
Bitgewicht der Survivor-Transferkante (Phase C).
Bleibt die lokale `ℚ`-Gewichtssprache; keine Identifikation mit `quatNorm`.
-/
def clogBitWeight : Bool → Rat := resonanceWeight

theorem clogBitWeight_bits :
    clogBitWeight false = (1 : Rat) / 2 ∧ clogBitWeight true = (3 : Rat) / 2 := by
  constructor <;> rfl

/--
Hurwitz/Primvierling-Norm (bestehende Repo-Definition).
Phase-D-Brücke: beobachtbare Integer-Norm auf `(a,b,c,e)`, invariant unter `shiftCEAB`.
-/
def hurwitzNorm : Primvierling → Nat := quatNorm

theorem hurwitzNorm_shift_invariant (v : Primvierling) :
    hurwitzNorm (shiftCEAB v) = hurwitzNorm v :=
  quatNorm_invariant_under_shiftCEAB v

/--
Schnittstellen-Marker (Propositionsschicht):
Ein Phase-D-Lift muss lokal die `(8,8)`-Doob-Lücke erhalten und
global eine Hurwitz-invariante Observable (hier: `hurwitzNorm`) respektieren.

Dies ist **kein** Existenzbeweis eines globalen Operators auf `ℋ_q`.
-/
def PhaseD_LiftInterface : Prop :=
  PhaseC_C8_L8_Consolidated ∧
    (∀ v : Primvierling, hurwitzNorm (shiftCEAB v) = hurwitzNorm v)

theorem phaseD_lift_interface_holds : PhaseD_LiftInterface :=
  ⟨phaseD_inherits_phaseC_core, hurwitzNorm_shift_invariant⟩

/--
Explizite Nicht-Gleichsetzung: Bitgewicht und Quaternionen-Norm leben in
verschiedenen Typen/Semantiken. Phase D darf sie koppeln, nicht identifizieren.
-/
def WeightsAreNotNorms : Prop := True

theorem weights_are_not_norms : WeightsAreNotNorms := trivial

/-- Phase-D Einstiegsstatus: Dictionary + Startanker grün. -/
def PhaseD_Bootstrap_C8L8 : Prop :=
  phaseD_start_cell ∧ PhaseD_LiftInterface

theorem phaseD_bootstrap_C8L8 : PhaseD_Bootstrap_C8L8 :=
  ⟨phaseD_start_cell_holds, phaseD_lift_interface_holds⟩

/-! ## Golden drift source: Perron 2-node sector (numeric freeze → Lean anchors) -/

/-- Right Perron support words of `M₃M₅` at `(8,8)` (Lean `vCert` support). -/
def goldenPerronWord₁ : String := "01111100"
def goldenPerronWord₂ : String := "11111100"

/--
Topological Primvierling labels from bit-pairs (not prime quadruplets):
  `01111100` ↦ (1,3,3,0), `11111100` ↦ (3,3,3,0).
-/
def goldenLabelπ₁ : Primvierling := (1, 3, 3, 0)
def goldenLabelπ₂ : Primvierling := (3, 3, 3, 0)

theorem goldenLabelπ₁_ceab :
    shiftCEAB goldenLabelπ₁ = (3, 0, 1, 3) := by
  native_decide

theorem goldenLabelπ₂_ceab :
    shiftCEAB goldenLabelπ₂ = (3, 0, 3, 3) := by
  native_decide

theorem goldenLabelπ₁_norm : quatNorm goldenLabelπ₁ = 19 := by
  native_decide

theorem goldenLabelπ₂_norm : quatNorm goldenLabelπ₂ = 27 := by
  native_decide

/--
Archive marker: the golden drift source is the labeled 2-node Perron sector,
not a Frobenius average over the 41×41 transport medium.
-/
def PhaseD_GoldenDriftSource_Labeled : Prop :=
  PhaseD_Bootstrap_C8L8 ∧
    goldenPerronWord₁ = "01111100" ∧
    goldenPerronWord₂ = "11111100"

theorem phaseD_golden_drift_source_labeled : PhaseD_GoldenDriftSource_Labeled := by
  refine ⟨phaseD_bootstrap_C8L8, rfl, rfl⟩

/--
Phase-D Sektorstück abgeschlossen: Goldene Drift-Quelle `(8,8)` ist archiviert.
Weiterarbeit am Dirac/Spiegel-Fenster geschieht nicht durch Verallgemeinerung
dieses Clog-Sektors (Nachbarzellen: Nilpotenz; siehe JSON-Nachbar-Scan).
-/
def PhaseD_GoldenSector_Closed : Prop := PhaseD_GoldenDriftSource_Labeled

theorem phaseD_golden_sector_closed : PhaseD_GoldenSector_Closed :=
  phaseD_golden_drift_source_labeled

end KeplerHurwitz.Collatz.PhaseD_HurwitzBridge_C8L8
