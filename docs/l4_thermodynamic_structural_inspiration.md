# L4: Thermodynamic Structural Inspiration

Dieses Dokument fuehrt thermodynamische Begriffe als strukturelle
Orientierung ein. Es erzeugt keine neue Evidenzstufe und keine
physikalische Identifikation.

## Defensiver Rahmen

Nicht behauptet wird:

- dass EABC bereits eine physikalische Thermodynamik herleitet,
- dass Konstanten wie `k_B`, `hbar`, `alpha` oder `sigma` aus dem Modell
  bereits formal folgen.

Stattdessen:

- thermodynamische Sprache als Organisationsrahmen fuer Spektren,
  Zustandsdichten, Skalenfluesse und Attraktorverhalten.

## Strukturfluss

`Zustandsraum -> Spektrum -> Zustandssumme -> Temperatur/Entropie/freie Energie`

## Minimaler mathematischer Kern (neutral)

Fuer endliche Spektren als formale Ausgangssprache:

- `Z(beta) = sum_i exp(-beta * E_i)`
- `F(beta) = -(1/beta) * log Z(beta)`
- `S(beta) = beta * (E - F)`

Diese Formeln sind hier als strukturelle Zielgroessen gemeint, nicht als
bereits bewiesene EABC-Theoreme.

## Projektinterne Rollenmatrix

| Ebene | Bedeutung im Projekt | Evidenzstatus (typisch) |
|---|---|---|
| Spektrum | Eigenwerte diskreter Operatoren | `[A]` oder `[B]` |
| Zustandssumme | formaler Ausdruck ueber Spektralwerte | zunaechst `[C]` oder `A-D` |
| Thermodynamische Groessen | Entropie, freie Energie, Temperatur | zunaechst `[C]`/`L4` |
| Physikalische Konstanten | `k_B`, `hbar`, `c`, `alpha`, `sigma` | ausschliesslich `L4` bis zur formalen/kalibrierten Einfuehrung |

## Riemann-/Spektralbezug (L4-Frage)

Nicht:

- "Nullstellen erzeugen bereits physikalische Planck-Struktur."

Sondern:

- Spektrale Lesarten motivieren die Frage, ob Zustandssummen oder
  thermodynamische Formalismen als Organisationssprache fuer
  Nullstellen- oder Hurwitz-Spektren dienen koennen.

## Schutzregel

Physikalische Konstanten duerfen ausserhalb von `L4` erst dann verwendet
werden, wenn sie als dimensionslose/normalisierte Modellparameter oder als
klar kalibrierte externe Konstanten eingefuehrt sind.
