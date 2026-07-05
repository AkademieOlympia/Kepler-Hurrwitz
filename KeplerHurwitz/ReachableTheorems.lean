import Mathlib
import KeplerHurwitz.CollatzNormShell
import KeplerHurwitz.InterferenceAttraktorBridge
import KeplerHurwitz.KeplerInvariants
import KeplerHurwitz.KleinCollapse
import KeplerHurwitz.CollatzProofAttemptV2
import KeplerHurwitz.CollatzProofAttemptV21
import KeplerHurwitz.CollatzProofAttemptV22
import KeplerHurwitz.CollatzProofAttemptV23
import KeplerHurwitz.CollatzProofAttemptV24
import KeplerHurwitz.CollatzProofAttemptV25
import KeplerHurwitz.CollatzProofAttemptV26
import KeplerHurwitz.CollatzProofAttemptV27
import KeplerHurwitz.Representation.Invariant
import KeplerHurwitz.Representation.EABCChronology
import KeplerHurwitz.SchuettePtolemyCaeda
import KeplerHurwitz.SymbolicResultants
import KeplerHurwitz.HalesTaoIntegration

namespace KeplerHurwitz

/--
Gebuendelter erreichbarer Basisfall aus der Collatz-Normschale.
-/
theorem reachable_collatz_pow_two_to_one (k : Nat) :
    Nat.iterate collatzStep k (2 ^ k) = 1 := by
  exact collatz_iterate_pow_two_to_one k

/--
Gebuendelte lokale Interferenz-Bridge auf Mod-12-Ebene.
-/
theorem reachable_local_interference_bridge :
    CanonicalInterferenceSelectsB11Local := by
  exact canonicalInterferenceSelectsB11Local_true

/--
Globale Bridge als abgeleitete Form unter Coverage-Annahme.
-/
theorem reachable_global_bridge_from_coverage
    (hcov : GlobalCoverageByCanonicalResidues) :
    InterferenceSelectsB11 := by
  exact global_bridge_of_canonical_coverage hcov

/--
Klein-Viererklassen-Wirkung der Collapse-Retraktion.
-/
theorem reachable_collapse_klein_channel_cases
    {n : Nat} (d : OddCoreDecomposition n) :
    (d.m % 8 = 1 ∧ eSchalenSprung d.m = 2) ∨
    (d.m % 8 = 3 ∧ eSchalenSprung d.m = 1) ∨
    (d.m % 8 = 5 ∧ 3 ≤ eSchalenSprung d.m) ∨
    (d.m % 8 = 7 ∧ eSchalenSprung d.m = 1) := by
  exact collapse_effect_channel_cases d

/--
Kepler-Kernrelation im gueltigen Parameterbereich.
-/
theorem reachable_kepler_speed_ratio
    {a e : ℝ} (ha : 0 < a) (he0 : 0 ≤ e) (he1 : e < 1) :
    radiusRatio e = perihelionSpeed a e / aphelionSpeed a e := by
  exact radiusRatio_eq_speedRatio ha he0 he1

/--
Hales/Tao-Seed-Schnittstelle ist als Infrastruktur integriert.
-/
theorem reachable_hales_seed_interface : IsIntegrated halesSeedNode := by
  exact halesSeedNode_integrated

theorem reachable_tao_seed_interface : IsIntegrated taoSeedNode := by
  exact taoSeedNode_integrated

/--
Schuette-und-Caeda-Basiszugang: Iso-Caeda ist fuer Modellzustaende sofort erfuellt.
-/
theorem reachable_iso_caeda
    {M : SchuetteTensionModel} (s : M.State) :
    IsoCaeda s := by
  exact isoCaeda_of_state s

/--
Symbolic-Resultants: simultane Interferenznullstelle.
-/
theorem reachable_interference_simultaneous_zero :
    Polynomial.eval (-((5 : ℚ) / 2)) resultantMu = 0 ∧
      Polynomial.eval ((15 : ℚ) / 4) resultantS = 0 := by
  exact interference_point_simultaneous_zero

/--
Neuer Collatz-V2-Schritt: mod-4-Fall `1` liefert strikten Abstieg des ungeraden Kerns.
-/
theorem reachable_collatz_attempt_v2_mod4_case
    {n : Nat} (hn : 1 < n) (hmod : n % 4 = 1) :
    (3 * n + 1) / 4 < n := by
  exact three_mul_add_one_quarter_lt_of_mod4_eq_one hn hmod

/--
V2-Split fuer den offenen `mod 4 = 3`-Zweig:
Nach dem ungeraden Beschleunigungsschritt liegt entweder ein guter Zweig
(`mod 4 = 1` mit lokalem Shrink) oder der offene Zweig (`mod 4 = 3`) vor.
-/
theorem reachable_collatz_attempt_v2_mod4_three_good_or_open
    {n : Nat} (hn : 1 < n) (hmod : n % 4 = 3) :
    (CollatzAttemptV2.T_odd n % 4 = 1 ∧
      (3 * CollatzAttemptV2.T_odd n + 1) / 4 < CollatzAttemptV2.T_odd n)
      ∨
    CollatzAttemptV2.T_odd n % 4 = 3 := by
  exact CollatzAttemptV2.mod4_eq_three_then_good_or_open hn hmod

/--
V2.1 bad-run-Verfeinerung: `15 mod 16` faellt unter `T_odd` auf `7 mod 8`.
-/
theorem reachable_collatz_attempt_v2_bad_run_mod16
    {n : Nat} (hmod : n % 16 = 15) :
    CollatzAttemptV2.T_odd n % 8 = 7 := by
  exact CollatzAttemptV2.BadRuns.T_odd_mod8_eq_seven_of_mod16_eq_fifteen hmod

/--
V2.1 bad-run-Verfeinerung: `31 mod 32` faellt unter `T_odd` auf `15 mod 16`.
-/
theorem reachable_collatz_attempt_v2_bad_run_mod32
    {n : Nat} (hmod : n % 32 = 31) :
    CollatzAttemptV2.T_odd n % 16 = 15 := by
  exact CollatzAttemptV2.BadRuns.T_odd_mod16_eq_fifteen_of_mod32_eq_thirtyone hmod

/--
V2.1 bad-run-Verfeinerung: `63 mod 64` faellt unter `T_odd` auf `31 mod 32`.
-/
theorem reachable_collatz_attempt_v2_bad_run_mod64
    {n : Nat} (hmod : n % 64 = 63) :
    CollatzAttemptV2.T_odd n % 32 = 31 := by
  exact CollatzAttemptV2.BadRuns.T_odd_mod32_eq_thirtyone_of_mod64_eq_sixtythree hmod

/--
V2.1 Kettenlemma: `63 mod 64` liefert nach drei `T_odd`-Schritten `7 mod 8`.
-/
theorem reachable_collatz_attempt_v2_bad_run_chain_64_to_8
    {n : Nat} (hmod : n % 64 = 63) :
    CollatzAttemptV2.T_odd
      (CollatzAttemptV2.T_odd
        (CollatzAttemptV2.T_odd n)) % 8 = 7 := by
  exact CollatzAttemptV2.BadRuns.T_odd_three_mod8_eq_seven_of_mod64_eq_sixtythree hmod

/--
Allgemeiner lokaler 2-adischer bad-run-Descent:
`-1 mod 2^m` geht unter `T_odd` auf `-1 mod 2^(m-1)` ueber.
-/
theorem reachable_collatz_attempt_v21_bad_residue_descends
    {m n : Nat}
    (hm : 3 ≤ m)
    (hmod : n % (2 ^ m) = 2 ^ m - 1) :
    CollatzAttemptV2.T_odd n % (2 ^ (m - 1)) = 2 ^ (m - 1) - 1 := by
  exact CollatzAttemptV2.BadRuns.T_odd_bad_residue_descends hm hmod

/--
V2.1: Iterierte bad-run-Descent-Kette bis Tiefe `m - 3` ist erfuellt.
-/
theorem reachable_collatz_attempt_v21_iterated_bad_run_descent :
    CollatzAttemptV2.BadRuns.BadRunIteratedDescentStatement := by
  exact CollatzAttemptV2.BadRuns.bad_run_iterated_descent_statement_holds

/--
V2.1: Endpunkt der iterierten bad-run-Kette liegt in `3 mod 4`.
-/
theorem reachable_collatz_attempt_v21_iterated_endpoint_mod4 :
    CollatzAttemptV2.BadRuns.BadRunIteratedEndpointMod4Statement := by
  exact CollatzAttemptV2.BadRuns.bad_run_iterated_endpoint_mod4_statement_holds

/--
V2.2: Exit `3 mod 8` fuehrt in den guten `1 mod 4`-Shrink-Zweig.
-/
theorem reachable_collatz_attempt_v22_exit_mod8_to_good_branch :
    CollatzAttemptV2.ExitClasses.BadRunExitToGoodBranchStatement := by
  exact CollatzAttemptV2.ExitClasses.bad_run_exit_to_good_branch_statement_holds

/--
V2.2: Level-Exit-Residuum iteriert zur finalen Klasse `3 mod 8`.
-/
theorem reachable_collatz_attempt_v22_level_exit_iterates_to_mod8_three
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : CollatzAttemptV2.ExitClasses.LevelExitResidue m n) :
    (CollatzAttemptV2.T_odd^[m - 3]) n % 8 = 3 := by
  exact CollatzAttemptV2.ExitClasses.level_exit_residue_iterates_to_mod8_three hm hexit

/--
V2.2: Level-Exit-Residuum fuehrt in den guten Shrink-Zweig auf dem Exit-Tail.
Lokal: `(3 * T_odd x + 1) / 4 < T_odd x` fuer `x = T_odd^[m-3] n`, kein globaler Abstieg unter `n`.
-/
theorem reachable_collatz_attempt_v22_level_exit_eventually_good_branch_shrink
    {m n : Nat}
    (hm : 4 ≤ m)
    (hexit : CollatzAttemptV2.ExitClasses.LevelExitResidue m n) :
    (3 * CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[m - 3]) n) + 1) / 4
      < CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[m - 3]) n) := by
  exact
    CollatzAttemptV2.ExitClasses.level_exit_residue_eventually_good_branch_shrink_of_level_exit
      hm hexit

/--
V2.3: Exakte Bad-Run-Tiefe `d ≥ 3` fuehrt nach `d-2` Odd-Schritten in den lokalen Shrink-Zweig.
-/
theorem reachable_collatz_attempt_v23_bad_run_depth_eventually_good_branch_shrink
    {d n : Nat}
    (hd : 3 ≤ d)
    (hdepth : CollatzAttemptV2.ExitDepth.BadRunDepth d n) :
    (3 * CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[d - 2]) n) + 1) / 4
      < CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[d - 2]) n) := by
  exact
    CollatzAttemptV2.ExitDepth.bad_run_depth_eventually_good_branch_shrink
      hd
      hdepth

/--
V2.3: Einheitliche Bad-Run-Tiefen-Aussage fuer alle `d ≥ 2`.
-/
theorem reachable_collatz_attempt_v23_bad_run_depth_statement :
    CollatzAttemptV2.ExitDepth.BadRunDepthStatement := by
  exact CollatzAttemptV2.ExitDepth.bad_run_depth_statement_holds

/--
V2.4: Regression — `3 mod 8` hat exakte Bad-Run-Tiefe `2`.
-/
theorem reachable_collatz_attempt_v24_mod8_three_has_bad_run_depth_two
    {n : Nat}
    (hmod : n % 8 = 3) :
    CollatzAttemptV2.ExitDepth.BadRunDepth 2 n := by
  exact CollatzAttemptV2.DepthExtraction.mod8_three_has_bad_run_depth_two hmod

/--
V2.4: Regression — `7 mod 16` hat exakte Bad-Run-Tiefe `3`.
-/
theorem reachable_collatz_attempt_v24_mod16_seven_has_bad_run_depth_three
    {n : Nat}
    (hmod : n % 16 = 7) :
    CollatzAttemptV2.ExitDepth.BadRunDepth 3 n := by
  exact CollatzAttemptV2.DepthExtraction.mod16_seven_has_bad_run_depth_three hmod

/--
V2.4: Regression — `15 mod 32` hat exakte Bad-Run-Tiefe `4`.
-/
theorem reachable_collatz_attempt_v24_mod32_fifteen_has_bad_run_depth_four
    {n : Nat}
    (hmod : n % 32 = 15) :
    CollatzAttemptV2.ExitDepth.BadRunDepth 4 n := by
  exact CollatzAttemptV2.DepthExtraction.mod32_fifteen_has_bad_run_depth_four hmod

/--
V2.4: Exakte 2-adische Tiefe von `n+1` impliziert `BadRunDepth d n`.
-/
theorem reachable_collatz_attempt_v24_exact_depth_implies_bad_run_depth
    {d n : Nat}
    (h : CollatzAttemptV2.DepthExtraction.ExactTwoAdicDepthOfSucc d n) :
    CollatzAttemptV2.ExitDepth.BadRunDepth d n := by
  exact CollatzAttemptV2.DepthExtraction.exact_two_adic_depth_of_succ_implies_bad_run_depth h

/--
V2.5: Exakte 2-adische Tiefenextraktion fuer `n % 4 = 3` (via `padicValNat`).
-/
theorem reachable_collatz_attempt_v25_exact_two_adic_depth_extraction :
    CollatzAttemptV2.DepthExtraction.ExactTwoAdicDepthExtractionStatement := by
  exact CollatzAttemptV2.ProofAttempt.exact_two_adic_depth_extraction_statement_holds

/--
V2.5: Bad-Run-Tiefenextraktion fuer `n % 4 = 3`.
-/
theorem reachable_collatz_attempt_v25_bad_run_depth_extraction :
    CollatzAttemptV2.DepthExtraction.BadRunDepthExtractionStatement := by
  exact CollatzAttemptV2.ProofAttempt.bad_run_depth_extraction_statement_holds

/--
V2.5: Schlechter Zweig `mod 4 = 3` erreicht lokalen Shrink-Zweig.
-/
theorem reachable_collatz_attempt_v25_bad_branch_local_shrink
    {n : Nat}
    (hmod : n % 4 = 3) :
    ∃ d : Nat,
      2 ≤ d ∧
      (3 * CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[d - 2]) n) + 1) / 4
        < CollatzAttemptV2.T_odd ((CollatzAttemptV2.T_odd^[d - 2]) n) := by
  exact CollatzAttemptV2.ProofAttempt.mod4_eq_three_has_eventually_local_shrink hmod

/--
V2.5: Status-Buendel des Collatz-Beweisversuchs (lokal bewiesen, global offen).
-/
theorem reachable_collatz_proof_attempt_status :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatus := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status

/--
V2.6: Zwei `collatzStep`-Schritte entsprechen einem `T_odd`-Schritt (ungerade Startwerte).
-/
theorem reachable_collatz_two_steps_eq_T_odd
    {n : Nat}
    (ho : n % 2 = 1) :
    (collatzStep^[2]) n = CollatzAttemptV2.T_odd n := by
  exact CollatzAttemptV2.CollatzBridge.collatz_two_steps_eq_T_odd ho

/--
V2.6: Aus `mod 4 = 3` erreicht eine endliche `collatzStep`-Iteration den Good-Branch `mod 4 = 1`.
Lokal only — kein globaler Wertabstieg.
-/
theorem reachable_collatz_mod4_three_eventually_mod4_one
    {n : Nat}
    (hmod : n % 4 = 3) :
    ∃ t, (collatzStep^[t]) n % 4 = 1 := by
  exact CollatzAttemptV2.ProofAttempt.mod4_three_eventually_mod4_one hmod

/--
V2.6: Erweitertes Status-Buendel inkl. collatzStep-Bruecke (global weiterhin offen).
-/
theorem reachable_collatz_proof_attempt_status_v26 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV26 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v26

/--
V2.7: Good-Branch `mod 4 = 1` liefert strikten `collatzStep`-Abstieg in drei Schritten.
-/
theorem reachable_collatz_good_branch_collatz_local_shrink
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 1) :
    (collatzStep^[3]) n < n := by
  exact CollatzAttemptV2.CollatzNetDescent.good_branch_collatz_local_shrink hn hmod

/--
V2.7 `[A]`: Net-Descent-Zeuge liefert echten `collatzStep`-Abstieg fuer `mod 4 = 3`.
-/
theorem reachable_collatz_mod4_three_descends_from_net_descent_witness
    {n : Nat}
    (hmod : n % 4 = 3)
    (w : CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentWitness n) :
    ∃ t, (collatzStep^[t]) n < n := by
  exact
    CollatzAttemptV2.CollatzNetDescent.mod4_three_descends_from_net_descent_witness hmod w

/--
V2.7: V2.6-Good-Branch-Eintritt als Zeugenstruktur (ohne Netto-Shrink).
-/
theorem reachable_collatz_bad_run_good_branch_entry_of_mod4_three
    {n : Nat}
    (hmod : n % 4 = 3) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.BadRunGoodBranchEntryWitness n) := by
  exact ⟨CollatzAttemptV2.ProofAttempt.bad_run_good_branch_entry_of_mod4_three hmod⟩

/--
V2.7 `[A]`: Net-Descent-Zeugen schliessen den offenen `mod 4 = 3`-Abstieg.
-/
theorem reachable_collatz_mod4_three_eventually_descends_of_net_descent
    (h : CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement) :
    CollatzAttemptV2.ProofAttempt.Mod4ThreeEventuallyDescendsStatement := by
  exact CollatzAttemptV2.CollatzNetDescent.mod4_three_eventually_descends_of_net_descent h

/--
V2.7 `[A]`: Net-Descent-Zeugen schliessen `CollatzAttemptV2OpenCase`.
-/
theorem reachable_collatz_open_case_of_net_descent
    (h : CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement) :
    CollatzAttemptV2OpenCase := by
  exact CollatzAttemptV2.CollatzNetDescent.bad_run_net_descent_implies_collatz_open_case h

/--
V2.7: Erweitertes Status-Buendel inkl. Net-Descent-Kompositionsschicht.
-/
theorem reachable_collatz_proof_attempt_status_v27 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV27 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v27

/--
Darstellungstheorie: Schnitt-Invarianz ist erreichbar.
-/
theorem reachable_representation_inf_invariant
    {G : Type*} [Group G]
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V]
    (ρ : LinearRepresentation G K V)
    {W₁ W₂ : Submodule K V}
    (hW₁ : ρ.IsInvariant W₁)
    (hW₂ : ρ.IsInvariant W₂) :
    ρ.IsInvariant (W₁ ⊓ W₂) := by
  exact LinearRepresentation.isInvariant_inf (ρ := ρ) hW₁ hW₂

/--
Darstellungstheorie: Summen-Invarianz ist erreichbar.
-/
theorem reachable_representation_sup_invariant
    {G : Type*} [Group G]
    {K : Type*} [Field K]
    {V : Type*} [AddCommGroup V] [Module K V]
    (ρ : LinearRepresentation G K V)
    {W₁ W₂ : Submodule K V}
    (hW₁ : ρ.IsInvariant W₁)
    (hW₂ : ρ.IsInvariant W₂) :
    ρ.IsInvariant (W₁ ⊔ W₂) := by
  exact LinearRepresentation.isInvariant_sup (ρ := ρ) hW₁ hW₂

/--
EABC-Chronologie: simultane chirale Rotation laesst `Phi` invariant.
-/
theorem reachable_phi_tensor_invariance :
    JchiTensor Phi = Phi := by
  exact Phi_invariant_under_JchiTensor

/--
EABC-Chronologie: linksseitige Rotation entspricht rechtsseitiger inverser Rotation.
-/
theorem reachable_phi_left_eq_right_inverse :
    JchiLeft Phi = JchiRightInv Phi := by
  exact Phi_left_rotation_eq_right_inverse_rotation

end KeplerHurwitz
