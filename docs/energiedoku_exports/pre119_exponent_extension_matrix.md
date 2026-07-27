# Pre119 — Exponent-Extension Matrix (diagnostic `[B]`)

**Purpose:** Instance table for Core6 single-step fibers `fiberE e = Core6 ++ [e]`,
after minimal probes through `e = 9`. Supports recurrence scouting for Weg B;
**does not** claim `liftExponent`, `CompatibleNextData`, or `∀ e`.

**Governance:** `[A]` = discharged infinite lifting instances · `[B]` = matrix / pattern notes · `[C]` = uniform step / Collatz. ClaimsFreeze false.

## Discharged infinite lifting (`[A]`)

`e ∈ {4,5,6,7,8,9}` via `FiberWordAffine` + seed/margin data (PR #13 through e=8; this PR adds e=9).

## Instance matrix

| e | FiberWord \(W_e\) | \(S\) | period \(2^{S+1}\) | classBase \(b_e\) | wordC \(C\) | margin \(2^S-3^7\) | Margin check |
|---|-------------------|------|--------------------|-------------------|-------------|--------------------|--------------|
| 4 | `[1,1,1,1,2,2,4]` | 12 | 8192 | 6687 | 2347 | 1909 | `2347 < 6687·1909` |
| 5 | `[1,1,1,1,2,2,5]` | 13 | 16384 | 10783 | 2347 | 6005 | `2347 < 10783·6005` |
| 6 | `[1,1,1,1,2,2,6]` | 14 | 32768 | 18975 | 2347 | 14197 | `2347 < 18975·14197` |
| 7 | `[1,1,1,1,2,2,7]` | 15 | 65536 | 2591 | 2347 | 30581 | `2347 < 2591·30581` |
| 8 | `[1,1,1,1,2,2,8]` | 16 | 131072 | 100895 | 2347 | 63349 | `2347 < 100895·63349` |
| 9 | `[1,1,1,1,2,2,9]` | 17 | 262144 | 166431 | 2347 | 128885 | `2347 < 166431·128885` |

Offline census bases (not yet infinite-lifted here): `e=10 → 35359`, `e=11 → 297503`.

## Leitfragen (Weg B) — status after e=9

1. **Wortrekursion \(W_{e+1}=F(W_e)\):**  
   Empirisch: \(W_e = \mathrm{Core6}\mathbin{+\hspace{-.2em}+}[e]\). Der einzige wechselnde Slot ist der Endexponent; Präfix `Core6` ist konstant. Das ist eine **parametrische Familie**, keine nichttriviale Wort-Faltung. `[B]`

2. **Affine Seed-Rekursion \(b_{e+1}=\alpha_e b_e+\beta_e\):**  
   Folge \(6687,10783,18975,2591,100895,166431\) ist **nicht** monoton und springt bei `e=7` abwärts. Kein globales affines \((\alpha,\beta)\) auf `{4..9}` ohne Fallunterscheidung. `[B]` / Induktionsschritt noch `[C]`

3. **Monotone Margin-Schranke:**  
   `wordC` ist konstant `2347` für alle diese Endexponenten.  
   Margin \(2^{8+e}-2187\) wächst strikt in `e`. Produkt \(b_e\cdot\mathrm{margin}(e)\) dominiert `2347` auf allen sechs Punkten — Guard ist unkritisch, sobald ein realisierender Seed existiert. `[B]`

## Nicht behauptet

- `CompatibleNextData` / `liftExponent`
- `InfiniteApLiftingHypothesis_forall_e_ge_8`
- CoverCertified / Collatz
