# Collatz V2.9 — Large-Witness Phasenindex als Angriffsschicht

**Quelle:** `KeplerHurwitz/CollatzProofAttemptV29.lean`  
**Kernel:** `KeplerHurwitz/Collatz/Octonion/LargeWitnessPhaseVolume.lean`  
**Vorgänger:** [`docs/collatz_v27_net_descent.md`](collatz_v27_net_descent.md), V2.8

---

## Governance

| Tag | Aussage | Status |
|---|---|---|
| **`[A]`** | `large_witness_phase_index_theorem` im Collatz-Versuch verfügbar | geschlossen |
| **`[A]`** | Kanal `7` ⇒ Carrier `.C`; Kanal `3` ⇒ `.B` | geschlossen |
| **`[A]`** | `binaryContractionIndex (v₂(2⁴⁰)) = 861`; `triangularS = triangleNumber` | geschlossen |
| **`[C]`** | Kanal-`7`-Witness aus Large-Witness-Budget | offen (`sorry` via V2.8) |
| offen | globale Collatz-Termination | **nicht** behauptet (`V29DoesNotClaimGlobalCollatz`) |

> Large-Witness sichert **Exponenten-Index + Restklassen-Invarianz**.  
> Es beweist **nicht** Collatz; V2.9 startet damit einen gezielten Kanal-`7`-Angriff.

---

## Angriffsplan

1. **Carrier-Brücke:** `n ≡ 7 (mod 8)` ↔ `mod8Carrier = .C` (skalenstabil).
2. **Kontraktionsindex:** `binaryContractionIndex v₂ = S(v₂)` (E-099-Dreieck).
3. **Ziel `[C]`:** Budget + Carrier schließen `bad_run_net_descent_witness_mod8_channel_seven_v28`.

```bash
lake build KeplerHurwitz.CollatzProofAttemptV29
```
