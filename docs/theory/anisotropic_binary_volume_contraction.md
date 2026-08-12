---
title: Anisotropic Binary Volume Contraction Bridge
date: 2026-07-20
status: "[C]"
evidence_id: E-099
orq_id: ORQ-099
claim_boundary: >-
  Das Produkt ∏_{k=1}^n 2^{-k} = 2^{-n(n+1)/2} ist elementare Algebra [A].
  Die Lesart als anisotrope Projektion entlang (i,j,k) bzw. als binärer
  Mehrskalen-Filter auf EABC-Sektoren ist eine [C]-Analogie — kein Beweis
  quaternionischer Volumenkompression, keine Identifikation von (L,H,W) mit
  {E,A,B,C}, keine Retraktions-Identität mit R^* → 24I_3.
not_claimed:
  - Die Grafik beweist EABC-Struktur oder Hurwitz-Idealtheorie
  - (L,H,W)-Skalierung ist kanonisch gleich (i,j,k) oder den vier Kanälen
  - 5 = 1²+2² legt die EABC-Klasse von 5 fest
  - Produkt 2^{-k} misst bereits Norm-/Phasenverteilung auf Primvierlingen
  - Anisotrope Kontraktion ersetzt die projektive Retraktion R^*
---

> **Evidence status:** `[C]` skalentheoretische Brückenhypothese (ORQ-099)  
> **Verwandte:** E-053 (Renormierung / anisotroper Defekt), E-075 (Signaturgeometrie), E-096 (Normalform \(2^\alpha\)), ORQ-087 (Ordnungs-Defekt)  
> **Algebra-Kern `[A]`:** Dreiecksexponent \(S_n=\tfrac{n(n+1)}{2}\)

# ORQ-099: Anisotrope binäre Volumenkontraktion

**Stand:** 20. Juli 2026  
**Governance:** Elementare Identitäten `[A]`; EABC-/Quaternionen-Lesart `[C]` — Upgrade zu `[B]` nur über reproduzierbare Kontraktions-Exporte mit Nullmodellen  
**Lean:** `KeplerHurwitz/AnisotropicBinaryVolumeContraction.lean` — `triangleNumber`, \(\prod 2^{\pm k}=2^{\pm S_n}\) (`[A]`); EABC-Lesemarker als `Prop := True` (`[C]`)  
**Didaktik (Abitur-Audit):** [`../energiedoku_exports/normalform_messbecher_lean_kern_abitur_2026_07_20.md`](../energiedoku_exports/normalform_messbecher_lean_kern_abitur_2026_07_20.md) — Messbecher mappt auf den Formel-Kern `[A]`; „Normalform-Phasenvolumen“ ist Phantom-Kopplung (nicht Lean).

> **Re-verifiziert, weiterhin zutreffend Stand 21. Juli 2026.**  
> Lean-Kern E-099 unverändert seit `7e91ec0`; keine Normalform→Volumen-Brücke in Lean; Claim-Wall unverändert. Collatz nicht bewiesen.

---

## Kernfrage

**Kann die gerichtete Skalenfamilie**

$$
T_n \;=\; \bigl(2^{-1},\,2^{-2},\,\ldots,\,2^{-n}\bigr),\qquad
\prod_{k=1}^{n} 2^{-k} \;=\; 2^{-\tfrac{n(n+1)}{2}},
$$

als **kontrollierte Lesesprache** für anisotrope Mehrskalen-Kontraktion auf EABC-/Hurwitz-Gittern dienen — komplementär zur isotropen Retraktion \(R^*\mapsto 24I_3\) — **ohne** Volumen-/Norm-Identität zu behaupten?

---

## 1. Algebraischer Kern `[A]`

Für \(n\in\mathbb{N}\) gilt

$$
\prod_{k=1}^{n} 2^{-k}
  \;=\;
  2^{-\sum_{k=1}^{n} k}
  \;=\;
  2^{-\tfrac{n(n+1)}{2}}.
$$

Der Exponent ist die \(n\)-te **Dreieckszahl** \(S_n=\tfrac{n(n+1)}{2}\).

**Beispiel \(n=3\):** Richtungsskalierung \((2^{-1},2^{-2},2^{-3})=\bigl(\tfrac12,\tfrac14,\tfrac18\bigr)\) liefert

$$
\tfrac12\cdot\tfrac14\cdot\tfrac18 \;=\; \tfrac{1}{64} \;=\; 2^{-6},\qquad S_3=6.
$$

Das ist reine Potenzarithmetik — unabhängig von EABC.

**Didaktischer Binärschritt:** \(\tfrac{5}{10}=\tfrac12\) illustriert eine exakte Verjüngung um den Faktor \(2^{-1}\). Das ist **kein** Theorem über die EABC-Klasse von \(5\) oder \(10\); \(5=1^2+2^2\) ist die klassische Zwei-Quadrate-Darstellung (externe Zahlentheorie `[A]`), nicht automatisch Kanal \(E\)/`A` im Sinne von `signatures.py`.

---

## 2. Geometrische Lesart: Volume contracting `[C]`

Im Bild wird ein Quader **nicht isotrop** geschrumpft, sondern **richtungsspezifisch getaktet**:

$$
\text{Skalierung}_{n=3} \;=\; (2^{-1},\,2^{-2},\,2^{-3}).
$$

| Bildobjekt | Vorgeschlagene EABC-/Hurwitz-Lesart | Status |
|---|---|---|
| Achsen \(L,H,W\) | Drei unabhängige Kontraktionsrichtungen — **Analogie** zu \((i,j,k)\) oder zu drei Gitterachsen | `[C]` |
| Produkt der Skalen | Volumenfaktor \(2^{-S_n}\) als globale Kompressionsmaßzahl | `[A]` Formel / `[C]` Lesart |
| Sequenz \(T_k: x\mapsto 2^{-k}x_k\) | Iterativer Kontraktionsoperator, Dimension \(k\) mit Gewicht \(2^{-k}\) | `[C]` |
| Binäre Potenzen | Mehrskalen-Filter entlang \(\log_2\)-Achsen (vgl. Normalform \(2^\alpha\) in E-096) | `[C]` |

**Governance:** \((L,H,W)\leftrightarrow(i,j,k)\) und \((L,H,W)\leftrightarrow\{E,A,B,C\}\) sind **nicht** kanonisch. Die vier Kanalrollen \(\{E,A,B,C\}\) bleiben die mod-12-Signatur; die drei Achsen des Quaders sind ein **3D-Anschauungsbild**, kein vierter Kanalersatz.

---

## 3. Brücke zum eabc-Modell `[C]`

### 3.1 Binäre Zerlegung und Sektor-Audit

Im Quaternionen-/EABC-Raster zählen Potenzen von \(2\) und das Wechselspiel gerader/ungerader Anteile für Zerlegbarkeit und Normen (vgl. Normalform \(n=2^\alpha 3^\beta r\,e\), E-096). Die Familie \(2^{-k}\) liefert einen **skalentheoretischen Baustein**, um Normen oder Phasen **skalenübergreifend** über Sektoren zu verfolgen — als Audit-Sprache, nicht als Beweis.

**Operatorlesart (vorgeschlagen):**

$$
(T_k x)_j \;=\;
\begin{cases}
2^{-k}\,x_j & j=k,\\
x_j & j\neq k,
\end{cases}
\qquad
V_n \;=\; \prod_{k=1}^{n} T_k.
$$

Dann gilt \(\det V_n = 2^{-S_n}\) auf \(\mathbb{R}^n\) (`[A]` für die Determinante; Anschluss an Hurwitz-Norm `[C]` offen).

### 3.2 Komplement zur Renormierungs-Retraktion

E-053 fragt, ob **anisotrope** Defekte \(w_p vv^T\) durch \(R^*\) auf den **isotropen** Fixpunkt \(24I_3\) zurückprojiziert werden. ORQ-099 liefert die **gegenläufige** Anschauung: gerichtete Kontraktion **erzeugt** Anisotropie in den Skalenachsen.

| Motiv | E-053 / Renorm | ORQ-099 |
|---|---|---|
| Anisotropie | Defekt, der entfernt werden soll | gerichtete Skalenfamilie |
| Isotropie | Ziel \(24I_3\) | nicht behauptet |
| Maßzahl | Tensor / Shell-Skalierung | \(2^{-S_n}\) |

**Regel:** Ein Befund zu \(R^*\) rechtfertigt **keinen** Volumenkontraktions-Claim und umgekehrt.

### 3.3 Phasenakkumulation / Dreieckszahlen

\(S_n\) taucht in diskreten Gitter- und Phasenargumenten häufig als kumulative Indexsumme auf. Hier bleibt das eine **Motiv-Parallele** `[C]` — kein Identitätsclaim mit Berry-Holonomie (ORQ-083) oder Gap-Rotor-Windung (ORQ-089).

---

## 4. Status- und Governance-Tabelle

| Claim | Status | Upgrade-Pfad |
|---|---|---|
| \(\prod_{k=1}^n 2^{-k}=2^{-S_n}\) | `[A]` | — |
| Anisotrope Lesart \((2^{-1},\ldots,2^{-n})\) als Audit-Metrik | `[C]` | — |
| \(T_k\) / \(V_n\) trennt Primvierling-Sektoren von Nullmodellen | `[B]` offen | Export + Shuffle-/Norm-Nullmodelle |
| \((L,H,W)=(i,j,k)\) kanonisch | **nein** | nicht behauptet |
| \(2^{-S_n}\) = quaternionische Normkompression | **nein** | nicht behauptet |
| ORQ-099 beweist Retraktion oder Dedekind-\(\Phi\) | **nein** | — |

---

## 5. Bezug zu bestehenden Repo-Schichten

| Dokument / Modul | Rolle |
|---|---|
| [`../energiedoku_exports/eabc_renormalisierungsprogramm.md`](../energiedoku_exports/eabc_renormalisierungsprogramm.md) | Anisotroper Defekt → isotrope Retraktion (E-053) |
| [`../eabc_normal_form.md`](../eabc_normal_form.md) | \(2^\alpha\)-Faktor in der Normalform (E-096) |
| [`dumas_cone_orbit_model.md`](dumas_cone_orbit_model.md) | Gerichtete Orbit-Pfade, Mehrskalen-Lesefragen |
| [`weyl_commutator_operator_bridge.md`](weyl_commutator_operator_bridge.md) | Ordnungs-Defekt (ORQ-087) — komplementär, nicht identisch |
| [`nuclear_binding_multiscale_analogy.md`](nuclear_binding_multiscale_analogy.md) | Mehrskalen-Hülle + Residuum (ORQ-092) |

---

## 6. Nächster `[B]`-Implementierungsschritt

1. **Fixiere** eine Testrepräsentation: z. B. drei Norm-Komponenten oder drei reguläre Multiplikationsachsen \(\{i,j,k\}\).
2. **Definiere** \(c_n(v)=\prod_{k=1}^{n}\|P_k v\|\,2^{-k}\) (oder \(\log\)-Summenform) für Primvierlinge \(v\).
3. **Exportiere** gegen Nullmodelle: CEAB-Permutation, Kanal-Shuffle, norm-matched random.
4. **Falsifikation:** Trennt \(c_n\) nicht, bleibt ORQ-099 bei `[C]`.

**Nicht jetzt:** Manuskript-Upgrade über `[C]`-Remark hinaus, Identifikation mit \(R^*\), Lean-Formalisierung der EABC-Lesart jenseits der `[C]`-Marker.
