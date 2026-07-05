---
title: Destillierte Projektparameter — Lift, Schnitt, Projektion
date: 2026-07-05
status: "[B]/[C]"
claim_boundary: >-
  Parameter destillieren ja; Identifikation behaupten nein. Kepler-Namen sind
  Analogiesprache [C], keine physikalische Identifikation von Quaternionen und
  Keplerellipsen.
evidence_id: E-075
---

# Destillierte Projektparameter

**Stand:** 5. Juli 2026  
**Implementierung:** `src/kepler_hurwitz/diagnostics.py`, Signatur-Basis `src/kepler_hurwitz/signatures.py`  
**Atlas (Top-8 Primär-API):** [`../diagnostics_parameter_atlas.md`](../diagnostics_parameter_atlas.md)  
**Brücke:** [`kepler_quaternion_lift_projection.md`](kepler_quaternion_lift_projection.md)

---

## Governance

\[
\boxed{\text{Parameter destillieren ja; Identifikation behaupten nein.}}
\]

| Schicht | Inhalt | Tag |
|---|---|---|
| **Arithmetisch intern** | $H(n)$, $M(n)$, $\Omega(n)$, Primvierling-Produkt | `[B]` |
| **Geometrisch analog** | Kepler-Namen ($a$, $e$, Perihel, Periode) | `[C]` |
| **Empirisch numerisch** | $H(N(\gamma_v))$, $\delta_H$, $L_\pi$ | `[B]` |
| **Offene Brücke** | $\Phi(v)=\gamma$, $\mathcal S_{\mathrm{ideal}}$ | `[C]` |

**Wichtig:** $M(n) \neq \Omega(n)$ und $Q(n) \neq \|\mathbf{i}_N\|_\infty$ im Allgemeinen — Achsenprimes $2,3$ und höhere Exponenten tragen zu $\Omega$ bzw. $\max i_p$, nicht zu $M$ bzw. $Q$.

Kepler-Parameter dienen als **Analogiesprache**, nicht als physikalische Keplergrößen.

---

## Tag-Tabelle Lift / Kepler

| Objekt | Status |
|---|---|
| Quaternionische Norm als Definition | `[A]`/`[B]` |
| Vergleich Kepler-Kegel ↔ Quaternionennorm | `[C]` |
| Projektion $\pi_Q$ als EABC-Signatur | `[B]` (implementiert) |
| Vergleich $\pi_K \leftrightarrow \pi_Q$ | `[C]` |

---

## Acht priorisierte Parameter `[B]`/`[C]`

| # | Parameter | Definition | Tag |
|---|---|---|---|
| 1 | **NetDescentMargin** | $\Delta_{\mathrm{net}} = n - \mathrm{collatzStep}^{[t_{\mathrm{loc}}]} m_{\mathrm{good}}$; V2.7-Kern: $\Delta_{\mathrm{net}} > 0$ | `[B]` empirisch / Collatz `[C]` |
| 2 | **BadRunCost** | $C_{\mathrm{bad}} = t_{\mathrm{good}}$ (Schritte bis $\mod 4 = 1$) | `[B]` |
| 3 | **ShrinkEfficiency** | $\eta = \Delta_{\mathrm{net}} / (C_{\mathrm{bad}} + 1)$ | `[B]` |
| 4 | **ChannelEntropy** | $-\sum_c p_c \log p_c$, $p_c = X/M$ | `[B]` |
| 5 | **PrimeGridCompression** | $\rho_{\mathrm{PG}} = M(n)/\Omega(n)$ | `[B]` |
| 6 | **NormSignatureDefect** | $\delta_H(v) = \|H(N(\gamma_v)) - H(P(v))\|_1$ | `[B]` |
| 7 | **ProjectionLoss** | $L_\pi = \Omega(N) - M(N)$ | `[B]` |
| 8 | **ChiralityNorm** | $\|\chi\| = \sqrt{\alpha^2+\beta^2+\gamma^2}$ aus 8D-Hurwitz | **`[C]`** (Nat→8D offen) |

**Optional:** $R_\infty(n) = Q(n)/\|\mathbf{i}_n\|_\infty$ — implementiert als `prime_grid_infinity_ratio`, wenn $\max_p i_p > 0$.

---

## Collatz-Formulierung (V2.7)

\[
m_{\mathrm{good}} = \mathrm{collatzStep}^{[t_{\mathrm{good}}]}(n),
\qquad m_{\mathrm{good}} \equiv 1 \pmod 4
\]

\[
\Delta_{\mathrm{net}}(n) = n - \mathrm{collatzStep}^{[t_{\mathrm{loc}}]}(m_{\mathrm{good}})
\]

**Offener V2.7-Kern (`[C]`):** uniform $\Delta_{\mathrm{net}} > 0$ für $n \equiv 3 \pmod 4$. Siehe [`collatz_v27_net_descent.md`](../collatz_v27_net_descent.md).

---

## Primvierling — $\gamma_v$, $H(P(v))$, $\delta_H$

\[
v=(p,p+2,p+6,p+8),\qquad
\gamma_v=p+(p+2)i+(p+6)j+(p+8)k
\]

| Größe | Wert | Tag |
|---|---|---|
| $H(P(v))$ | $(1,1,1,1)$ strukturell | `[B]` |
| $M(P(v))$ | $4$ | `[B]` |
| $H(N(\gamma_v))$ | faktorisierungsabhängig | `[B]` empirisch |
| $\delta_H(v)$ | $\|H(N(\gamma_v)) - H(P(v))\|_1$ — **Governance-Diagnostic** | `[B]` |

Beispiel $v=(5,7,11,13)$: $H(N(\gamma_v))=(1,0,1,0)$, $\delta_H=2$, $L_\pi(N(\gamma_v))=2$.

---

## Weitere destillierte Größen (Legacy / ergänzend)

| Parameter | Definition | Tag |
|---|---|---|
| Kanal-Exzentrizität $e_{\mathrm{EABC}}$ | $(\max H - \min H)/M$ | `[B]` |
| Kanal-Varianz $\sigma^2_{\mathrm{EABC}}$ | $\frac14\sum (X-M/4)^2$ | `[B]` |
| Norm-Produkt-Drift $D_{NP}$ | $M(N(\gamma_v)) - 4$ | `[B]` |
| Normsignatur-Anisotropie $A_N$ | $\max H(N) - \min H(N)$ | `[B]` |

---

## JSON-Felder

**Allgemein (`DistilledInvariants`):** u. a. `channel_entropy`, `prime_grid_compression`, `projection_loss`, `prime_grid_infinity_ratio`.

**Primvierling (`PrimvierlingDistilled`):** u. a. `norm_signature_defect`, `product_signature`, `channel_entropy_product`.

**Collatz (`CollatzNetDescentDiagnostics`):** `bad_run_cost`, `net_descent_margin`, `shrink_efficiency`.

---

## Repo-Anschluss

| Artefakt | Pfad |
|---|---|
| Python-API | `kepler_hurwitz.diagnostics` |
| Legacy-Reexport | `kepler_hurwitz.distilled_parameters` |
| Signatur-Basis | `kepler_hurwitz.signatures` |
| Parameter-Atlas | `docs/diagnostics_parameter_atlas.md` |
| Demo | `examples/run_diagnostics.py` |
| Tests | `tests/test_diagnostics.py` |
| JSON-Beispiel | `docs/energiedoku_exports/diagnostics_sample.json` |

---

## Explizit nicht behauptet

| Claim | Status |
|---|---|
| Kepler-Exzentrizität **ist** $e_{\mathrm{EABC}}$ | **falsch** — nur Analogie `[C]` |
| $M(n)=\Omega(n)$ allgemein | **nicht behauptet** |
| $Q(n)=\max_p i_p$ allgemein | **nicht behauptet** |
| $\Phi(v)=\gamma$ dedekindisch etabliert | **`[C]` offen** |
| Quaternionen-Ideale sind Keplerbahnen | **falsch** |

---

## Schluss

> Die nächsten Parameter sollen keine neuen Identitätsbehauptungen einführen, sondern Projektionsverluste, Defekte, Kosten und Balancegrößen messbar machen. Besonders hoch priorisiert sind `NetDescentMargin`, `BadRunCost`, `ChannelEntropy`, `PrimeGridCompression` und `NormSignatureDefect` — jeweils als `[B]`-Diagnostics mit klarer Trennung von `[C]`-Brücken (Collatz-Witness-Existenz, Chiralität Nat→8D, $\pi_K \leftrightarrow \pi_Q$).
