# Dedekind-Idealtheorie-Schicht — Schnittstelle (E-064 / E-065 / E-066)

**Didaktischer Einstieg:** [Ideale, Dedekind-Hasse und quaternionische Primzahlpfade](energiedoku_exports/idealtheorie_abitur_kurz.md)

**Lean:** `KeplerHurwitz/DedekindIdealLayer.lean`  
**Basis:** E-053 (`DedekindHasseDumasInterface.lean`)

> Dedekind-Hasse prüft die PID-Fähigkeit. Dedekind-Idealtheorie beschreibt die Pfade.
> EABC interpretiert mögliche Signaturmuster.

## Schichten

| Schicht | Symbole | Status |
|---|---|---|
| Dedekind–Hasse (PID-Check) | `DedekindHasseCriterion`, `DedekindHasseImpliesPID` | `[C]` E-053 |
| Dedekind-Idealtheorie | `LeftIdeal`, `RightIdeal`, `PrincipalLeftIdeal`, `LeftPIDWitness` | `[C]` E-064 |
| Links/Rechts-Asymmetrie | `DedekindTest_DED3_*`, `LeftRightIdealPathAsymmetryStatement` | `[B]`/`[C]` E-065 |
| Idealclassen-Obstruktion | `DedekindTest_DED5_*`, `ReferenceOrdersNoIdealClassObstruction` | `[B]` E-066 |
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
