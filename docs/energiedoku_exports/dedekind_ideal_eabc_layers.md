# Dedekind-Ideal- und EABC-Schichten (E-064–E-066)

Didaktischer Einstieg: [Ideale, Dedekind-Hasse und quaternionische Primzahlpfade](idealtheorie_abitur_kurz.md)

**Lean:** `KeplerHurwitz/DedekindIdealLayer.lean`  
**Register:** E-064, E-065, E-066

## Drei Schichten

| Schicht | Mathematisches Bild | Rolle | Evidenz |
|---|---|---|---|
| **DH** | `α·ρ − β`, Norm `0 < N(·) < 1` | analytisch-metrisch; PID-Stabilitaetscheck | E-053 `[C]` |
| **Dedekind-Ideal** | `H·γ` vs. `γ·H`, Hauptideal-Ketten | topologisch-algebraisch; **einheiteninvariant** | E-064–E-066 `[C]`/`[B]` |
| **EABC mod 12** | `EABCSignature4`, Kanalprojektion | Interpretation moeglicher Signaturmuster | `[C]` offen |

> Dedekind-Hasse prueft die PID-Faehigkeit. Dedekind-Idealtheorie beschreibt die Pfade.
> EABC interpretiert moegliche Signaturmuster.

## Chiralitaet (E-065)

Pfad-Signaturen:

- links: `σ(H·γ)` via `principalLeftPathSigma`
- rechts: `σ(γ·H)` via `principalRightPathSigma`
- Indikator: `idealPathChiralityDelta = σ(H·γ) − σ(γ·H)` — numerischer Experiment-Check **in progress** `[B]`

## Obstruktion (E-066)

Referenzordnungen `H_{1,7}`, `H_{7,13}`: **keine** nichttriviale Idealclassen-Obstruktion gegen links-PID (DED-5 negativ). Obstruktionstest dient als negativer Kontrollrahmen fuer `h > 1` Ordnungen.

## Governance

- **DH beweist nicht EABC** und umgekehrt.
- Idealpfade sind invariant gegenueber Elementdarstellungen; `EabcInterpretationFromIdealPaths` bleibt offen.
- Dumas/Primvierling nur strukturelle Parallele (`dumasHostComponentPath`), kein Idealquotient.

**Build:** `lake build KeplerHurwitz.DedekindIdealLayer KeplerHurwitz.ReachableTheorems`
