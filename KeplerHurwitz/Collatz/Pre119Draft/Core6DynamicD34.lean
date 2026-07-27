import Mathlib.Data.Set.Basic
import Mathlib.Data.Set.Lattice
import Mathlib.Tactic.IntervalCases
import KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3

set_option linter.style.nativeDecide false
set_option autoImplicit false

/-!
# Pre119Draft — Core6DynamicD34 (Residual fine-structure after D3.3 freeze)

**Base:** PR #18 / `Core6DynamicD3` math freeze `24bd5c8`.
**This module** formalizes D3.4 residual fine-structure:

```
core6PathResidualSet e₀
  = finiteBlockExitSet e₀ ∪̇ foreverExpandingBoundarySet e₀
```

for expanding start channels `e₀ ∈ {1,2,3}`.

*FiniteBlockExit*: some expanding-only sojourn ends with an Off-Core6 next block.
*ForeverExpandingBoundary*: every expanding-only sojourn has expanding next block.

Dynamics (`ResidualFeedInGoal`, Off-Core6 re-entry, exclusion of the forever
boundary) remain open `[C]`. No Collatz claim. ClaimsFreeze false.
-/

namespace KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD34

open Set
open KeplerHurwitz.Collatz.Pre119Draft.Core6CylinderPartition
open KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicFeedIn
open KeplerHurwitz.Collatz.Pre119Draft.Core6SingleStepSchema
open KeplerHurwitz.Collatz.Pre119Draft.FiberWordBasics
open KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD3

/-! ### Path terminals -/

def channelPathEndLabel : List Nat → Nat
  | [] => 0
  | [e] => e
  | _ :: f :: rest => channelPathEndLabel (f :: rest)

def channelPathEndValue : List Nat → Nat → Nat
  | [], n => n
  | [_] , n => n
  | e :: f :: rest, n =>
      channelPathEndValue (f :: rest) (realizedImage n (fiberE e))

theorem channelPathEndLabel_cons (e : Nat) (rest : List Nat) (hne : rest ≠ []) :
    channelPathEndLabel (e :: rest) = channelPathEndLabel rest := by
  match rest with
  | [] => exact (hne rfl).elim
  | _ :: _ => rfl

theorem channelPathEndValue_cons (e : Nat) (rest : List Nat) (n : Nat)
    (hne : rest ≠ []) :
    channelPathEndValue (e :: rest) n =
      channelPathEndValue rest (realizedImage n (fiberE e)) := by
  match rest with
  | [] => exact (hne rfl).elim
  | _ :: _ => rfl

theorem realizesChannelPath_endValue_mem_endLabel
    {p : List Nat} {n : Nat}
    (hne : p ≠ []) (hR : RealizesChannelPath p n) :
    channelPathEndValue p n ∈ canonicalCylinder (channelPathEndLabel p) := by
  match p with
  | [] => exact (hne rfl).elim
  | [_] =>
    simpa [channelPathEndValue, channelPathEndLabel, RealizesChannelPath] using hR
  | e :: f :: rest =>
    have hR' :
        n ∈ canonicalCylinder e ∧
          RealizesChannelPath (f :: rest) (realizedImage n (fiberE e)) := hR
    simpa [channelPathEndValue, channelPathEndLabel] using
      realizesChannelPath_endValue_mem_endLabel (List.cons_ne_nil _ _) hR'.2

theorem realizesChannelPath_mem_headCylinder
    {e₀ : Nat} {mid : List Nat} {n : Nat}
    (hR : RealizesChannelPath (e₀ :: mid) n) :
    n ∈ canonicalCylinder e₀ := by
  match mid with
  | [] => simpa [RealizesChannelPath] using hR
  | _ :: _ => exact hR.1

theorem realizesChannelPath_cons_image
    {e₀ x : Nat} {xs : List Nat} {n : Nat}
    (hR : RealizesChannelPath (e₀ :: x :: xs) n) :
    realizedImage n (fiberE e₀) ∈ canonicalCylinder x ∧
      RealizesChannelPath (x :: xs) (realizedImage n (fiberE e₀)) := by
  have h := hR.2
  refine ⟨?_, h⟩
  match xs with
  | [] => simpa [RealizesChannelPath] using h
  | _ :: _ => exact h.1

/--
Drop a singleton snoc: the expanding/prefix path is realized, and the **next**
block image from its end channel lands in `C_f`.
-/
theorem realizesChannelPath_drop_snoc
    {e₀ : Nat} {mid : List Nat} {f n : Nat}
    (hR : RealizesChannelPath (e₀ :: (mid ++ [f])) n) :
    RealizesChannelPath (e₀ :: mid) n ∧
      realizedImage
          (channelPathEndValue (e₀ :: mid) n)
          (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ canonicalCylinder f := by
  match mid with
  | [] =>
    have hR' : RealizesChannelPath [e₀, f] n := by simpa using hR
    refine ⟨by simpa [RealizesChannelPath] using hR'.1, ?_⟩
    simpa [channelPathEndValue, channelPathEndLabel, RealizesChannelPath] using hR'.2
  | x :: xs =>
    have hR' : RealizesChannelPath (e₀ :: x :: (xs ++ [f])) n := by
      simpa [List.cons_append] using hR
    have himg := realizesChannelPath_cons_image (xs := xs ++ [f]) hR'
    have ih :=
      realizesChannelPath_drop_snoc (e₀ := x) (mid := xs) (f := f)
        (n := realizedImage n (fiberE e₀))
        (by simpa [List.cons_append] using himg.2)
    refine ⟨?_, ?_⟩
    · match xs with
      | [] => exact ⟨hR'.1, by simpa [RealizesChannelPath] using ih.1⟩
      | _ :: _ => exact ⟨hR'.1, ih.1⟩
    · simpa [channelPathEndValue_cons e₀ (x :: xs) n (List.cons_ne_nil _ _),
        channelPathEndLabel_cons e₀ (x :: xs) (List.cons_ne_nil _ _)] using ih.2

/-- Extend a realized path by one further next-block channel membership. -/
theorem realizesChannelPath_snoc
    {e₀ : Nat} {mid : List Nat} {x n : Nat}
    (hR : RealizesChannelPath (e₀ :: mid) n)
    (hx :
      realizedImage
          (channelPathEndValue (e₀ :: mid) n)
          (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ canonicalCylinder x) :
    RealizesChannelPath (e₀ :: (mid ++ [x])) n := by
  match mid with
  | [] =>
    refine ⟨by simpa [RealizesChannelPath] using hR, ?_⟩
    simpa [channelPathEndValue, channelPathEndLabel, RealizesChannelPath] using hx
  | y :: ys =>
    have himg := realizesChannelPath_cons_image (xs := ys) hR
    have ih :=
      realizesChannelPath_snoc (e₀ := y) (mid := ys) (x := x)
        (n := realizedImage n (fiberE e₀)) himg.2
        (by
          simpa [channelPathEndValue_cons e₀ (y :: ys) n (List.cons_ne_nil _ _),
            channelPathEndLabel_cons e₀ (y :: ys) (List.cons_ne_nil _ _)] using hx)
    simpa [List.cons_append] using ⟨hR.1, ih⟩

theorem eq_of_mem_two_canonicalCylinders {e f n : Nat}
    (he : 1 ≤ e) (hf : 1 ≤ f)
    (heN : n ∈ canonicalCylinder e) (hfN : n ∈ canonicalCylinder f) :
    e = f := by
  by_contra hne
  exact (disjoint_left.1 (canonicalCylinders_pairwise_disjoint he hf hne)) heN hfN

theorem mem_expandingCore6_of_expandingChannel
    {e n : Nat} (he : IsExpandingChannel e) (hn : n ∈ canonicalCylinder e) :
    n ∈ expandingCore6 := by
  have : e = 1 ∨ e = 2 ∨ e = 3 := by
    have := he.1; have := he.2; omega
  have hmem :
      n ∈ canonicalCylinder 1 ∨ n ∈ canonicalCylinder 2 ∨
        n ∈ canonicalCylinder 3 := by
    rcases this with rfl | rfl | rfl
    · exact Or.inl hn
    · exact Or.inr (Or.inl hn)
    · exact Or.inr (Or.inr hn)
  simpa [expandingCore6, smallTailCore6, or_assoc] using hmem

theorem mem_contractingCore6_of_contractingChannel
    {e n : Nat} (he : IsContractingChannel e) (hn : n ∈ canonicalCylinder e) :
    n ∈ contractingCore6 :=
  mem_iUnion.2 ⟨e, mem_iUnion.2 ⟨he, hn⟩⟩

theorem IsExpandingChannel.endLabel
    {e₀ : Nat} {mid : List Nat}
    (he₀ : IsExpandingChannel e₀)
    (hmid : ∀ e ∈ mid, IsExpandingChannel e) :
    IsExpandingChannel (channelPathEndLabel (e₀ :: mid)) := by
  match mid with
  | [] => simpa [channelPathEndLabel] using he₀
  | x :: xs =>
    simpa [channelPathEndLabel] using
      IsExpandingChannel.endLabel (he₀ := hmid x (by simp))
        (fun e he => hmid e (List.mem_cons.2 (Or.inr he)))

theorem exists_expanding_channel_of_mem_expandingCore6
    {m : Nat} (hm : m ∈ expandingCore6) :
    ∃ e : Nat, IsExpandingChannel e ∧ m ∈ canonicalCylinder e := by
  have h :
      m ∈ canonicalCylinder 1 ∨ m ∈ canonicalCylinder 2 ∨
        m ∈ canonicalCylinder 3 := by
    simpa [expandingCore6, smallTailCore6, or_assoc] using hm
  rcases h with h1 | h2 | h3
  · exact ⟨1, ⟨by decide, by decide⟩, h1⟩
  · exact ⟨2, ⟨by decide, by decide⟩, h2⟩
  · exact ⟨3, ⟨by decide, by decide⟩, h3⟩

theorem exists_contracting_channel_of_mem_contractingCore6
    {m : Nat} (hm : m ∈ contractingCore6) :
    ∃ e : Nat, IsContractingChannel e ∧ m ∈ canonicalCylinder e := by
  obtain ⟨e, he'⟩ := mem_iUnion.1 hm
  obtain ⟨he, hC⟩ := mem_iUnion.1 he'
  exact ⟨e, he, hC⟩

/-! ### D3.4a — FiniteBlockExit -/

def finiteBlockExitSet (e₀ : Nat) : Set Nat :=
  {n | ∃ mid : List Nat,
    IsExpandingChannel e₀ ∧
      (∀ e ∈ mid, IsExpandingChannel e) ∧
      RealizesChannelPath (e₀ :: mid) n ∧
      realizedImage
          (channelPathEndValue (e₀ :: mid) n)
          (fiberE (channelPathEndLabel (e₀ :: mid))) ∉ core6Cylinder}

theorem oneBlockOffCore6Set_subset_finiteBlockExitSet
    {e₀ : Nat} (he₀ : IsExpandingChannel e₀) :
    oneBlockOffCore6Set e₀ ⊆ finiteBlockExitSet e₀ := by
  intro n hn
  refine ⟨[], he₀, ?_, ?_, ?_⟩
  · intro e he; cases he
  · simpa [RealizesChannelPath] using hn.1
  · simpa [channelPathEndValue, channelPathEndLabel] using hn.2

theorem mem_finiteBlockExitSet_one_31 : 31 ∈ finiteBlockExitSet 1 :=
  oneBlockOffCore6Set_subset_finiteBlockExitSet ⟨by decide, by decide⟩
    mem_oneBlockOffCore6Set_one_31

theorem finiteBlockExitSet_one_nonempty : (finiteBlockExitSet 1).Nonempty :=
  ⟨31, mem_finiteBlockExitSet_one_31⟩

theorem not_mem_core6PathFeedInSet_of_finiteBlockExit
    {e₀ n : Nat} (hF : n ∈ finiteBlockExitSet e₀) :
    n ∉ core6PathFeedInSet e₀ := by
  obtain ⟨mid, he₀, hmid, hR, hOff⟩ := hF
  revert he₀ hmid hR hOff
  induction mid generalizing e₀ n with
  | nil =>
    intro he₀ _hmid hR hOff hFeed
    obtain ⟨p, hp'⟩ := mem_iUnion.1 hFeed
    obtain ⟨hp, hFeedR⟩ := mem_iUnion.1 hp'
    obtain ⟨midF, f, rfl, _, hmidF, hf⟩ := hp
    exact hOff (by
      simpa [channelPathEndValue, channelPathEndLabel] using
        realizesContractingFirstHit_firstImage_mem_core6 hmidF hf hFeedR)
  | cons x xs ih =>
    intro he₀ hmid hR hOff hFeed
    obtain ⟨p, hp'⟩ := mem_iUnion.1 hFeed
    obtain ⟨hp, hFeedR⟩ := mem_iUnion.1 hp'
    obtain ⟨midF, f, rfl, _, hmidF, hf⟩ := hp
    have hx := realizesChannelPath_cons_image (xs := xs) hR
    have hxExp : IsExpandingChannel x := hmid x (List.mem_cons.2 (Or.inl rfl))
    match midF with
    | [] =>
      have himgCon : realizedImage n (fiberE e₀) ∈ canonicalCylinder f := by
        simpa [RealizesChannelPath] using
          (show RealizesChannelPath [e₀, f] n by simpa using hFeedR).2
      exact (disjoint_left.1
        (core6Cylinder_eq_expanding_disjoint_union_contracting).2)
        (mem_expandingCore6_of_expandingChannel hxExp hx.1)
        (mem_contractingCore6_of_contractingChannel hf himgCon)
    | y :: ys =>
      have hFeedTail : RealizesChannelPath (y :: (ys ++ [f]))
          (realizedImage n (fiberE e₀)) := hFeedR.2
      have hyMem : realizedImage n (fiberE e₀) ∈ canonicalCylinder y :=
        realizesChannelPath_mem_headCylinder (mid := ys ++ [f]) hFeedTail
      have hyExp : IsExpandingChannel y :=
        hmidF y (List.mem_cons.2 (Or.inl rfl))
      have hyx : x = y :=
        eq_of_mem_two_canonicalCylinders hxExp.1 hyExp.1 hx.1 hyMem
      have hOffTail :
          realizedImage
              (channelPathEndValue (x :: xs) (realizedImage n (fiberE e₀)))
              (fiberE (channelPathEndLabel (x :: xs))) ∉ core6Cylinder := by
        simpa [channelPathEndValue_cons e₀ (x :: xs) n (List.cons_ne_nil _ _),
          channelPathEndLabel_cons e₀ (x :: xs) (List.cons_ne_nil _ _)] using hOff
      have hFeedTailX : RealizesChannelPath (x :: (ys ++ [f]))
          (realizedImage n (fiberE e₀)) := by
        rwa [hyx]
      have hyExpX : IsExpandingChannel x := by rwa [← hyx] at hyExp
      exact ih (e₀ := x) (n := realizedImage n (fiberE e₀))
        hxExp (fun e he => hmid e (List.mem_cons.2 (Or.inr he))) hx.2 hOffTail
        (mem_iUnion.2 ⟨x :: (ys ++ [f]), mem_iUnion.2
          ⟨⟨ys, f, rfl, hyExpX,
              fun e he => hmidF e (by
                rw [← hyx]; exact List.mem_cons.2 (Or.inr he)), hf⟩,
            hFeedTailX⟩⟩)

theorem finiteBlockExitSet_subset_core6PathResidualSet
    {e₀ : Nat} (_he₀ : IsExpandingChannel e₀) :
    finiteBlockExitSet e₀ ⊆ core6PathResidualSet e₀ := by
  intro n hF
  refine ⟨?_, not_mem_core6PathFeedInSet_of_finiteBlockExit hF⟩
  obtain ⟨mid, _, _, hR, _⟩ := hF
  exact realizesChannelPath_mem_headCylinder hR

/-! ### D3.4b — ForeverExpandingBoundary -/

def foreverExpandingBoundarySet (e₀ : Nat) : Set Nat :=
  {n | IsExpandingChannel e₀ ∧
    n ∈ canonicalCylinder e₀ ∧
    ∀ mid : List Nat,
      (∀ e ∈ mid, IsExpandingChannel e) →
      RealizesChannelPath (e₀ :: mid) n →
        realizedImage
            (channelPathEndValue (e₀ :: mid) n)
            (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ expandingCore6}

theorem disjoint_finiteBlockExit_foreverExpanding (e₀ : Nat) :
    Disjoint (finiteBlockExitSet e₀) (foreverExpandingBoundarySet e₀) := by
  refine disjoint_left.2 ?_
  intro n hF hFor
  obtain ⟨mid, _he₀, hmid, hR, hOff⟩ := hF
  have hexp : realizedImage
      (channelPathEndValue (e₀ :: mid) n)
      (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ expandingCore6 :=
    hFor.2.2 mid hmid hR
  have hphase := core6Cylinder_eq_expanding_disjoint_union_contracting
  exact hOff (by rw [hphase.1]; exact Or.inl hexp)

theorem mem_core6PathFeedInSet_of_expanding_prefix_contracting_hit
    {e₀ : Nat} {mid : List Nat} {f n : Nat}
    (he₀ : IsExpandingChannel e₀)
    (hmid : ∀ e ∈ mid, IsExpandingChannel e)
    (hf : IsContractingChannel f)
    (hR : RealizesChannelPath (e₀ :: mid) n)
    (hHit :
      realizedImage
          (channelPathEndValue (e₀ :: mid) n)
          (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ canonicalCylinder f) :
    n ∈ core6PathFeedInSet e₀ :=
  mem_iUnion.2 ⟨e₀ :: (mid ++ [f]), mem_iUnion.2
    ⟨⟨mid, f, rfl, he₀, hmid, hf⟩, realizesChannelPath_snoc hR hHit⟩⟩

theorem foreverExpandingBoundarySet_subset_core6PathResidualSet
    {e₀ : Nat} (_he₀ : IsExpandingChannel e₀) :
    foreverExpandingBoundarySet e₀ ⊆ core6PathResidualSet e₀ := by
  intro n hn
  refine ⟨hn.2.1, ?_⟩
  intro hFeed
  obtain ⟨p, hp'⟩ := mem_iUnion.1 hFeed
  obtain ⟨hp, hR⟩ := mem_iUnion.1 hp'
  obtain ⟨mid, f, rfl, he₀F, hmidF, hf⟩ := hp
  have hDrop := realizesChannelPath_drop_snoc (mid := mid) (f := f) hR
  have hexpNext := hn.2.2 mid hmidF hDrop.1
  exact (disjoint_left.1
    (core6Cylinder_eq_expanding_disjoint_union_contracting).2)
    hexpNext
    (mem_contractingCore6_of_contractingChannel hf hDrop.2)

/-! ### D3.4c — residual dichotomy -/

theorem mem_finiteBlockExit_or_forever_of_mem_residual
    {e₀ n : Nat} (he₀ : IsExpandingChannel e₀)
    (hn : n ∈ core6PathResidualSet e₀) :
    n ∈ finiteBlockExitSet e₀ ∨ n ∈ foreverExpandingBoundarySet e₀ := by
  classical
  by_cases hForever :
      ∀ mid : List Nat,
        (∀ e ∈ mid, IsExpandingChannel e) →
        RealizesChannelPath (e₀ :: mid) n →
          realizedImage
              (channelPathEndValue (e₀ :: mid) n)
              (fiberE (channelPathEndLabel (e₀ :: mid))) ∈ expandingCore6
  · exact Or.inr ⟨he₀, hn.1, hForever⟩
  · push Not at hForever
    obtain ⟨mid, hmid, hR, hnotExp⟩ := hForever
    set img :=
      realizedImage
        (channelPathEndValue (e₀ :: mid) n)
        (fiberE (channelPathEndLabel (e₀ :: mid)))
    have hEndLab := IsExpandingChannel.endLabel he₀ hmid
    have hEndMem :=
      realizesChannelPath_endValue_mem_endLabel (List.cons_ne_nil _ _) hR
    have htri :=
      canonicalCylinder_eq_oneBlock_trichotomy (e₀ := channelPathEndLabel (e₀ :: mid))
        hEndLab.1
    have hEndIn :
        channelPathEndValue (e₀ :: mid) n ∈
          oneBlockFeedInSet (channelPathEndLabel (e₀ :: mid)) ∪
            oneBlockExpandingReturnSet (channelPathEndLabel (e₀ :: mid)) ∪
              oneBlockOffCore6Set (channelPathEndLabel (e₀ :: mid)) := by
      rw [← htri]; exact hEndMem
    rcases hEndIn with hLR | hOff
    · rcases hLR with hCon | hExpRet
      · have himgCon : img ∈ contractingCore6 := by
          simpa [contractingMass] using hCon.2
        obtain ⟨f, hf, hCf⟩ :=
          exists_contracting_channel_of_mem_contractingCore6 himgCon
        have hFeed :=
          mem_core6PathFeedInSet_of_expanding_prefix_contracting_hit
            he₀ hmid hf hR (by simpa [img] using hCf)
        exact (hn.2 hFeed).elim
      · exact (hnotExp hExpRet.2).elim
    · exact Or.inl ⟨mid, he₀, hmid, hR, hOff.2⟩

theorem core6PathResidualSet_eq_finiteBlockExit_union_forever
    {e₀ : Nat} (he₀ : IsExpandingChannel e₀) :
    core6PathResidualSet e₀ =
      finiteBlockExitSet e₀ ∪ foreverExpandingBoundarySet e₀ := by
  ext n
  constructor
  · intro hn
    exact mem_finiteBlockExit_or_forever_of_mem_residual he₀ hn
  · intro hn
    rcases hn with hF | hFor
    · exact finiteBlockExitSet_subset_core6PathResidualSet he₀ hF
    · exact foreverExpandingBoundarySet_subset_core6PathResidualSet he₀ hFor

/-! ### D3.4 package -/

structure Core6DynamicD34ResidualGoals : Prop where
  offCore6SubsetFiniteExit :
    ∀ e₀ : Nat, IsExpandingChannel e₀ →
      oneBlockOffCore6Set e₀ ⊆ finiteBlockExitSet e₀
  finiteExitWitness : 31 ∈ finiteBlockExitSet 1
  finiteExitSubsetResidual :
    ∀ e₀ : Nat, IsExpandingChannel e₀ →
      finiteBlockExitSet e₀ ⊆ core6PathResidualSet e₀
  foreverSubsetResidual :
    ∀ e₀ : Nat, IsExpandingChannel e₀ →
      foreverExpandingBoundarySet e₀ ⊆ core6PathResidualSet e₀
  finiteExitDisjointForever :
    ∀ e₀ : Nat,
      Disjoint (finiteBlockExitSet e₀) (foreverExpandingBoundarySet e₀)
  residualDichotomy :
    ∀ e₀ : Nat, IsExpandingChannel e₀ →
      core6PathResidualSet e₀ =
        finiteBlockExitSet e₀ ∪ foreverExpandingBoundarySet e₀

theorem core6DynamicD34ResidualGoals_named : Core6DynamicD34ResidualGoals where
  offCore6SubsetFiniteExit := fun _ he =>
    oneBlockOffCore6Set_subset_finiteBlockExitSet he
  finiteExitWitness := mem_finiteBlockExitSet_one_31
  finiteExitSubsetResidual := fun _ he =>
    finiteBlockExitSet_subset_core6PathResidualSet he
  foreverSubsetResidual := fun _ he =>
    foreverExpandingBoundarySet_subset_core6PathResidualSet he
  finiteExitDisjointForever := fun _ =>
    disjoint_finiteBlockExit_foreverExpanding _
  residualDichotomy := fun _ he =>
    core6PathResidualSet_eq_finiteBlockExit_union_forever he

/-!
## Explicit non-theorems

- `ResidualFeedInGoal` / `ReachabilityFeedInGoal` remain open `[C]` (still equivalent
  by D3.3d).
- `OffCore6ReentryGoal` remains `[C]`.
- No exclusion of `foreverExpandingBoundarySet`.
- No Collatz / collapse statement. ClaimsFreeze false.
-/

end KeplerHurwitz.Collatz.Pre119Draft.Core6DynamicD34
