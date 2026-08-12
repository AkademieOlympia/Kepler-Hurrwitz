/-
Copyright (c) 2026 Kepler-Hurrwitz contributors.
Auto-generated: L=11 surgical composite M3∘M2 at **C=8**, sparse active support.

Parameter dependence (in-repo clog + block pipeline, L=11 baseline):
* Resonant cell requiring this ForbiddenSet surgery: **(C,L)=(8,11)**.
* For C ≥ 9 at L=11 the baseline composites M₃M₂ / M₃M₅ are already
  nilpotent in this pipeline — surgery is not applied / not claimed there.
* Informal rule for comments only (not a Core definition):
    if C = 8 ∧ L = 11 then apply ForbiddenSetL11
    else use plain clog survivors.
* Do not read this as induction in C or L.

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

namespace KeplerHurwitz.Collatz.CompositeCert_M3M2_L11_Surgery

open Matrix

def IsSubinvariantCertificate {n : Nat}
    (M : Matrix (Fin n) (Fin n) Rat) (v : Fin n → Rat) (θ : Rat) : Prop :=
  (∀ i, 0 < v i) ∧ 0 < θ ∧ ∀ i, (M.mulVec v) i ≤ θ * v i

def HasContractiveDoob {n : Nat} (M : Matrix (Fin n) (Fin n) Rat) : Prop :=
  ∃ v : Fin n → Rat, ∃ θ : Rat, θ < 1 ∧ IsSubinvariantCertificate M v θ

/-- Active support size after L=11 surgical cut. -/
def nComp : Nat := 140

/-- Nilpotency index (numeric witness used to build v). -/
def nilpotencyIndex : Nat := 6

/-- Sparse nonzero entries `(i, j, Mᵢⱼ)`. -/
def Mnz : List (Nat × Nat × Rat) := [
  (0, 99, (27 : Rat) / 32),
  (1, 137, (27 : Rat) / 32),
  (2, 62, (27 : Rat) / 32),
  (3, 71, (27 : Rat) / 32),
  (4, 127, (81 : Rat) / 32),
  (5, 99, (27 : Rat) / 32),
  (6, 36, (27 : Rat) / 32),
  (7, 55, (81 : Rat) / 32),
  (8, 107, (27 : Rat) / 32),
  (9, 134, (27 : Rat) / 32),
  (10, 61, (27 : Rat) / 32),
  (11, 73, (27 : Rat) / 32),
  (12, 95, (9 : Rat) / 32),
  (13, 100, (27 : Rat) / 32),
  (14, 137, (27 : Rat) / 32),
  (15, 18, (27 : Rat) / 32),
  (16, 41, (81 : Rat) / 32),
  (17, 55, (81 : Rat) / 32),
  (18, 81, (27 : Rat) / 32),
  (19, 111, (81 : Rat) / 32),
  (20, 120, (81 : Rat) / 32),
  (21, 137, (27 : Rat) / 32),
  (22, 62, (27 : Rat) / 32),
  (23, 71, (27 : Rat) / 32),
  (24, 126, (27 : Rat) / 32),
  (24, 127, (81 : Rat) / 32),
  (25, 40, (27 : Rat) / 32),
  (26, 67, (81 : Rat) / 32),
  (27, 72, (81 : Rat) / 32),
  (28, 94, (81 : Rat) / 32),
  (28, 95, (9 : Rat) / 32),
  (28, 97, (27 : Rat) / 32),
  (29, 112, (27 : Rat) / 32),
  (30, 123, (81 : Rat) / 32),
  (31, 124, (27 : Rat) / 32),
  (32, 130, (27 : Rat) / 32),
  (33, 138, (27 : Rat) / 32),
  (34, 37, (9 : Rat) / 32),
  (35, 51, (27 : Rat) / 32),
  (36, 71, (27 : Rat) / 32),
  (37, 74, (81 : Rat) / 32),
  (37, 78, (27 : Rat) / 32),
  (38, 93, (27 : Rat) / 32),
  (39, 105, (81 : Rat) / 32),
  (40, 127, (81 : Rat) / 32),
  (41, 129, (9 : Rat) / 32),
  (42, 134, (27 : Rat) / 32),
  (43, 55, (81 : Rat) / 32),
  (44, 107, (27 : Rat) / 32),
  (45, 133, (9 : Rat) / 32),
  (45, 134, (27 : Rat) / 32),
  (46, 25, (81 : Rat) / 32),
  (47, 56, (9 : Rat) / 32),
  (47, 57, (27 : Rat) / 32),
  (48, 63, (27 : Rat) / 32),
  (49, 96, (27 : Rat) / 32),
  (50, 107, (27 : Rat) / 32),
  (51, 110, (27 : Rat) / 32),
  (52, 122, (9 : Rat) / 32),
  (53, 134, (27 : Rat) / 32),
  (54, 19, (27 : Rat) / 32),
  (55, 61, (27 : Rat) / 32),
  (57, 83, (27 : Rat) / 32),
  (58, 100, (27 : Rat) / 32),
  (58, 101, (27 : Rat) / 32),
  (58, 102, (81 : Rat) / 32),
  (60, 10, (81 : Rat) / 32),
  (62, 81, (27 : Rat) / 32),
  (64, 111, (81 : Rat) / 32),
  (65, 107, (27 : Rat) / 32),
  (66, 134, (27 : Rat) / 32),
  (67, 137, (27 : Rat) / 32),
  (68, 18, (27 : Rat) / 32),
  (69, 41, (81 : Rat) / 32),
  (70, 86, (81 : Rat) / 32),
  (70, 87, (81 : Rat) / 32),
  (71, 111, (81 : Rat) / 32),
  (72, 99, (27 : Rat) / 32),
  (73, 9, (81 : Rat) / 32),
  (75, 22, (243 : Rat) / 32),
  (76, 38, (27 : Rat) / 32),
  (77, 47, (81 : Rat) / 32),
  (78, 55, (81 : Rat) / 32),
  (79, 59, (27 : Rat) / 32),
  (80, 84, (27 : Rat) / 32),
  (82, 103, (9 : Rat) / 32),
  (83, 107, (27 : Rat) / 32),
  (84, 108, (27 : Rat) / 32),
  (85, 115, (27 : Rat) / 32),
  (86, 135, (27 : Rat) / 32),
  (87, 137, (27 : Rat) / 32),
  (88, 92, (81 : Rat) / 32),
  (89, 95, (9 : Rat) / 32),
  (90, 116, (9 : Rat) / 32),
  (91, 125, (81 : Rat) / 32),
  (94, 18, (27 : Rat) / 32),
  (97, 55, (81 : Rat) / 32),
  (98, 66, (81 : Rat) / 32),
  (99, 111, (81 : Rat) / 32),
  (104, 123, (81 : Rat) / 32),
  (106, 71, (27 : Rat) / 32),
  (107, 126, (27 : Rat) / 32),
  (107, 127, (81 : Rat) / 32),
  (109, 72, (81 : Rat) / 32),
  (112, 124, (27 : Rat) / 32),
  (113, 138, (27 : Rat) / 32),
  (114, 57, (27 : Rat) / 32),
  (115, 71, (27 : Rat) / 32),
  (116, 78, (27 : Rat) / 32),
  (117, 101, (27 : Rat) / 32),
  (117, 102, (81 : Rat) / 32),
  (118, 127, (81 : Rat) / 32),
  (119, 134, (27 : Rat) / 32),
  (121, 107, (27 : Rat) / 32),
  (123, 133, (9 : Rat) / 32),
  (123, 134, (27 : Rat) / 32),
  (125, 36, (27 : Rat) / 32),
  (125, 38, (27 : Rat) / 32),
  (128, 63, (27 : Rat) / 32),
  (128, 64, (27 : Rat) / 32),
  (131, 137, (27 : Rat) / 32),
  (132, 19, (27 : Rat) / 32),
  (136, 139, (27 : Rat) / 32)
]

def lookup (i j : Nat) : Rat :=
  match Mnz.find? (fun t => t.1 = i ∧ t.2.1 = j) with
  | some t => t.2.2
  | none => 0

def MComp : Matrix (Fin nComp) (Fin nComp) Rat :=
  Matrix.of fun i j => lookup i.val j.val

def vArr : Array Nat := #[
  2944000, 704512, 1451008, 2944000, 1589248, 2944000, 5230144, 3828736, 3690496, 704512, 704512, 6723136, 409600, 704512, 704512, 1451008, 2335744, 3828736, 704512, 1589248,
  1589248, 704512, 1451008, 2944000, 2031616, 2944000, 3828736, 15166144, 14216320, 1451008, 4575232, 704512, 704512, 704512, 4790404, 1451008, 2944000, 8050240, 704512, 1589248,
  1589248, 409600, 704512, 3828736, 3690496, 851968, 15166144, 11361232, 704512, 704512, 3690496, 704512, 409600, 704512, 2944000, 704512, 262144, 6489856, 2473984, 262144,
  3828736, 262144, 704512, 262144, 1589248, 3690496, 704512, 704512, 1451008, 2335744, 7395328, 1589248, 2944000, 3828736, 262144, 22299328, 1451008, 57778381, 3828736, 704512,
  1451008, 262144, 409600, 3690496, 704512, 5230144, 704512, 704512, 1589248, 409600, 4043908, 32758372, 262144, 262144, 1451008, 262144, 262144, 3828736, 3828736, 1589248,
  262144, 262144, 262144, 262144, 4575232, 262144, 2944000, 2031616, 262144, 15166144, 262144, 262144, 704512, 704512, 11213776, 2944000, 6723136, 2031616, 1589248, 704512,
  262144, 3690496, 262144, 851968, 262144, 6419008, 262144, 262144, 3386368, 262144, 262144, 704512, 2944000, 262144, 262144, 262144, 704512, 262144, 262144, 262144
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

end KeplerHurwitz.Collatz.CompositeCert_M3M2_L11_Surgery
