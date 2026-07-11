import Mathlib
import KeplerHurwitz.Representation.EABCChronology

/-!
# EABC-Kanal-Partition (kombinatorischer Kern **[A]**)

Formal counterpart of `docs/eabc_partition.md` §1–§2 and the greedy upper bound §3.

The development is **prime-independent**: only a finite stream, a four-channel map
`κ`, and finite channel lists / Finsets matter.  Python reference:
`src/kepler_hurwitz/eabc_rising_collection.py` (`partition_eabc_quadruples_by_channels`,
`EABC_CHANNEL_ORDER`, `eabc_channel_from_mod12` via mod-12 residues 1/5/7/11).
-/

namespace KeplerHurwitz

open EABCChannel

/-!
## Channel lists and bucket capacity (Python `EABC_CHANNEL_ORDER`, `K = min_c |L_c|`)
-/

/--
Four rising channel lists `L_E, L_A, L_B, L_C` — the data side of the bucket partition.
-/
structure EABCChannelLists (α : Type*) where
  L_E : List α
  L_A : List α
  L_B : List α
  L_C : List α

namespace EABCChannelLists

variable {α : Type*}

def channelList (L : EABCChannelLists α) (c : EABCChannel) : List α :=
  match c with
  | EABCChannel.E => L.L_E
  | EABCChannel.A => L.L_A
  | EABCChannel.B => L.L_B
  | EABCChannel.C => L.L_C

/-- `K_bucket = min_c |L_c|` (synchronized slot count). -/
def bucketCapacity (L : EABCChannelLists α) : Nat :=
  min (min L.L_E.length L.L_A.length) (min L.L_B.length L.L_C.length)

theorem bucketCapacity_eq_min_channel_lengths (L : EABCChannelLists α) :
    L.bucketCapacity =
      min (min L.L_E.length L.L_A.length) (min L.L_B.length L.L_C.length) := rfl

end EABCChannelLists

/-!
## EABC-complete quadruples and Finset channel buckets
-/

section Combinatorics

variable {α : Type*} [DecidableEq α]

/-- Channel bucket inside a finite stream `S`. -/
def channelFinset (S : Finset α) (κ : α → EABCChannel) (c : EABCChannel) : Finset α :=
  S.filter (fun x => κ x = c)

/-- `K_bucket` from channel cardinalities inside `S`. -/
def bucketCapacityFinset (S : Finset α) (κ : α → EABCChannel) : Nat :=
  min (min (channelFinset S κ EABCChannel.E).card (channelFinset S κ EABCChannel.A).card)
      (min (channelFinset S κ EABCChannel.B).card (channelFinset S κ EABCChannel.C).card)

/-- A four-element set with exactly one element per EABC channel. -/
def IsEABCComplete (Q : Finset α) (κ : α → EABCChannel) : Prop :=
  Q.card = 4 ∧
    ∀ c : EABCChannel, (Q.filter (fun x => κ x = c)).card = 1

theorem IsEABCComplete.card_four {Q : Finset α} {κ : α → EABCChannel}
    (h : IsEABCComplete Q κ) : Q.card = 4 :=
  h.1

theorem IsEABCComplete.channel_singleton {Q : Finset α} {κ : α → EABCChannel}
    (h : IsEABCComplete Q κ) (c : EABCChannel) :
    (Q.filter (fun x => κ x = c)).card = 1 :=
  h.2 c

private def channelSlice (Q : Finset α) (κ : α → EABCChannel) (c : EABCChannel) : Finset α :=
  Q.filter (fun x => κ x = c)

private lemma channelSlice_pairwiseDisjoint {κ : α → EABCChannel}
    {Q₁ Q₂ : Finset α} (hne : Q₁ ≠ Q₂) (hdisj : Disjoint Q₁ Q₂) (c : EABCChannel) :
    Disjoint (channelSlice Q₁ κ c) (channelSlice Q₂ κ c) := by
  rw [Finset.disjoint_left]
  intro x hx₁ hx₂
  exact Finset.disjoint_left.mp hdisj (Finset.mem_filter.mp hx₁).1 (Finset.mem_filter.mp hx₂).1

private lemma card_channel_le {S : Finset α} {κ : α → EABCChannel} {F : Finset (Finset α)}
    (hcomplete : ∀ Q, Q ∈ F → IsEABCComplete Q κ)
    (hsub : ∀ Q, Q ∈ F → Q ⊆ S)
    (hdisj : ∀ Q₁ Q₂, Q₁ ∈ F → Q₂ ∈ F → Q₁ ≠ Q₂ → Disjoint Q₁ Q₂) (c : EABCChannel) :
    F.card ≤ (channelFinset S κ c).card := by
  have hslice_card : ∀ Q ∈ F, (channelSlice Q κ c).card = 1 := by
    intro Q hQ
    simpa [channelSlice] using (hcomplete Q hQ).2 c
  have hunion_sub :
      F.biUnion (fun Q => channelSlice Q κ c) ⊆ channelFinset S κ c := by
    intro x hx
    obtain ⟨Q, hQ, hxQ⟩ := Finset.mem_biUnion.mp hx
    exact Finset.mem_filter.mpr ⟨(hsub Q hQ (Finset.mem_filter.mp hxQ).1),
      (Finset.mem_filter.mp hxQ).2⟩
  have hcard_union :
      (F.biUnion (fun Q => channelSlice Q κ c)).card = F.card := by
    have hpair : (F : Set (Finset α)).PairwiseDisjoint (fun Q => channelSlice Q κ c) := by
      intro Qa hQa Qb hQb hne
      exact channelSlice_pairwiseDisjoint hne (hdisj Qa Qb hQa hQb hne) c
    rw [Finset.card_biUnion hpair, Finset.sum_congr rfl fun Q hQ => hslice_card Q hQ]
    simp [Finset.sum_const]
  calc
    F.card = (F.biUnion (fun Q => channelSlice Q κ c)).card := hcard_union.symm
    _ ≤ (channelFinset S κ c).card := Finset.card_le_card hunion_sub

/--
**Maximalitätssatz [A].** Any family of pairwise disjoint EABC-complete quadruples inside
`S` has cardinality at most `K = min_c |L_c|`.
Corresponds to `docs/eabc_partition.md` §2.
-/
theorem card_disjoint_eabc_quadruples_le_bucketCapacity
    (S : Finset α) (κ : α → EABCChannel) (F : Finset (Finset α))
    (hcomplete : ∀ Q, Q ∈ F → IsEABCComplete Q κ)
    (hsub : ∀ Q, Q ∈ F → Q ⊆ S)
    (hdisj : ∀ Q₁ Q₂, Q₁ ∈ F → Q₂ ∈ F → Q₁ ≠ Q₂ → Disjoint Q₁ Q₂) :
    F.card ≤ bucketCapacityFinset S κ := by
  have hE := card_channel_le hcomplete hsub hdisj EABCChannel.E
  have hA := card_channel_le hcomplete hsub hdisj EABCChannel.A
  have hB := card_channel_le hcomplete hsub hdisj EABCChannel.B
  have hC := card_channel_le hcomplete hsub hdisj EABCChannel.C
  rw [bucketCapacityFinset]
  exact le_min (le_min hE hA) (le_min hB hC)

/--
**Greedy-Obergrenze [A].** Any disjoint family of EABC-complete quadruples extracted by
*any* scan rule (including the rising greedy scan) satisfies
`K_greedy ≤ K_bucket`.  Corresponds to `docs/eabc_partition.md` §3.2.
-/
theorem greedy_card_le_bucketCapacity
    (S : Finset α) (κ : α → EABCChannel) (F : Finset (Finset α))
    (hcomplete : ∀ Q, Q ∈ F → IsEABCComplete Q κ)
    (hsub : ∀ Q, Q ∈ F → Q ⊆ S)
    (hdisj : ∀ Q₁ Q₂, Q₁ ∈ F → Q₂ ∈ F → Q₁ ≠ Q₂ → Disjoint Q₁ Q₂) :
    F.card ≤ bucketCapacityFinset S κ :=
  card_disjoint_eabc_quadruples_le_bucketCapacity S κ F hcomplete hsub hdisj

/-!
## Synchronized bucket construction
-/

namespace EABCChannelLists

variable {α : Type*} [DecidableEq α]

/-- Synchronized quadruple `Q_i = (L_E[i], L_A[i], L_B[i], L_C[i])`. -/
def synchronizedQuadrupleFinset (L : EABCChannelLists α) (i : Nat)
    (hi_E : i < L.L_E.length) (hi_A : i < L.L_A.length)
    (hi_B : i < L.L_B.length) (hi_C : i < L.L_C.length) : Finset α :=
  {L.L_E[i], L.L_A[i], L.L_B[i], L.L_C[i]}

theorem synchronizedQuadrupleFinset_card (L : EABCChannelLists α) (i : Nat)
    (hi_E : i < L.L_E.length) (hi_A : i < L.L_A.length)
    (hi_B : i < L.L_B.length) (hi_C : i < L.L_C.length)
    (hdist : L.L_E[i] ≠ L.L_A[i] ∧ L.L_E[i] ≠ L.L_B[i] ∧ L.L_E[i] ≠ L.L_C[i] ∧
      L.L_A[i] ≠ L.L_B[i] ∧ L.L_A[i] ≠ L.L_C[i] ∧ L.L_B[i] ≠ L.L_C[i]) :
    (synchronizedQuadrupleFinset L i hi_E hi_A hi_B hi_C).card = 4 := by
  simp [synchronizedQuadrupleFinset, hdist]

/-- Bucket construction slot count (Python `K = min_c |L_c|`). -/
theorem bucketConstructionSlotCount (L : EABCChannelLists α) :
    L.bucketCapacity =
      min (min L.L_E.length L.L_A.length) (min L.L_B.length L.L_C.length) := rfl

end EABCChannelLists

end Combinatorics

/-!
## Mod-12 channel map (Python `eabc_channel_from_mod12` / `EABC_MOD12_RESIDUE`)
-/

/-- Residue-class channel map: `1 ↦ E`, `5 ↦ A`, `7 ↦ B`, `11 ↦ C`. -/
def eabcChannelOfMod12 (r : Nat) : Option EABCChannel :=
  match r % 12 with
  | 1 => some EABCChannel.E
  | 5 => some EABCChannel.A
  | 7 => some EABCChannel.B
  | 11 => some EABCChannel.C
  | _ => none

theorem eabcChannelOfMod12_one : eabcChannelOfMod12 1 = some EABCChannel.E := by
  simp [eabcChannelOfMod12]

theorem eabcChannelOfMod12_five : eabcChannelOfMod12 5 = some EABCChannel.A := by
  simp [eabcChannelOfMod12]

theorem eabcChannelOfMod12_seven : eabcChannelOfMod12 7 = some EABCChannel.B := by
  simp [eabcChannelOfMod12]

theorem eabcChannelOfMod12_eleven : eabcChannelOfMod12 11 = some EABCChannel.C := by
  simp [eabcChannelOfMod12]

theorem eabcChannelOfMod12_two : eabcChannelOfMod12 2 = none := by
  simp [eabcChannelOfMod12]

theorem eabcChannelOfMod12_three : eabcChannelOfMod12 3 = none := by
  simp [eabcChannelOfMod12]

end KeplerHurwitz
