# Oktonionischer Collatz-Beweisversuch v1 (post-freeze)

## Governance

- **Scope:** außerhalb `audit-freeze-2026`
- **Branch:** `post-freeze/octonionic-collatz-proof-attempt`
- **Frozen:** keine Änderung an `ι_n`, `ε_n`, frozen dossier
- **Status-Tags:** `[A]` bewiesen · `[B]` empirisch · `[C]` offen

## Modul O3 — Oktonionischer Lift (EABC/Fano-Zustand)

Scaffold in `KeplerHurwitz/Collatz/Octonion/Definitions.lean`:

- `EABCClass` (`E/A/B/C` via mod 12), `IntegralOctonion`, `OctCollatzState`
- Felder: `value`, `is_odd`, `residue8 : Fin 4`, `residue12`, `valuation`, `shell`, `octDirection`
- `[A]` `liftOdd_project`, `octOddStep_intertwines`, `octOddStep_intertwines_lift`
- Fano-Richtung in `octOddStep`: Identitäts-Transport (echte Rotation = O4-Frontier)

```bash
lake build KeplerHurwitz.Collatz.Octonion.Definitions
```

## Witness-Beweiskette (O2, strikte Reihenfolge)

### 1. Definitionen `[A]` — `Definitions.lean`

```lean
def witnessExponent (L : ℕ) := 2 * L + 1
def witnessStart (L : ℕ) := 2 ^ witnessExponent L - 1
def closedWitnessValue (L j : ℕ) := 3 ^ j * 2 ^ (witnessExponent L - j) - 1
abbrev tOdd := oddCoreStep
```

- `[A]` `witnessExponent_odd`, `witnessExponent_gt`
- Legacy: `mersenneOddExponent` / `mersenneOdd` (mod-6-robuste Verschiebung; deckt sich mit `witnessStart` nur für `L ∈ {0,1}`)

Kritischer Punkt `[A]`: `nu2_one_iff_mod4_eq_three` — für ungerade `n` gilt `ν₂(3n+1)=1 ⟺ n≡3 (mod 4)`.

### 2. Elementare Startwerte `[A]` (ohne Bahnformel)

- `[A]` `three_not_dvd_two_pow_odd_sub_one`
- `[A]` `witnessStart_odd`, `witnessStart_coprime_six`, `witnessStart_gt_one`
- `[A]` `witnessStart_mod4_eq_three` (via Add-One-Trick)

### 3. Geschlossene Bahnformel `[C]` (Blocker: `Nat`-Pow-Arithmetik)

Ziel-Reihenfolge (kein Zirkelschluss):

1. `closedWitnessValue_add_one` `[A]`
2. `three_mul_closedWitnessValue_add_one` → `closedWitnessValue_step` `[C] sorry`
3. `oddCoreIterate_witnessStart_eq_closed` `[C] sorry`
4. `witnessStart_iterate_closed_form_add_one` / `_closed_form` `[C] sorry`

Index: `j < witnessExponent L` (nicht `j ≤`; bei `j = m` bricht die Formel).

### 4. Valuation `[A]` / `[C]`

- `[A]` `consecutive_valuation_one_run_zero` (Start `witnessStart L`, `L ≥ 1`)
- `[C]` `witnessStart_valuation_one`, `consecutive_valuation_one_run` (abhängig von Bahnformel)

### 5. Existenz + No-Go (getrennte Props)

```lean
def ArbitrarilyLongValuationOneRuns : Prop := ...
def UniformValuationOneRunBound : Prop := ...
theorem arbitrarily_long_runs_imply_no_uniform_bound : ...  -- [A]
theorem no_uniform_valuation_one_run_bound : ...            -- [A] via Prop-Instanz
```

- Witness für Länge `L`: `witnessStart (L + 1)` (`L = 0` leer)
- `[C]` `arbitrarily_long_valuation_one_runs` (sorry — wartet auf Schritt 3–4)
- **[A]-Aussage:** `NoUniformValuationOneRunBoundStatement := ¬ UniformValuationOneRunBound`
- **Keine** pauschale Aussage "kein endlicher Automat"
- `[C]` nur als explizite Brücke: `FiniteAutomatonWaittimeBridge`
  (`AutomatonRepresentsOddCoreDynamics` + `BadStateAcyclicity` -> `UniformValuationOneRunBound`)
- No-go nur konditional: `(Bridge ∧ ¬UniformValuationOneRunBound) -> ¬ BadStateAcyclicity A`
- Endlichkeit allein liefert keinen uniformen Bound (Zyklen im Automaten sind moeglich)

`valuationLogCorrectionAvg` (O5-Korrekturterm) unverändert.

## Build

```bash
lake build KeplerHurwitz.Collatz.Octonion.Termination
```
