# H7Mod256 — Trennung und Einwertigkeit bei 8 Bit

Separates Projekt vom versiegelten H7-mod-128-Zustandsgraphen.
Branch: `pr/11-collatz-v27-net-descent`.

## Governance

| Box | Inhalt |
|---|---|
| Trennung | **Nicht** Teil von `H7StateGraph` / `H7StateGraphAudit`. Keine Umschreibung der leeren Kantenfamilien `step6OddUBranchObstruction` / `step7BranchObstruction`. |
| `[B]` Separation-Scan | `src/kepler_hurwitz/h7_mod256_separation_scan.py` — mod-128-Kollisionspaare splitten bei 256. |
| `[B]` Einwertigkeits-Scan | `src/kepler_hurwitz/h7_mod256_single_valued_scan.py` — prüft `Fin 256 → Fin 256`-Kandidatur. |
| `[A]` Lean | `H7Mod256Separation.lean` (Trennung) + `H7Mod256SingleValued.lean` (Mehrwertigkeit). |
| Scope | Kein globaler Collatz-Claim. **Kein** unbewiesener Fin-256-Graph. Trennung ≠ Einwertigkeit. |

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

## Milestone 1–2: Separation (erledigt)

| Metrik | Wert |
|---|---|
| Dokumentiertes Paar mod 256 | `147` vs `211` — **getrennt** |
| Affine Δ (w → w+32) mod 256 | `64` |
| Step-6 Obstruktionspaare (odd `u≤255`) | 64 / 64 getrennt bei 256 |
| Step-7 analog | 64 / 64 getrennt bei 256 |
| **Verdict Separation** | **`separates_at_256`** |

Lean: `H7Mod256Separation.lean` — u.a.
`step6_odd_u_odd_v_affine_separates_mod256`,
`h7_step6_odd_u_pair_3_131_separates_mod256`.

## Milestone 3: Single-valuedness Fin 256 → Fin 256

### [B] Scan-Ergebnis

Export: `docs/exports/h7_mod256_single_valued_scan.json`.

| Metrik | Wert |
|---|---|
| odd-`u`/odd-`v` Restklassen `r ≡ 3 (mod 4)` mod 256 | **0** einwertig / **64** mehrwertig |
| alle odd-`u` Restklassen mod 256 | 0 / 128 mehrwertig |
| Step-7 odd-`v` Restklassen mod 256 | 0 / 128 mehrwertig |
| Dokumentierter Witness | `u=3` vs `u=259` (beide ≡ 3 mod 256) → Bilder **147** vs **19** |
| Domain 512 → Bild mod 256 (odd-v-Schale) | 128 / 128 einwertig (empirisch) |
| Fin 512 → Fin 512 (odd-v-Schale) | 0 / 128 — weiterhin mehrwertig |
| **Verdict Einwertigkeit** | **`multi_valued_need_512`** |
| Fin-256-Kante erlaubt? | **Nein** |
| `H7StateGraph256`-Scaffold? | **Nein** (Governance) |

### 2-adische Ursache

`v₂(1458) = 1`. Für `u = 4w+3` und `Δu = 256` gilt `Δw = 64`, also
`1458·64 ≡ 128 ≢ 0 (mod 256)`.
Allgemein: `1458·2^{n-2} ≡ 2^{n-1} ≢ 0 (mod 2^n)` — gleiche Bitbreite Domain/Codomain
scheitert für diese affine Familie. Ein Bit mehr im Domain (`Δu = 512` ⇒ `Δw = 128`)
macht das Bild kongruent mod 256, aber **nicht** mod 512.

### Lean `[A]` — erledigt

Datei: `KeplerHurwitz/Collatz/H7Mod256SingleValued.lean`
(in `Core.lean` registriert).
Build: `lake build KeplerHurwitz.Collatz.H7Mod256SingleValued` grün.

| Theorem | Aussage |
|---|---|
| `step6_odd_u_odd_v_affine_multi_valued_mod256` | `(1458w+1171) ≢ (1458(w+64)+1171) (mod 256)` |
| `step6_odd_u_odd_v_u_and_u_add256_multi_valued_mod256` | für `u=4w+3`: Bilder von `u` und `u+256` verschieden mod 256 |
| `h7_step6_odd_u_pair_3_259_multi_valued_mod256` | dokumentierter Mehrwertigkeits-Witness |
| `h7_step6_odd_u_pair_3_259_images_mod256` | explizit `147` vs `19` |
| `step6_odd_u_odd_v_not_single_valued_mod256` | Negation der Fin-256-Einwertigkeitsclaim |
| `step6_odd_u_odd_v_affine_congruent_mod256_of_add128` | `w` und `w+128` kongruent im Bild mod 256 (Domain-512-Hinweis) |

## Empfohlener nächster Schritt

1. ~~Trennung mod 128→256~~ (erledigt).
2. ~~Einwertigkeit Fin 256→Fin 256~~ — **widerlegt**; kein Graph-Scaffold.
3. **Optional:** separates Projekt „Domain mod 512 / Bild mod 256“ für die affine
   odd-`v`-Schale formalisieren — **kein** automatischer `Fin 512 → Fin 512`-Graph
   (Scan: Fin512→Fin512 weiterhin mehrwertig).
4. Versiegelten mod-128-`H7StateGraph` unverändert lassen.

## Checkpoint

1. `d52a193` — Python `[B]` Separation-Scan
2. `84202de` — Lean-Trennungslemmata
3. Python `[B]` Single-valuedness-Scan (dieses Milestone)
4. Lean Mehrwertigkeits-Obstruktion (dieses Milestone)
