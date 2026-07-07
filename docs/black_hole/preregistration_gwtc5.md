---
title: Präregistrierungs-Protokoll — GWTC-5 Lücken-Test (ORQ-093)
date: 2026-07-07
status: LOCK
evidence_id: E-093
orq_id: ORQ-093
claim_boundary: >-
  Phase-1-Grid-Sweep auf GWTC-3 liefert nur (kappa*, tau*) — kein [B]-Claim ohne Phase-2-Verifikation
  auf GWTC-4/5; Bonferroni über 92 Tests in Phase 1; Phase 2 ein einziger präregistrierter Test
  (alpha=0.05 einseitig). Kein Post-hoc-Minimum-p über explorative Sweeps.
---

# Präregistrierungs-Protokoll: GWTC-5 Lücken-Test (ORQ-093)

**Projekt:** Black Hole / #Energiedoku (Quaternionen-Primzahlmodell)  
**Datum der Fixierung:** 07. Juli 2026  
**Status:** LOCK (Bereit für Dateneinlesung)

## 1. Zielsetzung

Prüfung der Hypothese, dass 1G-Kandidaten ($\chi_p < 0{,}2$) signifikant häufiger Legendre-verbotene Normschalen ($4^a(8b+7)$) meiden als durch Zufall zu erwarten wäre, gemessen über einen Erwartungswert-Permutationstest der stochastischen Wahrscheinlichkeit $P_{\text{gap}}$.

## 2. Parameter-Raum und Grid-Definition

Wir suchen einen fundamentalen Quantisierungsfaktor $\kappa$ (Sonnenmassen zu Quaternionen-Norm) und definieren eine Toleranz $\tau$ für die Lückenbreite.

*   **Toleranz ($\tau$):** Wird fixiert auf $\tau \in \{0{,}25, 0{,}5\}$. Im quaternionischen Zahlenraum entspricht $0{,}5$ der maximalen Unschärfe, bevor ein Wert der benachbarten ganzen Zahl zugeordnet wird.
*   **Suchraum für den Quantisierungsfaktor ($\kappa$):** $\kappa \in [0{,}5, 5{,}0]$
*   **Schrittweite (Grid Step):** $\Delta\kappa = 0{,}1$
*   **Anzahl der Tests ($N_{\text{tests}}$):** 46 Schritte für $\kappa$ $\times$ 2 Schritte für $\tau$ = 92 unabhängige Hypothesentests.

## 3. Daten-Partitionierung (Das „Lockbox“-Verfahren)

Um Überanpassung (Overfitting) zu vermeiden, wird der Testzweig in zwei Phasen unterteilt:

### Phase 1: Kalibrierung (Out-of-Sample)

*   **Datensatz:** GWTC-3 (Alle bestätigten Events bis O3).
*   **Ziel:** Identifikation des optimalen Parameterpaars $(\kappa^*, \tau^*)$, das den Permutations-$p$-Wert minimiert.
*   **Multiple-Test-Korrektur:** Bonferroni über $N_{\text{tests}} = 92$; ein signifikantes Minimum nur bei $p_{\text{adj}} < 0{,}05$.
*   *Anmerkung:* Dieser Schritt dient rein der Parameterfindung. Ein signifikantes Ergebnis hier rechtfertigt **keinen** [B]-Claim.

### Phase 2: Verifikation (Blind-Test)

*   **Datensatz:** GWTC-4 und GWTC-5 (Nur neue Events aus O4).
*   **Ziel:** Das identifizierte Parameterpaar $(\kappa^*, \tau^*)$ aus Phase 1 wird **exakt einmal** auf die neuen Daten angewendet.
*   **Signifikanzniveau ($\alpha$):** $0{,}05$ (einseitig).
*   Da hier nur noch ein einziger, präregistrierter Test durchgeführt wird, entfällt die Notwendigkeit für eine multiple Testkorrektur.

## 4. Statistische Methode

*   **Fehlerfortpflanzung:** Monte-Carlo Split-Normal-Sampling mit $N=10.000$ pro Event zur Berechnung des Erwartungswerts $\mathbb{E}[P_{\text{gap}}]$.
*   **1G/2G-Stratifizierung:** Der Schwellenwert für die 1G-Population wird fixiert auf $\chi_p < 0{,}2$.
*   **Nullmodell:** $10.000$ Permutationen (Shuffle) des $\chi_p$-Vektors bei fixen Massen und fixen Messfehlern.
*   **Erfolgskriterium:** Der Test gilt als bestanden und die Heuristik [C] wird zu Evidenz [B] hochgestuft, wenn der Erwartungswert $\mathbb{E}[P_{\text{gap}}]$ der echten 1G-Population im GWTC-5 Datensatz kleiner ist als 95 % der Permutations-Nullmodelle ($p < 0{,}05$).

## 5. Ausschlusskriterien (Data Exclusion)

*   Ereignisse ohne veröffentlichte $\chi_p$-Werte oder ohne untere/obere Massenfehlergrenzen werden aus der Analyse entfernt.
*   Sekundärmassen ($M_2$) werden in dieser isolierten Analyse nicht berücksichtigt, um die Unabhängigkeit der Datenpunkte zu wahren (Fokus auf Primärmasse $M_1$).
