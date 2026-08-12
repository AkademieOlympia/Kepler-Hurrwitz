# EABC-Masse und kanonische Signatur H(n)

> **Governance — lokale Referenzschicht:** Dieses Dokument und die Python-Implementierung in `signatures.py` sind die **lokale Referenzschicht `[B]`** für \(H(n)\) und \(M(n)\). Sie stehen **vor** einer vollständigen Lean-Bridge; Lean (`EABCLayer.lean`) bleibt die formale Schicht `[A]`, ist aber hier noch nicht durchgängig angebunden.

**Implementierung:** `src/kepler_hurwitz/signatures.py` (`signature_from_nat`, `eabc_mass`)  
**Lean:** `KeplerHurwitz/EABCLayer.lean` (`EABCSignature4`, `totalWeight`)  
**Kanalabbildung:** `eabc_channel_from_mod12` in `dumas_natural_fill.py` (1→E, 5→A, 7→B, 11→C)  
**Normalform \(n=2^\alpha 3^\beta r\,e\):** [`docs/eabc_normal_form.md`](eabc_normal_form.md) · Lean `KeplerHurwitz/EABC/NormalForm.lean` · Register [`E-096`](../EVIDENCE_REGISTER.md) · [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md)

**Nomenklatur \(e\) vs. \(e_{\mathrm{kep}}\):** In der Normalform ist \(e\) ausschließlich der Mod-12-**E-Faktor** (\(p\equiv 1\bmod 12\)). Die Kepler-Exzentrizität heißt \(e_{\mathrm{kep}}\) (Lean `EABCSignature4.eccentricity` / `projectToKepler`); sie ist **nicht** der E-Faktor und **nicht** der Kanalzähler \(E\) in \(H(n)=(E,A,B,C)\). Pipeline und Governance: [`eabc_normal_form.md` §7](eabc_normal_form.md).

## Definition

Für natürliches \(n \ge 1\) sei \(H(n) = (E,A,B,C)\) die **additive Primfaktor-Zählfunktion**:

- zähle jeden Primteiler \(p \mid n\) **mit Multiplizität** \(\Omega(p)\);
- **ohne** die Achsen \(p \in \{2, 3\}\);
- ordne \(p > 3\) per Restklasse mod 12 den Kanälen E/A/B/C zu (invertible Klassen 1, 5, 7, 11).

Die **kanonische EABC-Masse** ist

\[
M(n) := \mathrm{totalWeight}(H(n)) = E + A + B + C = \Omega_{EABC}(n).
\]

Damit ist \(H(n)\) kompatibel zur aggregierten Signatur in `docs/grundgedanken.md` (ohne \(O\) und ohne Chiralitätsanteile \(A^\pm,B^\pm,C^\pm\)).

## Kanonische Signatur vs. Partitionsform

| Objekt | Bedeutung | Form |
|---|---|---|
| **Kanonische Signatur** \(H(n)\) | geordnete Kanalzählungen mit **fester Kanalzuordnung** | **(E, A, B, C)** — Positionen sind semantisch, nicht sortiert |
| **Partitionsform** | Typisierung für \(\Omega_{EABC} \le 4\) (Arbeitsprogramm Phase 4) | nicht-absteigende Zählwerte, z. B. (2,1,0,0) |

**Wichtig:** `EABCSignature4.sorted_counts()` liefert **nicht** die kanonische Signatur. Die Methode sortiert die vier Kanalzähler absteigend und dient ausschließlich der **Phase-4-Partitionsform** (Vergleich mit den Partitionstypen in `docs/arbeitsprogramm.md` für \(\Omega_{EABC} \le 4\)).

Beispiel \(n = 210 = 2 \cdot 3 \cdot 5 \cdot 7\):

- kanonisch: \(H(210) = (0, 1, 1, 0)\) — A und B je einmal, E und C leer;
- Partitionsform: `sorted_counts()` → (1, 1, 0, 0) — nur die Zählwerte, ohne Kanalnamen.

Die kanonische Signatur bleibt immer geordnet als **(E, A, B, C)**; die Partitionsform ist ein abgeleitetes, kanalagnostisches Hilfsobjekt.

## Referenzbeispiele

| \(n\) | \(H(n)\) | \(M(n)\) | Anmerkung |
|------:|----------|---------:|-----------|
| 1 | (0,0,0,0) | 0 | leer |
| 13 | (1,0,0,0) | 1 | \(k=1\), Partition (1,0,0,0) |
| 65 | (1,1,0,0) | 2 | \(k=2\), Partition (1,1,0,0) |
| 210 | (0,1,1,0) | 2 | \(2\cdot3\cdot5\cdot7\), Achsen abgespalten |
| 455 | (1,1,1,0) | 3 | \(k=3\), Partition (1,1,1,0) |
| 539 | (0,0,2,1) | 3 | \(7^2\cdot11\), siehe `docs/arbeitsprogramm.md` Phase 5 |
| 5005 | (1,1,1,1) | 4 | \(k=4\), Partition (1,1,1,1) |

Partitionstypen für \(\Omega_{EABC} \le 4\): `docs/arbeitsprogramm.md` Phase 4.

## Governance

**Lokal verifiziert `[B]`:** `signature_from_nat`, `eabc_mass`, Tests in `tests/test_signatures.py`.

**Nicht behauptet:** Keine Lean-Bridge für `signature_from_nat`; `sorted_counts()` ersetzt nicht \(H(n)\); Partitionsvergleich gilt nur für \(\Omega_{EABC} \le 4\) im Arbeitsprogramm-Kontext.

**Idealtheoretische Einordnung:** Für reine Prim-EABC-Quaternionen (\(M(p)=1\), \(p>3\), \(p \equiv 1,5,7,11 \pmod{12}\)) siehe [`docs/pure_prime_eabc_dedekind_interpretation.md`](pure_prime_eabc_dedekind_interpretation.md). Für kanonische Primzahlvierlinge \((p,p+2,p+6,p+8)\) mit Masse auf der Norm \(n=\texttt{quat\_norm}(v)\) siehe [`docs/pure_prime_quadruple_dedekind_interpretation.md`](pure_prime_quadruple_dedekind_interpretation.md).
