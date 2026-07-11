---
title: Green–Stokes Zirkulationsbrücke
date: 2026-07-06
status: "[C]"
orq_id: ORQ-089
claim_boundary: >-
  Greens und Stokes Satz liefern die Referenz-Lesesprache für Randintegral ↔
  Flächenintegral (Zirkulation ↔ Curl). Die numerische Verifikation im Repo ist
  reine Analysis — keine physikalische Identifikation mit EABC-Wirbeldiagnostik.
not_claimed:
  - Green/Stokes beweisen Onsager-Flussquantisierung oder Dumas-Zirkulation
  - EABC Gap-Rotor-Loops sind Konturintegrale eines glatten Vektorfeldes
  - Numerische Übereinstimmung auf der Scheibe überträgt sich auf diskrete Primvierling-Orbits
---

> **Evidence status:** `[C]` methodische Brücke · numerische Verifikation `[B]`  
> **Geschwister:** [`onsager_quantization_bridge.md`](onsager_quantization_bridge.md) (ORQ-089, E-089)  
> **Diagnostik:** `src/kepler_hurwitz/greens_stokes_verification.py`

# Green–Stokes Zirkulationsbrücke

**Stand:** 6. Juli 2026  
**Zweck:** Greens Satz (2D) und Stokes Satz (3D) als gemeinsames Rand–Bulk-Muster für Zirkulation — Anschluss an Onsager-Wirbel-Lesesprache und Bulk/Shell-Zerlegungen im Repo.

---

## Kernfrage `[C]`

**Liegt das interessante Signal am Rand (Umlauf) oder in der Fläche (Rotation/Curl)?**

\[
\boxed{
\oint_{C} \mathbf{F}\cdot d\mathbf{r}
\;=\;
\iint_{S} (\nabla\times\mathbf{F})\cdot\mathbf{\hat{n}}\,dS
}
\]

Green ist der 2D-Spezialfall; Stokes die 3D-Verallgemeinerung auf orientierten Flächen.

---

## Greens Satz (Ebene)

Für \(P,Q\) mit stetigen partiellen Ableitungen auf einer offenen Menge, die \(D\) enthält, und positiv orientierter geschlossener Kurve \(C=\partial D\):

\[
\oint_{C} P\,dx + Q\,dy
= \iint_{D}\left(\frac{\partial Q}{\partial x} - \frac{\partial P}{\partial y}\right)dA.
\]

Der Operator \(\frac{\partial Q}{\partial x}-\frac{\partial P}{\partial y}\) ist die **skalare \(z\)-Komponente** von \(\nabla\times\mathbf{F}\) für \(\mathbf{F}=\langle P,Q,0\rangle\).

---

## Stokes Satz (Raum)

\[
\oint_{C} \mathbf{F}\cdot d\mathbf{r}
= \iint_{S} (\nabla\times\mathbf{F})\cdot\mathbf{\hat{n}}\,dS.
\]

Voraussetzungen: \(\mathbf{F}\) glatt auf einer offenen Menge um \(S\); \(C=\partial S\) konsistent orientiert (Rechte-Hand-Regel).

---

## Referenzbeispiel: Rotationsfeld auf der Scheibe

\[
\mathbf{F}=\langle -y,\,x,\,0\rangle,\qquad
\nabla\times\mathbf{F}=\langle 0,\,0,\,2\rangle,\qquad
C:\;x^2+y^2=R^2,\quad S:\;x^2+y^2\le R^2,\;z=0,\;\mathbf{\hat{n}}=\mathbf{k}.
\]

| Seite | Ausdruck | Wert |
|---|---|---|
| Randintegral | \(\oint_C \mathbf{F}\cdot d\mathbf{r}\) | \(2\pi R^2\) |
| Green (2D) | \(\iint_D 2\,dA\) | \(2\pi R^2\) |
| Stokes (3D) | \(\iint_S 2\,dS\) | \(2\pi R^2\) |

Alle drei Seiten stimmen überein — Green und Stokes liefern auf der Ebene \(z=0\) dasselbe Bild.

---

## Vergleichstabelle

| Merkmal | Green (2D) | Stokes (3D) |
|---|---|---|
| Dimension | Ebene | Raum |
| Rand | geschlossene Kurve \(C\subset\mathbb{R}^2\) | geschlossene Kurve \(C\subset\mathbb{R}^3\) |
| Domäne | Fläche \(D\) | orientierte Fläche \(S\) |
| Operator | \(\partial_x Q - \partial_y P\) | \(\nabla\times\mathbf{F}\) |
| Integraltypen | Linien \(\leftrightarrow\) Doppel | Linien \(\leftrightarrow\) Fläche |

**Allgemeiner Stokes:** \(\int_{\partial M}\omega=\int_M d\omega\) — Green und Stokes sind Koordinatenfälle.

---

## Anschluss an ORQ-089 (Onsager)

| Physik `[A]` | Analysis | EABC `[C]` / `[B]` |
|---|---|---|
| Zirkulation \(\Gamma=\oint \mathbf{v}\cdot d\mathbf{r}\) | Stokes: \(\Gamma=\iint(\nabla\times\mathbf{v})\cdot\mathbf{\hat{n}}\,dS\) | `circulation_quantum_number` auf Gap-Rotor-Loops |
| Quantisierte Wirbelstärke \(\Gamma=n h/m\) | Curl-Kern liefert „Quelle“ der Rotation | diskreter Windungsindex \(n\in\mathbb{Z}\) |
| Rand vs. Bulk | \(\partial S\) vs. \(S\) | Meissner/Kernbindung: Rand-Residual vs. glatte Hülle |

**Governance:** Onsager-Wirbeldiagnostik (`onsager_vortex_diagnostics.py`) misst **kombinatorische** Phasenwindung — nicht das glatte Rotationsfeld \(\mathbf{F}=\langle-y,x,0\rangle\). Green/Stokes liefern die **Referenzgrammatik**, nicht die Identität.

---

## Numerische Verifikation `[B]`

```bash
PYTHONPATH=src python examples/run_greens_stokes_verification.py
pytest tests/test_greens_stokes_verification.py -q
```

Modul: `greens_stokes_verification.py` — parametrisiertes Randintegral und polare Doppel-/Flächenintegration für \(\mathbf{F}=\langle-y,x,0\rangle\); Export nach `docs/exports/greens_stokes_verification.json`.

### Symbolische Verifikation (SageMath) `[B]`

```bash
sage -python examples/run_vector_calculus_verification.py
pytest tests/test_vector_calculus_diagnostics.py -q
```

Modul: `vector_calculus_diagnostics.py` — exakte symbolische Integrale via Sage; Export nach `docs/exports/greens_stokes_symbolic.json`. Ergänzt die numerische Pipeline, ersetzt sie nicht.

---

## Brücke zu E-090 (e³-Multiplet) `[C]`

| Stokes-Form | Lesefrage im Repo |
|---|---|
| \(\int_{\partial\Omega}\omega\) | Rand/Umlauf — geschlossene Loop-Ordnung (Onsager, Gap-Rotor) |
| \(\int_\Omega d\omega\) | Bulk/Fläche — innere Quelle (Curl, Schaleninhalt) |
| Green (2D) | flache Kanalprojektion, skalarer Curl |
| Stokes (3D) | zusätzliche Orientierung \(\mathbf{\hat{n}}\), vektorielle Rotation |

Der Sprung von Green zu Stokes ist **methodisch parallel** zum Sprung von der linearen \(e\)-Achse zur e³-Zerlegung mit \(S_\pm^2\)-Multiplet (E-090): Ebene \(\to\) Raum mit orthogonaler Aufspaltung. **Nicht behauptet:** formale Identität zwischen Curl und \(S_\pm\)-Profil.

---

## Governance (verbindlich)

| Claim | Erlaubt? |
|---|---|
| Green/Stokes als Rand–Bulk-Lesesprache | Ja — `[C]` |
| Numerische Scheiben-Verifikation | Ja — `[B]` |
| Stokes beweist EABC-Zirkulation | **Nein** |
| Green identisch mit Dumas-Gap-Rotor | **Nein** |

---

## Querverweise

| Dokument | Rolle |
|---|---|
| [`onsager_quantization_bridge.md`](onsager_quantization_bridge.md) | ORQ-089, quantisierte Zirkulation |
| [`weyl_onsager_bridge_attack.md`](weyl_onsager_bridge_attack.md) | Operator- vs. Loop-Defekt |
| [`meissner_analogy_assessment.md`](meissner_analogy_assessment.md) | Bulk/Shell-Rand-Lesart |
| [`nuclear_binding_multiscale_analogy.md`](nuclear_binding_multiscale_analogy.md) | glatte Hülle + Residuum |
