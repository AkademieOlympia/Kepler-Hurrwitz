# Pre119 — Exponent-Extension Matrix (diagnostic `[B]`)

**Purpose:** Instance table for Core6 single-step fibers `fiberE e = Core6 ++ [e]`,
after minimal probes through `e = 9`. Supports recurrence scouting for Weg B;
**does not** claim `liftExponent`, `CompatibleNextData`, or `∀ e`.

**Governance:** `[A]` = discharged infinite lifting instances · `[B]` = matrix / congruence notes · `[C]` = uniform step / Collatz. ClaimsFreeze false.

## Discharged infinite lifting (`[A]`)

`e ∈ {4,5,6,7,8,9}` via `FiberWordAffine` + seed/margin data
(PR #13 through e=8; PR #14 adds e=9).

## API lock (before any `∀ e ≥ 8` claim)

Current `classBase` is a **finite table** (`4..11 ↦ b_e`, else `0`).
Because `ApMemberOk e 0` requires `RealizesWord (fiberE e) (classBase e)` and a
nonempty word needs an odd start, `InfiniteApLiftingHypothesis e` is **false for
`e ≥ 12` under the present definition**.

Before a universal statement: **totalize the seed** (`canonicalBase`) or
**decouple** the universal theorem from the census table.

## Instance matrix

| e | FiberWord \(W_e\) | \(S\) | period \(2^{S+1}\) | classBase \(b_e\) | wordC \(C\) | margin \(2^S-3^7\) | Margin check |
|---|-------------------|------|--------------------|-------------------|-------------|--------------------|--------------|
| 4 | `[1,1,1,1,2,2,4]` | 12 | 8192 | 6687 | 2347 | 1909 | `2347 < 6687·1909` |
| 5 | `[1,1,1,1,2,2,5]` | 13 | 16384 | 10783 | 2347 | 6005 | `2347 < 10783·6005` |
| 6 | `[1,1,1,1,2,2,6]` | 14 | 32768 | 18975 | 2347 | 14197 | `2347 < 18975·14197` |
| 7 | `[1,1,1,1,2,2,7]` | 15 | 65536 | 2591 | 2347 | 30581 | `2347 < 2591·30581` |
| 8 | `[1,1,1,1,2,2,8]` | 16 | 131072 | 100895 | 2347 | 63349 | `2347 < 100895·63349` |
| 9 | `[1,1,1,1,2,2,9]` | 17 | 262144 | 166431 | 2347 | 128885 | `2347 < 166431·128885` |
| 10 | `[1,1,1,1,2,2,10]` | 18 | 524288 | 35359 | 2347 | 259957 | formula regression |
| 11 | `[1,1,1,1,2,2,11]` | 19 | 1048576 | 297503 | 2347 | 522101 | formula regression |

## Decisive `[B]` finding: one 2-adic congruence

For \(W_e=\mathrm{fiberE}(e)\) one has \(|W_e|=7\), \(\sum W_e=e+8\), and
`wordC(W_e)=2347` **formally independent of `e`** (last exponent multiplies
`wordC [] = 0`).

From the affine identity, every realizing odd start satisfies the unique class

\[
b_e \equiv (2^{e+8}-2347)\,(3^7)^{-1} \pmod{2^{e+9}},
\qquad 0 \le b_e < 2^{e+9}.
\]

This reproduces **exactly** the census table for `e = 4..11`. Non-monotonicity
(e.g. the drop at `e=7`) is wrap-around in the dyadic module:

\[
b_{e+1} \equiv b_e + 2^{e+8} \pmod{2^{e+9}}.
\]

Example: \(18975 + 16384 = 35359 \equiv 2591 \pmod{32768}\).

### Margin (uniform sketch for `e ≥ 5`)

For `e ≥ 5`, \(2^{e+8}-3^7 \ge 6005 > 2347\). Any realizing odd seed is
≥ 1, so the margin inequality is automatic once realization holds. Formal
generic lemma → PR #15.

## Leitfragen (Weg B) — updated status

1. **Wortrekursion:** \(W_e=\mathrm{Core6}\mathbin{++}[e]\) — parametric family. `[B]`
2. **Seed-Rekursion:** not an ordinary affine map ℝ-style; exact dyadic congruence / Hensel lift. `[B]` → formal `canonicalBase` in PR #15 `[C→A]`
3. **Margin:** uniform for `e≥5` once realization is known. `[B]` → PR #15

## Roadmap

| PR | Content |
|----|---------|
| #13 | Basis `e=4..8` + FiberWordAffine |
| #14 | `e=9` probe + register CI repair + congruence diagnosis |
| #15 | `wordC` generic · uniform margin · `realizesWord_iff_affine_congruence` · `canonicalBase` · then universal infinite lifting |

## Nicht behauptet

- `CompatibleNextData` / `liftExponent` / `∀ e ≥ 8`
- CoverCertified / Collatz
