---
title: Crystal Prism (Brent & Hill 2026) — Crosswalk zu EABC/Hurwitz
date: 2026-07-06
status: "[D] externe konzeptionelle Brücke / spekulative Physik-Analogie"
claim_boundary: >-
  Keine Behauptung, dass EABC oder Hurwitz-Formalismus die Feinstrukturkonstante,
  Newton-Konstante, Kosmologie oder das Standardmodell aus FCC/E8/A5 ableitet.
  Crystal Prism dient ausschließlich als externer Resonanzanker für geteilte
  mathematische Motive (E8 112+128, Hurwitz 8D, A5, ζ(3)) — strikt getrennt vom
  Formal Core und von ORQ-Brücken [C].
evidence_id: —
external_source: "Brent, C., & Hill, N. (2026). The Crystal Prism Theory. Zenodo 10.5281/zenodo.21193348"
not_claimed:
  - EABC leitet α, ħ, G, H₀ oder Massenverhältnisse ab
  - 11/11-Validierung des Crystal Prism belegt das Kepler-Hurwitz-Programm
  - A5 → SU(3)×SU(2)×U(1) ist bewiesen oder formalisiert
  - 128 FCC-Void-Zyklen identifizieren E8-Typ-2-Wurzeln physikalisch
  - Crystal-Prism-RH- oder SM-Ableitungen werden ins Fixed-Locus-Programm (ORQ-088) übernommen
---

> **Evidence status:** `[D]` externe konzeptionelle Brücke  
> **No claim is made that EABC explains physical constants or validates Crystal Prism derivations.**  
> Shared mathematics may be verified independently; physics identifications remain `[C]`/`[D]` only.

# Crystal Prism ↔ EABC/Hurwitz — Crosswalk

**Externe Quelle:** Brent & Hill (2026), *The Crystal Prism Theory* (Zenodo)  
**Repo-Abgrenzung:** Geschwister zu [`arithmetic_vacuum_eabc_analogy.md`](arithmetic_vacuum_eabc_analogy.md) (E-074) — gleiche Governance: Resonanz ja, Deduktion nein.

---

## Drei strikte Schichten — nicht vermischen

$$\text{Crystal Prism (extern)} \;\neq\; \text{EABC Formal Core} \;\neq\; \text{Hurwitz/E8-Arithmetik}$$

| Schicht | Crystal Prism | Kepler-Hurwitz |
|---|---|---|
| **Formal Core** | Behauptet Ableitung aller Konstanten aus 4 Axiomen | EABC-Kanalpartition, Lean, Dumas/Renorm `[A]`/`[B]` |
| **Geteilte Mathematik** | E8-Zählung, Hurwitz, A5-Dimensionen, Gittersummen | `hurwitz_units_240`, `invariant_subspaces_a4_toy.sage` `[B]` |
| **Physik-Identifikation** | FCC-Supersolid, SM, Kosmologie | ORQ-Brücken `[C]`, Physical Analogies E-076 `[C]` |

---

## Crosswalk-Tabelle

| Crystal Prism | EABC/Hurwitz-Anknüpfung | Governance CP | Governance KH | Verifikation im Repo |
|---|---|---|---|---|
| E8: 112 + 128 = 240 Wurzeln | `hurwitz_units_240`: 112 ganzzahlige Norm-2 + 128 Halbgitter-Einheiten (E-037) | `[A]` Kombinatorik | `[B]` `discrete_time_flow.py`, `test_metacommutation.py` | Ja — 240/240 |
| Hurwitz-Theorem → 8D | Oktonionischer Hurwitz-Träger, arXiv double-sphere | `[A]` Satz | `[A]`/`[B]` Lattice-Sieve | Ja |
| A5 Irreps (1,3,3,4,5) | E-019–E-021: Ikosaeder-Ecken, Charakterzerlegung | `[A]` Rep.theorie | `[B]` Sage `a5_geo_*` | Ja (geometrisch, nicht `I_h`) |
| A5 → SU(3)×SU(2)×U(1) | Kein SM-Ableitungsprogramm | `[C]` unbewiesen | — (nicht behauptet) | Nein |
| DM/Baryon = (3²+4²+5²)/3² = 50/9 | Musketiere: 3'-Räume vs. 3-Räume (E-026) nur metaphorisch | `[C]` Post-hoc | `[C]` ORQ offen | Nein |
| φ aus Ikosaeder | E-019 ff., goldener Schnitt in Projektionen | `[A]` Geometrie | `[B]`/`[C]` Embedding | Teilweise |
| ζ(3) in Gittersummen / α | E-074: α₀ = 1/(4πζ(3)·9) — **andere** Formel | `[A]` Zeta-Wert | `[C]` extern Hassall | Getrennte Numerik |
| α⁻¹ Selbstkonsistenz (128, φ⁸, π/4) | Kein EABC-Formalpfad; widerspricht E-074-Grenze | `[C]` zirkulär | `[C]` refuted als Ableitung | Nein |
| FCC: Z=12, μ=21, b₁=128 | mod-12-Kanäle (E-072), 12-Ecken-Träger | `[A]`/`[B]` Kombinatorik | `[B]` mod-12 `[A-T]` lokal | FCC-Summen S₂,S₄ nicht im Repo |
| 128 Void-Zyklen = E8 Typ 2 | Numerologische Parallele zu 128 Halbgitter-Einheiten | `[C]` Analogie | `[C]` nicht identifiziert | Zählung nur extern |
| b₀ = (11N_c−2N_f)/3 = 7 | SM-Teilchenzahlen **implizit** (33−12) | `[C]` versteckter Input | — | Nein |
| ħ = f_s₀·g_FCC·m₀·c·a | SI-Konvention + Rückrechnung | `[C]` zirkulär | — | Nein |
| G, H₀, ρ_Λ, Σ_char | Kosmologie nicht EABC-Kern | `[C]` tautologisch/teils | — | Nein |
| Seeley–DeWitt Δ, Wärmekern a₂+a₄+a₆ | Spektralgeometrie-Metapher | `[C]` | ORQ-088 nur programmatisch `[L4]` | Nein |

---

## „11/11 Validierung“ — Einzelprüfung (ORQ-Stil)

| # | Größe | CP-Claim | Befund | ORQ-Label |
|---|---|---|---|---|
| 1 | α⁻¹ | 0,0003 % | Fixpunkt mit α in Δ; 128 = E8-Typ-2-Zählung eingebaut | `[C]` numerologisch |
| 2 | ħ | 0,07 % | Aus m₀,a,c,f_s₀,g_FCC; c,ħ sind SI-Definitionen | `[C]` zirkulär |
| 3 | G | 0,22 % | Viele freie Faktoren (Ω, η₀, C₄₄) | `[C]` |
| 4 | H₀ | 0,0 % | **67,4 im Nenner/Zähler** — Identität | `[C]` refuted |
| 5 | H₀,local | 0,65 % | φ⁻⁵ nachträglich zur Spannung | `[C]` Post-hoc |
| 6 | m_μ/m_e | 0,006 % | Nutzt bereits gefittetes α⁻¹ + ζ(3) | `[C]` |
| 7 | m_τ/m_e | 0,006 % | Koide-Relation + numerische Lösung | `[C]` |
| 8 | DM/Baryon | 1,68 % | Rep-Dimensionen willkürlich gewichtet | `[C]` |
| 9 | V_flat | 0,02 % | Lange Kette abgeleiteter Größen | `[C]` |
| 10 | Σ_char | 0,0 % | **(50/9)×9 = 50** algebraisch | `[C]` refuted |
| 11 | ρ_Λ | 0,0 % | Beobachtete Λ in x_eff,Dark | `[C]` refuted |

**Fazit:** 0/11 als unabhängige Vorhersage `[B]`; höchstens 3–4 als numerische Nähe nach vielen Freiheitsgraden `[C]`.

---

## Red Flags (Governance)

1. **„Keine empirischen Inputs“** — widerspricht SI-Nutzung von c, ħ; SM b₀; PIMC f_s₀; Planck DM/Baryon; H₀/ρ_Λ in Kosmologie.
2. **Zirkularität α–Δ–Seeley–DeWitt** — α⁻¹ erscheint in Δ und in der Fixpunktgleichung.
3. **FCC-Eindeutigkeit** — Axiom III behauptet eindeutigen FCC-Grundzustand; in der statistischen Mechanik nicht allgemein bewiesen.
4. **A5 → SM** — keine Darstellungstheorie- oder GUT-Kette im Dokument.
5. **Skalenwahl** — a und E₀=144 eV erzeugen ξ_coh/a = 10⁶ per Konstruktion.
6. **RH/SM** — nicht mit ORQ-088 oder EABC-Kern verknüpfen.

---

## Ehrliche Brücken

### Als `[C]`-Metapher nutzbar

- **112/128-Split** als Lesesprache für Integer- vs. Halbgitter-Hurwitz-Einheiten (bereits E-037).
- **A5-Modenzerlegung** auf 12-Ecken-Träger vs. „parallel/perpendicular“-Sektoren (Musketiere E-026).
- **Gitter-Summen S₂, S₄** als optionales `[B]`-Benchmark (FCC-Nachbarschaftssummen — noch nicht implementiert).
- **Projektionskette 8D → Ikosaeder → 3D** parallel zu Kepler-Lift (`kepler_quaternion_lift_projection.md`).

### Gemeinsame Verifikation

| Objekt | Skript/Modul |
|---|---|
| 240 Hurwitz-Einheiten | `hurwitz_units_240()`, `test_metacommutation.py` |
| A5 auf 12 Ecken | `scripts/invariant_subspaces_a4_toy.sage` (`a5_geo_*`) |
| E8-Nachbarschaft / soft resolver | `soft_e8_resolver`, `arithmetic_evolution.py` |

### Nicht mergen

- α-, G-, H₀-, ρ_Λ-„Ableitungen“ ins EABC-Register oder arXiv-Hurwitz-Paper.
- SM-Gauge-Gruppen aus A5 ohne Beweis.
- „11/11 validated“ in Evidenzsprache.
- Crystal Prism als Begründung für ORQ-088 / RH-Programm.

---

## Offene Fragen (kein ORQ bis Präzisierung)

1. Ist die 128=128-Parallele (E8 Typ 2 vs. FCC-Void-Zyklen vs. 128 Halbgitter-Einheiten) über Äquivalenzklassen operationalisierbar — oder reine Zahlensymbolik?
2. Lassen sich FCC-S₂, S₄ unabhängig von CP-Parametern reproduzieren und mit Hurwitz-Shell-Proxies (N=4,6,8) vergleichen?
3. Konflikt α: Crystal-Prism-Fixpunkt vs. E-074 α₀ — bewusst als **konkurrierende externe `[C]`-Modelle** dokumentieren, nicht vereinheitlichen.

---

## Verwandte Repo-Dokumente

| Dokument | Rolle |
|---|---|
| [`arithmetic_vacuum_eabc_analogy.md`](arithmetic_vacuum_eabc_analogy.md) | E-074, ζ(3)/α-Governance |
| [`open_research_questions.md`](../open_research_questions.md) | ORQ-Index |
| [`physical_reference_analogies.md`](../reports/physical_reference_analogies.md) | E-076 Lesesprache |
| [`kepler_quaternion_lift_projection.md`](kepler_quaternion_lift_projection.md) | Lift/Projektion `[C]` |

**Empfohlene Haltung:** Crystal Prism = **`[D]` externe Spekulation** mit **`[A]`/`[B]`-Schnittmenge** nur dort, wo Repo-Skripte dieselbe Kombinatorik bereits tragen.
