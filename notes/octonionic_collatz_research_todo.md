# Post-freeze Research TODO: Oktonionischer Collatz-Strang (O2/O5/O6)

Populärwissenschaftliche Darstellung (Spektrum-Stil): [`docs/reports/spektrum_octonionic_collatz_proof_attempt.md`](../docs/reports/spektrum_octonionic_collatz_proof_attempt.md).

## 1) Kurzkontext / Governance

- Geltungsbereich: nur post-freeze-Arbeit am oktonionischen Strang O2/O5/O6.
- Freeze-Regel: keine Anpassung am frozen Dossier und keine Claim-Upgrades.
- Sicherheitsregel: kein globaler Collatz-Claim aus diesem Dokument ableitbar.
- Statuslogik: `[A]` bewiesen, `[B]` empirisch/kalibriert, `[C]` offen.
- Priorisierung und Bearbeitungsreihenfolge: **O2 -> O5 -> O6**.

### Drei-Bausteine-Hierarchie (Schutzsatz-Kern)

| Baustein | Rolle |
|---|---|
| `bad_class_maps_to_A_or_C` | endliche mod-24-Übergangsstruktur |
| `arbitrarily_long_valuation_one_runs` | No-Go für uniforme Wartezeit |
| `valuation_surplus_implies_block_descent` | exakte O5-Schnittstelle (mit Korrekturterm) |

**Schutzsatz-Kern:** Jede erfolgreiche O5-Strategie muss über den endlichen mod-12-Automaten hinausgehen.

## Finaler Referenzstandard Schalenlift

- Zielstandard: **gemeinsame, nichttriviale und normverträgliche Schalenlift-Stützung**.
- Spezifikation von `Supp_m(u,v,w)` als gemeinsamer Lift:
  - `u = (ax)b`, `v = (ay)b`, `w = (az)b`, `z = x + y`
  - `g = N(a)N(b) > 1`
  - `N(x) = N(y) = N(z) = m / g` (insbesondere `g ∣ m`)
- Es gilt **keine** freie `pi(ab)`/`pi(cd)`-Alternativfassung.
- Governance-Hinweis: Diese Normierung ist rein definitorisch; keine Claim-Upgrades und kein globaler Collatz-Claim.

## 2) TODO-Liste O2/O5/O6 (priorisiert)

1. O2.0 `arbitrarily_long_valuation_one_runs` (beliebig lange `nu2 = 1`-Läufe, mod-6-Witness)
2. O2.1 `oddCoreIterate_mersenneOdd_eq` (geschlossenes Iterationsformat mit `m(L)`)
3. O2.2 `consecutive_valuation_one_run` (voller `nu2 = 1`-Lauf)
4. O2.3 `consecutive_valuation_one_run_zero` (Basisfall `j = 0`) — **[A]** mit `m(L)`-Parametrisierung
5. O2.4 `oddCoreStep_log_ratio_pos_mersenne` (positiver Drift auf Mersenne-Start)
6. O5.0 `valuation_surplus_implies_block_descent` (exakte endliche Block-Schwelle mit Korrekturterm)
7. O5.0b `bad_class_maps_to_A_or_C` (endliche mod-24-Übergangsstruktur)
8. O5.1 `octonionic_energy_implies_block_descent` (Bruecke zu V2.7-Witness)
9. O5.2 `octonionic_energy_implies_local_shrink` (lokale Schrumpfung aus Bridge)
10. O6.1 `octonionic_termination_implies_oddCoreCollatz` (Termination -> Odd-Core)
11. O6.2 `block_descent_uniform_implies_termination` (V2.7-Statement -> Termination)

## 3) TODO-Details mit Abnahmekriterien

### O2.0 `arbitrarily_long_valuation_one_runs`

- Problemstatement: Uniforme Wartezeit ist ausgeschlossen; Witness-Familie `n = 2^m - 1` mit ungeradem `m > L` liefert mindestens `L` Schritte mit `nu2 = 1`.
- Mod-6-Korrektur: `m(L) = L+1` (gerades `L`) bzw. `L+2` (ungerades `L`); dann `n in U_6` und `n ≡ 1 (mod 6)`.
- Geplante Lean-Signatur:
  - `theorem arbitrarily_long_valuation_one_runs (L : Nat) : ∃ n, Nat.Coprime n 6 ∧ Odd n ∧ ∀ j < L, padicValNat 2 (3 * oddCoreIterate j n + 1) = 1`
- Witness-Skizze: `n := mersenneOdd L` mit `mersenneOddExponent L` stets ungerade.
- Gewuenschter Status: `[C] -> [A]`.
- Abnahmekriterium: Beweis ohne `sorry`; `lake build KeplerHurwitz.Collatz.Octonion.LongLowValuationRuns` gruen.

### O2.1 `oddCoreIterate_mersenneOdd_eq`

- Problemstatement: Die arithmetische Induktionskette fuer Mersenne-Starts ist offen; damit fehlt die geschlossene Formel fuer `S^j`.
- Geplante Lean-Signatur:
  - `theorem oddCoreIterate_mersenneOdd_eq (L j : Nat) (hj : j <= mersenneOddExponent L) : oddCoreIterate j (mersenneOdd L) = 2 ^ (mersenneOddExponent L - j) * 3 ^ j - 1`
- Benoetigte Vorlemmata/Imports:
  - `import KeplerHurwitz.Collatz.Octonion.OddCoreCocycle`
  - Hilfslemmata zu `mersenneOdd`, `mersenneOddExponent`, Potenz-/Ring-Arithmetik und Divisibilitaet von `3 * n + 1`.
- Gewuenschter Status: `[C] -> [A]`.
- Abnahmekriterium:
  - Beweis `ohne sorry`.
  - `lake build KeplerHurwitz.Collatz.Octonion.LongLowValuationRuns` gruen.
- Risiko/Blocker: Nat/Int-Koerzions- und Potenzarithmetik kann die Induktionsschritte stark aufblaehen.

### O2.2 `consecutive_valuation_one_run`

- Problemstatement: Der volle Lauf `j < L` mit `padicValNat 2 (3 * S^j(n) + 1) = 1` ist noch nicht formal geschlossen.
- Geplante Lean-Signatur:
  - `theorem consecutive_valuation_one_run (L j : Nat) (_hL : 1 <= L) (hj : j < L) : padicValNat 2 (3 * oddCoreIterate j (mersenneOdd L) + 1) = 1`
- Benoetigte Vorlemmata/Imports:
  - O2.1 als direkte Voraussetzung.
  - `padicValNat_dvd_iff_le`-basierte Divisibilitaetslemmata fuer `2 | x` und `4 ∤ x`.
- Gewuenschter Status: `[C] -> [A]`.
- Abnahmekriterium:
  - Beweis `ohne sorry` mit explizitem Verweis auf O2.1.
  - `lake build KeplerHurwitz.Collatz.Octonion.LongLowValuationRuns` gruen.
- Risiko/Blocker: Uniformer Nachweis `4 ∤ (3 * ... + 1)` ueber den ganzen Bereich `j < L`.

### O2.3 `consecutive_valuation_one_run_zero`

- Problemstatement: Der Basisfall `j = 0` ist als `[A]` markiert, aber aktuell noch nicht formal eingeloest.
- Geplante Lean-Signatur:
  - `theorem consecutive_valuation_one_run_zero (L : Nat) (hL : 1 <= L) : padicValNat 2 (3 * mersenneOdd L + 1) = 1`
- Benoetigte Vorlemmata/Imports:
  - Arithmetische Normalform fuer `mersenneOdd`.
  - Optional als Korollar aus O2.2 bei `j = 0`.
- Gewuenschter Status: `[A]` (Implementierungsluecke schliessen, kein neuer Claim).
- Abnahmekriterium:
  - Beweis `ohne sorry`.
  - Keine Aenderung der Governance-Tagging-Logik.
- Risiko/Blocker: Konsistente Wiederverwendung der Lauf-Lemmata ohne zyklische Abhaengigkeit.

### O2.4 `oddCoreStep_log_ratio_pos_mersenne`

- Problemstatement: Die positive Log-Ratio fuer Mersenne-Starts haengt an der offenen `nu2 = 1`-Kette.
- Geplante Lean-Signatur:
  - `theorem oddCoreStep_log_ratio_pos_mersenne (L : Nat) (hL : 1 <= L) : 0 < oddCoreStepLogRatio (mersenneOdd L)`
- Benoetigte Vorlemmata/Imports:
  - `oddCoreStep_log_ratio_pos_of_nu2_one` aus `OddCoreCocycle`.
  - O2.3 oder O2.2 zur Bereitstellung von `padicValNat ... = 1`.
- Gewuenschter Status: `[C] -> [A]`.
- Abnahmekriterium:
  - Beweis `ohne sorry` via explizite Reduktion auf vorhandenes Positivitaetslemma.
  - Modul-Build in O2 bleibt gruen.
- Risiko/Blocker: Reihenfolge der Lemmata (Basisfall vs. allgemeiner Lauf) muss sauber entkoppelt sein.

### O5.0 `valuation_surplus_implies_block_descent`

- Problemstatement: Asymptotischer Kernterm `log₂(3/2)` allein reicht nicht; exakte endliche Schwelle braucht den `log₂(1 + 1/(3n_j))`-Korrekturterm.
- Geplante Lean-Signatur:
  - `theorem valuation_surplus_implies_block_descent {n k : Nat} (hn : 0 < n) (hk : 0 < k) (hsurplus : valuationSurplusExceedsExactThreshold n k) : oddCoreIterate k n < n`
- Governance: asymptotisch (`valuationSurplusAsymptoticThreshold`) vs. exakt (`valuationSurplusExactThreshold`) klar trennen.
- Gewuenschter Status: `[C] -> [A]`.
- Abnahmekriterium: Beweis via `oddCoreIterate_lt_iff_negative_log_ratio` und `oddCoreIterate_log_cocycle`.

### O5.0b `bad_class_maps_to_A_or_C`

- Problemstatement: Endliche mod-24-Übergangsstruktur — schlechte Restklassen landen in EABC-Kanal `A` oder `C`.
- Geplante Lean-Signaturen:
  - `def Mod24TransitionSound : Prop`
  - `def BadClassMapsToAOrCOneStepStatement : Prop`
  - `def BadClassEventuallyMapsToAOrCStatement : Prop`
  - `theorem bad_class_maps_to_A_or_C (hsound : Mod24TransitionSound) : BadClassMapsToAOrCOneStepStatement`
- Governance: Quantoren explizit trennen (`ein Schritt` vs. `eventually`), nicht vermischen.
- Governance: Endlichkeit der Tabelle allein impliziert keinen uniformen Bound; dafuer sind zusaetzliche Bedingungen (z.B. Bad-State-Azyklizitaet) noetig.
- Gewuenschter Status: `[C]`.
- Abnahmekriterium: Konkrete mod-24-Abbildung formalisiert; Build gruen.

### O5.1 `octonionic_energy_implies_block_descent`

- Problemstatement: Die zentrale Bruecke von oktonionischer kompensierter Energie zur V2.7-Bad-Run-Witness fehlt.
- Geplante Lean-Signatur:
  - `theorem octonionic_energy_implies_block_descent {n : Nat} (_hn : 1 < n) (_ho : n % 2 = 1) : octonionic_energy_to_block_descent n`
- Benoetigte Vorlemmata/Imports:
  - `import KeplerHurwitz.Collatz.Octonion.CompensatedEnergy`
  - `import KeplerHurwitz.CollatzProofAttemptV27`
  - Nicht-triviale Fassung von `CompensatedEnergyResidualBound (C : ℝ)`.
- Gewuenschter Status: `[C] -> [C]` (Brueckenentwurf formalisieren, kein Claim-Upgrade).
- Abnahmekriterium:
  - Theorem-Skelett ohne `sorry` oder mit explizitem Parameter `C` und klarer Annahmenliste.
  - `lake build KeplerHurwitz.Collatz.Octonion.BlockDescentBridge` gruen.
- Risiko/Blocker: Derzeit nur triviales Residual-Scaffold (`R(Q)=0`); fehlende Geometrieableitung fuer explizites `C`.

### O5.2 `octonionic_energy_implies_local_shrink`

- Problemstatement: Die Ableitung einer lokalen Schrumpfung aus der O5-Bruecke ist offen.
- Geplante Lean-Signatur:
  - `theorem octonionic_energy_implies_local_shrink {n : Nat} (hn : 1 < n) (ho : n % 2 = 1) : ∃ t, (collatzStep^[t]) n < n`
- Benoetigte Vorlemmata/Imports:
  - O5.1 als Kernannahme.
  - V2.7-Lemmata zur Witness->Shrink-Extraktion.
- Gewuenschter Status: `[C] -> [C]`.
- Abnahmekriterium:
  - Beweisweg als saubere Kette dokumentiert; kein versteckter globaler Claim.
  - `lake build KeplerHurwitz.Collatz.Octonion.BlockDescentBridge` gruen.
- Risiko/Blocker: Witness-zu-Iterat-Schrumpfung kann von nichttrivialen V2.7-Hilfssaetzen abhaengen.

### O6.1 `octonionic_termination_implies_oddCoreCollatz`

- Problemstatement: Die Verbindung von oktonionischer Termination zur bestehenden Odd-Core-Conjecture ist noch als Platzhalter offen.
- Geplante Lean-Signatur:
  - `theorem octonionic_termination_implies_oddCoreCollatz (_h : OctonionicOddCoreTermination) : OddCoreCollatzConjecture`
- Benoetigte Vorlemmata/Imports:
  - `import KeplerHurwitz.CollatzNormShell`
  - Entfaltung von `OctonionicOddCoreTermination` und Zielstruktur von `OddCoreCollatzConjecture`.
- Gewuenschter Status: `[C] -> [C]` (Schnittstelle schliessen, keine globale Behauptung).
- Abnahmekriterium:
  - Theorem `ohne sorry`; Beweis nur aus vorhandenen Definitionen/Brueckenannahmen.
  - `lake build KeplerHurwitz.Collatz.Octonion.Termination` gruen.
- Risiko/Blocker: Formale Uebersetzung zwischen den beiden Terminierungsformulierungen.

### O6.2 `block_descent_uniform_implies_termination`

- Problemstatement: Die uniforme V2.7-Statement-Annahme ist noch nicht in oktonionische Odd-Core-Termination ueberfuehrt.
- Geplante Lean-Signatur:
  - `theorem block_descent_uniform_implies_termination (hnet : CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement) : OctonionicOddCoreTermination`
- Benoetigte Vorlemmata/Imports:
  - `import KeplerHurwitz.Collatz.Octonion.BlockDescentBridge`
  - V2.7-Terminations-/Net-Descent-Transferlemmata.
- Gewuenschter Status: `[C] -> [C]`.
- Abnahmekriterium:
  - Beweis- oder Parametrisierungspfad explizit; kein `sorry` in O6-Zieltheorem.
  - `lake build KeplerHurwitz.Collatz.Octonion.Termination` gruen.
- Risiko/Blocker: Abhaengigkeit von externer V2.7-API-Stabilitaet und passender Statement-Instanziierung.

## 3b) Freeze-Strang (Einfrierung im nicht-assoziativen Raum) — parallel zu O2/O5/O6

Siehe [`notes/octonionic_collatz_freeze_proof_attempt_v1.md`](octonionic_collatz_freeze_proof_attempt_v1.md).

- Lean: `KeplerHurwitz/Collatz/Octonion/FreezeProofAttemptV1.lean` (`FreezePredicate`, Fano-Witness `[A]`)
- Python `[B]/[C]`: `src/kepler_hurwitz/octonionic_collatz_freeze_diagnostic.py`
- **Nicht** geschlossen: `bad_run_net_descent_witness_of_mod4_three`
- Erreicht: `diskAxisParity_collatzOctEmbed_oddCoreStep` (+ Kanal-7 `triadBaseParity`); volle Summenparität / Hurwitz / χ₇ gescheitert
- Nächstes Lean-Ziel: nichtkonstante endlichwertige Invariante auf abgeschlossener Odd-Core-Unterklasse (ohne Net-Descent-Claim)

```bash
lake build KeplerHurwitz.Collatz.Octonion.FreezeProofAttemptV1
PYTHONPATH=src pytest tests/test_octonionic_collatz_freeze_diagnostic.py -q
```

## 4) Milestones

- **M1 (O2):** Arithmetische Kernluecken schliessen (`oddCoreIterate_mersenneOdd_eq`, `consecutive_valuation_one_run`, `consecutive_valuation_one_run_zero`, `oddCoreStep_log_ratio_pos_mersenne`) mit modularem Build-Erfolg.
- **M2 (O5):** Brueckenpfad O4/O5 stabilisieren; Annahmen (insb. explizites `C`) sichtbar machen und O5-Theoreme buildbar machen.
- **M3 (O6):** End-to-End-Terminationsschnittstelle O5->O6 konsolidieren; keine globalen Claims, nur formale Route und Build-Stabilitaet.
- **M0-Freeze:** Algebraische Einfrierung als Scaffold; Brücken-Hypothesen bleiben `[C]` / unclaimed.

## 5) Test-/Build-Checkliste

```bash
lake build KeplerHurwitz.Collatz.Octonion.LongLowValuationRuns
lake build KeplerHurwitz.Collatz.Octonion.CompensatedEnergy
lake build KeplerHurwitz.Collatz.Octonion.BlockDescentBridge
lake build KeplerHurwitz.Collatz.Octonion.Termination
```

Optionaler Gesamtcheck fuer den Strang:

```bash
lake build KeplerHurwitz.Collatz.Octonion.Termination KeplerHurwitz.Collatz.Octonion.BlockDescentBridge KeplerHurwitz.Collatz.Octonion.LongLowValuationRuns
```
