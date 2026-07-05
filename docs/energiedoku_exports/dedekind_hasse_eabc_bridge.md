# Dedekind–Hasse ↔ EABC: Lean-Brückendokumentation (E-054)

Stand: 4. Juli 2026  
Lean: `KeplerHurwitz/DedekindHasseProofAttempt.lean`  
Artikel: `docs/energiedoku_exports/eabc_renormalisierungsprogramm.md` §13

## Zweck

Methodische Parallele zwischen

1. **Dedekind–Hasse-Reduktion** (quaternionische Ordnungen, Cardoso–Machiavelo), und  
2. **EABC-Renormalisierung** (`prime_norm_full_restoration` in `eabc-renorm`).

**Explizit nicht behauptet:** DH beweist EABC; PID erklärt `R^*`.

## Pipeline (beide Programme)

```
globale Struktur → lokale Reduktion → endlicher Check → Zertifikat
```

| Stufe | Dedekind–Hasse | EABC |
|-------|----------------|------|
| Global | `DedekindHasseLeftPID` | `IsotropyRestorationGlobalStatement` |
| Lokal | `DedekindHasseReductionProperty` | `EabcRetractionLocalStatement` |
| Endlich | `CardosoMachiaveloFiniteness` | `EabcFiniteShellCheckStatement` |
| Zertifikat | `DedekindHasseLeftPID` | `EabcFiniteCertificateStatement` |

Lean-Struktur: `ReductionArchitecture` (E-053) mit `dedekindHasseReductionArchitecture` und `eabcRenormalizationReductionArchitecture`.

## Governance

| Tag | Inhalt |
|-----|--------|
| `[A]` | DH-Kriterium-Schnittstelle, isotrope Signatur → Exzentrizität 0, Dumas-4↔4, Status-Bündel |
| `[C]` | EABC-Zertifikat (extern in `eabc-renorm`), Φ-Abbildung, Brücken-Implikation |

## Didaktischer Einstieg

Abitur-taugliche Einordnung von Divisionalgebren, Norm-Euklidizität und Dedekind-Hasse (Abschnitt 6–7):
[`idealtheorie_abitur_kurz.md`](idealtheorie_abitur_kurz.md) — didaktisch, kein Beweisanspruch.

## Verwandte Module

- `KeplerHurwitz/DedekindHasseDumasInterface.lean` — E-053, DH ↔ Dumas
- `eabc-renorm/EabcRenorm/TensorRestoration.lean` — verifiziertes `prime_norm_full_restoration`
- `KeplerHurwitz/ReachableTheorems.lean` — Hub-Exporte `reachable_dedekindHasse_*`

## Offene Schnittstelle

Explizite Abbildung `Φ : EABC-Konfigurationen → quaternionische Ordnung` fehlt.  
Bis dahin: Architektur-Analogie, keine etablierte mathematische Korrespondenz.

**Interface-Dokumentation (Governance, `[C]`):**

| | |
|---|---|
| **Domain** | EABC-Kanalstruktur / kanonischer Primzahlvierling \(v=(p,p+2,p+6,p+8)\) |
| **Codomain** | \(\gamma=\Phi(v)\) in Quaternionenordnung \(H\); Linksideal \(H\gamma\), Rechtsideal \(\gamma H\) |
| **Arithmetisch geschlossen** | \(M(P(v))=4\), \(H(P(v))=(1,1,1,1)\) — strukturell testbar `[B]` |
| **Offen** | \(\Phi(v)=\gamma\) — dedekindische Brücke `[C]` |

Formale LaTeX-Einordnung: [`eabc-renorm/docs/EABC_Uebersicht.tex`](../../eabc-renorm/docs/EABC_Uebersicht.tex), Abschnitt `sec:prime-quadruple-dedekind` (Build-Alias `eabc_renorm_overview.tex`).  
Repo-Doku: [`pure_prime_quadruple_dedekind_interpretation.md`](../pure_prime_quadruple_dedekind_interpretation.md).
