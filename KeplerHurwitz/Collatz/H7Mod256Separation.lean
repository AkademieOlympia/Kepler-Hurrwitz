import Mathlib
import KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
import KeplerHurwitz.Collatz.H7StateGraph

/-!
# H7Mod256 - Trennung der mod-128-Kollisionspaare bei 8 Bit

Separates Projekt vom versiegelten H7-mod-128-Zustandsgraphen
(H7StateGraph, notes/h7_mod128_state_graph.md).

## Governance
- [A] gezielte Restklassen- und Affine-Lemmata fuer die dokumentierte Obstruktionsfamilie.
- [B] Scan (h7_mod256_separation_scan.py) motiviert den Modulus-Lift; ersetzt keine Beweise.
- Kein H7StateGraph256 in diesem Modul.
- Kein globaler Collatz-Claim.

## Pointer auf die versiegelte Obstruktion
H7StateGraph.h7_step6_odd_u_branch_precision_obstruction:
u = 3 und u = 131 sind beide ≡ 3 (mod 128) und ungerade, liefern aber
verschiedene Bilder mod 128 unter syracuseOddStep ∘ step5Terminal (19 vs 83).

Dieses Modul zeigt: dieselben Paare (und die affine Familie u = 4w+3)
sind bereits mod 256 getrennt - notwendige Vorbedingung fuer einen
kuenftigen einwertigen Fin-256-Kantenbegriff auf diesem Zweig.
-/

namespace KeplerHurwitz.Collatz.H7Mod256Separation

open KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
open KeplerHurwitz.Collatz.H7StateGraph

/-! ## Affine Familie `u = 4w+3`: `S⁶ = 1458w + 1171` -/

/-- Differenz zwischen den affinen Terminals bei `w` und `w+32` (Lift um 128 in `u`). -/
theorem step6_odd_u_odd_v_affine_shift32 (w : Nat) :
    1458 * (w + 32) + 1171 = (1458 * w + 1171) + 46656 := by
  ring

/-- `46656 ≡ 64 (mod 256)` — nicht Null, daher trennt der Lift `u ↦ u+128`. -/
theorem step6_odd_u_odd_v_shift_mod256 : (46656 : Nat) % 256 = 64 := by
  decide

/--
Elementares Restklassenlemma: wenn `d % m ≠ 0`, dann `(x + d) % m ≠ x % m`.
-/
theorem nat_add_mod_ne_of_mod_ne_zero {x d m : Nat} (hm : 0 < m) (hd : d % m ≠ 0) :
    (x + d) % m ≠ x % m := by
  intro h
  have hcongr := Nat.add_mod x d m
  have ha : x % m < m := Nat.mod_lt x hm
  have hb : d % m < m := Nat.mod_lt d hm
  have h0 : (x % m + d % m) % m = x % m := by
    rw [← hcongr, h]
  by_cases hlt : x % m + d % m < m
  · have heq : (x % m + d % m) % m = x % m + d % m := Nat.mod_eq_of_lt hlt
    omega
  · have hge : m ≤ x % m + d % m := Nat.not_lt.mp hlt
    have heq : (x % m + d % m) % m = x % m + d % m - m := by
      rw [Nat.mod_eq_sub_mod hge]
      exact Nat.mod_eq_of_lt (by omega)
    omega

/--
`[A]` Uniform: in der Familie `S⁶ = 1458w + 1171` unterscheiden sich die Bilder
bei `w` und `w+32` (entspricht `u` und `u+128` für `u = 4w+3`) bereits mod 256.
-/
theorem step6_odd_u_odd_v_affine_separates_mod256 (w : Nat) :
    (1458 * w + 1171) % 256 ≠ (1458 * (w + 32) + 1171) % 256 := by
  rw [step6_odd_u_odd_v_affine_shift32 w]
  have hd : (46656 : Nat) % 256 ≠ 0 := by
    rw [step6_odd_u_odd_v_shift_mod256]
    decide
  exact (nat_add_mod_ne_of_mod_ne_zero (by decide : 0 < 256) hd).symm

/--
`[A]` Dieselbe Aussage über den Parameter `u = 4w+3`:
`u` und `u+128` haben verschiedene Step-6-Bilder mod 256 auf dem odd-`u`/odd-`v`-Zweig.
-/
theorem step6_odd_u_odd_v_u_and_u_add128_separates_mod256 (w : Nat) :
    syracuseOddStep (step5Terminal (4 * w + 3)) % 256 ≠
      syracuseOddStep (step5Terminal (4 * w + 3 + 128)) % 256 := by
  have h0 := step6_odd_u_odd_v_terminal w
  have h32 := step6_odd_u_odd_v_terminal (w + 32)
  have hu : (4 * w + 3 : Nat) = 2 * (2 * w + 1) + 1 := by ring
  have hu128 : (4 * w + 3 + 128 : Nat) = 2 * (2 * (w + 32) + 1) + 1 := by ring
  have hterm0 : syracuseOddStep (step5Terminal (4 * w + 3)) = 1458 * w + 1171 := by
    simpa [hu] using h0
  have hterm32 :
      syracuseOddStep (step5Terminal (4 * w + 3 + 128)) = 1458 * (w + 32) + 1171 := by
    simpa [hu128] using h32
  rw [hterm0, hterm32]
  exact step6_odd_u_odd_v_affine_separates_mod256 w

/-! ## Dokumentiertes Gegenbeispiel `u = 3` vs `u = 131` -/

/--
`[A]` Das versiegelte Hindernispaar trennt sich bereits mod 256:
Bilder `1171 % 256 = 147` vs `47827 % 256 = 211`.
-/
theorem h7_step6_odd_u_pair_3_131_separates_mod256 :
    (3 : Nat) % 128 = 131 % 128 ∧
      syracuseOddStep (step5Terminal 3) % 256 ≠
        syracuseOddStep (step5Terminal 131) % 256 := by
  refine ⟨by decide, ?_⟩
  simpa using step6_odd_u_odd_v_u_and_u_add128_separates_mod256 0

/--
[A] Explizite Zahlenform (Anschluss an den [B]-Export):
1171 % 256 = 147 ≠ 211 = 47827 % 256.
-/
theorem h7_step6_odd_u_pair_3_131_images_mod256 :
    syracuseOddStep (step5Terminal 3) % 256 = 147 ∧
      syracuseOddStep (step5Terminal 131) % 256 = 211 := by
  have h0 := step6_odd_u_odd_v_terminal 0
  have h32 := step6_odd_u_odd_v_terminal 32
  -- 3 = 2*(2*0+1)+1, 131 = 2*(2*32+1)+1
  norm_num at h0 h32
  rw [h0, h32]
  decide

/-- Erinnerung: die Fin-128-Obstruktion bleibt bestehen (Pointer, kein neuer Beweis). -/
theorem h7_mod128_obstruction_still_holds :
    (3 : Nat) % 128 = 131 % 128 ∧
      syracuseOddStep (step5Terminal 3) % 128 ≠
        syracuseOddStep (step5Terminal 131) % 128 :=
  h7_step6_odd_u_branch_precision_obstruction

/-!
## Empfohlener nächster Schritt (nicht in diesem Modul)
Ein künftiger `H7StateGraph256` darf odd-`u`-Kanten nur dann als einwertige
`Fin 256 → Fin 256`-Relation einführen, wenn die Einwertigkeit pro Kantenfamilie
bewiesen ist. Dieses Modul liefert die notwendige Trennungsaussage für die
dokumentierte Obstruktionsfamilie — **nicht** den Graphen selbst.
-/

end KeplerHurwitz.Collatz.H7Mod256Separation
