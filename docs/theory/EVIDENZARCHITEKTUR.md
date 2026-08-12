# Evidenzarchitektur

**Kurzname:** Evidenzarchitektur (alias: epistemisches Governance-Modell)  
**Zweck:** Einheitliche Trennung der Erkenntnisebenen für alle Module des Projekts — unabhängig vom konkreten EABC-, Collatz- oder Semiprim-Kontext.  
**Methodik-Companion:** [`AUDIT_PROTOCOL_AP1.md`](AUDIT_PROTOCOL_AP1.md) (AP-1 Standard-Protokoll)

> *Dieses Kapitel folgt der Evidenzarchitektur des Projekts: formaler Kern `[A]`, reproduzierbare Audits `[B]`, klassifizierte Hypothesen `[C]` und Governance `[G]`.*

---

## Theorie vs. Methodik (#Energiedoku)

```
                    #Energiedoku Architektur
                              │
          ┌───────────────────┴───────────────────┐
          ▼                                       ▼
 THEORIE (Inhaltsebene)              METHODIK (Prozess-Framework)
 • [A] Formale Mathematik            • Evidenzarchitektur ([A]/[B]/[C]/[G])
 • Blindheitssätze & Invarianten     • Audit-Protokoll Standard (AP-1)
 • Formalismus der Greedy-Regeln     • Hypothesen-Taxonomie
 • Mathematischer Diversitätsindex D • Claim-Register & Vorregistrierung
                                     • Governance-Regeln (G-001 … G-008)
```

Inhalt und Prozess bleiben getrennt: Theorie ändert sich mit dem Modell; die Methodik bleibt invariant und übertragbar.

---

## Claim-Kennungen (projektweit)

| Präfix | Bedeutung |
|---|---|
| **A-xxx** | formaler Satz / Lemma |
| **B-xxx** | Audit-Befund |
| **C-xxx** / **C-Hx** | Forschungs-Hypothese |
| **G-xxx** | Governance- oder Modellgrenze |

**Register:** [`CLAIM_REGISTER.md`](CLAIM_REGISTER.md)  
**Abgrenzung:** `E-xxx` = Evidenz-/Artefakt-ID; `A/B/C/G-xxx` = Aussagen-ID.

Beispielreferenzen: **A-002** Offset-Dualität · **B-014** BASE-Audit-Dualität · **C-H7** Diversitätstrajektorie · **G-007** tautologische Aggregationen.

---

## Die vier Pfeiler

| Pfeiler | Rolle | Inhalt |
|---|---|---|
| **`[A]` Formale Mathematik** | bewiesen | Beweisbare Aussagen, algebraische Dualitäten, arithmetische Invarianten (Eigenschaften der Zahlen/Restklassen) |
| **`[B]` Empirische Audits** | reproduzierbar | Vorregistrierte Kennzahlen inkl. Unsicherheitsmaßen (z. B. \(D\) mit Bootstrap-CI) |
| **`[C]` Klassifizierte Hypothesen** | offen | Struktur- / Algorithmus- / Asymptotikhypothesen mit Evidenzmatrix und Entscheidungsprotokoll |
| **`[G]` Governance & Grenzen** | Rahmen | Geltungsbereich; verhindert Vermischung von Werkzeug- und Objekt-Eigenschaften |

### Hypothesen-Taxonomie innerhalb `[C]`

| Klasse | Fokus | Beispiele |
|---|---|---|
| **Strukturhypothesen** | Eigenschaften der mathematischen Objekte / Algebra | **C-H2A**, **C-H2B** |
| **Algorithmushypothesen** | Verhalten des gewählten Erzeugungsverfahrens | **C-H7** (Greedy, Diversitätsindex \(D\)) |
| **Asymptotikhypothesen** | Verhalten für \(N\to\infty\) / Skala | **C-H1**, **C-H4** |
| **Modellgrenzen** | Governance (nicht als `[C]`-Hypothese führen) | **G-006**, **G-007**, **G-008** (AP-1) |

**Leitunterscheidung:** *arithmetische Invarianten* (Zahlen/Restklassen) vs. *algorithmic artifacts* (Greedy-Regel). Eigenschaften des Werkzeugs dürfen nicht den Zahlen selbst zugeschrieben werden.

**Diagnostische Verfeinerung (C-H7-Nomenklatur):**
- **Diversitätstrajektorie \(D(N)\)** — Verlauf vs. Suchgrenze \(N\)
- **Familientrajektorie \(D_F(N)\)** — Verlauf beschränkt auf Familie \(F\in\{E,A,B,C\}\)
- **Trajektorienkohärenz** — strukturelle Ähnlichkeit der \(D_F(N)\) (Korrelation / \(\max|D_{F_1}-D_{F_2}|\)); misst Algorithmen-Stabilität gegenüber Klassen-Symmetrien

**G-007 (Interpretationsregel für tautologische Aggregationen):** Sind aggregierte Kennzahlen oder Mittelwerte aufgrund der formalen Definition oder der Konstruktion des Algorithmus mathematisch/systemisch identisch, ist eine Interpretation dieser Mittelwerte als inhaltlicher Befund unzulässig. In diesen Fällen dürfen **ausschließlich der funktionale Verlauf, die Streuung, die Phasenlage sowie die Form der Trajektorien** (\(D(N)\) bzw. \(D_F(N)\)) ausgewertet und interpretiert werden.
### Ebene `[A]` — Formale Mathematik

- Definitionen
- Sätze
- Beweise
- exakte Invarianten (z. B. Offset-Dualität)

**Statuswort:** bewiesen / Definition.

### Ebene `[B]` — Reproduzierbare Audits

- vorregistrierte Kennzahlen
- feste Toleranzbänder
- Regressionstests
- Replikationen
- dokumentierte Datensätze / Exports

**Statuswort:** reproduzierbare Empirie.  
**Kein** Upgrade von `[B]` zu `[A]` allein durch numerische Stabilität.

### Audit-Unterklassen und AP-1

Jedes neue `[B]`-Audit zu Greedy-/Farbfamilien folgt dem **Audit-Protokoll Standard (AP-1)** — sechs Phasen: Vorregistrierung → Kennzahlen → Kontrollen → Entscheidungsmatrix → Artefakte → Governance-Prüfung. Details: [`AUDIT_PROTOCOL_AP1.md`](AUDIT_PROTOCOL_AP1.md).

| Audit-Klasse | Fokus | Beispiele |
|---|---|---|
| **Struktur-Audits** | Offsets, Fenster, lokale Dualität | **B-011**–**B-014** |
| **Trajektorien-Audits** | \(D(N)\), \(D_F(N)\), Kohärenz | **B-015**, **B-015b** |
| **Kontroll-Audits** | K1–K4 / Kalibrierung | **B-K*** (BA-Kontrollstudie) |

### Ebene `[C]` — Forschungsprogramm

- Konkurrenzhypothesen
- Kontrollfamilien
- Evidenzmatrix
- Falsifikationsprinzip
- Entscheidungsprotokoll

**Statuswort:** offen / Arbeitshypothese.  
**Kein** Upgrade von `[C]` zu `[B]` ohne vorregistrierten Audit; **kein** Upgrade zu `[A]` ohne Beweis.

**Governance** (Modellgrenzen) ist von `[C]`-Hypothesen zu trennen: organisatorische Abgrenzung, keine empirisch-mathematische Vorhersage.

---

## Querschnittsprinzipien

| Prinzip | Inhalt |
|---|---|
| **Korrelation ≠ Strukturidentität** | Übereinstimmung empirischer Kennzahlen begründet weder Mechanismusgleichheit noch Asymptotik. |
| **Vorregistrierung (`[B]`)** | Vor der Auswertung: Kennzahlen, Toleranzbänder, Kontrollfamilien, Entscheidungskriterien. |
| **Falsifikation (`[C]`)** | Jede Hypothese soll mindestens einen Test besitzen, der sie von einer Konkurrenzhypothese unterscheidet. |
| **Kontrollprinzip** | Strukturelle Erklärungen gewinnen Evidenz nur, wenn sie vorhersagen, wo der Effekt verschwindet oder sich ändert. |
| **Entscheidungsprotokoll** | Vor dem Audit ist festgelegt, welche Ergebnisse welche Konsequenz haben. |
| **Objekttrennung / GOVERNANCE** | Verschiedene Objekte (z. B. Konstellation vs. Einzelzahl-Normalform) erlauben keinen stillschweigenden Transfer; Modellgrenzen sind keine empirischen Hypothesen. **G-007:** tautologische Aggregationen nicht als Befund lesen. |

### Statuswort „Richtung gestützt“

Die beobachteten Daten entwickeln sich konsistent mit der Hypothese und zeigen systematische Tendenzen im Sinne der Vorhersage, erfüllen jedoch aufgrund verbleibender Unsicherheiten oder variierender Kontrollgruppen **nicht** die Kriterien für einen Nachweis oder eine finale Entscheidung. Die Hypothese bleibt somit **explizit offen**.

---

## Entscheidungsprotokoll

Für jede Hypothese der Ebene `[C]` wird **vor** dem Audit festgelegt, welche Ergebnisse welche Konsequenz haben.

### Beispiel (H2A vs H2B)

| Ergebnis des Audits | Konsequenz |
|---|---|
| Effekt verschwindet in K1–K4 | Evidenz für H2A |
| Effekt bleibt in allen K1–K4 erhalten | Evidenz für H2B |
| Gemischtes Bild | keine Entscheidung; Modell verfeinern |
| Starke Abweichung von beiden Vorhersagen | H2A und H2B überarbeiten oder neue Hypothese formulieren |

Damit ist nicht nur festgelegt, **wie** gemessen wird (Vorregistrierung), sondern auch **wie** die Ergebnisse interpretiert werden.

---

## Dualitätsleiter (Beispielschema)

Wo arithmetische Symmetrie und numerische Nähe zusammentreffen:

\[
\text{exakte Dualität }[A]
\;\Longrightarrow\;
\text{Audit-Dualität }[B]
\;\not\!\Longrightarrow\;
\text{Asymptotische Dualität }[C]
\]

Der erste Pfeil bezeichnet die epistemische Stufenfolge (Motivation des Audits), keine logische Ableitung der Kennzahlennähe aus dem Offset allein.

---

## Verwendung in Modulen

1. Am Kapitelanfang die Kurzformel zitieren (siehe oben).  
2. Aussagen explizit mit `[A]`, `[B]` oder `[C]` taggen; Governance gesondert.  
3. Bei `[B]`: **AP-1** durchlaufen (Vorregistrierung, Kontrollen, Entscheidungsmatrix, Artefakte, Governance-Check).  
4. Bei `[C]`: Evidenzmatrix + Entscheidungsprotokoll führen.  
5. Keine stillschweigenden Upgrades zwischen Ebenen.

**Referenzfälle:**  
- AP-1: [`AUDIT_PROTOCOL_AP1.md`](AUDIT_PROTOCOL_AP1.md)  
- BA/BAC/BAE: [`noncanonical_twin_color_extensions.md`](noncanonical_twin_color_extensions.md), [`../exports/ba_hypothesis_claims_report.md`](../exports/ba_hypothesis_claims_report.md)  
- Trajektorien-Referenzinstanz: [`../exports/ba_C_H7_first_vs_self_extension_report.md`](../exports/ba_C_H7_first_vs_self_extension_report.md)  
- Semiprimale Normalform (Objekttrennung): [`../eabc_normal_form.md`](../eabc_normal_form.md) (E-096)

---

## Was die Evidenzarchitektur absichtlich nicht ist

- kein Ersatz für Beweise  
- kein Freibrief, Audit-Stabilität als Theorem zu lesen  
- keine physikalische oder zahlentheoretische Existenzaussage jenseits der markierten Claims
