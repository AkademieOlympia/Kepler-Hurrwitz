---
title: EABC / Primvierling — 30-Block-Farbsymmetrie Π(Q+30)=τ(Π(Q))
date: 2026-07-25
status: "epistemic split sealed — [A] Lean color law; [B] K=16 audit; [C-H10] open"
claim_boundary: >-
  [A] coordinatewise color law under +30. [B] |R_16|=14 / |B_16|=10 finite lattice
  only. No universal |R|, no D_Π-density, no Collatz claim. Π is an order
  observable on a 4-config, not a fifth algebraic EABC object.
not_claimed:
  - "|R|=14 for all K / asymptotic pattern counts"
  - "nontrivial D_Π density or channel asymptotics (C-H10)"
  - "Collatz / Syracuse consequences from τ"
  - "Π as fifth algebraic EABC generator beyond V4 / channels"
---

> **Evidence status:** [A] Lean-Satz versiegelt · [B] K=16-Audit · [C-H10] offen  
> **Branch-Kontext:** `post-freeze/octonionic-collatz-proof-attempt`  
> **Keine Kollision** mit paralleler Collatz-G2-Arbeit auf `eabc-renorm`

# 30-Block-Farbsymmetrie — epistemische Versiegelung

## Mathematik

Auf dem 30er-Block-Shift gilt

\[
x_i\;\longmapsto\;x_i+30
\quad\Rightarrow\quad
x_i\equiv x_i+6\pmod{12}.
\]

Die induzierte Farbeinvolution auf den Kanälen \(\{E,A,B,C\}\) (Reste \(1,5,7,11\)) ist

\[
\tau=(E\;B)(A\;C)
\qquad\text{(d. h. }1\leftrightarrow 7,\;5\leftrightarrow 11\text{)}.
\]

Ziel-[A]-Satz (koordinatenweise):

\[
\Pi(Q+30)=\tau\bigl(\Pi(Q)\bigr).
\]

Klassifikationstripel:

\[
\bigl(\Phi_{\mathrm{lattice}},\; r,\; \Pi\bigr)
\qquad
\text{Π = Ordnungsobservable auf der 4-Konfiguration, kein 5. algebraisches EABC-Objekt}.
\]

## Epistemische Trennung

| Schicht | Inhalt | Status | Ort |
|---|---|---|---|
| **[A]** | `colorTau`-Involution; `toV4(n+30)=τ(toV4 n)`; `Π(Q+30)=τ(Π(Q))` | bewiesen | `KeplerHurwitz/EABC/Permutation30Block.lean` |
| **[B]** | \(|R_{16}|=14\), \(|B_{16}|=10\); τ schließt \(R\) und \(B\) auf dem endlichen K=16-Gitter | Audit (endlich) | `eabc_candidate_quad_index.py` · `audit_pi_shift30_color_tau` |
| **[C-H10]** | Stabilisierung \(K\to\infty\), nichttriviales \(D_\Pi\), asymptotische Kanalunterschiede | offen | CLAIM_REGISTER / AP-1 B-018 |

### Merksätze

1. **[A]** ist die kombinatorisch-arithmetische Farbsymmetrie unter Blockshift — unabhängig von Primzahldichte.
2. **[B]** \(|R|=14\) ist ein **endlicher** K=16-Gitterbefund; **kein** universeller Claim für alle \(K\).
3. **[C-H10]** bleibt die einzige Schicht für Dichte-/Stabilisierungsfragen; dieser Commit schließt sie nicht.

## Hooks

| Rolle | Pfad |
|---|---|
| Lean [A] | `KeplerHurwitz/EABC/Permutation30Block.lean` |
| Python API / [B]-Audit | `src/kepler_hurwitz/eabc_candidate_quad_index.py` |
| Tests | `tests/test_eabc_quad_permutations.py` |
| Theorie-Index | `docs/theory/eabc_candidate_quad_index.md` |
| V₄-Träger | `KeplerHurwitz/EABC/V4.lean` (`toV4`) |

## Build / Repro

```bash
lake env lean KeplerHurwitz/EABC/Permutation30Block.lean
PYTHONPATH=src python -m pytest tests/test_eabc_quad_permutations.py -q
```

```text
eabc_pi_30block_color_involution: epistemic split sealed 2026-07-25
[A] permutationOf_shift30   [B] |R_16|=14 audit only   [C-H10] open
```
