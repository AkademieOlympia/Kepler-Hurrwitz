"""Synthetic tests for ORQ-090 nuclear binding residual bridge scaffold."""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd
import pytest

from kepler_hurwitz.nuclear_binding_residual_bridge import (
    HYDROGEN_MASS_EXCESS_MEV,
    NEUTRON_MASS_EXCESS_MEV,
    NON_EABC_CLASS,
    ORQ_090_TAG,
    SEMFParameters,
    assign_eabc_classes,
    build_residual_export_schema,
    compute_binding_energy,
    compute_residuals,
    evaluate_incremental_signal,
    fit_semf,
    load_mass_table,
    make_grouped_splits,
    predict_semf,
    run_structured_permutation_test,
)


def _synthetic_mass_frame(n_rows: int = 40, *, seed: int = 90) -> pd.DataFrame:
    rng = np.random.default_rng(seed)
    z_values = rng.integers(2, 12, size=n_rows)
    n_values = rng.integers(2, 16, size=n_rows)
    a_values = z_values + n_values
    true_params = SEMFParameters(a_v=15.0, a_s=16.0, a_c=0.7, a_a=20.0, a_p=10.0)
    base = pd.DataFrame({"A": a_values, "Z": z_values, "N": n_values})
    binding = predict_semf(base, true_params, include_pairing=True)
    binding = binding + rng.normal(0.0, 0.5, size=n_rows)
    base["binding_exp_MeV"] = binding
    delta_mev = (
        base["Z"] * HYDROGEN_MASS_EXCESS_MEV
        + base["N"] * NEUTRON_MASS_EXCESS_MEV
        - base["binding_exp_MeV"]
    )
    base["mass_excess_keV"] = delta_mev * 1000.0
    base["element"] = "X"
    return base


def _write_csv(tmp_path: Path, rows: list[dict]) -> Path:
    path = tmp_path / "mass_table.csv"
    pd.DataFrame(rows).to_csv(path, index=False)
    return path


class TestGovernance:
    def test_tag_is_c(self):
        assert ORQ_090_TAG == "[C]"

    def test_export_schema_matches_dossier(self):
        fields = build_residual_export_schema()
        assert "residual_no_pair_MeV" in fields
        assert "eabc_joint_class" in fields
        assert "source_release" in fields


class TestEabcClasses:
    def test_known_eabc_residues(self):
        df = pd.DataFrame({"A": [12, 14], "Z": [5, 7], "N": [7, 7]})
        out = assign_eabc_classes(df)
        assert out.loc[0, "z_eabc_class"] == "A"
        assert out.loc[0, "n_eabc_class"] == "B"
        assert out.loc[1, "z_eabc_class"] == "B"

    def test_non_eabc_class_for_zero_mod12(self):
        df = pd.DataFrame({"A": [12], "Z": [6], "N": [6]})
        out = assign_eabc_classes(df)
        assert out.loc[0, "z_mod12"] == 6
        assert out.loc[0, "z_eabc_class"] == NON_EABC_CLASS
        assert out.loc[0, "eabc_joint_class"] == f"{NON_EABC_CLASS}:{NON_EABC_CLASS}"

    def test_pairing_class_labels(self):
        df = pd.DataFrame({"A": [4], "Z": [2], "N": [2]})
        out = assign_eabc_classes(df)
        assert out.loc[0, "pairing_class"] == "ee"


class TestSemf:
    def test_predict_with_known_parameters(self):
        params = SEMFParameters(a_v=15.0, a_s=16.0, a_c=0.7, a_a=20.0, a_p=12.0)
        df = pd.DataFrame({"A": [56], "Z": [26]})
        pred = predict_semf(df, params, include_pairing=True)
        assert pred.shape == (1,)
        assert np.isfinite(pred[0])

    def test_fit_recovers_on_noise_free_synthetic(self):
        params_true = SEMFParameters(a_v=15.0, a_s=16.0, a_c=0.7, a_a=20.0)
        a_vals = np.arange(20, 80, 4)
        z_vals = (a_vals // 2).astype(int)
        df = pd.DataFrame({"A": a_vals, "Z": z_vals, "N": a_vals - z_vals})
        df["binding_exp_MeV"] = predict_semf(df, params_true, include_pairing=False)
        fitted = fit_semf(df, include_pairing=False)
        preds = predict_semf(df, fitted, include_pairing=False)
        assert np.mean(np.abs(preds - df["binding_exp_MeV"])) < 1.0

    def test_fit_with_pairing_at_least_runs(self):
        train = _synthetic_mass_frame(60, seed=1)
        fitted = fit_semf(train, include_pairing=True)
        assert isinstance(fitted, SEMFParameters)
        preds = predict_semf(train, fitted, include_pairing=True)
        assert np.all(np.isfinite(preds))


class TestGroupedSplits:
    def test_respects_z_groups(self):
        df = pd.DataFrame(
            {
                "Z": [1, 1, 2, 2, 3],
                "A": [2, 3, 4, 5, 6],
            }
        )
        splits = make_grouped_splits(df, group_column="Z")
        assert len(splits) == 3
        for train_idx, test_idx in splits:
            train_z = set(df.loc[train_idx, "Z"])
            test_z = set(df.loc[test_idx, "Z"])
            assert train_z.isdisjoint(test_z)


class TestIncrementalSignal:
    def test_returns_expected_keys(self):
        df = assign_eabc_classes(_synthetic_mass_frame(50, seed=3))
        df["residual_pair_MeV"] = df["binding_exp_MeV"] - df["binding_exp_MeV"].mean()
        result = evaluate_incremental_signal(
            df,
            target="residual_pair_MeV",
            controls=["A", "Z", "z_parity", "n_parity"],
            eabc_features=["eabc_joint_class"],
        )
        for key in (
            "mae_baseline",
            "mae_extended",
            "delta_mae",
            "r2_baseline",
            "r2_extended",
            "delta_r2",
            "rmse_baseline",
            "rmse_extended",
            "delta_rmse",
        ):
            assert key in result
            assert np.isfinite(result[key])


class TestResiduals:
    def test_compute_residuals_columns(self):
        df = _synthetic_mass_frame(20, seed=4)
        params = fit_semf(df, include_pairing=False)
        params_pair = fit_semf(df, include_pairing=True)
        out = compute_residuals(df, params, params_pair)
        assert "residual_no_pair_MeV" in out.columns
        assert "residual_pair_MeV" in out.columns


class TestLoadMassTable:
    def test_missing_file_raises(self, tmp_path: Path):
        with pytest.raises(FileNotFoundError, match="nuclear mass table not found"):
            load_mass_table(tmp_path / "missing.csv")

    def test_load_with_binding_exp_only(self, tmp_path: Path):
        path = _write_csv(
            tmp_path,
            [{"A": 56, "Z": 26, "element": "Fe", "binding_exp_MeV": 492.0}],
        )
        df = load_mass_table(path)
        assert df.loc[0, "N"] == 30
        assert "binding_exp_MeV" in df.columns

    def test_load_with_mass_excess_only(self, tmp_path: Path):
        path = _write_csv(
            tmp_path,
            [{"A": 4, "Z": 2, "element": "He", "mass_excess_keV": 2424.916}],
        )
        df = load_mass_table(path)
        out = compute_binding_energy(df)
        assert "binding_exp_MeV" in out.columns
        assert np.isfinite(out.loc[0, "binding_exp_MeV"])

    def test_load_without_energy_column_raises(self, tmp_path: Path):
        path = _write_csv(tmp_path, [{"A": 56, "Z": 26, "element": "Fe"}])
        with pytest.raises(ValueError, match="binding_exp_MeV.*mass_excess_keV"):
            load_mass_table(path)

    def test_n_derived_when_absent(self, tmp_path: Path):
        path = _write_csv(
            tmp_path,
            [{"A": 12, "Z": 6, "element": "C", "binding_exp_MeV": 92.0}],
        )
        df = load_mass_table(path)
        assert df.loc[0, "N"] == 6

    def test_inconsistent_n_raises(self, tmp_path: Path):
        path = _write_csv(
            tmp_path,
            [{"A": 12, "Z": 6, "N": 5, "element": "C", "binding_exp_MeV": 92.0}],
        )
        with pytest.raises(ValueError, match="N.*inconsistent"):
            load_mass_table(path)


class TestComputeBindingEnergy:
    def test_mass_excess_formula_on_synthetic_row(self):
        z, n = 26, 30
        binding = 492.0
        delta_mev = (
            z * HYDROGEN_MASS_EXCESS_MEV + n * NEUTRON_MASS_EXCESS_MEV - binding
        )
        df = pd.DataFrame(
            {
                "A": [56],
                "Z": [z],
                "N": [n],
                "element": ["Fe"],
                "mass_excess_keV": [delta_mev * 1000.0],
            }
        )
        out = compute_binding_energy(df)
        assert out.loc[0, "binding_exp_MeV"] == pytest.approx(binding, rel=1e-9)


class TestPermutationStub:
    def test_structured_permutation_returns_frame(self):
        df = compute_residuals(
            _synthetic_mass_frame(30, seed=5),
            fit_semf(_synthetic_mass_frame(30, seed=5), include_pairing=False),
            fit_semf(_synthetic_mass_frame(30, seed=5), include_pairing=True),
        )
        nulls = run_structured_permutation_test(
            df,
            n_permutations=5,
            seed=90,
            mode="parity_class",
        )
        assert len(nulls) == 5
        assert "delta_mae" in nulls.columns
        assert nulls.loc[0, "status"] == "stub"
