# EABC / \(V_4\) ↔ Quaternionen-Brücke

> **Governance:** `[A]` algebraische Gesetze (Lean); `[B]` Achsen-/Norm-Konvention; `[C]` Ideal-Einbettung \(\Phi\) offen.  
> **Register:** [`E-096`](../EVIDENCE_REGISTER.md) (Normalform-Stack inkl. DualCarrier/\(\gamma\)) · [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md)  
> Lean: `KeplerHurwitz/EABC/QuaternionBridge.lean`, `SemiprimGeometry.lean`, `HigherResidual.lean`  
> Voraussetzung: [`eabc_normal_form.md`](eabc_normal_form.md), [`eabc_mass_convention.md`](eabc_mass_convention.md)  
> Primzahl-Turm (Gauß/Eisenstein/Hurwitz/Oktonion/Riemannkugel): [`eabc_prime_tower_bridge.md`](eabc_prime_tower_bridge.md)  
> Methodische Parallelbrücke: [`theory/kepler_quaternion_lift_projection.md`](theory/kepler_quaternion_lift_projection.md)

---

## 1. Was die Brücke leistet

Die EABC-Normalform zerlegt \(n=2^\alpha 3^\beta r\,e\) und trennt drei Rollen auf dem Kern \(\kappa=r\cdot e\):

| Rolle | Objekt | Quaternionische Lesart |
|---|---|---|
| Reduktionsstufe | \(\Omega(r)\) | wie viele Residualprimfaktoren die imaginären Achsen speisen |
| Symmetrieklasse | \([r]_{V_4}\) | welche imaginären Achsen \(i,j,k\) (Kanäle A/B/C) aktiv sind |
| Skalare Drift | \(e\) (Kanal E) | reeller Anteil / \(V_4\)-neutrales Neutralelement |

Die Quaternionenschicht liefert dazu die **nichtkommutative Algebra**, in der Norm und Konjugation die Lift-Invarianten sind.

---

## 2. Lipschitz-Quaternionen \(\mathbb H[\mathbb Z]\)

Wir arbeiten mit der **Lipschitz-Ordnung** (ganze Quaternionen)

\[
\gamma = e + a\,i + b\,j + c\,k \in \mathbb H[\mathbb Z],
\]

in Lean: `ℍ[ℤ]` (`Mathlib.Algebra.Quaternion`).

**Komponentenkonvention (Primvierling):** Tupel `(a,b,c,e)` entspricht

\[
\langle\mathrm{re},\mathrm{imI},\mathrm{imJ},\mathrm{imK}\rangle = \langle e,\,a,\,b,\,c\rangle.
\]

Damit ist Kanal **E** die reelle Achse (passend zu \(V_4\)-Neutralelement), Kanäle **A/B/C** die imaginären Achsen \(i,j,k\).

**Hurwitz-Ordnung** \(\mathbb Z\!\left[\tfrac12(1+i+j+k)\right]\) wird hier nur erwähnt — nicht formalisiert.

---

## 3. Algebraische Gesetze (Lean `[A]`)

### 3.1 Hamilton-Relationen

\[
i^2 = j^2 = k^2 = ijk = -1,\qquad ij=k,\quad ji=-k.
\]

Lean: `I_mul_I`, `J_mul_J`, `K_mul_K`, `I_mul_J`, `J_mul_I`, `I_mul_J_mul_K`.

### 3.2 Konjugation und Norm

\[
\overline\gamma = e - a\,i - b\,j - c\,k,\qquad
N(\gamma)=\gamma\,\overline\gamma = a^2+b^2+c^2+e^2.
\]

Gesetze:

| Gesetz | Formel | Lean |
|---|---|---|
| Anti-Homomorphie | \(\overline{xy}=\overline y\,\overline x\) | `star_mul_anti` |
| Norm-Darstellung | \(\gamma\,\overline\gamma=N(\gamma)\) | `mul_star_eq_normSq` |
| Multiplikativität | \(N(xy)=N(x)N(y)\) | `normSq_mul` |
| Komponentenformel | \(N=a^2+b^2+c^2+e^2\) | `normSq_ofPrimvierlingComponents` |

Das ist dieselbe Formel wie Repo-`quatNorm` / Lean `quatNorm` in `PrimvierlingSymmetry.lean`.

### 3.3 CEAB-Symmetrie

Die Primvierling-Verschiebung \((a,b,c,e)\mapsto(c,e,a,b)\) erhält \(N\):

\[
N(\mathrm{CEAB}(\gamma))=N(\gamma).
\]

Lean: `normSq_shiftCEAB` (vgl. `quatNorm_invariant_under_shiftCEAB`).

---

## 4. Kopplung an \(V_4\) und die Normalform

### 4.1 Reine Achsen-Einbettung

Für eine zu 6 teilerfremde Primzahl \(p\) mit Klasse \(v=\mathrm{toV4}(p)\):

\[
\iota(p) = \mathrm{axisPure}(v,p)
\quad\text{(nur eine Komponente }=p\text{)}.
\]

Dann gilt \(N(\iota(p))=p^2\) (`normSq_axisPure_nat`) und die Achsenwahl ist konsistent mit der Restklasse (`axisPure_toV4_consistent`).

Das ist die Lean-Form der „reinen Prim-EABC-Quaternion“ aus [`pure_prime_eabc_dedekind_interpretation.md`](pure_prime_eabc_dedekind_interpretation.md) — **arithmetisch**, noch ohne Ideal-\(\Phi\).

### 4.2 Rollenverteilung im Quaternionenbild

Für \(\kappa=r\cdot e\):

1. **\(e\) E-glatt** \(\Rightarrow\) \(e\equiv 1\pmod{12}\) \(\Rightarrow\) \([e]_{V_4}=E\) — reelle/kanal-E-Drift ändert die \(V_4\)-Klasse nicht.
2. **\([r]_{V_4}\)** bestimmt die Orientierung der imaginären Residualbeiträge (XOR in \(\mathbb F_2^2\)).
3. **\(\Omega(r)\)** zählt, wie tief die imaginäre Residualstruktur ist (`primTimesE` / `semiprimTimesE` / …).
4. **\(N(\gamma)\)** ist die quadratische Lift-Invariante; ihre eigene EABC-Normalform \(N(\gamma)=2^{\alpha'}3^{\beta'}r'e'\) ist ein **weiteres** Objekt — keine automatische Gleichheit \(r'=r\).

### 4.3 Kanonische Einbettung \(\gamma(n)\) aus der Normalform

Für \(n=2^\alpha 3^\beta r\,e\) mit \([r]_{V_4}\):

\[
\gamma(n)=\begin{cases}
e & \text{falls }[r]_{V_4}=E,\\
e + r\,i & \text{falls }[r]_{V_4}=A,\\
e + r\,j & \text{falls }[r]_{V_4}=B,\\
e + r\,k & \text{falls }[r]_{V_4}=C.
\end{cases}
\]

Lean: `gammaFromResidual`; Python: `gamma_of_nat` / `gamma_from_normal_form`.

**E-Kollaps:** Wenn \([r]_{V_4}=E\) aber \(r>1\) (z. B. \(25=5^2\), \(49=7^2\)), verschwinden die Imaginärteile — die Residualgröße geht verloren; \(\gamma\) hängt nur noch von \(e\) ab.

Lean `[A]`:
- `gammaFromResidual_of_toV4_E` / `gammaFromResidual_eq_of_toV4_E`
- Kollaps-Zeugen `gammaFromResidual_collapse_semiprim_square` (\(25\)), `…_49`
- Dualität: `DualCarrier` / `dualCarrier` mit Feldern `gamma`, `omega`, `shape`
- Hauptsatz der Unvollständigkeit: `e_collapse_requires_dual_carrier`
  (\(\gamma(25)=\gamma(1)\), aber \(\Omega(25)=2\neq 0=\Omega(1)\) und Shape `semiprimTimesE` ≠ `reineE`)

Damit ist \(\gamma\) **kein** vollständiges Invariant von \(n\); die Rekonstruktion braucht die Symbiose \((\gamma,\,\Omega(r),\,r)\).

**Korrektur zur manuellen 100er-Liste:** \(n=74=2\cdot 37\) hat \(r=1\), \(e=37\) (nicht \(r=37\)); Lean `gamma_74_e_factor`.

Katalog-Lemmata: `gamma_65`, `gamma_35`, `gamma_13`, `gamma_74_e_factor`.

Referenztabelle \(n=1\ldots 100\): [`exports/eabc_normal_form_gamma_1_100.csv`](exports/eabc_normal_form_gamma_1_100.csv) (wird von `tests/test_eabc_gamma_table.py` geschrieben).

### 4.4 Diagramm

```text
n  ──axis split──►  κ = r·e  ──toV4──►  [r]_{V₄}
                         │
                         │  gammaFromResidual
                         ▼
              γ = e + a i + b j + c k  ∈ ℍ[ℤ]
                         │
                         ▼
                    N(γ) = a²+b²+c²+e²
                         │
                         ▼
              H(N(γ)) ∈ ℕ⁴   (EABC-Signatur, optional)
```

---

## 5. Was **nicht** behauptet wird

1. Keine Identifikation Quaternionen = Keplerellipsen (siehe Lift-Projektions-Doku).
2. Keine Einbettung \(\Phi\) Primvierling → Hurwitz-Ideal (E-067–E-069 bleiben `[C]`).
3. Keine Gleichheit \(V_4\) (mod 12) mit Collatz-mod-8-Klein oder geometrischem `V4Raum`.
4. Kein Beweis, dass \(N(\gamma)\) die Residualklasse von \(\kappa\) reproduziert.
5. Hurwitz-½-Gitter und 240 Einheiten sind hier nicht formalisiert.

---

## 6. Artefakte

| Schicht | Pfad |
|---|---|
| Lean Brücke | `KeplerHurwitz/EABC/QuaternionBridge.lean` |
| Lean Semiprim/Triade | `KeplerHurwitz/EABC/SemiprimGeometry.lean` |
| Lean Higher/XOR | `KeplerHurwitz/EABC/HigherResidual.lean` |
| Lean \(V_4\) | `KeplerHurwitz/EABC/V4.lean` |
| Lean Normalform | `KeplerHurwitz/EABC/NormalForm.lean` |
| Primvierling-Norm | `KeplerHurwitz/PrimvierlingSymmetry.lean` (`quatNorm`) |
| Python | `src/kepler_hurwitz/quaternion_bridge.py` (`DualCarrier`) |
| Tests | `tests/test_quaternion_bridge.py`, `tests/test_eabc_gamma_table.py`, `tests/test_semiprim_geometry.py` |
| Tabelle \(n\le 100\) | `docs/exports/eabc_normal_form_gamma_1_100.csv` |
