---
title: Intrinsische Eigenenergie von EABC-Konstellationen
date: 2026-07-17
status: "[C] arithmetisch-algebraischer Kern / methodische Demarkation"
claim_boundary: >-
  E_eigen ist ein algebraischer Repräsentationswert der Konstellation vor
  externer Kopplung — kein QM-Eigenwert, keine MeV-Skalierung ohne
  kalibriertes Kopplungsfunktional, keine Identifikation mit B_exp.
  Fehlende Nullmodell-Signifikanz auf Toy-Daten widerlegt nicht E_eigen,
  sondern nur die naive lineare Projektion auf Kernbindungsresiduen.
not_claimed:
  - E_eigen ist Eigenwert eines nuklearen Hamilton-Operators
  - a_x, a_y liefern absolute MeV ohne empirisches Kopplungsfunktional
  - Fehlende Korrelation I_EABC ↔ R(A,Z) widerlegt die Konstellationsenergie
  - Spread oder Chiralitätsnorm sind additive Eigenenergie-Beiträge
  - Quartische Dualachsen-Energie E_bc = e_b·e_c ersetzt Quaternionen-Multiplikation in [A]
related:
  - eabc_energy_square_sum_substitution.md
  - van_der_waals_eabc_analogy.md
  - nuclear_binding_multiscale_analogy.md
  - ../atome_hypothese.md
  - ../eabc_mass_convention.md
---

> **Evidence status:** `[C]` arithmetisch-algebraischer Kern / methodische Demarkation
> **No claim is made that \(E_{\mathrm{eigen}}\) is a nuclear Hamiltonian eigenvalue, carries MeV units, or is falsified by a null Toy-21 residual correlation.**
> The note separates intrinsic constellation energy from empirical coupling to \(R(A,Z)\) / \(B_{\mathrm{exp}}\).

# #Energiedoku — Theorie-Notiz: Intrinsische Eigenenergie von EABC-Konstellationen

* **Status:** `[C]` (Arithmetisch-algebraischer Kern)
* **Kontext:** EABC-Modell (Kanal-Kopplung vs. intrinsische Energiedichte)
* **Referenz:** Atome/ORQ-092, `examples/run_atome_residual_export.py`
* **Ziel:** Begrifflich-mathematische Trennung der intrinsischen, unskalierten Konstellationsenergie von der physikalischen Kopplung an makroskopische Bindungsenergien (\(B_{\mathrm{exp}}\)).

**Verwandte Schichten:**

| Schicht | Dokument | Rolle |
|---|---|---|
| Quadratsummen-Substitution | [`eabc_energy_square_sum_substitution.md`](eabc_energy_square_sum_substitution.md) | BH-C-11: \(e_\alpha=\alpha_x^2+\alpha_y^2\), Dualachse \(E_{bc}\) |
| Masse / Signatur `[B]` | [`../eabc_mass_convention.md`](../eabc_mass_convention.md) | \(H(n)\), \(M(n)=\texttt{eabc\_mass}\) |
| VdW-Methode `[D]` | [`van_der_waals_eabc_analogy.md`](van_der_waals_eabc_analogy.md) | Ausschluss (\(b\)) vs. Kopplung (\(a\)) als Leseschema |
| Kern-Residuen `[C]` | [`nuclear_binding_multiscale_analogy.md`](nuclear_binding_multiscale_analogy.md), [`../atome_hypothese.md`](../atome_hypothese.md) | ORQ-092: \(I_{\mathrm{EABC}}\) vs. \(R(A,Z)\), nicht vs. \(B_{\mathrm{exp}}\) |

---

## 1. Die Trennung der beiden Schichten

Um algebraische Kategorienfehler zu vermeiden, wird das EABC-Modell in zwei strikt getrennte Beschreibungsebenen unterteilt:

| Schicht | Repräsentiertes Objekt | Mathematischer Status | Physikalische Entsprechung (VdW-Analogie) |
|---|---|---|---|
| **Diskrete Konstellation** | \(H(n) = (E, A, B, C)\) *(Welche Kanäle sind mit welcher Multiplizität besetzt?)* | `[B]` Signatur / Belegung | **Das Kovolumen (\(b\)):** Die geometrisch-diskrete Strukturierung und Lückenverteilung. |
| **Energetische Lesart** | Intrinsische Eigenenergie \(E_{\mathrm{eigen}}(K)\) *(Wie viel unskalierte Energiedichte trägt diese Belegung?)* | `[C]` Quadratfakt / Modul-Normen | **Der Binnendruck (\(a\)):** Die interne Phasen- und Intensitätsstruktur vor externer Kopplung. |

Die Konstellation definiert die reine geometrische Existenz und qualitative Natur der besetzten Achsen. Die intrinsische Eigenenergie bestimmt, wie viel mathematische Feldintensität dieser spezifischen Konstellation innewohnt — **bevor** eine Wechselwirkung mit externen physikalischen Residuen oder benachbarten Gitterpunkten stattfindet.

---

## 2. Mathematische Formulierung der Eigenenergie \(E_{\mathrm{eigen}}\)

Für eine gegebene EABC-Konstellation \(K\) mit den zugeordneten diskreten Kanalgewichten (Multiplizitäten) \(w_E, w_A, w_B, w_C\) wird die intrinsische Eigenenergie definiert als:

\[
E_{\mathrm{eigen}}(K) = \sum_{\alpha \in \{E, A, B, C\}} w_\alpha \cdot e_\alpha \qquad \text{mit} \quad e_\alpha \ge 0
\]

Dabei bestimmt die Natur der Achsenbeiträge \(e_\alpha\) die Abbildungstiefe des Modells:

1. **Zählenergie (Minimalfall):**
   Mit \(e_\alpha = 1\) reduziert sich die Eigenenergie auf die reine Belegungsmasse:
   \[
   E_{\mathrm{eigen}}(K) = M(n) = E + A + B + C \quad (\text{entspricht genau } \texttt{eabc\_mass})
   \]

2. **Quadratische Achsen-Energie (BH-C-11):**
   Die Beiträge folgen den quadratischen Normen der quaternionischen Projektionen auf den Achsen:
   \[
   e_a = a_x^2 + a_y^2, \quad e_b = b_x^2 + b_y^2, \quad e_c = c_x^2 + c_y^2
   \]

3. **Quartische Kopplung bei Dualachsen:**
   Bei gemischten Dualkanälen (wie \(bc\)) verhält sich die Energie nicht-additiv (multiplikativ):
   \[
   E_{bc} = e_b \cdot e_c \quad (\text{nicht } e_b + e_c)
   \]

*Hinweis zur Abgrenzung:* Formfaktoren wie die Chiralitätsnorm (\(\chi\)) oder der Spread (\(S\)) sind geometrische Verteilungskoeffizienten der Konstellation — sie stellen Modulatoren dar, keine eigenständigen Beiträge zur additiven Eigenenergie.

---

## 3. Die funktionale Rolle im Modell-Testing (Atome/ORQ-092)

Die Einführung dieses formalen Begriffs klärt die Interpretation der statistischen Nullmodell-Tests in `tests/test_nuclear_binding_residual.py`:

* **Intrinsische Eigenenergie (\(E_{\mathrm{eigen}}\)):** Beschreibt die Konstellation *in sich selbst*. Sie ist mathematisch deterministisch aus dem quaternionischen Primzahlmodell ableitbar.
* **Fremd-Kopplung (\(H_{\mathrm{int}}\)):** Beschreibt die Schnittstelle zur realen Kernphysik (die Korrelation der EABC-Features mit den experimentellen Massenresiduen \(R(A,Z)\)).

Wenn die Korrelationstests gegen die Nullmodelle (`permute_R`, `shuffle_channel`, `variance_match`) auf kleinen Datensätzen (wie Toy-21) keine signifikanten \(z\)-Werte liefern, bedeutet dies:

> **Erkenntnistheoretische Konsequenz:** Nicht das EABC-Modell oder die Definition von \(E_{\mathrm{eigen}}\) ist fehlerhaft, sondern die naive lineare Projektion der unskalierten mathematischen Eigenenergie auf die stark nichtlinearen, kollektiven Effekte der Kernbindungsenergie (\(B_{\mathrm{exp}}\)) ist an dieser Stelle unzureichend. Die physikalische Kopplung erfordert komplexere Wechselwirkungs- und Renormierungsstrukturen (Kopplungsparameter), die über einfache lineare Korrelationen hinausgehen.

---

## 4. Scharf gezogene Claim-Grenze

1. **Keine QM-Eigenwerte:** \(E_{\mathrm{eigen}}\) ist ein algebraischer Repräsentationswert innerhalb des quaternionischen Modells. Es handelt sich ausdrücklich nicht um den quantenmechanischen Eigenwert eines nuklearen Hamilton-Operators.
2. **Keine direkte MeV-Skalierung:** Aus den unskalierten Koordinatenwerten \(a_x, a_y\) lässt sich keine absolute physikalische Energieeinheit (wie MeV) ableiten, ohne ein empirisch kalibriertes Kopplungsfunktional einzuführen.
3. **Nullmodellpflicht:** Jede physikalische Interpretation der Eigenenergie als Erklärungsgröße für reale Massenunterschiede steht unter permanentem Vorbehalt und muss sich rigoros gegen die definierten statistischen Nullmodelle bewähren.
4. **Keine Falsifikation der Algebra durch Toy-Residuen:** Ein negativer ORQ-092-Befund auf einer Stichprobe betrifft nur die Kopplungshypothese \(I_{\mathrm{EABC}}\leftrightarrow R\), nicht die Wohldefiniertheit von \(H(n)\) oder \(E_{\mathrm{eigen}}(K)\).
