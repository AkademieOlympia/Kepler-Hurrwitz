# Primzahl-Turm: Gauß → Eisenstein → Hurwitz → Oktonionen → Riemannkugel

> **Governance:** Wörterbuch und klassische Sätze `[A]`/`[B]`; Übermodell-Einbettungen `[C]`.  
> Lean: `KeplerHurwitz/EABC/PrimeTower.lean`  
> Vorstufen: [`eabc_normal_form.md`](eabc_normal_form.md) · [`eabc_v4_quaternion_bridge.md`](eabc_v4_quaternion_bridge.md) · `EABC/Basic.lean` (zwei Quadrate)  
> Normalform-Stack Register: [`E-096`](../EVIDENCE_REGISTER.md) · [`EABC_MASTER_INDEX.md`](../EABC_MASTER_INDEX.md)

Dieses Dokument klärt, **wie** die EABC/\(V_4\)/Lipschitz-Schicht zu den klassischen Primarithmetiken und den Übermodellen steht — ohne sie zu identifizieren.

---

## 0. Turm-Übersicht

```text
ℂ ∪ {∞}  ≅  S²          Riemannkugel          [C] stereographische Lesart
    ↑
𝕆 / Octavian            Oktonionen-Übermodell  [C] Cayley–Dickson / Repo-Oktonion
    ↑
Hurwitz-Ordnung ℋ       Hurwitz-Primzahlen     [B]/[C] Norm = rationale Primzahl
    ↑
ℍ[ℤ] Lipschitz          Quaternionen-Brücke    [A] QuaternionBridge.lean
    ↑
ℤ[ω] Eisenstein         Primzahlen mod 3       [A]/[B] ↔ Repo mod-6-Achsen
    ↑
ℤ[i] Gauß               Primzahlen mod 4       [A] Zwei-Quadrate / E∪A
    ↑
ℕ / EABC-Kern           n = 2^α 3^β r e        [A]/[B] Normalform + V₄
```

Jede Stufe hat **eigene** Primdefinition. Die Pfeile sind Einbettungen oder Projektionen, keine Gleichheiten.

---

## 1. Gaußsche Primzahlen und zwei Quadrate (E und A)

### 1.1 Klassischer Satz (Fermat / Christmas)

Für eine ungerade rationale Primzahl \(p\):

\[
p = x^2 + y^2 \quad\text{für irgendwelche }x,y\in\mathbb N
\quad\Longleftrightarrow\quad
p \equiv 1 \pmod 4.
\]

In \(\mathbb Z[i]\) gilt entsprechend:

| rationale Primzahl | Verhalten in \(\mathbb Z[i]\) |
|---|---|
| \(p=2\) | verzweigt: \(2 = -i(1+i)^2\) (bis auf Einheiten) |
| \(p\equiv 1\pmod 4\) | zerlegt: \(p=\pi\overline\pi\), \(N(\pi)=p\) |
| \(p\equiv 3\pmod 4\) | träge (inert): bleibt prim in \(\mathbb Z[i]\) |

### 1.2 Kopplung an EABC-Kanäle (mod 12)

| Kanal | \(p\bmod 12\) | \(p\bmod 4\) | Zwei Quadrate | Gauß |
|---|---|---|---|---|
| **E** | 1 | 1 | ja | zerlegt |
| **A** | 5 | 1 | ja | zerlegt |
| **B** | 7 | 3 | nein | träge |
| **C** | 11 | 3 | nein | träge |

**Wichtig:** Das ist dieselbe \(p\equiv 1\pmod 4\)-Bedingung wie in `EABC/Basic.lean` für Mod-8-Klassen E∪A (`1,5\bmod 8`).  
Mod-8-E/A und Mod-12-E/A sind **beide** Teilmengen von \(\{p:p\equiv 1\pmod 4\}\), aber **nicht** dieselben Mengen (z. B. \(17\equiv 1\pmod 8\) ist Mod-8-E, aber \(17\equiv 5\pmod{12}\) ist Mod-12-A).

Lean: `channelEA_sum_of_two_squares` in `PrimeTower.lean`; Basis `odd_prime_sum_of_two_squares_iff_EA` in `Basic.lean`.

### 1.3 Beziehung zur Quaternionen-Brücke

Eine Gaußsche Zerlegung \(p=x^2+y^2\) liefert ein Element \(\pi=x+yi\in\mathbb Z[i]\subset\mathbb H[\mathbb Z]\) (einbetten als \(e=x,\,a=y,\,b=c=0\) oder äquivalent).  
Das ist **dünner** als `axisPure(toV4 p, p)` (eine Achse, Norm \(p^2\)): Zwei-Quadrate-Norm ist \(p\), Achsen-Einbettung hat Norm \(p^2\).

---

## 2. Eisensteinsche Primzahlen (mod 3 / Repo mod-6)

Ring \(\mathbb Z[\omega]\), \(\omega = e^{2\pi i/3}\), \(N(a+b\omega)=a^2-ab+b^2\).

| rationale Primzahl | in \(\mathbb Z[\omega]\) |
|---|---|
| \(p=3\) | verzweigt |
| \(p\equiv 1\pmod 3\) | zerlegt |
| \(p\equiv 2\pmod 3\) | träge |

Repo-mod-6-Primachsen (`eabc_six_state_prime_axes`):

| Achse | \(p\bmod 6\) | \(p\bmod 3\) | Eisenstein-Lesart |
|---|---|---|---|
| **a** | 1 | 1 | Split-Kandidat |
| **bc** | 5 | 2 | Inert-Kandidat |

Das ist **orthogonal** zur mod-12-\(V_4\)-Partition: mod 6 steuert die Eisenstein-/Energie-Achsen; mod 12 die EABC-Kanäle. Gemeinsam: beide verfeinern ungerade Primzahlen \(p>3\).

### 2.1 Doppel-Split: nur Kanal E

Unter den vier EABC-Einheitenklassen gilt:

| Kanal | Gauß-Split (\(1\bmod 4\)) | Eisenstein-Split (\(1\bmod 3\)) |
|---|---|---|
| **E** (`1 mod 12`) | ja | ja |
| **A** (`5 mod 12`) | ja | nein (`2 mod 3`) |
| **B** (`7 mod 12`) | nein (`3 mod 4`) | ja (`1 mod 6`) |
| **C** (`11 mod 12`) | nein | nein |

\[
\boxed{\text{Kanal E} \;=\; \text{Gauß-Split} \;\cap\; \text{Eisenstein-Split}
\quad\text{innerhalb }(\mathbb Z/12\mathbb Z)^\times.}
\]

Lean: `channelE_iff_double_split` in `PrimeTower.lean`.

---

## 3. Lagrange: jede natürliche Zahl als vier Quadrate

\[
\forall n\in\mathbb N:\quad
\exists a,b,c,d\in\mathbb N,\quad
n = a^2+b^2+c^2+d^2.
\]

Lean/Mathlib: `Nat.sum_four_squares` (importiert in `PrimeTower.lean`).

**Quaternionische Lesart:** \(N(\gamma)=a^2+b^2+c^2+e^2\) auf \(\mathbb H[\mathbb Z]\) zeigt, dass **jede** Norm eines Lipschitz-Elements eine Vier-Quadrate-Summe ist; umgekehrt liefert Lagrange zu jedem \(n\) ein Lipschitz-Element mit \(N(\gamma)=n\) (nicht eindeutig, nicht prim).

Euler-Identität \(N(xy)=N(x)N(y)\) ist genau die Multiplikativität der Quaternionennorm (`normSq_mul`).

---

## 4. Hurwitz-Primzahlen

### 4.1 Ordnung

- **Lipschitz:** \(\mathbb Z[i,j,k]\) — Repo-Brücke `[A]`.
- **Hurwitz:** \(\mathbb Z\!\left[\frac{1+i+j+k}{2}\right]\) — enthält zusätzlich Halbgitterpunkte; 240 Einheiten (`hurwitz_units_240` in Python `[B]`).

### 4.2 Definition (Standard)

Ein Hurwitz-Element \(\pi\) heißt **Hurwitz-Primzahl**, wenn seine Norm eine rationale Primzahl ist:

\[
N(\pi) = p \in \mathbb P.
\]

Dann ist \(\pi\) irreduzibel in der Hurwitz-Ordnung (bis auf Einheiten).

### 4.3 Beziehung zu rationalen Primzahlen / EABC

| rationale \(p\) | typisches Hurwitz-Verhalten (klassisch) | EABC-Hinweis |
|---|---|---|
| \(p=2\) | verzweigt / dyadisch | Achse, nicht in \(M(n)\) |
| \(p\equiv 1\pmod 4\) (Kanäle E,A) | zerlegt in \(\pi\overline\pi\), \(N(\pi)=p\) | Zwei-Quadrate + Quaternionenfaktorisierung |
| \(p\equiv 3\pmod 4\) (Kanäle B,C) | oft assoziiert zu einem Hurwitz-Prim mit \(N=p\) (als Summe von vier Quadraten mit einer Null) | keine Gauß-Zerlegung |

**Nicht behauptet `[C]`:** Dass `axisPure(toV4 p, p)` (Norm \(p^2\)) ein Hurwitz-Primelement ist — im Gegenteil: Norm \(p^2\) ist **zusammengesetzt**, das Element ist eher \(p\cdot u\) (rationales Prim × Einheit), kein Hurwitz-Prim der Norm \(p\).

Hurwitz-Prim der Norm \(p\) braucht eine Darstellung \(p=N(\pi)\) mit ggf. Halbkoordinaten — das ist die offene \(\Phi\)-Schicht.

### 4.4 Metakommutation

Nichtkommutative Multiplikation \(P\cdot U = U'\cdot P'\) auf Hurwitz-Prim × Einheit: Repo `[B]` (`metacommutation`, 240 Einheiten). Methodische Nachbarschaft zu CEAB/ABCE, keine Identität mit \(V_4\).

---

## 5. Oktonionisches Übermodell

Cayley–Dickson: \(\mathbb H\hookrightarrow\mathbb O\) (Verdopplung).

| Objekt | Dimension | Repo-Status |
|---|---|---|
| Lipschitz/Hurwitz | 4 | `[A]`/`[B]` QuaternionBridge + Units |
| Oktonionen / Octavian | 8 | `[C]` Collatz-Oktonion, `octonion_*`, E-098 |
| Fano-/G₂-Lesart | — | `[C]` Frontier |

**Beziehung zur EABC-Normalform:** Die vier EABC-Komponenten `(a,b,c,e)` sitzen als **4D-Slice** im 8D-Oktonion; die übrigen vier Koordinaten sind Übermodell-Freiheitsgrade, nicht durch \(V_4\) bestimmt.

Claim-Grenze: Kristallisationspfad ≠ Hurwitz-Prim-Zündung (E-098).

---

## 6. Riemannsche Einbettung: \(\mathbb C\) in die Riemannkugel

Stereographische Projektion:

\[
\mathbb C \cup \{\infty\} \;\cong\; S^2.
\]

| Stufe | Geometrie | EABC-Lesart |
|---|---|---|
| Gauß-Ebene \(\mathbb C\cong\mathbb R^2\) | \(x+yi\) | Zwei-Quadrate / Kanal E∪A |
| Riemannkugel \(S^2\) | kompaktifizierte Ebene | `[C]` globale Phase / „unendlich“ als Pol |
| Quaternionen \(S^3\) | \(N(\gamma)=1\) | Einheiten-Sphäre (Lipschitz/Hurwitz) |
| Oktonionen \(S^7\) | \(N=1\) | `[C]` Übermodell |

**Keine Behauptung:** Dass EABC-Kanäle Punkte auf \(S^2\) sind, oder dass die Riemannsche ζ-Funktion aus der Normalform folgt. Die Kugel ist eine **kompaktifizierende Lesart** der komplexen (Gauß-)Schicht — analog, nicht deduktiv.

---

## 7. Rollenverteilung im Gesamtbild

Für den EABC-Kern \(\kappa=r\cdot e\):

| Rolle | Arithmetik | Gauß/Eisenstein | Quaternion / Hurwitz | Übermodell |
|---|---|---|---|---|
| \(\Omega(r)\) | Reduktionsstufe | Anzahl Residualprimfaktoren | Komplexität der imaginären Achsen | Slice-Dichte |
| \([r]_{V_4}\) | Symmetrieklasse | welche der \(p\equiv 3\pmod 4\)-Kanäle B/C vs. gemischt | Orientierung in \(\mathrm{span}\{i,j,k\}\) | Fano-Kantenwahl `[C]` |
| \(e\) (Kanal E) | skalare Drift | oft Gauß-zerlegbare Faktoren | reeller Skalar | Zeit-/Driftkoordinate `[C]` |

---

## 8. Was gilt / was nicht

| Claim | Klasse |
|---|---|
| Fermat: ungerade Primzahl = zwei Quadrate \(\Leftrightarrow\) \(\equiv 1\pmod 4\) | `[A]` |
| Mod-12 E∪A \(\Rightarrow\) \(\equiv 1\pmod 4\) \(\Rightarrow\) zwei Quadrate | `[A]` |
| Lagrange: jedes \(n\) = vier Quadrate | `[A]` (Mathlib) |
| \(N(xy)=N(x)N(y)\) auf \(\mathbb H[\mathbb Z]\) | `[A]` |
| Eisenstein-Split \(\Leftrightarrow\) \(\equiv 1\pmod 3\); Repo-Achsen a/bc | `[A]`/`[B]` |
| Hurwitz-Prim \(\Leftrightarrow\) Norm rationale Primzahl | klassische Def. `[B]` Wörterbuch |
| `axisPure` = Hurwitz-Prim | **Nein** (Norm \(p^2\)) |
| \(\Phi\): Primvierling → Hurwitz-Ideal | `[C]` offen |
| Oktonion steuert EABC-Kanäle | `[C]` |
| Riemannkugel = EABC-Phasenraum | `[C]` Analogie |

---

## 9. Artefakte

| Schicht | Pfad |
|---|---|
| Doku | `docs/eabc_prime_tower_bridge.md` (dieses File) |
| Lean | `KeplerHurwitz/EABC/PrimeTower.lean` |
| Zwei Quadrate | `KeplerHurwitz/EABC/Basic.lean` |
| Quaternionen | `KeplerHurwitz/EABC/QuaternionBridge.lean` |
| Python | `src/kepler_hurwitz/prime_tower_bridge.py` |
| Tests | `tests/test_prime_tower_bridge.py` |
| Oktonion (Frontier) | `KeplerHurwitz/Collatz/Octonion/`, `octonion_*.py` |
| Hurwitz-Einheiten `[B]` | `discrete_time_flow.hurwitz_units_240` |
