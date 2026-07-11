# Vom Phasen-Homotopie-Ansatz zur Fixed-Locus-Konfinierung

Eine strukturelle Synthese der Riemannschen Zeta-Symmetrie im Kepler-Hurrwitz-Rahmenwerk.

**Governance:** `[L4 / programmatisch]` — keine RH-Behauptung, kein Epistemologie-Upgrade aus Numerik oder Heuristik.

**Register-Bezug:** E-034 (`[C]` refuted), E-035 (`[C]` open_hypothesis), ORQ-088 (Fixed-Locus-Konfinierung).

---

## 1. Die mathematische Demarkationslinie

Das Fixed-Locus-Programm formuliert die Riemannsche Vermutung (RH) von einer analytischen Nullstellensuche in eine rein algebraisch-topologische Strukturaussage um.

Reflexions-Konjugations-Operator:

\[
D(s) := 1 - \bar{s}
\]

Für \(s = \sigma + it\) gilt \(D(\sigma + it) = (1-\sigma) + it\). Die Fixpunktmenge ist exakt:

\[
\mathrm{Fix}(D) = \{s \in \mathbb{C} \mid \sigma = \tfrac{1}{2}\}
\]

### Symmetrie vs. Konfinierung

| Aussage | Status | Formulierung |
|---|---|---|
| **Symmetrie (bekannt)** | Orbit-Invarianz | \(D(Z) = Z\) — die nicht-triviale Nullstellenmenge \(Z\) ist global invariant; Orbit-Größen 1 oder 2 sind zulässig |
| **Konfinierung (offen)** | Ein-Punkt-Orbit-Kollaps | \(\mathrm{Fix}(D \mid_Z) = Z\) — jede Nullstelle liegt im Fixpunkt-Locus |

Da \(\mathrm{Fix}(D) = \{\sigma = \tfrac{1}{2}\}\), ist die Konfinierungs-Aussage äquivalent zur klassischen Lokations-Behauptung der RH.

**Whitepaper-Kern:** Die Demarkationslinie zwischen bekannter Symmetrie und offener Konfinierung ist die exakte mathematische Grenze — kein vorzeitiger Loss-Claim.

---

## 2. Einordnung im Evidenzrahmen (Governance)

```text
[L4 / Programm]      Fixed-Locus, SDTC, HoTT-Univalenz, Primexponenten-Gitter
        │
        ▼  nur mit expliziter Brücke
[C / offen]          Operator-Darstellung von ξ-Abweichungen; SBT-Domination (ORQ-088)
        │
        ▼  numerisch geprüft, nicht upgraden
[C / refuted]        E-034 Kosinus-Resonanz auf ΔM (Verdict: refuted)
        │
        ▼  numerisch offen
[C / open_hypothesis] E-035 Skalen-Kosinus-Interferenz auf x₀
        │
        ▼  maschinell verifiziert
[A / A-T]            Algebraische Kernstrukturen (Dumas, Musketiere, Collatz-V2 lokal)
```

**Pipeline-Regel:**

\[
\boxed{\text{Daten kanonisieren} \to \text{Invarianten prüfen} \to \text{erst dann Theorie schärfen}}
\]

Dieses Dokument gehört zur Theorie-Schärfung **nach** Daten-Kanonisierung — nicht auf dem Branch `extract-energiedoku-shell-coordinates-n1-n3`.

---

## 3. Epistemologische Abgrenzung zu früheren Phasen

### Phasen-Homotopie (2024)

Topologische Invarianten (Windungszahlen) detektieren lokale Singularitäten robust, besitzen jedoch keine geometrische Trennschärfe zur Isolation der kritischen Linie. Homotopie-Robustheit ≠ horizontale Positionierung.

### Kosinus-Resonanz — E-034

Durch destruktive Interferenz im Zufalls-Nullmodell formal **widerlegt** (`[C]`, Verdict: `refuted`).

Metrik: \(S(\Delta M) = \mathrm{mean}\,\cos(\gamma \cdot \Delta M)\) über Riemann-Nullstellen — kein Baseline-Überhang, identisch zum Zufalls-Nullmodell.

Visuelle oder statistische Resonanzen ohne strukturerhaltenden Morphismus sind unzulässig für Theorie-Upgrades.

### Skalen-Interferenz — E-035

Metrik: \(S(x_0) = \mathrm{mean}\,\cos(\gamma \cdot \log(a/a_0))\) — **open_hypothesis**: negative Evidenz, aber keine formale Widerlegung der strukturellen Kopplung.

### Arithmetisches Rückgrat

Primzahlexponenten-Isomorphie \(\mathbb{N} \hookrightarrow \mathbb{N}_0^{(\mathbb{P})}\) und Euler-Produkt

\[
\xi(s) \sim \prod_p (1 - p^{-s})^{-1}
\]

liefern die notwendige arithmetische Kopplung (Anschluss: Primvierling, Hurwitz-Signaturen, EABC-Kanäle), stellen jedoch isoliert keinen RH-Beweis dar.

---

## 4. Die drei Forschungssäulen

| Säule | Methode | Epistemologischer Status |
|---|---|---|
| **Formale Säule** | Lean-Stufen 1–5 (Symmetrie-Skelett → analytische Brücke) | Sukzessive Schließung Toy-Model ↔ Realität |
| **Computergestützte Säule** | \(D\)-Orbit-Diagramme, Unified Notebooks | Rein heuristisch-didaktisch; kein post-hoc-Visualisierungsbeweis |
| **Spektraltheoretische Säule** | SDTC (Self-Dual Trace Confinement), Operatortheorie | Konditional — siehe ORQ-088 |

### SDTC (konditional)

\[
\left(\mathcal{A} \text{ anti-invariant unter } D \;\wedge\; \lim_{k\to\infty}\mathrm{Spur}(\mathcal{B}_k) = 0\right) \implies \mathcal{A} = 0
\]

Übertragung auf RH erfordert die noch offene Brücke: Nullstellen-Abweichung \(\leftrightarrow\) spektraler Operator \(\mathcal{A}\) über Selberg-Klasse.

---

## 5. Das Kern-Prinzip

> Die Riemannsche Vermutung wird von einer analytischen Suchfrage zu einer Symmetrie-Konfinierungsfrage unter involutiver Selbstdualität — mit explizit getrennten Beweis-, Heuristik- und Spektralpfaden.

Objektivität erfordert explizite Brückenhypothese (vgl. `CanonicalBridgeHypothesis` in `DreiMusketiere.lean`, E-032) — nicht tautologische Wiederholung der Prämisse.

---

## Verwandte Dokumente

- [`../open_research_questions.md`](../open_research_questions.md) — ORQ-088
- [`../l4_reference_matrix.md`](../l4_reference_matrix.md) — L4-RL-009
- [`../paper-outline.md`](../paper-outline.md) — Satzgruppen S5a/S5b (E-034/E-035)
- [`../../EVIDENCE_REGISTER.md`](../../EVIDENCE_REGISTER.md)
