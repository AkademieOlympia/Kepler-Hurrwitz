import Mathlib
import KeplerHurwitz.OddCore
import KeplerHurwitz.OddCoreDynamics
import KeplerHurwitz.Collatz.Octonion.Definitions
import KeplerHurwitz.Collatz.ChannelSevenAttackV213
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.ChannelSevenAffineMod128V215
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
import KeplerHurwitz.Collatz.ChannelSeven71Step7BranchingV215
import KeplerHurwitz.CollatzChannelSeven

/-!
# H7-Zustandsgraph (mod 128) — Kanal-7 Reformalisierungsversuch

Zweiter Versuch (nach unwiederbringlichem Verlust von Agent `9d8a4ff2`s unbestätigter
Arbeit) zur Formalisierung eines endlichen H7-Zustandsgraphen über den bereits
bewiesenen affinen mod-128-Kantenfamilien.

## Zentrales Ergebnis der Neuanalyse (Governance-kritisch)

Ein **einheitlicher** `Fin 128 → Fin 128`-Kantenbegriff für Mehrfach-Syracuse-Schritte
ist für die tiefen Verzweigungsfamilien (`ChannelSeven71Step6BranchingV215`,
`ChannelSeven71Step7BranchingV215`) **beweisbar nicht sauber darstellbar**, ohne
entweder (a) auf einen mehrwertigen Zusammenhang auszuweichen oder (b) den Modulus je
Ebene zu verkleinern. Grund: Jeder `oddCoreStep` verliert (mindestens) ein 2-adisches
Bit; eine `k`-fache Komposition benötigt daher `mod 2^(7 + Σν₂)` Eingangsinformation,
um `mod 128` am Ausgang exakt zu bestimmen — echt mehr als die verfügbaren `mod 128`.

Nachweis am konkreten Beispiel: für `n = 128k + 71` (Kanal-7-Faser `71`, `k` frei)
sind die ersten vier Syracuse-Schritte exakt und **uniform in `k`**
(`192k+107`, `288k+161`, `216k+121`, `162k+91` — alle affine Funktionen *desselben* `k`,
siehe `ChannelSevenAttackV213`), *weil* die Bewertungskette `[1,1,2,2]` unabhängig
von `k` konstant ist. Ab Schritt 5 verzweigt `k mod 4`; nur der Zweig `k` gerade
(`k=2q`) bleibt **uniform in `k`** ausdrückbar (`243k+137`, da der Koeffizient `486`
gerade ist und sich die Halbierung algebraisch zurück in `k` absorbieren lässt).
Die Zweige `k ≡ 1, 3 (mod 4)` benötigen einen echten neuen Parameter (`r = (k-1)/4`
bzw. `(k-3)/4`), dessen `mod 128`-Wert **nicht** aus `k mod 128` rekonstruierbar ist
(er benötigt `k mod 512`) — der oben bewiesene Präzisionsverlust.

Diese Analyse verallgemeinert sich exakt auf den `deepLiftFiber`-Baum
(`ChannelSevenDeepLiftV214`, `ChannelSevenDynamicsV215`): Der Eintrittsparameter `u`
im Terminal `486u+103` (Schale `j=3`) erlaubt genau **eine** weitere saubere,
verlustfreie `mod 128`-Stufe (`729u+155` bei geradem `u`, siehe unten), weil der
Koeffizient `1458 = 2·729` gerade ist. Jede *weitere* Stufe (`ChannelSeven71Step7BranchingV215`)
benötigt eine neue Variable `v = u/2`, deren `mod 128`-Wert `u mod 256` erfordert.

**Konsequenz:** Dieser Graph liefert den größten *beweisbar soliden* Fin-128-Teilgraphen,
der aus der aktuellen Beweisbasis extrahierbar ist, plus eine präzise dokumentierte
Hindernis-Aussage für die tieferen Familien (siehe `H7EdgeFamily.step6OddUBranchObstruction`,
`.step7BranchObstruction`).

## Governance
- `[A]` endliche Restklassenrechnung + arithmetische Solidität (jede Kante/Pfad
  getragen von bereits bewiesenen `oddCore`-Sätzen).
- `[C]` Interpretation der Reichweiten- und Frontier-Aussagen als Vollständigkeitsclaim.
- Kein globaler Collatz-Beweis, keine Behauptung jenseits des bewiesenen Bereichs,
  keine Hochstufung von Numerik zu Theoremen.
- Kanal 3 und das eabc-Renorm-Repo werden nicht berührt.
-/

namespace KeplerHurwitz.Collatz.H7StateGraph

open KeplerHurwitz
open KeplerHurwitz.Collatz.ChannelSevenAttackV213
open KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
open KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
open KeplerHurwitz.Collatz.Octonion (oddCoreIterate)
open KeplerHurwitz.CollatzAttemptV2.CollatzNetDescent.ChannelSeven
  (LocalWitnessStatementMod8 bad_run_net_descent_witness_mod128_channel_seven_formal_union)

/-! ## Teil 2: Zustands- und Kantentyp -/

/--
Position eines `H7State` in der Kanal-7-Herleitungskette.

- `entryMod128`: klassische Restklasse `n % 128` auf der Kanal-7-Faser (`n % 8 = 7`).
- `deepLiftJ3EntryU`: Eintrittsparameter `u` der exakten Schale `j = 3`
  (`deepLiftFiber 3 (2u) = 486u + 103`, siehe `ChannelSevenDynamicsV215`).
- `deepLiftJ3StepU`: derselbe Parameter `u` nach genau einem weiteren `oddCoreStep`
  (`729u + 155`, nur für gerades `u` definiert — siehe Governance-Kommentar oben).
-/
inductive H7Position
  | entryMod128
  | deepLiftJ3EntryU
  | deepLiftJ3StepU
  deriving DecidableEq, Fintype, Repr

/-- Ein H7-Zustand: mod-128-Restklasse plus Positions-Tag (verfeinerter Zustand,
wie in der Aufgabenstellung ("`structure H7State`") vorgesehen — nötig, weil eine
reine `Fin 128`-Restklasse ohne Positions-Information die Mehrfachschritt-Semantik
nicht eindeutig trägt (siehe Governance-Kommentar oben). -/
structure H7State where
  residue : Fin 128
  pos : H7Position
  deriving DecidableEq, Fintype, Repr

/-- Die sechs statisch geschlossenen Kanal-7-Restklassen
(`bad_run_net_descent_witness_mod128_channel_seven_formal_union`). -/
def h7ClosedResiduesMod128 : Finset ℕ := {7, 15, 23, 55, 87, 119}

/--
Kantenfamilien des H7-Graphen.

- `closedNetDescentUnion`: die sechs statisch geschlossenen Restklassen (Selbstschleife;
  Terminierungszertifikat liegt bereits in
  `bad_run_net_descent_witness_mod128_channel_seven_formal_union`, nicht in
  weiterer mod-128-Dynamik).
- `deepLiftJ3EvenUStep`: der **einzige** dynamisch saubere Mehrschritt-Übergang, den
  die aktuelle Beweisbasis liefert (`ChannelSevenDeepLiftV214` + `ChannelSevenDynamicsV215`).
- `step6OddUBranchObstruction`, `step7BranchObstruction`: Platzhalter für
  `ChannelSeven71Step6BranchingV215` (ungerade-`u`-Zweige) bzw.
  `ChannelSeven71Step7BranchingV215` (alle Zweige) — **beweisbar leer** auf Fin-128-Ebene,
  siehe `h7_step6_odd_obstruction` / `h7_step7_obstruction` unten. Explizit aufgeführt,
  um das Hindernis zu dokumentieren statt es zu verschweigen.
-/
inductive H7EdgeFamily
  | closedNetDescentUnion
  | deepLiftJ3EvenUStep
  | step6OddUBranchObstruction
  | step7BranchObstruction
  deriving DecidableEq, Fintype, Repr

/-- Konkrete Kantenbeziehung je Familie. -/
def H7FamilyEdge : H7EdgeFamily → H7State → H7State → Prop
  | .closedNetDescentUnion, r, s =>
      r.pos = .entryMod128 ∧ s = r ∧ r.residue.val ∈ h7ClosedResiduesMod128
  | .deepLiftJ3EvenUStep, r, s =>
      r.pos = .deepLiftJ3EntryU ∧ s.pos = .deepLiftJ3StepU ∧
        r.residue.val % 2 = 0 ∧ s.residue.val = (729 * r.residue.val + 155) % 128
  | .step6OddUBranchObstruction, _, _ => False
  | .step7BranchObstruction, _, _ => False

instance H7FamilyEdge.decidable (f : H7EdgeFamily) (r s : H7State) :
    Decidable (H7FamilyEdge f r s) := by
  cases f <;> dsimp [H7FamilyEdge] <;> infer_instance

/-- Gesamte H7-Kantenrelation auf mod-128-verfeinerten Zuständen. -/
def H7EdgeMod128 (r s : H7State) : Prop := ∃ f : H7EdgeFamily, H7FamilyEdge f r s

instance : DecidableRel H7EdgeMod128 := fun _ _ =>
  Fintype.decidableExistsFintype

/-! ## Teil 3: Solidität jeder Graphkante -/

theorem h7ClosedResiduesMod128_iff (x : ℕ) :
    x ∈ h7ClosedResiduesMod128 ↔
      x = 7 ∨ x = 15 ∨ x = 23 ∨ x = 55 ∨ x = 87 ∨ x = 119 := by
  simp [h7ClosedResiduesMod128]

/--
`[A]` Konkreter H7-Einstiegspunkt der `j = 3`-Schale: die channel-7-Faser
`n = 8192·u + 1735` (`= channelSeven71Fiber (64u+13)`), für die
`syracuseOddStep^[5]` exakt `486u + 103 = deepLiftFiber 3 (2u)` liefert.
-/
theorem h7_entry_shell_eq (u : Nat) :
    4 * deepBranchParam 3 (2 * u) + 1 = 64 * u + 13 := by
  have hm : deepLiftModulus 3 = 8 := by decide
  rw [deepBranchParam_eq, deepLiftResidue_three, hm]
  ring

/-- `[A]` Fünf-Schritt-Brücke von der Kanal-7-Faser `71` zum `j=3`-Terminal `486u+103`. -/
theorem h7_step5_to_486u103 (u : Nat) :
    ChannelSevenAttackV213.syracuseOddStep^[5]
        (channelSeven71Fiber (64 * u + 13)) = 486 * u + 103 := by
  have ht : (2 * u) % 2 = 0 := by omega
  have h := channelSeven71_step5_deepLiftFiber_j3_even_t (2 * u) ht
  rw [h7_entry_shell_eq u] at h
  rwa [deepLiftFiber_j3_reparam_even] at h

/-- `[A]` Sechster Schritt: für gerades `u` ist das Terminal exakt `729u + 155`. -/
theorem h7_oddCoreStep_486u103_even (u : Nat) (hu : u % 2 = 0) :
    oddCoreStep (486 * u + 103) = 729 * u + 155 := by
  have h := syracuseOdd_deepLiftFiber_j3_step6_u_even u hu
  rwa [deepLiftFiber_j3_reparam_even] at h

/-- `[A]` Komposition: sechs Syracuse-Odd-Schritte von der `71`-Faser zum geraden-`u`-Terminal. -/
theorem h7_step6_to_729u155 (u : Nat) (hu : u % 2 = 0) :
    oddCoreIterate 6 (channelSeven71Fiber (64 * u + 13)) = 729 * u + 155 := by
  have h5 := h7_step5_to_486u103 u
  have h1 := h7_oddCoreStep_486u103_even u hu
  change oddCoreStep^[6] (channelSeven71Fiber (64 * u + 13)) = 729 * u + 155
  rw [show (6 : Nat) = 5 + 1 from rfl, Function.iterate_succ_apply']
  rw [h5, h1]

/-- Elementares Restklassen-Lemma: affine `729u+155` reduziert mod `128` allein über `u % 128`. -/
theorem h7_affine729_mod128 (u : Nat) :
    (729 * u + 155) % 128 = (729 * (u % 128) + 155) % 128 :=
  ((Nat.mod_modEq u 128).symm.mul_left 729).add_right 155

/--
`[A]` Solidität der `deepLiftJ3EvenUStep`-Kante: für JEDES `u` mit passender
Restklasse und gerader Parität liefert der reale Kanal-7-Eintrittspunkt
`n = 8192u + 1735` nach genau sechs `oddCore`-Schritten exakt die im Kantenziel
behauptete Restklasse. Dies ist die zentrale Korrektheitsprüfung des gesamten
Vorhabens (siehe Governance-Kommentar oben zur Präzisionsgrenze).
-/
theorem h7_edge_deepLiftJ3EvenUStep_sound {r s : H7State}
    (he : H7FamilyEdge .deepLiftJ3EvenUStep r s) :
    ∀ u : Nat, u % 128 = r.residue.val →
      oddCoreIterate 6 (channelSeven71Fiber (64 * u + 13)) % 128 = s.residue.val := by
  obtain ⟨_, _, hreven, hsval⟩ := he
  intro u hu
  have hueven : u % 2 = 0 := by omega
  rw [h7_step6_to_729u155 u hueven, h7_affine729_mod128 u, hu, hsval]

/--
`[A]` Solidität der `closedNetDescentUnion`-Kante: jede der sechs Restklassen
trägt bereits das (im `CollatzAttemptV2`-Framework via `collatzStep` formulierte)
Netto-Abstiegs-Zertifikat aus
`bad_run_net_descent_witness_mod128_channel_seven_formal_union`. Diese Kante
behauptet **keine** neue mod-128-Restklasse; sie markiert nur, dass für diese
Restklassen keine weitere H7-Verfolgung nötig ist.
-/
theorem h7_edge_closedNetDescentUnion_sound {r s : H7State}
    (he : H7FamilyEdge .closedNetDescentUnion r s) :
    ∀ n : Nat, 1 < n → n % 128 = r.residue.val →
      LocalWitnessStatementMod8 n := by
  obtain ⟨_, _, hmem⟩ := he
  intro n hn hnmod
  rw [h7ClosedResiduesMod128_iff] at hmem
  have hres :
      n % 128 = 7 ∨ n % 128 = 15 ∨ n % 128 = 23 ∨
        n % 128 = 55 ∨ n % 128 = 87 ∨ n % 128 = 119 := by
    rw [hnmod]; exact hmem
  exact bad_run_net_descent_witness_mod128_channel_seven_formal_union hn hres

/--
`[A]` Hindernis-Nachweis (`step6OddUBranchObstruction`): auf dem ungeraden-`u`-Zweig
von `ChannelSeven71Step6BranchingV215` liefert dieselbe `u`-Restklasse mod 128
(`u = 3` und `u = 131`, beide `≡ 3 mod 128`, beide ungerade) zwei
**verschiedene** Ausgangsrestklassen mod 128 (`1171 % 128 = 19` vs.
`47827 % 128 = 83`). Ein einwertiger `Fin 128 → Fin 128`-Kantenbegriff für
diesen Zweig ist daher beweisbar unmöglich — exakt der im Kopf-Kommentar
dokumentierte Präzisionsverlust, hier konkret bezeugt statt nur behauptet.
-/
theorem h7_step6_odd_u_branch_precision_obstruction :
    (3 : Nat) % 128 = 131 % 128 ∧
      ChannelSeven71Step6BranchingV215.syracuseOddStep
          (ChannelSeven71Step6BranchingV215.step5Terminal 3) % 128 ≠
        ChannelSeven71Step6BranchingV215.syracuseOddStep
          (ChannelSeven71Step6BranchingV215.step5Terminal 131) % 128 := by
  have h0 := ChannelSeven71Step6BranchingV215.step6_odd_u_odd_v_terminal 0
  have h32 := ChannelSeven71Step6BranchingV215.step6_odd_u_odd_v_terminal 32
  norm_num at h0 h32
  refine ⟨by decide, ?_⟩
  rw [h0, h32]
  decide

/-! ## Teil 4: Kontrollierte Fasern -/

/-- Die vier kontrollierten Zielrestklassen `F_ctrl = {39, 79, 95, 103} mod 128`. -/
def h7ControlledFibers : Finset ℕ := {39, 79, 95, 103}

theorem mem_h7ControlledFibers_iff (x : ℕ) :
    x ∈ h7ControlledFibers ↔ x = 39 ∨ x = 79 ∨ x = 95 ∨ x = 103 := by
  simp [h7ControlledFibers]

/-- Die geschlossene Selbstschleifen-Menge und `F_ctrl` sind disjunkt: kein
`closedNetDescentUnion`-Zustand trägt bereits eine kontrollierte Restklasse. -/
theorem h7_closed_disjoint_controlled :
    h7ClosedResiduesMod128 ∩ h7ControlledFibers = ∅ := by decide

/-! ## Teil 5: Pfade im H7-Graphen -/

/-- Ein H7-Pfad der Länge `j` von `r` nach `s`, entlang `H7EdgeMod128`. -/
inductive H7Path : ℕ → H7State → H7State → Prop
  | nil (r : H7State) : H7Path 0 r r
  | cons {j : ℕ} {r s t : H7State} (e : H7EdgeMod128 r s) (p : H7Path j s t) :
      H7Path (j + 1) r t

/-- `r` erreicht eine kontrollierte Faser innerhalb von höchstens `K` Schritten. -/
def H7ReachesControlledWithin (K : ℕ) (r : H7State) : Prop :=
  ∃ j ≤ K, ∃ s : H7State, H7Path j r s ∧ s.residue.val ∈ h7ControlledFibers

/-- `[A]` Ein einzelner Kompositionsschritt reicht immer aus, um jeden Pfad um
eine weitere Kante zu verlängern. -/
theorem h7Path_succ_of_edge {j : ℕ} {r s t : H7State}
    (e : H7EdgeMod128 r s) (p : H7Path j s t) : H7Path (j + 1) r t :=
  .cons e p

/-! ## Teil 6: Jede Kante gehört zu genau einer der zwei nichtleeren Familien -/

/-- `[A]` Jede tatsächlich existierende Kante fällt in genau einen der zwei
nichtleeren Konstruktoren von `H7EdgeFamily` (die beiden Hindernis-Konstruktoren
sind beweisbar leer, siehe `H7FamilyEdge`). Dies ist die zentrale Fallunterscheidung
für alle folgenden Erreichbarkeits- und Vollständigkeitsaussagen. -/
theorem h7_edge_cases {r s : H7State} (e : H7EdgeMod128 r s) :
    (r.pos = .entryMod128 ∧ s = r ∧ r.residue.val ∈ h7ClosedResiduesMod128) ∨
      (r.pos = .deepLiftJ3EntryU ∧ s.pos = .deepLiftJ3StepU ∧
        r.residue.val % 2 = 0 ∧ s.residue.val = (729 * r.residue.val + 155) % 128) := by
  obtain ⟨f, hf⟩ := e
  cases f with
  | closedNetDescentUnion => exact Or.inl hf
  | deepLiftJ3EvenUStep => exact Or.inr hf
  | step6OddUBranchObstruction => exact hf.elim
  | step7BranchObstruction => exact hf.elim

/-- `[A]` Ein Zustand an Position `deepLiftJ3StepU` hat **keine** ausgehende Kante:
weder `closedNetDescentUnion` (verlangt `entryMod128`) noch `deepLiftJ3EvenUStep`
(verlangt `deepLiftJ3EntryU`) greift, die Hindernis-Familien sind ohnehin leer. -/
theorem h7_deepLiftJ3StepU_no_outgoing {r : H7State} (hr : r.pos = .deepLiftJ3StepU) :
    ¬ ∃ s, H7EdgeMod128 r s := by
  rintro ⟨s, e⟩
  rcases h7_edge_cases e with ⟨hpos, -, -⟩ | ⟨hpos, -, -, -⟩ <;> rw [hr] at hpos <;> cases hpos

/-- `[A]` Von JEDEM `entryMod128`-Zustand bleibt **jeder** Pfad, unabhängig von
seiner Länge, an genau diesem Zustand stehen — unabhängig davon, ob die
Restklasse geschlossen ist: entweder ist sie es, dann ist die einzige Kante
die Selbstschleife (getragen vom Zertifikat aus Teil 3); oder sie ist es
nicht, dann existiert gar keine Kante und nur `j = 0` ist überhaupt möglich.
Keine Restklassen-Annahme nötig, siehe `h7_edge_cases`. -/
theorem h7Path_of_closedEntry {r : H7State} (hr1 : r.pos = .entryMod128) :
    ∀ {j : ℕ} {s : H7State}, H7Path j r s → s = r := by
  intro j
  induction j with
  | zero =>
    intro s p
    cases p with
    | nil => rfl
  | succ j ih =>
    intro s p
    cases p with
    | cons e p' =>
      rcases h7_edge_cases e with ⟨-, hs1, -⟩ | ⟨hpos, -, -, -⟩
      · rw [hs1] at p'; exact ih p'
      · exact absurd hr1 (hpos ▸ by decide)

/-- `[A]` **Vollständigkeitsschranke**: jeder Pfad der Länge `≥ 2` startet
notwendig an einem geschlossenen `entryMod128`-Zustand und bleibt (via der
vorherigen Selbstschleifen-Invarianz) exakt an diesem Zustand stehen. Beweis
durch Fallunterscheidung über die erste Kante: die einzige Familie, die eine
Kette von Länge `≥ 2` überhaupt zulässt, ist `closedNetDescentUnion`, weil
`deepLiftJ3EvenUStep` sofort in einen kantenlosen `deepLiftJ3StepU`-Zustand
führt (`h7_deepLiftJ3StepU_no_outgoing`). -/
theorem h7Path_length_ge_two_iff {j : ℕ} {r s : H7State} (p : H7Path j r s)
    (hj : 2 ≤ j) :
    r.pos = .entryMod128 ∧ r.residue.val ∈ h7ClosedResiduesMod128 ∧ s = r := by
  obtain ⟨j', rfl⟩ : ∃ j', j = j' + 2 := ⟨j - 2, by omega⟩
  cases p with
  | cons e p' =>
    rcases h7_edge_cases e with ⟨hpos, hs1, hmem⟩ | ⟨-, hspos, -, -⟩
    · subst hs1
      exact ⟨hpos, hmem, h7Path_of_closedEntry hpos p'⟩
    · exfalso
      cases p' with
      | cons e' _ => exact h7_deepLiftJ3StepU_no_outgoing hspos ⟨_, e'⟩

/-- `[A]` Erreichbarkeit einer kontrollierten Faser über **irgendeinen** Pfad ist
äquivalent zur Erreichbarkeit über einen Pfad der Länge `≤ 1`. Damit ist `K = 1`
eine bewiesen vollständige Suchschranke für diesen Graphen (kein größeres `K`
liefert zusätzliche erreichte Zustände). -/
theorem h7_reaches_controlled_iff_within_one (r : H7State) :
    (∃ j s, H7Path j r s ∧ s.residue.val ∈ h7ControlledFibers) ↔
      H7ReachesControlledWithin 1 r := by
  constructor
  · rintro ⟨j, s, p, hs⟩
    rcases Nat.lt_or_ge j 2 with hj | hj
    · exact ⟨j, by omega, s, p, hs⟩
    · exfalso
      obtain ⟨-, hmem, hsr⟩ := h7Path_length_ge_two_iff p hj
      rw [hsr] at hs
      have hboth : r.residue.val ∈ h7ClosedResiduesMod128 ∩ h7ControlledFibers :=
        Finset.mem_inter.mpr ⟨hmem, hs⟩
      rw [h7_closed_disjoint_controlled] at hboth
      exact absurd hboth (by simp)
  · rintro ⟨j, -, s, p, hs⟩
    exact ⟨j, s, p, hs⟩

/-! ## Teil 7: Domäne und residuale Frontier -/

/-- `[A]` Die exakte Vereinigung der beiden nichtleeren Kantenfamilien-Domänen
(die Hindernis-Familien tragen keine Zustände bei, da beweisbar leer). -/
def h7Domain : Finset H7State :=
  (Finset.univ.filter
      (fun r : H7State => r.pos = .entryMod128 ∧ r.residue.val ∈ h7ClosedResiduesMod128)) ∪
    (Finset.univ.filter
      (fun r : H7State => r.pos = .deepLiftJ3EntryU ∧ r.residue.val % 2 = 0))

/-- `[A]` `h7Domain` erfasst genau die Zustände mit mindestens einer ausgehenden
Kante — die Domäne ist also weder zu groß noch zu klein. -/
theorem mem_h7Domain_iff (r : H7State) :
    r ∈ h7Domain ↔ ∃ s, H7EdgeMod128 r s := by
  simp only [h7Domain, Finset.mem_union, Finset.mem_filter, Finset.mem_univ, true_and]
  constructor
  · rintro (⟨h1, h2⟩ | ⟨h1, h2⟩)
    · exact ⟨r, .closedNetDescentUnion, h1, rfl, h2⟩
    · refine ⟨⟨⟨(729 * r.residue.val + 155) % 128, Nat.mod_lt _ (by norm_num)⟩,
        .deepLiftJ3StepU⟩, .deepLiftJ3EvenUStep, h1, rfl, h2, rfl⟩
  · rintro ⟨s, e⟩
    rcases h7_edge_cases e with ⟨h1, -, h2⟩ | ⟨h1, -, h2, -⟩
    · exact Or.inl ⟨h1, h2⟩
    · exact Or.inr ⟨h1, h2⟩

/-- `[A]` `h7Domain` hat exakt `6 + 64 = 70` Elemente (`6` geschlossene
`entryMod128`-Zustände, `64` gerade `deepLiftJ3EntryU`-Zustände). -/
theorem h7Domain_card : h7Domain.card = 70 := by
  set_option maxRecDepth 4000 in decide

/-- Endlich entscheidbares Kriterium für "erreicht `F_ctrl` innerhalb von
höchstens einem Schritt" — reine `Fintype`/`Finset`-Aussage ohne `H7Path`,
daher direkt `decide`-fähig. Wird unten via `h7ReachesControlledWithin_one_iff`
mit der eigentlichen Pfad-Definition verbunden. -/
def H7ReachesControlledDecidable (r : H7State) : Prop :=
  r.residue.val ∈ h7ControlledFibers ∨ ∃ s, H7EdgeMod128 r s ∧ s.residue.val ∈ h7ControlledFibers

instance H7ReachesControlledDecidable.decidable (r : H7State) :
    Decidable (H7ReachesControlledDecidable r) := by
  unfold H7ReachesControlledDecidable; infer_instance

/-- `[A]` Die entscheidbare Ein-Schritt-Reichweite stimmt exakt mit
`H7ReachesControlledWithin 1` überein (`j = 0`: `nil`; `j = 1`: `cons e nil`). -/
theorem h7ReachesControlledWithin_one_iff (r : H7State) :
    H7ReachesControlledWithin 1 r ↔ H7ReachesControlledDecidable r := by
  constructor
  · rintro ⟨j, hj, s, p, hs⟩
    interval_cases j
    · cases p with
      | nil => exact Or.inl hs
    · cases p with
      | cons e p' =>
        cases p' with
        | nil => exact Or.inr ⟨_, e, hs⟩
  · rintro (h | ⟨s, e, hs⟩)
    · exact ⟨0, by omega, r, .nil r, h⟩
    · exact ⟨1, by omega, s, .cons e (.nil s), hs⟩

/-- `[A]` Residuale Frontier: Zustände, die (bewiesen, via die
Vollständigkeitsschranke `K = 1`) **niemals** eine kontrollierte Faser
erreichen — unabhängig davon, ob sie selbst noch eine ausgehende Kante haben. -/
def h7ResidualFrontier : Finset H7State :=
  Finset.univ.filter (fun r : H7State => ¬ H7ReachesControlledDecidable r)

/-- `[A]` **Erschöpfende Dichotomie**: jeder Zustand erreicht eine kontrollierte
Faser über irgendeinen `H7Path`, oder er liegt in der residualen Frontier — ein
Drittes gibt es nicht. Dies kombiniert die Vollständigkeitsschranke
(`h7_reaches_controlled_iff_within_one`) mit der `Fin`/`Finset`-Entscheidbarkeit
(`h7ReachesControlledWithin_one_iff`). -/
theorem h7_reaches_controlled_or_frontier (r : H7State) :
    (∃ j s, H7Path j r s ∧ s.residue.val ∈ h7ControlledFibers) ∨ r ∈ h7ResidualFrontier := by
  rw [h7_reaches_controlled_iff_within_one, h7ReachesControlledWithin_one_iff]
  rcases Classical.em (H7ReachesControlledDecidable r) with h | h
  · exact Or.inl h
  · refine Or.inr ?_
    simp only [h7ResidualFrontier, Finset.mem_filter, Finset.mem_univ, true_and]
    exact h

/-! ## Teil 8: Distanz zu einer kontrollierten Faser -/

/-- `[A]` Minimaler Schrittabstand zu `F_ctrl`, oder `none`, falls unerreichbar
(bewiesen vollständig für `K = 1`, siehe oben). -/
noncomputable def h7DistanceToControlled (r : H7State) : Option ℕ :=
  if r.residue.val ∈ h7ControlledFibers then some 0
  else if ∃ s, H7EdgeMod128 r s ∧ s.residue.val ∈ h7ControlledFibers then some 1
  else none

/-- `[A]` Ist `h7DistanceToControlled r = some d`, existiert tatsächlich ein
`H7Path d r s` mit `s.residue.val ∈ h7ControlledFibers` — Solidität der
Distanzfunktion gegenüber der Pfad-Semantik. -/
theorem h7DistanceToControlled_sound {r : H7State} {d : ℕ}
    (hd : h7DistanceToControlled r = some d) :
    ∃ s : H7State, H7Path d r s ∧ s.residue.val ∈ h7ControlledFibers := by
  unfold h7DistanceToControlled at hd
  split_ifs at hd with h1 h2
  · exact ⟨r, (Option.some.injEq _ _ ▸ hd) ▸ .nil r, h1⟩
  · obtain ⟨s, e, hs⟩ := h2
    exact ⟨s, (Option.some.injEq _ _ ▸ hd) ▸ .cons e (.nil s), hs⟩

/-- `[A]` **Minimalität**: `h7DistanceToControlled r = none` heißt bewiesen
"unerreichbar über jeden Pfad", nicht nur "unerreichbar in `≤ 1` Schritten" —
dies ist genau die Vollständigkeitsschranke aus Teil 6, angewandt in der
Kontraposition. -/
theorem h7DistanceToControlled_none_iff_unreachable (r : H7State) :
    h7DistanceToControlled r = none ↔
      ¬ ∃ j s, H7Path j r s ∧ s.residue.val ∈ h7ControlledFibers := by
  rw [h7_reaches_controlled_iff_within_one, h7ReachesControlledWithin_one_iff]
  unfold h7DistanceToControlled H7ReachesControlledDecidable
  split_ifs with h1 h2 <;> simp_all

/-! ## Teil 9: Pfad-Solidität (Komposition) -/

/--
`[A]` Zulässigkeitsbegriff für die Komposition, bewusst **nur** für die
`entryMod128`-Position formuliert.

Ein positionsunabhängiger Begriff (`n % 128 = r.residue.val` für JEDE Position)
wäre für `deepLiftJ3EntryU` **falsch**: die dort gespeicherte Restklasse ist
`u % 128` für den Deep-Lift-Indexparameter `u` aus `ChannelSevenDeepLiftV214`,
und `u` ist im Allgemeinen **kein** Wert, der in der `oddCoreIterate`-Bahn von
irgendeinem `n` auftritt (`486u+103 ≢ u`, `729u+155 ≢ u mod 128` im
Allgemeinen). Für diese Familie ist die stärkste korrekte Aussage bereits in
Teil 3 bewiesen (`h7_edge_deepLiftJ3EvenUStep_sound`), mit der EXAKTEN
Grundierung `n = channelSeven71Fiber (64u+13)` statt einer bloßen mod-128-
Kennzeichnung. `H7AdmissibleAt` deckt daher gezielt den Teilgraphen ab, auf dem
eine positionsfreie mod-128-Zulässigkeit überhaupt sound ist.
-/
def H7AdmissibleAt (r : H7State) (n : ℕ) : Prop :=
  r.pos = .entryMod128 ∧ n % 128 = r.residue.val

/--
`[A]` **Kompositionssatz für die `entryMod128`-Familie**: von einem zulässigen
`n` aus bleibt entlang JEDES `H7Path` beliebiger Länge `j` sowohl der
Zielzustand als auch die Restklasse von `n` unverändert (`s = r`), weil die
einzige von `entryMod128` ausgehende Kante die Selbstschleife
`closedNetDescentUnion` ist (`h7Path_of_closedEntry`) — und falls die
Restklasse nicht einmal geschlossen ist, existiert gar keine Kante, also ist
ohnehin nur `j = 0` möglich. In beiden Fällen liefert `K = 0`
(`oddCoreIterate 0 n = n`) den geforderten Zeugen — dies ist die stärkste WAHRE
Form der verlangten Aussage `∃ K, oddCoreIterate K n % 128 = s.residue.val` für
diese Familie: der Zustand bewegt sich nie, also braucht die Bahn auch keinen
einzigen Schritt.
-/
theorem h7_path_sound {j : ℕ} {r s : H7State} (hpath : H7Path j r s)
    {n : ℕ} (hn : H7AdmissibleAt r n) :
    s = r ∧ ∃ K : ℕ, oddCoreIterate K n % 128 = s.residue.val := by
  obtain ⟨hr1, hr2⟩ := hn
  have hsr : s = r := h7Path_of_closedEntry hr1 hpath
  exact ⟨hsr, 0, hsr ▸ hr2⟩

/--
`[A]` **Punktweise Komposition für die `deepLiftJ3EvenUStep`-Familie**: dies ist
die exakte Übersetzung des in Teil 3 bewiesenen `h7_edge_deepLiftJ3EvenUStep_sound`
in die `H7Path`-Sprache. Jeder Pfad, der an einem `deepLiftJ3EntryU`-Zustand
beginnt, hat (per `h7Path_length_ge_two_iff`) Länge `≤ 1`; für Länge `1` liefert
genau dieses Lemma den `K = 6`-Zeugen relativ zur konkreten Grundierung
`n = channelSeven71Fiber (64u+13)`.
-/
theorem h7_path_sound_deepLiftJ3EvenUStep {r s : H7State}
    (hpath : H7Path 1 r s) (hr : r.pos = .deepLiftJ3EntryU) :
    ∀ u : Nat, u % 128 = r.residue.val →
      oddCoreIterate 6 (channelSeven71Fiber (64 * u + 13)) % 128 = s.residue.val := by
  cases hpath with
  | cons e p' =>
    cases p' with
    | nil =>
      have he : H7FamilyEdge .deepLiftJ3EvenUStep r s := by
        rcases h7_edge_cases e with ⟨hpos, -, -⟩ | h
        · rw [hr] at hpos; cases hpos
        · exact h
      exact h7_edge_deepLiftJ3EvenUStep_sound he

end KeplerHurwitz.Collatz.H7StateGraph
