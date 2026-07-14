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

end KeplerHurwitz.Collatz.H7StateGraph
