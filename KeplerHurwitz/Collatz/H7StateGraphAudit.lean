import KeplerHurwitz.Collatz.H7StateGraph

/-!
# H7-Zustandsgraph — Audit (`[A]`/`[C]`)

Begleitende Regressions- und Sichtprüfungen für `KeplerHurwitz.Collatz.H7StateGraph`.
Wo möglich sind die `example`-Aussagen sorry-freie `decide`-Zertifikate (nicht
nur `#eval`); für die zwei Aussagen, deren `Decidable`-Instanz eine
verschachtelte `Fintype`-Existenz kernel-reduzieren müsste (zu teuer für
`decide`), wird stattdessen `#eval` (kompiliert) als reine Zähl-Sichtprüfung
verwendet — klar als solche gekennzeichnet. Jede Änderung am Graphen muss diese
Datei weiterhin kompilieren lassen, bevor sie als "sound" gelten kann.

Governance: reine Audit-Datei, keine neuen mathematischen Behauptungen über
`H7StateGraph.lean` hinaus. `[A]` für alle `decide`-Aussagen, `[C]` für die
`#eval`-Übersichten (Interpretation/Anzeige, kein Beweis).
-/

namespace KeplerHurwitz.Collatz.H7StateGraphAudit

open KeplerHurwitz.Collatz.H7StateGraph

/-! ## Kantenfamilien: Kardinalitäten -/

/-- `[A]` Genau 4 der 384 Fintype-Elemente von `H7EdgeFamily` sind nichtleer
konstruierbar (die zwei Hindernis-Konstruktoren sind Nullelemente). -/
example : Fintype.card H7EdgeFamily = 4 := by decide

/-- `[A]` Die geschlossene Selbstschleifen-Menge hat genau `6` Elemente. -/
example : h7ClosedResiduesMod128.card = 6 := by decide

/-- `[A]` `F_ctrl` hat genau `4` Elemente. -/
example : h7ControlledFibers.card = 4 := by decide

/-- `[A]` Geschlossene Menge und `F_ctrl` sind disjunkt (bereits in
`H7StateGraph.h7_closed_disjoint_controlled` bewiesen; hier zusätzlich als
eigenständiges Regressionszertifikat). -/
example : h7ClosedResiduesMod128 ∩ h7ControlledFibers = ∅ := by decide

/-! ## Domäne -/

/-- `[A]` `h7Domain` hat exakt `70` der `384` Zustände (`6 + 64`). -/
example : h7Domain.card = 70 := h7Domain_card

/-! ## Die vier konkreten Treffer der einzigen dynamischen Kante

Von den `64` geraden `deepLiftJ3EntryU`-Restklassen `u ∈ {0,2,…,126}` landen
via `(729u+155) mod 128` genau die vier Restklassen `{44, 84, 100, 108}` in
`F_ctrl = {39, 79, 95, 103}` — je eine pro Zielfaser, bijektiv. Dies ist der
einzige Weg, wie dieser Graph `F_ctrl` überhaupt erreicht. -/

private def entryU (v : ℕ) (hv : v < 128) : H7State :=
  ⟨⟨v, hv⟩, .deepLiftJ3EntryU⟩

private def stepU (v : ℕ) (hv : v < 128) : H7State :=
  ⟨⟨v, hv⟩, .deepLiftJ3StepU⟩

/-- `[A]` `u ≡ 44`: Kante nach Restklasse `103`. -/
example : H7EdgeMod128 (entryU 44 (by decide)) (stepU 103 (by decide)) := by decide

/-- `[A]` `u ≡ 84`: Kante nach Restklasse `79`. -/
example : H7EdgeMod128 (entryU 84 (by decide)) (stepU 79 (by decide)) := by decide

/-- `[A]` `u ≡ 100`: Kante nach Restklasse `95`. -/
example : H7EdgeMod128 (entryU 100 (by decide)) (stepU 95 (by decide)) := by decide

/-- `[A]` `u ≡ 108`: Kante nach Restklasse `39`. -/
example : H7EdgeMod128 (entryU 108 (by decide)) (stepU 39 (by decide)) := by decide

-- `[C]` Anzahl der `deepLiftJ3EntryU`-Zustände mit `H7ReachesControlledDecidable`:
-- `8 = 4 + 4` — die `4` Restklassen `{39,79,95,103}` selbst (trivial "erreicht"
-- mit `K = 0`, unabhängig von Parität) plus die `4` echten `u`-Treffer
-- `{44,84,100,108}` von oben, die über die `deepLiftJ3EvenUStep`-Kante
-- (`K = 6`) in `F_ctrl` münden. Wegen der verschachtelten `Fintype`-Existenz in
-- `H7ReachesControlledDecidable` ist `decide` (Kernel-Reduktion) hier nicht
-- praktikabel — `#eval` (kompiliert) genügt für diese reine Zähl-Sichtprüfung;
-- die eigentliche `[A]`-Solidität steht bereits in
-- `H7StateGraph.h7ReachesControlledWithin_one_iff`.
#eval (Finset.univ.filter
  (fun v : Fin 128 =>
    H7ReachesControlledDecidable (⟨v, .deepLiftJ3EntryU⟩ : H7State))).card

/-! ## Residuale Frontier -/

-- `[C]` `h7ResidualFrontier.card + 16 = 384`: die `12` Zustände mit
-- `residue ∈ F_ctrl` selbst (`4` Restklassen `×` `3` Positionen, alle trivial
-- "erreicht" mit `K = 0`) plus die `4` `deepLiftJ3EntryU`-Treffer von oben ergeben
-- genau `16` Nicht-Frontier-Zustände; die restlichen `368` bilden die Frontier
-- (`#eval`-Zähl-Sichtprüfung, aus demselben Performance-Grund wie oben).
#eval h7ResidualFrontier.card + 16 == Fintype.card H7State

/-! ## `#eval`-Übersicht (`[C]`, reine Anzeige) -/

-- `[C]` Die vier `u`-Restklassen, die `F_ctrl` erreichen.
#eval (List.range 64).map (· * 2) |>.filter (fun u => (729 * u + 155) % 128 ∈ [39, 79, 95, 103])

-- `[C]` `h7Domain`-Größe zur Sichtprüfung.
#eval h7Domain.card

-- `[C]` `h7ResidualFrontier`-Größe zur Sichtprüfung.
#eval h7ResidualFrontier.card

end KeplerHurwitz.Collatz.H7StateGraphAudit
