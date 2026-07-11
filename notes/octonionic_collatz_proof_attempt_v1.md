# Oktonionischer Collatz-Beweisversuch v1 (post-freeze)

## Governance

- **Scope:** außerhalb `audit-freeze-2026`
- **Branch:** `post-freeze/octonionic-collatz-proof-attempt`
- **Frozen:** keine Änderung an `ι_n`, `ε_n`, frozen dossier
- **Axiome:** `collatz_ergodic`, `collatz_log_average_negative` werden **nicht** geschlossen
- **Status-Tags:** `[A]` bewiesen · `[B]` empirisch · `[C]` offen

## Beweiskette (Ziel)

Oktonionische/EABC-Struktur ⇒ deterministischer Odd-Core-Abstieg ⇒ klassische Collatz-Vermutung

Bereits im Repo: `ClassicalCollatzConjecture ↔ OddCoreCollatzConjecture` (`CollatzNormShell.lean`)

## Modul-Status

| Modul | Datei | Status | Inhalt |
|-------|-------|--------|--------|
| O1 | `Collatz/Octonion/OddCoreCocycle.lean` | **[A]** | `oddCoreStep_log_ratio`, `oddCoreIterate_log_cocycle`, `oddCoreIterate_lt_iff_negative_log_ratio` |
| O2 | `Collatz/Octonion/LongLowValuationRuns.lean` | **[C]/[A]** | `arbitrarily_long_valuation_one_runs` (Witness-Skizze); Mersenne-Form mit `m(L)` offen; No-Go für `C=0` **[A]** |
| O3 | `Collatz/Octonion/Definitions.lean` | **[A/B]** | `mersenneOddExponent`, `collatzMod6U6`, `OctCollatzState`, `liftOdd`, `octOddStep`, `projectOdd`, `octOddStep_intertwines` |
| O4 | `Collatz/Octonion/CompensatedEnergy.lean` | **[C]** | `Δ_comp = -16/3 + R(Q)`, Schranke `|R|≤C/q²` offen |
| O5 | `Collatz/Octonion/BlockDescentBridge.lean` | **[C]** | `valuation_surplus_implies_block_descent`, `bad_class_maps_to_A_or_C`, `octonionic_energy_to_block_descent` → V2.7 Witness |
| O6 | `Collatz/Octonion/Termination.lean` | **[C]** | Anbindung Odd-Core / V2.7 / klassisch |

## O1 — Odd-Core-Log-Cocycle [A]

Bewiesen:

- `log(S(n)/n) = log 3 - ν₂(3n+1)·log 2 + log(1 + 1/(3n))` als `oddCoreStep_log_ratio`
- k-Schritt-Cocycle `oddCoreIterate_log_cocycle`
- Äquivalenz Abstieg ↔ negatives Log-Verhältnis `oddCoreIterate_lt_iff_negative_log_ratio`

## O2 — Lange ν₂=1-Läufe & No-Go

**Mod-6-Witness-Familie (Korrektur 2):**

Robuste Parametrisierung `m(L) := L+1` (gerades `L`) bzw. `L+2` (ungerades `L`), Start `n₀ := 2^m(L) - 1`.
Dann ist `m(L)` stets ungerade, `n₀ ≡ 1 (mod 6)`, `n₀ ∈ U_6`, mindestens `L` Schritte mit `ν₂ = 1`.
Bahn: `n_j = 3^j · 2^{m(L)-j} - 1` für `0 ≤ j < m(L) - 1`.

Lean-Ziel:
```lean
theorem arbitrarily_long_valuation_one_runs (L : Nat) :
  ∃ n : Nat, Nat.Coprime n 6 ∧ Odd n ∧
    ∀ j < L, padicValNat 2 (3 * oddCoreIterate j n + 1) = 1
```
Witness: ungerades `m > L`, `n := 2^m - 1` (implementiert via `mersenneOddExponent` / `mersenneOdd`).

**Offen [C]:**

- `oddCoreIterate_mersenneOdd_eq`: `S^j(2^m(L)-1) = 2^(m(L)-j)·3^j - 1`
- `consecutive_valuation_one_run`: voller Lauf `j < L`
- `arbitrarily_long_valuation_one_runs`: Witness-Skizze mit `sorry`
- `consecutive_valuation_one_run_zero` **[A]**, `oddCoreStep_log_ratio_pos_mersenne`

**No-Go [A] (Teilresultat):**

- `no_go_not_all_negative_compensated_drift`: Für `C = 0` kann keine Korrekturklasse **alle** ungeraden Starts mit strikt negativer kompensierter Drift liefern (Gegenbeispiel `R ≡ 0`, `n = 3`).
- `no_go_zero_correction_positive_drift`: expliziter Zeuge `n = 3`.

**Befund:** Eine beschränkte `O(1/q²)`-Korrektur mit **allgemeinem** `C` kann die universelle Ein-Schritt-Negativität nicht erzwingen; der arithmetische Kern (Mersenne-Läufe) blockiert eine globale Schranke — formal noch `[C]` für `C` beliebig und Lauf-Länge `L`.

**Schutzsatz-Kern:** Keine uniforme Wartezeit — jede erfolgreiche O5-Strategie muss über den endlichen mod-12-Automaten hinausgehen.

## O5 — Engpass

### Drei-Bausteine-Hierarchie

| Baustein | Rolle |
|---|---|
| `bad_class_maps_to_A_or_C` | endliche mod-24-Übergangsstruktur |
| `arbitrarily_long_valuation_one_runs` | No-Go für uniforme Wartezeit |
| `valuation_surplus_implies_block_descent` | exakte O5-Schnittstelle (mit Korrekturterm) |

### Block-Schwelle (Korrektur 1: asymptotisch vs. exakt)

**Asymptotischer Kernterm** (struktureller Hauptterm, nicht die vollständige endliche Schwelle):
\[
\frac1k\sum_{j<k}(\nu_2(3n_j+1)-1) > \log_2\frac32 \approx 0.5849625
\]

**Exakte endliche Schwelle** mit O(1)-Korrekturterm; dann folgt `T^k(n₀) < n₀`:
\[
\frac1k\sum_{j<k}(\nu_2(3n_j+1)-1) > \log_2\frac32 + \frac1k\sum_{j<k}\log_2\left(1+\frac1{3n_j}\right)
\]

Lean-Schnittstelle: `valuationSurplusExceedsExactThreshold` ⇒ `oddCoreIterate k n < n` via `valuation_surplus_implies_block_descent`.

`octonionic_energy_implies_block_descent` / `octonionic_energy_implies_local_shrink` verlangen eine Brücke von kompensierter oktonionischer Energie zu `BadRunNetDescentWitness` (V2.7). Offene Kette:

1. Explizites `C` aus EABC-Slice (`CompensatedEnergyResidualBound` ≠ trivial)
2. Blockweise Drift `< 1` auf Odd-Core-Größe
3. Einbindung in `CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement`

## Build

```bash
lake build KeplerHurwitz.Collatz.Octonion.Termination
```
