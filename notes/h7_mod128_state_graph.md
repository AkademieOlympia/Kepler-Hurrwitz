# H7 Mod-128 State Graph — Zusammenfassung

Formalisiert in `KeplerHurwitz/Collatz/H7StateGraph.lean` (Kerntheoreme) und
`KeplerHurwitz/Collatz/H7StateGraphAudit.lean` (Regressions- und Sichtprüfungen),
auf Branch `pr/11-collatz-v27-net-descent`. Zweiter Versuch, nachdem eine
vorherige, unbewiesene Arbeit (Agent `9d8a4ff2`) ohne Commit verloren ging.

## Governance

- `[A]` endliche Restklassenrechnung + arithmetische Solidität — jede Kante und
  jeder Pfad ist auf bereits bewiesene `oddCore`-Sätze zurückgeführt.
- `[C]` Interpretation der Reichweiten-/Frontier-Aussagen als Vollständigkeitsclaim
  (nur `#eval`-Sichtprüfungen in der Audit-Datei).
- **Kein** globaler Collatz-Beweis, keine Behauptung jenseits des bewiesenen
  Bereichs, keine Hochstufung von Numerik zu Theoremen.
- Kanal 3 und das eabc-Renorm-Repo wurden nicht berührt.

## Zentrales Ergebnis

Ein einheitlicher `Fin 128 → Fin 128`-Kantenbegriff für Mehrfach-Syracuse-Schritte
ist für die tieferen Verzweigungsfamilien (`ChannelSeven71Step6BranchingV215`,
`ChannelSeven71Step7BranchingV215`) **beweisbar nicht sauber darstellbar** —
jeder `oddCoreStep` verliert mindestens ein 2-adisches Bit, sodass eine
`k`-fache Komposition mehr Eingangsinformation benötigt als `mod 128` liefert.
Konkretes Gegenbeispiel: `u = 3` und `u = 131` sind beide `≡ 3 mod 128` und beide
ungerade, liefern aber verschiedene Restklassen nach dem 6. Schritt
(`h7_step6_odd_u_branch_precision_obstruction`).

Der Graph liefert daher den größten *beweisbar soliden* `Fin 128`-Teilgraphen,
der aus der aktuellen Beweisbasis extrahierbar ist:

- **`closedNetDescentUnion`**: Selbstschleife auf den sechs statisch
  geschlossenen Restklassen `{7, 15, 23, 55, 87, 119}` — trägt das
  Netto-Abstiegs-Zertifikat aus
  `bad_run_net_descent_witness_mod128_channel_seven_formal_union` (kein neuer
  mod-128-Übergang).
- **`deepLiftJ3EvenUStep`**: die **einzige** dynamisch echte Mehrschritt-Kante
  (6 `oddCoreStep`), von einem `deepLiftJ3EntryU`-Zustand (Parameter `u mod 128`,
  gerade) zu `deepLiftJ3StepU` mit Restklasse `(729u + 155) mod 128`.
- **`step6OddUBranchObstruction`**, **`step7BranchObstruction`**: beweisbar
  leere Platzhalter für die ungeraden-`u`-Zweige — explizit dokumentiert statt
  verschwiegen.

## Kontrollierte Fasern `F_ctrl = {39, 79, 95, 103} mod 128`

Von den 64 geraden `deepLiftJ3EntryU`-Restklassen `u ∈ {0, 2, …, 126}` landen via
`(729u + 155) mod 128` genau vier — bijektiv, je eine pro Zielfaser:

| `u mod 128` | `(729u+155) mod 128` |
|---|---|
| 44  | 103 |
| 84  | 79  |
| 100 | 95  |
| 108 | 39  |

Das ist der **einzige** Weg, wie dieser Graph `F_ctrl` erreicht.

## Vollständigkeitsschranke `K = 1`

`h7_reaches_controlled_iff_within_one` beweist: Erreichbarkeit einer
kontrollierten Faser über **irgendeinen** `H7Path` ist äquivalent zur
Erreichbarkeit über einen Pfad der Länge `≤ 1`. Grund: Jeder Pfad der Länge
`≥ 2` startet notwendig an einem `closedNetDescentUnion`-Zustand und bleibt dort
für immer stehen (`h7Path_length_ge_two_iff`), und diese Restklassen sind
disjunkt von `F_ctrl` (`h7_closed_disjoint_controlled`). `K = 1` ist damit eine
**bewiesene**, nicht nur vermutete, vollständige Suchschranke.

## Domäne und Frontier (von 384 Zuständen `Fin 128 × H7Position`)

- **`h7Domain`** (70 Zustände): exakte Vereinigung der beiden nichtleeren
  Kantenfamilien-Domänen — 6 geschlossene `entryMod128`-Zustände + 64 gerade
  `deepLiftJ3EntryU`-Zustände (`h7Domain_card`, `mem_h7Domain_iff`).
- **`h7ResidualFrontier`** (368 Zustände): bewiesen niemals `F_ctrl` erreichend
  (via die `K=1`-Vollständigkeitsschranke). Die restlichen 16 Zustände sind die
  12 trivialen (`residue ∈ F_ctrl`, alle 3 Positionen) plus die 4 echten
  `deepLiftJ3EntryU`-Treffer aus der Tabelle oben.
- **`h7_reaches_controlled_or_frontier`**: erschöpfende Dichotomie — jeder
  Zustand erreicht `F_ctrl` oder liegt in der Frontier, kein Drittes.

## Distanzfunktion

`h7DistanceToControlled : H7State → Option ℕ` liefert `some 0` (bereits
kontrolliert), `some 1` (ein `deepLiftJ3EvenUStep`-Schritt) oder `none`
(bewiesen unerreichbar über **jeden** Pfad, nicht nur `≤ 1` Schritte —
`h7DistanceToControlled_none_iff_unreachable`).

## Pfad-Solidität (Komposition)

- **`h7_path_sound`**: für die `entryMod128`-Familie ist die Komposition
  trivial-aber-wahr — der Zustand bewegt sich nie (`K = 0` genügt immer), weil
  die einzige ausgehende Kante die Selbstschleife ist.
- **`h7_path_sound_deepLiftJ3EvenUStep`**: für die dynamische Familie ist die
  Komposition exakt die in Teil 3 bewiesene punktweise Aussage
  (`h7_edge_deepLiftJ3EvenUStep_sound`), mit der konkreten Grundierung
  `n = channelSeven71Fiber (64u+13)`.
- **Dokumentierte Grenze**: ein positionsunabhängiger `H7AdmissibleAt`-Begriff
  (`n mod 128 = residue` für JEDE Position) wäre für `deepLiftJ3EntryU` falsch,
  da die dort gespeicherte Restklasse ein reiner Index-Parameter `u mod 128` ist,
  kein Wert aus der `oddCoreIterate`-Bahn von `n` (`486u+103 ≢ u`, `729u+155 ≢ u`
  im Allgemeinen). Der Deep-Lift-Zweig benötigt daher stets die explizite
  `u`-Grundierung statt einer generischen mod-128-Admissibility.

## Build-Status

- 0 `sorry` in `H7StateGraph.lean` und `H7StateGraphAudit.lean`.
- Vollständiger Projekt-Build (`lake build`) grün.
- Registriert in `KeplerHurwitz/Core.lean`.

## Checkpoint-Commits (Branch `pr/11-collatz-v27-net-descent`)

1. `07da7a4` — `feat(collatz): H7 edge family type and mod-128 relation scaffold`
2. `b3f7d66` — `proof(collatz): H7 edge soundness theorems (0 sorry or documented gaps)`
3. `6dfdfe0` — `proof(collatz): H7 finite reachability, domain, and residual frontier`
4. (final) — `formalize H7 mod-128 state graph and controlled-fiber reachability`
