# EABC-Intervall-Wavelets (beschränkte MRA)

> **Governance:** Diagnostik `[B]`; Resonanz-/Physik-Lesart `[C]`.  
> **Code:** `eabc_interval_wavelet.py` · `eabc_interval_wavelet_shuffle.py` · `eabc_interval_wavelet_plot.py`  
> **Voraussetzung:** [`eabc_normal_form.md`](eabc_normal_form.md) §0 Claim-Wand · `EABC/Semiprim.lean`

---

## Audit-Abschluss \([1,256]\), \(M=1000\)

Referenzlauf: `docs/exports/eabc_interval_wavelet_shuffle_report.json` ·  
Plot: `docs/exports/eabc_interval_wavelet_scalogram.png`

```text
[1, 256] Intervall-Analyse
 ├── Discrete Wavelet / Haar Parseval  ──> [B] wasserdicht (rel. Err. ≲ 10⁻¹⁶)
 ├── V₄-Cross-Correlation (ρ ≈ -0.54)  ──> [B] nachgewiesen (z ≈ -8.7, p₂ = 0)
 ├── Mid-Scale CWT Resonanz (a = 4, 8) ──> [C] VERWORFEN (z ≤ 1.17, p ≥ 0.12)
 └── Lean 4 Absicherung                ──> [A/B] Semiprim-Claim-Wand (Kanal/Gestalt);
                                          Wavelet/Nullmodell bleiben Python-[B]
```

| Schicht | Urteil |
|---|---|
| Haar-Parseval auf endlichem Intervall | `[B]` gehalten |
| Antikorrelation `f_distinct` × `f_triad_cos` | `[B]` algebraische Konsequenz der Triaden-Definition (\(+1\) vs. \(-\tfrac12\)), keine spektrale Physik |
| Mid-Scale-MRA-Resonanz | `[C]` auf diesem Fenster **verworfen** (dichteverträglich unter Multiset-Shuffle) |

**Lean-Scope:** `reachable_semiprim_claim_wall_status` / `EABC/Semiprim.lean` sichern Kanalnormalform und Non-Claims zur Faktorisierung — **nicht** den CWT-Nullmodell-Lauf.

---

## Idee

Auf einem festen Intervall \([N_{\min}, N_{\max}]\) werden Residual-/Semiprim-/γ-Felder zu **endlichen** \(\ell^2\)-Folgen. Ohne Schranken gibt es kein kanonisches Standard-\(L^2\)-Maß über allen Primzahlen (logarithmische Dichte); mit Schranken ist diskrete Haar-Parseval und eine Morlet-CWT operational.

## Signale

| Signal | Definition | Rolle |
|---|---|---|
| `f_kanal` | \(+1\) wenn \([r]=A\); \(-\tfrac12\) wenn \(B\)/`C`; sonst \(0\) (higher→0) | diskreter Spin `[B]` |
| `f_distinct` | \(1\) bei `distinctChannel`, sonst \(0\) | Cosinus-\(-\tfrac12\)-Maske |
| `f_triad_cos` | \(-\tfrac12\) / \(+1\) auf \(\Omega(r)=2\), sonst \(0\) | Triaden-Dictionary |
| `f_gamma_im_norm` | \(\|{\mathrm{Im}\,\gamma(n)}\|_1\) | Quaternion-Amplitude |

## Transformationen

1. **Haar (orthogonal, gepaddet auf \(2^L\)):** Energieerhaltung \(\|f\|^2=\|a\|^2+\sum\|d_j\|^2\) numerisch `[B]`.
2. **Morlet-CWT:** \(C(a,b)=a^{-1/2}\sum_n f(n)\,\overline{\psi((n-b)/a)}\) — Scalogramm-Diagnostik `[B]`; „\(\omega=2\pi/3\)-Resonanz“ bleibt `[C]`.

## Claim-Wand

| Tag | Inhalt |
|---|---|
| `[B]` | endliches Intervall, Signale, Haar-Parseval, CWT-Export |
| `[C]` | physikalische MRA; Triaden-Frequenz als Naturkonstante des Scalogramms |
| **nicht** | Faktorisierung von \(r\); Cosinus auf `higher`; Lean-Plancherel; Collatz |

Lean: ein formales `wavelet_energy_conservation` über `Finset` ist **optional später** — der Python-Prototyp ist die Arbeitsfläche.

## Nullmodell (Kanal-Shuffle)

Modul: `src/kepler_hurwitz/eabc_interval_wavelet_shuffle.py`

| Schritt | Inhalt |
|---|---|
| H₀ | Mid-Scale-Peaks (\(a\in[4,16]\)) entstehen nur durch dünne Besetzung |
| Shuffle | Multiset der Signalwerte bleibt (Energie/Häufigkeiten), Orte permutieren |
| \(E(a)\) | mean\(_n\,\|W(a,n)\|\) |
| \(z(a)\) | \((E_{\mathrm{real}}-\mu_{\mathrm{shuf}})/\sigma_{\mathrm{shuf}}\) |
| Cross-Corr | \(f_{\mathrm{distinct}}\) fix, \(f_{\mathrm{triad\_cos}}\) shuffeln (Alignment-Null) |

Gleiche Permutation auf beiden Signalen würde \(\langle f,g\rangle\) invariant lassen — deshalb **nicht** für den Cross-Corr-Test.

| Tag | Inhalt |
|---|---|
| `[B]` | \(z\)-Scores, empirische \(p\)-Werte, JSON |
| `[C]` | „Resonanz überlebt H₀“ / MRA-Physik |
| **nicht** | Lean-Signifikanzsatz; Multiple-Testing-Korrektur als Theorem |

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_interval_wavelet_shuffle \
  --n-min 1 --n-max 128 --reps 100 --fast \
  --out docs/exports/eabc_interval_wavelet_shuffle_report.json
```

### Scalogramm-Inspektion (matplotlib)

Nach dem Shuffle-Lauf:

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_interval_wavelet_plot \
  --shuffle-json docs/exports/eabc_interval_wavelet_shuffle_report.json \
  --out docs/exports/eabc_interval_wavelet_scalogram.png
```

Drei Panels: Signalspuren · Scalogramm \(|W|\) für `f_distinct` · \(z(a)\) mit Schwelle \(\pm 2.58\).

## CLI (Basis-Signale)

```bash
PYTHONPATH=src python -m kepler_hurwitz.eabc_interval_wavelet --n-min 1 --n-max 256 --fast \
  --out docs/exports/eabc_interval_wavelet_report.json
```
