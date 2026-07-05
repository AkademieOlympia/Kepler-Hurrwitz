---
title: Prime Grid / Signaturgeometrie natürlicher Zahlen
date: 2026-07-05
evidence_id: E-075
status: "[B]/[C]"
claim_boundary: >-
  Prime Grid liefert eine externe mathematische Normalform für Signaturgeometrie
  natürlicher Zahlen. Die Brücke zu EABC, Dedekind-Idealen, HoTT und Renormalisierung
  ist methodisch — ohne Beweis von EABC, Dedekind–Hasse, HoTT, RH oder physikalischen
  Identifikationstheoremen.
not_claimed:
  - Prime Grid beweist EABC oder die kanonische mod-12-Kanalpartition
  - Signatur-Normen implizieren Dedekind-Idealstruktur oder HoTT-Identitätsschicht
  - Number trail / L∞-Pfade beweisen EABC-Stream- oder Bucket-Dynamik
  - Kepler-Givental-Lift beweist Retraktion R* oder Isotropierestauration
---

# Prime Grid / Signaturgeometrie natürlicher Zahlen (E-075)

**Stand:** 5. Juli 2026  
**Evidenz:** E-075 — `[B]` Prime Grid-Geometrie; `[C]` EABC-Brückeninterpretation  
**Quellen:** [Kolossváry, *The Prime Grid* (2017)](../../mathematische_texte/kolossvary_the_prime_grid.pdf) · [Givental, *Kepler's laws and conic sections*](../../mathematische_texte/givental_kepler_laws_conic_sections.pdf)

---

## Kernaussage

Natürliche Zahlen $N\ge 2$ besitzen die **kanonische Primfaktor-Signatur**

$$N = \prod_{p\ \mathrm{prim}} p^{i_p}
\qquad\longleftrightarrow\qquad
\mathbf{i}_N = (i_p)_{p\ \mathrm{prim}},$$

eine unendlich-dimensionale Exponentenvektor-Darstellung (Prime Grid). Auf dieser Signatur definieren sich die klassischen **additiven** und **supremums** Normen:

$$\|\mathbf{i}_N\|_1 = \sum_p i_p = \Omega(N), \qquad
\|\mathbf{i}_N\|_\infty = \max_p i_p.$$

Das EABC-Programm komprimiert dieselbe Priminformation auf **vier mod-12-Kanäle** ($E,A,B,C$) und misst dort eine **restriktierte** $\ell^1$-Norm $M(n)$. Prime Grid und EABC sind **komplementäre Signatur-Normalformen** — die Verbindung ist dokumentiert als methodische Brücke, nicht als etablierte mathematische Äquivalenz.

---

## Prime Grid vs. EABC — Vergleichstabelle

| Aspekt | Prime Grid (Kolossváry) | EABC (Kepler-Hurrwitz) |
|---|---|---|
| **Träger** | Alle Primexponenten $(i_p)_p$ | Vier Kanäle $H(n)=(E,A,B,C)$ |
| **Projektion** | Vollständige Primzerlegung | mod-12-Restklassen: $p>3$, $p\bmod 12\in\{1,5,7,11\}$ |
| **$\ell^1$-Norm** | $\|\mathbf{i}_N\|_1=\Omega(N)$ | $M(n)=E+A+B+C$ (Kanalsumme) |
| **$\ell^\infty$-Norm** | $\|\mathbf{i}_N\|_\infty=\max_p i_p$ | $Q(n)=\max\{E,A,B,C\}$ (optional) |
| **Geometrie** | Gitter / Pfad in Primachsen | 12-Punkt-Konfiguration, Retraktion, Shell |
| **Status** | Externe Normalform `[B]` | Formaler Kern + Brücken `[A]`/`[B]`/`[C]` |
| **Brücke** | — | Resonanz-Lesart `[C]` — siehe Governance |

**PDF:** [`kolossvary_the_prime_grid.pdf`](../../mathematische_texte/kolossvary_the_prime_grid.pdf) · **arXiv:** [1711.02903](https://arxiv.org/abs/1711.02903)

---

## Normen und Signaturen

### Prime Grid (volle Primachse)

Für $N=\prod_p p^{i_p}$:

| Symbol | Definition | Zahlentheorie |
|---|---|---|
| $\mathbf{i}_N$ | Exponentenvektor $(i_p)_p$ | Primfaktor-Signatur |
| $\|\mathbf{i}_N\|_1$ | $\sum_p i_p$ | $\Omega(N)$ — totale Primfaktorzahl mit Multiplizität |
| $\|\mathbf{i}_N\|_\infty$ | $\max_p i_p$ | stärkste Primmacht in $N$ |

### EABC (mod-12-Vierkanal)

Sei $H(n)=(E,A,B,C)$ die **mod-12-projizierte** Vierkanal-Signatur (Primzählen $p>3$ nach Restklasse $p\bmod 12\in\{1,5,7,11\}$ gezählt):

$$M(n) = E + A + B + C \qquad\text{— restriktierte $\ell^1$-Norm auf EABC-Kanälen.}$$

**Optionale $\ell^\infty$-Erweiterung:**

$$Q(n) = \max\{E,A,B,C\} \qquad\text{— maximale Kanalmultiplizität.}$$

$M(n)$ und $Q(n)$ sind **EABC-interne** Größen; sie ersetzen nicht $\Omega(N)$ oder $\max i_p$, sondern lesen dieselbe Priminformation durch die mod-12-Kompression.

---

## Number trail / $L_\infty$ und EABC-Streams

Im Prime Grid motiviert der **Number trail** (Pfad der Exponentenentwicklung) und die $L_\infty$-Geometrie (Supremumsachse) eine **methodische** Parallele zu EABC-Stream- und Bucket-Pfaden:

- Primachsen-Schritte ↔ diskrete Kanal-Updates in Shell/Stream-Modellen
- $\|\cdot\|_\infty$-Steuerung ↔ Spitzenkanal-Dominanz ($Q(n)$)

> **Governance `[C]`:** Diese Analogie ist **methodologisch** — es wird **nicht** behauptet, dass Number-trail-Dynamik EABC-Retraktion oder Bucket-Orbits beweist.

---

## Kepler–Givental: methodische Parallele

Givental formuliert Keplersche Gesetze als **Kegelschnitt-Invarianten** — Übergang von Ebene (Ellipsen/Parabeln/Hyperbeln) zu **Kegel-Lift** und einfacher Schnittgeometrie.

| Givental (Kepler/Kegel) | Prime Grid / EABC (Lesart) |
|---|---|
| Ebene: Bahn/Kepler-Orbit | Prime Grid: volle Exponentenachse |
| Kegel-Lift | mod-12-Kompression → $H(n)$ |
| Einfache Schnitt-Invarianten | $M(n)$, $Q(n)$, Shell-Tensoren |
| Methodischer Nutzen | Geometrie-Rahmen für Signatur-Projektion |

**PDF:** [`givental_kepler_laws_conic_sections.pdf`](../../mathematische_texte/givental_kepler_laws_conic_sections.pdf)

> **Governance `[C]`:** Kepler-Givental-Lift ist **kein** Beweis der EABC-Isotropierestauration oder der Dedekind–Hasse-Analogie in [`eabc_renormalisierungsprogramm.md`](eabc_renormalisierungsprogramm.md) §13.

---

## Governance — explizit nicht behauptet

| Tag | Inhalt |
|---|---|
| `[B]` | Prime Grid als klare Signatur-Normalform; $\|\cdot\|_1=\Omega(N)$, $\|\cdot\|_\infty=\max i_p$; externe Quelle Kolossváry |
| `[C]` | Brücke zu EABC-Masse $M(n)$, mod-12-Kanälen, Prim-Stream, Dedekind-Idealen, HoTT, Renormalisierung — Resonanz-Lesart |

**Nicht behauptet:**

- Prime Grid **beweist** EABC, Dedekind–Hasse, HoTT, Renormalisierung oder RH
- $M(n)=\Omega(N)$ oder $Q(n)=\max i_p$ allgemein
- Number trail **identifiziert** EABC-Bucket-Pfade formal
- Givental-Geometrie **ersetzt** Lean-Zertifikate (`prime_norm_full_restoration` o. Ä.)

---

## Verwandte Projekt-Dokumente

| Schicht | Dokument |
|---|---|
| EABC-Renormierung | [`eabc_renormalisierungsprogramm.md`](eabc_renormalisierungsprogramm.md) |
| Dedekind–Hasse-Brücke | [`dedekind_hasse_eabc_bridge.md`](dedekind_hasse_eabc_bridge.md) |
| Dedekind-Ideal-Schicht | [`../dedekind_ideal_layer.md`](../dedekind_ideal_layer.md) |
| HoTT Identity Layer | [`../hott_identity_layer.md`](../hott_identity_layer.md) |
| Related Work | [`../related-work.md`](../related-work.md) §6 |
| Literatur | [`../literaturliste.md`](../literaturliste.md) |

---

## Referenzen

1. Kolossváry, I. *The Prime Grid. Introducing a geometric representation of natural numbers.* arXiv:1711.02903 (2017). Repo: [`kolossvary_the_prime_grid.pdf`](../../mathematische_texte/kolossvary_the_prime_grid.pdf)
2. Givental, A. *Kepler's laws and conic sections.* Repo: [`givental_kepler_laws_conic_sections.pdf`](../../mathematische_texte/givental_kepler_laws_conic_sections.pdf)
