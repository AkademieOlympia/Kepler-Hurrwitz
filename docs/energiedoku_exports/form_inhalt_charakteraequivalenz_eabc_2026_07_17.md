---
title: Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell
date: 2026-07-17
status: "Lokal reproduziert und gehasht am 2026-07-17 auf Seal-Commit
         b252198c758ebeb2a14807bc1786bb78e6bb1d33; Arbeitsbaum enthielt
         unbezogene Dirty-Dateien außerhalb dieses Seals; externe
         Verifikation offen; kein Collatz-Beweis."
governance: "[B] diagnostic audit; Phase-A moduli 8..128; kein Collatz-Beweis"
---

# Form-Inhalt-Programm und Charakteräquivalenz im EABC-Modell

**Stand:** 2026-07-17  
**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku-Archiv / Bamberg Cycle-Phase (Form–Inhalt)  
**Governance:** **[B]** diagnostischer Audit — **kein** Collatz-Beweis, **keine** externe Verifikation beansprucht

**Querverweise:**

- Freeze-Notiz: [`notes/octonionic_collatz_freeze_proof_attempt_v1.md`](../../notes/octonionic_collatz_freeze_proof_attempt_v1.md)
- Theorie §5.5: [`docs/theory/bh_c11_scale_invariance_homogeneity.md`](../theory/bh_c11_scale_invariance_homogeneity.md)
- Runner:

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_cycle_phase_audit \
  --out docs/exports/cycle_phase_audit_protocol.json
```

---

## Epistemische Grenze

$$
\boxed{\text{Entwurf} \quad \neq \quad \text{Ausführung} \quad \neq \quad \text{revisionssicheres Artefakt}}
$$

---

## Statuszusammenfassung (Freeze-Kandidat)

$$
\boxed{\begin{aligned}
\text{Monolith-Topologie:}\quad& \text{schwach zusammenhängend für mod } 8 \dots 128 \text{ (Komponenten = 1)}, \\
\text{statische Invarianten:}\quad& \text{auf diesen vollständigen Räumen bewiesen ausgeschlossen}, \\
\text{Phase-C-Sperre:}\quad& \text{strukturell wirksam (jede vorwärtsabgeschlossene Teilmenge zieht den Zyklus)}, \\
\text{Phasenfaktor:}\quad& \varphi(Tx)=\varphi(x)+1\pmod\ell \quad [\ell \ge 1], \\
\text{Phasennormalisierung:}\quad& \text{nur bei eindeutigem strukturellem Anker reproduzierbar}, \\
\text{Attraktortiefe:}\quad& d(Tx)\le d(x) \text{ mit striktem Abstieg als exakte Lyapunov-Funktion}, \\
\text{Audit-Typ:}\quad& \text{Kollisionsanalyse liefert volles Witness-Paar bei Fehlschlag}, \\
\text{Bedingung } F=Q:\quad& \text{kardinalitätsminimale exakte Zielkodierung}, \\
\text{echte Kompression:}\quad& \text{ausstehend (Kosten-, Bitlängen- oder Entropieanalyse erforderlich)}, \\
\text{Verifikations-Runner:}\quad& \text{produktionsgebunden entworfen (Import ohne Dummy-Fallbacks)}.
\end{aligned}}
$$

**Ehrlichkeit (\(\ell=1\)):** Auf den Phase-A-Moduli \(8\ldots128\) ist der Attraktor \(\{1\}\). Dann ist \(\varphi\) konstant \(0\) und die Mod-1-Kovarianz trivial; die live Zielobservable ist die Transiententiefe \(d\).

**Nicht beansprucht:** Collatz-Terminierung; Lean-`[A]`-Beweis dieses Cycle-Phase-Audits; externe Reproduktion durch Dritte.

---

## Nächste operative Schritte zur Statusanhebung

Jede Anhebung auf den Grad `lokal reproduziert, gehasht, versioniert und eingefroren` erfordert den zusammenhängenden Terminalnachweis mit:

1. **Repository-Identität** (`git remote get-url origin`) und vollständigem **40-stelligen Voll-Hash** (`git rev-parse HEAD`).
2. Dem Nachweis des **sauberen Arbeitsbaums** (`git status --short`) und der **Tag-Zuordnung** (`git tag --points-at HEAD`).
3. Dem lückenlos identischen Ausgang des strukturellen **JSON-Abgleichs** (`diff -u audit-normal.json audit-optimized.json`).
4. Dem bestandenen, detaillierten Protokoll der **parametrisierten Testsuite** (`pytest tests/test_cycle_phase_compressor.py -v`).
5. Den unbestechlichen **SHA-256-Krypto-Hashes** der beteiligten Quelltexte und Protokolle.

---

## Lokaler Attestationslauf (2026-07-17)

Lauf gegen Quell-/Runner-Stand auf Parent-HEAD (vor Seal-Commit der Archivartefakte).

### 1. Repository-Identität

| Feld | Wert |
|---|---|
| `git remote get-url origin` | `https://github.com/AkademieOlympia/Kepler-Hurrwitz.git` |
| `git rev-parse HEAD` (Pre-Seal, Quellstand) | `2494be0ac6c80f09519f622b358094c1f36add70` |
| Seal-Commit (Archiv + Attestationsartefakte) | `b252198c758ebeb2a14807bc1786bb78e6bb1d33` |
| Status-Bump-Commit (dieser Status-/Hash-Eintrag) | siehe `git rev-parse HEAD` nach Push dieses Docs-only Follow-ups |

### 2. Arbeitsbaum und Tags

| Prüfung | Ergebnis |
|---|---|
| `git status --short` | **dirty** — zahlreiche unbezogene lokale Änderungen/Untracked außerhalb dieses Seals (u. a. andere Energiedoku-/Export-/Lean-Pfade). Freeze-Claim bezieht sich **nur** auf die hier gehashten Cycle-Phase-Quellen und Seal-Artefakte. |
| `git tag --points-at HEAD` | **kein Tag** |

### 3. Optimierungsunabhängigkeit (`python` vs `python -O`)

```bash
PYTHONPATH=src python -m kepler_hurwitz.run_cycle_phase_audit \
  --out docs/exports/audit-normal.json
PYTHONPATH=src python -O -m kepler_hurwitz.run_cycle_phase_audit \
  --out docs/exports/audit-optimized.json
diff -u docs/exports/audit-normal.json docs/exports/audit-optimized.json
```

| Prüfung | Ergebnis |
|---|---|
| Runner-Stdout | beide: `CYCLE PHASE AUDIT: PASSED` |
| `diff -u` JSON | **leer** (exit 0) |
| `diff -u` stdout | **leer** (exit 0) |
| Identität zu `cycle_phase_audit_protocol.json` | **identisch** |

### 4. pytest

```bash
PYTHONPATH=src pytest tests/test_cycle_phase_compressor.py -v
```

```
============================= test session starts ==============================
platform darwin -- Python 3.13.11, pytest-9.1.0
collected 21 items

tests/test_cycle_phase_compressor.py::TestRequire::test_passes_on_true PASSED
tests/test_cycle_phase_compressor.py::TestRequire::test_raises_on_false PASSED
tests/test_cycle_phase_compressor.py::TestOddCoreResidueBinding::test_matches_lean_odd_core_step PASSED
tests/test_cycle_phase_compressor.py::TestOddCoreResidueBinding::test_mod_projection_matches_odd_core_step PASSED
tests/test_cycle_phase_compressor.py::TestOddCoreResidueBinding::test_rejects_non_power_of_two PASSED
tests/test_cycle_phase_compressor.py::TestConstructCyclePhaseToy::test_phase_covariance_and_depth_descent PASSED
tests/test_cycle_phase_compressor.py::TestConstructCyclePhaseToy::test_weak_connectivity_required PASSED
tests/test_cycle_phase_compressor.py::TestConstructCyclePhaseToy::test_anchored_vs_unanchored_phase_differ_by_global_constant PASSED
tests/test_cycle_phase_compressor.py::TestConstructCyclePhaseToy::test_unique_anchor_works_on_l_gt_1_toy PASSED
tests/test_cycle_phase_compressor.py::TestConstructCyclePhaseToy::test_ambiguous_canonical_key_raises_audit_failed PASSED
tests/test_cycle_phase_compressor.py::TestAuditTargetReconstruction::test_identity_success_reports_f_q_minimal PASSED
tests/test_cycle_phase_compressor.py::TestAuditTargetReconstruction::test_depth_identity_is_minimal PASSED
tests/test_cycle_phase_compressor.py::TestAuditTargetReconstruction::test_collision_returns_full_witness_pair PASSED
tests/test_cycle_phase_compressor.py::TestAuditTargetReconstruction::test_alias_matches_target_audit PASSED
tests/test_cycle_phase_compressor.py::TestAuditTargetReconstruction::test_target_must_cover_universe PASSED
tests/test_cycle_phase_compressor.py::TestPhaseAOddCoreMonoliths::test_monolith_phase_depth_cover[8] PASSED
tests/test_cycle_phase_compressor.py::TestPhaseAOddCoreMonoliths::test_monolith_phase_depth_cover[16] PASSED
tests/test_cycle_phase_compressor.py::TestPhaseAOddCoreMonoliths::test_monolith_phase_depth_cover[32] PASSED
tests/test_cycle_phase_compressor.py::TestPhaseAOddCoreMonoliths::test_monolith_phase_depth_cover[64] PASSED
tests/test_cycle_phase_compressor.py::TestPhaseAOddCoreMonoliths::test_monolith_phase_depth_cover[128] PASSED
tests/test_cycle_phase_compressor.py::TestOptimizationFlagIndependence::test_audit_runner_stdout_identical_under_dash_o PASSED

============================== 21 passed in 0.38s ==============================
```

### 5. SHA-256 (`shasum -a 256`)

| Datei | sha256 |
|---|---|
| `src/kepler_hurwitz/cycle_phase_compressor.py` | `b4f4ea77962cc546e2284c31e2d5c1c559c9cb96c73ff5bbe7012fa4146f12ce` |
| `src/kepler_hurwitz/run_cycle_phase_audit.py` | `8593aec727ce4ad098145ef1d6ae16d6cef9290f8e9e3e73050d6f6b78fd6041` |
| `src/kepler_hurwitz/odd_core_residue.py` | `c75ef1585c1635e4fc61e51fb9115e217902a90aecd4871bc62a7c80c901ba63` |
| `tests/test_cycle_phase_compressor.py` | `ae0525b1ee715268c80b42ea56023a4b7b62ce57201917122d489fc16f7a42cb` |
| `docs/exports/cycle_phase_audit_protocol.json` | `da5fee9fda8233d7940287c21c22cb0cbb540c92c858cc5c6477679691a72127` |
| `docs/exports/audit-normal.json` | `da5fee9fda8233d7940287c21c22cb0cbb540c92c858cc5c6477679691a72127` |
| `docs/exports/audit-optimized.json` | `da5fee9fda8233d7940287c21c22cb0cbb540c92c858cc5c6477679691a72127` |

**Protokoll-Hash bestätigt:** `da5fee9f…` stimmt mit dem zuvor dokumentierten Wert in [`notes/octonionic_collatz_freeze_proof_attempt_v1.md`](../../notes/octonionic_collatz_freeze_proof_attempt_v1.md) überein.

---

## Governance-Box

```
[B] Cycle-phase / Form-Inhalt diagnostic audit
Phase-A moduli: 8, 16, 32, 64, 128
≠ Collatz proof
≠ external verification
≠ echte informationstheoretische Kompression (F=Q allein reicht nicht)
```
