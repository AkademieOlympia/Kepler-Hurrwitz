import KeplerHurwitz.CyclicWordOrbit
import KeplerHurwitz.PrimvierlingSymmetry

namespace KeplerHurwitz.Doc

/-!
# EABC-OrbitSymmetry: Uebersicht ueber die Symmetriegruppen im Modell

Dieses Dokument dient als zentraler Einstiegspunkt und dokumentiert die
Invarianzstrukturen unter zyklischen Permutationen.

## 1. Die Primvierling-Ebene

Wir betrachten die Aktion, die ein Tupel `(a,b,c,e)` in `(c,e,a,b)` ueberfuehrt.
Diese Operation ist involutiv, wie in `shiftCEAB_involutive` bewiesen.

Wichtige Invarianten auf dieser Bahn:
- geometrisch: der diagonale Paar-Abstand `pairGapsInt`
- algebraisch: die quaternionische Feld-Norm `quatNorm`
-/
#check Primvierling
#check shiftCEAB
#check shiftCEAB_involutive
#check orbitCEAB
#check pairGapsInt
#check pairGapsInt_invariant_under_shiftCEAB
#check quatNorm
#check quatNorm_invariant_under_shiftCEAB

/-!
## 2. Die Collatz-Wort-Ebene

Fuer die Filterreduktion im kombinatorischen Raum betrachten wir die zyklische
Aequi\-valenz von Woertern (hier als Listen), induziert durch `rotateLeft`.
Die Relation `CyclicEquivalent` ist mit den vorliegenden Saetzen reflexiv und transitiv.
-/
#check rotateLeft
#check CyclicEquivalent
#check cyclicEquivalent_refl
#check cyclicEquivalent_trans
#check orbitPrefix

end KeplerHurwitz.Doc
