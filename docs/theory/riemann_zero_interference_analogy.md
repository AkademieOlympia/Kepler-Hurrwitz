---
title: Riemann-Nullstellen-Interferenz — Phasenkollaps-Analogie
date: 2026-07-07
status: "[C]"
evidence_id: E-095
orq_id: ORQ-095
claim_boundary: >-
  Die Welle f(x)=sum cos(gamma_n ln x) ist illustrative Lesesprache fuer konstruktive vs.
  destruktive Interferenz an Prim- vs. bc-Achsen-Knoten — kein Beweis von EABC-Symmetriebruch,
  kein Nachweis dass Nullstellen Bivektor-Kollaps verursachen, keine Physik-Identitaet.
not_claimed:
  - Nullstellen beweisen EABC-Symmetriebruch oder Bivektor-Zerreissung
  - Explizite Formel identisch mit Pauli-Stabilisatoren oder QEC-Schutz
  - 35 und 143 zeigen universell destruktive Interferenz ohne Präregistrierung
  - Plot ersetzt Dirichlet-L-Konjugator oder RH-Beweis
---

> **Evidence status:** `[C]` konzeptionelle Analogie; Plot-Export `[B]` illustrativ  
> **Governance (DE):** Illustrative Diagnostik nur — **kein** Beweis von Symmetriebruch; **kein** Nachweis dass Nullstellen EABC-Bivektor-Kollaps verursachen; **keine** Physik-Identität.  
> **Governance (EN):** Illustrative diagnostic only — **not** proof of symmetry breaking; **does not** prove zeros cause EABC bivector collapse; **not** a physics identity.

# Riemann-Nullstellen-Interferenz und bc-Achsen-Phasenkollaps

**Stand:** 7. Juli 2026  
**Register:** E-095 · **ORQ:** ORQ-095 (Geschwister E-093 Riemann-Monopol, E-094 Cross-Talk)  
**Modul:** `src/kepler_hurwitz/riemann_interference_diagnostics.py`  
**Basis:** [`eabc_riemann_axis_monopole.md`](eabc_riemann_axis_monopole.md), [`phaseninvarianz_pauli_energy_bridge.md`](phaseninvarianz_pauli_energy_bridge.md)

---

## Motivation (Energiedoku)

Imaginärteile \(\gamma_n\) der Riemann-Zeta-Nullstellen erzeugen Oszillationen der Form \(\cos(\gamma_n \ln x)\). In der Lesesprache der **expliziten Formel** (Riemann–von Mangoldt) koppeln diese Terme an die Primverteilung — externe Mathematik `[C]`, nicht EABC-intern bewiesen.

**Hypothese `[C]`:** An Primzahlen addieren sich Phasen bevorzugt konstruktiv; an bc-Achsen-Komposita wie \(35=5\cdot7\) und \(143=11\cdot13\) tritt destruktive Interferenz auf — als **Analogie** zum diskreten Crosstalk-Fehler \(\Delta E \neq 0\) und zum „Zerreißen“ des Bivektor-Zustands.

---

## Wellenfunktion

\[
f(x) = \sum_{n=1}^{N} \cos(\gamma_n \ln x), \qquad x > 1.
\]

Implementierung: `calculate_interference_signal`, `wave_function` — erste \(N\) Nullstellen aus eingebetteter Odlyzko-Tabelle (`RIEMANN_INTERFERENCE_ZEROS`, Standard \(N=150\)).

**Testtabelle** (`symmetry_breaking_node_table`):

| \(x\) | Rolle |
|---|---|
| 29, 31, 37, 41 | Prim-Knoten nahe 35 |
| **35** | bc-Komposit \(5\cdot7\) |
| 137, 139, 149 | Prim-Knoten nahe 143 |
| **143** | bc-Komposit \(11\cdot13\) |

---

## Verbindungen im Repo

| Thema | Datei | Rolle |
|---|---|---|
| a-vs-bc-Resonanz | [`eabc_riemann_axis_monopole.md`](eabc_riemann_axis_monopole.md) | gewichtete \(\psi_a,\psi_{bc}\)-Partialsummen |
| Pauli / Bivektor | [`phaseninvarianz_pauli_energy_bridge.md`](phaseninvarianz_pauli_energy_bridge.md) | \(E_a\) stabil, \(E_{bc}\) tensor-verwundbar `[C]` |
| Kern-Residual | [`nuclear_binding_multiscale_analogy.md`](nuclear_binding_multiscale_analogy.md) | glatte Hülle + oszillatorisches Residuum |
| e³-Multiplet | E-090 / `e3_decomposition.py` | \(35=5\cdot7\), \(143=11\cdot13\) als faktorisierbare Knoten |

---

## Visualisierung `[B]` illustrativ

Zwei Subplots für Manuskript-Export:

1. \(x \in [25,45]\) um Zentrum **35**
2. \(x \in [130,155]\) um Zentrum **143**

Markierungen:

- **grün gepunktet:** Primzahlen im Fenster
- **rot gestrichelt:** bc-Komposita 35 und 143

**Artefakte:**

| Artefakt | Pfad |
|---|---|
| PNG | `docs/exports/riemann_interference_phase_collapse.png` |
| JSON | `docs/exports/riemann_interference_phase_collapse.summary.json` |
| CLI | `examples/run_riemann_interference_export.py` |
| Tests | `tests/test_riemann_interference_diagnostics.py` |

**Governance Plot:** Der Export ist eine **illustrative `[B]`-Diagnostik** — er zeigt die Wellenform, beweist aber **nicht**, dass Nullstellen EABC-Symmetriebruch oder Bivektor-Kollaps verursachen. Kein Ersatz für Präregistrierung oder Nullmodell.

---

## Abgrenzung zu E-034 / E-035

`riemann_resonance_checker.py` (E-034/E-035) mittelt \(\cos(\gamma \Delta_M)\) bzw. \(\cos(\gamma \log(a/a_0))\) — **andere Metrik**, negative Evidenz für Resonanz bei großem \(N\). Dieses Modul summiert **ohne Mittelung** und dient der **visuellen** Phasen-Lesesprache, nicht dem Resonanz-Verdict.

---

## Governance-Zusammenfassung

| Aussage | Status |
|---|---|
| Explizite Formel / Mangoldt-Kontext | extern `[C]` |
| Konstruktiv bei Prim, destruktiv bei 35/143 | Hypothese `[C]` |
| EABC-Bivektor / \(\Delta E\) Brücke | Lesesprache `[C]` |
| Matplotlib-Export | illustrativ `[B]` |
| Beweis Symmetriebruch oder Physik-Identität | **nicht** behauptet |
