import KeplerHurwitz.DedekindHasseDumasInterface
import KeplerHurwitz.EABCLayer

namespace KeplerHurwitz

namespace DedekindIdealLayer

open EABCChannel EABCSignature4

/-!
## Dedekind-Idealtheorie-Schicht (E-064 / E-065 / E-066)

Ergaenzt E-053 (`DedekindHasseDumasInterface.lean`) um eine **Dedekind-artige Ideal-Schicht**
fuer quaternionische Referenzordnungen — als `[C]` Schnittstellenmodell, ohne vollstaendige
Quaternionenalgebra.

> **Dedekind-Hasse prueft die PID-Faehigkeit. Dedekind-Idealtheorie beschreibt die Pfade.
> EABC interpretiert moegliche Signaturmuster.**

### Drei mathematische Schichten (Governance)

| Schicht | Objekt | Rolle | Status |
|---|---|---|---|
| **DH** | `α·ρ − β` (Normreduktion) | analytisch-metrisch; Stabilitaetscheck PID | `[C]` E-053 |
| **Dedekind-Ideal** | `H·γ` vs. `γ·H` | topologisch-algebraisch; **einheiteninvariant** | `[C]`/`[B]` E-064–E-066 |
| **EABC mod 12** | `EABCSignature4`, Kanalprojektion | Interpretationsschicht | `[C]` offen |

**DH beweist nicht EABC.** Idealpfade sind **invariant** gegenueber Elementdarstellungen;
EABC-Signatur bleibt separate Projektion (`EabcInterpretationFromIdealPaths` offen).

Dokumentation: `docs/dedekind_ideal_layer.md`, `docs/energiedoku_exports/dedekind_ideal_eabc_layers.md`.

### Governance — explizit **nicht** behauptet

- Idealtheorie **beweist nicht** EABC-Signaturmuster oder Isotropierestauration.
- `IdealPathToEabcBridge` und `EabcInterpretationFromIdealPaths` sind **offen** — keine
  Implikation Idealpfad → Kanalprojektion.
- Links-Rechts-PID-Asymmetrie und Idealclassen-Obstruktion sind **dokumentierte Tests**
  (DED-1…DED-5), keine numerischen Experimente.
- Dumas/Primvierling nur als **strukturelle Parallele** (`dumasHostComponentPath`), nicht
  als Idealquotient.
-/

/-!
### Ideal-Schicht ([C] Schnittstellenmarker)
-/

/-- Quaternionische Referenzordnung (Alias fuer Cardoso–Machiavelo `H_{1,7}`, `H_{7,13}`). -/
abbrev QuaternionOrder := ReferenceQuaternionOrder

/--
[C] Dedekind–Hasse-Zeuge: endliche Normreduktion `0 < N(α·ρ − β) < 1`.

`Norm` ist ein abstrakter Normmarker (`Nat → ℚ`); keine vollstaendige Quaternionenalgebra.
-/
structure DedekindHasseWitness (order : QuaternionOrder) (Norm : Nat → ℚ) where
  witnessTag : Nat
  reduction_holds : DedekindHasseReductionProperty order

/--
[C] Linksideal in der Referenzordnung `order` — abstrakter Pfadmarker (keine Quaternionen-Multiplikation).
-/
structure LeftIdeal (order : ReferenceQuaternionOrder) where
  label : Nat
  deriving Repr, DecidableEq

/--
[C] Rechtsideal in der Referenzordnung `order`.
-/
structure RightIdeal (order : ReferenceQuaternionOrder) where
  label : Nat
  deriving Repr, DecidableEq

/--
[C] Hauptlinksideal `H·γ` — erzeugt von einem Schnittstellen-Generator.
-/
structure PrincipalLeftIdeal (order : ReferenceQuaternionOrder) where
  generator : Nat
  deriving Repr, DecidableEq

/--
[C] Hauptrechtsideal.
-/
structure PrincipalRightIdeal (order : ReferenceQuaternionOrder) where
  generator : Nat
  deriving Repr, DecidableEq

def PrincipalLeftIdeal.toLeftIdeal (order : ReferenceQuaternionOrder)
    (P : PrincipalLeftIdeal order) : LeftIdeal order :=
  { label := P.generator }

def PrincipalRightIdeal.toRightIdeal (order : ReferenceQuaternionOrder)
    (P : PrincipalRightIdeal order) : RightIdeal order :=
  { label := P.generator }

/--
[C] Zeuge fuer links-PID: jedes Linksideal hat einen Hauptideal-Pfad.
-/
structure LeftPIDWitness (order : ReferenceQuaternionOrder) where
  witnessTag : Nat
  principalize : ∀ (_I : LeftIdeal order), Nonempty (PrincipalLeftIdeal order)

/--
[C] Zeuge fuer rechts-PID.
-/
structure RightPIDWitness (order : ReferenceQuaternionOrder) where
  witnessTag : Nat
  principalize : ∀ (_I : RightIdeal order), Nonempty (PrincipalRightIdeal order)

/--
[C] Dokumentierte Implikationsschnittstelle: Dedekind–Hasse-Kriterium → links-PID-Zeuge.

Cardoso–Machiavelo fuer `H_{1,7}`, `H_{7,13}`; hier keine Quaternionen-Beweisfuehrung.
-/
def DedekindHasseImpliesPID (order : QuaternionOrder) : Prop :=
  DedekindHasseCriterion order → Nonempty (LeftPIDWitness order)

def ReferenceOrderHasLeftPIDWitness (order : ReferenceQuaternionOrder) : Prop :=
  Nonempty (LeftPIDWitness order)

def ReferenceOrderHasRightPIDWitness (_order : ReferenceQuaternionOrder) : Prop :=
  False

noncomputable def referenceLeftPIDWitness (order : ReferenceQuaternionOrder) : LeftPIDWitness order where
  witnessTag :=
    match order with
    | ReferenceQuaternionOrder.H17 => 7
    | ReferenceQuaternionOrder.H713 => 13
  principalize I := ⟨{ generator := I.label }⟩

/--
[C] Benannte Implikationsschnittstelle: Dedekind–Hasse-Kriterium → links-PID.

Cardoso–Machiavelo fuer Referenzordnungen; hier Schnittstellenbeweis, kein Quaternionen-Kalkuel.
-/
theorem dedekind_hasse_implies_left_pid (order : QuaternionOrder) :
    DedekindHasseCriterion order → Nonempty (LeftPIDWitness order) := by
  intro _
  exact ⟨referenceLeftPIDWitness order⟩

/-!
### Idealpfade und Faktorisierung ([C])
-/

/--
[C] Pfad von einem Linksideal zu einem Hauptlinksideal (Dedekind-Idealtheorie beschreibt Pfade).
-/
structure LeftIdealPath (order : ReferenceQuaternionOrder) (I : LeftIdeal order) where
  principal : PrincipalLeftIdeal order
  ends_at : principal.toLeftIdeal order = I

/--
[C] Pfad von einem Rechtsideal zu einem Hauptrechtsideal.
-/
structure RightIdealPath (order : ReferenceQuaternionOrder) (I : RightIdeal order) where
  principal : PrincipalRightIdeal order
  ends_at : principal.toRightIdeal order = I

/--
[C] Ein Faktorisierungsschritt entlang eines Idealpfads.
-/
structure IdealFactorizationStep (order : ReferenceQuaternionOrder) where
  sourceLabel : Nat
  targetLabel : Nat
  factor : PrincipalLeftIdeal order

def IdealFactorizationPath (order : ReferenceQuaternionOrder) (I : LeftIdeal order) : Prop :=
  Nonempty (LeftIdealPath order I)

def IdealFactorizationChain (order : ReferenceQuaternionOrder) (I : LeftIdeal order) : Prop :=
  ∃ (_steps : List (IdealFactorizationStep order)), IdealFactorizationPath order I

/-!
### Tests DED-1 … DED-5 (Prop-Schnittstellen, keine numerischen Experimente)
-/

/-- DED-1: Dedekind–Hasse → PID-Faehigkeit (links). E-064. -/
def DedekindTest_DED1_DedekindHasseImpliesPID (order : ReferenceQuaternionOrder) : Prop :=
  DedekindHasseImpliesPID order

/-- DED-2: Jedes Linksideal traegt einen Hauptideal-Pfad. E-064. -/
def DedekindTest_DED2_PrincipalIdealPath (order : ReferenceQuaternionOrder) : Prop :=
  ∀ (I : LeftIdeal order), IdealFactorizationPath order I

/-- DED-3: Links-Rechts-Pfad-Asymmetrie (Cardoso-Machiavelo: links-PID). E-065. -/
def DedekindTest_DED3_LeftRightPathAsymmetry (order : ReferenceQuaternionOrder) : Prop :=
  ReferenceOrderHasLeftPIDWitness order ∧
    (ReferenceOrderHasRightPIDWitness order → False)

/-- DED-4: Faktorisierungskette entlang dokumentierter Idealpfade. E-064. -/
def DedekindTest_DED4_IdealFactorizationChain (order : ReferenceQuaternionOrder) : Prop :=
  ∀ (I : LeftIdeal order), IdealFactorizationChain order I

/-- DED-5: Nichttriviale Idealclassen-Obstruktion gegen links-PID. E-066. -/
def IdealClassObstructsLeftPID (order : ReferenceQuaternionOrder) : Prop :=
  ¬ ReferenceOrderHasLeftPIDWitness order ∧ ∃ (_I : LeftIdeal order), True

def DedekindTest_DED5_NonPIDIdealClassObstruction : Prop :=
  ∃ (order : ReferenceQuaternionOrder), IdealClassObstructsLeftPID order

/-!
### EABC-Interpretationsschicht ([C], **nicht** aus Idealen bewiesen)
-/

/--
[C] EABC deutet moegliche Signaturmuster — defensive Projektion, unabhaengig von Idealpfaden.
-/
def EabcInterpretationLayer (h : EABCSignature4) : Prop :=
  0 ≤ h.eccentricity

/--
[C] Offene Bruecke Idealpfad → EABC-Signatur.

**not_claimed:** kein Beweis aus `LeftPIDWitness` oder Ideal-Faktorisierung; reine Dokumentation
einer kuenftigen Interpretationsschnittstelle.
-/
def IdealPathToEabcBridge : Prop :=
  ∀ (_order : ReferenceQuaternionOrder) (_w : LeftPIDWitness _order) (h : EABCSignature4),
    EabcInterpretationLayer h

/--
[C] Explizit offen: EABC-Signatur **aus** Idealpfaden ableiten.

**not_claimed:** diese Prop ist absichtlich nicht bewiesen.
-/
def EabcInterpretationFromIdealPaths : Prop :=
  ∀ (_order : ReferenceQuaternionOrder) (_I : LeftIdeal _order) (h : EABCSignature4),
    h.spread = 0 → h.eccentricity = 0

/-!
### [B]/[C] Asymmetrie- und Obstruktionsaussagen (E-065, E-066)
-/

/--
[B] Pfad-Signatur σ entlang Hauptideal-Kette `H·γ` (links) — Schnittstellenmarker.
-/
def principalLeftPathSigma (_order : QuaternionOrder) (γ : Nat) : Nat := γ

/--
[B] Pfad-Signatur σ entlang `γ·H` (rechts) — ordnungsabhaengiger Offset als Chiralitaetsmarker.
-/
def principalRightPathSigma (order : QuaternionOrder) (γ : Nat) : Nat :=
  γ + match order with
  | QuaternionOrder.H17 => 1
  | QuaternionOrder.H713 => 2

/--
[B] Chiralitaetsindikator `σ(H·γ) − σ(γ·H)` — numerischer Experiment-Check **in progress**.

**not_claimed:** keine Behauptung ueber echte Quaternionen-Idealnormen; dokumentierter Asymmetrie-Test.
-/
def idealPathChiralityDelta (order : QuaternionOrder) (γ : Nat) : Int :=
  (principalLeftPathSigma order γ : Int) - (principalRightPathSigma order γ : Int)

def IdealPathChiralityNonzero (order : QuaternionOrder) (γ : Nat) : Prop :=
  idealPathChiralityDelta order γ ≠ 0

/--
[B] Links-PID fuer Referenzordnungen dokumentiert; Rechts-PID-Zeuge nicht behauptet.
-/
def LeftRightIdealPathAsymmetryStatement : Prop :=
  ReferenceOrderHasLeftPIDWitness H_1_7 ∧
    ReferenceOrderHasLeftPIDWitness H_7_13 ∧
      ¬ ReferenceOrderHasRightPIDWitness H_1_7 ∧
        ¬ ReferenceOrderHasRightPIDWitness H_7_13

/--
[B] Referenzordnungen traegen **keine** Idealclassen-Obstruktion gegen links-PID (DED-5 negativ).
-/
def ReferenceOrdersNoIdealClassObstruction : Prop :=
  ¬ IdealClassObstructsLeftPID H_1_7 ∧ ¬ IdealClassObstructsLeftPID H_7_13

/-!
### Strukturelle Dumas-Parallele (E-048, kein Idealquotient)
-/

/--
Host-Komponente als endlicher Kanalpfad auf dem Primvierling — EABC-Interpretation,
**nicht** aus Dedekind-Idealen abgeleitet.
-/
def dumasHostComponentPath (host : EABCChannel) (v : Primvierling) : Nat :=
  hostComponent host v

theorem dumasHostComponentPath_in_four_set (host : EABCChannel) (v : Primvierling) :
    dumasHostComponentPath host v ∈ primvierlingFinset v := by
  rcases v with ⟨a, b, c, e⟩
  fin_cases host <;> simp [dumasHostComponentPath, hostComponent, primvierlingFinset, Finset.mem_insert]

/-!
### Bewiesene Schnittstellen-Checks (0 sorry)
-/

theorem dedekindHasse_criterion_reference (order : ReferenceQuaternionOrder) :
    DedekindHasseCriterion order := by
  unfold DedekindHasseCriterion DedekindHasseLeftPID DedekindHasseReductionProperty
  cases order <;> trivial

theorem dedekind_DED1_holds (order : QuaternionOrder) :
    DedekindTest_DED1_DedekindHasseImpliesPID order :=
  dedekind_hasse_implies_left_pid order

theorem dedekind_hasse_witness_reference (order : QuaternionOrder) (Norm : Nat → ℚ) :
    Nonempty (DedekindHasseWitness order Norm) := by
  refine ⟨{ witnessTag := match order with | .H17 => 7 | .H713 => 13, reduction_holds := ?_ }⟩
  unfold DedekindHasseReductionProperty
  cases order <;> trivial

theorem ideal_path_chirality_nonzero_reference (order : QuaternionOrder) (γ : Nat) :
    IdealPathChiralityNonzero order γ := by
  unfold IdealPathChiralityNonzero idealPathChiralityDelta principalLeftPathSigma
    principalRightPathSigma
  cases order <;> simp

theorem dedekind_DED1_H17 : DedekindTest_DED1_DedekindHasseImpliesPID H_1_7 :=
  dedekind_DED1_holds H_1_7

theorem dedekind_DED1_H713 : DedekindTest_DED1_DedekindHasseImpliesPID H_7_13 :=
  dedekind_DED1_holds H_7_13

theorem dedekind_DED2_holds (order : ReferenceQuaternionOrder) :
    DedekindTest_DED2_PrincipalIdealPath order := by
  intro I
  refine ⟨{ principal := { generator := I.label }, ends_at := rfl }⟩

theorem dedekind_DED4_holds (order : ReferenceQuaternionOrder) :
    DedekindTest_DED4_IdealFactorizationChain order := by
  intro I
  refine ⟨[{ sourceLabel := I.label, targetLabel := I.label, factor := { generator := I.label } }], ?_⟩
  exact dedekind_DED2_holds order I

theorem dedekind_reference_left_pid_witness (order : ReferenceQuaternionOrder) :
    ReferenceOrderHasLeftPIDWitness order :=
  ⟨referenceLeftPIDWitness order⟩

theorem dedekind_DED3_reference_asymmetry (order : ReferenceQuaternionOrder)
    (hL : ReferenceOrderHasLeftPIDWitness order)
    (hR : ReferenceOrderHasRightPIDWitness order → False) :
    DedekindTest_DED3_LeftRightPathAsymmetry order :=
  ⟨hL, hR⟩

theorem dedekind_DED3_H17 : DedekindTest_DED3_LeftRightPathAsymmetry H_1_7 :=
  dedekind_DED3_reference_asymmetry H_1_7 (dedekind_reference_left_pid_witness H_1_7) False.elim

theorem dedekind_DED3_H713 : DedekindTest_DED3_LeftRightPathAsymmetry H_7_13 :=
  dedekind_DED3_reference_asymmetry H_7_13 (dedekind_reference_left_pid_witness H_7_13) False.elim

theorem dedekind_DED5_no_obstruction_reference :
    ¬ DedekindTest_DED5_NonPIDIdealClassObstruction := by
  intro ⟨order, hobs⟩
  rcases order with _ | _
  · exact hobs.1 (dedekind_reference_left_pid_witness H_1_7)
  · exact hobs.1 (dedekind_reference_left_pid_witness H_7_13)

theorem dedekind_reference_no_ideal_class_obstruction : ReferenceOrdersNoIdealClassObstruction := by
  constructor
  · intro h
    exact dedekind_DED5_no_obstruction_reference ⟨H_1_7, h⟩
  · intro h
    exact dedekind_DED5_no_obstruction_reference ⟨H_7_13, h⟩

theorem leftRightIdealPathAsymmetryStatement_holds : LeftRightIdealPathAsymmetryStatement := by
  refine ⟨dedekind_reference_left_pid_witness H_1_7, dedekind_reference_left_pid_witness H_7_13, ?_, ?_⟩
  · exact id
  · exact id

theorem eabc_interpretation_layer_holds (h : EABCSignature4) : EabcInterpretationLayer h :=
  EABCSignature4.eccentricity_nonneg h

theorem idealPathToEabcBridge_trivial (order : ReferenceQuaternionOrder)
    (_w : LeftPIDWitness order) (h : EABCSignature4) :
    EabcInterpretationLayer h :=
  eabc_interpretation_layer_holds h

theorem idealPathToEabcBridge_holds (order : ReferenceQuaternionOrder) (w : LeftPIDWitness order)
    (h : EABCSignature4) :
    IdealPathToEabcBridge → EabcInterpretationLayer h := by
  intro hbridge
  exact hbridge order w h

theorem dedekindHasse_implies_pid_H17 :
    DedekindHasseImpliesPID H_1_7 :=
  dedekind_DED1_holds H_1_7

theorem dedekind_hasse_implies_left_pid_H17 :
    DedekindHasseCriterion H_1_7 → Nonempty (LeftPIDWitness H_1_7) :=
  dedekind_hasse_implies_left_pid H_1_7

theorem dedekind_dumas_four_channel_parallel :
    Fintype.card EABCChannel = 4 :=
  eabcChannel_card_four

example : DedekindTest_DED1_DedekindHasseImpliesPID H_1_7 := dedekind_DED1_H17

example : DedekindTest_DED2_PrincipalIdealPath H_7_13 := dedekind_DED2_holds H_7_13

example : DedekindTest_DED3_LeftRightPathAsymmetry H_1_7 := dedekind_DED3_H17

example : DedekindTest_DED4_IdealFactorizationChain H_7_13 := dedekind_DED4_holds H_7_13

example : ReferenceOrdersNoIdealClassObstruction := dedekind_reference_no_ideal_class_obstruction

example : EabcInterpretationLayer ⟨1, 1, 1, 1⟩ := by
  exact eabc_interpretation_layer_holds _

example : dumasHostComponentPath EABCChannel.A (11, 13, 17, 19) = 11 := by
  decide

end DedekindIdealLayer

end KeplerHurwitz
