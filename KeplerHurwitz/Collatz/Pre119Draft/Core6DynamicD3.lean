import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Data.ZMod.Basic
import Mathlib.Tactic.IntervalCases
import KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
import KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
import KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase

set_option linter.style.nativeDecide false
set_option autoImplicit false

/-!
# Pre119Draft — Core6DynamicD3 (Follow-up after D2b freeze)

**Base:** PR #17 / `Core6DynamicFeedIn` (D2b frozen at `18e8747`).
**This module** develops D3.0–D3.2 algebraic structure; D3.3–D4 remain `[C]`.

Must not reopen PR #16 static math or the frozen D2b package.
No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3

open Set
open KeplerHurwitz.Collatz.Pre119Draft.CanonicalBase
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics

open KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn

/-! ### D3.0 — semantic one-block trichotomy -/

/-- Starts whose one-block image lands back in an expanding Core6 channel. -/
def oneBlockExpandingReturnSet (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∈ expandingCore6}

/-- Starts whose one-block image leaves the entire Core6 cylinder. -/
def oneBlockOffCore6Set (e₀ : Nat) : Set Nat :=
  {n | n ∈ canonicalCylinder e₀ ∧
    realizedImage n (fiberE e₀) ∉ core6Cylinder}

/--
`[C→A]` After one full `fiberE e₀` block, every start in `C_{e₀}` falls into
exactly one of: contracting hit / expanding return / off-Core6 exit.
-/
theorem canonicalCylinder_eq_oneBlock_trichotomy {e₀ : Nat} (_he₀ : 1 ≤ e₀) :
    canonicalCylinder e₀ =
      oneBlockFeedInSet e₀ ∪
        oneBlockExpandingReturnSet e₀ ∪
          oneBlockOffCore6Set e₀ := by
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have hcore_eq : core6Cylinder = expandingCore6 ∪ contractingCore6 := hphase.1
  ext n
  constructor
  · intro hnC
    set img := realizedImage n (fiberE e₀)
    by_cases hcon : img ∈ contractingCore6
    · left; left
      exact ⟨hnC, by simpa [contractingMass] using hcon⟩
    · by_cases hexp : img ∈ expandingCore6
      · left; right
        exact ⟨hnC, hexp⟩
      · right
        refine ⟨hnC, ?_⟩
        intro hcore
        have : img ∈ expandingCore6 ∪ contractingCore6 := by
          rwa [← hcore_eq]
        exact Or.elim this hexp hcon
  · intro hn
    exact hn.elim (fun h => h.elim (fun hF => hF.1) (fun hE => hE.1))
      (fun hO => hO.1)

theorem oneBlockFeedIn_disjoint_expandingReturn (e₀ : Nat) :
    Disjoint (oneBlockFeedInSet e₀) (oneBlockExpandingReturnSet e₀) := by
  refine disjoint_left.2 ?_
  intro n hF hE
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have himgF : realizedImage n (fiberE e₀) ∈ contractingCore6 := by
    simpa [contractingMass] using hF.2
  exact (disjoint_left.1 hphase.2) hE.2 himgF

theorem oneBlockFeedIn_disjoint_offCore6 (e₀ : Nat) :
    Disjoint (oneBlockFeedInSet e₀) (oneBlockOffCore6Set e₀) := by
  refine disjoint_left.2 ?_
  intro n hF hO
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have himg : realizedImage n (fiberE e₀) ∈ contractingCore6 := by
    simpa [contractingMass] using hF.2
  have hcore : realizedImage n (fiberE e₀) ∈ core6Cylinder := by
    rw [hphase.1]; exact Or.inr himg
  exact hO.2 hcore

theorem oneBlockExpandingReturn_disjoint_offCore6 (e₀ : Nat) :
    Disjoint (oneBlockExpandingReturnSet e₀) (oneBlockOffCore6Set e₀) := by
  refine disjoint_left.2 ?_
  intro n hE hO
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  have hcore : realizedImage n (fiberE e₀) ∈ core6Cylinder := by
    rw [hphase.1]; exact Or.inl hE.2
  exact hO.2 hcore

/-- Expanding return is the union of progressions into `C_1,C_2,C_3`. -/
theorem oneBlockExpandingReturnSet_eq_iUnion_progressions {e₀ : Nat}
    (he₀ : 1 ≤ e₀) :
    oneBlockExpandingReturnSet e₀ =
      ⋃ f : Nat, ⋃ (_ : 1 ≤ f ∧ f ≤ 3), oneBlockTargetProgression e₀ f := by
  ext n
  constructor
  · intro hn
    obtain ⟨hnC, himg⟩ := hn
    have himg' :
        realizedImage n (fiberE e₀) ∈ canonicalCylinder 1 ∨
          realizedImage n (fiberE e₀) ∈ canonicalCylinder 2 ∨
            realizedImage n (fiberE e₀) ∈ canonicalCylinder 3 := by
      simpa [expandingCore6, smallTailCore6, or_assoc] using himg
    rcases himg' with h1 | h2 | h3
    · exact mem_iUnion.2
        ⟨1, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h1⟩⟩⟩
    · exact mem_iUnion.2
        ⟨2, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h2⟩⟩⟩
    · exact mem_iUnion.2
        ⟨3, mem_iUnion.2 ⟨⟨by decide, by decide⟩,
          (mem_oneBlockTargetProgression_iff he₀ (by decide)).2 ⟨hnC, h3⟩⟩⟩
  · intro hn
    obtain ⟨f, hf'⟩ := mem_iUnion.1 hn
    obtain ⟨hfg, hP⟩ := mem_iUnion.1 hf'
    obtain ⟨hf1, hf3⟩ := hfg
    have hmem := (mem_oneBlockTargetProgression_iff he₀ hf1).1 hP
    refine ⟨hmem.1, ?_⟩
    have himg : realizedImage n (fiberE e₀) ∈ canonicalCylinder f := hmem.2
    have : f = 1 ∨ f = 2 ∨ f = 3 := by omega
    rcases this with rfl | rfl | rfl
    · exact Or.inl (Or.inl himg)
    · exact Or.inl (Or.inr himg)
    · exact Or.inr himg

/-- Witness: `31` exits Core6 after one block (`image = 137`). -/
theorem mem_oneBlockOffCore6Set_one_31 : 31 ∈ oneBlockOffCore6Set 1 := by
  refine ⟨mem_canonicalCylinder_one_31, ?_⟩
  intro hcore
  have : RealizesWord core6 137 := by
    change 137 ∈ core6Cylinder
    simpa [realizedImage_fiberE_one_31] using hcore
  exact not_realizes_core6_137 this

theorem oneBlockOffCore6Set_one_nonempty : (oneBlockOffCore6Set 1).Nonempty :=
  ⟨31, mem_oneBlockOffCore6Set_one_31⟩

/-! ### D3.1 — affine target-index transport -/

theorem exists_unique_oneBlockTargetBaseIndex {e₀ f : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    ∃! j : Nat,
      fiberIndexMap f j =
        realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) := by
  set img :=
    realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀)
  have himgC : img ∈ canonicalCylinder f :=
    (fiberIndexImage_mem_target_iff_index_modEq he₀ hf).2 (Nat.ModEq.refl _)
  obtain ⟨j, hj⟩ := exists_fiberIndex_of_mem_cylinder himgC
  refine ExistsUnique.intro j hj.symm ?_
  intro j' hj'
  exact fiberIndexMap_injective f (hj'.trans hj)

/--
Unique target index `λ(e₀,f)` of the canonical one-block landing
`Φ_{e₀}(κ(e₀,f)) ↦ Φ_f(λ)`.
-/
noncomputable def oneBlockTargetBaseIndex
    (e₀ f : Nat) (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) : Nat :=
  Classical.choose (ExistsUnique.exists (exists_unique_oneBlockTargetBaseIndex he₀ hf))

theorem oneBlockTargetBaseIndex_spec {e₀ f : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) =
      realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) :=
  Classical.choose_spec
    (ExistsUnique.exists (exists_unique_oneBlockTargetBaseIndex he₀ hf))

theorem fiberIndexMap_add (e j t : Nat) :
    fiberIndexMap e (j + t) = fiberIndexMap e j + t * seedModulus e := by
  simp [fiberIndexMap]; ring

theorem oneBlock_step_scale (f : Nat) :
    (4374 : Nat) * oneBlockIndexModulus f = coeff3 * seedModulus f := by
  have h4374 : (4374 : Nat) = 2 * coeff3 := by
    simp only [coeff3_eq_three_pow]; native_decide
  rw [h4374, seedModulus_eq_two_mul_indexModulus f]
  ring

/--
`[C→A]` Affine target-index transport:
source index `κ + r·2^{f+8}` maps to target index `λ + 2187·r`.
-/
theorem oneBlock_targetIndex_affine {e₀ f r : Nat}
    (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    realizedImage
        (fiberIndexMap e₀
          (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
        (fiberE e₀) =
      fiberIndexMap f
        (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r) := by
  have hbase := oneBlockTargetBaseIndex_spec he₀ hf
  have himg :=
    realizedImage_fiberIndexMap_coeff he₀
      (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f)
  have himg0 :=
    realizedImage_fiberIndexMap_coeff he₀ (oneBlockIndexClass e₀ f)
  have hsum :
      realizedImage
          (fiberIndexMap e₀
            (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
          (fiberE e₀) =
        realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) +
          4374 * r * oneBlockIndexModulus f := by
    rw [himg, himg0]; ring
  have hscale := oneBlock_step_scale f
  calc
    realizedImage
        (fiberIndexMap e₀
          (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
        (fiberE e₀)
        = realizedImage (fiberIndexMap e₀ (oneBlockIndexClass e₀ f)) (fiberE e₀) +
            4374 * r * oneBlockIndexModulus f := hsum
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            r * (4374 * oneBlockIndexModulus f) := by
          rw [hbase]; ring
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            r * (coeff3 * seedModulus f) := by rw [hscale]
    _ = fiberIndexMap f (oneBlockTargetBaseIndex e₀ f he₀ hf) +
            (coeff3 * r) * seedModulus f := by ring
    _ = fiberIndexMap f
          (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r) := by
          symm; exact fiberIndexMap_add _ _ _


/-! ### D3.2 — finite channel paths

For a **fixed** finite path, realization is arithmetic in the source fiber index.
Length-2 paths recover the D2b progressions. The residual/`coeff3` mechanism is the
composition engine for longer fixed paths. Universality over starts remains `[C]`.
-/

/-- Successive full-block channel membership along `es`. -/
def RealizesChannelPath : List Nat → Nat → Prop
  | [], _ => False
  | [e], n => n ∈ canonicalCylinder e
  | e :: f :: rest, n =>
      n ∈ canonicalCylinder e ∧
        RealizesChannelPath (f :: rest) (realizedImage n (fiberE e))

/-- Every channel label on the path is at least `1`. -/
def ChannelPathLabelsValid (es : List Nat) : Prop :=
  ∀ e ∈ es, 1 ≤ e

/--
Index modulus of a path: product of one-block moduli of the **target** labels.
Singleton paths have modulus `1`.
-/
def channelPathIndexModulus : List Nat → Nat
  | [] | [_] => 1
  | _ :: f :: rest =>
      oneBlockIndexModulus f * channelPathIndexModulus (f :: rest)

theorem channelPathIndexModulus_pos (es : List Nat) :
    0 < channelPathIndexModulus es := by
  match es with
  | [] => exact Nat.one_pos
  | [_] => exact Nat.one_pos
  | _ :: f :: rest =>
    exact Nat.mul_pos (oneBlockIndexModulus_pos f)
      (channelPathIndexModulus_pos (f :: rest))

instance channelPathIndexModulus.instNeZero (es : List Nat) :
    NeZero (channelPathIndexModulus es) :=
  ⟨Nat.pos_iff_ne_zero.mp (channelPathIndexModulus_pos es)⟩

theorem coeff3_coprime_channelPathIndexModulus (es : List Nat) :
    Nat.Coprime coeff3 (channelPathIndexModulus es) := by
  match es with
  | [] => exact Nat.coprime_one_right _
  | [_] => exact Nat.coprime_one_right _
  | _ :: f :: rest =>
    exact (coeff3_coprime_oneBlockIndexModulus f).mul_right
      (coeff3_coprime_channelPathIndexModulus (f :: rest))

private theorem isUnit_coeff3_path (es : List Nat) :
    IsUnit ((coeff3 : ZMod (channelPathIndexModulus es))) :=
  (ZMod.isUnit_iff_coprime coeff3 (channelPathIndexModulus es)).2
    (coeff3_coprime_channelPathIndexModulus es)

/-- Unit of `3^7` in the path index modulus ring. -/
noncomputable def coeff3UnitPath (es : List Nat) :
    (ZMod (channelPathIndexModulus es))ˣ :=
  (isUnit_coeff3_path es).unit

theorem coeff3UnitPath_coe (es : List Nat) :
    (coeff3UnitPath es : ZMod (channelPathIndexModulus es)) = coeff3 :=
  IsUnit.unit_spec (isUnit_coeff3_path es)

theorem channelPathIndexModulus_singleton (e : Nat) :
    channelPathIndexModulus [e] = 1 :=
  rfl

theorem channelPathIndexModulus_cons (e f : Nat) (rest : List Nat) :
    channelPathIndexModulus (e :: f :: rest) =
      oneBlockIndexModulus f * channelPathIndexModulus (f :: rest) :=
  rfl

theorem channelPathIndexModulus_two (e f : Nat) :
    channelPathIndexModulus [e, f] = oneBlockIndexModulus f := by
  rw [channelPathIndexModulus_cons, channelPathIndexModulus_singleton, mul_one]

/--
Canonical source-index class `κ(es)` for a fixed channel path.
Recurses via one-block `κ` and affine target base indices.
-/
noncomputable def channelPathIndexClass : List Nat → Nat
  | [] | [_] => 0
  | e :: f :: rest =>
    if h : 1 ≤ e ∧ 1 ≤ f then
      let es' := f :: rest
      let Mf := oneBlockIndexModulus f
      let κ1 := oneBlockIndexClass e f
      let baseIdx := oneBlockTargetBaseIndex e f h.1 h.2
      let κrest := channelPathIndexClass es'
      let ρ :=
        ((↑(coeff3UnitPath es')⁻¹ : ZMod (channelPathIndexModulus es')) *
            ((κrest : ZMod (channelPathIndexModulus es')) -
              (baseIdx : ZMod (channelPathIndexModulus es')))).val
      κ1 + ρ * Mf
    else 0

/-- Residual `ρ` refining the next-hop congruence after the first block. -/
noncomputable def channelPathResidual (e f : Nat) (rest : List Nat)
    (he : 1 ≤ e) (hf : 1 ≤ f) : Nat :=
  let es' := f :: rest
  let baseIdx := oneBlockTargetBaseIndex e f he hf
  let κrest := channelPathIndexClass es'
  ((↑(coeff3UnitPath es')⁻¹ : ZMod (channelPathIndexModulus es')) *
      ((κrest : ZMod (channelPathIndexModulus es')) -
        (baseIdx : ZMod (channelPathIndexModulus es')))).val

theorem channelPathIndexClass_cons {e f : Nat} {rest : List Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) :
    channelPathIndexClass (e :: f :: rest) =
      oneBlockIndexClass e f +
        channelPathResidual e f rest he hf * oneBlockIndexModulus f := by
  simp only [channelPathIndexClass, channelPathResidual, he, hf, and_self,
    ↓reduceDIte]

theorem channelPathResidual_lt {e f : Nat} {rest : List Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) :
    channelPathResidual e f rest he hf < channelPathIndexModulus (f :: rest) :=
  ZMod.val_lt _

theorem channelPathResidual_spec {e f : Nat} {rest : List Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) :
    (coeff3 : ZMod (channelPathIndexModulus (f :: rest))) *
        (channelPathResidual e f rest he hf :
          ZMod (channelPathIndexModulus (f :: rest))) =
      (channelPathIndexClass (f :: rest) :
          ZMod (channelPathIndexModulus (f :: rest))) -
        (oneBlockTargetBaseIndex e f he hf :
          ZMod (channelPathIndexModulus (f :: rest))) := by
  simp only [channelPathResidual]
  rw [ZMod.natCast_zmod_val, ← coeff3UnitPath_coe (f :: rest), ← mul_assoc,
    Units.mul_inv, one_mul]

/-- Length-2 class recovers the one-block κ-class. -/
theorem channelPathIndexClass_two {e f : Nat} (he : 1 ≤ e) (hf : 1 ≤ f) :
    channelPathIndexClass [e, f] = oneBlockIndexClass e f := by
  have h := channelPathIndexClass_cons (rest := []) he hf
  have hρ : channelPathResidual e f [] he hf = 0 := by
    have hlt := channelPathResidual_lt (rest := []) he hf
    simp only [channelPathIndexModulus_singleton] at hlt
    exact Nat.lt_one_iff.mp hlt
  simpa [hρ] using h

/-- Parametrization of the path progression in the source fiber. -/
noncomputable def channelPathIndexMap (es : List Nat) (r : Nat) : Nat :=
  match es with
  | [] => 0
  | e :: _ =>
      fiberIndexMap e
        (channelPathIndexClass es + r * channelPathIndexModulus es)

/-- Arithmetic progression of starts realizing a fixed channel path. -/
noncomputable def channelPathProgression (es : List Nat) : Set Nat :=
  {n | ∃ r : Nat, n = channelPathIndexMap es r}

/-- Length-2 path progression coincides with the one-block target progression. -/
theorem channelPathProgression_two_eq_oneBlock
    {e₀ f : Nat} (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    channelPathProgression [e₀, f] = oneBlockTargetProgression e₀ f := by
  ext n
  constructor
  · intro hn
    obtain ⟨r, rfl⟩ := hn
    exact ⟨r, by
      simp only [channelPathIndexMap, channelPathIndexClass_two he₀ hf,
        channelPathIndexModulus_two]⟩
  · intro hn
    obtain ⟨r, rfl⟩ := hn
    exact ⟨r, by
      simp only [channelPathIndexMap, channelPathIndexClass_two he₀ hf,
        channelPathIndexModulus_two]⟩

/--
`[C→A]` For a fixed length-2 path, realization ⇔ membership in the path AP.
-/
theorem realizesChannelPath_two_iff_mem_progression
    {e₀ f n : Nat} (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    RealizesChannelPath [e₀, f] n ↔ n ∈ channelPathProgression [e₀, f] := by
  rw [channelPathProgression_two_eq_oneBlock he₀ hf]
  exact (mem_oneBlockTargetProgression_iff he₀ hf).symm

/--
`[C→A]` Source index realizes a fixed length-2 path iff it lies in κ-class.
-/
theorem realizesChannelPath_two_fiberIndex_iff
    {e₀ f k : Nat} (he₀ : 1 ≤ e₀) (hf : 1 ≤ f) :
    RealizesChannelPath [e₀, f] (fiberIndexMap e₀ k) ↔
      k ≡ channelPathIndexClass [e₀, f]
        [MOD channelPathIndexModulus [e₀, f]] := by
  rw [channelPathIndexClass_two he₀ hf, channelPathIndexModulus_two]
  constructor
  · intro h
    exact (fiberIndexImage_mem_target_iff_index_modEq he₀ hf).1 h.2
  · intro hk
    refine ⟨?_, (fiberIndexImage_mem_target_iff_index_modEq he₀ hf).2 hk⟩
    simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e₀ k

private theorem eq_add_mul_of_modEq {k κ M : Nat} (hκ : κ < M)
    (hk : k ≡ κ [MOD M]) :
    k = κ + (k / M) * M := by
  have hmod : k % M = κ := by
    have := hk
    rw [Nat.ModEq, Nat.mod_eq_of_lt hκ] at this
    exact this
  have h := (Nat.div_add_mod k M).symm
  rw [hmod] at h
  calc
    k = M * (k / M) + κ := h
    _ = κ + (k / M) * M := by ring

/--
Compose one extra hop: after the Cancel-by-2 congruence for `e → f`,
continuing along `f::rest` is path-realization on the affine target index.
-/
theorem realizesChannelPath_cons_fiberIndex_step
    {e f : Nat} {rest : List Nat} {k : Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f)
    (hk : k ≡ oneBlockIndexClass e f [MOD oneBlockIndexModulus f]) :
    let r := k / oneBlockIndexModulus f
    let j := oneBlockTargetBaseIndex e f he hf + coeff3 * r
    RealizesChannelPath (e :: f :: rest) (fiberIndexMap e k) ↔
      RealizesChannelPath (f :: rest) (fiberIndexMap f j) := by
  intro r j
  have hdecomp := eq_add_mul_of_modEq (oneBlockIndexClass_lt e f) hk
  have himg :
      realizedImage (fiberIndexMap e k) (fiberE e) = fiberIndexMap f j := by
    rw [hdecomp]
    simpa [r, j] using oneBlock_targetIndex_affine (r := r) he hf
  constructor
  · intro hR
    simpa [himg] using hR.2
  · intro htail
    refine ⟨?_, ?_⟩
    · simpa [← canonicalCylinder_eq_ap] using fiberIndexMap_mem e k
    · simpa [himg] using htail

/--
`[C→A]` The residual `ρ` satisfies
`baseIdx + 2187·ρ ≡ κ(f::rest) (mod M(f::rest))`.
-/
theorem channelPathResidual_solves {e f : Nat} {rest : List Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) :
    oneBlockTargetBaseIndex e f he hf +
        coeff3 * channelPathResidual e f rest he hf ≡
      channelPathIndexClass (f :: rest)
        [MOD channelPathIndexModulus (f :: rest)] := by
  set es' := f :: rest
  set baseIdx := oneBlockTargetBaseIndex e f he hf
  set κrest := channelPathIndexClass es'
  set Mrest := channelPathIndexModulus es'
  set ρ := channelPathResidual e f rest he hf
  have hspec : (coeff3 : ZMod Mrest) * (ρ : ZMod Mrest) =
      (κrest : ZMod Mrest) - (baseIdx : ZMod Mrest) := by
    simpa [es', baseIdx, κrest, Mrest, ρ] using
      channelPathResidual_spec (rest := rest) he hf
  have hZ :
      (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (ρ : ZMod Mrest) =
        (κrest : ZMod Mrest) := by
    rw [hspec]; abel
  have hcast :
      ((baseIdx + coeff3 * ρ : Nat) : ZMod Mrest) =
        (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (ρ : ZMod Mrest) := by
    push_cast; rfl
  exact (ZMod.natCast_eq_natCast_iff _ _ _).1 (hcast.trans hZ)

/-- Concrete length-2 witness: path `1 → 4` via `n = 1246239`. -/
theorem realizesChannelPath_one_four_1246239 :
    RealizesChannelPath [1, 4] 1246239 := by
  refine ⟨?_, ?_⟩
  · simpa [← fiberIndexMap_one_1217, ← canonicalCylinder_eq_ap] using
      fiberIndexMap_mem 1 1217
  · rw [realizedImage_one_1246239]
    simpa [RealizesChannelPath] using mem_canonicalCylinder_four_5323295

theorem mem_channelPathProgression_one_four_1246239 :
    1246239 ∈ channelPathProgression [1, 4] :=
  (realizesChannelPath_two_iff_mem_progression (by decide) (by decide)).1
    realizesChannelPath_one_four_1246239

/-! ### D3.2 closure — general fixed-path AP equivalence

Iterated dyadic congruence lifting (not classical CRT): after each hop the next
condition is pulled back through `j = λ + 2187·r`, and oddness of `2187` yields
a unique residual class. Moduli multiply as `∏ 2^{eᵢ+8}`.
-/

theorem ChannelPathLabelsValid.head {e : Nat} {es : List Nat}
    (h : ChannelPathLabelsValid (e :: es)) : 1 ≤ e :=
  h e (List.mem_cons.2 (Or.inl rfl))

theorem ChannelPathLabelsValid.tail {e : Nat} {es : List Nat}
    (h : ChannelPathLabelsValid (e :: es)) : ChannelPathLabelsValid es :=
  fun x hx => h x (List.mem_cons.2 (Or.inr hx))

/--
`[C→A]` Canonical representative is strictly below the path modulus.
-/
theorem channelPathIndexClass_lt {es : List Nat}
    (hvalid : ChannelPathLabelsValid es) (hne : es ≠ []) :
    channelPathIndexClass es < channelPathIndexModulus es := by
  match es with
  | [] => exact (hne rfl).elim
  | [_] =>
    change (0 : Nat) < 1
    exact Nat.one_pos
  | e :: f :: rest =>
    have he : 1 ≤ e := hvalid.head
    have hf : 1 ≤ f := hvalid.tail.head
    rw [channelPathIndexClass_cons he hf, channelPathIndexModulus_cons]
    set κ1 := oneBlockIndexClass e f
    set ρ := channelPathResidual e f rest he hf
    set Mf := oneBlockIndexModulus f
    set Mrest := channelPathIndexModulus (f :: rest)
    have hκlt : κ1 < Mf := oneBlockIndexClass_lt e f
    have hρlt : ρ < Mrest := channelPathResidual_lt (rest := rest) he hf
    have hstrict : κ1 + ρ * Mf < Mf + ρ * Mf :=
      Nat.add_lt_add_right hκlt _
    have heq : Mf + ρ * Mf = Mf * (ρ + 1) := by ring
    have hle : Mf * (ρ + 1) ≤ Mf * Mrest :=
      Nat.mul_le_mul_left Mf (Nat.succ_le_of_lt hρlt)
    exact lt_of_lt_of_le (hstrict.trans_eq heq) hle

/--
`[C→A]` Residual cancellation: `λ + 2187·r ≡ κ_rest ↔ r ≡ ρ`,
using that `2187` is a unit modulo every path modulus.
-/
theorem channelPathResidual_iff {e f : Nat} {rest : List Nat} {r : Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f) :
    oneBlockTargetBaseIndex e f he hf + coeff3 * r ≡
        channelPathIndexClass (f :: rest)
          [MOD channelPathIndexModulus (f :: rest)] ↔
      r ≡ channelPathResidual e f rest he hf
        [MOD channelPathIndexModulus (f :: rest)] := by
  set es' := f :: rest
  set baseIdx := oneBlockTargetBaseIndex e f he hf
  set κrest := channelPathIndexClass es'
  set Mrest := channelPathIndexModulus es'
  set ρ := channelPathResidual e f rest he hf
  have hρspec : (coeff3 : ZMod Mrest) * (ρ : ZMod Mrest) =
      (κrest : ZMod Mrest) - (baseIdx : ZMod Mrest) := by
    simpa [es', baseIdx, κrest, Mrest, ρ] using
      channelPathResidual_spec (rest := rest) he hf
  constructor
  · intro hj
    have hZ : ((baseIdx + coeff3 * r : Nat) : ZMod Mrest) =
        (κrest : ZMod Mrest) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).2 hj
    have hcast :
        ((baseIdx + coeff3 * r : Nat) : ZMod Mrest) =
          (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (r : ZMod Mrest) := by
      push_cast; rfl
    have hr_mul : (coeff3 : ZMod Mrest) * (r : ZMod Mrest) =
        (κrest : ZMod Mrest) - (baseIdx : ZMod Mrest) := by
      have : (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (r : ZMod Mrest) =
          (κrest : ZMod Mrest) := by rwa [← hcast]
      simpa [add_sub_cancel_left] using
        congrArg (fun z : ZMod Mrest => z - (baseIdx : ZMod Mrest)) this
    have hcoeff : (coeff3 : ZMod Mrest) * (r : ZMod Mrest) =
        (coeff3 : ZMod Mrest) * (ρ : ZMod Mrest) := by
      rw [hr_mul, hρspec]
    have hinv :=
      congrArg (fun z : ZMod Mrest =>
        (↑(coeff3UnitPath es')⁻¹ : ZMod Mrest) * z) hcoeff
    have hrZ : (r : ZMod Mrest) = (ρ : ZMod Mrest) := by
      simpa [← coeff3UnitPath_coe es', ← mul_assoc, Units.inv_mul] using hinv
    exact (ZMod.natCast_eq_natCast_iff _ _ _).1 hrZ
  · intro hr
    have hrZ : (r : ZMod Mrest) = (ρ : ZMod Mrest) :=
      (ZMod.natCast_eq_natCast_iff _ _ _).2 hr
    have hjZ :
        (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (r : ZMod Mrest) =
          (κrest : ZMod Mrest) := by
      rw [hrZ, hρspec]; abel
    have hcast :
        ((baseIdx + coeff3 * r : Nat) : ZMod Mrest) =
          (baseIdx : ZMod Mrest) + (coeff3 : ZMod Mrest) * (r : ZMod Mrest) := by
      push_cast; rfl
    exact (ZMod.natCast_eq_natCast_iff _ _ _).1 (hcast.trans hjZ)

/--
Dyadic lifting compose: `r ≡ ρ [MOD N]` ⇒ `κ + r·M ≡ κ + ρ·M [MOD M·N]`.
-/
theorem modEq_compose_residue {κ r ρ M N : Nat}
    (hr : r ≡ ρ [MOD N]) :
    κ + r * M ≡ κ + ρ * M [MOD M * N] := by
  refine (Int.natCast_modEq_iff).1 ?_
  refine (Int.modEq_iff_dvd).2 ?_
  have hdiv : (N : ℤ) ∣ (ρ : ℤ) - r :=
    (Int.modEq_iff_dvd).1 ((Int.natCast_modEq_iff).2 hr)
  obtain ⟨t, ht⟩ := hdiv
  refine ⟨t, ?_⟩
  calc
    ((κ + ρ * M : Nat) : ℤ) - ↑(κ + r * M)
        = ((ρ : ℤ) - r) * M := by push_cast; ring
    _ = (N * t) * M := by rw [ht]
    _ = ↑(M * N) * t := by push_cast; ring

/--
Dyadic lifting decompose: from `k ≡ κ + ρ·M [MOD M·N]` with `κ < M`,
recover `k ≡ κ [MOD M]` and `k/M ≡ ρ [MOD N]`.
-/
theorem modEq_decompose_residue {k κ ρ M N : Nat}
    (hκ : κ < M)
    (hk : k ≡ κ + ρ * M [MOD M * N]) :
    k ≡ κ [MOD M] ∧ k / M ≡ ρ [MOD N] := by
  have hkM : k ≡ κ [MOD M] := by
    have h1 : k ≡ κ + ρ * M [MOD M] :=
      Nat.ModEq.of_dvd (Nat.dvd_mul_right M N) hk
    have h0 : κ + ρ * M ≡ κ [MOD M] := by
      have : ρ * M ≡ 0 [MOD M] := by
        rw [Nat.ModEq]; simp
      exact this.add_left κ
    exact h1.trans h0
  refine ⟨hkM, ?_⟩
  have hdecomp := eq_add_mul_of_modEq hκ hkM
  have hcongr : κ + (k / M) * M ≡ κ + ρ * M [MOD M * N] := by
    rwa [← hdecomp]
  have hmul : (k / M) * M ≡ ρ * M [MOD M * N] :=
    Nat.ModEq.add_left_cancel' κ hcongr
  have hM : 0 < M := Nat.zero_lt_of_lt hκ
  have hdiv : ↑(M * N) ∣ (↑(ρ * M) : ℤ) - ↑(k / M * M) :=
    (Int.modEq_iff_dvd).1 ((Int.natCast_modEq_iff).2 hmul)
  obtain ⟨t, ht⟩ := hdiv
  have hfactor : (ρ : ℤ) - ↑(k / M) = ↑N * t := by
    have hMne : (M : ℤ) ≠ 0 := by exact_mod_cast hM.ne'
    apply mul_left_cancel₀ hMne
    calc
      ↑M * ((ρ : ℤ) - ↑(k / M))
          = ↑(ρ * M) - ↑(k / M * M) := by push_cast; ring
      _ = ↑(M * N) * t := ht
      _ = ↑M * (↑N * t) := by push_cast; ring
  exact (Int.natCast_modEq_iff).1 ((Int.modEq_iff_dvd).2 ⟨t, hfactor⟩)

private theorem realizes_image_mem_first_target
    {e f : Nat} {rest : List Nat} {n : Nat}
    (hR : RealizesChannelPath (e :: f :: rest) n) :
    realizedImage n (fiberE e) ∈ canonicalCylinder f := by
  have htail := hR.2
  match rest with
  | [] =>
    simpa [RealizesChannelPath] using htail
  | _ :: _ =>
    exact htail.1

/--
`[C→A]` General fixed-path index characterization by induction on the tail:
`Φ_{e₀}(k)` realizes `e₀::rest` iff `k ≡ κ(e₀::rest) [MOD M(e₀::rest)]`.
-/
theorem realizesChannelPath_fiberIndex_iff
    {e₀ : Nat} {rest : List Nat} {k : Nat}
    (he₀ : 1 ≤ e₀) (hrest : ChannelPathLabelsValid rest) :
    RealizesChannelPath (e₀ :: rest) (fiberIndexMap e₀ k) ↔
      k ≡ channelPathIndexClass (e₀ :: rest)
        [MOD channelPathIndexModulus (e₀ :: rest)] := by
  revert k
  induction rest generalizing e₀ with
  | nil =>
    intro k
    constructor
    · intro _
      exact Nat.modEq_zero_iff_dvd.2 (Nat.one_dvd _)
    · intro _
      simpa [RealizesChannelPath, ← canonicalCylinder_eq_ap] using
        fiberIndexMap_mem e₀ k
  | cons f rest ih =>
    intro k
    have hf : 1 ≤ f := hrest.head
    have hrest' : ChannelPathLabelsValid rest := hrest.tail
    have hmod := channelPathIndexModulus_cons e₀ f rest
    have hclass := channelPathIndexClass_cons (rest := rest) he₀ hf
    set Mf := oneBlockIndexModulus f
    set es' := f :: rest
    set Mrest := channelPathIndexModulus es'
    set κ1 := oneBlockIndexClass e₀ f
    set baseIdx := oneBlockTargetBaseIndex e₀ f he₀ hf
    set κrest := channelPathIndexClass es'
    set ρ := channelPathResidual e₀ f rest he₀ hf
    have hκlt : κ1 < Mf := oneBlockIndexClass_lt e₀ f
    constructor
    · intro hR
      have himg_mem := realizes_image_mem_first_target hR
      have hkκ : k ≡ κ1 [MOD Mf] :=
        (fiberIndexImage_mem_target_iff_index_modEq he₀ hf).1 himg_mem
      set r := k / Mf
      have hstep :=
        realizesChannelPath_cons_fiberIndex_step (rest := rest) he₀ hf hkκ
      have htail :
          RealizesChannelPath es'
            (fiberIndexMap f (baseIdx + coeff3 * r)) :=
        hstep.1 hR
      have hj :=
        (ih (e₀ := f) hf hrest' (k := baseIdx + coeff3 * r)).1 htail
      have hrρ : r ≡ ρ [MOD Mrest] :=
        (channelPathResidual_iff (rest := rest) (r := r) he₀ hf).1
          (by simpa [baseIdx, κrest, Mrest, es'] using hj)
      have hdecomp : k = κ1 + r * Mf := eq_add_mul_of_modEq hκlt hkκ
      have hcomp : k ≡ κ1 + ρ * Mf [MOD Mf * Mrest] := by
        rw [hdecomp]
        exact modEq_compose_residue hrρ
      simpa [hmod, hclass, Mf, Mrest, κ1, ρ] using hcomp
    · intro hk
      have hk' : k ≡ κ1 + ρ * Mf [MOD Mf * Mrest] := by
        simpa [hmod, hclass, Mf, Mrest, κ1, ρ] using hk
      obtain ⟨hkκ, hrρ⟩ := modEq_decompose_residue hκlt hk'
      set r := k / Mf
      have hstep :=
        realizesChannelPath_cons_fiberIndex_step (rest := rest) he₀ hf hkκ
      have hj : baseIdx + coeff3 * r ≡ κrest [MOD Mrest] :=
        (channelPathResidual_iff (rest := rest) (r := r) he₀ hf).2
          (by simpa [r, ρ, Mrest] using hrρ)
      have htail :
          RealizesChannelPath es'
            (fiberIndexMap f (baseIdx + coeff3 * r)) :=
        (ih (e₀ := f) hf hrest' (k := baseIdx + coeff3 * r)).2
          (by simpa [baseIdx, κrest, Mrest, es'] using hj)
      exact hstep.2 htail

/--
`[C→A]` For every nonempty valid fixed path, realizers equal the path progression.
-/
theorem realizesChannelPath_iff_mem_progression
    {e₀ : Nat} {rest : List Nat} {n : Nat}
    (he₀ : 1 ≤ e₀) (hrest : ChannelPathLabelsValid rest) :
    RealizesChannelPath (e₀ :: rest) n ↔
      n ∈ channelPathProgression (e₀ :: rest) := by
  constructor
  · intro hR
    have hnC : n ∈ canonicalCylinder e₀ := by
      match rest with
      | [] => simpa [RealizesChannelPath] using hR
      | _ :: _ => exact hR.1
    obtain ⟨k, rfl⟩ := exists_fiberIndex_of_mem_cylinder hnC
    have hk := (realizesChannelPath_fiberIndex_iff he₀ hrest).1 hR
    set M := channelPathIndexModulus (e₀ :: rest)
    set κ := channelPathIndexClass (e₀ :: rest)
    have hvalid : ChannelPathLabelsValid (e₀ :: rest) := by
      intro x hx
      rcases List.mem_cons.1 hx with rfl | hx'
      · exact he₀
      · exact hrest x hx'
    have hκlt : κ < M :=
      channelPathIndexClass_lt hvalid (by simp)
    have hmod : k % M = κ := by
      have := hk
      rw [Nat.ModEq, Nat.mod_eq_of_lt hκlt] at this
      exact this
    refine ⟨k / M, ?_⟩
    have hdecomp := (Nat.div_add_mod k M).symm
    rw [hmod] at hdecomp
    change fiberIndexMap e₀ k =
      fiberIndexMap e₀ (κ + (k / M) * M)
    congr 1
    calc
      k = M * (k / M) + κ := hdecomp
      _ = κ + (k / M) * M := by ring
  · intro hn
    obtain ⟨r, rfl⟩ := hn
    refine (realizesChannelPath_fiberIndex_iff he₀ hrest).2 ?_
    rw [Nat.ModEq]
    simp [Nat.add_mul_mod_self_right]

theorem realizesChannelPath_eq_progression
    {e₀ : Nat} {rest : List Nat}
    (he₀ : 1 ≤ e₀) (hrest : ChannelPathLabelsValid rest) :
    {n | RealizesChannelPath (e₀ :: rest) n} =
      channelPathProgression (e₀ :: rest) := by
  ext n
  exact realizesChannelPath_iff_mem_progression he₀ hrest

/-! ### Open D3/D4 dynamical goals (definitions only) -/

/--
`[C]` Hits contracting mass at a complete block boundary (`t = 7r`).
-/
def BlockBoundaryFeedInGoal : Prop :=
  ∀ n ∈ expandingMass,
    ∃ r : Nat, 1 ≤ r ∧
      syracuseOddIterate (7 * r) n ∈ contractingMass

/--
`[C]` After exiting Core6 in one block, some later odd iterate re-enters Core6.
-/
def OffCore6ReentryGoal : Prop :=
  ∀ e₀ : Nat, 1 ≤ e₀ → e₀ ≤ 3 →
    ∀ n ∈ oneBlockOffCore6Set e₀,
      ∃ s : Nat, 1 ≤ s ∧
        syracuseOddIterate s (realizedImage n (fiberE e₀)) ∈ core6Cylinder

theorem blockBoundaryFeedIn_implies_reachability :
    BlockBoundaryFeedInGoal → ReachabilityFeedInGoal := by
  intro h n hn
  obtain ⟨r, hr, himg⟩ := h n hn
  exact ⟨7 * r, by omega, himg⟩

/-! ### D3 algebraic package -/

structure Core6DynamicD3AlgebraGoals : Prop where
  trichotomy : ∀ e₀ : Nat, 1 ≤ e₀ →
    canonicalCylinder e₀ =
      oneBlockFeedInSet e₀ ∪
        oneBlockExpandingReturnSet e₀ ∪
          oneBlockOffCore6Set e₀
  expandingReturnProgressions : ∀ e₀ : Nat, 1 ≤ e₀ →
    oneBlockExpandingReturnSet e₀ =
      ⋃ f : Nat, ⋃ (_ : 1 ≤ f ∧ f ≤ 3), oneBlockTargetProgression e₀ f
  targetIndexAffine :
    ∀ e₀ f r : Nat, ∀ he₀ : 1 ≤ e₀, ∀ hf : 1 ≤ f,
      realizedImage
          (fiberIndexMap e₀
            (oneBlockIndexClass e₀ f + r * oneBlockIndexModulus f))
          (fiberE e₀) =
        fiberIndexMap f
          (oneBlockTargetBaseIndex e₀ f he₀ hf + coeff3 * r)
  channelPathLengthTwo :
    ∀ e₀ f : Nat, 1 ≤ e₀ → 1 ≤ f →
      channelPathProgression [e₀, f] = oneBlockTargetProgression e₀ f
  channelPathHopStep :
    ∀ e f : Nat, ∀ rest : List Nat, ∀ k : Nat,
      ∀ he : 1 ≤ e, ∀ hf : 1 ≤ f,
        k ≡ oneBlockIndexClass e f [MOD oneBlockIndexModulus f] →
          let r := k / oneBlockIndexModulus f
          let j := oneBlockTargetBaseIndex e f he hf + coeff3 * r
          (RealizesChannelPath (e :: f :: rest) (fiberIndexMap e k) ↔
            RealizesChannelPath (f :: rest) (fiberIndexMap f j))
  channelPathFiberIndex :
    ∀ e₀ : Nat, ∀ rest : List Nat, ∀ k : Nat,
      1 ≤ e₀ → ChannelPathLabelsValid rest →
        (RealizesChannelPath (e₀ :: rest) (fiberIndexMap e₀ k) ↔
          k ≡ channelPathIndexClass (e₀ :: rest)
            [MOD channelPathIndexModulus (e₀ :: rest)])
  channelPathEqProgression :
    ∀ e₀ : Nat, ∀ rest : List Nat,
      1 ≤ e₀ → ChannelPathLabelsValid rest →
        {n | RealizesChannelPath (e₀ :: rest) n} =
          channelPathProgression (e₀ :: rest)
  channelPathWitness : RealizesChannelPath [1, 4] 1246239
  offCore6Witness : 31 ∈ oneBlockOffCore6Set 1
  blockBoundaryImpliesReachability :
    BlockBoundaryFeedInGoal → ReachabilityFeedInGoal

theorem core6DynamicD3AlgebraGoals_named : Core6DynamicD3AlgebraGoals where
  trichotomy := fun _ he => canonicalCylinder_eq_oneBlock_trichotomy he
  expandingReturnProgressions := fun _ he =>
    oneBlockExpandingReturnSet_eq_iUnion_progressions he
  targetIndexAffine := fun _ _ _ he₀ hf => oneBlock_targetIndex_affine he₀ hf
  channelPathLengthTwo := fun _ _ he₀ hf =>
    channelPathProgression_two_eq_oneBlock he₀ hf
  channelPathHopStep := fun _ _ _ _ he hf hk =>
    realizesChannelPath_cons_fiberIndex_step he hf hk
  channelPathFiberIndex := fun _ _ _ he₀ hrest =>
    realizesChannelPath_fiberIndex_iff he₀ hrest
  channelPathEqProgression := fun _ _ he₀ hrest =>
    realizesChannelPath_eq_progression he₀ hrest
  channelPathWitness := realizesChannelPath_one_four_1246239
  offCore6Witness := mem_oneBlockOffCore6Set_one_31
  blockBoundaryImpliesReachability := blockBoundaryFeedIn_implies_reachability

/-!
## Explicit non-theorems

- `BlockBoundaryFeedInGoal` / `OffCore6ReentryGoal` are not discharged.
- `ReachabilityFeedInGoal` remains `[C]`.
- Fixed-path APs are structure for each finite `p`, not universal reachability.
- The constructed path modulus need not be the minimal period.
- No Collatz / collapse statement.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3
