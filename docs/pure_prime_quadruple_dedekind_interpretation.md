# Wie sieht das im Lichte der dedekindschen Idealtheorie aus? — Primzahlvierlinge

**Evidenz:** `[B]`/`[C]` — arithmetische Lesart definitorisch/getestet; idealtheoretische Brücke offen  
**Register:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-046/E-048 (Primvierling/Dumas), E-072 (mod-12-Kanalpartition), E-073 (HoTT Identity Layer)  
**Lean:** `KeplerHurwitz/DedekindIdealLayer.lean`, `KeplerHurwitz/PrimvierlingSymmetry.lean` (`PrimeQuadruplet`)  
**Daten:** [`docs/energiedoku_exports/pure_prime_quadruples.csv`](energiedoku_exports/pure_prime_quadruples.csv)  
**Konvention:** [`docs/eabc_mass_convention.md`](eabc_mass_convention.md)  
**Testkonzept:** [`docs/prime_quadruple_test_concept.md`](prime_quadruple_test_concept.md)  
**Schwester-Doku (1D / achsenausgerichtet):** [`docs/pure_prime_eabc_dedekind_interpretation.md`](pure_prime_eabc_dedekind_interpretation.md)

---

**Reine Primzahlvierlinge** sind im Repo kanonische Primquadruplet

\[
v = (p,\, p+2,\, p+6,\, p+8), \qquad p > 3,
\]

deren **alle vier Komponenten** prim sind (`PrimeQuadruplet` in Lean, `is_prime_quadruplet` in Python). Als Quaternionen-Vierling \(q=(a,b,c,e)\) liegen alle vier Achsen auf echten Primzahlen — im Gegensatz zur achsenausgerichteten CSV-Einbettung \((p,0,0,0)\) aus der p-only-Schicht.

Die **quaternionische Norm** ist

\[
n(v) := \|q\|^2 = a^2 + b^2 + c^2 + e^2 = \texttt{quat\_norm}(v).
\]

Darauf läuft die kanonische EABC-Signatur

\[
H(n(v)) = (E,A,B,C), \qquad M(n(v)) = \texttt{eabc\_mass}(n(v)),
\]

via `signature_from_nat` / `eabc_mass` (siehe [`docs/eabc_mass_convention.md`](eabc_mass_convention.md)).

Zusätzlich trägt jede Komponente \(x \in \{a,b,c,e\}\) als Primzahl genau **einen** EABC-Kanal (mod 12). Das **Produkt**

\[
P(v) := a \cdot b \cdot c \cdot e
\]

hat für echte Primvierlinge \(p>3\) **strukturell** die volle Vier-Kanal-Signatur \(H(P(v))=(1,1,1,1)\), \(M(P(v))=4\) (mod-12-Vollabdeckung \(\{1,5,7,11\}\); siehe [`docs/prime_quadruple_test_concept.md`](prime_quadruple_test_concept.md)) — ein Kontrast zur p-only-Schicht mit \(M(p)=1\).

Idealtheoretisch sind reine Primzahlvierlinge Kandidaten für **volle** Quaternionen-Generatoren mit Dumas-Host-Struktur — aber noch keine bewiesene Einbettung in eine konkrete Dedekind- oder Hurwitz-Ordung.

---

## Abgrenzung: achsenausgerichtetes \(p\) vs. echter Vierling

| Schicht | Objekt | Koordinaten | EABC-Masse (typisch) |
|---|---|---|---|
| **Reine Prim-EABC-Quaternion** (Schwester-Doku) | einzelnes \(p>3\) | \((p,0,0,0)\) o. ä. | \(M(p)=1\) |
| **Reiner Primzahlvierling** (hier) | \(v=(p,p+2,p+6,p+8)\) | alle vier Achsen \(\neq 0\) | \(M(n(v))=2\) (Norm), \(M(P(v))=4\) (Produkt) |
| **Kanalvierling** (Partition) | vier Primzahlen aus EABC-Buckets | nicht \((p,p+2,p+6,p+8)\) | kombinatorisch, kein Primquadruplet |

Die p-only-CSV [`pure_prime_eabc_quaternions.csv`](energiedoku_exports/pure_prime_eabc_quaternions.csv) listet **Atome der 1D-EABC-Stromschicht** (\(M=1\)).  
Die Vierling-CSV [`pure_prime_quadruples.csv`](energiedoku_exports/pure_prime_quadruples.csv) listet **kanonische Primquadruplet-Witnessen** mit voller Achsenbelegung und Dumas-Struktur (E-046/E-048).

---

## 1. Arithmetische Ebene: Norm und Kanalabdeckung

### 1.1 Normsignatur \(H(n(v))\), \(M(n(v))\)

Für \(v=(5,7,11,13)\):

\[
n(v) = 25 + 49 + 121 + 169 = 364 = 2^2 \cdot 7 \cdot 13,
\]
\[
H(364) = (1,0,1,0), \quad M(364) = 2.
\]

Die Achsen \(2,3\) werden in der EABC-Zählung abgespalten; der Faktor \(2^2\) aus der Norm trägt nicht zu \(M\) bei. \(M(n(v))=2\) für \((5,7,11,13)\) ist **Referenzfall**, kein Invariantensatz über alle Primvierlinge — faktorisatorisch variabel, nicht als globale Eigenschaft zu behaupten.

### 1.2 Komponenten und Produkt \(H(P(v))\)

Jede Komponente ist eine EABC-Klasse prim (\( \bmod 12 \in \{1,5,7,11\}\)):

| Komponente | mod 12 | Kanal |
|---|---|---|
| \(p\) | variiert | A oder C (Rotor) |
| \(p+2\) | variiert | … |
| \(p+6\) | variiert | … |
| \(p+8\) | variiert | … |

Für kanonische Quadruplet ab \(p>3\) sind die vier Primzahlen paarweise verschieden und belegen modulo 12 **genau** die Restklassen \(\{1,5,7,11\}\) — daher strukturell:

\[
H(P(v)) = (1,1,1,1), \quad M(P(v)) = 4.
\]

**Strukturelle Begründung (mod 12):** Für echte Primvierlinge gilt \(p \equiv 5\) oder \(p \equiv 11 \pmod{12}\) (sonst trifft \(p+2\) oder \(p+8\) die Restklasse 3); die Komponenten durchlaufen einen der Zyklen \((5,7,11,1)\) oder \((11,1,5,7)\). Details und `[B]`-Test → [`docs/prime_quadruple_test_concept.md`](prime_quadruple_test_concept.md), Abschnitt 4.

Beispiel \(v=(5,7,11,13)\): Kanäle A, B, C, E je einmal; \(P(v)=5005\).

### 1.3 Was „rein prim“ hier bedeutet

| Lesart | Bedingung | Status |
|---|---|---|
| **Strukturell rein** | alle vier Komponenten prim, paarweise verschieden | definitorisch (`PrimeQuadruplet`, `primvierlingDistinct`) |
| **EABC-Normatom** | \(M(n(v))=1\) | **nicht** typisch für Vierlinge; gilt p-only-Schicht |
| **EABC-Vollabdeckung** | \(M(P(v))=4\), \(H=(1,1,1,1)\) | strukturell invariant für \(p>3\) (mod 12) |
| **Hurwitz-Primelement** | \(q\) ist irreduzibel in konkreter Ordnung | offen (braucht \(\Phi\)) |

„Rein prim“ beim Vierling meint im Repo **primzahltheoretische Reinheit aller vier Achsen**, nicht die p-only-Bedingung \(M=1\).

---

## 2. Idealtheoretische Lesart: voller Generator statt Idealbeweis

Im dedekindschen Bild erzeugt ein Quaternionenelement \(\gamma=(a,b,c,e)\) Linksideale \(H\gamma\) und Rechtsideale \(\gamma H\).

Für einen reinen Primzahlvierling \(v\) lautet die vorsichtige Interpretation:

| Ebene | Objekt | Bedeutung |
|---|---|---|
| EABC-Arithmetik (Norm) | \(H(n(v))\), \(M(n(v))\) | Normgetriebene Kanalzählung, typisch \(M=2\) |
| EABC-Arithmetik (Produkt) | \(H(P(v))\), \(M(P(v))=4\) | volle mod-12-Kanalabdeckung auf Komponentenebene |
| CSV-/Exportebene | echter Primvierling \((a,b,c,e)\) | alle Achsen prim, keine Nullen |
| Dumas-Schicht | `hostTriple`, `hostComponent` | E-046/E-048: Gap kodiert Host |
| Idealtheorie | \(\gamma\) als voller Generatorlabel | Kandidat für \(H\gamma\) und \(\gamma H\) |
| Formale Brücke | \(\Phi : \mathrm{EABC} \to H_{d}\) | noch offen |

Der Governance-Punkt:

\[
M(n(v)) = 2 \;\text{(typisch)}
\]

ist EABC-Signatur auf der **Normhöhe** — nicht die Dedekind-Hasse-Kontrolle und nicht dasselbe wie \(M(p)=1\) in der p-only-Schicht.

Die Aussage

\[
v \mapsto \text{Primelement oder Primideal in einer konkreten Hurwitz-Ordung}
\]

braucht \(\Phi\) und Norm-/Idealpfadkontrolle; sie folgt nicht aus der Primquadruplet-Definition allein.

---

## 3. Links-/Rechtsideale und Chiralität

Die Dedekind-Ideal-Schicht E-067–E-069 macht Nichtkommutativität sichtbar:

```
             γ = (a,b,c,e)
            / \
           /   \
        Hγ     γH
       links   rechts
```

Ein reiner Primzahlvierling ist auf der **Komponentenebene** Dumas-symmetrisch (vier Host-Rollen, je ein Host-Dreier). Auf der **Idealpfadebene** werden \(H\gamma\) und \(\gamma H\) in der Dedekind-Ideal-Schicht als **chiral unterscheidbare Pfade modelliert** — solange \(\Phi\) offen ist, ohne zu behaupten, dass diese Pfade bereits bewiesen verschieden sind.

| Aussage | Status |
|---|---|
| Vier paarweise verschiedene Primkomponenten | definitorisch / getestet |
| Dumas-Lemma: Host-Dreier = Komplement der Host-Komponente | E-048, bewiesen |
| Links- und Rechtsidealpfade als chiral unterscheidbare Pfade modelliert (falls \(\Phi\) offen) | Dedekind-Ideal-Schicht |
| mod-12-Kanalabdeckung erklärt Idealchiralität vollständig | offen |
| Kanal \(\Rightarrow\) Idealchiralität | Hypothesenbrücke, nicht bewiesen |

Chiralität ist keine Eigenschaft von \(M(n(v))\) oder \(M(P(v))\) allein, sondern der nichtkommutativen Idealpfade nach Einbettung \(\Phi\).

---

## 4. Dedekind-Hasse-Defekte

E-053 und `DedekindHasseDumasInterface.lean` verbinden Primvierling-Struktur mit Referenz-Quaternionenordnungen — **lokal** über Dumas-Architektur (4 Hosts \(\leftrightarrow\) 4 Komponenten), nicht als globale EABC-Masse-Identität.

Für reine Primzahlvierlinge:

\[
M(n(v)) = 2 \;\text{(typisch)}
\]

ist **kein** Dedekind-Hasse-Satz.

Dedekind-Hasse fragt: Liegt der aus \(v\) gebildete Generator in einer Ordnung mit kontrollierter Links-/Rechtsidealtheorie und guter Normreduktion?

```
EABC-Masse M(n(v))  (Norm)
        ≠
Dedekind-Hasse-Kontrolle

Primquadruplet-Struktur + Dumas (E-048)
        +
Einbettung Φ in Quaternionenordnung
        +
Idealpfad-/Normkontrolle
        =
mögliche dedekindische Interpretation
```

Ohne \(\Phi\) bleibt der Zusammenhang methodisch, nicht deduktiv — wie in der p-only-Schwester-Doku.

---

## 5. Unit-Migration und HoTT-Identitätsschicht

E-073 modelliert Unit-Migration als **Pfadzeuge**, nicht als flache Quotientierung.

Für reine Primzahlvierlinge:

- Auf der rationalen Komponentenebene: je \(\pm x\) pro Primachse — trivialer als volle Quaternioneneinheiten.
- In einer Hurwitz-Ordung: Einheiten können echte Drehungen erzeugen; CEAB-Invarianz der Norm (`dedekindHasse_quatNorm_CEAB_invariant`) ist bewiesen, Unit-Pfade sind E-073 `[C]`.
- Dumas-Rotor-Labels (`host_for_quadruplet_index`) sind **Export-Konstruktion**, keine HoTT-Pfade.

---

## Governance-Tabelle

| Aussage | Einordnung |
|---|---|
| \(v=(p,p+2,p+6,p+8)\), alle vier prim, \(p>3\) | definitorisch (`PrimeQuadruplet`) |
| `primvierlingDistinct v` | bewiesen für \(p>3\) (Lean) |
| \(M(n(v))\) via `eabc_mass(quat_norm(v))` | arithmetische Signaturkonvention `[B]` |
| \(M(P(v))=4\), \(H(P(v))=(1,1,1,1)\) | strukturell invariant / getestet `[B]` |
| \(M(n(v))\) nur Referenz/Empirie | faktorisatorisch variabel, kein globales Axiom |
| Echter Vierling vs. achsenausgerichtetes \((p,0,0,0)\) | Export-/Modellkonvention |
| Ein Bild \(\Phi(v)=\gamma\) würde links/rechts Hauptideal-Kandidaten \(H\gamma\) und \(\gamma H\) erzeugen | nur nach \(\Phi\) sinnvoll |
| Dumas Host-Dreier / Gap kodiert Host | E-048, bewiesen |
| mod-12-Kanal erklärt Idealchiralität | offen |
| Dedekind-Hasse erklärt EABC-Masse auf Norm | nicht behauptet |
| Kanalvierling = Primquadruplet | **nein** (E-072 vs. Zahlentheorie) |
| Unit-Migration als Pfad | E-073, konzeptionell `[C]` |
| HoTT/Univalenz/HITs formal bewiesen | nicht behauptet |

---

## Praktische Folge fürs Repo

Die **p-only-Schicht** (Schwester-Doku) ist die atomare 1D-Testebene:

\[
M(p)=1,\qquad H(p)\in \{(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1)\}.
\]

Die **Primzahlvierling-Schicht** ist die volle 4-Achsen-Testebene mit Dumas-Symmetrie:

\[
v=(a,b,c,e)\ \text{prim},\quad M(n(v))\ \text{Referenz/Empirie},\quad M(P(v))=4\ \text{strukturell}.
\]

Die Dedekind-Ideal-Schicht bleibt die nichtkommutative Struktur- und Pfadebene:

\[
\gamma \mapsto H\gamma,\qquad \gamma \mapsto \gamma H.
\]

Die HoTT-Schicht bleibt konzeptionell:

\[
\text{Unit-Migration} \mapsto \text{Pfadzeuge}.
\]

Kurz: Ein reiner Primzahlvierling ist arithmetisch ein **voller Primzeugen-Witness** mit Dumas-Struktur — idealtheoretisch ein Kandidat für einen **vierachsigen** Hauptideal-Generator, nicht dasselbe Objekt wie ein p-only-Atom mit \(M=1\).

Die wichtigste offene Brücke bleibt:

\[
\Phi : \text{EABC-Kanalstruktur / Primvierling} \longrightarrow \text{Quaternionenordnung / Idealpfade}.
\]

Erst mit \(\Phi\) wird aus der Parallelität zwischen EABC-Signatur, Primquadruplet-Geometrie und Dedekind-Idealtheorie eine echte deduktive Verbindung.

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
