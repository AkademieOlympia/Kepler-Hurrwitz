# EABC-Kandidaten-Vierlinge — Index \(\Phi(Q)\)

**Status:** kombinatorisches Koordinatensystem `[B]`-Tooling (kein Audit-Claim)  
**Governance:** **G-007** — Raster auf dem Sieb, keine Primzahleigenschaft, kein `[A]`-Claim  
**Modul:** [`../../src/kepler_hurwitz/eabc_candidate_quad_index.py`](../../src/kepler_hurwitz/eabc_candidate_quad_index.py)  
**Tests:** `tests/test_eabc_candidate_quad_index.py`

## Intervall

Zwischen nicht-überlappenden Primvierling-Kerzen \(V_k=(p_k,\ldots,p_k+8)\):

\[
I_k=(p_k+8,\,p_{k+1}).
\]

Anker: \(p=5\) und \(p\equiv 11\pmod{30}\), überlappende Kerzen (z. B. \(p=11\)) ausgelassen.

## Kandidat \(Q\)

Strikt steigendes 4-Tupel in \(I_k\), ein gemeinsamer 30er-Block, Farben \(\{E,A,B,C\}\) je einmal.

## Index (block-aligned)

\[
K=2^4=16,\qquad
m(Q)=\Big\lfloor\tfrac{x_1}{30}\Big\rfloor-\Big\lfloor\tfrac{p_k+8}{30}\Big\rfloor,\qquad
I_{\mathrm{local}}=K\cdot m+r(Q).
\]

\(r(Q)\in\{1,\ldots,16\}\): lexikographischer Rang des Restmusters in

\[
\mathcal R_{30}=\{1,7,11,13,17,19,23,29\}
\]

(pro Farbe in \(\{E,A,B,C\}\) genau zwei Reste ⇒ \(K=16\)).

**Hinweis:** \(\lfloor(x_1-(p_k+8))/30\rfloor\) ist **nicht** block-aligned und verletzt die Monotonie in \(x_1\); deshalb die obige Form.

## Duale Indizierung

```
            [ Grid-Koordinate Φ(Q) ]
                       │
     ┌─────────────────┴─────────────────┐
     ▼                                   ▼
 Φ_lattice (Kapazität)              global_phi (dicht)
 geometrische Gitterplätze          realisierte Q als 1…N
 Lücken = unbesetzte Muster         Basis für D(Φ)-Trajektorien
```

| Index | Bedeutung |
|---|---|
| \(\Phi_{\mathrm{lattice}}\) | kumulative Block-Kapazität + \(I_{\mathrm{local}}\) — ortstreu im Modulo-30-Raum |
| \(\Phi_{\mathrm{dense}}\) (`global_phi`) | lückenlose Abzählung der realisierten \(Q\) — AP-1-Trajektorien \(D(\Phi)\) |

## Governance (G-007)

\(\Phi(Q)\) / \(\Phi_{\mathrm{lattice}}\) sind ein **rein kombinatorisch-arithmetisches Koordinatensystem** auf dem Sieb. Sie messen keine Primzahleigenschaft und erzeugen keine `[A]`-Claims; sie adressieren Algorithmen-Scores \(\vec D\) und Trajektorien in den Intervallen \(I_k\) ortstreu.

### Kombinatorik vs. Dynamik (drei Ebenen)

| Ebene | Inhalt | Status |
|---|---|---|
| **1. Kombinatorische Farbsymmetrie** | \(K=16=2^4\) gleichberechtigte Muster pro 30er-Block (\(\mathcal R_{30}\to\{E,A,B,C\}\)) | Gitter-Faktum |
| **2. Neutrales `[B]`-Messgitter** | \(\Phi_{\mathrm{lattice}}\) / \(\phi_{\mathrm{global}}\) ohne synthetischen Koordinaten-Bias | Methodik |
| **3. Metrische / dynamische Isotropie** | ob Primverteilung oder Greedy die Symmetrie homogen nutzen | **nur** per AP-1-Audit |

> **Merksatz [G]:** Kombinatorische Farbsymmetrie garantiert ein neutrales Messwerkzeug — sie ist **kein** Beweis für stochastische oder arithmetische Gleichverteilung der Messwerte.

### Vergleichsdefekt \(\Delta D\) (Diagnose)

\[
\Delta D \;=\; D_{\mathrm{lattice}}\bigl(\Phi_{\mathrm{lattice}}\bigr)
\;-\;
D_{\mathrm{global}}\bigl(\phi_{\mathrm{global}}\bigr).
\]

| Befund | Lesart |
|---|---|
| \(\Delta D\approx 0\) | Invarianz gegenüber Lücken — Effekt unabhängig von der Sieb-Dichte-Kompression |
| \(\lvert\Delta D\rvert\gg 0\) | Sieb-Geometrie-Effekt — Verdichtung verzerrt das Signal |

\(\Delta D\) ist ein **Diagnose-Instrument** für künftige AP-1-Läufe, kein vorregistrierter Claim.

## Freeze-Zustand — vier Säulen

1. **Gitter-Ausrichtung \(m\):** \(m=\lfloor x_1/30\rfloor-\lfloor(p_k+8)/30\rfloor\) — ortstreu, monoton.
2. **Duale Koordinaten:** \(\Phi_{\mathrm{lattice}}\) (Raum/Lücken) vs. \(\phi_{\mathrm{global}}\) (Folge \(1\ldots N\)).
3. **Diagnose \(\Delta D\):** Siebgeometrie vs. Komprimierungs-Artefakt.
4. **Schranke G-007:** \(K=2_E\times 2_A\times 2_B\times 2_C=16\) = neutrales `[B]`-Messgitter, kein `[A]`-Isotropie-Claim.

### Drei leitende Merksätze (Claim-Register)

\[
\boxed{\Phi(Q)\text{ nummeriert EABC-Kandidaten so, dass Lage im Modulo-30-Sieb und lückenlose Beobachtungsreihenfolge analysierbar sind.}}
\]
\[
\boxed{K=16\text{ beschreibt die symmetrische Kapazität des Messgitters, nicht die Symmetrie der gemessenen Arithmetik.}}
\]
\[
\boxed{\Delta D\text{ zeigt, ob ein Signal von der realen Siebgeometrie oder von der lückenlosen Komprimierung abhängt.}}
\]

\[
\boxed{[A]/[B]/[C]/[G]\;+\;\mathrm{AP\text{-}1}\;+\;\Phi_{\mathrm{lattice}}\;+\;\phi_{\mathrm{global}}
\quad\text{geschlossen, governance-konform, auditbereit.}}
\]

## Feinstruktur \(\Pi(Q)\) — Permutationsklassen

\[
\Pi(Q)=\bigl(\kappa(x_1),\kappa(x_2),\kappa(x_3),\kappa(x_4)\bigr)\in S_4
\quad\text{(als Farbwort, z. B. }\mathtt{CEAB}\text{)}.
\]

**Klassifikationstripel:**

\[
\bigl(\Phi_{\mathrm{lattice}}(Q),\; r(Q)\in\{1,\ldots,16\},\; \Pi(Q)\bigr).
\]

### \(K=16\) vs. \(4!=24\)

| Größe | Bedeutung |
|---|---|
| \(K=16\) | Restmuster (2 Reste je Farbe in \(\mathcal R_{30}\)) |
| \(24\) | alle Farbpermutationen \(S_4\) |
| **14 realisierbar** | in *einem* 30er-Block (über beide Blockparitäten) |
| **10 blockiert** | benötigen Blockgrenzen-Überschreitung / andere Geometrie |

Wichtig: \(30\equiv 6\pmod{12}\) ⇒ dieselbe Restwahl liefert auf **geraden/ungeraden** Blöcken oft **verschiedene** \(\Pi\) (z. B. Muster \((11,13,17,19)\): even \(\mathtt{CEAB}\), odd \(\mathtt{ABCE}\)). Daher \(\Pi(Q)=\texttt{permutation_of}(Q)\) aus absoluten \(x_i\), nicht aus \(r\) allein.

API: `permutation_of`, `color_tau` / `tau_permutation`, `shift_Q_by_30`, `audit_pi_shift30_color_tau`, `REALIZABLE_PERMUTATIONS`, `BLOCKED_PERMUTATIONS`, `pattern_permutation_table`, `classification_triple`.

### 30-Block-Farbsymmetrie \(\tau\)

\[
x\mapsto x+30\;\Rightarrow\;x\equiv x+6\pmod{12},\qquad
\tau=(E\;B)(A\;C).
\]

| Schicht | Aussage | Status |
|---|---|---|
| **[A]** | \(\Pi(Q+30)=\tau(\Pi(Q))\) koordinatenweise | Lean: `KeplerHurwitz/EABC/Permutation30Block.lean` (`permutationOf_shift30`) |
| **[B]** | \(\lvert R_{16}\rvert=14\), \(\lvert B_{16}\rvert=10\); \(\tau(R)=R\), \(\tau(B)=B\) auf dem endlichen K=16-Gitter | Python-Audit — **nicht** universell in \(K\) |
| **[C-H10]** | Stabilisierung \(K\to\infty\), \(D_\Pi\), asymptotische Kanalunterschiede | offen (B-018) |

Energiedoku-Versiegelung: [`../energiedoku_exports/eabc_pi_30block_color_involution.md`](../energiedoku_exports/eabc_pi_30block_color_involution.md).

> **Merksatz:** \(\Pi(Q)\) ist Ordnungsobservable im Klassifikationstripel \((\Phi_{\mathrm{lattice}},r,\Pi)\) — kein 5. algebraisches EABC-Objekt. Das `[A]`-Gesetz ist die Blockshift-Farbsymmetrie; Dichtefragen bleiben **C-H10**.

## Nutzung

Phasen-Audits **zwischen** den Kerzen-Vierlingen (Anbindung an B-016-Lücken / \(D(\Phi)\) / \(\Delta D\) / \(\Pi\)-Feinstruktur), ohne zahlentheoretische Invarianten zu behaupten.
