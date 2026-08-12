---
title: Exclusion of Infinite Bad Cylinders — H_Fano-Defect (Variante C)
date: 2026-07-25
branch: post-freeze/octonionic-collatz-proof-attempt
status: RESEARCH HYPOTHESIS / Prop scaffold — NOT proved
claim_boundary: >-
  Declares ExclusionOfInfiniteBadCylindersProp as an open research hypothesis.
  Conditional glue fano_defect_implies_block_descent unpacks the Prop only.
  No Collatz claim. Fano/octonion geometry does not prove Collatz.
---

# Exclusion of Infinite Bad Cylinders (Variante C)

**Collatz?** **NEIN** — Hypothese / Scaffold, kein Beweis.

## Hypothese \(H_{\mathrm{Fano\text{-}Defect}}\)

Sei \(n_0 \in \mathbb{N}_{\mathrm{odd}}\), \(n_0 > 1\), Start einer hypothetisch
unendlichen Nicht-Abstiegstrajektorie \(n_{j+1}=S(n_j)\) mit
\(n_k \ge n_0\) für alle \(k\). Dann akkumuliert der geliftete Zustand einen
Fano-Richtungsdefekt \(D\), der

1. divergiert: \(\sum D \to +\infty\),
2. einer endlichen Schalen-Schranke \(M(n_0)\) widerspricht.

**Folgerung (modellintern, unbewiesen):** ein solcher „schlechter Zylinder“
existiert in der EABC-/Fano-Gittergeometrie nicht.

## Claim-Wall

| Schicht | Rolle | Status |
|---|---|---|
| `[C]` | Modell: `fanoDefect`, `fanoShellBound` | Konstruktion / Beobachtungsgröße |
| `[B]` | `ExclusionOfInfiniteBadCylindersProp` | Prop-Scaffold, **unbewiesen** |
| `[B]` | `fano_defect_implies_block_descent` | konditionale Glue (0 `sorry`) |
| `[E]` | `examples/verify_v2_defect_scan.py` | numerische Diagnostik only |

**Nicht beansprucht**

- Collatz-Vermutung / globale Termination
- „Fano beweist Collatz“ / oktonionischer Abschluss
- Instanz von `ExclusionOfInfiniteBadCylindersProp` ohne Beweis

## Artefakte

| Artefakt | Pfad |
|---|---|
| Lean O5 | `KeplerHurwitz/Collatz/Octonion/BlockDescentBridge.lean` |
| Scan `[E]` | `examples/verify_v2_defect_scan.py` |
| Syracuse/v2 | `src/kepler_hurwitz/tao_collatz_diagnostics.py` |

```bash
lake build KeplerHurwitz.Collatz.Octonion.BlockDescentBridge
python examples/verify_v2_defect_scan.py --peaks 27 703
```

## Prüfprotokoll (offen)

1. **[E]** Numerischer Scan bekannter Peaks / beschränkter Odd-Starts — Defektsumme vs. \(M\).
2. **[B]** Akkumulationssatz: \(\nu_2=1\) über \(L\) Schritte \(\Rightarrow\) \(\sum D \ge L\cdot\log_2(3/2)\).
3. **[C]→[B]** Barriere-Lemma: unbegrenzte Defektsumme vs. Intertwining / Schalenkompaktheit.
4. **[B]** Formale Schließung der Prop — derzeit **nicht** erledigt.
