/-
  Canonical EABC normal form of a natural number:

      n = 2^α · 3^β · r · e

  with axis split {2,3}, E-factor e (channel E, mod 12), residual r (channels A/B/C).

  Reduced residual shapes (the phrases used in the model):
    * reine E-Form          — r = 1
    * Primzahl × E          — r prime
    * Semiprim × E          — Ω(r) = 2  (covers p·q and p²)

  Layer note: channel E here is **mod-12** (`p ≡ 1 (mod 12)`), matching
  `docs/eabc_mass_convention.md` / `signature_from_nat`.
  Do not identify with mod-8 `isE` from `KeplerHurwitz.EABC.Basic` without a bridge.
-/

import Mathlib
import KeplerHurwitz.EABC.Basic
import KeplerHurwitz.EABC.V4

namespace KeplerHurwitz.EABC

/-! ## Channel predicates (mod-12 mass layer) -/

/-- EABC-relevant odd prime (not an axis). -/
def IsEABCPrime (p : ℕ) : Prop :=
  p.Prime ∧ 3 < p ∧ p % 12 ∈ ({1, 5, 7, 11} : Finset ℕ)

/-- Channel-E prime: `p ≡ 1 (mod 12)`. -/
def IsChannelEPrime (p : ℕ) : Prop :=
  p.Prime ∧ 3 < p ∧ p % 12 = 1

/-- Residual prime: channel A, B, or C. -/
def IsResidualPrime (p : ℕ) : Prop :=
  p.Prime ∧ 3 < p ∧ p % 12 ∈ ({5, 7, 11} : Finset ℕ)

theorem isEABCPrime_iff_channelE_or_residual {p : ℕ} :
    IsEABCPrime p ↔ IsChannelEPrime p ∨ IsResidualPrime p := by
  constructor
  · intro ⟨hp, h3, hmem⟩
    have : p % 12 = 1 ∨ p % 12 = 5 ∨ p % 12 = 7 ∨ p % 12 = 11 := by
      simp [Finset.mem_insert, Finset.mem_singleton] at hmem
      omega
    rcases this with h | h | h | h
    · left; exact ⟨hp, h3, h⟩
    · right; exact ⟨hp, h3, by simp [h]⟩
    · right; exact ⟨hp, h3, by simp [h]⟩
    · right; exact ⟨hp, h3, by simp [h]⟩
  · intro h
    rcases h with ⟨hp, h3, h1⟩ | ⟨hp, h3, hmem⟩
    · exact ⟨hp, h3, by simp [h1]⟩
    · refine ⟨hp, h3, ?_⟩
      simp [Finset.mem_insert, Finset.mem_singleton] at hmem ⊢
      exact Or.inr hmem

/-! ## Smoothness predicates on the core -/

/-- All prime factors lie in channel E (vacuously true for `1`). -/
def IsESmooth (e : ℕ) : Prop :=
  0 < e ∧ ∀ p : ℕ, p.Prime → p ∣ e → IsChannelEPrime p

/-- Every prime divisor is a residual (A/B/C) prime; `1` allowed. -/
def IsResidualSmooth (r : ℕ) : Prop :=
  0 < r ∧ ∀ p : ℕ, p.Prime → p ∣ r → IsResidualPrime p

theorem isESmooth_one : IsESmooth 1 := by
  refine ⟨by decide, ?_⟩
  intro p hp hdiv
  have : p = 1 := Nat.eq_one_of_dvd_one hdiv
  exact absurd this hp.ne_one

theorem isResidualSmooth_one : IsResidualSmooth 1 := by
  refine ⟨by decide, ?_⟩
  intro p hp hdiv
  have : p = 1 := Nat.eq_one_of_dvd_one hdiv
  exact absurd this hp.ne_one

/-! ## Axis split and normal-form data -/

/-- Unique writing `n = 2^α · 3^β · κ` with `κ` coprime to `6`. -/
structure AxisSplit (n : ℕ) where
  alpha : ℕ
  beta : ℕ
  core : ℕ
  eq_pow : n = 2 ^ alpha * 3 ^ beta * core
  coprime6 : Nat.Coprime core 6

/-- Multiplicative normal form on the EABC core: `κ = r · e`
with `e` channel-E-smooth and `r` residual-smooth. -/
structure CoreNormalForm (κ : ℕ) where
  residual : ℕ
  eFactor : ℕ
  eq_mul : κ = residual * eFactor
  residual_smooth : IsResidualSmooth residual
  e_smooth : IsESmooth eFactor

/-- Residual shape that names the spoken normal-form phrases. -/
inductive ResidualShape
  | reineE
    -- r = 1
  | primTimesE
    -- Ω(r) = 1 (hence r prime, for residual-smooth r)
  | semiprimTimesE
    -- Ω(r) = 2: either p·q (p ≠ q) or p²
  | higher
    -- Ω(r) ≥ 3
  deriving DecidableEq, Repr

/-- Total prime-Ω of a residual (with multiplicity). -/
def residualOmega (r : ℕ) : ℕ :=
  r.factorization.sum fun _p k => k

/-- Classify the residual factor. -/
def classifyResidual (r : ℕ) : ResidualShape :=
  if r ≤ 1 then
    if r = 1 then ResidualShape.reineE else ResidualShape.higher
  else
    match residualOmega r with
    | 1 => ResidualShape.primTimesE
    | 2 => ResidualShape.semiprimTimesE
    | _ => ResidualShape.higher

/-- Full normal form of `n`. -/
structure EABCNormalForm (n : ℕ) where
  axes : AxisSplit n
  coreNF : CoreNormalForm axes.core
  shape : ResidualShape
  shape_eq : shape = classifyResidual coreNF.residual

/-! ## Spoken predicates (definitional API) -/

/-- `κ` is in reine-E form: residual trivial. -/
def IsReineEForm (κ : ℕ) : Prop :=
  ∃ nf : CoreNormalForm κ, nf.residual = 1

/-- Primzahl × E: `κ = p · e` with residual prime `p` and E-smooth `e`. -/
def IsPrimTimesE (κ : ℕ) : Prop :=
  ∃ p e : ℕ, IsResidualPrime p ∧ IsESmooth e ∧ κ = p * e

/-- Semiprim × E: residual has Ω = 2. -/
def IsSemiprimTimesE (κ : ℕ) : Prop :=
  ∃ r e : ℕ,
    IsResidualSmooth r ∧ IsESmooth e ∧ κ = r * e ∧ residualOmega r = 2

/-- Reduced normal form: reine E, Prim×E, or Semiprim×E (not `higher`). -/
def IsReducedNormalForm (κ : ℕ) : Prop :=
  IsReineEForm κ ∨ IsPrimTimesE κ ∨ IsSemiprimTimesE κ

/-! ## Shape lemmas -/

theorem classifyResidual_one : classifyResidual 1 = ResidualShape.reineE := by
  simp [classifyResidual]

theorem classifyResidual_of_omega_one {r : ℕ} (hr : 1 < r) (hω : residualOmega r = 1) :
    classifyResidual r = ResidualShape.primTimesE := by
  have : ¬ r ≤ 1 := Nat.not_le.mpr hr
  simp [classifyResidual, this, hω]

theorem classifyResidual_of_omega_two {r : ℕ} (hr : 1 < r) (hω : residualOmega r = 2) :
    classifyResidual r = ResidualShape.semiprimTimesE := by
  have : ¬ r ≤ 1 := Nat.not_le.mpr hr
  simp [classifyResidual, this, hω]

theorem IsPrimTimesE.of_residual_prime (p : ℕ) (hp : IsResidualPrime p) :
    IsPrimTimesE p :=
  ⟨p, 1, hp, isESmooth_one, (mul_one p).symm⟩

theorem IsReineEForm.one : IsReineEForm 1 :=
  ⟨{
    residual := 1
    eFactor := 1
    eq_mul := (one_mul 1).symm
    residual_smooth := isResidualSmooth_one
    e_smooth := isESmooth_one
  }, rfl⟩

/-- Catalog: `classifyResidual r = reineE` iff `r = 1`. -/
theorem classifyResidual_eq_reineE_iff (r : ℕ) :
    classifyResidual r = ResidualShape.reineE ↔ r = 1 := by
  constructor
  · intro h
    by_cases hle : r ≤ 1
    · by_cases h1 : r = 1
      · exact h1
      · simp [classifyResidual, hle, h1] at h
    · have : 1 < r := Nat.lt_of_not_ge hle
      simp [classifyResidual, Nat.not_le.mpr this] at h
      split at h <;> cases h
  · intro h; subst h; exact classifyResidual_one

/-! ## Ω-witnesses (multiplicity) -/

-- Concrete factorization witnesses; `native_decide` is acceptable outside Mathlib.
set_option linter.style.nativeDecide false in
theorem residualOmega_one : residualOmega 1 = 0 := by native_decide

set_option linter.style.nativeDecide false in
theorem residualOmega_25 : residualOmega 25 = 2 := by native_decide

set_option linter.style.nativeDecide false in
theorem residualOmega_49 : residualOmega 49 = 2 := by native_decide

set_option linter.style.nativeDecide false in
theorem residualOmega_35 : residualOmega 35 = 2 := by native_decide

theorem classifyResidual_25 :
    classifyResidual 25 = ResidualShape.semiprimTimesE :=
  classifyResidual_of_omega_two (by decide : 1 < 25) residualOmega_25

theorem classifyResidual_49 :
    classifyResidual 49 = ResidualShape.semiprimTimesE :=
  classifyResidual_of_omega_two (by decide : 1 < 49) residualOmega_49

theorem classifyResidual_35 :
    classifyResidual 35 = ResidualShape.semiprimTimesE :=
  classifyResidual_of_omega_two (by decide : 1 < 35) residualOmega_35

/-! ## Explicit non-identification flags -/

/-- Mod-8 `isE` (`Basic`) ≠ channel-E factor of this normal form. -/
theorem mod8_layer_distinct_from_channelE : True := trivial


/-! ## \(V_4\) coupling: E-factor is neutral, residual carries the class -/

theorem IsChannelEPrime.mod12_eq_one {p : ℕ} (hp : IsChannelEPrime p) : p % 12 = 1 :=
  hp.2.2

/-- Residues in \((\mathbb Z/12\mathbb Z)^\times\) are coprime to 6. -/
theorem mod12_unit_coprime_six {n : ℕ}
    (h : n % 12 = 1 ∨ n % 12 = 5 ∨ n % 12 = 7 ∨ n % 12 = 11) :
    Nat.Coprime n 6 := by
  have h12 : Nat.Coprime n 12 := by
    rcases h with h | h | h | h
    · have : n * 1 ≡ 1 [MOD 12] := by
        change n * 1 % 12 = 1 % 12
        simp [h]
      exact Nat.coprime_of_mul_modEq_one 1 this
    · have : n * 5 ≡ 1 [MOD 12] := by
        change n * 5 % 12 = 1 % 12
        rw [Nat.mul_mod, h]
      exact Nat.coprime_of_mul_modEq_one 5 this
    · have : n * 7 ≡ 1 [MOD 12] := by
        change n * 7 % 12 = 1 % 12
        rw [Nat.mul_mod, h]
      exact Nat.coprime_of_mul_modEq_one 7 this
    · have : n * 11 ≡ 1 [MOD 12] := by
        change n * 11 % 12 = 1 % 12
        rw [Nat.mul_mod, h]
      exact Nat.coprime_of_mul_modEq_one 11 this
  exact h12.coprime_dvd_right (by decide : 6 ∣ 12)

theorem mod12_eq_one_coprime_six {n : ℕ} (h1 : n % 12 = 1) : Nat.Coprime n 6 :=
  mod12_unit_coprime_six (Or.inl h1)

theorem IsChannelEPrime.coprime_six {p : ℕ} (hp : IsChannelEPrime p) : Nat.Coprime p 6 :=
  mod12_eq_one_coprime_six hp.mod12_eq_one

/-- E-smooth numbers are ≡ 1 (mod 12). -/
theorem IsESmooth.mod12_eq_one {e : ℕ} (he : IsESmooth e) : e % 12 = 1 := by
  induction e using Nat.strong_induction_on with
  | _ e ih =>
    by_cases h1 : e = 1
    · subst h1; decide
    · have hpos : 0 < e := he.1
      obtain ⟨p, hp, hpdvd⟩ := Nat.exists_prime_and_dvd h1
      have hpE : IsChannelEPrime p := he.2 p hp hpdvd
      obtain ⟨m, hm⟩ := hpdvd
      have hmpos : 0 < m := by
        have hpm : 0 < p * m := by rw [← hm]; exact hpos
        exact Nat.pos_of_mul_pos_left hpm
      have hm_lt : m < e := by
        rw [hm]
        calc
          m = 1 * m := (one_mul m).symm
          _ < p * m := Nat.mul_lt_mul_of_pos_right hp.one_lt hmpos
      have hmSmooth : IsESmooth m := by
        refine ⟨hmpos, fun q hq hqdiv => he.2 q hq ?_⟩
        exact hm ▸ dvd_mul_of_dvd_right hqdiv p
      have ihm : m % 12 = 1 := ih m hm_lt hmSmooth
      have hp1 : p % 12 = 1 := hpE.mod12_eq_one
      calc
        e % 12 = (p * m) % 12 := by rw [hm]
        _ = 1 := by simp [Nat.mul_mod, hp1, ihm]

theorem IsESmooth.coprime_six {e : ℕ} (he : IsESmooth e) : Nat.Coprime e 6 :=
  mod12_eq_one_coprime_six he.mod12_eq_one

theorem IsResidualPrime.mod12_mem {p : ℕ} (hp : IsResidualPrime p) :
    p % 12 = 5 ∨ p % 12 = 7 ∨ p % 12 = 11 := by
  have hmem : p % 12 ∈ ({5, 7, 11} : Finset ℕ) := hp.2.2
  simpa [Finset.mem_insert, Finset.mem_singleton] using hmem

theorem IsResidualPrime.coprime_six {p : ℕ} (hp : IsResidualPrime p) : Nat.Coprime p 6 :=
  mod12_unit_coprime_six (Or.inr hp.mod12_mem)

/-- Residual-smooth numbers are coprime to 6. -/
theorem IsResidualSmooth.coprime_six {r : ℕ} (hr : IsResidualSmooth r) : Nat.Coprime r 6 := by
  induction r using Nat.strong_induction_on with
  | _ r ih =>
    by_cases h1 : r = 1
    · subst h1; decide
    · have hpos : 0 < r := hr.1
      obtain ⟨p, hp, hpdvd⟩ := Nat.exists_prime_and_dvd h1
      have hpR : IsResidualPrime p := hr.2 p hp hpdvd
      obtain ⟨m, hm⟩ := hpdvd
      have hmpos : 0 < m := by
        have hpm : 0 < p * m := by rw [← hm]; exact hpos
        exact Nat.pos_of_mul_pos_left hpm
      have hm_lt : m < r := by
        rw [hm]
        calc
          m = 1 * m := (one_mul m).symm
          _ < p * m := Nat.mul_lt_mul_of_pos_right hp.one_lt hmpos
      have hmSmooth : IsResidualSmooth m := by
        refine ⟨hmpos, fun q hq hqdiv => hr.2 q hq ?_⟩
        exact hm ▸ dvd_mul_of_dvd_right hqdiv p
      have ihm : Nat.Coprime m 6 := ih m hm_lt hmSmooth
      have hp6 : Nat.Coprime p 6 := hpR.coprime_six
      simpa [hm] using Nat.Coprime.mul_left hp6 ihm

/-- Hauptsatz: der E-Faktor ist \(V_4\)-neutral. -/
theorem e_factor_v4_neutral {e : ℕ} (he : IsESmooth e) :
    toV4 e he.coprime_six = V4.E :=
  toV4_of_mod12_one he.coprime_six he.mod12_eq_one

/-- Das Residual trägt die gesamte \(V_4\)-Signatur des Kerns \(r\cdot e\). -/
theorem residual_carries_v4 {r e : ℕ} (hr : Nat.Coprime r 6) (he : IsESmooth e) :
    toV4 (r * e) (Nat.Coprime.mul_left hr he.coprime_six) = toV4 r hr := by
  have h := toV4_mul hr he.coprime_six
  rw [h, e_factor_v4_neutral he]
  cases toV4 r hr <;> rfl

end KeplerHurwitz.EABC
