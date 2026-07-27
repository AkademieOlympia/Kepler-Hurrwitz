# Pre119 Finite Fiber Freeze

**Status:** finite `[A]`-Front eingefroren · **ClaimsFreeze:** false · **Collatz:** unbewiesen  
**Branch:** `post-freeze/octonionic-collatz-proof-attempt` · **PR:** #13  
**Datum:** 2026-07-27

## Was zugeknotet ist (endlicher Sack)

| Baustein | Inhalt | Tag |
|----------|--------|-----|
| `FiberWordBasics` | minimale Realizes/Image/Good-API | `[A]` |
| `GapFiberShortPack1` | Zeugen 4639 / 8735 / 9247 | `[A]` |
| `GapFiberClassTail5` | Wort `[1,1,1,1,2,2,5]`, AP `10783+k·2^14`, **∀k&lt;128** | `[A]` |
| `GapFiberClassTail4` | Wort `[1,1,1,1,2,2,4]`, AP `6687+k·2^13`, **∀k&lt;256** | `[A]` |

**Zensus geschlossen:** 128 + 256 = **384** endliche Klassenmitglieder der beiden
dominantesten Core-6-Single-Step-Endklassen unter \(2^{21}\), plus Short-Pack-1.

`lake build` der genannten Module: grün · **0 sorry**.

## Was bewusst offen bleibt

| Front | Status |
|-------|--------|
| Weitere Endklassen `Core6++[e]` (`e≠4,5`) | optional, Schema-Lemma empfohlen |
| `HasGoodPrefixContinuation` / S1 ∀n | `[C]` |
| CoverUpTo-double-lift / CoverCertified | `[C]` |
| Infinite Cover / Collatz | **unbewiesen** |

## Epistemische Grenze

Dieser Freeze ist **kein** Collatz-Beweis und **keine** unendliche Zylinder-Partition.
Er schließt nur die dokumentierte finite Sample-/Klassen-Front unter `[A]`.

## Schema-Keil (nachgezogen)

`Core6SingleStepSchema.lean`: Güte für alle `e≥4`, Periode \(2^{S+1}\),
Vollzensus-Brücken e=4..7 (480 Mitglieder). Siehe
`pre119_core6_single_step_schema_status.md`.
