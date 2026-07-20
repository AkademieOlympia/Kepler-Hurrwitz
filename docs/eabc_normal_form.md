# EABC-Normalform natürlicher Zahlen

> **Governance:** Definitorische Referenzschicht `[B]` (Zerlegung + Benennung); Lean-Kern `[A]`.  
> **Register:** [`E-096`](../EVIDENCE_REGISTER.md) · Master-Index: [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md)  
> Lean: `KeplerHurwitz/EABC/{NormalForm,V4,SemiprimGeometry,HigherResidual,QuaternionBridge}.lean`  
> Python: `signatures.py`, `quaternion_bridge.py`  
> Masse/Signatur: [`eabc_mass_convention.md`](eabc_mass_convention.md) · Quaternionen: [`eabc_v4_quaternion_bridge.md`](eabc_v4_quaternion_bridge.md) · Primturm: [`eabc_prime_tower_bridge.md`](eabc_prime_tower_bridge.md)  
> Collatz-Audit (nicht Beweis): [`eabc_collatz_audit_grid.md`](eabc_collatz_audit_grid.md) · [`E-097`](../EVIDENCE_REGISTER.md)

Wenn im Modell von **„Normalform“**, **„Primzahl × E“** oder **„Semiprim × E“** die Rede ist, ist **ausschließlich** die folgende Zerlegung gemeint.

---

## 1. Kanonische Zerlegung

Für jedes \(n \ge 1\) gibt es eindeutige \(\alpha,\beta\in\mathbb N_0\) und einen **Kern** \(\kappa=\kappa(n)\) mit

\[
n \;=\; 2^{\alpha}\,3^{\beta}\,\kappa,\qquad \gcd(\kappa,6)=1.
\]

Die Achsen \(\{2,3\}\) zählen **nicht** zur EABC-Masse \(M(n)\) (vgl. Mass-Konvention).

Der Kern zerlegt sich weiter eindeutig in

\[
\kappa \;=\; r\cdot e
\]

mit

| Faktor | Name | Primteiler-Restriktion |
|---|---|---|
| \(e\) | **E-Faktor** | jeder Primteiler \(p\mid e\) erfüllt \(p\equiv 1\pmod{12}\) (Kanal **E**), oder \(e=1\) |
| \(r\) | **Residual** | jeder Primteiler \(p\mid r\) erfüllt \(p\in\{5,7,11\}\pmod{12}\) (Kanäle **A/B/C**), oder \(r=1\) |

Damit ist die volle Normalform

\[
\boxed{n = 2^{\alpha}\,3^{\beta}\,r\,e}.
\]

**Eindeutigkeit:** \(e\) ist der größte E-glatte Teiler von \(\kappa\); \(r=\kappa/e\).

**Nicht verwechseln:** \(e\) hier ≠ Kepler-Exzentrizität \(e_{\mathrm{kep}}\) (siehe §7).

---

## 2. Residual-Formen (gesprochenes Vokabular)

Sei \(\Omega(r)\) die Primfaktorzahl von \(r\) **mit** Multiplizität.

| ResidualShape | Bedingung an \(r\) | Gesprochene Form | Beispiel \(\kappa\) |
|---|---|---|---|
| `reineE` | \(r=1\) | **reine E-Form** | \(13\), \(13^2\), \(1\) |
| `primTimesE` | \(\Omega(r)=1\) (also \(r\) prim) | **Primzahl × E** | \(5\), \(5\cdot13\), \(7\cdot13^2\) |
| `semiprimTimesE` | \(\Omega(r)=2\) | **Semiprim × E** | \(5\cdot7\), \(5^2\), \(5\cdot7\cdot13\) |
| `higher` | \(\Omega(r)\ge 3\) (oder \(r=0\)) | **nicht reduziert** | \(5\cdot7\cdot11\) |

### Feindifferenzierung innerhalb Semiprim × E

Beide zählen als `semiprimTimesE` (\(\Omega(r)=2\)):

| Untertyp (`SemiprimKind`) | \(r\) | \(V_4\)-Produkt | Triad-\(\cos\) | Beispiel |
|---|---|---|---|---|
| `square` | \(p^2\) | \(X\cdot X=E\) | \(+1\) | \(25=5^2\) |
| `sameChannel` | \(p\cdot q\), gleiche Klasse | \(X\cdot X=E\) | \(+1\) | \(85=5\cdot17\) |
| `distinctChannel` | \(p\cdot q\), verschiedene Klassen | dritter Kanal | \(-\tfrac12\) | \(35=5\cdot7\) (A×B→C) |

**Darstellungs-Scope:** Jede natürliche Zahl hat die eindeutige Form

\[
n = \underbrace{2^{\alpha}3^{\beta}}_{\text{Hamming-\{2,3\}-glatt}}\;\cdot\; r\;\cdot\; e.
\]

„Prim oder Semiprim aus A/B/C“ gilt nur im **reduzierten** Fall \(\Omega(r)\le 2\). Der Restfall `higher` (\(\Omega(r)\ge 3\)) bleibt erlaubt — nicht jede Zahl ist reduziert.

**Vektoralgebra / Triade `[B]`:** Die Residualkanäle \(\{A,B,C\}\) werden als 120°-Triade gelesen:

\[
\cos(X,X)=1,\qquad \cos(X,Y)=-\tfrac12\quad(X\neq Y\text{ in }\{A,B,C\}).
\]

Das ergänzt die \(V_4\)-Multiplikation (Produkt = dritter Kanal). **Nicht** identisch mit dem Hamilton-Skalarprodukt von \(i,j,k\) (dort \(\cos=0\); Lean `axisPure_A_mul_B` liefert rein den dritten Achsenvektor). Spatprodukt jenseits dieses Dictionaries: `[C]` offen.

Lean: `KeplerHurwitz/EABC/SemiprimGeometry.lean` · Python: `classify_semiprim_residual`, `channel_cos`, `DualCarrier`.

### Lesart von `higher` (\(\Omega(r)\ge 3\)) — XOR, nicht Semiprim

`higher` wird **nicht** auf `SemiprimKind` zurückgeführt. Stattdessen:

\[
[r]_{V_4}
\;=\;
\bigotimes_{p^{\nu}\,\|\,r}
[p]_{V_4}^{\otimes\nu}
\;=\;
\texttt{v4XorFold}(\text{Kanalliste von }r)
\quad\text{in }\mathbb F_2^2\cong V_4.
\]

| Beispiel | Faktoren | Kanalliste | XOR | \(\gamma\) (bei \(e=1\)) |
|---|---|---|---|---|
| \(385=5\cdot7\cdot11\) | A,B,C | `[A,B,C]` | **E** | \(1\) (Kollaps der Klasse, aber \(\Omega=3\)) |
| \(175=5^2\cdot7\) | A,A,B | `[A,A,B]` | **B** | \(1+175j\) |
| \(125=5^3\) | A,A,A | `[A,A,A]` | **A** | \(1+125i\) |

`DualCarrier.higher` trägt \((\Omega,\;\text{Kanäle},\;\mathrm{xorClass})\); `semiprim_kind` bleibt `None`.

Lean: `KeplerHurwitz/EABC/HigherResidual.lean` · Python: `classify_higher_residual`, `v4_xor_fold`.

---

## 3. \(V_4\)-Signatur des Kerns

Der bereinigte Kern \(\tilde n=\kappa=r\cdot e\) lebt in den Einheiten

\[
(\mathbb Z/12\mathbb Z)^\times=\{1,5,7,11\}\;\cong\;C_2\times C_2\;\cong\;V_4.
\]

| Klasse \(x\bmod 12\) | \(V_4\) | Kanal | \(\mathbb F_2^2\) |
|---|---|---|---|
| 1 | **E** | E | \((0,0)\) |
| 5 | **A** | A | \((1,0)\) |
| 7 | **B** | B | \((0,1)\) |
| 11 | **C** | C | \((1,1)\) |

**Kanalprodukt** (Lean `V4.mul`): \(A\cdot A=B\cdot B=C\cdot C=E\), und \(A\cdot B=C\) (zyklisch).

**Hauptsätze (Lean, 0 `sorry`):**

1. \(e\) E-glatt \(\Rightarrow\) \(e\equiv 1\pmod{12}\) \(\Rightarrow\) `toV4 e = E` (`e_factor_v4_neutral`).
2. `toV4(r·e) = toV4 r` (`residual_carries_v4`) — der E-Faktor ist \(V_4\)-Drift, das Residual trägt die Klasse.

| Shape | typische \(V_4\)-Lesart von \(r\) |
|---|---|
| `reineE` | \([r]=E\) |
| `primTimesE` | \([r]\in\{A,B,C\}\) = Klasse der einen Residualprimzahl |
| `semiprimTimesE` | \(p\cdot q\) gleiche Klasse \(\Rightarrow E\); verschiedene \(\Rightarrow\) Komplement |
| `higher` | XOR-Summe der Residualprimklassen in \(\mathbb F_2^2\) |

**Abgrenzung:** Collatz-mod-8-Klein und geometrisches `V4Raum` sind **andere** \(V_4\)-Sprachen.

**Quaternionen-Brücke:** Lipschitz-\(\mathbb H[\mathbb Z]\), kanonisches \(\gamma(n)\) aus Residual/\(V_4\) — [`eabc_v4_quaternion_bridge.md`](eabc_v4_quaternion_bridge.md) · Lean `gammaFromResidual` · Tabelle \(n\le 100\): [`exports/eabc_normal_form_gamma_1_100.csv`](exports/eabc_normal_form_gamma_1_100.csv).

**Primzahl-Turm:** Gauß (zwei Quadrate für E∪A), Eisenstein (mod 3 / mod-6-Achsen), Lagrange (vier Quadrate), Hurwitz-Prim (Norm = rationale Primzahl), Oktonion/`S^2` — [`eabc_prime_tower_bridge.md`](eabc_prime_tower_bridge.md).

---

## 4. Restriktionen des Modells (was gilt / was nicht)

1. **Kanal-E = mod 12**, nicht mod 8.  
   `KeplerHurwitz.EABC.Basic.isE` (\(n\equiv 1\pmod 8\)) ist eine **andere** Schicht und wird hier **nicht** mit dem E-Faktor identifiziert.
2. Achsen \(\{2,3\}\) gehören zur Präfix-Form, nicht zu \(r\) oder \(e\).
3. \(M(n)=\Omega_{\mathrm{EABC}}(n)\) zählt Primfaktoren in \(r\) **und** \(e\) (mit Multiplizität); Achsen nicht.
4. „Primzahl × E“ verlangt Residual **genau einer** Primzahl zur Potenz \(1\), nicht \(p^k\) für \(k\ge 2\) (das wäre \(\Omega(r)=k\ge 2\) → Semiprim oder higher).
5. Keine Behauptung: dass jede Zahl „interessant“ reduziert sei; `higher` ist ein erlaubter, benannter Restfall.
6. Keine Identifikation mit Dumas-Orbit-Normalform, GeometryScaffold oder Prime-Grid-Signatur — das sind parallele Normalform-Sprachen.

---

## 5. Bezug zur Signatur \(H(n)\)

Schreibe \(H(n)=(E,A,B,C)\). Dann gilt für den Kern:

- \(E = \Omega(e)\) (Kanal-E-Zähler),
- \(A+B+C = \Omega(r)\),
- \(M(n)=E+A+B+C=\Omega(e)+\Omega(r)\).

Die ResidualShape hängt **nur** von \(\Omega(r)\) ab, nicht von der Kanalaufteilung innerhalb A/B/C.

| Shape | Bedingung an \(H\) (nach Achsenabspaltung) |
|---|---|
| reine E | \(A=B=C=0\) |
| Prim × E | \(A+B+C=1\) |
| Semiprim × E | \(A+B+C=2\) |
| higher | \(A+B+C\ge 3\) |

---

## 6. Referenzbeispiele

| \(n\) | \(\alpha,\beta\) | \(r\) | \(e\) | Shape | \(H(n)\) | \(M\) |
|------:|:---:|---:|---:|---|---|---:|
| 1 | 0,0 | 1 | 1 | reineE | (0,0,0,0) | 0 |
| 13 | 0,0 | 1 | 13 | reineE | (1,0,0,0) | 1 |
| 5 | 0,0 | 5 | 1 | primTimesE | (0,1,0,0) | 1 |
| 65 | 0,0 | 5 | 13 | primTimesE | (1,1,0,0) | 2 |
| 35 | 0,0 | 35 | 1 | semiprimTimesE | (0,1,1,0) | 2 |
| 455 | 0,0 | 35 | 13 | semiprimTimesE | (1,1,1,0) | 3 |
| 210 | 1,1 | 35 | 1 | semiprimTimesE | (0,1,1,0) | 2 |
| 385 | 0,0 | 385 | 1 | higher | (0,1,1,1) | 3 |

\(210=2\cdot3\cdot5\cdot7\): Achsen abgespalten, Residual \(5\cdot7\), E-Faktor \(1\).

---

## 7. Kepler-Projektion und Schichten

Dieses Kapitel schärft die Schnittstelle **Normalform → Signatur → Kepler** und trennt die Größen \(e\) (E-Faktor) und \(e_{\mathrm{kep}}\) (Kepler-Exzentrizität).

### 7.1 Nomenklatur: \(e\) vs. \(e_{\mathrm{kep}}\)

| Symbol | Bedeutung | Schicht |
|---|---|---|
| \(e\) | **E-Faktor** der Normalform \(n=2^\alpha 3^\beta r\,e\) (Primteiler \(\equiv 1\bmod 12\)) | Stufe 1 `[A]` |
| \(E\) in \(H(n)=(E,A,B,C)\) | Kanal-E-**Zähler** \(\Omega(e)\) | Stufe 2 `[B]` |
| \(e_{\mathrm{kep}}\) (auch \(\varepsilon\)) | **Kepler-Exzentrizität** aus `projectToKepler` | Stufe 3 `[B]/[C]` |

**Strikt:** Das Symbol \(e\) allein bezeichnet im Normalform-Stack **nur** den Mod-12-E-Faktor. Kepler-Exzentrizität wird immer \(e_{\mathrm{kep}}\) (oder \(\varepsilon\)) geschrieben. In Lean heißt das Feld von `EABCKeplerProjection` historisch `e`; semantisch ist es \(e_{\mathrm{kep}}\).

### 7.2 Formale Pipeline (kanonische Kette)

\[
n
\;\xrightarrow{\;[A]\;}\;
2^\alpha 3^\beta r\,e
\;\xrightarrow{\;[B]\;}\;
H(n)=(E,A,B,C)
\;\xrightarrow{\;[B]/[C]\;}\;
(a,\,e_{\mathrm{kep}},\,R_v)
\;\xrightarrow{\;\text{opt.}\;}
\gamma(n)\in\mathbb H[\mathbb Z].
\]

| Stufe | Abbildung | Objekt | Governance |
|:---:|---|---|---|
| **1** | Normalform | \(n = 2^\alpha 3^\beta r\,e\) | `[A]` Lean `NormalForm` |
| **2** | Signatur | \(H(n)=(E,A,B,C)\), \(M=\mathrm{totalWeight}\) | `[B]` Referenz (`signatures.py`); Lean-Struktur `[A]` |
| **3** | `projectToKepler` | \((a,\,e_{\mathrm{kep}},\,R_v)\) | `[B]` numerisch / `[C]` geometrische Lesart |
| **4** (opt.) | Einbettung | \(\gamma(n)\in\mathbb H[\mathbb Z]\) via \(V_4\)/Residual | Hamilton/Norm `[A]`; Ideal-\(\Phi\) `[C]` offen |

Stufen 1–3 sind die **kanonische** Kepler↔EABC-Kette. Stufe 4 ist die Quaternionen-Brücke ([`eabc_v4_quaternion_bridge.md`](eabc_v4_quaternion_bridge.md)) und **nicht** Teil der Kepler-Form-Projektion.

### 7.3 Kanonische Lean-Definition von \(e_{\mathrm{kep}}\) (spread-basiert)

**Aktuell und kanonisch** in `KeplerHurwitz/EABCLayer.lean` (`EABCSignature4.eccentricity` / `projectToKepler`):

\[
\begin{aligned}
\mathrm{spread}(H) &= \max(E,A,B,C) - \min(E,A,B,C), \\
a &= \frac{M}{4},\qquad M=\mathrm{totalWeight}(H), \\
e_{\mathrm{kep}} &= \frac{\mathrm{spread}(H)}{M+1}, \\
R_v &= \frac{1+e_{\mathrm{kep}}}{1-e_{\mathrm{kep}}}.
\end{aligned}
\]

Damit gilt stets \(0\le e_{\mathrm{kep}}<1\). Python-Spiegel: `project_to_kepler` in `dumas_cone_orbit.py`.

**Keine Formeländerung ohne Governance-Beschluss.** Die Lean-spread-Definition bleibt die Referenz für \(e_{\mathrm{kep}}\).

#### Optionale Anisotropie-Diagnostik (nicht Lean-Replacement)

Eine **Varianz-/RMS-Metrik** über die Kanalzählungen (z. B. \(\sigma^2=\tfrac14\sum_X(X-M/4)^2\) oder RMS derselben Abweichungen) ist eine **mögliche alternative Anisotropie-Diagnostik** `[B]/[C]`. Sie ist **klar getrennt** von `eccentricity` / `projectToKepler` und ersetzt die Lean-Definition **nicht**.

### 7.4 Entkopplung: Kepler-Form vs. Quaternionen-Frame

> Die Kepler-Ellipse bestimmt die Geometrie der Trajektorie (**Form**), während \(\gamma(n)\) über \(V_4\) und \(24I_3\) die Raumorientierung des Orbits (**Lage** im Quaternionenraum) festlegt.

| Aspekt | Träger | Governance |
|---|---|---|
| **Form** (Ellipse: \(a\), \(e_{\mathrm{kep}}\), \(R_v\)) | `projectToKepler` aus \(H(n)\) | `[B]` operational / `[C]` Interpretation |
| **Frame / Lage** (Orientierung) | \(\gamma(n)\), \(V_4\), isotropes Ziel \(24I_3\) | Algebra/Norm `[A]`; Ideal-/Retraktionslesart `[C]` |

\(24I_3\) ist **kein** Ersatz für \(e_{\mathrm{kep}}\) und steuert nicht die Ellipsenform; umgekehrt legt \(e_{\mathrm{kep}}\) keine Quaternionen-Lage fest.

### 7.5 Zusammenfassung Schichten-Governance

| Schicht | Inhalt | Status |
|---|---|---|
| Normalform \(n=2^\alpha 3^\beta r\,e\) | Zerlegung, E-Faktor \(e\) | `[A]` |
| Signatur \(H(n)\), Masse \(M(n)\) | Kanalzählung | `[B]` (Lean-Struktur `[A]`) |
| Kepler-Projektion \((a,e_{\mathrm{kep}},R_v)\) | spread-basiert, Lean-kanonisch | `[B]`/`[C]` |
| Varianz/RMS-Anisotropie | optionale Diagnostik | `[B]`/`[C]`, nicht kanonisch |
| \(\gamma(n)\), \(V_4\), \(24I_3\) | Frame/Lage, nicht Form | `[A]` Algebra · `[C]` Ideal |

---

## 8. Artefakte

| Schicht | Pfad |
|---|---|
| Lean Normalform | `KeplerHurwitz/EABC/NormalForm.lean` |
| Lean Semiprim/Triade | `KeplerHurwitz/EABC/SemiprimGeometry.lean` |
| Lean Higher/XOR | `KeplerHurwitz/EABC/HigherResidual.lean` |
| Lean \(V_4\) | `KeplerHurwitz/EABC/V4.lean` |
| Lean Kepler-Projektion | `KeplerHurwitz/EABCLayer.lean` (`projectToKepler`, Feld `e` = \(e_{\mathrm{kep}}\)) |
| Python | `signatures.py` (`axis_split`, `eabc_normal_form`, `to_v4`, `HigherReading`) |
| Python Kepler | `dumas_cone_orbit.py` (`project_to_kepler`), `kepler.py` |
| Tests | `tests/test_eabc_normal_form.py`, `tests/test_semiprim_geometry.py`, `tests/test_higher_residual.py` |
| Masse | `docs/eabc_mass_convention.md` |
| Mod-8-Schicht (getrennt) | `KeplerHurwitz/EABC/Basic.lean` |
| Register | [`E-096`](../EVIDENCE_REGISTER.md) |
| Master-Index | [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md) |
