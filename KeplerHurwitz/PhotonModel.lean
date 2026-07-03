import Mathlib
import KeplerHurwitz.GodelKerr
import KeplerHurwitz.KeplerInvariants

namespace KeplerHurwitz

/--
Defensives Photon-Observable fuer das Projekt.
Alle Groessen sind normierte reelle Observablen.
-/
structure PhotonObservable where
  frequency : ℝ
  wavelength : ℝ
  energy : ℝ

/--
Abstrakte Dispersionsbeziehung: `frequency * wavelength = c`.
Zusatzlich werden Nichtnegativitaeten gefordert.
-/
def SatisfiesDispersion (c : ℝ) (p : PhotonObservable) : Prop :=
  0 ≤ p.frequency ∧ 0 ≤ p.wavelength ∧ p.frequency * p.wavelength = c

/--
Abstrakte Planck-Beziehung: `energy = h * frequency`.
-/
def SatisfiesPlanck (h : ℝ) (p : PhotonObservable) : Prop :=
  p.energy = h * p.frequency

theorem energy_nonneg_of_planck
    {h : ℝ} (hh : 0 ≤ h) {p : PhotonObservable}
    (hp : SatisfiesPlanck h p) (hf : 0 ≤ p.frequency) :
    0 ≤ p.energy := by
  rw [hp]
  exact mul_nonneg hh hf

theorem frequency_nonneg_of_dispersion
    {c : ℝ} {p : PhotonObservable} (hp : SatisfiesDispersion c p) :
    0 ≤ p.frequency := hp.1

theorem wavelength_nonneg_of_dispersion
    {c : ℝ} {p : PhotonObservable} (hp : SatisfiesDispersion c p) :
    0 ≤ p.wavelength := hp.2.1

/--
Brueckenpraedikat zur Kepler-Invariantenebene:
das normierte "Lichttempo" `c` wird mit `radiusRatio e` identifiziert.
-/
def IsPhotonKeplerCompatible (a e c h : ℝ) (p : PhotonObservable) : Prop :=
  0 < a ∧ 0 ≤ e ∧ e < 1 ∧
  SatisfiesDispersion c p ∧
  SatisfiesPlanck h p ∧
  radiusRatio e = c

theorem kepler_ratio_nonneg_of_photon_compatible
    {a e c h : ℝ} {p : PhotonObservable}
    (hc : IsPhotonKeplerCompatible a e c h p) :
    0 ≤ radiusRatio e := by
  rcases hc with ⟨ha, he0, he1, -, -, -⟩
  unfold radiusRatio
  apply div_nonneg <;> linarith

/--
Brueckenpraedikat zur Goedel-Kerr-Ebene.
Es koppelt ein Photon-Observable an ein kompatibles Raumzeit-Observable.
-/
def IsPhotonGodelKerrCompatible
    (M : GodelKerrModel)
    (o : GodelKerrObservable M)
    (p : PhotonObservable) : Prop :=
  IsGodelKerrCompatible M o ∧ 0 ≤ p.energy

theorem photon_energy_nonneg_of_godelKerr
    {M : GodelKerrModel} {o : GodelKerrObservable M} {p : PhotonObservable}
    (h : IsPhotonGodelKerrCompatible M o p) :
    0 ≤ p.energy := h.2

end KeplerHurwitz
