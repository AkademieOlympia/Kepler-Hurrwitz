# Grundgedanken: Arithmetischer Hurwitz-Doppelkegel

## 1. Grundstruktur

Nach Abspaltung der 2- und 3-Achsen wird eine Zahl \(n\) in einen orientierten 8-Koordinatenraum eingebettet:

\[
\mathcal H(n)=
(O(n),E(n),A^+(n),B^+(n),C^+(n),A^-(n),B^-(n),C^-(n)).
\]

- \(E\): Mittelachse des arithmetischen Doppelkegels
- \(A^\pm,B^\pm,C^\pm\): gerichtete Mantellinien
- \(O\): Skalar-/Normkoordinate

Aggregation auf die bisherige EABC-Signatur:

\[
A=A^+ + A^-,\quad
B=B^+ + B^-,\quad
C=C^+ + C^-.
\]

Orientierungskoordinaten (Chiralitaet):

\[
\alpha=A^+ - A^-,\quad
\beta=B^+ - B^-,\quad
\gamma=C^+ - C^-.
\]

## 2. Geometrische Lesart

Alte Ebene:

\[
(A,B,C)\ \text{misst Verteilung/Masse}.
\]

Neue Ebene:

\[
(\alpha,\beta,\gamma)\ \text{misst Orientierung/Chiralitaet}.
\]

Damit wird EABC von einer rein verteilungsbasierten Signatur zu einer orientierten Kegelschnitt-Geometrie erweitert.

## 3. Hurwitz-Anschluss

Arithmetik im Ring der Hurwitz-Integer liefert den formalen Operatorrahmen:

\[
P,Q \in \mathcal H,\quad N(P)=p,\ N(Q)=q,\quad PQ=Q'P'.
\]

Die durch Metakommutation induzierte Permutation auf Hurwitz-Primzahlen ueber \(p\) traegt ein Signum, das durch den quadratischen Charakter \(\left(\frac{q}{p}\right)\) gesteuert ist.  
Damit wird Chiralitaet nicht nur heuristisch, sondern operatorarithmetisch messbar.

## 4. Kepler-Invarianten

Zu jeder Zahl \(n\) gehoert neben \(\mathcal H(n)\) ein Invariantensystem:

\[
\kappa(n)=
(a(n),b(n),e(n),L(n),T(n),v_{\mathrm{peri}}(n),v_{\mathrm{apo}}(n),R_v(n)).
\]

Definitionen (normiert):

\[
b=a\sqrt{1-e^2},\quad
L=\sqrt{a(1-e^2)},\quad
T=a^{3/2},
\]
\[
v_{\mathrm{peri}}=\sqrt{\frac{1+e}{a(1-e)}},\quad
v_{\mathrm{apo}}=\sqrt{\frac{1-e}{a(1+e)}}.
\]

Schluesselrelation:

\[
\boxed{
R_v(n)=\frac{1+e(n)}{1-e(n)}
=
\frac{v_{\mathrm{peri}}(n)}{v_{\mathrm{apo}}(n)}.
}
\]

## 5. Leit-Hypothese

\[
n \longmapsto \mathcal H(n) \longmapsto \mathcal C(n) \longmapsto \kappa_{\mathrm{Kepler}}(n).
\]

Jede Zahl bestimmt damit:
- eine orientierte Hurwitz-Signatur,
- einen arithmetischen Kegelschnitt,
- ein dynamisches Kepler-Invariantensystem.

## 6. Quaternionisch-oktonionische Grenzschicht

Fuer die Energiedoku wird die quaternionische Schicht \(\mathbb H\) als
assoziativer Kern beibehalten und durch einen oktonionischen Slice-Test
erganzt.

Fixiert man eine imaginare Einheit \(\hat u \in \operatorname{Im}\mathbb O\),
entsteht ein \(SU(3)\)-Slice der \(G_2\)-Geometrie. Die rechten Spektralloci
werden ueber zwei starre algebraische Bedingungen repraesentiert:

\[
\mu^4 + 6\mu^3 + (2Q^2 - 15)\mu^2 + (6Q^2 - 56)\mu + Q^4 + Q^2 = 0,
\]
\[
(\mu + 2)^2 + Q^2 = 4.
\]

Zusatzlich werden dieselben Loci in spur-/norminvarianter Form erfasst:

\[
N^2 + (3T + 1)N - 4T^2 - 28T = 0,\qquad N + 2T = 0.
\]

Interpretation im Modell:
- In \(\mathbb H\) verschwindet der gemischte Assoziator identisch.
- Die beiden Schnittpunkte \((\mu, Q)=(-5/2,\pm\sqrt{15}/2)\) markieren
  interferenzartige, geometrisch starre Uebergaenge.
- Damit koennen nicht-assoziative Effekte als kontrollierte Deformationen
  einer assoziativen Grundschicht codiert werden.
