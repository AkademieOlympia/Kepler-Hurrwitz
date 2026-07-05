# Lift-Projektions-Prinzip (Quaternionen ↔ Kepler/Givental)

**Status:** `[C]` methodische Brücke — **kein** Identitätsclaim  
**Register:** E-075 (Prime Grid / Givental-Parallele), E-067–E-069 (Dedekind-Ideal-Schicht)  
**Architektur:** [`ARCHITECTURE.md`](../ARCHITECTURE.md) — Bridge Interfaces `[C]`, Interpretation `L4`

---

## Was **nicht** behauptet wird

> **Quaternionen sind Keplerellipsen** — **falsch als Identität.**

Quaternionen und Keplerellipsen leben auf **verschiedenen Ebenen**. Die Verbindung ist **methodisch**: gleiches Schema (Lift → Schnitt → Projektion), nicht gleiche Objekte.

---

## Drei Ebenen (Governance)

| Ebene | Objekt | Rolle | Tag |
|---|---|---|---|
| **Lift-Raum** | Quaternionenordnung \(H\), Normschale \(N(\gamma)=a^2+b^2+c^2+e^2\) | Signatur-/Lift-Geometrie, assoziativer Kern | `[A]`/`[B]` (arithmetisch) |
| **Schnitt** | \(Q \cap S\) — Quaternionenmenge \(\cap\) Normschale / EABC-Schnitt | Zwischenstufe mit Invarianten | `[B]`/`[C]` |
| **Projektion** | \(\pi_K\) (Kepler) bzw. \(\pi_Q\) (EABC) | Beobachtbare niedrigdimensionale Größen | `[B]`/`[C]` |

**Nicht behauptet:** \(\pi_K = \pi_Q\); Quaternion \(\Rightarrow\) Primideal; \(M(n(v)) \Rightarrow\) Dedekind–Hasse-Kontrolle.

---

## Givental: Kepler als Projektion von Schnitten

Givental (*Kepler's laws and conic sections*) formuliert Keplersche Gesetze als **Kegelschnitt-Invarianten**:

1. **Lift:** Ebene \((x,y)\) auf den Kegel \(r^2 = x^2 + y^2\)
2. **Schnitt:** Kegel \(\cap\) Ebene \(\Pi\) → Kurve \(C \cap \Pi\) (Ellipse, Parabel, Hyperbel)
3. **Projektion:** \(\pi_K : C \cap \Pi \to \mathbb{R}^2\) → **Keplerellipse** (beobachtbare Bahn-Invarianten)

Die Ellipse ist **Projektion eines Schnitts**, nicht das ursprüngliche Lift-Objekt.

**PDF:** [`docs/mathematische_texte/givental_kepler_laws_conic_sections.pdf`](mathematische_texte/givental_kepler_laws_conic_sections.pdf)

---

## EABC-Analogie: gleiche Methode, andere Objekte

| Givental (Kepler/Kegel) | EABC / Quaternionen (Lesart) |
|---|---|
| Ebene: Bahn/Kepler-Orbit | Priminformation, Prime Grid, Hurwitz-Signatur |
| Kegel-Lift \(r^2=x^2+y^2\) | Normschale \(N(\gamma)=a^2+b^2+c^2+e^2\) |
| Schnitt \(C \cap \Pi\) | \(Q \cap S\) — EABC-Quaternionen \(\cap\) Norm-/Signaturbedingungen |
| Projektion \(\pi_K\) → Ellipse | Projektion \(\pi_Q : H \to \mathbb{Z}^4_{\mathrm{EABC}}\), \(H(n)=(E,A,B,C)\) |
| Kepler-Invarianten \((a,e,L,T,\ldots)\) | \(M(n)=E+A+B+C\), \(Q(n)=\max\{E,A,B,C\}\), Shell-Tensoren |

\[
\pi_K(C \cap \Pi) \longleftrightarrow \pi_Q(Q \cap S)
\]

**Methodisch parallel** — Schnittgeometrie liefert Invarianten nach Projektion. **Nicht identisch** — andere Domäne, andere Projektionsregeln, andere Invarianten.

> **Governance `[C]`:** Givental-Kegel-Lift ist **kein** Beweis der EABC-Isotropierestauration, der Dedekind–Hasse-Analogie oder von Lean-Zertifikaten. Siehe auch [`e075_prime_grid_signaturgeometrie.md`](energiedoku_exports/e075_prime_grid_signaturgeometrie.md).

---

## Primvierling: konkretes Beispiel

Kanonischer Primzahlvierling \(v=(p,p+2,p+6,p+8)\), \(p>3\):

| Größe | Definition | Tag |
|---|---|---|
| Komponentenprodukt | \(P(v)=p(p+2)(p+6)(p+8)\) | `[B]` |
| EABC-Signatur | \(H(P(v))=(1,1,1,1)\), \(M(P(v))=4\) | `[B]` |
| Quaternion \(\gamma_v\) | \(\Phi(v)=\gamma\) — Interface zur Ordnung \(H\) | **`[C]`** offen |
| Norm | \(N(\gamma_v)=a^2+b^2+c^2+e^2\) | Referenz-/Empiriegröße |
| Vergleich | \(H(P(v))\) vs. \(H(N(\gamma_v))\) | **`[C]`** — keine etablierte Korrespondenz ohne \(\Phi\) |

Arithmetisch geschlossen: \(M(P(v))=4\). Offen: \(\Phi(v)=\gamma\) als dedekindische Brücke.

**Detail:** [`pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md), [`dedekind_hasse_eabc_bridge.md`](energiedoku_exports/dedekind_hasse_eabc_bridge.md)

---

## Repo-Anschluss (Leit-Hypothese)

In [`grundgedanken.md`](grundgedanken.md) ist die Projektionskette skizziert:

\[
n \longmapsto \mathcal{H}(n) \longmapsto \mathcal{C}(n) \longmapsto \kappa_{\mathrm{Kepler}}(n)
\]

- \(\mathcal{H}(n)\): orientierte Hurwitz-Signatur (8-Koordinaten-Doppelkegel)
- \(\mathcal{C}(n)\): arithmetischer Kegelschnitt
- \(\kappa_{\mathrm{Kepler}}(n)\): Kepler-Invariantensystem \((a,e,L,T,v_{\mathrm{peri}},v_{\mathrm{apo}},R_v)\)

**Implementierung:** `src/kepler_hurwitz/kepler.py` (`kepler_invariants`), Signatur-Schicht `src/kepler_hurwitz/signatures.py` (\(M(n)=E+A+B+C\)). Eine dedizierte Funktion `project_to_kepler` ist im Repo **noch nicht** etabliert; die formale Lift-Schicht in Lean (`KeplerHurwitz/Representation/KeplerEABCAtlas.lean`, `FormalFloquetChiLiftStatement`) dokumentiert die Kanal-Liftung ohne dynamischen Kepler-Claim.

---

## Explizit nicht behauptet

| Claim | Status |
|---|---|
| Quaternionen **sind** Keplerellipsen | **falsch** |
| Givental-Geometrie **beweist** EABC oder Dedekind–Hasse | **falsch** |
| \(M(n(v))=2\) global für Primvierling-Normen | **nicht behauptet** |
| Primvierling \(\Rightarrow\) Primideal | **nicht behauptet** |
| Kanalabdeckung \(\Rightarrow\) Idealchiralität | **nicht behauptet** |

---

## Schluss

**Gleiche Methode, nicht gleiche Objekte.**

Lift-Räume (Kegel, Normschale, Hurwitz-Doppelkegel) tragen mehr Information als ihre Projektionen (Ellipse, EABC-Signatur, Kepler-Invarianten). Die Brücke ist ein **Governance-Interface** für strukturelle Parallelen — nicht eine mathematische Identifikation.

---

## Verwandte Dokumente

| Dokument | Rolle |
|---|---|
| [`grundgedanken.md`](grundgedanken.md) | Hurwitz-Doppelkegel, Kepler-Invarianten, Leit-Hypothese |
| [`pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md) | \(\Phi(v)=\gamma\), \(M(P(v))=4\) |
| [`e075_prime_grid_signaturgeometrie.md`](energiedoku_exports/e075_prime_grid_signaturgeometrie.md) | Prime Grid, Givental-Parallele (E-075) |
| [`dedekind_hasse_eabc_bridge.md`](energiedoku_exports/dedekind_hasse_eabc_bridge.md) | Dedekind–Hasse-Interface |
| [`related-work.md`](related-work.md) | externe Quellen (Givental, Kolossváry) |
| [`ARCHITECTURE.md`](../ARCHITECTURE.md) | Schichtenmodell, Bridge Interfaces `[C]` |
