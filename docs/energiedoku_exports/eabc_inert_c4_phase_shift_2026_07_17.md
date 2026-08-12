---
title: EABC C₄ — inert-Nomenklatur und Claim-Grenze (Phasenverschiebung π)
date: 2026-07-17
status: >-
  Abschnitt geschlossen: Nomenklatur inert; bewiesener Kern vs. abgetretene
  Claims dokumentiert.
governance: >-
  [B] Kongruenz-/Typwort-Kern; Illustration ≠ Physik; B3 bleibt unabhängig
  blockiert; kein Collatz-Beweis.
---

# EABC \(C_4\): Nomenklatur `inert` und versiegelte Claim-Grenze

**Stand:** 2026-07-17  
**Branch:** `post-freeze/octonionic-collatz-proof-attempt`  
**Typ:** #Energiedoku-Archiv — Abschnittsverschluss  
**Status:** Abschnitt geschlossen: Nomenklatur inert; bewiesener Kern vs. abgetretene Claims dokumentiert.

\[
\boxed{\begin{aligned}
&\text{konstantes }C_4\text{-Übergangswort }(+1,+1,+1)\\
&+\ \text{Phasenverschiebung um }\pi\\
&+\ \text{wohldefinierte Gaußsche Typabbildung }\Phi_\theta
\end{aligned}}
\]

**Quellen der Wahrheit:**

- Theorie: [`../theory/primvierling_c4_rotation.md`](../theory/primvierling_c4_rotation.md)
- Manuskriptfragment: [`../manuscripts/primvierling_c4_rotation_fragment.tex`](../manuscripts/primvierling_c4_rotation_fragment.tex)
- Implementierung: `src/kepler_hurwitz/primvierling_c4_rotation.py`

---

## Nomenklaturregel (verbindlich)

| Kanon | Erstverwendung / Alias |
|---|---|
| **`inert`** | bei erstem Auftreten: `inert` (zunächst: *„träge“*) |
| **`zerfallend`** | zweiter Gauß-Typ unter \(\Phi_\theta\) (beibehalten) |

Danach ausschließlich `inert` / `zerfallend`. Keine neuen Metaphern-Synonyme.

---

## Bewiesener Kern

1. Zwei reguläre Startkanäle: \(p\equiv 11\pmod{12}\) und \(p\equiv 5\pmod{12}\).
2. Invariantes Übergangswort \((+1,+1,+1)\) auf dem \(C_4\)-Zustandsraum für beide Kanäle.
3. Reine Phasenverschiebung um exakt \(\pi\) zwischen den Trajektorien.
4. Zwei algebraisch komplementäre Gaußsche Typwörter via wohldefinierter \(\Phi_\theta\)
   (an jeder Position des Vierlings wird der Typ des einen Kanals durch den jeweils anderen Typ ersetzt):
   - \(\Phi_\theta(0)=\Phi_\theta(3\pi/2)=\mathrm{inert}\)
   - \(\Phi_\theta(\pi/2)=\Phi_\theta(\pi)=\mathrm{zerfallend}\)

---

## Rigoros abgetretene Claims

- **Keine Antipodalität** — gleiche Typen sitzen auf benachbarten \(C_4\)-Zuständen, nicht gegenüber.
- **Keine Achsenprojektion** — keine kanonische Identifikation mit Real-/Imaginärachsen von \(\mathbb{C}\).
- **Keine Metaphern** — keine physikalische Dynamik, Dualität oder topologische Invarianz postuliert.
- **Interaktive Darstellung** = nur geometrische Illustration von kombinatorischer Rotation und Typmarkierung.

\[
\boxed{\text{Illustration} \;\neq\; \text{Physik}}
\]

---

## Explizite Nicht-Claims (Governance)

- **Kein** Collatz-Beweis.
- **Schicht B3** (Fano-/Inzidenz-Kopplung) bleibt **unabhängig blockiert** — dieser Abschnittsverschluss hebt B3 nicht auf.
  Siehe [`../theory/bh_c11_scale_invariance_homogeneity.md`](../theory/bh_c11_scale_invariance_homogeneity.md) §5.6 und
  [`form_inhalt_bigraded_cylinder_b2_2026_07_17.md`](form_inhalt_bigraded_cylinder_b2_2026_07_17.md).

---

## Governance-Box

```
[B] C4 congruence + Gaussian type words via Φ_θ
nomenclature: inert (first use: „träge“) / zerfallend
sealed: proven core vs withdrawn claims (2026-07-17)
≠ Collatz proof
≠ physics / duality / topological invariance
≠ B3 unblocked
illustration ≠ physics
```
