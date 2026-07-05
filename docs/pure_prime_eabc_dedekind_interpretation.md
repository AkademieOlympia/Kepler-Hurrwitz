# Wie sieht das im Lichte der dedekindschen Idealtheorie aus?

**Evidenz:** `[B]`/`[C]` — arithmetische Lesart definitorisch/getestet; idealtheoretische Brücke offen  
**Register:** E-067–E-069 (Dedekind-Ideal-Schicht), E-053 (Dedekind–Hasse), E-072 (mod-12-Kanalpartition), E-073 (HoTT Identity Layer)  
**Lean:** `KeplerHurwitz/DedekindIdealLayer.lean`  
**Daten:** [`docs/energiedoku_exports/pure_prime_eabc_quaternions.csv`](energiedoku_exports/pure_prime_eabc_quaternions.csv)  
**Konvention:** [`docs/eabc_mass_convention.md`](eabc_mass_convention.md)

---

Reine Prim-EABC-Quaternionen sind im Repo rationale Primzahlen

\[
p>3,\qquad p \equiv 1,5,7,11 \pmod{12},
\]

mit kanonischer EABC-Signatur

\[
H(p)=(E,A,B,C)
\]

und genau einem aktiven Kanal. Daher gilt

\[
M(p)=E(p)+A(p)+B(p)+C(p)=1.
\]

Arithmetisch sind sie also die Atome des EABC-Stroms: ein Primfaktor, ein Kanal, eine Masseeinheit. Idealtheoretisch sind sie zunächst Kandidaten für achsenausgerichtete Generatoren — aber noch keine bewiesene Einbettung in eine konkrete Dedekind- oder Quaternionenordnung.

---

## 1. Arithmetische Ebene: M(p)=1

Die EABC-Masse ist eine additive Primfaktor-Zählung über den vier relevanten Restklassen modulo 12:

| Restklasse | Kanal |
|---|---|
| \(1 \pmod{12}\) | E |
| \(5 \pmod{12}\) | A |
| \(7 \pmod{12}\) | B |
| \(11 \pmod{12}\) | C |

Für eine reine Primzahl \(p>3\) ist genau eine dieser vier Komponenten aktiv. Zum Beispiel:

\[
p=5 \Rightarrow H(p)=(0,1,0,0),\quad M(p)=1,
\]
\[
p=7 \Rightarrow H(p)=(0,0,1,0),\quad M(p)=1.
\]

Das ist zunächst eine arithmetische Aussage: \(M(p)=1\) bedeutet, dass \(p\) genau ein EABC-relevanter Primfaktor mit Multiplizität eins ist.

Es bedeutet noch nicht automatisch, dass \(p\) in einer Quaternionenordnung ein Primelement, ein Primideal oder ein nichttrivialer Idealklassenfall ist.

---

## 2. Idealtheoretische Lesart: Generator statt Idealbeweis

Im dedekindschen Bild denkt man nicht nur in Elementen, sondern in Idealen. Ein Element \(\gamma\) erzeugt etwa ein Linksideal

\[
H\gamma
\]

und ein Rechtsideal

\[
\gamma H.
\]

In einer kommutativen Dedekind-Domäne fällt diese Unterscheidung weg. In einer nichtkommutativen Quaternionenordnung ist sie aber zentral.

Für ein reines EABC-Prim \(p\) lautet die vorsichtige Interpretation:

| Ebene | Objekt | Bedeutung |
|---|---|---|
| EABC-Arithmetik | \(H(p)\), \(M(p)=1\) | ein Kanal, eine Masseeinheit |
| CSV-/Exportebene | achsenausgerichteter Primvierling | \(p\) liegt auf genau einer EABC-Komponente |
| Idealtheorie | \(\gamma\) als Generatorlabel | Kandidat für \(H\gamma\) und \(\gamma H\) |
| Formale Brücke | \(\Phi : \mathrm{EABC} \to H_{d}\) | noch offen |

Der entscheidende Governance-Punkt ist:

\[
M(p)=1
\]

ist im Repo sauber als EABC-Signatur/Masse interpretierbar. Aber die Aussage

\[
p \mapsto \text{Primelement oder Primideal in einer konkreten Quaternionenordnung}
\]

braucht eine zusätzliche Einbettung \(\Phi\), die nicht automatisch aus der EABC-Masse folgt.

---

## 3. Links-/Rechtsideale und Chiralität

Die Dedekind-Ideal-Schicht E-067–E-069 ist gerade deshalb interessant, weil sie die Nichtkommutativität sichtbar macht:

```
             γ
            / \
           /   \
        Hγ     γH
       links   rechts
```

Selbst wenn \(\gamma\) auf der EABC-Seite „rein“ ist, also nur einen Kanal trägt, können die zugehörigen Links- und Rechtsidealpfade unterschiedlich sein.

Das ist der zentrale Punkt:

\[
M(p)=1
\]

misst arithmetische Einfachheit.

Die Links-/Rechtsdifferenz misst dagegen nichtkommutative Chiralität.

Diese beiden Aussagen widersprechen sich nicht. Ein Objekt kann auf der EABC-Zählseite atomar sein und auf der Idealpfadseite trotzdem eine Links-/Rechtsasymmetrie tragen.

Präzise gesagt:

| Aussage | Status |
|---|---|
| Reines \(p\) hat genau einen EABC-Kanal | definitorisch / getestet |
| Links- und Rechtsidealpfade können verschieden sein | Dedekind-Ideal-Schicht |
| Diese Verschiedenheit erklärt die mod-12-Kanäle vollständig | offen |
| mod-12-Kanal \(\Rightarrow\) Idealchiralität | Hypothesenbrücke, nicht bewiesen |

Damit ist die Chiralität keine Eigenschaft von \(M(p)\) allein, sondern eine Eigenschaft der nichtkommutativen Idealpfade, sobald ein EABC-Element in eine Quaternionenordnung interpretiert wird.

---

## 4. Dedekind-Hasse-Defekte

E-053 gehört zur Dedekind-Hasse-Schicht. Dort geht es um die Frage, wann eine Ordnung hinreichend gute Divisionseigenschaften besitzt, etwa über Kriterien der Normreduktion.

Im klassischen Idealbild ist das wichtig, weil Dedekind-artige Struktur oft bedeutet:

- Ideale sind besser kontrollierbar als Elemente.
- Faktorisierung kann auf Idealebene funktionieren, auch wenn Elementfaktorisierung scheitert.
- Lokale Defekte zeigen, wo euklidische oder PID-artige Argumente nicht mehr greifen.

Für die reinen EABC-Primzahlen heißt das:

\[
M(p)=1
\]

ist kein Dedekind-Hasse-Satz. Es ist eine EABC-Zählkonvention.

Dedekind-Hasse sagt eher: Wenn ein solches \(p\) über eine Abbildung \(\Phi\) in eine Quaternionenordnung gebracht wird, dann muss man prüfen, ob der entstehende Generator in einer Ordnung liegt, deren Links-/Rechtsidealtheorie kontrolliert ist.

Also:

```
EABC-Masse M(p)=1
        ≠
Dedekind-Hasse-Kontrolle

EABC-Masse M(p)=1
        +
Einbettung Φ in Quaternionenordnung
        +
Idealpfad-/Normkontrolle
        =
mögliche dedekindische Interpretation
```

Ohne \(\Phi\) bleibt der Zusammenhang methodisch, nicht deduktiv.

---

## 5. Unit-Migration und HoTT-Identitätsschicht

E-073 ergänzt diese Perspektive auf der Identitätsebene.

In Quaternionenordnungen gibt es Einheiten. Zwei Elemente können sich nur durch Multiplikation mit einer Einheit unterscheiden. Klassisch würde man sagen:

\[
x \sim y
\]

und die beiden Elemente in einer Äquivalenzklasse zusammenfassen.

Die HoTT-Interpretation sagt vorsichtiger:

Nicht einfach flach quotientieren, sondern die Migration als Pfad erhalten.

Also:

```
klassisch:
x und y sind assoziiert → gleiche Klasse

HoTT-Lesart:
x und y sind assoziiert → Pfadzeuge zwischen x und y
```

Für reine EABC-Primzahlen bedeutet das:

- Auf der rationalen Ebene ist die Assoziiertheit fast trivial: \(\pm p\).
- In einer Quaternionenordnung können Einheiten aber echte geometrische Drehungen erzeugen.
- Diese Drehungen könnten später als Unit-Migrationspfade modelliert werden.
- Im Repo ist das E-073 und damit bewusst `[C]`: konzeptionelles Interface, kein HoTT-Beweis.

---

## Governance-Tabelle

| Aussage | Einordnung |
|---|---|
| \(p>3\), \(p \equiv 1,5,7,11 \pmod{12}\) hat genau einen EABC-Kanal | definitorisch / E-072 |
| \(M(p)=1\) für reine Prim-EABC-Quaternionen | arithmetische Signaturkonvention |
| Achsenausrichtung in der CSV | Export-/Modellkonvention |
| \(p\) erzeugt links/rechts ein Hauptideal in einer konkreten Ordnung | nur nach gewählter Einbettung \(\Phi\) sinnvoll |
| Links-/Rechtsidealpfade unterscheiden sich | Dedekind-Ideal-/Chiralitätsschicht |
| mod-12-Kanal erklärt Idealchiralität | offen |
| Dedekind-Hasse erklärt EABC-Masse | nicht behauptet |
| Unit-Migration als Pfad | E-073, konzeptionell `[C]` |
| HoTT/Univalenz/HITs formal bewiesen | nicht behauptet |

---

## Praktische Folge fürs Repo

Die reine Prim-EABC-Schicht ist die atomare Testebene:

\[
M(p)=1,\qquad H(p)\in \{(1,0,0,0),(0,1,0,0),(0,0,1,0),(0,0,0,1)\}.
\]

Die Dedekind-Ideal-Schicht ist die nichtkommutative Struktur- und Pfadebene:

\[
\gamma \mapsto H\gamma,\qquad \gamma \mapsto \gamma H.
\]

Die HoTT-Schicht ist die konzeptionelle Identitätsebene:

\[
\text{Unit-Migration} \mapsto \text{Pfadzeuge}.
\]

Kurz gesagt:

\[
M(p)=1
\]

heißt: arithmetisch ein EABC-Atom.

Idealtheoretisch heißt es vorsichtig: ein natürlicher Kandidat für einen einfachen Hauptideal-Generator.

Nicht behauptet wird: dass daraus bereits ein bewiesenes Primideal, eine vollständige Idealklassenerklärung oder eine HoTT-Topologie folgt.

Die wichtigste offene Brücke bleibt daher:

\[
\Phi : \text{EABC-Kanalstruktur} \longrightarrow \text{Quaternionenordnung / Idealpfade}.
\]

Erst mit einer solchen Abbildung kann aus der Parallelität zwischen EABC-Masse und Dedekind-Idealtheorie eine echte deduktive Verbindung werden.
