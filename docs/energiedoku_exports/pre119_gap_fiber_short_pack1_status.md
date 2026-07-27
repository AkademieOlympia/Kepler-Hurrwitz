# Pre119 — GapFiberShortPack1 Status

**Tag:** `[A]` · **ClaimsFreeze:** false · **Collatz:** unbewiesen · **0 sorry**

## Kontext

Short-Pack 1 schließt die drei kleinsten offenen Short-Kandidaten
`n ∈ {4639, 8735, 9247}` mit echten first-good Valuation-Wörtern.

> **Korrektur:** Die Muster aus der Entwurfsskizze
> (`[…,1,1,1,5]`, `[…,1,2,1,4]`, `[…,1,1,3,3]`) realisieren **nicht** auf diesen
> Startwerten. Verankert sind die verifizierten first-good-Fasern.

Module:

- `KeplerHurwitz/Collatz/Pre119Draft/FiberWordBasics.lean` — minimale API
- `KeplerHurwitz/Collatz/Pre119Draft/GapFiberShortPack1.lean` — Bündel

Hinweis: Der frühere Pre119-Worktree (`pre119-cylinder-scan`) ist in diesem
Checkout nicht vorhanden; Short-Pack 1 startet hier mit einer schlanken
eigenständigen Fiber-API (ohne CoverUpTo-/∀n-Claims).

## Invarianten

| n | fiberE | m | S | Bild | Abstieg |
|--:|--------|--:|--:|------:|---------|
| 4639 | `[1,1,1,1,2,2,3,1,2,1,1,2,2,2,3]` | 15 | 25 | 1985 | ✓ |
| 8735 | `[1,1,1,1,2,2,3,2]` | 8 | 13 | 6997 | ✓ |
| 9247 | `[1,1,1,1,2,2,1,1,1,1,3,3,3]` | 13 | 21 | 7031 | ✓ |

Prefix Core-6 `[1,1,1,1,2,2]` expandiert jeweils (Bilder 13213 / 24877 / 26335);
die Kontraktion kommt erst durch das volle good-Muster.

## Lean `[A]`

- `realizes_fiber_*` / `fiberE_*_isGood` / `fiber_*_contracts`
- Bundle: `short_pack1_all_realize`, `short_pack1_all_good`, `short_pack1_all_contract`

## Epistemik

Endliche Zeugen. Kein CoverUpTo@2^21, kein Infinite Cover, kein Collatz.
