# Pre119 — GapFiberClassTail5 (Muster-Systematisierung)

**Tag:** `[A]` Vollzensus · **ClaimsFreeze:** false · **Collatz:** unbewiesen · **0 sorry**

## Muster

\[
E = [1,1,1,1,2,2,5], \qquad m=7,\ S=13,\quad 3^7 < 2^{13}.
\]

AP unter \(2^{21}\):

\[
n_k = 10783 + k\cdot 2^{14},\qquad k=0,\ldots,127 \quad (128\ \mathrm{Mitglieder}).
\]

## Lean `[A]`

| Aussage | Status |
|---------|--------|
| `fiberE_tail5_isGood` | `[A]` |
| `realizes_fiber_10783` / contracts | `[A]` |
| Pilot-Pack `k=0..7` | `[A]` |
| **`tail5_forall_fin128` / `tail5_forall_k_lt_128`** | **`[A]` Vollzensus** |

Modul: `GapFiberClassTail5.lean`

## Epistemik

Finite Klasse `k < 128`, kein ∀n, kein CoverCertified, kein Collatz.

## Nächster optionaler Keil

Parallelklasse `…4`: Wort `[1,1,1,1,2,2,4]`, offline 256 Mitglieder,
AP `n_k = 6687 + k·2^{13}` (`k=0..255`).
