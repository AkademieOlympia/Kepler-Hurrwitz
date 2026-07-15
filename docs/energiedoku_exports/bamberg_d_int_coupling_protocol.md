---
title: Bamberg interne EABC-Kopplung — Protokoll v1
date: 2026-07-15
evidence_id: "E-110"
status: "[A]/[B]/[C] Baustein 2 — interne Kopplung"
governance: >-
  Baustein 2 der #Energiedoku-Bamberg-Kette: Hilbertraum-Zerlegung 2+3+3,
  U(1)-Ladungsregeln für D_int, Neutralstart q=0. Keine Metrikauswahl,
  kein α_scale, keine Naturkonstanten-Ableitung.
claim_boundary: >-
  Formal bewiesen [A]: Sektor-Dimensionen, Ladungserhaltungs-Lemma,
  Neutralfall q_EA=q_B=q_C=0. Rechnerisch [B]: konkrete Blöcke via erpc_233.
  Theoretisch [C]: Higgs-Label bei q_X≠q_Y. Modellaxiom: Flächenrelation w_f=w_p w_q.
not_claimed:
  - Vollständige Lean-Absicherung gewichteter Spektren von D_geom ⊗ D_int
  - Physikalische Metrikauswahl oder α_scale-Festlegung
  - Ableitung von Naturkonstanten
  - Topologische Eichdynamik (Baustein 3) — siehe E-111
---

# Bamberg interne EABC-Kopplung — Protokoll v1

**Stand:** 15. Juli 2026 (Rev. 1)  
**Register:** `E-110`  
**Vorgänger:** `E-103` (Kwant-EABC-Triptychon), Baustein 1 `BambergQuadrupletAdmissibility.lean` **[A]**  
**Sequenz:** interne EABC-Kopplung → topologische Eichdynamik

---

## 0. Governance — vier Erkenntnisstufen

| Stufe | Bedeutung | In Baustein 2 |
|---|---|---|
| **formal bewiesen [A]** | Lean 4, ohne `sorry` | 2+3+3-Dimension, Ladungserhaltung, Neutralfall |
| **theoretisch hergeleitet [C]** | Algebraische Skizze | Higgs-Label bei \(\Delta q \neq 0\) |
| **rechnerisch nachvollzogen [B]** | Reproduzierbare Numerik | Konkrete \(Y_B, Y_C, K, M_\*\) via `erpc_233` |
| **offene Modelldaten** | Auswahlprinzip ausstehend | Metrikauswahl, \(\alpha_{\mathrm{scale}}\) |

**Statusschranke (unveränderlich):**

\[
\boxed{\text{bewiesene Zell- und Spektralstruktur} \;\neq\; \text{physikalisch ausgewählte Metrik} \;\neq\; \text{Ableitung von Naturkonstanten}}
\]

---

## 1. Leitfrage

Wie koppelt der interne 8-dimensionale Operator \(D_{\mathrm{int}}(n)\) an die bewiesene
geometrische Zellstruktur \(D_{\mathrm{geom}}(A)\), ohne die Eichkovarianz von
\(D_n(A) = D_{\mathrm{geom}}(A) \otimes I_8 + I_4 \otimes D_{\mathrm{int}}(n)\) zu verletzen?

**Nicht behauptet:** Physikalische Teilchenzuordnung der Sektoren EA/B/C.

---

## 2. Hilbertraum-Zerlegung \(\mathcal H_{\mathrm{int}}\)

Komplexifizierung des reellen Bamberger-Raums \(V_8\):

\[
\mathcal H_{\mathrm{int}} = V_8 \otimes_{\mathbb R} \mathbb C \cong \mathbb C^8
= \mathcal H_{EA} \oplus \mathcal H_B \oplus \mathcal H_C
\cong \mathbb C^2 \oplus \mathbb C^3 \oplus \mathbb C^3
\]

| Sektor | Dimension | Rolle (interpretativ) |
|---|---|---|
| \(\mathcal H_{EA}\) | 2 | Ordnungsparameter, Phasenbeziehungen, Spur der komplexen Ebene |
| \(\mathcal H_B\) | 3 | Quaternionische Primrichtungen / räumliche Freiheitsgrade |
| \(\mathcal H_C\) | 3 | Komplementärer Sektor (Generationen / algebraische Kanäle) |

**Lean [A]:** `KeplerHurwitz/BambergInternalCoupling.lean` — `internal_dim_sum`.

---

## 3. \(U(1)\)-Ladungskonfiguration

Diskrete ganzzahlige Ladungen \(q_{EA}, q_B, q_C \in \mathbb Z\). Die lokale Eichtransformation
\(g(v) \in U(1)\) wirkt auf \(\mathcal H_{\mathrm{int}}\) als

\[
G_g^{\mathrm{int}}(v) =
\begin{pmatrix}
g(v)^{q_{EA}} \mathbf 1_2 & 0 & 0 \\
0 & g(v)^{q_B} \mathbf 1_3 & 0 \\
0 & 0 & g(v)^{q_C} \mathbf 1_3
\end{pmatrix}
\]

---

## 4. Blockstruktur von \(D_{\mathrm{int}}(n)\)

\[
D_{\mathrm{int}}(n) =
\begin{pmatrix}
D_{EA}(n) & Y_B(n)^\dagger & Y_C(n)^\dagger \\
Y_B(n) & M_B(n) & K(n) \\
Y_C(n) & K(n)^\dagger & M_C(n)
\end{pmatrix}
\]

Eichkovarianz erfordert für alle Vertices \(v\) und alle \(g(v) \in U(1)\):

\[
\left[ G_g^{\mathrm{int}}(v),\, D_{\mathrm{int}}(n) \right] = 0
\]

### Ladungserhaltungs-Regeln

| Block | Sektoren | Erlaubt iff |
|---|---|---|
| \(D_{EA}, M_B, M_C\) | gleicher Sektor | stets (hermitesch) |
| \(Y_B\) | EA ↔ B | \(q_{EA} = q_B\) |
| \(Y_C\) | EA ↔ C | \(q_{EA} = q_C\) |
| \(K\) | B ↔ C | \(q_B = q_C\) |

Bei \(q_X \neq q_Y\): Kopplung nur über dynamisches Hintergrundfeld (Higgs-Label) **[C]**.

**Lean [A]:** `offDiagonalCouplingAllowed`, `neutral_offDiagonalCouplingAllowed`.

---

## 5. Neutralstart (Standardsektor)

\[
\boxed{q_{EA} = q_B = q_C = 0}
\]

In diesem Fall wirkt \(U(1)\) ausschließlich auf \(\mathcal H_n^{\mathrm{geom}}\) (Baustein 1).
Alle Blöcke von \(D_{\mathrm{int}}(n)\) sind frei koppelbar, ohne Eichkovarianz zu verletzen.

---

## 6. Verbindung zu Baustein 1

| Baustein 1 (abgeschlossen) | Baustein 2 (dieses Protokoll) |
|---|---|
| \(X_{p,q}\), \(D_{\mathrm{geom}}(A)\) **[A]** | \(D_{\mathrm{int}}(n)\) auf \(\mathbb C^8\) |
| \(V_4\)-Symmetrie-Schnitt **[A]** | \(U(1)\)-Ladungsregeln **[A]** |
| Ungewichtete Spektren **[B]** | Gewichtete interne Blöcke **[B]** |
| Topologischer Schutz **[C]** | Sektorkopplung unter Neutralstart **[A/B]** |

Gesamtoperator (schematisch):

\[
D_n(A) = D_{\mathrm{geom}}(A) \otimes_{\mathbb C} I_8 \;+\; I_4 \otimes_{\mathbb C} D_{\mathrm{int}}(n)
\]

Spektrum von \(D_n(A)\): **[B]** — noch nicht Lean-formalisiert.

---

## 7. Numerische Brücke [B]

Bestehende Implementation:

```
src/kepler_hurwitz/erpc_233_hamiltonian.py
src/kepler_hurwitz/erpc_sector_transport.py
tests/test_erpc_233_hamiltonian.py
tests/test_erpc_sector_transport.py
docs/energiedoku_exports/erpc_233_sector_transport_protocol.md  (E-108)
```

Onsite-Block entspricht \(D_{\mathrm{int}}\) pro Site:

- \(H_{EA}(x) = \mathrm{diag}(e_0,a_0) + \delta\,\chi_{11}(x)\sigma_z\)
- \(H_B = b_0 I_3\), \(H_C = c_0 I_3\)
- Inter-Sektor: \(g_{EB} K_{EB}\), \(g_{EC} K_{EC}\), \(g_{BC} K_{BC}\)

**Geplanter Audit (Schritt 3):** Kommutator \(\|[G_g, D_{\mathrm{int}}]\|_F\) für Ladungskonfigurationen.

**Implementiert [B]:** `audit_charge_commutator`, `run_standard_charge_audits` in
`src/kepler_hurwitz/erpc_233_hamiltonian.py`; Tests in `tests/test_erpc_233_hamiltonian.py`.
Standardszenarien A (neutral), B (Teilladung), C (Vollladung).

---

## 8. Harte Freigabekriterien (Baustein 2)

| Prüfung | Schwelle | Tier |
|---|---|---|
| \(\dim \mathcal H_{EA} + \dim \mathcal H_B + \dim \mathcal H_C = 8\) | exakt | **[A]** |
| Ladungserhaltungs-Lemma | Lean ohne `sorry` | **[A]** |
| Neutralfall: alle Off-Diagonal-Blöcke erlaubt | Lean ohne `sorry` | **[A]** |
| `lake build KeplerHurwitz.BambergInternalCoupling` | grün | **[A]** |
| Hermitizität konkreter Blöcke | \(\|H-H^\dagger\|_F \le 10^{-12}\) | **[B]** |
| Nullmodell-Sektortrennung | wie E-108 | **[B]** |

---

## 9. Abgrenzung

| Thema | Status |
|---|---|
| Flächenrelation \(w_f = w_p w_q\) | Modellaxiom (nicht in v1) |
| \(\mathcal A_{pq}^{(\alpha)}\) | theoretisch hergeleitet, \(\alpha_{\mathrm{scale}}\) offen |
| Topologische Eichdynamik | Baustein 3 — nach interner Kopplung |
| Naturkonstanten | **explizit ausgeschlossen** |

---

## 10. Artefakte

```
KeplerHurwitz/BambergInternalCoupling.lean
KeplerHurwitz/Core.lean                          (Import)
docs/energiedoku_exports/bamberg_d_int_coupling_protocol.md
src/kepler_hurwitz/erpc_233_hamiltonian.py       (numerische Brücke)
```

## Ausführung

```bash
lake build KeplerHurwitz.BambergInternalCoupling
pytest tests/test_erpc_233_hamiltonian.py -q
```
