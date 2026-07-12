import Mathlib
import KeplerHurwitz.Collatz.ChannelSevenAttackV213

/-!
# Kanal-7 V2.14 — 2-adische Lift-Infrastruktur für `243r + 95`

Governance: `[A]` Ebene A (Generator; Ziel: allgemeines `j`); `[C]` Ebene B (Dynamik nach `S⁵`).

Leitformeln:

`Bewertungskaskade vollständig klassifizieren ≠ dynamischen Lift-Baum schließen`

`2-adische Struktur ≠ dynamischer Deszent`

Ebene A: eindeutiger 2-adischer Lift der **linearen** Kongruenz `243r + 95 ≡ 0 (mod 2^j)`
(243 invertierbar mod 2^j — präziser als allgemeiner Hensel-Lift).

**Governance:** die korrekte Generator-Invariante ist `2^j ∣ 243·ρ_j + 95` (plus `ρ_j < 2^j`),
**nicht** `ν_2(243·ρ_j + 95) = j`. Plateaus sind erlaubt (z. B. `ρ_5 = … = ρ_9 = 27`,
`ν_2(243·27 + 95) = 9 ≠ 5`).

Kanal-7-Kontext: im Zweig `k ≡ 1 (mod 4)` gilt `S⁵ = oddCore(243r + 95)` mit Multiplikator
`243 = 3⁵` und Konstante `95`; mod-256-Faser `{95}` nutzt dieselbe `243`-Skala in
`CollatzNetDescentMod8`.
-/

namespace KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214

open KeplerHurwitz.Collatz.ChannelSevenAttackV213

/-- Kanal-7 Deep-Branch-Multiplikator: `243 = 3⁵`. -/
def deepBranchMultiplier : Nat := 243

/-- Kanal-7 Deep-Branch-Konstante im Zweig `k ≡ 1 (mod 4)`. -/
def deepBranchConstant : Nat := 95

/-- Modulus der `j`-ten Lift-Schale: `2^j`. -/
def deepLiftModulus (j : Nat) : Nat :=
  2 ^ j

/-- Deep-branch polynomial am fünften Kick. -/
def deepBranchPoly (r : Nat) : Nat :=
  deepBranchMultiplier * r + deepBranchConstant

theorem deepBranchPoly_eq (r : Nat) :
    deepBranchPoly r = 243 * r + 95 := by
  unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
  rfl

/-!
## Invertierbarkeit von `243` modulo `2^j` (Ebene A, ohne Dynamik)
-/

theorem deepBranchMultiplier_odd : deepBranchMultiplier % 2 = 1 := by decide

theorem deepBranchMultiplier_coprime_two : Nat.Coprime deepBranchMultiplier 2 := by decide

theorem deepBranchMultiplier_coprime_pow_two (j : Nat) :
    Nat.Coprime deepBranchMultiplier (deepLiftModulus j) := by
  cases j with
  | zero => simp [deepLiftModulus, deepBranchMultiplier_coprime_two]
  | succ j =>
    rw [deepLiftModulus, Nat.coprime_pow_right_iff (Nat.succ_pos j)]
    exact deepBranchMultiplier_coprime_two

theorem deepBranchMultiplier_isUnit_zmod (j : Nat) :
    IsUnit (deepBranchMultiplier : ZMod (deepLiftModulus j)) := by
  rw [ZMod.isUnit_iff_coprime, deepBranchMultiplier, deepLiftModulus]
  exact deepBranchMultiplier_coprime_pow_two j

/-!
## Lift-Generator (H5)

Eindeutiger 2-adischer Lift der linearen Kongruenz `243r + 95 ≡ 0 (mod 2^j)`.

Mit `q_j = (243·ρ_j + 95) / 2^j` und Lift-Bit `b ≡ q_j (mod 2)` (da `243 ≡ 1 (mod 2)`):
`ρ_{j+1} = ρ_j + b·2^j` mit `b = 0` falls `q_j` gerade, sonst `b = 1`.
Äquivalent: `ρ_{j+1} = ρ_j` falls `243·ρ_j + 95 ≡ 0 (mod 2^{j+1})`, sonst `ρ_j + 2^j`.

Die Rekursion garantiert `2^{j+1} ∣ 243·ρ_{j+1} + 95`, aber **nicht** `ν_2 = j+1`.
Der Parameter `j` ist der eigentliche Beitrag — nicht eine Fallliste.
-/

/-- Eindeutige Lift-Restklasse `ρ_j` modulo `2^j`. -/
def deepLiftResidue : Nat → Nat
  | 0 => 0
  | j + 1 =>
    let ρ := deepLiftResidue j
    let m := deepLiftModulus j
    let q := deepBranchPoly ρ / m
    if q % 2 = 0 then ρ else ρ + m

/-- Affine Quotientenkonstante `c_j = (243·ρ_j + 95) / 2^j`. -/
def deepLiftConstant (j : Nat) : Nat :=
  (deepBranchPoly (deepLiftResidue j)) / deepLiftModulus j

theorem deepLiftModulus_succ (j : Nat) :
    deepLiftModulus (j + 1) = 2 * deepLiftModulus j := by
  simp [deepLiftModulus, pow_succ, mul_comm]

theorem deepLiftModulus_pos (j : Nat) : 0 < deepLiftModulus j := by
  simp [deepLiftModulus, pow_pos]

private theorem deepBranchPoly_add_mod (r m : Nat) :
    deepBranchPoly (r + m) = deepBranchPoly r + deepBranchMultiplier * m := by
  unfold deepBranchPoly deepBranchMultiplier
  ring

/-- Lift-Restklasse bleibt strikt unter dem Modulus `2^j`. -/
theorem deepLiftResidue_lt (j : Nat) : deepLiftResidue j < deepLiftModulus j := by
  induction j with
  | zero => simp [deepLiftResidue, deepLiftModulus]
  | succ j ih =>
    dsimp [deepLiftResidue]
    split_ifs with h
    · have hlt : deepLiftModulus j < deepLiftModulus (j + 1) := by
        rw [deepLiftModulus_succ]
        have hmpos : 0 < deepLiftModulus j := deepLiftModulus_pos j
        omega
      exact lt_trans ih hlt
    · have hm : deepLiftModulus j = 2 ^ j := rfl
      have hρ : deepLiftResidue j < 2 ^ j := by simpa [hm] using ih
      have htwo : deepLiftModulus (j + 1) = 2 * 2 ^ j := by
        simp [deepLiftModulus, pow_succ, mul_comm]
      rw [htwo]
      omega

private theorem mul_dvd_mod_zero (a b : Nat) : (a * b) % a = 0 :=
  Nat.mul_mod_right a b

private theorem m_two_mul_mod_zero (m q : Nat) : (m * (2 * q)) % (2 * m) = 0 := by
  have h : 2 * m ∣ m * (2 * q) := ⟨q, by ring⟩
  exact Nat.mod_eq_zero_of_dvd h

private theorem two_q_mul_m_mod_zero (m q : Nat) : (2 * q * m) % (2 * m) = 0 := by
  have h : 2 * m ∣ 2 * q * m := ⟨q, by ring⟩
  exact Nat.mod_eq_zero_of_dvd h

private theorem deepLiftResidue_spec_succ (j : Nat)
    (ih : deepBranchPoly (deepLiftResidue j) % deepLiftModulus j = 0) :
    deepBranchPoly (deepLiftResidue (j + 1)) % deepLiftModulus (j + 1) = 0 := by
  dsimp [deepLiftResidue]
  set ρ := deepLiftResidue j
  set m := deepLiftModulus j
  have hm : deepLiftModulus (j + 1) = 2 * m := by
    dsimp [m]
    exact deepLiftModulus_succ j
  have hρm : deepBranchPoly ρ % m = 0 := by
    dsimp [ρ, m] at ih ⊢
    exact ih
  have hdvd : m ∣ deepBranchPoly ρ := Nat.dvd_of_mod_eq_zero hρm
  rcases hdvd with ⟨q, hq⟩
  have hqdef : deepBranchPoly ρ / m = q := by
    simpa [hq] using Nat.mul_div_cancel_left q (deepLiftModulus_pos j)
  split_ifs with hqeven
  · have htwo : 2 ∣ q := by
      rw [← hqdef]
      exact Nat.dvd_of_mod_eq_zero hqeven
    rcases htwo with ⟨t, ht⟩
    have hdiv : deepBranchPoly ρ % (2 * m) = 0 := by
      rw [hq, ht, mul_comm m (2 * t)]
      exact two_q_mul_m_mod_zero m t
    simpa [hm, ρ, m, hqdef] using hdiv
  · have hc_odd : q % 2 = 1 := by omega
    have hadd :
        deepBranchPoly (ρ + m) = deepBranchPoly ρ + deepBranchMultiplier * m :=
      deepBranchPoly_add_mod ρ m
    have hcore : deepBranchPoly (ρ + m) = (q + deepBranchMultiplier) * m := by
      rw [hadd, hq, add_mul, mul_comm m q, add_comm (q * m)]
    have hsum_even : (q + deepBranchMultiplier) % 2 = 0 := by
      have hm_odd : deepBranchMultiplier % 2 = 1 := deepBranchMultiplier_odd
      omega
    have hmod :
        deepBranchPoly (ρ + m) % (2 * m) = 0 := by
      rw [hcore]
      have htwo : 2 ∣ q + deepBranchMultiplier :=
        Nat.dvd_of_mod_eq_zero hsum_even
      rcases htwo with ⟨t, ht⟩
      rw [ht]
      exact two_q_mul_m_mod_zero m t
    simpa [hm, ρ, m, hqdef, hc_odd] using hmod

private theorem deepLiftResidue_mod_zero (j : Nat) :
    deepBranchPoly (deepLiftResidue j) % deepLiftModulus j = 0 := by
  induction j with
  | zero =>
    simp [deepLiftResidue, deepLiftModulus, deepBranchPoly, deepBranchConstant]
  | succ j ih =>
    exact deepLiftResidue_spec_succ j ih

/-- H1: Generator-Lösung für beliebiges `j` — Bound plus `2^j ∣ 243·ρ_j + 95` (Induktion). -/
theorem deepLiftResidue_spec (j : Nat) :
    deepLiftResidue j < deepLiftModulus j ∧
      deepLiftModulus j ∣ deepBranchPoly (deepLiftResidue j) := by
  refine ⟨deepLiftResidue_lt j, ?_⟩
  rw [Nat.dvd_iff_mod_eq_zero]
  exact deepLiftResidue_mod_zero j

theorem deepLiftResidue_one : deepLiftResidue 1 = 1 := by decide
theorem deepLiftResidue_two : deepLiftResidue 2 = 3 := by decide
theorem deepLiftResidue_three : deepLiftResidue 3 = 3 := by decide
theorem deepLiftResidue_four : deepLiftResidue 4 = 11 := by decide
theorem deepLiftResidue_five : deepLiftResidue 5 = 27 := by decide

/-- Plateau-Beispiel: `ρ_5 = … = ρ_9 = 27`; hier `ν_2(243·27 + 95) = 9 ≠ 5`. -/
theorem deepLiftResidue_five_nu2 :
    padicValNat 2 (deepBranchPoly (deepLiftResidue 5)) = 9 := by
  rw [deepLiftResidue_five, deepBranchPoly_eq]
  have hnum : 243 * 27 + 95 = 6656 := by decide
  rw [hnum]
  have hn : (6656 : Nat) ≠ 0 := by decide
  have h9 : 2 ^ 9 ∣ 6656 := by decide
  have hnot10 : ¬ 2 ^ 10 ∣ 6656 := by decide
  have hle9 : 9 ≤ padicValNat 2 6656 :=
    (padicValNat_dvd_iff_le (p := 2) (a := 6656) hn).1 h9
  have hnot10le : ¬ 10 ≤ padicValNat 2 6656 := by
    intro h10
    exact hnot10 ((padicValNat_dvd_iff_le (p := 2) (a := 6656) hn).2 h10)
  omega

theorem deepLiftResidue_six : deepLiftResidue 6 = 27 := by decide
theorem deepLiftResidue_seven : deepLiftResidue 7 = 27 := by decide
theorem deepLiftResidue_eight : deepLiftResidue 8 = 27 := by decide
theorem deepLiftResidue_nine : deepLiftResidue 9 = 27 := by decide

theorem deepLiftConstant_one : deepLiftConstant 1 = 169 := by decide
theorem deepLiftConstant_two : deepLiftConstant 2 = 206 := by decide
theorem deepLiftConstant_three : deepLiftConstant 3 = 103 := by decide
theorem deepLiftConstant_four : deepLiftConstant 4 = 173 := by decide
theorem deepLiftConstant_five : deepLiftConstant 5 = 208 := by decide

theorem deepLiftResidue_spec_one :
    deepBranchPoly (deepLiftResidue 1) % deepLiftModulus 1 = 0 := by decide

theorem deepLiftResidue_spec_two :
    deepBranchPoly (deepLiftResidue 2) % deepLiftModulus 2 = 0 := by decide

theorem deepLiftResidue_spec_three :
    deepBranchPoly (deepLiftResidue 3) % deepLiftModulus 3 = 0 := by decide

theorem deepLiftResidue_spec_four :
    deepBranchPoly (deepLiftResidue 4) % deepLiftModulus 4 = 0 := by decide

theorem deepLiftResidue_spec_five :
    deepBranchPoly (deepLiftResidue 5) % deepLiftModulus 5 = 0 := by decide

theorem deepLiftResidue_succ_compat_one :
    deepLiftResidue 2 % deepLiftModulus 1 = deepLiftResidue 1 := by decide

theorem deepLiftResidue_succ_compat_two :
    deepLiftResidue 3 % deepLiftModulus 2 = deepLiftResidue 2 := by decide

theorem deepLiftResidue_succ_compat_three :
    deepLiftResidue 4 % deepLiftModulus 3 = deepLiftResidue 3 := by decide

theorem deepLiftResidue_succ_compat_four :
    deepLiftResidue 5 % deepLiftModulus 4 = deepLiftResidue 4 := by decide

/-!
## Eindeutigkeit der Lift-Restklasse (Ebene A)
-/

private theorem deepLiftResidue_unique_of_lt {j r₁ r₂ : Nat}
    (hr₁ : r₁ < deepLiftModulus j) (hr₂ : r₂ < deepLiftModulus j)
    (hs₁ : deepBranchPoly r₁ % deepLiftModulus j = 0)
    (hs₂ : deepBranchPoly r₂ % deepLiftModulus j = 0) :
    r₁ = r₂ := by
  have h₁ : deepBranchPoly r₁ ≡ 0 [MOD deepLiftModulus j] := by
    rwa [Nat.ModEq]
  have h₂ : deepBranchPoly r₂ ≡ 0 [MOD deepLiftModulus j] := by
    rwa [Nat.ModEq]
  have hmul :
      deepBranchMultiplier * r₁ ≡ deepBranchMultiplier * r₂ [MOD deepLiftModulus j] := by
    simpa [deepBranchPoly] using
      Nat.ModEq.add_right_cancel' deepBranchConstant (h₁.trans h₂.symm)
  have hr : r₁ ≡ r₂ [MOD deepLiftModulus j] :=
    Nat.ModEq.cancel_left_of_coprime
      (by
        rw [Nat.gcd_comm]
        exact Nat.Coprime.gcd_eq_one (deepBranchMultiplier_coprime_pow_two j))
      hmul
  have hmod : r₁ % deepLiftModulus j = r₂ % deepLiftModulus j := hr
  rw [Nat.mod_eq_of_lt hr₁, Nat.mod_eq_of_lt hr₂] at hmod
  exact hmod

def DeepLiftResidueUnique (j : Nat) : Prop :=
  ∃! r : Nat, r < deepLiftModulus j ∧ deepBranchPoly r % deepLiftModulus j = 0

theorem existsUnique_deepLiftResidue_of_lt {j r : Nat}
    (hr : r < deepLiftModulus j)
    (hspec : deepBranchPoly r % deepLiftModulus j = 0) :
    DeepLiftResidueUnique j := by
  refine ⟨r, ⟨hr, hspec⟩, ?_⟩
  intro r' ⟨hr', hspec'⟩
  exact deepLiftResidue_unique_of_lt hr' hr hspec' hspec

/-- H1: Eindeutigkeit der Lift-Restklasse für beliebiges `j` (aus `deepLiftResidue_spec`). -/
theorem existsUnique_deepLiftResidue (j : Nat) : DeepLiftResidueUnique j := by
  refine ⟨deepLiftResidue j, ⟨deepLiftResidue_lt j, ?_⟩, ?_⟩
  · exact deepLiftResidue_mod_zero j
  intro r ⟨hr, hspec⟩
  exact deepLiftResidue_unique_of_lt hr (deepLiftResidue_lt j) hspec (deepLiftResidue_mod_zero j)

/-- Eindeutigkeit: die einzige Lösung `< 2^j` der Kongruenz ist `ρ_j`. -/
theorem deepLiftResidue_unique {j r : Nat}
    (hr : r < deepLiftModulus j)
    (hdvd : deepLiftModulus j ∣ deepBranchPoly r) :
    r = deepLiftResidue j :=
  deepLiftResidue_unique_of_lt hr (deepLiftResidue_lt j)
    (Nat.mod_eq_zero_of_dvd hdvd) (deepLiftResidue_mod_zero j)

private theorem deepBranchPoly_mod_eq_residue (j r : Nat) :
    deepBranchPoly r % deepLiftModulus j =
      deepBranchPoly (r % deepLiftModulus j) % deepLiftModulus j := by
  set m := deepLiftModulus j
  have h := (Nat.mod_modEq r m).mul_left deepBranchMultiplier |>.add_right deepBranchConstant
  exact h.symm

private theorem deepBranchPoly_mod_zero_of_residue_mod (j r : Nat)
    (hmod : r % deepLiftModulus j = deepLiftResidue j) :
    deepBranchPoly r % deepLiftModulus j = 0 := by
  rw [deepBranchPoly_mod_eq_residue]
  rw [hmod]
  exact deepLiftResidue_mod_zero j

/-- Kongruenzcharakterisierung: `2^j ∣ 243r + 95` iff Restklasse `ρ_j`. -/
theorem deepLiftResidue_iff (j r : Nat) :
    deepLiftModulus j ∣ deepBranchPoly r ↔ r % deepLiftModulus j = deepLiftResidue j := by
  constructor
  · intro hdvd
    set d := r % deepLiftModulus j
    have hdlt : d < deepLiftModulus j := Nat.mod_lt r (deepLiftModulus_pos j)
    have hzero : deepBranchPoly d % deepLiftModulus j = 0 := by
      rw [← deepBranchPoly_mod_eq_residue]
      exact Nat.mod_eq_zero_of_dvd hdvd
    exact deepLiftResidue_unique_of_lt hdlt (deepLiftResidue_lt j) hzero
      (deepLiftResidue_mod_zero j)
  · intro hmod
    rw [Nat.dvd_iff_mod_eq_zero]
    exact deepBranchPoly_mod_zero_of_residue_mod j r hmod

/-- Schwache Bewertungsuntergrenze am Generator: `j ≤ ν_2(243·ρ_j + 95)` (nicht Gleichheit). -/
theorem deepLiftResidue_val_ge (j : Nat) :
    j ≤ padicValNat 2 (deepBranchPoly (deepLiftResidue j)) := by
  rcases j with - | j
  · simp [deepLiftResidue, deepLiftModulus, deepBranchPoly, deepBranchConstant,
      deepBranchMultiplier]
  · have hne : deepBranchPoly (deepLiftResidue (j + 1)) ≠ 0 := by
      unfold deepBranchPoly deepBranchMultiplier deepBranchConstant
      have := deepLiftResidue_lt (j + 1)
      omega
    have hdvd := (deepLiftResidue_spec (j + 1)).2
    exact (padicValNat_dvd_iff_le (p := 2)
      (a := deepBranchPoly (deepLiftResidue (j + 1))) hne).1 hdvd

theorem existsUnique_deepLiftResidue_one : DeepLiftResidueUnique 1 := by
  refine ⟨1, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 1 = 2 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 1 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_two : DeepLiftResidueUnique 2 := by
  refine ⟨3, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 2 = 4 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 3 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_three : DeepLiftResidueUnique 3 := by
  refine ⟨3, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 3 = 8 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 7 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_four : DeepLiftResidueUnique 4 := by
  refine ⟨11, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 4 = 16 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 15 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

theorem existsUnique_deepLiftResidue_five : DeepLiftResidueUnique 5 := by
  refine ⟨27, ⟨by decide, by decide⟩, ?_⟩
  intro r ⟨hr, hspec⟩
  have hm : deepLiftModulus 5 = 32 := by decide
  rw [hm] at hr hspec
  have hr' : r ≤ 31 := by omega
  interval_cases r <;> simp_all (config := {decide := true})

/-!
## Bewertungscharakterisierung und affine Terminalform (Ebene A — Ziele)

Korrekte Zielaussagen (keine falsche Identität `ν_2 = j` am Generator):

- `ν_2(243r + 95) ≥ j` ↔ `r ≡ ρ_j (mod 2^j)` (`nu2_deepBranch_ge_iff`)
- `ν_2(243r + 95) = j` ↔ `r ≡ ρ_j (mod 2^j)` und `r ≢ ρ_{j+1} (mod 2^{j+1})`
  (`nu2_deepBranch_eq_iff`)

Plateau-Beispiel: `ρ_5 = 27`, aber `ν_2(243·27 + 95) = ν_2(6656) = 9`.
-/

/-- H2-Ziel: Bewertungsuntergrenze. Noch offen für allgemeines `j`. -/
theorem nu2_deepBranch_ge_iff (j r : Nat) :
    j ≤ padicValNat 2 (deepBranchPoly r) ↔
      r % deepLiftModulus j = deepLiftResidue j := by
  sorry

/-- H2-Ziel: exakte Bewertungsschale (mit Plateau-Ausschluss). Noch offen. -/
theorem nu2_deepBranch_eq_iff (j r : Nat) :
    padicValNat 2 (deepBranchPoly r) = j ↔
      r % deepLiftModulus j = deepLiftResidue j ∧
        r % deepLiftModulus (j + 1) ≠ deepLiftResidue (j + 1) := by
  sorry

/-- H4-Ziel: affine Terminalform bei `r = ρ_j + 2^j t`. Noch offen für allgemeines `j`. -/
theorem deepLift_terminal_affine (j t : Nat) :
    deepBranchPoly (deepLiftResidue j + deepLiftModulus j * t) =
      deepLiftModulus j * (deepBranchMultiplier * t + deepLiftConstant j) := by
  sorry

theorem channelSeven71_step5_certificate_link (r : Nat) :
    3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * deepBranchPoly r :=
  channelSeven71_step5_certificate_mod4_one r

/-- Scaffold-Status: Generator + Ebene-A-Kern + verifizierte Anfangs-Schalen (`j ≤ 5`). -/
structure ChannelSevenDeepLiftScaffold : Prop where
  multiplier_invertible :
    ∀ j : Nat, Nat.Coprime deepBranchMultiplier (deepLiftModulus j)
  generator_values :
    deepLiftResidue 1 = 1 ∧
      deepLiftResidue 2 = 3 ∧
        deepLiftResidue 3 = 3 ∧
          deepLiftResidue 4 = 11 ∧
            deepLiftResidue 5 = 27
  constant_values :
    deepLiftConstant 1 = 169 ∧
      deepLiftConstant 2 = 206 ∧
        deepLiftConstant 3 = 103 ∧
          deepLiftConstant 4 = 173 ∧
            deepLiftConstant 5 = 208
  residue_specs :
    deepBranchPoly (deepLiftResidue 1) % deepLiftModulus 1 = 0 ∧
      deepBranchPoly (deepLiftResidue 2) % deepLiftModulus 2 = 0 ∧
        deepBranchPoly (deepLiftResidue 3) % deepLiftModulus 3 = 0 ∧
          deepBranchPoly (deepLiftResidue 4) % deepLiftModulus 4 = 0 ∧
            deepBranchPoly (deepLiftResidue 5) % deepLiftModulus 5 = 0
  compat_samples :
    deepLiftResidue 2 % deepLiftModulus 1 = deepLiftResidue 1 ∧
      deepLiftResidue 3 % deepLiftModulus 2 = deepLiftResidue 2 ∧
        deepLiftResidue 4 % deepLiftModulus 3 = deepLiftResidue 3 ∧
          deepLiftResidue 5 % deepLiftModulus 4 = deepLiftResidue 4
  existsUnique_samples :
    DeepLiftResidueUnique 1 ∧
      DeepLiftResidueUnique 2 ∧
        DeepLiftResidueUnique 3 ∧
          DeepLiftResidueUnique 4 ∧
            DeepLiftResidueUnique 5
  step5_certificate :
    ∀ r : Nat, 3 * (162 * (4 * r + 1) + 91) + 1 = 2 ^ 3 * deepBranchPoly r

theorem channel_seven_deep_lift_scaffold : ChannelSevenDeepLiftScaffold where
  multiplier_invertible := deepBranchMultiplier_coprime_pow_two
  generator_values := ⟨deepLiftResidue_one, deepLiftResidue_two, deepLiftResidue_three,
    deepLiftResidue_four, deepLiftResidue_five⟩
  constant_values := ⟨deepLiftConstant_one, deepLiftConstant_two, deepLiftConstant_three,
    deepLiftConstant_four, deepLiftConstant_five⟩
  residue_specs := ⟨deepLiftResidue_spec_one, deepLiftResidue_spec_two, deepLiftResidue_spec_three,
    deepLiftResidue_spec_four, deepLiftResidue_spec_five⟩
  compat_samples := ⟨deepLiftResidue_succ_compat_one, deepLiftResidue_succ_compat_two,
    deepLiftResidue_succ_compat_three, deepLiftResidue_succ_compat_four⟩
  existsUnique_samples := ⟨
    existsUnique_deepLiftResidue_one,
    existsUnique_deepLiftResidue_two,
    existsUnique_deepLiftResidue_three,
    existsUnique_deepLiftResidue_four,
    existsUnique_deepLiftResidue_five⟩
  step5_certificate := channelSeven71_step5_certificate_link

end KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
