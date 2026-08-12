---
title: Bamberg topologische Eichdynamik — Protokoll v1 (Baustein 3.1)
date: 2026-07-15
evidence_id: "E-111"
status: "[B/C] Baustein 3.1 — Krümmungsextraktion (Freeze)
governance: >-
  Ladungsabhängiger Kantentransport U_e = exp(i a_e Q), getwister Ko-Rand d_A,
  Plakettenholonomie U_f, Klein-F-Asymptotik. Keine Deutung von g_eff oder alpha_eff.
claim_boundary: >-
  Theoretisch hergeleitet [C]: Eichkovarianz D_X(A^g) = G_g D_X(A) G_g^{-1}, U_f^g = U_f.
  Lokal numerisch geprüft [B]: Holonomie-Invarianz, Tr(D_X^2)-Invarianz, Klein-F-Limes.
  Formal vorbereitet [A]: BambergGaugeCovariance.lean ohne sorry.
not_claimed:
  - Physikalische Eichkopplungsstärke oder effektive Naturkopplung
  - Metrikauswahl, alpha_scale
  - Heat-Kernel / Determinanten-Antwort (Baustein 3.2)
---

# Bamberg topologische Eichdynamik — Protokoll v1 (Baustein 3.1)

**Stand:** 15. Juli 2026 (Freeze Rev. 1)  
**Register:** `E-111`  
**Vorgänger:** `E-110` (interne EABC-Kopplung), `E-103` (Kwant-Triptychon)  
**Sequenz:** Baustein 3.1 (dieses Protokoll) → Baustein 3.2 (Determinanten-/Heat-Kernel-Antwort)

---

## 0. Statusbericht (verbindlich)

\[
\boxed{
\text{theoretisch hergeleitet}
\;\big|\;
\text{lokal numerisch geprüft}
\;\big|\;
\text{formal vorbereitet}
\;\big|\;
\text{repo-seitig integriert (Freeze Rev. 1)}
}
\]

**Lean 4:**

\[
\boxed{
\texttt{BambergGaugeCovariance.lean}
\text{ ohne } \texttt{sorry} \text{ aufgesetzt.}
}
\]

**Numerischer Krümmungstest:**

\[
\frac{1-\cos(qF)}{F^2} \to \frac{q^2}{2}
\]

bestätigt die korrekte Klein-F-Asymptotik des gewählten Plakettenterms. Sie beweist **keine**
physikalische Eichkopplungsstärke, sondern nur die saubere geometrische Ladungsantwort des Minimalmodells.

**Governance-Grenze:**

\[
\boxed{
\text{Eichkovarianz}
\;\neq\;
\text{quadratischer Krümmungskoeffizient}
\;\neq\;
\text{effektive Naturkopplung}
}
\]

---

## 1. Leitfrage

Wie sieht die Ladung die Krümmung auf der arithmetischen Quadrat-Plakette — und wie extrahiert
man den quadratischen Krümmungskoeffizienten aus \(\mathrm{Tr}(D_X(A)^2)\), ohne Eichinvarianz
oder Plakettenholonomie zu verletzen?

---

## 2. Mathematischer Kern [C]

| Objekt | Definition |
|---|---|
| Ladungsoperator | \(Q = \mathrm{diag}(q_{EA}\mathbf 1_2, q_B\mathbf 1_3, q_C\mathbf 1_3)\) |
| Kantentransport | \(U_e = \exp(i a_e Q)\) |
| Getwister Ko-Rand | \((d_A\psi)(e) = U_e \psi(\mathrm{target}) - \psi(\mathrm{source})\) |
| Gesamtoperator | \(D_X(A) = D_{\mathrm{geom}}(A) + I_4 \otimes D_{\mathrm{int}}\) |
| Plakettenholonomie | \(U_f = \exp(i F_f Q)\), \(F_f = a_{1p}+a_{p,pq}-a_{q,pq}-a_{1q}\) |

**Satz (Eichkovarianz):** Unter \([Q, D_{\mathrm{int}}]=0\):

\[
D_X(A^g) = G_g D_X(A) G_g^{-1}, \qquad U_f^g = U_f \quad \text{(abelsch)}.
\]

---

## 3. Numerische Audits [B]

| Prüfung | Schwelle | Modul |
|---|---|---|
| Plakettenholonomie \(U_f^g = U_f\) | \(\le 10^{-12}\) | `audit_plaquette_holonomy_invariance` |
| \(\mathrm{Tr}(D_X(A^g)^2) = \mathrm{Tr}(D_X(A)^2)\) | rel. \(\le 10^{-10}\) | `audit_trace_gauge_invariance` |
| Klein-F \((1-\cos qF)/F^2 \to q^2/2\) | rel. \(\le 10^{-3}\) bei \(F\in\{10^{-3},\ldots\}\) | `audit_klein_f_asymptotics` |

---

## 4. Artefakte

```
KeplerHurwitz/BambergGaugeCovariance.lean
KeplerHurwitz/Core.lean                              (Import)
src/kepler_hurwitz/bamberg_gauge_dynamics.py
tests/test_bamberg_gauge_dynamics.py
docs/energiedoku_exports/bamberg_gauge_dynamics_protocol.md
```

---

## 5. Ausführung

```bash
lake build KeplerHurwitz.BambergGaugeCovariance
pytest tests/test_bamberg_gauge_dynamics.py tests/test_erpc_233_hamiltonian.py -q
python -c "from kepler_hurwitz.bamberg_gauge_dynamics import run_gauge_dynamics_audit; print(run_gauge_dynamics_audit().passed)"
```

---

## 6. Abgrenzung / Baustein 3.2

- **Nicht** in v1: Determinanten- oder Heat-Kernel-Antwort, \(g_{\mathrm{eff}}\), \(\alpha_{\mathrm{eff}}\)
- **Baustein 3.2:** Extraktion der Krümmungsantwort über \(\det D_X\) oder Wärme-Kern-Spur

---

## 7. Kette (Abschluss Baustein 3.1)

\[
[Q, D_{\mathrm{int}}] = 0
\;\Longrightarrow\;
D_X(A) \text{ eichkovariant}
\;\Longrightarrow\;
U_f \text{ eichinvariant}
\;\Longrightarrow\;
\frac{1-\cos(qF)}{F^2} \to \frac{q^2}{2}
\]

**Interpretation:** Die Ladung sieht die Plakettenkrümmung — der Koeffizient ist geometrisch,
nicht physikalisch kalibriert.
