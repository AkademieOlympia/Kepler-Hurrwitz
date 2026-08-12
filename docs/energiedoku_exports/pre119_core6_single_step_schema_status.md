# Pre119 — Core6SingleStepSchema

**Tag:** `[A]` Schema + Zensus e=4..7 · **ClaimsFreeze:** false · **Collatz:** unbewiesen · **0 sorry**

## Schema

\[
E(e)=[1,1,1,1,2,2]{+}{+}[e],\qquad
\mathrm{isGood}(E(e))\ \text{für}\ e\ge 4\ (3^7<2^{8+e}).
\]

Beobachtete AP unter \(2^{21}\) (offline `[B]`, Kernel für e=4..7):

\[
n_k=\mathrm{base}(e)+k\cdot 2^{S+1},\qquad S=8+e,\quad
\#\{n_k<2^{21}\}=2^{12-e}.
\]

| e | S | Periode \(2^{S+1}\) | # | base | Kernel |
|--:|--:|--:|--:|--:|--------|
| 4 | 12 | \(2^{13}\) | 256 | 6687 | ∀k&lt;256 `[A]` |
| 5 | 13 | \(2^{14}\) | 128 | 10783 | ∀k&lt;128 `[A]` |
| 6 | 14 | \(2^{15}\) | 64 | 18975 | ∀k&lt;64 `[A]` |
| 7 | 15 | \(2^{16}\) | 32 | 2591 | ∀k&lt;32 `[A]` |
| 8..11 | … | … | 16..2 | siehe JSON | Basen `[A]`-Defs, Zensus optional |

## Lean

Modul: `Core6SingleStepSchema.lean` · Pack: `core6_single_step_schema_pack`

## Epistemik

Generator statt Einzelmodule. Finite Klassen unter \(2^{21}\), kein ∀n, kein Collatz.
