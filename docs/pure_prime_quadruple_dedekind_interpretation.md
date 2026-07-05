# Primzahlvierlinge im Lichte der dedekindschen Idealtheorie

**Evidenz:** `[B]`/`[C]` — arithmetische Lesart definitorisch/getestet; idealtheoretische Brücke offen  
**Register:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-046/E-048 (Primvierling/Dumas), E-072 (mod-12-Kanalpartition), E-073 (HoTT Identity Layer)  
**LaTeX-Anschluss:** [`eabc-renorm/docs/EABC_Uebersicht.tex`](../../eabc-renorm/docs/EABC_Uebersicht.tex), Abschnitt `sec:prime-quadruple-dedekind` (Build-Alias `eabc_renorm_overview.tex`)  
**Brückendoku:** [`docs/energiedoku_exports/dedekind_hasse_eabc_bridge.md`](energiedoku_exports/dedekind_hasse_eabc_bridge.md)

---

## Arithmetische Schicht (geschlossen, `[B]`)

Kanonische Primzahlvierlinge \(v=(p,p+2,p+6,p+8)\), \(p>3\), mit Komponentenprodukt
\(P(v)=p(p+2)(p+6)(p+8)\) erfüllen strukturell

\[
H(P(v))=(1,1,1,1), \qquad M(P(v))=4.
\]

Die quaternionische Norm \(n(v)=\|v\|^2\) hat eine eigene Faktorisierung; \(M(n(v))\) wird nur als Referenz-/Empiriegröße geführt — kein globaler Satz \(M(n(v))=2\).

---

## Interface \(\Phi\) (formal dokumentiert, Implementierung `[C]` offen)

Die dedekindische Brücke ist als **Governance-Schnittstelle** beschrieben, auch ohne konkrete Lean-/Python-Implementierung:

| | |
|---|---|
| **Domain** | EABC-Kanalstruktur / kanonischer Primzahlvierling \(v=(p,p+2,p+6,p+8)\) |
| **Codomain** | \(\gamma=\Phi(v)\) in einer konkreten Quaternionenordnung \(H\); Idealpfade \(H\gamma\), \(\gamma H\) |
| **Status** | `[C]` offen — keine etablierte mathematische Korrespondenz |

Erst mit \(\Phi\) werden aus \(v\) Linksideal- und Rechtsidealkandidaten analysierbar. Ohne \(\Phi\) bleibt der Zusammenhang methodisch (DH ↔ EABC-Architektur), nicht deduktiv.

---

## Governance-Grenze

\[
M(P(v))=4
\quad\text{ist arithmetisch strukturell testbar,}
\]

aber

\[
\Phi(v)=\gamma
\quad\text{ist die offene Brücke zur dedekindischen Idealtheorie.}
\]

**Nicht behauptet:** Primvierling \(\Rightarrow\) Primideal; \(M(n(v))\) \(\Rightarrow\) Dedekind–Hasse-Kontrolle; Kanalabdeckung \(\Rightarrow\) Idealchiralität.

---

## Lift-Projektions-Prinzip (methodische Brücke, `[C]`)

Quaternionen \(\gamma_v\) und Keplerellipsen sind **nicht identisch** — sie verbinden sich über dasselbe Schema Lift → Schnitt → Projektion. Die Normschale \(N(\gamma)\) entspricht methodisch dem Givental-Kegel; \(\pi_Q : H \to \mathbb{Z}^4_{\mathrm{EABC}}\) der Kepler-Projektion \(\pi_K\).

**Detail:** [`lift_projection_principle.md`](lift_projection_principle.md) · Givental-Parallele E-075: [`e075_prime_grid_signaturgeometrie.md`](energiedoku_exports/e075_prime_grid_signaturgeometrie.md)
