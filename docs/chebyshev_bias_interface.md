# Chebyshev mod-4-Bias — Schnittstelle [C] (E-050)

**Evidenz:** `[C]` · **Lean-Label:** E-050 · **Register:** E-050  
**Quelle:** `KeplerHurwitz/ChebyshevBiasInterface.lean`  
**Abhaengigkeiten:** E-048 (Dumas, nur Typimport — kein Beweis der Bruecke)

## Abgrenzung

| Schicht | ID | Inhalt | Status |
|---|---|---|---|
| Endliche Host-Kombinatorik | **E-048** | `hostTriple`, `dumasLemma`, Gap kodiert Host | `[A-T]` bewiesen |
| Globales mod-4-Rennen | **E-050** | `π(x;4,3) − π(x;4,1)`, Chebyshev-Bias-Hypothesen | `[C]` offen |

E-048 und E-050 werden **nicht** vermischt: Dumas ist pointwise endliche Kombinatorik auf
einem Primvierling; Chebyshev-Bias ist ein globales asymptotisches Dirichlet-Rennen.

## Lean-Symbole

- `oddPrimesBelow`, `pi_mod4`, `chebyshevBiasDifference` — endliche Zaehldefinitionen
- `[C]` Hypothesen: `ChebyshevBiasMostlyThreeModFour`, `ChebyshevBiasSignChangesInfinitelyOften`,
  `GRHImpliesChebyshevBias`, `GRHImpliesChebyshevBiasSignChanges`
- `[C]` Bruecke (offen): `ChebyshevDumasInterface` — verlangt kuenftige Korrelation Host-Rolle ↔ globales Rennen

## Bewiesen in Lean (ohne analytische Zahlentheorie)

- `pi_mod4_residue_one_or_three` — jede ungerade Primzahl `> 2` ist `≡ 1` oder `≡ 3 (mod 4)`
- `hostComponent_mod4_one_or_three` — Host-Komponenten eines Primquadruplets liegen in `{1,3} mod 4`
- Kleine `decide`-Beispiele fuer `chebyshevBiasDifference` bei `x ∈ {3, 10}`

## Governance

- **Nicht behauptet:** Beweis des Chebyshev-Bias, der Primquadruplet-Unendlichkeit,
  oder einer Dumas–Chebyshev-Verschmelzung
- **Referenz:** Rubinstein–Sarnak (mod `GRH`) fuer Vorzeichenwechsel und asymptotischen Bias
- Siehe auch: `docs/dumas_lemma.md` (E-048)
