# Decision Memo: Dual-Track n₀ Governance (E-085)

**Datum:** 2026-07-05  
**Status:** Entscheidung dokumentiert — **kein Gate-Aktivierung**  
**Bezug:** E-085 `shellPrimeMatchAtFirstLoss`, Protokoll-Abschnitt [Dual-Track n₀ Governance](shell_separation_diagnostics_protocol.md#dual-track-n0-governance)

---

## Ausgangslage

Zwei unabhängige Konstruktionsschichten liefern unterschiedliche Antworten auf die Frage nach dem ersten Separationsverlust `n_0`:

| Spur | Konstruktion | Kombinatorik | `first_loss_n` (φ-Regel) |
|---|---|---|---|
| **Track A** (Primary Pre-Reg) | `canonical_from_qec_bridge` | `n + 1` | **NONE** (n = 1 … 17) |
| **Track B** (Theorematic Reference) | `energiedoku_full` | `4^n` | **2** (n ≤ 3, boundary equality) |

Ohne formale Trennung bestünde die Gefahr, Track B's `n_0 = 2` post-hoc für die arithmetische Kopplung (E-085) zu verwenden — entgegen der Pre-Registration-Regel *geometrisch blind zuerst*.

---

## Entscheidungsempfehlung

**Track A bleibt primary frozen construction** für die E-085 Pre-Registration, bis entweder:

1. ein **gate-eligible** `n_0` aus Track A unter eingefrorenem Protokoll beobachtet wird, oder
2. eine **neue Pre-Registration** Track B als alleinige Konstruktion einfriert, oder
3. eine **dokumentierte Vereinheitlichung** (`unified ι_n` mit nachweisbarer Bijektion / Prefix-Kompatibilität) beide Spuren verbindet.

**Track B liefert den ersten Hinweis** `∃ n : ShellSeparationLoss(n)` unter der theorematischen `4^n`-Konstruktion mit `theorematic_energiedoku_v1` — gelabelt **`[C]`**, exploratorisch, **nicht gate-eligible**.

**Negative Regel:** Solange Track A primary bleibt, darf `n_0 = 2` aus Track B **nicht** für `shellPrimeMatchAtFirstLoss` verwendet werden.

---

## Gate-Status

| Konstante / Feld | Wert |
|---|---|
| `SHELL_PRIME_MATCH_GATE_ACTIVE` | `false` |
| `SHELL_PRIME_MATCH_PRIMARY_TRACK` | `canonical_from_qec_bridge` |
| Track A `n_0` | `null` / NONE |
| Track B `exploratory_n_0` | `2` |
| Track B `gate_eligible` | `false` |

E-085 bleibt **GATE INACTIVE / PRE-REGISTRATION NOT COMPLETE**.

---

## Was fehlt für Gate-Aktivierung (Checklist)

- [ ] **Pfad B1:** Neue Pre-Registration, die `energiedoku_full` als **einzige** primary construction einfriert (Konstruktion, Metrik, ε_n, Suchbereich, sep, Loss-Definition, n₀-Extraktion).
- [ ] **Pfad B2:** Dokumentierte globale Bijektion / unified `ι_n` zwischen qec_bridge-Prefix (`n+1`) und EABC-Wortbaum (`4^n`) mit Prefix-Kompatibilität — **Teilweise:** interpretive Brücke für n≤3 dokumentiert (`partial_interpretive_no_global_bijection`); **gate_eligible bleibt false**
- [ ] **Pfad B3:** Beobachteter `n_0` aus Track A (canonical, n = 1 … 17) unter frozen items 1–7 — derzeit NONE für alle ε-Regeln.
- [ ] Explizite Reviewer-Freigabe der gewählten Spur **vor** Setzen von `SHELL_PRIME_MATCH_GATE_ACTIVE = true`.
- [ ] Kein Primindex, EABC-Kanal, Rest-Signal oder arithmetisches Feature in der Spur-Wahl.

**Heute erfüllt:** Keiner der drei Pfade vollständig. **Pfad B2 partial:** interpretive `ι_n`-Brücke für n≤3 dokumentiert — reicht **nicht** für Gate-Aktivierung.

---

## Path B2: Unified ι_n bridge (exploratory)

**Status (2026-07-05):** Partial interpretive bridge documented — **gate_eligible: false**.

| Artefakt | Pfad |
|---|---|
| Modul | `src/kepler_hurwitz/unified_shell_embedding.py` |
| Script | `scripts/unified_shell_embedding_bridge.py` |
| CSV | `docs/energiedoku_exports/unified_embedding_bridge_n123.csv` |
| Tests | `tests/test_unified_shell_embedding.py` |

### Ergebnis

- **Prefix-Kompatibilität** `ι_{n+1}|_{S_n} = ι_n` auf bridged Track-A-Koordinaten für n=1→2, 2→3: **verifiziert `[A]`**
- **Globale Bijektion** Prefix ↔ `ShellVertex(n)`: **nein** (`partial_interpretive_no_global_bijection`)
- **`sep_bridged` = `sep_canonical`**: ja (uniforme Vorzeichenkorrektur)
- **Gate:** `SHELL_PRIME_MATCH_GATE_ACTIVE` bleibt **`false`**

### Checklist: Partial vs Full B2

| Kriterium | Partial (heute) | Full (gate-fähig) |
|---|---|---|
| Regeln n=1,2,3 dokumentiert | ✅ | ✅ |
| `ι_{n+1}|_{S_n} = ι_n` prüfbar | ✅ `[A]` | ✅ |
| Globale Bijektion primary track | ❌ | ✅ erforderlich |
| Gate aktiviert E-085 | ❌ | Nur mit B1 oder primary-track bijection |
| Track B `n_0=2` gate-eligible | ❌ | ❌ (solange A primary) |

### Empfehlung

**Kann B2 jemals gate-fähig werden ohne Track-Wechsel?** Nur wenn eine **bewiesene Bijektion auf Track A** (nicht nur interpretive Achsenlabels) für den gesamten Pre-Reg-Bereich n=1…17 dokumentiert wird — derzeit strukturell blockiert durch `n+1` vs `4^n` Kombinatorik.

**Track B** bleibt ein **separater theorematischer Referenzstrang** `[C]`. Die B2-Brücke unterstützt Interpretation und Sign-Korrektur, ersetzt aber weder qec_bridge noch eine B1 Pre-Reg-Umstellung.

---

## Reviewer-Hinweis

Track B's n=2-Loss ist **robust** auf vollem `ShellVertex(2)` (16 Punkte, `sep = φ⁻² = ε₂`). Es handelt sich um eine **Grenzgleichheit** der boolean-Diagnostik (`sep ≤ ε`), nicht um einen Beweis von `MetricSeparationLossExists` für Track A. Die Spuren trennen **Kombinatorik und Einbettung** — Vermischung würde die Pre-Registration invalidieren.

**Artefakte:** [`shell_separation_preregistration.json`](shell_separation_preregistration.json) · [`shell_separation_diagnostics_protocol.md`](shell_separation_diagnostics_protocol.md) · `src/kepler_hurwitz/shell_separation_diagnostics.py`
