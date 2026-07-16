# H7Mod256 — Trennung der mod-128-Kollisionspaare bei 8 Bit

Separates Projekt vom versiegelten H7-mod-128-Zustandsgraphen.
Branch: `pr/11-collatz-v27-net-descent`.

## Governance

| Box | Inhalt |
|---|---|
| Trennung | **Nicht** Teil von `H7StateGraph` / `H7StateGraphAudit`. Keine Umschreibung der leeren Kantenfamilien `step6OddUBranchObstruction` / `step7BranchObstruction`. |
| `[B]` Scan | `src/kepler_hurwitz/h7_mod256_separation_scan.py` + Export `docs/exports/h7_mod256_separation_scan.json` — diagnostisch, **kein** Lean-Soliditätsbeweis für einen Fin-256-Graphen. |
| `[A]` Lean | Nur gezielte Trennungslemmata (Milestone 2), **kein** `H7StateGraph256` in diesem Milestone. |
| Scope | Kein globaler Collatz-Claim. Keine unbewiesene einwertige Fin-256-Kante. |

## Audited mod-128 obstruction (sealed)

Quelle: `KeplerHurwitz/Collatz/H7StateGraph.lean`,
`notes/h7_mod128_state_graph.md`,
`ChannelSeven71Step6BranchingV215.lean` / `…Step7…`.

| Item | Inhalt |
|---|---|
| Edge-Platzhalter | `H7EdgeFamily.step6OddUBranchObstruction`, `.step7BranchObstruction` (beide `False` auf Fin 128) |
| Hindernis-Theorem | `h7_step6_odd_u_branch_precision_obstruction` |
| Map | `syracuseOddStep(step5Terminal u)` mit `step5Terminal u = 486u + 103` |
| Dokumentiertes Paar | `u = 3` vs `u = 131` (beide ≡ 3 mod 128, ungerade) |
| Bilder mod 128 | `1171 % 128 = 19` vs `47827 % 128 = 83` |
| Affine Familie | odd-`u`/odd-`v`: `u = 4w+3`, `S⁶ = 1458w + 1171` (`step6_odd_u_odd_v_terminal`) |

## [B] Scan-Ergebnis

| Metrik | Wert |
|---|---|
| Dokumentiertes Paar mod 256 | `147` vs `211` — **getrennt** |
| Affine Δ (w → w+32) mod 256 | `64` |
| Step-6 Obstruktionspaare (odd `u≤255`, gleiche `u%128`, verschiedene Bilder mod 128) | 64 / 64 getrennt bei 256 |
| Step-7 analog (odd `v`) | 64 / 64 getrennt bei 256 |
| Odd-Restklassen, die mod 256 splitten (Step 6 / 7) | 64 / 64 |
| Paare, die noch mod 256 kollidieren | **0** |
| **Verdict** | **`separates_at_256`** |

Export: `docs/exports/h7_mod256_separation_scan.json`.

## Lean (Milestone 2)

Zieltheoreme (nach positivem `[B]`-Verdict):

- dokumentiertes Paar `3`/`131` hat verschiedene Bilder mod 256
- uniforme Aussage für die Familie `u = 4w+3` vs `u+128` (Δ ≡ 64 mod 256)

Datei (geplant): `KeplerHurwitz/Collatz/H7Mod256Separation.lean`.

## Empfohlener nächster Lean-Schritt

1. `[A]` Trennungslemmata in `H7Mod256Separation.lean` (dieses Milestone).
2. **Später:** Entwurf eines `H7StateGraph256` nur für Familien mit bewiesener Einwertigkeit mod 256 — **nicht** hier gebaut.
3. Keine Hochstufung des `[B]`-Scans zu Kanten-Solidität.

## Checkpoint

1. Python `[B]` Scan + Tests + Export + diese Notiz
2. Lean-Trennungslemmata (falls Scan positiv — ja)
