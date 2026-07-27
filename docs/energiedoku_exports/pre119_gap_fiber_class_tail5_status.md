# Pre119 — GapFiberClassTail5 (Muster-Systematisierung)

**Tag:** `[A]` Piloten · `[B]` Zensus · **ClaimsFreeze:** false · **Collatz:** unbewiesen · **0 sorry**

## Muster

Exaktes first-good-Wort der Klasse:

\[
E = [1,1,1,1,2,2,5], \qquad m=7,\ S=13,\quad 3^7=2187 < 8192=2^{13}.
\]

Offline-Scan aller ungeraden \(n < 2^{21}\): **genau 128** Starter haben dieses
first-good-Wort. Sie bilden die AP

\[
n_k = 10783 + k\cdot 2^{14},\qquad k=0,\ldots,127.
\]

Alle 128 realisieren \(E\) und kontrahieren (offline `[B]`).

## Lean `[A]`

Modul: `KeplerHurwitz/Collatz/Pre119Draft/GapFiberClassTail5.lean`

| Aussage | Status |
|---------|--------|
| `fiberE_tail5_isGood` | `[A]` |
| `realizes_fiber_10783` / `fiber_10783_contracts` | `[A]` |
| AP-Piloten `k=0..7` realize+contracts | `[A]` |
| `tail5_class_pilot_pack` | `[A]` |
| Zensus 128 / Vollbeweis ∀k&lt;128 | `[B]` / offen |

## Epistemik

Finite Klassen-Piloten + offline AP-Zensus. Kein ∀n, kein CoverCertified, kein Collatz.
Nächster Keil: AP-Induktion `∀ k < 128` im Kernel, oder Parallelklasse `…4` (`[1,1,1,1,2,2,4]`).
