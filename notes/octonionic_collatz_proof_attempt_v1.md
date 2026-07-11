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
| O2 | `Collatz/Octonion/LongLowValuationRuns.lean` | **[C]/[A]** | Geschlossene Mersenne-Form & voller `ν₂=1`-Lauf offen; No-Go für `C=0` **[A]** |
| O3 | `Collatz/Octonion/Definitions.lean` | **[A/B]** | `OctCollatzState`, `liftOdd`, `octOddStep`, `projectOdd`, `octOddStep_intertwines` |
| O4 | `Collatz/Octonion/CompensatedEnergy.lean` | **[C]** | `Δ_comp = -16/3 + R(Q)`, Schranke `|R|≤C/q²` offen |
| O5 | `Collatz/Octonion/BlockDescentBridge.lean` | **[C]** | `octonionic_energy_to_block_descent` → V2.7 Witness |
| O6 | `Collatz/Octonion/Termination.lean` | **[C]** | Anbindung Odd-Core / V2.7 / klassisch |

## O1 — Odd-Core-Log-Cocycle [A]

Bewiesen:

- `log(S(n)/n) = log 3 - ν₂(3n+1)·log 2 + log(1 + 1/(3n))` als `oddCoreStep_log_ratio`
- k-Schritt-Cocycle `oddCoreIterate_log_cocycle`
- Äquivalenz Abstieg ↔ negatives Log-Verhältnis `oddCoreIterate_lt_iff_negative_log_ratio`

## O2 — Lange ν₂=1-Läufe & No-Go

**Offen [C]:**

- `oddCoreIterate_mersenneOdd_eq`: `S^j(2^(L+1)-1) = 2^(L+1-j)·3^j - 1`
- `consecutive_valuation_one_run`: voller Lauf `j < L`
- `consecutive_valuation_one_run_zero`, `oddCoreStep_log_ratio_pos_mersenne`

**No-Go [A] (Teilresultat):**

- `no_go_not_all_negative_compensated_drift`: Für `C = 0` kann keine Korrekturklasse **alle** ungeraden Starts mit strikt negativer kompensierter Drift liefern (Gegenbeispiel `R ≡ 0`, `n = 3`).
- `no_go_zero_correction_positive_drift`: expliziter Zeuge `n = 3`.

**Befund:** Eine beschränkte `O(1/q²)`-Korrektur mit **allgemeinem** `C` kann die universelle Ein-Schritt-Negativität nicht erzwingen; der arithmetische Kern (Mersenne-Läufe) blockiert eine globale Schranke — formal noch `[C]` für `C` beliebig und Lauf-Länge `L`.

## O5 — Engpass

`octonionic_energy_implies_block_descent` / `octonionic_energy_implies_local_shrink` verlangen eine Brücke von kompensierter oktonionischer Energie zu `BadRunNetDescentWitness` (V2.7). Offene Kette:

1. Explizites `C` aus EABC-Slice (`CompensatedEnergyResidualBound` ≠ trivial)
2. Blockweise Drift `< 1` auf Odd-Core-Größe
3. Einbindung in `CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement`

## Build

```bash
lake build KeplerHurwitz.Collatz.Octonion.Termination
```
