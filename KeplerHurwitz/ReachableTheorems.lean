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
import KeplerHurwitz.DedekindHasseProofAttempt
import KeplerHurwitz.DedekindIdealLayer
import KeplerHurwitz.CollatzProofAttemptV26
import KeplerHurwitz.CollatzProofAttemptV27
import KeplerHurwitz.CollatzProofAttemptV28
import KeplerHurwitz.CollatzProofAttemptV29
import KeplerHurwitz.CollatzNetDescentMod8
import KeplerHurwitz.CollatzNetDescentDiagnostics
import KeplerHurwitz.Representation.Invariant
import KeplerHurwitz.Representation.EABCChronology
import KeplerHurwitz.DistilledParameters
import KeplerHurwitz.SchuettePtolemyCaeda
import KeplerHurwitz.SymbolicResultants
import KeplerHurwitz.HalesTaoIntegration
import KeplerHurwitz.AnisotropicBinaryVolumeContraction
import KeplerHurwitz.Collatz.Octonion.LargeWitnessPhaseVolume
import KeplerHurwitz.EABC.Semiprim
import KeplerHurwitz.EABC.SemiprimeWaveletCartan
import KeplerHurwitz.EABC.CartanTwinRayAudit
import KeplerHurwitz.EABC.SemiprimeReconstruction
import KeplerHurwitz.FiniteFactorTree.CoefficientDynamics
import KeplerHurwitz.FiniteFactorTree.PipelineDynamicsAudit
import KeplerHurwitz.FiniteFactorTree.SemiprimeSymReconstruction
import KeplerHurwitz.E101.CoreModel
import KeplerHurwitz.E101.CoupledSlotProbe
import KeplerHurwitz.E101.NullmodelShuffle
import KeplerHurwitz.E101.AnalogyProbe
import KeplerHurwitz.E101.LeptonRoleProbe
import KeplerHurwitz.E101.DiracPictureGovernance
import KeplerHurwitz.E101.ConstantNomenclature
import KeplerHurwitz.E101.CoreShellValence
import KeplerHurwitz.E101.DiracLikeAudit
import KeplerHurwitz.EABC.CollatzSyracuseNorm
import KeplerHurwitz.EABC.CollatzTwoStep
import KeplerHurwitz.EABC.CollatzThreeStep
import KeplerHurwitz.EABC.CollatzCycleNecessary
import KeplerHurwitz.EABC.CollatzModularV2
import KeplerHurwitz.EABC.CollatzDigraph

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
V2.8: Channel-`3` even-`k` (`T_odd % 8 = 5`) net descent at uniform `t_loc = 4`.
-/
theorem reachable_collatz_proof_attempt_status_v28 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV28 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v28

/--
V2.8: channel `3` with `T_odd n % 8 = 5` yields a full net-descent witness at `t_loc = 4`.
-/
theorem reachable_bad_run_net_descent_witness_mod8_channel_three_mod8_five
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3) (hfive : CollatzAttemptV2.T_odd n % 8 = 5) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzAttemptV2.CollatzNetDescentMod8.Mod4ThreeInputChannel.ch3) := by
  exact CollatzAttemptV2.CollatzNetDescentV28.bad_run_net_descent_witness_mod8_channel_three_mod8_five
    hn h8 hfive

/--
V2.8: four `collatzStep`s from `T_odd n` descend below `n` when `k` is even (`n = 8k+3`).
-/
theorem reachable_channel_three_collatz_net_descent_mod8_five_at_four
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3)
    (heven : ∃ k, n = 8 * k + 3 ∧ k % 2 = 0) :
    (collatzStep^[4]) (CollatzAttemptV2.T_odd n) < n := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.channel_three_collatz_net_descent_mod8_five_at_four
    hn h8 heven

/--
V2.8: channel `3` odd-`k` with `k % 4 = 1` yields a full net-descent witness at `t_loc = 6`.
-/
theorem reachable_bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3) (hk1 : ∃ j, n = 32 * j + 11) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzAttemptV2.CollatzNetDescentMod8.Mod4ThreeInputChannel.ch3) := by
  exact CollatzAttemptV2.CollatzNetDescentV28.bad_run_net_descent_witness_mod8_channel_three_mod8_one_k_mod4_one
    hn h8 hk1

/--
V2.8: six `collatzStep`s from `T_odd n` descend below `n` when `k % 4 = 1` (`n = 32j+11`).
-/
theorem reachable_channel_three_collatz_net_descent_mod8_one_at_six_k_mod4_one
    {n : Nat} (hn : 1 < n) (h8 : n % 8 = 3) (hk1 : ∃ j, n = 32 * j + 11) :
    (collatzStep^[6]) (CollatzAttemptV2.T_odd n) < n := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.channel_three_collatz_net_descent_mod8_one_at_six_k_mod4_one
    hn h8 hk1

/--
V2.8: uniform five-step barrier for odd `k` — no net descent at `t_loc ≤ 5`.
-/
theorem reachable_channel_three_uniform_five_step_fails_net
    {k : Nat} (hk_odd : k % 2 = 1) (hk_pos : 0 < k) :
    (8 * k + 3) ≤ (collatzStep^[5]) (CollatzAttemptV2.T_odd (8 * k + 3)) := by
  exact CollatzAttemptV2.CollatzNetDescentV28.channel_three_uniform_five_step_fails_net hk_odd hk_pos

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

/--
Dedekind–Hasse ↔ EABC: DH-Kriterium-Schnittstelle ist dokumentiert (Cardoso–Machiavelo).
-/
theorem reachable_dedekindHasse_criterion_statement (order : ReferenceQuaternionOrder) :
    DedekindHasseProofAttempt.DedekindHasseCriterionStatement order := by
  exact DedekindHasseProofAttempt.dedekindHasse_criterion_holds order

/--
Dedekind–Hasse ↔ EABC: isotrope EABC-Signatur hat Exzentrizitaet null (Kepler-Projektion).
-/
theorem reachable_isotropic_eabc_signature_zero_eccentricity (h : EABCSignature4)
    (hi : DedekindHasseProofAttempt.IsotropicEabcSignature h) :
    h.eccentricity = 0 := by
  exact DedekindHasseProofAttempt.isotropic_signature_eccentricity_zero h hi

/--
Dedekind–Hasse ↔ EABC: Status-Buendel (DH/Dumas lokal, EABC-Zertifikat extern, Φ offen).
-/
theorem reachable_dedekindHasse_proof_attempt_status :
    DedekindHasseProofAttempt.DedekindHasseProofAttemptStatus := by
  exact DedekindHasseProofAttempt.dedekindHasse_proof_attempt_status

/--
Dedekind-Ideal-Schicht: DH-Kriterium impliziert links-PID-Zeuge (E-067, Schnittstellenbeweis).
-/
theorem reachable_dedekind_hasse_implies_left_pid (order : ReferenceQuaternionOrder) :
    DedekindHasseCriterion order → Nonempty (DedekindIdealLayer.LeftPIDWitness order) := by
  exact DedekindIdealLayer.dedekind_hasse_implies_left_pid order

/--
Dedekind-Ideal-Schicht: Links-Rechts-Pfad-Asymmetrie fuer Referenzordnungen (E-068).
-/
theorem reachable_leftRightIdealPathAsymmetry :
    DedekindIdealLayer.LeftRightIdealPathAsymmetryStatement := by
  exact DedekindIdealLayer.leftRightIdealPathAsymmetryStatement_holds

/--
Dedekind-Ideal-Schicht: Referenzordnungen ohne Idealclassen-Obstruktion (E-069, negativer Befund).
-/
theorem reachable_referenceOrdersNoIdealClassObstruction :
    DedekindIdealLayer.ReferenceOrdersNoIdealClassObstruction := by
  exact DedekindIdealLayer.dedekind_reference_no_ideal_class_obstruction

/--
Dedekind-Ideal-Schicht: Chiralitaetsindikator σ(H·γ)−σ(γ·H) ≠ 0 fuer Referenzordnungen (E-068).
-/
theorem reachable_idealPathChiralityNonzero (order : ReferenceQuaternionOrder) (γ : Nat) :
    DedekindIdealLayer.IdealPathChiralityNonzero order γ := by
  exact DedekindIdealLayer.ideal_path_chirality_nonzero_reference order γ

/--
Destillierte Kanalparameter: Spread ist durch Kanalmass begrenzt.
-/
theorem reachable_channel_spread_le_mass (h : EABCSignature4) :
    channelSpread_ofSignature h ≤ channelMass_ofSignature h := by
  exact channelSpread_le_channelMass h

/--
V2.7 Diagnostics: positive net margin from good-branch entry yields net-descent witness.
-/
def reachable_collatz_bad_run_net_descent_witness_of_margin
    {n : Nat}
    (e : CollatzAttemptV2.CollatzNetDescent.BadRunGoodBranchEntryWitness n)
    (t_loc : Nat)
    (hmargin :
      0 < CollatzAttemptV2.CollatzNetDescent.netDescentMargin n t_loc e.m_good) :
    CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentWitness n :=
  CollatzAttemptV2.CollatzNetDescent.bad_run_net_descent_witness_of_margin e t_loc hmargin

/--
V2.7 Diagnostics: uniform witness existence equals uniform positive net margin.
-/
theorem reachable_collatz_net_descent_via_margin_iff :
    CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentViaMarginStatement ↔
      CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentStatement := by
  exact CollatzAttemptV2.CollatzNetDescent.bad_run_net_descent_via_margin_iff

/--
V2.7 mod-8: `n ≡ 3 (mod 4)` forces `ν₂(3n+1) = 1`.
-/
theorem reachable_nu2_one_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    padicValNat 2 (3 * n + 1) = 1 := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.nu2_three_mul_add_one_eq_one_of_mod4_eq_three ho hmod

/--
V2.7 mod-8: first Syracuse step mod-8 subcases from `mod 4 = 3` inputs.
-/
theorem reachable_first_syracuse_mod8_subcases_of_mod4_eq_three
    {n : Nat} (ho : n % 2 = 1) (hmod : n % 4 = 3) :
    (n % 8 = 3 ∧ (CollatzAttemptV2.T_odd n % 8 = 1 ∨ CollatzAttemptV2.T_odd n % 8 = 5)) ∨
      (n % 8 = 7 ∧
        (CollatzAttemptV2.T_odd n % 8 = 3 ∨ CollatzAttemptV2.T_odd n % 8 = 7)) := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.first_syracuse_mod8_subcases_of_mod4_eq_three ho hmod

/--
V2.7 mod-8 channel 3: first Syracuse odd strictly exceeds start.
-/
theorem reachable_T_odd_gt_of_mod8_eq_three
    {n : Nat} (h8 : n % 8 = 3) :
    n < CollatzAttemptV2.T_odd n := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.T_odd_gt_of_mod8_eq_three h8

/--
V2.7 mod-8 channel 3: canonical three-step shrink value `9k+4` when `n = 8k+3`.
-/
theorem reachable_three_step_shrink_gt_start_of_mod8_eq_three
    {n : Nat} (h8 : n % 8 = 3) :
    n < (3 * CollatzAttemptV2.T_odd n + 1) / 4 := by
  exact CollatzAttemptV2.CollatzNetDescentMod8.three_step_shrink_gt_start_of_mod8_eq_three h8

/--
Large-witness `[A]`: Phasenexponent + padicVal + skalenstabiler mod-8-Carrier
(`LargeWitnessPhaseVolume.large_witness_phase_index_theorem`).
-/
theorem reachable_large_witness_phase_index_theorem :
    Collatz.Octonion.LargeWitness.LargeWitnessPhaseIndexTheorem :=
  Collatz.Octonion.LargeWitness.large_witness_phase_index_theorem

/--
Large-witness `[A]`: `S(v₂(2⁴⁰)) = 861`.
-/
theorem reachable_phaseExponent_two_pow_forty :
    Collatz.Octonion.LargeWitness.phaseExponent
        (padicValNat 2 (2 ^ 40)) = 861 :=
  Collatz.Octonion.LargeWitness.phaseExponent_two_pow_forty

/--
Large-witness `[A]`: Carrier von `10¹³+7` ist `.C`.
-/
theorem reachable_mod8Carrier_ten_pow_thirteen_plus_seven :
    Collatz.Octonion.LargeWitness.mod8Carrier (10 ^ 13 + 7) =
      Collatz.Octonion.LargeWitness.Mod8Carrier.C :=
  Collatz.Octonion.LargeWitness.mod8Carrier_ten_pow_thirteen_plus_seven

/--
Large-witness `[A]`: Carrier von `5¹³` (Odd-Core von `10¹³`) ist `.B`.
-/
theorem reachable_mod8Carrier_five_pow_thirteen :
    Collatz.Octonion.LargeWitness.mod8Carrier (5 ^ 13) =
      Collatz.Octonion.LargeWitness.Mod8Carrier.B :=
  Collatz.Octonion.LargeWitness.mod8Carrier_five_pow_thirteen

/--
Large-witness `[A]`: `triangularS` = E-099 `triangleNumber`.
-/
theorem reachable_triangularS_eq_triangleNumber (k : Nat) :
    Collatz.Octonion.LargeWitness.triangularS k = triangleNumber k :=
  Collatz.Octonion.LargeWitness.triangularS_eq_triangleNumber k

/--
V2.9: Status-Buendel — Large-Witness Kernel + V2.8; kein globaler Collatz-Claim.
-/
theorem reachable_collatz_proof_attempt_status_v29 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV29 :=
  CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v29

/--
V2.9 `[A]`: Kanal `7` ⇒ Large-Witness-Carrier `.C` und Bad-Run-Budget `≥ 2`.
-/
theorem reachable_channel_seven_carrier_C_and_budget_ge_two
    {n : Nat} (h7 : n % 8 = 7) :
    Collatz.Octonion.LargeWitness.mod8Carrier n =
        Collatz.Octonion.LargeWitness.Mod8Carrier.C ∧
      2 ≤ CollatzAttemptV2.CollatzNetDescentV28.badRunTwoAdicBudget n :=
  CollatzAttemptV2.CollatzNetDescentV29.channel_seven_carrier_C_and_budget_ge_two h7

/--
V2.9 `[A]`: binärer Kontraktionsindex bei `2^40` ist `861`.
-/
theorem reachable_binaryContractionIndex_two_pow_forty :
    CollatzAttemptV2.CollatzNetDescentV29.binaryContractionIndex
        (padicValNat 2 (2 ^ 40)) = 861 :=
  CollatzAttemptV2.CollatzNetDescentV29.binaryContractionIndex_two_pow_forty

/--
E-096 Semiprim claim wall: `[A]`/`[B]` fixed; no arithmetic factorization claim.
-/
theorem reachable_semiprim_claim_wall_status :
    Nonempty EABC.SemiprimClaimWallStatus :=
  ⟨EABC.semiprim_claim_wall_status⟩

/--
Semiprimaler Dreikanal-Zerlegungssatz `[A]`: endliche C₃-äquivariante Haar-Filterbank
mit Detailenergie = Chirurgieenergie = Cartan-C₂. Kein klassisches MRA auf ℕ.
-/
theorem reachable_semiprime_three_channel_decomposition (q : Fin 3 → ℝ) :
    EABC.SemiprimeWavelet.ThreeChannelDecomposition q :=
  EABC.SemiprimeWavelet.threeChannelDecomposition q

/--
FiniteFactorTree [B] coefficient dynamics (consumer): `idMap` is wavelet and energy exact;
`collapseToMean` is asymptotically collapsing. Does not modify the freeze.
-/
theorem reachable_finite_factor_tree_coefficient_dynamics (d : ℕ) :
    FiniteFactorTree.CoefficientDynamics.IsWaveletExact
        (FiniteFactorTree.CoefficientDynamics.idMap d) ∧
      FiniteFactorTree.CoefficientDynamics.IsEnergyExact
        (FiniteFactorTree.CoefficientDynamics.idMap d) ∧
      FiniteFactorTree.CoefficientDynamics.IsAsymptoticallyCollapsing
        (FiniteFactorTree.CoefficientDynamics.collapseToMean d) :=
  ⟨FiniteFactorTree.CoefficientDynamics.idMap_waveletExact d,
    FiniteFactorTree.CoefficientDynamics.idMap_energyExact d,
    FiniteFactorTree.CoefficientDynamics.collapseToMean_asymptoticallyCollapsing⟩

/--
Pipeline → Dynamics bridge: audits use frozen centered-leaf energy; `idMap` preserves it;
`collapseToMean` kills detail. No freeze extension.
-/
theorem reachable_pipeline_dynamics_audit_bridge {d : ℕ}
    (track : FiniteFactorTree.ArithmeticSignalPipeline.PipelineTrack)
    (t : FiniteFactorTree.BinTree (Fin d → ℝ))
    (xs : List (Fin d → ℝ)) (hne : xs ≠ []) :
    (FiniteFactorTree.PipelineDynamicsAudit.runDynamicsAudit
        .idMap track t.leaves).inputDetailEnergy =
      FiniteFactorTree.centeredLeafEnergy t ∧
    (FiniteFactorTree.PipelineDynamicsAudit.runDynamicsAudit
        .idMap track xs).outputDetailEnergy =
      (FiniteFactorTree.PipelineDynamicsAudit.runDynamicsAudit
        .idMap track xs).inputDetailEnergy ∧
    (FiniteFactorTree.PipelineDynamicsAudit.runDynamicsAudit
        .collapseToMean track xs).outputDetailEnergy = 0 :=
  ⟨FiniteFactorTree.PipelineDynamicsAudit.audit_input_eq_centeredLeafEnergy
      .idMap track t,
    FiniteFactorTree.PipelineDynamicsAudit.audit_idMap_preserves_energy track xs,
    FiniteFactorTree.PipelineDynamicsAudit.audit_collapseToMean_output_zero track xs hne⟩

/--
Cartan TwinRay audit consumer: exact inversion `qCE = -qAB` implies even C₂/I₂
invariance and odd I₃ sign reversal; audit deltas vanish on the canonical neg-pair.
-/
theorem reachable_cartan_twinray_audit (qAB : Fin 3 → ℝ) :
    EABC.CartanTwinRayAudit.IsTwinRayInvariantExact qAB (-qAB) ∧
      (EABC.CartanTwinRayAudit.runTwinRayAuditNeg qAB).deltaC2 = 0 ∧
      (EABC.CartanTwinRayAudit.runTwinRayAuditNeg qAB).deltaI2 = 0 ∧
      (EABC.CartanTwinRayAudit.runTwinRayAuditNeg qAB).deltaI3 = 0 :=
  ⟨EABC.CartanTwinRayAudit.auditNeg_invariantExact qAB,
    (EABC.CartanTwinRayAudit.auditNeg_deltas_zero qAB).1,
    (EABC.CartanTwinRayAudit.auditNeg_deltas_zero qAB).2.1,
    (EABC.CartanTwinRayAudit.auditNeg_deltas_zero qAB).2.2⟩

/--
Semiprime reconstruction mod symmetry (consumer 3): on coded residual pairs,
synthesize ∘ analyze = id up to swap; filterbank S∘A = id on Fin 3.
Explicitly not arithmetic factorization.
-/
theorem reachable_semiprime_reconstruction_mod_symmetry
    (p : EABC.SemiprimeReconstruction.CodedResidualPair) (q : Fin 3 → ℝ) :
    EABC.SemiprimeReconstruction.UnorderedEq
        (EABC.SemiprimeReconstruction.synthesize
          (EABC.SemiprimeReconstruction.analyze p)
          (EABC.SemiprimeReconstruction.analyze_isResidual p)) p ∧
      EABC.SemiprimeReconstruction.synthesizeTriad
          (EABC.SemiprimeReconstruction.analyzeTriad q) = q ∧
      ¬ KeplerHurwitz.FiniteFactorTree.ClaimWall.ArithmeticFactorization :=
  ⟨EABC.SemiprimeReconstruction.synthesize_analyze_unordered p,
    EABC.SemiprimeReconstruction.synthesize_analyze_triad q,
    EABC.SemiprimeReconstruction.does_not_claim_factorization⟩

/--
Satzkandidat 17 (weight layer): on Sym²(ℕ), synthesize ∘ analyze = id
for any left-invertible weight coding. Not arithmetic factorization.
-/
theorem reachable_semiprime_sym2_reconstruction
    (w : ℕ → ℝ) (w_inv : ℝ → ℕ)
    (h_inv : ∀ p : ℕ, w_inv (w p) = p)
    (pair : Sym2 ℕ) :
    FiniteFactorTree.SemiprimeSymReconstruction.synthesize w_inv
        (FiniteFactorTree.SemiprimeSymReconstruction.analyze w pair) = pair ∧
      ¬ FiniteFactorTree.ClaimWall.ArithmeticFactorization :=
  ⟨FiniteFactorTree.SemiprimeSymReconstruction.reconstruction_sym2_identity
      w w_inv h_inv pair,
    FiniteFactorTree.SemiprimeSymReconstruction.does_not_claim_factorization⟩

/--
E-101 Kernmodell: typed assembly of E-100 interface contracts.
Own anchor `E101.CoreModel.status`; does not mutate the E-100 freeze.
-/
theorem reachable_e101_core_model :
    Nonempty E101.CoreModel.Status ∧
      E101.CoreModel.status.upstreamAnchor = "ClaimWall.status" ∧
      E101.CoreModel.status.ownAnchor = "E101.CoreModel.status" ∧
      ¬ FiniteFactorTree.ClaimWall.ArithmeticFactorization :=
  ⟨⟨E101.CoreModel.status⟩, rfl, rfl, E101.CoreModel.does_not_claim_factorization⟩

/--
E-101.1 Coupled Slot Probe: idMap preserves detail energy; collapse kills it;
`mutates_e100 = false`.
-/
theorem reachable_e101_coupled_slot_probe {d : ℕ}
    (track : FiniteFactorTree.ArithmeticSignalPipeline.PipelineTrack)
    (xs : List (Fin d → ℝ)) (hne : xs ≠ []) :
    E101.CoupledSlotProbe.mutatesE100 = false ∧
      (E101.CoupledSlotProbe.runDynamicsProbe
          .B1 .idMap track xs .notApplicable
          { kind := .notApplicable, unorderedMatch := True, swapInvariant := True
          }).energyDelta = 0 ∧
      (E101.CoupledSlotProbe.runDynamicsProbe
          .B1 .collapseToMean track xs .notApplicable
          { kind := .notApplicable, unorderedMatch := True, swapInvariant := True
          }).detailEnergyOut = 0 :=
  ⟨E101.CoupledSlotProbe.mutates_e100_false,
    E101.CoupledSlotProbe.coupledProbe_idMap_energyDelta_zero
      .B1 track xs .notApplicable
      { kind := .notApplicable, unorderedMatch := True, swapInvariant := True },
    E101.CoupledSlotProbe.coupledProbe_collapse_zeroDetailEnergy
      .B1 track xs hne .notApplicable
      { kind := .notApplicable, unorderedMatch := True, swapInvariant := True }⟩

/--
E-101.2 Nullmodell-Shuffle: leaf permutation preserves detail energy;
Sym² orientation swap is invariant; TwinRay exact antipode has ΔI₃=0;
`mutates_e100 = false`.
-/
theorem reachable_e101_nullmodel_shuffle {d : ℕ}
    {xs ys : List (Fin d → ℝ)} (h : List.Perm xs ys)
    (w : ℕ → ℝ) (p q : ℕ) (qAB : Fin 3 → ℝ) :
    E101.NullmodelShuffle.mutatesE100 = false ∧
      FiniteFactorTree.CoefficientDynamics.configDetailEnergy xs =
        FiniteFactorTree.CoefficientDynamics.configDetailEnergy ys ∧
      FiniteFactorTree.SemiprimeSymReconstruction.analyze w s(p, q) =
        FiniteFactorTree.SemiprimeSymReconstruction.analyze w s(q, p) ∧
      (EABC.CartanTwinRayAudit.runTwinRayAuditNeg qAB).deltaI3 = 0 :=
  ⟨E101.NullmodelShuffle.mutates_e100_false,
    E101.NullmodelShuffle.leafShuffle_preserves_configDetailEnergy h,
    E101.NullmodelShuffle.sym2OrientationShuffle_analyze_invariant w p q,
    E101.NullmodelShuffle.twinRay_exact_deltaI3_zero qAB⟩

/--
E-101.3 Analogy Discrimination Probe: I₃ is orientation-odd; C₂ is anisotropy
energy; up/down and CP/mass maps are explicitly unsupported; `mutates_e100=false`.
-/
theorem reachable_e101_analogy_probe (q : Fin 3 → ℝ) :
    E101.AnalogyProbe.mutatesE100 = false ∧
      E101.AnalogyProbe.I3TwinRayOdd = true ∧
      E101.AnalogyProbe.CPViolation = false ∧
      E101.AnalogyProbe.UpDownCanonical = false ∧
      E101.AnalogyProbe.ParticleMassMap = false ∧
      EABC.SemiprimeWavelet.I3 (-q) = -EABC.SemiprimeWavelet.I3 q ∧
      EABC.SemiprimeWavelet.C2 q = EABC.SemiprimeWavelet.detailEnergy q :=
  ⟨E101.AnalogyProbe.mutates_e100_false,
    E101.AnalogyProbe.i3TwinRayOdd_true,
    E101.AnalogyProbe.cpViolation_false,
    E101.AnalogyProbe.upDownCanonical_false,
    E101.AnalogyProbe.particleMassMap_false,
    E101.AnalogyProbe.i3_is_orientationOdd q,
    E101.AnalogyProbe.c2_is_anisotropyEnergy q⟩

/--
E-101.4 Lepton Sector Role Probe: continuous B1 roles only; no particle /
generation / PMNS / Majorana identity; collapse is exact isotropic endpoint;
`mutates_e100 = false`.
-/
theorem reachable_e101_lepton_role_probe {d : ℕ}
    (xs : List (Fin d → ℝ)) (hne : xs ≠ []) (w : ℕ → ℝ) (p q : ℕ) :
    E101.LeptonRoleProbe.mutatesE100 = false ∧
      E101.LeptonRoleProbe.particleIdentityClaim = false ∧
      E101.LeptonRoleProbe.generationStructure = false ∧
      E101.LeptonRoleProbe.neutrinoOscillation = false ∧
      E101.LeptonRoleProbe.majoranaClaim = false ∧
      FiniteFactorTree.CoefficientDynamics.configDetailEnergy
          ((FiniteFactorTree.CoefficientDynamics.collapseToMean d).toFun xs) = 0 ∧
      FiniteFactorTree.SemiprimeSymReconstruction.detailEnergyState
          (FiniteFactorTree.SemiprimeSymReconstruction.analyze w s(p, q)) =
        FiniteFactorTree.SemiprimeSymReconstruction.detailEnergyState
          (FiniteFactorTree.SemiprimeSymReconstruction.analyze w s(q, p)) :=
  ⟨E101.LeptonRoleProbe.mutates_e100_false,
    E101.LeptonRoleProbe.particleIdentityClaim_false,
    E101.LeptonRoleProbe.generationStructure_false,
    E101.LeptonRoleProbe.neutrinoOscillation_false,
    E101.LeptonRoleProbe.majoranaClaim_false,
    E101.LeptonRoleProbe.collapse_is_exact_isotropic xs hne,
    E101.LeptonRoleProbe.sym2Orientation_preserves_detailEnergyState w p q⟩

/--
E-101.5 Dirac Picture Governance: free-spectrum bands ≠ particle identity;
exact isotropic kernel ≠ near-isotropic band; No-Gos for QM/PMNS claims;
`mutates_e100 = false`.
-/
theorem reachable_e101_dirac_picture_governance {d : ℕ}
    (track : FiniteFactorTree.ArithmeticSignalPipeline.PipelineTrack)
    (xs : List (Fin d → ℝ)) (hne : xs ≠ []) (q : Fin 3 → ℝ) :
    E101.DiracPictureGovernance.mutatesE100 = false ∧
      E101.DiracPictureGovernance.corePhysicsClaim = false ∧
      E101.DiracPictureGovernance.restMassFromBand = false ∧
      E101.DiracPictureGovernance.particleIdentityFromBand = false ∧
      E101.LeptonRoleProbe.ContinuousLeptonRole.exactIsotropic ≠
        E101.LeptonRoleProbe.ContinuousLeptonRole.nearIsotropic ∧
      EABC.SemiprimeWavelet.C2 q = EABC.SemiprimeWavelet.detailEnergy q ∧
      (E101.CoupledSlotProbe.runDynamicsProbe
          .B1 .idMap track xs .notApplicable
          { kind := .notApplicable, unorderedMatch := True, swapInvariant := True
          }).energyDelta = 0 ∧
      (E101.CoupledSlotProbe.runDynamicsProbe
          .B1 .collapseToMean track xs .notApplicable
          { kind := .notApplicable, unorderedMatch := True, swapInvariant := True
          }).detailEnergyOut = 0 :=
  ⟨E101.DiracPictureGovernance.mutates_e100_false,
    E101.DiracPictureGovernance.corePhysicsClaim_false,
    E101.DiracPictureGovernance.restMassFromBand_false,
    E101.DiracPictureGovernance.particleIdentityFromBand_false,
    E101.DiracPictureGovernance.exactIsotropic_ne_nearIsotropic,
    E101.DiracPictureGovernance.H0_proxy_is_detailEnergy q,
    E101.DiracPictureGovernance.freeEvolution_idMap_energyDelta_zero track xs,
    E101.DiracPictureGovernance.projectiveV_collapse_to_kernel track xs hne⟩

/--
E-101.6 Constant-Role Nomenclature: role-equivalent symbols ≠ natural constants;
`alpha101` well-defined; Parseval \(\Lambda_{101}+C_2\); claim barriers frozen false.
-/
theorem reachable_e101_constant_nomenclature (q : Fin 3 → ℝ) (K : ℝ)
    (x : EABC.V4) :
    E101.ConstantNomenclature.mutatesE100 = false ∧
      E101.ConstantNomenclature.nomenclatureOnly = true ∧
      E101.ConstantNomenclature.h101_is_planck_constant = false ∧
      E101.ConstantNomenclature.G101_is_newton_constant = false ∧
      E101.ConstantNomenclature.alpha101_is_fine_structure_constant = false ∧
      E101.ConstantNomenclature.mu101_is_particle_mass = false ∧
      (EABC.SemiprimeWavelet.C2 q +
          E101.ConstantNomenclature.defaultConfig.epsilonReg ≠ 0) ∧
      EABC.SemiprimeWavelet.energySq q =
        E101.ConstantNomenclature.Lambda101 q +
          EABC.SemiprimeWavelet.detailEnergy q ∧
      FiniteFactorTree.energySq
          (E101.ConstantNomenclature.characterSignature x) = 2 ∧
      E101.ConstantNomenclature.crossEnergy
          E101.ConstantNomenclature.defaultConfig (-K) =
        E101.ConstantNomenclature.crossEnergy
          E101.ConstantNomenclature.defaultConfig K :=
  ⟨E101.ConstantNomenclature.mutates_e100_false,
    E101.ConstantNomenclature.nomenclatureOnly_true,
    E101.ConstantNomenclature.h101_is_planck_constant_false,
    E101.ConstantNomenclature.G101_is_newton_constant_false,
    E101.ConstantNomenclature.alpha101_is_fine_structure_constant_false,
    E101.ConstantNomenclature.mu101_is_particle_mass_false,
    E101.ConstantNomenclature.alpha101_well_defined
      E101.ConstantNomenclature.defaultConfig K (EABC.SemiprimeWavelet.C2 q)
      (by simpa [← EABC.SemiprimeWavelet.detailEnergy_eq_C2] using
        EABC.SemiprimeWavelet.detailEnergy_nonneg q),
    E101.ConstantNomenclature.parseval_iso_plus_detail q,
    E101.ConstantNomenclature.characterSignature_normSq x,
    E101.ConstantNomenclature.crossEnergy_neg_invariant
      E101.ConstantNomenclature.defaultConfig K⟩

/--
E-101.7 Core/Shell/Valence reading: Parseval = core+shell only;
valence is coupling role, not a third energy summand; physics IDs false.
-/
theorem reachable_e101_core_shell_valence (q : Fin 3 → ℝ) :
    E101.CoreShellValence.mutatesE100 = false ∧
      E101.CoreShellValence.ExclusionShellReading = true ∧
      E101.CoreShellValence.ValenceIsThirdParsevalSummand = false ∧
      E101.CoreShellValence.ValenceIsCouplingRole = true ∧
      E101.CoreShellValence.AtomicShellIdentity = false ∧
      E101.CoreShellValence.NuclearBindingEnergyClaim = false ∧
      E101.CoreShellValence.ResidualEqualsC2Claim = false ∧
      EABC.SemiprimeWavelet.energySq q =
        E101.CoreShellValence.coreEnergy q +
          E101.CoreShellValence.shellEnergy q :=
  ⟨E101.CoreShellValence.mutates_e100_false,
    E101.CoreShellValence.ExclusionShellReading_true,
    E101.CoreShellValence.ValenceIsThirdParsevalSummand_false,
    E101.CoreShellValence.ValenceIsCouplingRole_true,
    E101.CoreShellValence.AtomicShellIdentity_false,
    E101.CoreShellValence.NuclearBindingEnergyClaim_false,
    E101.CoreShellValence.ResidualEqualsC2Claim_false,
    E101.CoreShellValence.parseval_core_plus_shell q⟩

/--
E-101.8 Dirac-like audit: core-centered spectral doublet
λ± = Λ ± √(C₂+G K²); inversion-even in K; no physical Dirac claim.
-/
theorem reachable_e101_dirac_like_audit
    (Λ C2 K : ℝ) (hC2 : 0 ≤ C2) :
    E101.DiracLikeAudit.mutatesE100 = false ∧
      E101.DiracLikeAudit.physicalDiracEquation = false ∧
      E101.DiracLikeAudit.physicalMassGap = false ∧
      E101.DiracLikeAudit.particleEnergyFromEigenvalue = false ∧
      (E101.DiracLikeAudit.g101
          E101.ConstantNomenclature.defaultConfig K) ^ 2 =
        E101.ConstantNomenclature.defaultConfig.G101 * K ^ 2 ∧
      (E101.DiracLikeAudit.gapHalf
          E101.ConstantNomenclature.defaultConfig C2 K) ^ 2 =
        C2 + E101.ConstantNomenclature.defaultConfig.G101 * K ^ 2 ∧
      E101.DiracLikeAudit.lambdaPlus
          E101.ConstantNomenclature.defaultConfig Λ C2 (-K) =
        E101.DiracLikeAudit.lambdaPlus
          E101.ConstantNomenclature.defaultConfig Λ C2 K :=
  ⟨E101.DiracLikeAudit.mutates_e100_false,
    E101.DiracLikeAudit.physicalDiracEquation_false,
    E101.DiracLikeAudit.physicalMassGap_false,
    E101.DiracLikeAudit.particleEnergyFromEigenvalue_false,
    E101.DiracLikeAudit.g101_sq E101.ConstantNomenclature.defaultConfig K,
    E101.DiracLikeAudit.gapHalf_sq
      E101.ConstantNomenclature.defaultConfig hC2,
    (E101.DiracLikeAudit.spectrum_inversion_even
      E101.ConstantNomenclature.defaultConfig Λ C2 K).1⟩

/--
E-097 conditional: under `SyracuseNormHypothesis`, embedding norms are core squares.
-/
theorem reachable_normSq_embed_of_syracuseNormHypothesis
    {κ κ' v : Nat} (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v) :
    EABC.EABCCoord.normSq (EABC.CollatzBridge.embedOddCore κ H.embeddable_pre) =
        (κ : Int) ^ 2 ∧
      EABC.EABCCoord.normSq (EABC.CollatzBridge.embedOddCore κ' H.embeddable_post) =
        (κ' : Int) ^ 2 :=
  EABC.CollatzSyracuseNorm.normSq_embed_of_syracuseNormHypothesis H

/--
Audit-grid witness: half-step `7 → 11` is an embedding-norm *ascent* (not descent).
-/
theorem reachable_witness_7_11_is_ascent :
    ¬ EABC.CollatzSyracuseNorm.SyracuseNormDescent 7 11 (by decide) (by decide) :=
  EABC.CollatzSyracuseNorm.witness_7_11_is_ascent

/--
Two-step macro: `13 → 5 → 1` descends; compensation criterion holds.
-/
theorem reachable_twoStep_13_5_1_macroDescent :
    EABC.CollatzTwoStep.TwoStepMacroDescent 13 1 :=
  EABC.CollatzTwoStep.twoStep_13_5_1_macroDescent

/--
Two-step macro: `7 → 11 → 17` does *not* descend (double half-step ascent).
-/
theorem reachable_twoStep_7_11_17_not_macroDescent :
    ¬ EABC.CollatzTwoStep.TwoStepMacroDescent 7 17 :=
  EABC.CollatzTwoStep.twoStep_7_11_17_not_macroDescent

/--
Three-step macro: `11 → 17 → 13 → 5` descends under compensation `v₃=3`.
-/
theorem reachable_threeStep_11_17_13_5_macroDescent :
    EABC.CollatzThreeStep.ThreeStepMacroDescent 11 5 :=
  EABC.CollatzThreeStep.threeStep_11_17_13_5_macroDescent

/--
Three-step macro: `7 → 11 → 17 → 13` does not descend (`v₃=2` fails compensation).
-/
theorem reachable_threeStep_7_11_17_13_not_macroDescent :
    ¬ EABC.CollatzThreeStep.ThreeStepMacroDescent 7 13 :=
  EABC.CollatzThreeStep.threeStep_7_11_17_13_not_macroDescent

/--
Cycle necessary `[A]`: the only accelerated one-step fixed point is `κ=1, v=2`.
-/
theorem reachable_odd_core_fixed_point_eq_one
    {κ v : Nat} (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ v) :
    κ = 1 ∧ v = 2 :=
  EABC.CollatzCycleNecessary.odd_core_fixed_point_eq_one H

/--
Cycle necessary `[A]`: three-step return forbids macro-descent.
-/
theorem reachable_threeStep_return_not_macroDescent
    {κ κ' κ'' v1 v2 v3 : Nat}
    (H : EABC.CollatzThreeStep.SyracuseThreeStepHypothesis κ κ' κ'' κ v1 v2 v3) :
    ¬ EABC.CollatzThreeStep.ThreeStepMacroDescent κ κ :=
  EABC.CollatzCycleNecessary.threeStep_return_not_macroDescent H

/--
Modular filter `[A]`: κ ≡ 15 (mod 16) ⇒ ν₂(3κ+1) = 1.
-/
theorem reachable_mod16_fifteen_v2_eq_one {κ : Nat} (h : κ % 16 = 15) :
    padicValNat 2 (3 * κ + 1) = 1 :=
  EABC.CollatzModularV2.mod16_fifteen_v2_eq_one h

/--
Modular filter `[A]`: κ ≡ 5 (mod 16) ⇒ ν₂(3κ+1) ≥ 4.
-/
theorem reachable_mod16_five_v2_ge_four {κ : Nat} (h : κ % 16 = 5) :
    4 ≤ padicValNat 2 (3 * κ + 1) :=
  EABC.CollatzModularV2.mod16_five_v2_ge_four h

/--
CRT filter `[A]`: κ ≡ 5 (mod 16), gcd(κ,6)=1 ⇒ κ ≡ 1 or 5 (mod 12).
-/
theorem reachable_mod16_five_mod12_is_one_or_five {κ : Nat}
    (h16 : κ % 16 = 5) (h6 : Nat.gcd κ 6 = 1) :
    κ % 12 = 1 ∨ κ % 12 = 5 :=
  EABC.CollatzModularV2.mod16_five_mod12_is_one_or_five h16 h6

/--
CRT filter `[A]`: κ ≡ 15 (mod 16), gcd(κ,6)=1 ⇒ κ ≡ 7 or 11 (mod 12).
-/
theorem reachable_mod16_fifteen_mod12_is_seven_or_eleven {κ : Nat}
    (h16 : κ % 16 = 15) (h6 : Nat.gcd κ 6 = 1) :
    κ % 12 = 7 ∨ κ % 12 = 11 :=
  EABC.CollatzModularV2.mod16_fifteen_mod12_is_seven_or_eleven h16 h6

/--
Modular filter + H `[A under H]`: κ ≡ 15 (mod 16) ⇒ half-step ascent.
-/
theorem reachable_mod16_fifteen_normHyp_ascent
    {κ κ' v : Nat} (h16 : κ % 16 = 15)
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hκ : 0 < κ) :
    v = 1 ∧ κ < κ' :=
  EABC.CollatzModularV2.mod16_fifteen_normHyp_ascent h16 H hκ

/--
Modular filter + H `[A under H]`: κ ≡ 5 (mod 16) ⇒ immediate descent.
-/
theorem reachable_mod16_five_normHyp_descent
    {κ κ' v : Nat} (h16 : κ % 16 = 5)
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hκ : 0 < κ) :
    4 ≤ v ∧ κ' < κ :=
  EABC.CollatzModularV2.mod16_five_normHyp_descent h16 H hκ

/-- Modular filter `[A]`: κ ≡ 7 (mod 16) ⇒ ν₂(3κ+1) = 1. -/
theorem reachable_mod16_seven_v2_eq_one {κ : Nat} (h : κ % 16 = 7) :
    padicValNat 2 (3 * κ + 1) = 1 :=
  EABC.CollatzModularV2.mod16_seven_v2_eq_one h

/-- Half-step image `[A]`: κ ≡ 15 ⇒ ((3κ+1)/2) ≡ 7 or 15 (mod 16). -/
theorem reachable_mod16_fifteen_half_image {κ : Nat} (h : κ % 16 = 15) :
    ((3 * κ + 1) / 2) % 16 = 7 ∨ ((3 * κ + 1) / 2) % 16 = 15 :=
  EABC.CollatzModularV2.mod16_fifteen_half_image h

/-- Half-step image `[A]`: κ ≡ 7 ⇒ ((3κ+1)/2) ≡ 3 or 11 (mod 16). -/
theorem reachable_mod16_seven_half_image {κ : Nat} (h : κ % 16 = 7) :
    ((3 * κ + 1) / 2) % 16 = 3 ∨ ((3 * κ + 1) / 2) % 16 = 11 :=
  EABC.CollatzModularV2.mod16_seven_half_image h

/-- Prison image under H `[A under H]`: class 15 → {7,15}. -/
theorem reachable_mod16_fifteen_normHyp_image
    {κ κ' v : Nat} (h16 : κ % 16 = 15)
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 7 ∨ κ' % 16 = 15) :=
  EABC.CollatzModularV2.mod16_fifteen_normHyp_image h16 H

/-- Exit image under H `[A under H]`: class 7 → {3,11}. -/
theorem reachable_mod16_seven_normHyp_image
    {κ κ' v : Nat} (h16 : κ % 16 = 7)
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v) :
    v = 1 ∧ (κ' % 16 = 3 ∨ κ' % 16 = 11) :=
  EABC.CollatzModularV2.mod16_seven_normHyp_image h16 H

/-- Exact `m mod 2` split `[A]`: class 15 → 7 ↔ Even (κ / 16). -/
theorem reachable_mod16_fifteen_half_image_iff_even_quot {κ : Nat}
    (h : κ % 16 = 15) :
    ((3 * κ + 1) / 2) % 16 = 7 ↔ Even (κ / 16) :=
  EABC.CollatzModularV2.mod16_fifteen_half_image_iff_even_quot h

/-- Exact `m mod 2` split `[A]`: class 7 → 11 ↔ Even (κ / 16). -/
theorem reachable_mod16_seven_half_image_iff_even_quot {κ : Nat}
    (h : κ % 16 = 7) :
    ((3 * κ + 1) / 2) % 16 = 11 ↔ Even (κ / 16) :=
  EABC.CollatzModularV2.mod16_seven_half_image_iff_even_quot h

/-- Exit channel `[A]`: κ ≡ 3 (mod 16) ⇒ ν₂ = 1. -/
theorem reachable_mod16_three_v2_eq_one {κ : Nat} (h : κ % 16 = 3) :
    padicValNat 2 (3 * κ + 1) = 1 :=
  EABC.CollatzModularV2.mod16_three_v2_eq_one h

/-- Exit channel `[A]`: κ ≡ 11 (mod 16) ⇒ ν₂ = 1. -/
theorem reachable_mod16_eleven_v2_eq_one {κ : Nat} (h : κ % 16 = 11) :
    padicValNat 2 (3 * κ + 1) = 1 :=
  EABC.CollatzModularV2.mod16_eleven_v2_eq_one h

/-- Exit image `[A]`: class 3 → {5,13}. -/
theorem reachable_mod16_three_half_image {κ : Nat} (h : κ % 16 = 3) :
    ((3 * κ + 1) / 2) % 16 = 5 ∨ ((3 * κ + 1) / 2) % 16 = 13 :=
  EABC.CollatzModularV2.mod16_three_half_image h

/-- Exit image `[A]`: class 11 → {1,9}. -/
theorem reachable_mod16_eleven_half_image {κ : Nat} (h : κ % 16 = 11) :
    ((3 * κ + 1) / 2) % 16 = 1 ∨ ((3 * κ + 1) / 2) % 16 = 9 :=
  EABC.CollatzModularV2.mod16_eleven_half_image h

/-- Exact split `[A]`: class 3 → 5 ↔ Even (κ / 16). -/
theorem reachable_mod16_three_half_image_iff_even_quot {κ : Nat}
    (h : κ % 16 = 3) :
    ((3 * κ + 1) / 2) % 16 = 5 ↔ Even (κ / 16) :=
  EABC.CollatzModularV2.mod16_three_half_image_iff_even_quot h

/-- Exact split `[A]`: class 11 → 1 ↔ Even (κ / 16). -/
theorem reachable_mod16_eleven_half_image_iff_even_quot {κ : Nat}
    (h : κ % 16 = 11) :
    ((3 * κ + 1) / 2) % 16 = 1 ↔ Even (κ / 16) :=
  EABC.CollatzModularV2.mod16_eleven_half_image_iff_even_quot h

/-- Finite AP half-count `[A]`: among first `2M` indices of `16m+15`, exactly `M` map to 7. -/
theorem reachable_fifteen_AP_image7_card (M : Nat) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 15) + 1) / 2) % 16 = 7).card = M :=
  EABC.CollatzModularV2.fifteen_AP_image7_card M

/-- Finite AP half-count `[A]`: among first `2M` indices of `16m+7`, exactly `M` map to 11. -/
theorem reachable_seven_AP_image11_card (M : Nat) :
    ((Finset.range (2 * M)).filter fun m =>
        ((3 * (16 * m + 7) + 1) / 2) % 16 = 11).card = M :=
  EABC.CollatzModularV2.seven_AP_image11_card M

/-- Complete odd-mod-16 ν₂ table `[A]`: `1,9 ↦ 2`. -/
theorem reachable_mod16_one_v2_eq_two {κ : Nat} (h : κ % 16 = 1) :
    padicValNat 2 (3 * κ + 1) = 2 :=
  EABC.CollatzModularV2.mod16_one_v2_eq_two h

theorem reachable_mod16_nine_v2_eq_two {κ : Nat} (h : κ % 16 = 9) :
    padicValNat 2 (3 * κ + 1) = 2 :=
  EABC.CollatzModularV2.mod16_nine_v2_eq_two h

theorem reachable_mod16_thirteen_v2_eq_three {κ : Nat} (h : κ % 16 = 13) :
    padicValNat 2 (3 * κ + 1) = 3 :=
  EABC.CollatzModularV2.mod16_thirteen_v2_eq_three h

/-- Usable dispatcher `[A]`: lower bound from `κ % 16` for odd κ. -/
theorem reachable_mod16_odd_v2_ge_lowerBound {κ : Nat} (hodd : Odd κ) :
    EABC.CollatzModularV2.mod16OddV2LowerBound (κ % 16) ≤
      padicValNat 2 (3 * κ + 1) :=
  EABC.CollatzModularV2.mod16_odd_v2_ge_lowerBound hodd

/-- Usable descent `[A under H]`: `v ≥ 2` and `κ > 1` ⇒ core descent. -/
theorem reachable_normHyp_descent_of_v_ge_two
    {κ κ' v : Nat}
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hv : 2 ≤ v) (hκ : 1 < κ) :
    κ' < κ :=
  EABC.CollatzModularV2.normHyp_descent_of_v_ge_two H hv hκ

/--
Master first-step classifier `[A under H]` by `κ % 16`.
Primary entry point for modular Syracuse analysis.
-/
theorem reachable_mod16_normHyp_firstStep
    {κ κ' v : Nat}
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hκpos : 0 < κ) :
    (κ % 16 = 3 ∨ κ % 16 = 7 ∨ κ % 16 = 11 ∨ κ % 16 = 15) ∧ v = 1 ∧ κ < κ'
      ∨
    (κ % 16 = 1 ∨ κ % 16 = 9) ∧ v = 2 ∧ (1 < κ → κ' < κ)
      ∨
    κ % 16 = 13 ∧ v = 3 ∧ κ' < κ
      ∨
    κ % 16 = 5 ∧ 4 ≤ v ∧ κ' < κ :=
  EABC.CollatzModularV2.mod16_normHyp_firstStep H hκpos

/-! ## Half-step digraph / ascent-cycle obstruction (§5.12) -/

/-- `[A]` Every ascent-only half-step cycle is constantly residue `15`. -/
theorem reachable_ascent_cycle_all_fifteen {n : Nat} (hn : 0 < n)
    (ρ : Fin n → Nat)
    (hasc : ∀ i, EABC.CollatzDigraph.IsAscentClass (ρ i))
    (hedge : ∀ i, EABC.CollatzDigraph.HalfStepEdge (ρ i)
      (ρ (EABC.CollatzDigraph.cycleSucc hn i))) :
    ∀ i, ρ i = 15 :=
  EABC.CollatzDigraph.ascent_cycle_all_fifteen hn ρ hasc hedge

/-- `[A]` No ascent-only half-step cycle visits a non-`15` residue. -/
theorem reachable_no_ascent_cycle_with_non_fifteen {n : Nat} (hn : 0 < n)
    (ρ : Fin n → Nat)
    (hasc : ∀ i, EABC.CollatzDigraph.IsAscentClass (ρ i))
    (hedge : ∀ i, EABC.CollatzDigraph.HalfStepEdge (ρ i)
      (ρ (EABC.CollatzDigraph.cycleSucc hn i)))
    {j : Fin n} (hj : ρ j ≠ 15) :
    False :=
  EABC.CollatzDigraph.no_ascent_cycle_with_non_fifteen hn ρ hasc hedge hj

/-- `[A]` Class `7` cannot lie on an ascent-only half-step cycle. -/
theorem reachable_seven_not_on_ascent_cycle {n : Nat} (hn : 0 < n)
    (ρ : Fin n → Nat)
    (hasc : ∀ i, EABC.CollatzDigraph.IsAscentClass (ρ i))
    (hedge : ∀ i, EABC.CollatzDigraph.HalfStepEdge (ρ i)
      (ρ (EABC.CollatzDigraph.cycleSucc hn i)))
    {j : Fin n} (hj : ρ j = 7) :
    False :=
  EABC.CollatzDigraph.seven_not_on_ascent_cycle hn ρ hasc hedge hj

/-- `[A]` Half-step image of a class-`15` odd is never itself (no ℕ fixed point). -/
theorem reachable_half_step_ne_self_of_mod16_fifteen {κ : Nat} (h : κ % 16 = 15) :
    (3 * κ + 1) / 2 ≠ κ :=
  EABC.CollatzDigraph.half_step_ne_self_of_mod16_fifteen h

/-- `[A under H]` Class-`15` self-loop on residues is still a strict core ascent. -/
theorem reachable_mod16_fifteen_self_loop_not_fixed
    {κ κ' v : Nat} (h16 : κ % 16 = 15)
    (H : EABC.CollatzSyracuseNorm.SyracuseNormHypothesis κ κ' v)
    (hκ : 0 < κ) (hres : κ' % 16 = 15) :
    κ < κ' ∧ κ' ≠ κ :=
  EABC.CollatzDigraph.mod16_fifteen_self_loop_not_fixed h16 H hκ hres

/-- `[A]` From residue `7`, every length-2 half-step digraph walk lands in descent. -/
theorem reachable_seven_two_step_reaches_descent
    {r1 r2 : Nat}
    (e01 : EABC.CollatzDigraph.HalfStepEdge 7 r1)
    (e12 : EABC.CollatzDigraph.HalfStepEdge r1 r2) :
    EABC.CollatzDigraph.IsDescentClass r2 :=
  EABC.CollatzDigraph.seven_two_step_reaches_descent e01 e12

/--
`[A]` Ascent residues other than `15` reach a descent class in ≤2 digraph edges.
-/
theorem reachable_ascent_non_fifteen_reaches_descent_within_two_edges
    {r : Nat} (h : EABC.CollatzDigraph.IsAscentClass r) (hne : r ≠ 15) :
    (∀ r', EABC.CollatzDigraph.HalfStepEdge r r' →
      EABC.CollatzDigraph.IsDescentClass r') ∨
      (∀ r' r'', EABC.CollatzDigraph.HalfStepEdge r r' →
        EABC.CollatzDigraph.HalfStepEdge r' r'' →
          EABC.CollatzDigraph.IsDescentClass r'') :=
  EABC.CollatzDigraph.ascent_non_fifteen_reaches_descent_within_two_edges h hne

/--
`[A]` If `κ % 16 ∈ {3,7,11}`, after ≤2 forced half-steps the residue is descent.
Class `15` excluded; no global ℕ avoidance.
-/
theorem reachable_ascent_non_fifteen_exits_in_at_most_two_half_steps
    {κ : Nat} (h : EABC.CollatzDigraph.IsAscentClass (κ % 16))
    (hne : κ % 16 ≠ 15) :
    EABC.CollatzDigraph.IsDescentClass (((3 * κ + 1) / 2) % 16) ∨
      EABC.CollatzDigraph.IsDescentClass
        (((3 * ((3 * κ + 1) / 2) + 1) / 2) % 16) :=
  EABC.CollatzDigraph.ascent_non_fifteen_exits_in_at_most_two_half_steps h hne

end KeplerHurwitz
