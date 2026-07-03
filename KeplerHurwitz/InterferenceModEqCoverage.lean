import Mathlib
import KeplerHurwitz.InterferenceAttraktorBridge

namespace KeplerHurwitz

/--
Kanonische ungerade Restklassen modulo `12`.
-/
def OddResidueMod12 (r : Nat) : Prop :=
  r ≡ 1 [MOD 12] ∨
  r ≡ 3 [MOD 12] ∨
  r ≡ 5 [MOD 12] ∨
  r ≡ 7 [MOD 12] ∨
  r ≡ 9 [MOD 12] ∨
  r ≡ 11 [MOD 12]

/--
Bruecke von explizitem Mod-12-Repräsentanten zu `ModEq`.
-/
lemma modEq_of_eq_mod12 {n r : Nat}
    (h : r = n % 12) :
    r ≡ n [MOD 12] := by
  subst r
  exact Nat.mod_modEq n 12

/--
Ungerader Input erzeugt eine kanonische ungerade Mod-12-Klasse.
-/
lemma odd_mod12_to_oddResidueMod12
    {n r : Nat}
    (hr : r = n % 12)
    (hn : n % 2 = 1) :
    OddResidueMod12 r := by
  subst r
  unfold OddResidueMod12
  rcases odd_mod12_cases hn with h1 | h3 | h5 | h7 | h9 | h11
  · exact Or.inl (by unfold Nat.ModEq; simpa [h1])
  · exact Or.inr <| Or.inl (by unfold Nat.ModEq; simpa [h3])
  · exact Or.inr <| Or.inr <| Or.inl (by unfold Nat.ModEq; simpa [h5])
  · exact Or.inr <| Or.inr <| Or.inr <| Or.inl (by unfold Nat.ModEq; simpa [h7])
  · exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inl (by unfold Nat.ModEq; simpa [h9])
  · exact Or.inr <| Or.inr <| Or.inr <| Or.inr <| Or.inr (by unfold Nat.ModEq; simpa [h11])

/--
Rekonstruktion eines kanonischen Interferenz-Residuenobjekts aus lokalem
Mod-12-Bounds plus Ungeradheit.
-/
lemma canonicalResidue_of_lt12_and_odd
    {r : Nat}
    (hbound : r < 12)
    (hodd : r % 2 = 1) :
    CanonicalInterferenceResidue r := by
  refine ⟨canonicalInterferencePointAvailable_true, r, hodd, ?_⟩
  symm
  exact Nat.mod_eq_of_lt hbound

/--
Lokale Coverage-Ableitung: aus kanonischer Interferenzresidue folgt eine
ungerade Mod-12-Klasse.
-/
theorem oddResidueMod12_of_canonicalResidue
    {r : Nat}
    (hr : CanonicalInterferenceResidue r) :
    OddResidueMod12 r := by
  rcases hr with ⟨_, n, hnodd, hrEq⟩
  exact odd_mod12_to_oddResidueMod12 hrEq hnodd

/--
Globaler Reduktionssatz unter der offenen Coverage-Hypothese.
-/
theorem oddResidueMod12_of_globalCoverage
    (hcov : GlobalCoverageByCanonicalResidues)
    {r : Nat}
    (hr : InterferenceAdmissibleChannel r) :
    OddResidueMod12 r := by
  exact oddResidueMod12_of_canonicalResidue (hcov r hr)

end KeplerHurwitz
