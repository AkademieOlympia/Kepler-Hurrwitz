import Mathlib
import KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
import KeplerHurwitz.Collatz.H7Mod256Separation

/-!
# H7Mod256 — Einwertigkeit der odd-u Step-6-Kante auf Fin 256?

Separates Projekt vom versiegelten H7-mod-128-Zustandsgraphen und vom
Trennungs-Milestone (`H7Mod256Separation`).

## Governance
- [A] gezielte Einwertigkeits- / Mehrwertigkeits-Lemmata fuer die odd-`u`/odd-`v`-Familie.
- [B] Scan (`h7_mod256_single_valued_scan.py`) motiviert den Verdict; ersetzt keine Beweise.
- Trennung mod 128→256 ≠ Einwertigkeit Fin 256→Fin 256.
- Kein `H7StateGraph256`, solange Fin-256-Einwertigkeit fehlt.
- Kein globaler Collatz-Claim.

## Verdict (dieses Modul)
Die affine Familie `u = 4w+3`, `S⁶ = 1458w + 1171` ist **nicht** einwertig als
`Fin 256 → Fin 256`: `u` und `u+256` kollidieren in der Restklasse, liefern aber
verschiedene Bilder mod 256 (Witness `u = 3` vs `u = 259`: `147` vs `19`).

Ursache: `v₂(1458) = 1`, daher `1458·64 ≡ 128 ≢ 0 (mod 256)`.
-/

namespace KeplerHurwitz.Collatz.H7Mod256SingleValued

open KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
open KeplerHurwitz.Collatz.H7Mod256Separation

/-! ## Affine Verschiebung `w ↦ w+64` (entspricht `u ↦ u+256`) -/

/-- Differenz der affinen Terminals bei `w` und `w+64`. -/
theorem step6_odd_u_odd_v_affine_shift64 (w : Nat) :
    1458 * (w + 64) + 1171 = (1458 * w + 1171) + 93312 := by
  ring

/-- `93312 ≡ 128 (mod 256)` — nicht Null, daher bricht Fin-256-Einwertigkeit. -/
theorem step6_odd_u_odd_v_shift64_mod256 : (93312 : Nat) % 256 = 128 := by
  decide

/--
`[A]` Uniform: in der Familie `S⁶ = 1458w + 1171` unterscheiden sich die Bilder
bei `w` und `w+64` (entspricht `u` und `u+256` für `u = 4w+3`) bereits mod 256.
-/
theorem step6_odd_u_odd_v_affine_multi_valued_mod256 (w : Nat) :
    (1458 * w + 1171) % 256 ≠ (1458 * (w + 64) + 1171) % 256 := by
  rw [step6_odd_u_odd_v_affine_shift64 w]
  have hd : (93312 : Nat) % 256 ≠ 0 := by
    rw [step6_odd_u_odd_v_shift64_mod256]
    decide
  exact (nat_add_mod_ne_of_mod_ne_zero (by decide : 0 < 256) hd).symm

/--
`[A]` Dieselbe Aussage über den Parameter `u = 4w+3`:
`u` und `u+256` haben verschiedene Step-6-Bilder mod 256 auf dem odd-`u`/odd-`v`-Zweig.
-/
theorem step6_odd_u_odd_v_u_and_u_add256_multi_valued_mod256 (w : Nat) :
    syracuseOddStep (step5Terminal (4 * w + 3)) % 256 ≠
      syracuseOddStep (step5Terminal (4 * w + 3 + 256)) % 256 := by
  have h0 := step6_odd_u_odd_v_terminal w
  have h64 := step6_odd_u_odd_v_terminal (w + 64)
  have hu : (4 * w + 3 : Nat) = 2 * (2 * w + 1) + 1 := by ring
  have hu256 : (4 * w + 3 + 256 : Nat) = 2 * (2 * (w + 64) + 1) + 1 := by ring
  have hterm0 : syracuseOddStep (step5Terminal (4 * w + 3)) = 1458 * w + 1171 := by
    simpa [hu] using h0
  have hterm64 :
      syracuseOddStep (step5Terminal (4 * w + 3 + 256)) = 1458 * (w + 64) + 1171 := by
    simpa [hu256] using h64
  rw [hterm0, hterm64]
  exact step6_odd_u_odd_v_affine_multi_valued_mod256 w

/-! ## Dokumentiertes Gegenbeispiel `u = 3` vs `u = 259` -/

/--
`[A]` Gleiche Restklasse mod 256, verschiedene Step-6-Bilder mod 256:
`1171 % 256 = 147` vs `(1458·64 + 1171) % 256 = 19`.
-/
theorem h7_step6_odd_u_pair_3_259_multi_valued_mod256 :
    (3 : Nat) % 256 = 259 % 256 ∧
      (3 : Nat) % 4 = 3 ∧
        (259 : Nat) % 4 = 3 ∧
          syracuseOddStep (step5Terminal 3) % 256 ≠
            syracuseOddStep (step5Terminal 259) % 256 := by
  refine ⟨by decide, by decide, by decide, ?_⟩
  -- 259 = 4*0+3+256
  simpa using step6_odd_u_odd_v_u_and_u_add256_multi_valued_mod256 0

/--
[A] Explizite Zahlenform (Anschluss an den [B]-Export):
Bilder `147` vs `19`.
-/
theorem h7_step6_odd_u_pair_3_259_images_mod256 :
    syracuseOddStep (step5Terminal 3) % 256 = 147 ∧
      syracuseOddStep (step5Terminal 259) % 256 = 19 := by
  have h0 := step6_odd_u_odd_v_terminal 0
  have h64 := step6_odd_u_odd_v_terminal 64
  norm_num at h0 h64
  -- 3 = 2*(2*0+1)+1, 259 = 2*(2*64+1)+1
  have h3 : syracuseOddStep (step5Terminal 3) = 1458 * 0 + 1171 := by
    simpa using h0
  have h259 : syracuseOddStep (step5Terminal 259) = 1458 * 64 + 1171 := by
    -- 259 = 4*64+3 = 2*(2*64+1)+1
    have hu : (259 : Nat) = 2 * (2 * 64 + 1) + 1 := by decide
    simpa [hu] using h64
  rw [h3, h259]
  decide

/--
`[A]` Negation der Fin-256-Einwertigkeitsclaim auf der odd-`u`/odd-`v`-Familie.
-/
theorem step6_odd_u_odd_v_not_single_valued_mod256 :
    ¬ (∀ u₁ u₂ : Nat,
        u₁ % 4 = 3 →
          u₂ % 4 = 3 →
            u₁ % 256 = u₂ % 256 →
              syracuseOddStep (step5Terminal u₁) % 256 =
                syracuseOddStep (step5Terminal u₂) % 256) := by
  intro h
  have hne := (h7_step6_odd_u_pair_3_259_multi_valued_mod256).2.2.2
  exact hne (h 3 259 (by decide) (by decide) (by decide))

/-! ## Optionale Eskalationsnotiz: Domain 512 → Bild mod 256 -/

/-- `1458·128 ≡ 0 (mod 256)` — ein Bit mehr im Domain genügt für Bild-Kongruenz mod 256. -/
theorem step6_odd_u_odd_v_shift128_mod256 : (1458 * 128 : Nat) % 256 = 0 := by
  decide

theorem step6_odd_u_odd_v_affine_shift128 (w : Nat) :
    1458 * (w + 128) + 1171 = (1458 * w + 1171) + 1458 * 128 := by
  ring

/--
`[A]` In der affinen Familie sind `w` und `w+128` (entspricht `u` und `u+512`)
bereits kongruent mod 256 im Bild — nötig für Domain-mod-512 / Bild-mod-256,
**nicht** fuer `Fin 512 → Fin 512`.
-/
theorem step6_odd_u_odd_v_affine_congruent_mod256_of_add128 (w : Nat) :
    (1458 * w + 1171) % 256 = (1458 * (w + 128) + 1171) % 256 := by
  rw [step6_odd_u_odd_v_affine_shift128 w]
  have hdiv : 256 ∣ 1458 * 128 :=
    Nat.dvd_of_mod_eq_zero step6_odd_u_odd_v_shift128_mod256
  obtain ⟨k, hk⟩ := hdiv
  rw [hk, Nat.add_mul_mod_self_left]

/-- Erinnerung: Trennung bei `u` vs `u+128` bleibt bestehen (Pointer). -/
theorem h7_mod256_separation_still_holds (w : Nat) :
    (1458 * w + 1171) % 256 ≠ (1458 * (w + 32) + 1171) % 256 :=
  step6_odd_u_odd_v_affine_separates_mod256 w

/-!
## Governance-Folgerung
Kein einwertiger `Fin 256 → Fin 256`-Kantenbegriff fuer die odd-`u`/odd-`v`-Familie.
Kein `H7StateGraph256`-Scaffold auf dieser Basis.
Nächster diagnostischer Kandidat: Domain mod 512 mit Bild mod 256 (empirisch einwertig
im [B]-Scan) — separates Projekt, kein automatischer Fin-512-Graph.
-/

end KeplerHurwitz.Collatz.H7Mod256SingleValued
