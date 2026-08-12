/-
  Experimental [C]: Pointer / non-claim bundle for DISCRETE_ANALOGY_GLOSSARY.md

  The working lexicon lives in Markdown (human-editable). This Lean file only
  freezes the governance flags so the glossary cannot be mistaken for theorems.
-/

namespace DimensionalSombrero.DiscreteAnalogyGlossary

def glossaryPath : String :=
  "experimental/dimensional_sombrero_hurwitz/DISCRETE_ANALOGY_GLOSSARY.md"

/-- Physics names are reading labels only. -/
def AnalogySlotsAreNotTheorems : Prop := True

theorem analogy_slots_are_not_theorems : AnalogySlotsAreNotTheorems := trivial

def ClaimedAsTheorem : Prop := False

theorem not_claimed_as_theorem : ClaimedAsTheorem = False := rfl

def IsART : Prop := False
def IsEM : Prop := False
def IsPilotWave : Prop := False

theorem not_art : IsART = False := rfl
theorem not_em : IsEM = False := rfl
theorem not_pilot_wave : IsPilotWave = False := rfl

/-- Translation rule encoded as documentation strings. -/
def translationRule : String :=
  "Physikmetapher → Träger + Observable + Nullmodell — nie Feldgleichung"

def coreSlots : List String :=
  [ "Gamma_Traeger",
    "L_Laenge",
    "W1_Transport",
    "kappa_Ollivier",
    "G_Bilanz",
    "oint_Zirkulation",
    "Stufe_Plateau",
    "Exklusion_Shell",
    "J_Strom",
    "Defekt",
    "Scaffold_Geometrie",
    "Messung_MAlgebra",
    "Niveau_LambSlot",
    "DudleyTucker_AlteredFibonacci",
    "DiracBild_FreeSpectrum_E101_5",
    "KonstantenRollen_E101_6",
    "KernSchaleValenz_E101_7",
    "DiracLikeAudit_E101_8",
    "FunktionaleInformation_WongFilter_E112",
    "LemaitreDifferenz_DeltaL_E113",
    "Skalierungsdiagnose_cHat_B_E113_EXT",
    "AchsenKopplung_DeltaAxis_E113_TENSION",
    "Spin8Ankopplung_E113_SPIN8" ]

end DimensionalSombrero.DiscreteAnalogyGlossary
