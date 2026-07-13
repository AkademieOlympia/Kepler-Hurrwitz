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
import KeplerHurwitz.CollatzProofAttemptV210
import KeplerHurwitz.CollatzProofAttemptV211
import KeplerHurwitz.CollatzProofAttemptV212
import KeplerHurwitz.CollatzProofAttemptV213
import KeplerHurwitz.CollatzProofAttemptV215
import KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214
import KeplerHurwitz.Collatz.ChannelSevenDynamicsV215
import KeplerHurwitz.Collatz.ChannelSeven71Step6BranchingV215
import KeplerHurwitz.Collatz.ChannelSevenKernel
import KeplerHurwitz.CollatzNetDescentMod8
import KeplerHurwitz.CollatzNetDescentDiagnostics
import KeplerHurwitz.Representation.Invariant
import KeplerHurwitz.Representation.EABCChronology
import KeplerHurwitz.DistilledParameters
import KeplerHurwitz.SchuettePtolemyCaeda
import KeplerHurwitz.SymbolicResultants
import KeplerHurwitz.HalesTaoIntegration
import KeplerHurwitz.OctonionicChiralDiagnostic

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
V2.9: CEAB-Spiegelparitäts-Brücke (ORQ-098) + Blocking-Assembly; globaler Collatz-Satz
explizit nicht behauptet.
-/
theorem reachable_collatz_proof_attempt_status_v29 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV29 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v29

/--
V2.9: mod-8-Blocking-Interface liefert Net-Descent-Witness (Assembly-Schicht).
-/
theorem reachable_collatz_net_descent_from_mod8_blocking
    {n : Nat}
    (hn : 1 < n)
    (hmod : n % 4 = 3)
    (hblock : Collatz.Octonion.Mod8NetDescentBlockingInterface n) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.BadRunNetDescentWitness n) := by
  exact CollatzAttemptV2.CollatzNetDescentV29.bad_run_net_descent_from_mod8_blocking
    hn hmod hblock

/--
V2.10: Kanal-7 Restklasse `55 mod 128` — Drei-Schritt-Syracuse-Zertifikat `[1,1,3]`.
-/
theorem reachable_channel_seven55_syracuse_three_step_descent (k : Nat) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV210.syracuseOddStep^[3]
      (_root_.KeplerHurwitz.Collatz.ChannelSevenAttackV210.channelSeven55Fiber k) <
      _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV210.channelSeven55Fiber k :=
  CollatzAttemptV2.CollatzNetDescentV210.channel_seven55_syracuse_three_step_net_descent k

/--
V2.10: `55 mod 128` liefert mod-8-Net-Descent-Witness (Kanal 7).
-/
theorem reachable_bad_run_net_descent_mod128_channel_seven_fifty_five
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 55) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzAttemptV2.CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  exact CollatzAttemptV2.CollatzNetDescentV210.bad_run_net_descent_mod128_channel_seven_fifty_five
    hn h7 hmod

/--
V2.10: Status-Bündel inkl. geschlossener `55 mod 128`-Faser.
-/
theorem reachable_collatz_proof_attempt_status_v210 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV210 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v210

/--
V2.11: Kanal-7 Restklasse `87 mod 128` — Drei-Schritt-Syracuse-Zertifikat `[1,1,4]`.
-/
theorem reachable_channel_seven87_syracuse_three_step_descent (k : Nat) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV211.syracuseOddStep^[3]
      (_root_.KeplerHurwitz.Collatz.ChannelSevenAttackV211.channelSeven87Fiber k) <
      _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV211.channelSeven87Fiber k :=
  CollatzAttemptV2.CollatzNetDescentV211.channel_seven87_syracuse_three_step_net_descent k

/--
V2.11: `87 mod 128` liefert mod-8-Net-Descent-Witness (Kanal 7).
-/
theorem reachable_bad_run_net_descent_mod128_channel_seven_eighty_seven
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 87) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzAttemptV2.CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  exact CollatzAttemptV2.CollatzNetDescentV211.bad_run_net_descent_mod128_channel_seven_eighty_seven
    hn h7 hmod

/--
V2.11: Status-Bündel inkl. geschlossener `87 mod 128`-Faser.
-/
theorem reachable_collatz_proof_attempt_status_v211 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV211 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v211

/--
V2.12: Kanal-7 Restklasse `119 mod 128` — Drei-Schritt-Syracuse-Zertifikat `[1,1,3]`.
-/
theorem reachable_channel_seven119_syracuse_three_step_descent (k : Nat) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV212.syracuseOddStep^[3]
      (_root_.KeplerHurwitz.Collatz.ChannelSevenAttackV212.channelSeven119Fiber k) <
      _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV212.channelSeven119Fiber k :=
  CollatzAttemptV2.CollatzNetDescentV212.channel_seven119_syracuse_three_step_net_descent k

/--
V2.12: `119 mod 128` liefert mod-8-Net-Descent-Witness (Kanal 7).
-/
theorem reachable_bad_run_net_descent_mod128_channel_seven_one_nineteen
    {n : Nat}
    (hn : 1 < n)
    (h7 : n % 8 = 7)
    (hmod : ∃ m, n = 128 * m + 119) :
    Nonempty (CollatzAttemptV2.CollatzNetDescent.CollatzNetDescentMod8Witness.BadRunNetDescentWitnessMod8 n
      CollatzAttemptV2.CollatzNetDescentMod8.Mod4ThreeInputChannel.ch7) := by
  exact CollatzAttemptV2.CollatzNetDescentV212.bad_run_net_descent_mod128_channel_seven_one_nineteen
    hn h7 hmod

/--
V2.12: Status-Bündel inkl. geschlossener `119 mod 128`-Faser.
-/
theorem reachable_collatz_proof_attempt_status_v212 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV212 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v212

/--
V2.12: Drei geschlossene affine Progressionen `{55, 87, 119} mod 128`.
-/
theorem reachable_channel_seven_affine_block_v212_status :
    CollatzAttemptV2.ProofAttempt.ChannelSevenAffineBlockV212Status := by
  exact CollatzAttemptV2.ProofAttempt.channel_seven_affine_block_v212_status

/--
V2.13: offene Kanal-7-Progression `71 mod 128` — affine Zertifikate Tiefe 3/4.
-/
theorem reachable_channel_seven71_three_step_affine_form (k : Nat) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.syracuseOddStep^[3]
      (_root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channelSeven71Fiber k) =
      216 * k + 121 :=
  CollatzAttemptV2.CollatzNetDescentV213.channel_seven71_three_step_affine_form k

/--
V2.13: uniformes Kurzpräfix-Nichtabstiegszertifikat bis Tiefe 4 für `71 mod 128`.
-/
theorem reachable_channel_seven71_short_prefix_strict_ascent
    (k : Nat) (t : Nat) (ht : t = 1 ∨ t = 2 ∨ t = 3 ∨ t = 4) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channelSeven71Fiber k <
      _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.syracuseOddStep^[t]
        (_root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channelSeven71Fiber k) :=
  _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channelSeven71_short_prefix_strict_ascent k t ht

theorem reachable_channel_seven71_open_fiber_status :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.ChannelSeven71OpenFiberStatus := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channel_seven71_open_fiber_status

/--
V2.13-Kern: konsolidierter Kanal-7-Status inkl. Zahlentheorie-Brücken.
-/
theorem reachable_channel_seven_kernel_status :
    _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.ChannelSevenKernelStatus := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.channel_seven_kernel_status

theorem reachable_channel_seven_syracuse_eq_oddCore (n : Nat) :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV210.syracuseOddStep n = oddCoreStep n := by
  rfl

theorem reachable_channel_seven_mod512_step5_cascade :
    _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.Mod512ChannelSevenStep5Cascade := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.mod512_channel_seven_step5_cascade

theorem reachable_channel_seven71_step5_branching_cascade :
    _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.ChannelSeven71Step5BranchingCascade := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenAttackV213.channel_seven71_step5_branching_cascade

theorem reachable_channel_seven_mod256_split_71 :
    _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.Mod256ChannelSevenSplit := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenKernel.mod256_channel_seven_split_71

theorem reachable_collatz_proof_attempt_status_v213 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV213 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v213

/-!
## V2.14–V2.15: Ebene A (Lift-Geometrie) und Ebene B (Dynamik-Scaffold)
-/

theorem reachable_channel_seven_deep_lift_level_a_status :
    _root_.KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214.ChannelSevenDeepLiftLevelAStatus := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214.channel_seven_deep_lift_level_a_status

theorem reachable_channel_seven_deep_lift_scaffold :
    _root_.KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214.ChannelSevenDeepLiftScaffold := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenDeepLiftV214.channel_seven_deep_lift_scaffold

theorem reachable_channel_seven_dynamics_v215_scaffold :
    _root_.KeplerHurwitz.Collatz.ChannelSevenDynamicsV215.ChannelSevenDynamicsV215Scaffold := by
  exact _root_.KeplerHurwitz.Collatz.ChannelSevenDynamicsV215.channel_seven_dynamics_v215_scaffold

theorem reachable_deep_lift_fiber_h7_mod128_inverse :
    (243 : Collatz.ChannelSevenAffineMod128V215.mod128) * 59 = 1 ∧
      (59 : Collatz.ChannelSevenAffineMod128V215.mod128) * 243 = 1 := by
  exact ⟨
    Collatz.ChannelSevenAffineMod128V215.coeff243_mul_59_mod128,
    Collatz.ChannelSevenAffineMod128V215.coeff59_mul_243_mod128⟩

theorem reachable_deep_lift_affine_entry_spec
    (j : ℕ) (a : Collatz.ChannelSevenAffineMod128V215.mod128) :
    Collatz.ChannelSevenAffineMod128V215.deepLiftFiberZMod j
      (Collatz.ChannelSevenAffineMod128V215.entryParameterMod128 j a) = a := by
  exact Collatz.ChannelSevenAffineMod128V215.deepLiftFiber_entry_spec j a

theorem reachable_deep_lift_affine_entry_unique
    (j : ℕ) (a t : Collatz.ChannelSevenAffineMod128V215.mod128)
    (ht : Collatz.ChannelSevenAffineMod128V215.deepLiftFiberZMod j t = a) :
    t = Collatz.ChannelSevenAffineMod128V215.entryParameterMod128 j a := by
  exact Collatz.ChannelSevenAffineMod128V215.deepLiftFiber_entry_unique j a t ht

theorem reachable_deep_lift_affine_target_unique
    (j : ℕ) (a : Collatz.ChannelSevenAffineMod128V215.mod128) :
    ∃! t : Collatz.ChannelSevenAffineMod128V215.mod128,
      Collatz.ChannelSevenAffineMod128V215.deepLiftFiberZMod j t = a := by
  exact Collatz.ChannelSevenAffineMod128V215.deepLiftFiber_has_unique_parameter_type j a

theorem reachable_deep_lift_affine_modEq128_iff (j t a : ℕ) :
    Nat.ModEq 128 (Collatz.ChannelSevenDynamicsV215.deepLiftFiber j t) a ↔
      Nat.ModEq 128 t
        (Collatz.ChannelSevenAffineMod128V215.entryParameterMod128 j
          (a : Collatz.ChannelSevenAffineMod128V215.mod128)).val := by
  exact Collatz.ChannelSevenDynamicsV215.deepLiftFiber_modEq128_iff j t a

theorem reachable_deep_lift_affine_mod128_parameter (j a : ℕ) :
    (Collatz.ChannelSevenDynamicsV215.deepLiftFiber j
        (Collatz.ChannelSevenAffineMod128V215.entryParameterMod128 j
          (a : Collatz.ChannelSevenAffineMod128V215.mod128)).val) % 128 =
      a % 128 := by
  exact Collatz.ChannelSevenDynamicsV215.deepLiftFiber_mod128_parameter j a

theorem reachable_channel_seven71_step6_branching_v215_scaffold :
    Collatz.ChannelSeven71Step6BranchingV215.ChannelSeven71Step6BranchingV215Scaffold := by
  exact Collatz.ChannelSeven71Step6BranchingV215.channel_seven71_step6_branching_v215_scaffold

theorem reachable_collatz_proof_attempt_status_v215 :
    CollatzAttemptV2.ProofAttempt.CollatzProofAttemptStatusV215 := by
  exact CollatzAttemptV2.ProofAttempt.collatz_proof_attempt_status_v215

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

/-!
## ORQ-098: Oktonionische Chiral-Diagnostik (System-Freeze V3)
-/

/--
ORQ-098: Infrastruktur validiert impliziert nicht arithmetische Resonanz.
-/
theorem reachable_octonionic_infrastructure_not_resonance :
    OctonionicChiralDiagnostic.InfrastructureValidated →
      OctonionicChiralDiagnostic.ArithmeticResonanceConfirmed → False := by
  exact OctonionicChiralDiagnostic.infrastructure_does_not_imply_resonance

/--
ORQ-098: CEAB-Spiegel `S² = id` auf Chiral-Kanalprojektionen.
-/
theorem reachable_chiral_mirror_involutive
    (c : OctonionicChiralDiagnostic.ChiralChannelProjection) :
    OctonionicChiralDiagnostic.mirrorChannelProjection
      (OctonionicChiralDiagnostic.mirrorChannelProjection c) = c := by
  exact OctonionicChiralDiagnostic.mirrorChannelProjection_involutive c

/--
ORQ-098: Chiralität `C_Δ` ist ungerade unter CEAB-Spiegelung.
-/
theorem reachable_chiral_delta_neg_under_mirror
    (c : OctonionicChiralDiagnostic.ChiralChannelProjection) :
    OctonionicChiralDiagnostic.chiralDelta
      (OctonionicChiralDiagnostic.mirrorChannelProjection c) =
      -OctonionicChiralDiagnostic.chiralDelta c := by
  exact OctonionicChiralDiagnostic.chiralDelta_neg_under_mirror c

/--
ORQ-098: Paritätszerlegung — `A_sym` ist der reine spiegelgerade Anteil.
-/
theorem reachable_symmetrized_amplitude_eq_mirror_even_part
    (c : OctonionicChiralDiagnostic.ChiralChannelProjection) :
    OctonionicChiralDiagnostic.mirrorEvenPart
      OctonionicChiralDiagnostic.symmetrizedAmplitude c =
      OctonionicChiralDiagnostic.symmetrizedAmplitude c := by
  exact OctonionicChiralDiagnostic.symmetrizedAmplitude_eq_mirrorEvenPart c

/--
ORQ-098: Paritätszerlegung — `C_Δ` ist der reine spiegelungerade Anteil.
-/
theorem reachable_chiral_delta_eq_mirror_odd_part
    (c : OctonionicChiralDiagnostic.ChiralChannelProjection) :
    OctonionicChiralDiagnostic.mirrorOddPart
      OctonionicChiralDiagnostic.chiralDelta c =
      OctonionicChiralDiagnostic.chiralDelta c := by
  exact OctonionicChiralDiagnostic.chiralDelta_eq_mirrorOddPart c

/--
ORQ-098: Fano-Ebene hat 168 Kollineationen (V2.1 Fano-Audit).
-/
theorem reachable_fano_automorphism_count_eq_168 :
    OctonionicChiralDiagnostic.fanoAutomorphisms.card = 168 := by
  exact OctonionicChiralDiagnostic.fano_automorphism_count_eq_168

/--
ORQ-098: Primquadruplet-Offset-Geometrie `(0,2,6,8)`.
-/
theorem reachable_prime_quadruplet_canonical_offsets
    (v : PrimeQuadruplet) :
    [v.p, v.p + 2, v.p + 6, v.p + 8] =
      OctonionicChiralDiagnostic.primeQuadrupletRelativeOffsets.map (fun d => v.p + d) := by
  exact OctonionicChiralDiagnostic.PrimeQuadruplet.canonical_offsets v


end KeplerHurwitz
