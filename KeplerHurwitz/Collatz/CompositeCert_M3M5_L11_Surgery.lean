/-
Copyright (c) 2026 Kepler-Hurrwitz contributors.
Auto-generated: L=11 surgical composite M3∘M5 at **C=8**, sparse active support.

Parameter dependence (in-repo clog + block pipeline, L=11 baseline):
* Resonant cell requiring ForbiddenSet surgery: **(C,L)=(8,11)**.
* For C ≥ 9 at L=11 baseline M₃M₂ / M₃M₅ are already nilpotent here;
  this module certifies only the C=8 surgical matrix.
* Informal comment rule (not Core):
    if C = 8 ∧ L = 11 then apply ForbiddenSetL11 else plain clog.
* No induction in C or L.

Claim boundary:
* Finite Not-Patch for the (8,11) singularity only.
* Forbidden windows are NOT a Core survivor refinement.
* Epistemics: finite audit; not a Collatz proof.
-/

import Mathlib.Data.Matrix.Basic
import Mathlib.Data.Rat.Defs
import Mathlib.Tactic

set_option maxRecDepth 100000
set_option linter.style.longLine false
set_option linter.style.nativeDecide false

namespace KeplerHurwitz.Collatz.CompositeCert_M3M5_L11_Surgery

open Matrix

def IsSubinvariantCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) : Prop :=
  (∀ i, 0 < v i) ∧ 0 < θ ∧ ∀ i, (M.mulVec v) i ≤ θ * v i

def HasContractiveDoob {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ v : Fin n → Rat, ∃ θ : Rat, θ < 1 ∧ IsSubinvariantCertificate M v θ

/-- Active support size after L=11 surgical cut. -/
def nComp : Nat := 104

/-- Nilpotency index (numeric witness used to build v). -/
def nilpotencyIndex : Nat := 4

/-- Sparse nonzero entries `(i, j, Mᵢⱼ)`. -/
def Mnz : List (Nat × Nat × Rat) := [
  (0, 100, (243 : Rat) / 256),
  (1, 86, (729 : Rat) / 256),
  (2, 94, (81 : Rat) / 256),
  (2, 95, (243 : Rat) / 256),
  (3, 100, (243 : Rat) / 256),
  (4, 100, (243 : Rat) / 256),
  (5, 91, (243 : Rat) / 256),
  (6, 59, (729 : Rat) / 256),
  (7, 49, (243 : Rat) / 256),
  (8, 69, (243 : Rat) / 256),
  (9, 86, (729 : Rat) / 256),
  (10, 18, (729 : Rat) / 256),
  (11, 83, (243 : Rat) / 256),
  (12, 100, (243 : Rat) / 256),
  (12, 101, (243 : Rat) / 256),
  (13, 86, (729 : Rat) / 256),
  (14, 95, (243 : Rat) / 256),
  (15, 102, (243 : Rat) / 256),
  (15, 103, (243 : Rat) / 256),
  (17, 86, (729 : Rat) / 256),
  (18, 95, (243 : Rat) / 256),
  (19, 100, (243 : Rat) / 256),
  (20, 102, (243 : Rat) / 256),
  (21, 78, (729 : Rat) / 256),
  (22, 8, (729 : Rat) / 256),
  (23, 81, (243 : Rat) / 256),
  (23, 83, (243 : Rat) / 256),
  (23, 88, (729 : Rat) / 256),
  (24, 76, (81 : Rat) / 256),
  (25, 16, (729 : Rat) / 256),
  (28, 92, (81 : Rat) / 256),
  (29, 46, (243 : Rat) / 256),
  (30, 100, (243 : Rat) / 256),
  (32, 82, (729 : Rat) / 256),
  (34, 59, (729 : Rat) / 256),
  (35, 49, (243 : Rat) / 256),
  (36, 69, (243 : Rat) / 256),
  (37, 55, (729 : Rat) / 256),
  (38, 62, (243 : Rat) / 256),
  (38, 66, (81 : Rat) / 256),
  (38, 67, (243 : Rat) / 256),
  (39, 97, (81 : Rat) / 256),
  (40, 85, (243 : Rat) / 256),
  (41, 49, (243 : Rat) / 256),
  (42, 69, (243 : Rat) / 256),
  (43, 100, (243 : Rat) / 256),
  (44, 86, (729 : Rat) / 256),
  (46, 44, (243 : Rat) / 256),
  (47, 100, (243 : Rat) / 256),
  (47, 101, (243 : Rat) / 256),
  (47, 102, (243 : Rat) / 256),
  (48, 59, (729 : Rat) / 256),
  (53, 49, (243 : Rat) / 256),
  (54, 69, (243 : Rat) / 256),
  (55, 86, (729 : Rat) / 256),
  (56, 95, (243 : Rat) / 256),
  (57, 102, (243 : Rat) / 256),
  (57, 103, (243 : Rat) / 256),
  (58, 51, (729 : Rat) / 256),
  (58, 52, (729 : Rat) / 256),
  (60, 100, (243 : Rat) / 256),
  (61, 50, (729 : Rat) / 256),
  (63, 33, (729 : Rat) / 256),
  (64, 98, (243 : Rat) / 256),
  (65, 31, (243 : Rat) / 256),
  (66, 59, (729 : Rat) / 256),
  (67, 74, (243 : Rat) / 256),
  (68, 45, (81 : Rat) / 256),
  (70, 49, (243 : Rat) / 256),
  (71, 83, (243 : Rat) / 256),
  (72, 93, (243 : Rat) / 256),
  (73, 26, (243 : Rat) / 256),
  (73, 27, (729 : Rat) / 256),
  (75, 95, (243 : Rat) / 256),
  (77, 50, (729 : Rat) / 256),
  (79, 16, (729 : Rat) / 256),
  (80, 100, (243 : Rat) / 256),
  (84, 8, (729 : Rat) / 256),
  (87, 66, (81 : Rat) / 256),
  (87, 67, (243 : Rat) / 256),
  (88, 100, (243 : Rat) / 256),
  (89, 102, (243 : Rat) / 256),
  (90, 49, (243 : Rat) / 256),
  (91, 69, (243 : Rat) / 256),
  (93, 91, (243 : Rat) / 256),
  (93, 98, (243 : Rat) / 256),
  (96, 97, (81 : Rat) / 256),
  (96, 100, (243 : Rat) / 256),
  (99, 100, (243 : Rat) / 256)
]

def lookup (i j : Nat) : Rat :=
  match Mnz.find? (fun t => t.1 = i ∧ t.2.1 = j) with
  | some t => t.2.2
  | none => 0

def MComp : Matrix (Fin nComp) (Fin nComp) Rat :=
  Matrix.of fun i j => lookup i.val j.val

def vArr : Array Nat := #[
  6078464, 14041088, 7405568, 6078464, 6078464, 13636736, 14041088, 6078464, 6078464, 14041088, 36715904, 6078464, 10059776, 14041088, 6078464, 10059776, 2097152, 14041088, 6078464, 6078464,
  6078464, 14041088, 36715904, 44678528, 3424256, 14041088, 2097152, 2097152, 3424256, 56683457, 6078464, 2097152, 14041088, 2097152, 14041088, 6078464, 6078464, 82065536, 26503424, 3424256,
  6078464, 6078464, 6078464, 6078464, 14041088, 2097152, 28753280, 14041088, 14041088, 2097152, 2097152, 2097152, 2097152, 6078464, 6078464, 14041088, 6078464, 10059776, 25985024, 2097152,
  6078464, 14041088, 2097152, 14041088, 6078464, 6078464, 14041088, 6078464, 3424256, 2097152, 6078464, 6078464, 35543915, 18022400, 2097152, 6078464, 2097152, 14041088, 2097152, 14041088,
  6078464, 2097152, 2097152, 2097152, 36715904, 2097152, 2097152, 22522112, 6078464, 6078464, 6078464, 6078464, 2097152, 17618048, 2097152, 2097152, 7405568, 2097152, 2097152, 6078464,
  2097152, 2097152, 2097152, 2097152
]

def vCert : Fin nComp → Rat := fun i => (vArr[i.val]! : Rat)

def thetaCert : Rat := (1 : Rat) / 2

theorem vCert_pos : ∀ i : Fin nComp, 0 < vCert i := by
  native_decide

theorem thetaCert_lt_one : thetaCert < 1 := by
  norm_num [thetaCert]

theorem MComp_subinvariant :
    ∀ i : Fin nComp, (MComp.mulVec vCert) i ≤ thetaCert * vCert i := by
  native_decide

theorem composite_HasContractiveDoob : HasContractiveDoob MComp := by
  refine ⟨vCert, thetaCert, thetaCert_lt_one, vCert_pos, ?_, MComp_subinvariant⟩
  norm_num [thetaCert]

end KeplerHurwitz.Collatz.CompositeCert_M3M5_L11_Surgery
