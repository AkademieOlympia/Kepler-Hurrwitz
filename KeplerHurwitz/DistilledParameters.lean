import Mathlib
import KeplerHurwitz.EABCLayer

namespace KeplerHurwitz

/--
Destillierte Kanalmass- und Spread-Definitionen auf `(E,A,B,C)`-Tupeln.
Keine Identifikationsbehauptung mit Kepler-Dynamik.
-/
def ChannelMass (h : Nat × Nat × Nat × Nat) : Nat :=
  let e := h.1
  let a := h.2.1
  let b := h.2.2.1
  let c := h.2.2.2
  e + a + b + c

def ChannelSpread (h : Nat × Nat × Nat × Nat) : Nat :=
  let e := h.1
  let a := h.2.1
  let b := h.2.2.1
  let c := h.2.2.2
  max (max e a) (max b c) - min (min e a) (min b c)

def channelMass_ofSignature (h : EABCSignature4) : Nat :=
  h.totalWeight

def channelSpread_ofSignature (h : EABCSignature4) : Nat :=
  h.spread

theorem channelMass_eq_totalWeight (h : EABCSignature4) :
    channelMass_ofSignature h = h.totalWeight := by
  rfl

theorem channelSpread_eq_spread (h : EABCSignature4) :
    channelSpread_ofSignature h = h.spread := by
  rfl

theorem channelSpread_le_channelMass (h : EABCSignature4) :
    channelSpread_ofSignature h ≤ channelMass_ofSignature h := by
  exact h.spread_le_totalWeight

/--
Strukturelle Primvierling-Produktmasse: vier verschiedene EABC-Klassenprimes
liefern `(1,1,1,1)` und damit Masse 4.
-/
def ProductMassFour (h : Nat × Nat × Nat × Nat) : Prop :=
  ChannelMass h = 4

def productMassFour_ofSignature (h : EABCSignature4) : Prop :=
  h.totalWeight = 4

theorem productMassFour_iff_totalWeight (h : EABCSignature4) :
    productMassFour_ofSignature h ↔ h.totalWeight = 4 := by
  rfl

end KeplerHurwitz
