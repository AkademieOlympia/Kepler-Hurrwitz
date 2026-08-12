---
title: Primvierling — C₄-Kanalrotation, Φ_θ und inert/zerfallend
date: 2026-07-17
status: >-
  Abschnitt geschlossen: Nomenklatur inert; bewiesener Kern vs. abgetretene
  Claims dokumentiert. [B] Kongruenzsätze elementar; Enumeration = Regressionstest;
  Typwort-Lesesprache [C]; Illustration ≠ Physik.
claim_boundary: >-
  Die beiden Restklassenzyklen (11,1,5,7) und (5,7,11,1) für echte Primvierlinge
  p>3 folgen aus modularer Arithmetik — kein empirischer Beweis nötig.
  Enumeration bis 10^6 ist Regressionstest der Implementierung, kein Existenzbeweis.
  „Kanal-Signatur“ / Übergangswort / Gaußsches Typwort ist kombinatorisch, keine
  Homotopieinvariante ohne definierte Transformationsgruppe.
  Keine physikalische Dualität, keine Achsenprojektion auf ℂ, keine Antipodalität.
  Interaktive Darstellung = geometrische Illustration nur.
  Kein Collatz-Beweis. Schicht B3 bleibt unabhängig blockiert.
not_claimed:
  - Endliche Enumeration beweist den Kongruenzsatz
  - Übergangswort ist topologische Invariante (Homotopie/Fundamentalgruppe)
  - C₄-Rotation ist physikalische Dualität oder Feldtheorie
  - Antipodalität gleicher Typen auf C₄
  - Kanonische Identifikation mit Real-/Imaginärachsen von ℂ
  - Ausnahme Q(5) widerlegt die regulären Kanäle
  - Collatz bewiesen
  - Schicht B3 freigegeben
epistemic_layers:
  B: Kongruenzsätze, Definition von S, Δθ, Φ_θ, Phasenverschiebung π
  C: Übergangswort / Gaußsches Typwort als modellinterne Bezeichnung
  E: Regressionstest bis p+8 ≤ 10^6 (166 Vierlinge)
related:
  - ../prime_quadruple_test_concept.md
  - eabc_epistemic_layers_vdw_eigen_vacuum.md
  - eabc_complement_and_vacuum.md
  - ../energiedoku_exports/eabc_inert_c4_phase_shift_2026_07_17.md
  - bh_c11_scale_invariance_homogeneity.md
---

> **Evidence:** Kongruenzaussagen **Ebene B** · Terminologie **Ebene C** · Enumeration **Ebene E** (Regression).  
> Siehe [`eabc_epistemic_layers_vdw_eigen_vacuum.md`](eabc_epistemic_layers_vdw_eigen_vacuum.md).  
> **Archiv-Seal:** [`../energiedoku_exports/eabc_inert_c4_phase_shift_2026_07_17.md`](../energiedoku_exports/eabc_inert_c4_phase_shift_2026_07_17.md).

# Primvierling: \(C_4\)-Zustandskreis, \(\Phi_\theta\) und Phasenverschiebung \(\pi\)

## 0. Nomenklaturregel (verbindlich)

| Kanonischer Term | Erstverwendung / Alias |
|---|---|
| **`inert`** | bei erstem Auftreten: `inert` (zunächst: *„träge“*) |
| **`zerfallend`** | zweiter Gauß-Typ unter \(\Phi_\theta\) (beibehalten) |

Nach der Erstnennung wird ausschließlich **`inert`** verwendet (nicht weiter „träge“).  
`zerfallend` bleibt der komplementäre Typname.

## 1. Zustandskreis

Mit der festen Ordnung der EABC-Restklassen

\[
\mathcal{S} = (11,\, 1,\, 5,\, 7)
\]

identifizieren wir den diskreten Zustandsraum mit dem Kreisgraphen \(C_4\). Die Phasenabbildung

\[
\varphi:\ \{11,1,5,7\}\ \to\ \{0,1,2,3\},
\qquad
\varphi(11)=0,\ \varphi(1)=1,\ \varphi(5)=2,\ \varphi(7)=3
\]

ordnet jeder Restklasse einen Winkelindex zu. Der zugehörige Winkel ist
\(\theta = \varphi(r)\cdot\pi/2\in\{0,\pi/2,\pi,3\pi/2\}\).

Das **Rotationsinkrement** zwischen zwei aufeinanderfolgenden Vierlingskomponenten mit Restklassen \(r,r'\) ist

\[
\Delta\theta(r,r')
=
\bigl(\varphi(r')-\varphi(r)\bigr)\bmod 4
\in\{0,1,2,3\},
\]

gemessen in Einheiten von \(\pi/2\) (ein Schritt auf \(C_4\)).

## 2. Vierlingskomponenten und sukzessive Differenzen

Für \(Q(p)=(p,\ p+2,\ p+6,\ p+8)\) sind die drei sukzessiven Differenzen der Glieder

\[
\delta_1=+2,\qquad \delta_2=+4,\qquad \delta_3=+2.
\]

(Die Offsets vom Startglied sind \(+2,+6,+8\); hier zählen die **Kanten** des Vierlings.)

Sei \(r_i = q_i \bmod 12\) für die Glieder \(q_0,\ldots,q_3\) von \(Q(p)\). Das **Übergangswort** (kombinatorische Kanal-Signatur) ist

\[
w(Q(p)) = (r_0,r_1,r_2,r_3).
\]

## 3. Kongruenzsatz (Ebene B)

Für echte Primvierlinge mit \(p>3\) gilt:

1. \(p\equiv 5\) oder \(p\equiv 11\pmod{12}\) (sonst teilt \(3\) ein Glied).
2. Die Restklassenfolge ist genau eine der beiden Rotationen auf \(\mathcal{S}\):
   - \(p\equiv 11\pmod{12}\) (gerade Indexierung \(k\) in der üblichen Parametrisierung):  
     \(w=(11,1,5,7)\), also \(\Delta\theta=+1\) auf jeder Kante.
   - \(p\equiv 5\pmod{12}\) (ungerade \(k\)):  
     \(w=(5,7,11,1)\), wiederum \(\Delta\theta=+1\) auf jeder Kante (phasenverschobener Start auf \(\mathcal{S}\)).
3. Ausnahme \(Q(5)=(5,7,11,13)\): liegt im ungeraden Kanal; wird in Statistiken getrennt als `ausnahme_5` geführt, nicht als Scope-Leak der Schleifenvariable.

Damit bilden die arithmetischen Differenzen \(\delta_i\in\{+2,+4\}\) unter der Einbettung in \(\mathcal{S}\) jeweils denselben diskreten Winkelschritt \(\Delta\theta=+1\). Das **invariante Übergangswort** auf dem \(C_4\)-Zustandsraum ist daher für beide regulären Kanäle

\[
(+1,+1,+1).
\]

Das ist eine Aussage der modularen Arithmetik, keine empirische Entdeckung.

## 4. Geometrische Relation: Phasenverschiebung \(\pi\)

Die beiden regulären Trajektorien sind rein phasenverschoben um **exakt \(\pi\)**
(zwei Schritte auf \(C_4\)): Start bei \(\varphi(11)=0\) versus Start bei \(\varphi(5)=2\).

\[
w_{p\equiv 5}
=
\mathrm{Rot}_{2}\bigl(w_{p\equiv 11}\bigr)
\quad\text{auf}\quad
\mathcal{S}.
\]

## 5. Algebraische Typmarkierung \(\Phi_\theta\)

Die wohldefinierte Abbildung von Winkel zu Gaußschem Typ lautet:

\[
\Phi_\theta(0)
=
\Phi_\theta\Bigl(\frac{3\pi}{2}\Bigr)
=
\mathrm{inert}
\qquad
\text{(zunächst: *„träge“*)}
\]

\[
\Phi_\theta\Bigl(\frac{\pi}{2}\Bigr)
=
\Phi_\theta(\pi)
=
\mathrm{zerfallend}.
\]

Mit \(\theta=\varphi(r)\cdot\pi/2\) erhalten die Restklassen die Typen:

| Restklasse | \(\varphi\) | \(\theta\) | Typ |
|---|---|---|---|
| \(11\) | \(0\) | \(0\) | `inert` |
| \(1\) | \(1\) | \(\pi/2\) | `zerfallend` |
| \(5\) | \(2\) | \(\pi\) | `zerfallend` |
| \(7\) | \(3\) | \(3\pi/2\) | `inert` |

Die beiden Gaußschen Typwörter sind **algebraisch komplementär**: an jeder Position des Vierlings wird der Typ des einen Kanals durch den jeweils anderen Typ ersetzt.

| Kanal | Restklassenwort | Typwort |
|---|---|---|
| \(p\equiv 11\pmod{12}\) | \((11,1,5,7)\) | \((\mathrm{inert},\mathrm{zerfallend},\mathrm{zerfallend},\mathrm{inert})\) |
| \(p\equiv 5\pmod{12}\) | \((5,7,11,1)\) | \((\mathrm{zerfallend},\mathrm{inert},\mathrm{inert},\mathrm{zerfallend})\) |

## 6. Bewiesener Kern (versiegelt)

1. Zwei reguläre Startkanäle: \(p\equiv 11\pmod{12}\) und \(p\equiv 5\pmod{12}\).
2. Invariantes Übergangswort \((+1,+1,+1)\) auf dem \(C_4\)-Zustandsraum für beide Kanäle.
3. Reine Phasenverschiebung um exakt \(\pi\) zwischen den beiden Trajektorien.
4. Zwei algebraisch komplementäre Gaußsche Typwörter via wohldefinierter \(\Phi_\theta\) wie in §5.

## 7. Rigoros abgetretene Claims

- **Keine Antipodalität:** Dieselben algebraischen Typen sitzen auf **benachbarten** \(C_4\)-Zuständen (\(0\) mit \(3\pi/2\); \(\pi/2\) mit \(\pi\)), nicht gegenüber.
- **Keine Achsenprojektion:** Es gibt keine kanonische Identifikation der Zustände mit Real- oder Imaginärachsen von \(\mathbb{C}\).
- **Keine Metaphern:** Es wird keine physikalische Dynamik, Dualität oder topologische Invarianz postuliert.
- **Interaktive Darstellung:** falls vorhanden, nur geometrische Illustration von kombinatorischer Rotation und Typmarkierung — **Illustration ≠ Physik**.

## 8. Regressionstest (Ebene E)

Endliche Enumeration prüft die **korrekte Übersetzung** der Definitionen in Code — sie beweist den Kongruenzsatz nicht.

Referenzlauf (SageMath 10.5, Verifikationsbereich \(p+8\le 10^6\)):

| Größe | Wert |
|---|---|
| Vierlinge insgesamt | 166 |
| Ausnahmevierling \(Q(5)\) | 1 |
| Reguläre Vierlinge | 165 |
| Kanal \(p\equiv 5\pmod{12}\) | 83 |
| Kanal \(p\equiv 11\pmod{12}\) | 82 |
| Kongruenzfehler | 0 |
| Kanalmusterfehler | 0 |
| Zerlegungsfehler in \(\mathbb{Z}[i]\) | 0 |

Implementierung: `src/kepler_hurwitz/primvierling_c4_rotation.py` · Tests: `tests/test_primvierling_c4_rotation.py`.

## 9. Terminologie

| Vermeiden | Verwenden |
|---|---|
| „träge“ (nach Erstnennung) | `inert` |
| Kryptokomponente | Vierlingskomponente / Glied des Vierlings |
| topologische Invariante (ohne Gruppe) | kombinatorische Kanal-Signatur / Übergangswort / Gaußsches Typwort |
| empirischer Beweis des Kongruenzsatzes | Regressionstest der Implementierung |
| Antipodalität / Achsenprojektion / Dualitätsphysik | (abgetreten — nicht behaupten) |

## 10. Claim-Grenze und Governance

Aus der \(C_4\)-Rotation folgt keine physikalische Dualität. Eine Bijektion zu Eigenschaften in \(\mathbb{Z}[i]\) bleibt eine modellinterne Korrespondenz (Ebene C), solange sie nicht als Lean-`[A]`-Satz oder präregistrierter empirischer Effekt (Ebene E) ausgewiesen ist.

\[
\boxed{\text{Illustration} \;\neq\; \text{Physik}}
\]

**Kein Collatz-Beweis.** Die unabhängige **Schicht B3** (Fano-/Inzidenz-Kopplung) bleibt **blockiert**; dieser Abschnittsverschluss hebt B3 nicht auf
(siehe [`bh_c11_scale_invariance_homogeneity.md`](bh_c11_scale_invariance_homogeneity.md) §5.6).
