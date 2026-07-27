# Pre119 — GapFiberClassTail4 (Parallelklasse `…4`)

**Tag:** `[A]` Vollzensus · **ClaimsFreeze:** false · **Collatz:** unbewiesen · **0 sorry**

## Muster

\[
E = [1,1,1,1,2,2,4], \qquad m=7,\ S=12,\quad 3^7=2187 < 4096=2^{12}.
\]

AP unter \(2^{21}\):

\[
n_k = 6687 + k\cdot 2^{13},\qquad k=0,\ldots,255 \quad (256\ \mathrm{Mitglieder}).
\]

Katalog-Rep: \(n_1 = 14879\) (Bild \(7945\)).

## Lean `[A]`

Modul: `GapFiberClassTail4.lean`

| Aussage | Status |
|---------|--------|
| `fiberE_tail4_isGood` | `[A]` |
| `6687` / `14879` realize+contracts | `[A]` |
| Pilot-Pack `k=0..7` | `[A]` |
| **`tail4_forall_fin256` / `tail4_forall_k_lt_256`** | **`[A]` Vollzensus** |

## Epistemik

Finite Klasse `k < 256`, kein ∀n, kein CoverCertified, kein Collatz.

Zusammen mit Tail-5 (`k < 128`) sind die beiden dominantesten Single-Step-Endklassen
nach Core-6 unter `[A]` zensusgeschlossen.
