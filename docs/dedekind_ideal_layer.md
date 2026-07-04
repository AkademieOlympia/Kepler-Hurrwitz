# Dedekind-Idealtheorie-Schicht — Schnittstelle (E-067 / E-068 / E-069)

**Didaktischer Einstieg:** [Ideale, Dedekind-Hasse und quaternionische Primzahlpfade](energiedoku_exports/idealtheorie_abitur_kurz.md)

**Lean:** `KeplerHurwitz/DedekindIdealLayer.lean`  
**Basis:** E-053 (`DedekindHasseDumasInterface.lean`)

> Dedekind-Hasse prüft die PID-Fähigkeit. Dedekind-Idealtheorie beschreibt die Pfade.
> EABC interpretiert mögliche Signaturmuster.

## Schichten

| Schicht | Symbole | Status |
|---|---|---|
| Dedekind–Hasse (PID-Check) | `DedekindHasseCriterion`, `DedekindHasseImpliesPID` | `[C]` E-053 |
| Dedekind-Idealtheorie | `LeftIdeal`, `RightIdeal`, `PrincipalLeftIdeal`, `LeftPIDWitness` | `[C]` E-067 |
| Links/Rechts-Asymmetrie | `DedekindTest_DED3_*`, `LeftRightIdealPathAsymmetryStatement` | `[B]`/`[C]` E-068 |
| Idealclassen-Obstruktion | `DedekindTest_DED5_*`, `ReferenceOrdersNoIdealClassObstruction` | `[B]` E-069 |
| EABC-Interpretation | `EabcInterpretationLayer`, `EabcInterpretationFromIdealPaths` | `[C]` offen |

## Tests DED-1 … DED-5

Prop-Schnittstellen (keine numerischen Experimente):

- **DED-1:** `DedekindTest_DED1_DedekindHasseImpliesPID`
- **DED-2:** `DedekindTest_DED2_PrincipalIdealPath`
- **DED-3:** `DedekindTest_DED3_LeftRightPathAsymmetry`
- **DED-4:** `DedekindTest_DED4_IdealFactorizationChain`
- **DED-5:** `DedekindTest_DED5_NonPIDIdealClassObstruction`

## Governance

**Nicht behauptet:** Idealtheorie beweist keine EABC-Signatur; `EabcInterpretationFromIdealPaths` ist offen.
Dumas (`dumasHostComponentPath`) nur strukturelle Parallele, kein Idealquotient.

**Build:** `lake build KeplerHurwitz.DedekindIdealLayer`

---

## Glatte Hamming-Zahlen und das `{2,3,5}`-Gerüst `[C]`

### Was sind glatte Hamming-Zahlen?

**Hamming-Zahlen** (auch **5-glatte Zahlen** oder **regular numbers**) sind natürliche Zahlen, deren Primteiler nur **2, 3 und 5** sind:

$$S_{235}=\{2^a 3^b 5^c \mid a,b,c\in\mathbb N_0\}
=\{1,2,3,4,5,6,8,9,10,12,15,16,\dots\}.$$

Auf **Elementebene** hat jedes $n\in S_{235}$ eine **eindeutige** Zerlegung in die drei Primfaktoren — im Gegensatz zu Ringen wie $\mathbb Z[\sqrt{-5}]$, wo Elementzerlegungen kollabieren können (siehe didaktischer Einstieg, Abschnitt 3).

In der **#Energiedoku** erscheint $S_{235}$ nicht als physikalische Primfaktorbehauptung, sondern als **minimale glatte Skalenhülle** für diskrete Skalenlifts (Artikel §11 in [`eabc_renormalisierungsprogramm.md`](energiedoku_exports/eabc_renormalisierungsprogramm.md)).

### Bezug zur Ideal-/Pfad-Schicht

| Ebene | Bild | Rolle |
|---|---|---|
| **Element** | $n=2^a3^b5^c$ | explizite Zahl; Faktorisierung in `{2,3,5}` eindeutig |
| **Monoid / Struktur** | $S_{235}$ als multiplikatives Gerüst | kontrollierte Skalenmenge; Rekursion `g_i = min{s∈S \| …}` liefert **Pfade** entlang Chiralitätsworten |
| **Idealtheorie (E-067)** | Linksideale, Hauptideal-Ketten | einheiteninvariante Pfade in quaternionischen Ordnungen — **andere** Zahlwelt als $S_{235}$ |

Die didaktische Parallele ist **methodisch**, nicht formal bewiesen:

- **Enge Primleiter `{2,3,5}`:** Elementdarstellungen bleiben in einem kleinen, gut kontrollierten Faktorband — wenig „Rauschen“ von grossen Primteilerwechseln.
- **Ideale in nichtkommutativen Ordnungen:** Elemente können täuschen; Idealpfade stabilisieren die Struktur (E-067–E-069).
- **Hamming-Skala vs. Quaternion-Ideal:** $S_{235}$ beschreibt **Skalenlifts** im EABC-Renormalisierungsprogramm; Dedekind-Ideale beschreiben **arithmetische Pfade** in Ordnungen wie $\mathcal H_{1,7}$ — ohne etablierte Abbildung zwischen beiden.

### Abgrenzung im Repo

| Begriff | Bedeutung hier | Datei / Evidenz |
|---|---|---|
| **Glatte Hamming-Zahlen** $S_{235}$ | 5-glatte Skalenhülle `{2,3,5}` | `eabc_renormalisierungsprogramm.md` §11 |
| **`IsBSmooth` / B-Glattheit** | Collatz: alle Primteiler $\leq B$ | `KeplerHurwitz/SmoothAttraktor.lean`, E-011–E-014 |
| **Hamming-Gewicht** | GF(2)-Code: Anzahl Einsen in einem Wort | `qec_bridge.py`, E-038 — **nicht** Hamming-Zahlen |

### Governance `[C]`

**Nicht behauptet:**

- Hamming-Zahlen beweisen **nicht** Dumas (E-048), Dedekind-PID (E-053) oder EABC-Isotropierestauration.
- Die Eindeutigkeit der Zerlegung in $S_{235}$ ist **kein** Modell für quaternionische Primideale — nur illustratives Gegenstück zu Elementchaos in $\mathbb Z[\sqrt{-5}]$.
- Die Verbindung Skalenhülle ↔ Idealpfad bleibt **offen** (`[C]`); sie ersetzt keine explizite Abbildung $\Phi$ (vgl. E-053-Governance).

**Illustrativ:** In $S_{235}$ zeigen die **Elemente** bereits eine saubere `{2,3,5}`-Struktur; in verzerrten Quaternionenordnungen rettet **Idealtheorie** die Pfadstabilität, wenn Elementzerlegungen allein nicht genügen — und **Dedekind-Hasse** prüft, ob diese Idealstruktur PID-tauglich bleibt.
