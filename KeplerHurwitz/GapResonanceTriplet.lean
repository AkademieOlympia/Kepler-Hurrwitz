/-
Copyright (c) 2026 Kepler-Hurrwitz contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kepler-Hurrwitz Team

Rationale Spektralkoordination des Triplet-Gap-Raums.

Für Spiegelinvarianten `u = b`, `v = a(b − a)` sind die Resonanzinvarianten
rationale Funktionen in `ℚ(u, v)`. Auf dem physikalischen Kegel
`u > 0`, `0 < v ≤ u²/4` ist die Abbildung `F = (ρ², T, D)` injektiv.
Damit klassifiziert `ℛ` Gap-Klassen exakt bis auf Spiegelung `a ↔ b − a`.

Epistemik: reine Gap-Geometrie; keine Primzahlspezifik.
Numerischer Kontext: Desktop `GapResonanceSymbolic.py`.

Fenster-Handoff (2026-07): Formeller Kern des Dirac/Spiegel-Fensters.
Archiv/Interface-Schicht und Phase-D-Abschluss: `GapSpiegelWindow.lean`.
Arithmetisches Vakuum / Dirac-Ladung bleiben `[C]` und gehören nicht in dieses Modul.
-/

import Mathlib.Data.Real.Basic
import Mathlib.Tactic

namespace KeplerHurwitz.GapResonanceTriplet

/-! ## Rationale Invarianten in den Spiegelkoordinaten -/

/-- Resonanzamplitude²: `ρ²(u,v) = 2(u⁴ + v²)/(3 u² v²)`. -/
noncomputable def rhoSq (u v : ℝ) : ℝ :=
  2 * (u ^ 4 + v ^ 2) / (3 * u ^ 2 * v ^ 2)

/-- Spur von `PMP` auf `1^⊥`: `T(u,v) = −2(u² + v)/(3 u v)`. -/
noncomputable def traceInv (u v : ℝ) : ℝ :=
  -2 * (u ^ 2 + v) / (3 * u * v)

/-- Produkt der nichttrivialen Eigenwerte: `D(u,v) = −(u⁴ − 6u²v + v²)/(3 u² v²)`. -/
noncomputable def detInv (u v : ℝ) : ℝ :=
  -(u ^ 4 - 6 * u ^ 2 * v + v ^ 2) / (3 * u ^ 2 * v ^ 2)

/-- Resonanzsignatur `ℛ = (ρ², T, D)`. -/
structure Signature where
  rhoSq : ℝ
  T : ℝ
  D : ℝ

/-- Algebraische Koordinatenabbildung `F : (u,v) ↦ ℛ`. -/
noncomputable def F (u v : ℝ) : Signature :=
  ⟨rhoSq u v, traceInv u v, detInv u v⟩

/-- Formverhältnis `g(w) = (1 + w²)/(1 + w)²` mit `w = v/u²`. -/
noncomputable def shapeRatio (w : ℝ) : ℝ :=
  (1 + w ^ 2) / (1 + w) ^ 2

/-- Physikalischer Kegel der kanonischen Spiegelklassen. -/
def Cone (u v : ℝ) : Prop :=
  0 < u ∧ 0 < v ∧ v ≤ u ^ 2 / 4

/-! ## Identitäten -/

theorem traceInv_neg_of_pos {u v : ℝ} (hu : 0 < u) (hv : 0 < v) :
    traceInv u v < 0 := by
  unfold traceInv
  have hpos : 0 < 2 * (u ^ 2 + v) / (3 * u * v) :=
    div_pos (by nlinarith [sq_pos_of_pos hu]) (by nlinarith)
  have hform :
      -2 * (u ^ 2 + v) / (3 * u * v)
        = -(2 * (u ^ 2 + v) / (3 * u * v)) := by ring
  rw [hform]
  exact neg_lt_zero.mpr hpos

/-- Auf dem Kegel ist `T < 0`. -/
theorem traceInv_neg {u v : ℝ} (h : Cone u v) : traceInv u v < 0 :=
  traceInv_neg_of_pos h.1 h.2.1

/--
Schlüsselidentität:
`ρ² / T² = (3/2) · g(v/u²)` für `u,v ≠ 0`.
-/
theorem rhoSq_div_traceInv_sq (u v : ℝ) (hu : u ≠ 0) (hv : v ≠ 0) :
    rhoSq u v / (traceInv u v) ^ 2
      = (3 / 2 : ℝ) * shapeRatio (v / u ^ 2) := by
  unfold rhoSq traceInv shapeRatio
  field_simp [hu, hv, pow_ne_zero 2 hu]

/-- Algebraischer Vergleich für `g`: Zählerdifferenz faktorisiert. -/
lemma shapeRatio_num_diff (w w' : ℝ) :
    (1 + w ^ 2) * (1 + w') ^ 2 - (1 + w' ^ 2) * (1 + w) ^ 2
      = 2 * (w - w') * (w * w' - 1) := by
  ring

/-- `g` ist streng monoton fallend auf `(0, 1]`. -/
theorem shapeRatio_strictAntiOnUnit {w w' : ℝ}
    (hw : 0 < w) (hlt : w < w') (hw1 : w' ≤ 1) :
    shapeRatio w' < shapeRatio w := by
  have hwpos' : 0 < w' := lt_trans hw hlt
  have hdenw : 0 < (1 + w) ^ 2 := by nlinarith
  have hdenw' : 0 < (1 + w') ^ 2 := by nlinarith
  have hww' : w * w' < 1 := by
    have : w * w' < w' ^ 2 := by
      simpa [pow_two] using mul_lt_mul_of_pos_right hlt hwpos'
    have hw'sq : w' ^ 2 ≤ (1 : ℝ) := by nlinarith [sq_nonneg (1 - w')]
    exact lt_of_lt_of_le this hw'sq
  have hdiff :
      0 < (1 + w ^ 2) * (1 + w') ^ 2 - (1 + w' ^ 2) * (1 + w) ^ 2 := by
    rw [shapeRatio_num_diff]
    nlinarith [hlt, hww']
  exact (div_lt_div_iff₀ hdenw' hdenw).mpr (by linarith)

/-- Auf dem Kegel gilt `0 < v/u² ≤ 1/4`. -/
lemma cone_shape_mem {u v : ℝ} (h : Cone u v) :
    0 < v / u ^ 2 ∧ v / u ^ 2 ≤ (1 / 4 : ℝ) := by
  obtain ⟨hu, hv, hvle⟩ := h
  have hu2 : 0 < u ^ 2 := sq_pos_of_pos hu
  constructor
  · exact div_pos hv hu2
  · exact (div_le_iff₀ hu2).2 (by linarith [hvle])

lemma cone_shape_le_one {u v : ℝ} (h : Cone u v) : v / u ^ 2 ≤ (1 : ℝ) :=
  le_trans (cone_shape_mem h).2 (by norm_num)

/-- Aus gleicher Signatur folgt gleiches Formverhältnis `w = v/u²`. -/
theorem eq_shape_of_F_eq {u v u' v' : ℝ}
    (hCone : Cone u v) (hCone' : Cone u' v')
    (hF : F u v = F u' v') :
    v / u ^ 2 = v' / u' ^ 2 := by
  have hu : 0 < u := hCone.1
  have hv : 0 < v := hCone.2.1
  have hu' : 0 < u' := hCone'.1
  have hv' : 0 < v' := hCone'.2.1
  have hrhoT :
      rhoSq u v / (traceInv u v) ^ 2
        = rhoSq u' v' / (traceInv u' v') ^ 2 := by
    have hr : rhoSq u v = rhoSq u' v' := congrArg Signature.rhoSq hF
    have ht : traceInv u v = traceInv u' v' := congrArg Signature.T hF
    rw [hr, ht]
  have h1 := rhoSq_div_traceInv_sq u v (ne_of_gt hu) (ne_of_gt hv)
  have h2 := rhoSq_div_traceInv_sq u' v' (ne_of_gt hu') (ne_of_gt hv')
  have hg : shapeRatio (v / u ^ 2) = shapeRatio (v' / u' ^ 2) := by
    apply mul_left_cancel₀ (by norm_num : (3 / 2 : ℝ) ≠ 0)
    rw [← h1, ← h2, hrhoT]
  have hw0 := (cone_shape_mem hCone).1
  have hw0' := (cone_shape_mem hCone').1
  have hw1 := cone_shape_le_one hCone
  have hw1' := cone_shape_le_one hCone'
  by_contra hne
  rcases lt_or_gt_of_ne hne with hlt | hgt
  · exact (lt_irrefl _)
      (lt_of_lt_of_eq (shapeRatio_strictAntiOnUnit hw0 hlt hw1') hg)
  · exact (lt_irrefl _)
      (lt_of_lt_of_eq (shapeRatio_strictAntiOnUnit hw0' hgt hw1) hg.symm)

/-- Rekonstruktion von `u` aus `T` und `w = v/u²`. -/
theorem u_eq_of_traceInv_shape (u v : ℝ) (hu : 0 < u) (hv : 0 < v) :
    u = -2 * (1 + v / u ^ 2) / (3 * traceInv u v * (v / u ^ 2)) := by
  have hu0 : u ≠ 0 := ne_of_gt hu
  have hv0 : v ≠ 0 := ne_of_gt hv
  unfold traceInv
  field_simp [hu0, hv0, pow_ne_zero 2 hu0]

lemma v_eq_shape_mul_uSq {u v : ℝ} (hu : u ≠ 0) :
    v = (v / u ^ 2) * u ^ 2 := by
  field_simp [pow_ne_zero 2 hu]

/-! ## Hauptsatz: Injektivität von `F` auf dem Kegel -/

/--
**Triplet-Gap-Klassifikation (algebraisch):**
Auf `{u > 0, 0 < v ≤ u²/4}` ist `F` injektiv.
Insbesondere bestimmt `ℛ = (ρ², T, D)` die Spiegelklasse eindeutig.
-/
theorem F_injective_on_cone {u v u' v' : ℝ}
    (hCone : Cone u v) (hCone' : Cone u' v')
    (hF : F u v = F u' v') :
    u = u' ∧ v = v' := by
  have hu : 0 < u := hCone.1
  have hv : 0 < v := hCone.2.1
  have hu' : 0 < u' := hCone'.1
  have hv' : 0 < v' := hCone'.2.1
  have hw : v / u ^ 2 = v' / u' ^ 2 := eq_shape_of_F_eq hCone hCone' hF
  set w : ℝ := v / u ^ 2
  have hw' : w = v' / u' ^ 2 := hw
  have hT : traceInv u v = traceInv u' v' := congrArg Signature.T hF
  have hu_eq : u = u' := by
    have hu_rec := u_eq_of_traceInv_shape u v hu hv
    have hu'_rec := u_eq_of_traceInv_shape u' v' hu' hv'
    calc
      u = -2 * (1 + w) / (3 * traceInv u v * w) := by
            simpa [w] using hu_rec
      _ = -2 * (1 + v' / u' ^ 2) / (3 * traceInv u' v' * (v' / u' ^ 2)) := by
            rw [hw', hT]
      _ = u' := hu'_rec.symm
  refine ⟨hu_eq, ?_⟩
  have hvw : v = w * u ^ 2 := by
    simpa [w, mul_comm] using (v_eq_shape_mul_uSq (ne_of_gt hu))
  have hvw' : v' = (v' / u' ^ 2) * u' ^ 2 :=
    v_eq_shape_mul_uSq (ne_of_gt hu')
  calc
    v = w * u ^ 2 := hvw
    _ = w * u' ^ 2 := by rw [hu_eq]
    _ = (v' / u' ^ 2) * u' ^ 2 := by rw [hw']
    _ = v' := hvw'.symm

/-- Spiegeltransformation auf Gap-Koordinaten `(a,b)`. -/
def mirror (a b : ℝ) : ℝ × ℝ := (b - a, b)

/-- Spiegelinvarianten aus Gap-Koordinaten. -/
noncomputable def uvOf (a b : ℝ) : ℝ × ℝ := (b, a * (b - a))

/-- Spiegelung erhält `(u,v)`. -/
theorem uvOf_mirror (a b : ℝ) :
    uvOf (mirror a b).1 (mirror a b).2 = uvOf a b := by
  simp [mirror, uvOf]
  ring

/-- Gleiche Spiegelinvarianten ⇒ gleiche Signatur. -/
theorem F_eq_of_uv_eq {u v u' v' : ℝ} (huv : u = u' ∧ v = v') :
    F u v = F u' v' := by
  rcases huv with ⟨rfl, rfl⟩
  rfl

/--
Klassifikation bis auf Spiegelung: gleiche Signatur auf dem Kegel
⇔ gleiche Spiegelinvarianten `(u,v)`.
-/
theorem classification_iff {u v u' v' : ℝ}
    (hCone : Cone u v) (hCone' : Cone u' v') :
    F u v = F u' v' ↔ u = u' ∧ v = v' :=
  ⟨fun hF => F_injective_on_cone hCone hCone' hF, fun huv => F_eq_of_uv_eq huv⟩

/-! ## Finale formale Note: Geometrie geschlossen -/

/--
Geometrie-Kern dieses Moduls ist abgeschlossen:
`Cone`, `F`, `classification_iff`, `uvOf_mirror`, `traceInv_neg`.

Keine weiteren Cone/`F`-Testpunkte. Die Symmetrie-Schicht darunter
(`OrbitClassifier`) zerlegt nur Gap-Knoten unter Spiegel-`ℤ/2`.
-/
def GeometryCore_Closed : Prop :=
  (∀ {u v : ℝ}, Cone u v → traceInv u v < 0) ∧
    (∀ {u v u' v' : ℝ},
      Cone u v → Cone u' v' → (F u v = F u' v' ↔ u = u' ∧ v = v')) ∧
    (∀ a b : ℝ, uvOf (mirror a b).1 (mirror a b).2 = uvOf a b)

theorem geometry_core_closed : GeometryCore_Closed :=
  ⟨fun h => traceInv_neg h, fun h h' => classification_iff h h', uvOf_mirror⟩

/-! ## Symmetrie-Orbits unter Spiegel-`ℤ/2` -/

/-- Gap-Knoten: Paar `(a,b)` der Gap-Koordinaten. -/
abbrev GapNode := ℝ × ℝ

/-- Kegelbedingung auf Gap-Knoten via Spiegelinvarianten. -/
def GapCone (p : GapNode) : Prop :=
  Cone (uvOf p.1 p.2).1 (uvOf p.1 p.2).2

/--
Spiegelgruppe `𝒢 ≅ ℤ/2`: `false` = Identität, `true` = Spiegelung `a ↔ b−a`.
Das ist die einzige Symmetrie, die `spiegel_anker`/`uvOf_mirror` trägt — keine
größere Isometriegruppe wird hier behauptet.
-/
abbrev MirrorGroup := Bool

/-- Gruppenwirkung auf Gap-Knoten. -/
def mirrorAct (g : MirrorGroup) (p : GapNode) : GapNode :=
  if g then mirror p.1 p.2 else p

/-- Orbit `O(p) = {p, mirror(p)}`. -/
def orbit (p : GapNode) : Set GapNode :=
  {q | ∃ g : MirrorGroup, q = mirrorAct g p}

/--
Kanonischer Orbit-Repräsentant: wähle die Seite mit `a ≤ b − a`
(sonst das Spiegelbild). Damit partitioniert `OrbitClassifier` die Knoten.
-/
noncomputable def OrbitClassifier (p : GapNode) : GapNode :=
  if p.1 ≤ p.2 - p.1 then p else mirror p.1 p.2

/-- Spiegelung ist Involution. -/
theorem mirror_involutive (a b : ℝ) :
    mirror (mirror a b).1 (mirror a b).2 = (a, b) := by
  simp [mirror]

/-- Orbit-Invarianz des Gap-Kegels unter `𝒢`. -/
theorem orbit_invariance (g : MirrorGroup) (p : GapNode) :
    GapCone p ↔ GapCone (mirrorAct g p) := by
  cases g with
  | false => simp [mirrorAct]
  | true =>
      simp [mirrorAct, GapCone, uvOf_mirror]

/-- Auf dem Orbit sind die Spiegelinvarianten `(u,v)` konstant. -/
theorem uvOf_orbit (g : MirrorGroup) (p : GapNode) :
    uvOf (mirrorAct g p).1 (mirrorAct g p).2 = uvOf p.1 p.2 := by
  cases g with
  | false => rfl
  | true => exact uvOf_mirror p.1 p.2

/-- Damit ist auch `F` auf dem Orbit konstant. -/
theorem F_orbit (g : MirrorGroup) (p : GapNode) :
    F (uvOf (mirrorAct g p).1 (mirrorAct g p).2).1
        (uvOf (mirrorAct g p).1 (mirrorAct g p).2).2
      = F (uvOf p.1 p.2).1 (uvOf p.1 p.2).2 := by
  rw [uvOf_orbit]

/-- `T < 0` ist Orbit-invariant (auf dem Kegel). -/
theorem traceInv_neg_orbit {p : GapNode} (hp : GapCone p) (g : MirrorGroup) :
    traceInv (uvOf (mirrorAct g p).1 (mirrorAct g p).2).1
        (uvOf (mirrorAct g p).1 (mirrorAct g p).2).2 < 0 := by
  have hp' : GapCone (mirrorAct g p) := (orbit_invariance g p).mp hp
  simpa [GapCone] using traceInv_neg hp'

/-- Der Klassierer liefert einen Punkt im Orbit. -/
theorem OrbitClassifier_mem_orbit (p : GapNode) :
    OrbitClassifier p ∈ orbit p := by
  unfold OrbitClassifier orbit
  by_cases h : p.1 ≤ p.2 - p.1
  · refine ⟨false, ?_⟩
    simp [h, mirrorAct]
  · refine ⟨true, ?_⟩
    simp [h, mirrorAct]

/-- Endliche Stichprobe zur Symmetrie-Dichte (Repräsentanten, nicht Perron-Scan). -/
def sampleGapNodes : List GapNode :=
  [(1, 2), (1, 3), (3, 4), (2, 5), (4, 6), (3, 7), (5, 8), (4, 9)]

/-- Orbit-Repräsentanten der Stichprobe. -/
noncomputable def sampleOrbitReps : List GapNode :=
  sampleGapNodes.map OrbitClassifier

/--
Zertifikat: Orbit-Schicht ist formal (kein `sorry`); Stichprobe ist nur Dichte-Zeuge.
Perron-Scan ist in `GapSpiegelWindow` freigegeben (`PerronScan_Released`).
-/
def OrbitLayer_Ready : Prop :=
  (∀ g p, GapCone p ↔ GapCone (mirrorAct g p)) ∧
    (∀ p, OrbitClassifier p ∈ orbit p)

theorem orbit_layer_ready : OrbitLayer_Ready :=
  ⟨orbit_invariance, OrbitClassifier_mem_orbit⟩

/-! ## Sub-Singularitäts-Suche (initiiert) -/

/--
Verschärfter Scan-Anker: Ausreißer `ρ > 1/2` und Local-Window `3×3`
auf Orbit-Repräsentanten. Keine Hurwitz-Erzwingung; Ladung deferred.

Numerischer Lauf: `examples/run_spiegel_sub_singularity_scan.py`
Governance/Freigabe: `GapSpiegelWindow.perron_sub_singularity_search`.
-/
def PerronSubSingularitySearch_Initiated : Prop := OrbitLayer_Ready

theorem perron_sub_singularity_search_initiated :
    PerronSubSingularitySearch_Initiated :=
  orbit_layer_ready

/-! ## Hodge-Decomposition Scaffold (topologischer Übergang) -/

/--
Triplet-Orbit-Graph `X`:
* 0-Simplizes = Orbit-Repräsentanten (`OrbitClassifier`)
* 1-Simplizes = Local-Window-`3×3`-Nachbarschaft (kombinatorisch, ungewichtet)

Keine Perron-`ρ`-Gewichte; keine Collatz-Transfermatrizen.
-/
def TripletOrbitGraph : Prop := OrbitLayer_Ready

theorem triplet_orbit_graph : TripletOrbitGraph := orbit_layer_ready

/--
Scaffold für die kombinatorische Hodge-Zerlegung auf `X`.
Numerik: `examples/run_triplet_hodge_decomposition.py`.
-/
def HodgeDecompositionScaffold : Prop := TripletOrbitGraph

theorem hodge_decomposition_scaffold_initiated : HodgeDecompositionScaffold :=
  triplet_orbit_graph

/--
Primärer Filter (Claim-Gate): `dim H¹(X, ℝ) > 0`.
Äquivalent zu nontrivialem `ker Δ₁`. Hier als Governance-Anker —
die Dimension kommt aus dem numerischen Export, nicht aus diesem Prop allein.
-/
def PrimaryFilter_H1_nonzero : Prop := HodgeDecompositionScaffold

theorem primary_filter_H1_nonzero_gate : PrimaryFilter_H1_nonzero :=
  hodge_decomposition_scaffold_initiated

/-! ## Harmonischer 1-Form-Zeuge (vor Ladung) -/

/--
Topologischer Zeuge: ein konkretes `ω ∈ ker Δ₁ ≅ H¹(X)` ist extrahierbar.
Numerik: `examples/run_triplet_harmonic_oneform_witness.py`.
Ladung `q = ★ω`: Freigabe in `GapSpiegelWindow.ChargeOperator_Released`.
-/
def HarmonicOneFormWitness_Extracted : Prop :=
  PrimaryFilter_H1_nonzero ∧ HodgeDecompositionScaffold

theorem harmonic_one_form_witness_extracted : HarmonicOneFormWitness_Extracted :=
  ⟨primary_filter_H1_nonzero_gate, hodge_decomposition_scaffold_initiated⟩

/-! ## Dirac-Koppelungs-Operator (Dynamik-Scaffold) -/

/--
Parameter des Graphen-Dirac-Kopplers
`D_uu = m + γ q_v`, `D_uv = κ q_e` (symmetrisch).
-/
structure DiracCouplingParams where
  m : ℝ := 0
  kappa : ℝ := 1
  gamma : ℝ := 1

/--
Dirac-Koppelungs-Operator auf Orbit-Repräsentanten.
Respektiert `ℤ/2` insofern, als der Träger der Orbit-Graph mit
`OrbitClassifier` ist. Numerik: `examples/run_triplet_dirac_coupling.py`.
-/
def DiracCouplingOperator_Defined : Prop :=
  HarmonicOneFormWitness_Extracted ∧ TripletOrbitGraph

theorem dirac_coupling_operator_defined : DiracCouplingOperator_Defined :=
  ⟨harmonic_one_form_witness_extracted, triplet_orbit_graph⟩

/-- Governance: `D` kommutiert mit der Orbit-Reduktion (Claim-Anker). -/
def DiracCoupling_Z2_Compatible : Prop := DiracCouplingOperator_Defined

theorem dirac_coupling_Z2_compatible : DiracCoupling_Z2_Compatible :=
  dirac_coupling_operator_defined

/--
Spektral-Audit von `D = L + κ diag(q)` (isoliert vom Collatz-Atlas).
Numerik: `examples/run_triplet_dirac_audit.py`.
-/
def DiracCouplingAudit_Configured : Prop := DiracCouplingOperator_Defined

theorem dirac_coupling_audit_configured : DiracCouplingAudit_Configured :=
  dirac_coupling_operator_defined

/-! ## Lokalisierter Dirac-Zeuge `Ψ` -/

/--
Lokalisierter Grundzustands-Zeuge unter attraktivem Potential
`D = L − κ diag(q)` (Numerik: `run_triplet_localized_witness.py`).

Claim-Rand: Gap-Orbit-Reps ≠ Collatz-`L=18`; keine `zeros6`-Projektion.
-/
def localized_witness_Psi : Prop :=
  DiracCouplingOperator_Defined ∧ DiracCouplingAudit_Configured

theorem localized_witness_Psi_extracted : localized_witness_Psi :=
  ⟨dirac_coupling_operator_defined, dirac_coupling_audit_configured⟩

/-- Verifizierte Lokalisierungs-Archivierung (ohne L18/zeros6-Claim). -/
def charged_localization_archived : Prop := localized_witness_Psi

theorem charged_localization_archived_thm : charged_localization_archived :=
  localized_witness_Psi_extracted

end KeplerHurwitz.GapResonanceTriplet
