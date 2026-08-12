---
title: Digitaler Messbecher — was Lean wirklich zu 2^{-n(n+1)/2} beweist
date: 2026-07-20
status: "[A]/[C] mixed — honest audit of a didactic draft"
evidence_id: E-099
orq_id: ORQ-099
related: E-096
claim_boundary: >-
  Lean beweist die algebraische Identität ∏_{k=1}^n 2^{-k} = 2^{-n(n+1)/2}
  für jedes n (E-099, [A]). Lean beweist NICHT, dass die EABC-Normalform
  (E-096) nach n Schritten ein „Phasenvolumen“ um diesen Faktor schrumpft.
  Messbecher = Anschauung für den Volumenfaktor der gerichteten Skalen;
  EABC-/Quaternionen-Etiketten bleiben [C]. Collatz ist nicht bewiesen.
  Metapher ≠ Physik.
verdict_user_exact_packaged_claim: "NO"
verdict_on_algebraic_formula: "YES"
lean_kernel: KeplerHurwitz/AnisotropicBinaryVolumeContraction.lean
theory_home: docs/theory/anisotropic_binary_volume_contraction.md
not_claimed:
  - Collatz-Vermutung bewiesen
  - Phasenvolumen der Normalform schrumpft in Lean
  - Quaternionen-/EABC-Etiketten sind Teil des [A]-Kerns
  - Messbecher = physikalisches Messgerät oder Feldgleichung
---

# Der digitale Messbecher — und was Lean davon wirklich sagt

**Zielgruppe:** Abitur / Studienstart · **Stand:** 20. Juli 2026  
**Verdict zur Entwurfs-Behauptung „In der Normalform schrumpft das Phasenvolumen nach \(n\) Schritten um \(2^{-n(n+1)/2}\)“:** **NEIN** (als Gesamtpaket).  
**Verdict zur reinen Formel \(\prod_{k=1}^{n}2^{-k}=2^{-n(n+1)/2}\):** **JA** — Lean `[A]`, für jedes \(n\).

> **Re-verifiziert, weiterhin zutreffend Stand 21. Juli 2026.**  
> Geprüft: `KeplerHurwitz/AnisotropicBinaryVolumeContraction.lean` bytegleich zu Commit `7e91ec0` (kein Diff); `KeplerHurwitz/EABC/NormalForm.lean` enthält weiterhin keine Volumen-/Schrumpfungstheoreme (nur Zahlzerlegungs-API \(n=2^\alpha 3^\beta r\,e\)); EABC-Lesemarker bleiben `Prop := True` `[C]`. Keine neue Brücke Normalform → Phasenvolumenfaktor. Collatz nicht bewiesen.

---

## 1. Was jemand behaupten wollte

Ein didaktischer Entwurf sagte sinngemäß:

> In der *Normalform* schrumpft nach \(n\) Schritten das *Phasenvolumen* mit
> \[
> 2^{-1}\cdot 2^{-2}\cdots 2^{-n}=2^{-n(n+1)/2}.
> \]
> Lean beweist das bombenfest für jede Dimension. Schrumpfung = Fakt `[A]`;
> EABC-/Quaternionen-Namen = Deutung `[C]`.

Die **Trennung** `[A]` vs. `[C]` am Ende ist richtig gedacht.  
Die **Kopplung** „Normalform + Phasenvolumen + diese Formel“ ist falsch: Lean kennt die Formel — aber nicht als Theorem über Normalform-Schritte.

---

## 2. Was Lean wirklich beweist (`[A]`)

Datei: `KeplerHurwitz/AnisotropicBinaryVolumeContraction.lean` (E-099 / ORQ-099)

| Name | Inhalt |
|---|---|
| `triangleNumber` | \(S_n=n(n+1)/2\) |
| `sum_Icc_id_eq_triangleNumber` | \(\sum_{k=1}^n k=S_n\) |
| `prod_two_pow_eq_two_pow_triangle` | \(\prod_{k=1}^n 2^k=2^{S_n}\) (Nat) |
| `prod_two_zpow_neg_eq_two_zpow_neg_triangle` | \(\prod_{k=1}^n 2^{-k}=2^{-S_n}\) über \(\mathbb{Q}\) |
| `anisotropicVolumeFactor_eq_prod` | Volumenfaktor \(=\) Produkt der gerichteten Skalen |
| Zeugen \(n=3\) | \(\tfrac12\cdot\tfrac14\cdot\tfrac18=\tfrac1{64}=2^{-6}\) |

Das ist **reine Potenzarithmetik**. Kein Collatz, keine Primvierlinge, keine Quaternionen-Norm. Für jedes natürliche \(n\) — ja, „bombenfest“ im Sinne von: maschinengeprüft, dimensionunabhängig.

**Separat** (E-096, anderes Modul): `KeplerHurwitz/EABC/NormalForm.lean` formalisiert die **Zahlzerlegungs-Normalform**
\[
n=2^\alpha\,3^\beta\,r\,e
\]
mit Kanal-/Residual-Prädikaten, \(V_4\)-Neutralität des E-Faktors usw. Das ist eine **Schreibweise für natürliche Zahlen**, kein Volumenprozess mit \(n\) Schrumpfungsschritten.

---

## 3. Was Lean *nicht* beweist

- Kein Theorem der Form: „Nach \(n\) Normalform-Schritten schrumpft ein Phasenvolumen um \(2^{-S_n}\).“
- Keine Identifikation von Messbecherachsen mit Quaternionenachsen \((i,j,k)\) oder Kanälen \(\{E,A,B,C\}\) — in Lean nur `[C]`-Marker (`Prop := True`).
- **Collatz ist nicht bewiesen** (weder hier noch anderswo im Repo als abgeschlossener Beweis).
- Die Metapher ist **keine Physik**: kein Messbecher im Labor, keine Feldgleichung, keine Aussage über Raumzeit.

Die Brücken-Docs sagen das bereits klar:  
`docs/theory/anisotropic_binary_volume_contraction.md`.

---

## 4. Messbecher — behalten, aber korrekt kalibriert

Die Messbecher-Metapher **darf bleiben**, wenn sie genau auf den `[A]`-Kern zeigt:

Stell dir einen **digitalen Messbecher** vor, der nicht „alles auf einmal“ halbieren muss, sondern **Richtung für Richtung** eine andere Binärskala setzt:

- Achse 1: Faktor \(\tfrac12 = 2^{-1}\)
- Achse 2: Faktor \(\tfrac14 = 2^{-2}\)
- …
- Achse \(n\): Faktor \(2^{-n}\)

Das **Produkt** dieser Skalen — der Inhalt, den der Becher als Gesamtvolumenfaktor anzeigt — ist immer
\[
2^{-1}\cdot 2^{-2}\cdots 2^{-n}=2^{-S_n},\qquad S_n=\tfrac{n(n+1)}{2}.
\]
Für \(n=3\): \(\tfrac12\cdot\tfrac14\cdot\tfrac18=\tfrac1{64}\). Das ist der Lean-Kern.

**Falsche Kalibrierung (Phantom-Claim):**  
„Dieser Becher *ist* die EABC-Normalform und misst Phasenvolumen nach Collatz-/Orbit-Schritten.“  
→ Das steht **nicht** in Lean.

**Richtige Kalibrierung:**  
Der Becher misst den **algebraischen Volumenfaktor einer gerichteten Skalenfamilie**. Ob man denselben Faktor später als Audit-Metrik auf EABC-Sektoren *liest*, ist eine **Deutung** `[C]` — interessant, aber kein Beweis.

Kurz:

| Schicht | Status | Inhalt |
|---|---|---|
| Formel / Dreiecksexponent | `[A]` | Lean, alle \(n\) |
| Messbecher als Anschauung für diese Formel | didaktisch ok | mappt auf `[A]` |
| „Normalform-Phasenvolumen“ | **nicht** `[A]` | Entwurf überzieht |
| EABC / Quaternion / Mehrskalen-Filter | `[C]` | Lesesprache, offen Richtung `[B]` |

---

## 5. Merksatz für die Klausur

> Lean beweist: Das Produkt der gerichteten Binärskalen \(2^{-1},\ldots,2^{-n}\) ist \(2^{-n(n+1)/2}\).  
> Lean beweist **nicht**: Collatz, noch dass die EABC-Normalform ein physikalisches oder Phasen-Volumen um genau diesen Faktor schrumpft.  
> Metapher hilft beim Rechnen — sie ersetzt keinen Beweis und keine Physik.

---

## 6. Pointer

| Rolle | Pfad |
|---|---|
| Lean-Kern `[A]` | `KeplerHurwitz/AnisotropicBinaryVolumeContraction.lean` |
| Theorie / Claim-Wall | `docs/theory/anisotropic_binary_volume_contraction.md` |
| Normalform (andere Schicht) | `docs/eabc_normal_form.md` · `KeplerHurwitz/EABC/NormalForm.lean` |
| Register | E-099 (Formel `[A]` / Lesart `[C]`), E-096 (Normalform) |
| Index | `docs/theory/README.md` § E-099 |
