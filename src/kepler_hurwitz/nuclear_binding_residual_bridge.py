"""
Nuclear binding residual bridge — ORQ-090 / E-090 diagnostic scaffold [C].

Tests whether a preregistered EABC residue classification (Z mod 12, N mod 12)
adds out-of-sample information about SEMF binding residuals beyond parity controls.

Governance: [C] — statistical residual diagnostic only; no nuclear physics claim.
Promotion target: [B0] reproducible export. No promotion to physical mechanism.

See docs/reports/orq_090_nuclear_binding_residual_bridge.md.
"""

from __future__ import annotations

import hashlib
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Literal

import numpy as np
import pandas as pd

ORQ_090_TAG = "[C]"

EABC_RESIDUE_TO_CLASS: dict[int, str] = {1: "E", 5: "A", 7: "B", 11: "C"}
EABC_RESIDUE_CLASSES: frozenset[int] = frozenset(EABC_RESIDUE_TO_CLASS)
NON_EABC_CLASS = "non-EABC"

NULLMODEL_MODES: tuple[str, ...] = (
    "a_bin",
    "parity_class",
    "isotope_chain_shift",
    "structure_matched",
)

PairingClass = Literal["ee", "eo", "oe", "oo"]
PermutationMode = Literal[
    "a_bin",
    "parity_class",
    "isotope_chain_shift",
    "structure_matched",
]

REQUIRED_MASS_COLUMNS: tuple[str, ...] = ("A", "Z", "mass_excess_keV")

__all__ = [
    "ORQ_090_TAG",
    "EABC_RESIDUE_TO_CLASS",
    "EABC_RESIDUE_CLASSES",
    "NON_EABC_CLASS",
    "NULLMODEL_MODES",
    "SEMFParameters",
    "RESIDUAL_EXPORT_FIELDS",
    "assign_eabc_classes",
    "build_residual_export_schema",
    "compute_binding_energy",
    "compute_residuals",
    "evaluate_incremental_signal",
    "fit_semf",
    "load_mass_table",
    "make_grouped_splits",
    "predict_semf",
    "run_structured_permutation_test",
    "semf_pairing_delta",
]


@dataclass(frozen=True)
class SEMFParameters:
    """Semi-empirical mass formula coefficients (MeV). Not fitted until fit_semf runs."""

    a_v: float = 0.0
    a_s: float = 0.0
    a_c: float = 0.0
    a_a: float = 0.0
    a_p: float = 0.0

    def as_dict(self) -> dict[str, float]:
        return asdict(self)


def build_residual_export_schema() -> tuple[str, ...]:
    """Field names for ORQ-090 residual CSV export (see dossier)."""
    return RESIDUAL_EXPORT_FIELDS


RESIDUAL_EXPORT_FIELDS: tuple[str, ...] = (
    "A",
    "Z",
    "N",
    "element",
    "mass_excess_keV",
    "binding_exp_MeV",
    "binding_semf_no_pair_MeV",
    "binding_semf_pair_MeV",
    "residual_no_pair_MeV",
    "residual_pair_MeV",
    "z_parity",
    "n_parity",
    "pairing_class",
    "z_mod12",
    "n_mod12",
    "z_eabc_class",
    "n_eabc_class",
    "eabc_joint_class",
    "split_id",
    "source_release",
)


def _require_columns(df: pd.DataFrame, columns: tuple[str, ...]) -> None:
    missing = [name for name in columns if name not in df.columns]
    if missing:
        raise ValueError(f"mass table missing required columns: {missing}")


def load_mass_table(path: Path) -> pd.DataFrame:
    """Load an AME/NUBASE-style CSV. Raises if the file does not exist."""
    if not path.exists():
        raise FileNotFoundError(
            f"nuclear mass table not found: {path}. "
            "See data/external/README_nuclear_mass_data.md for expected format."
        )
    df = pd.read_csv(path)
    _require_columns(df, REQUIRED_MASS_COLUMNS)
    if "N" not in df.columns:
        df = df.copy()
        df["N"] = df["A"] - df["Z"]
    return df


def compute_binding_energy(df: pd.DataFrame) -> pd.DataFrame:
    """
    Ensure binding_exp_MeV is present.

    If binding_exp_MeV already exists, returns a copy unchanged.
    Otherwise derives from mass_excess_keV via B = -Δ (MeV convention on tabulated excess).
    """
    out = df.copy()
    if "binding_exp_MeV" in out.columns:
        return out
    _require_columns(out, ("mass_excess_keV",))
    # Scaffold convention: binding energy magnitude from mass excess (MeV).
    out["binding_exp_MeV"] = -out["mass_excess_keV"] / 1000.0
    return out


def semf_pairing_delta(a: np.ndarray, z: np.ndarray, *, a_p: float) -> np.ndarray:
    """SEMF pairing term δ(A,Z); zero for odd A."""
    delta = np.zeros_like(a, dtype=float)
    even_a = (a % 2) == 0
    even_z = (z % 2) == 0
    delta[even_a & even_z] = a_p / np.sqrt(a[even_a & even_z])
    delta[even_a & ~even_z] = -a_p / np.sqrt(a[even_a & ~even_z])
    return delta


def _semf_features(df: pd.DataFrame, *, include_pairing: bool) -> np.ndarray:
    a = df["A"].to_numpy(dtype=float)
    z = df["Z"].to_numpy(dtype=float)
    features = [
        np.ones(len(df)),
        a,
        np.power(a, 2.0 / 3.0),
        z * (z - 1.0) / np.power(a, 1.0 / 3.0),
        np.power(a - 2.0 * z, 2.0) / a,
    ]
    if include_pairing:
        # Fit uses a dummy coefficient; actual delta uses fitted a_p at predict time.
        pairing_proxy = np.zeros(len(df))
        even_a = (a.astype(int) % 2) == 0
        pairing_proxy[even_a] = 1.0 / np.sqrt(a[even_a])
        features.append(pairing_proxy)
    return np.column_stack(features)


def fit_semf(train: pd.DataFrame, include_pairing: bool) -> SEMFParameters:
    """Fit SEMF coefficients on training data (synthetic-friendly least squares)."""
    if len(train) < 2:
        raise ValueError("fit_semf requires at least two training rows")
    work = compute_binding_energy(train)
    x_matrix = _semf_features(work, include_pairing=include_pairing)
    y = work["binding_exp_MeV"].to_numpy(dtype=float)
    coeffs, _, _, _ = np.linalg.lstsq(x_matrix, y, rcond=None)
    if include_pairing:
        return SEMFParameters(
            a_v=float(coeffs[1]),
            a_s=float(-coeffs[2]),
            a_c=float(-coeffs[3]),
            a_a=float(-coeffs[4]),
            a_p=float(coeffs[5]),
        )
    return SEMFParameters(
        a_v=float(coeffs[1]),
        a_s=float(-coeffs[2]),
        a_c=float(-coeffs[3]),
        a_a=float(-coeffs[4]),
    )


def predict_semf(
    df: pd.DataFrame,
    params: SEMFParameters,
    include_pairing: bool,
) -> np.ndarray:
    """Predict SEMF binding energy B(A,Z) in MeV."""
    a = df["A"].to_numpy(dtype=float)
    z = df["Z"].to_numpy(dtype=float)
    coulomb = params.a_c * z * (z - 1.0) / np.power(a, 1.0 / 3.0)
    asymmetry = params.a_a * np.power(a - 2.0 * z, 2.0) / a
    binding = (
        params.a_v * a
        - params.a_s * np.power(a, 2.0 / 3.0)
        - coulomb
        - asymmetry
    )
    if include_pairing:
        binding = binding + semf_pairing_delta(a, z, a_p=params.a_p)
    return binding


def _eabc_class_from_mod12(residue: int) -> str:
    normalized = int(residue) % 12
    return EABC_RESIDUE_TO_CLASS.get(normalized, NON_EABC_CLASS)


def _pairing_class(z_parity: int, n_parity: int) -> PairingClass:
    return ("e" if z_parity == 0 else "o") + ("e" if n_parity == 0 else "o")


def assign_eabc_classes(df: pd.DataFrame) -> pd.DataFrame:
    """Add z_mod12, n_mod12, EABC class columns, and parity controls."""
    out = df.copy()
    if "N" not in out.columns:
        out["N"] = out["A"] - out["Z"]
    out["z_mod12"] = out["Z"] % 12
    out["n_mod12"] = out["N"] % 12
    out["z_parity"] = out["Z"] % 2
    out["n_parity"] = out["N"] % 2
    out["z_eabc_class"] = out["z_mod12"].map(_eabc_class_from_mod12)
    out["n_eabc_class"] = out["n_mod12"].map(_eabc_class_from_mod12)
    out["eabc_joint_class"] = out["z_eabc_class"] + ":" + out["n_eabc_class"]
    out["pairing_class"] = [
        _pairing_class(int(zp), int(np_))
        for zp, np_ in zip(out["z_parity"], out["n_parity"], strict=True)
    ]
    return out


def make_grouped_splits(
    df: pd.DataFrame,
    group_column: str = "Z",
) -> list[tuple[np.ndarray, np.ndarray]]:
    """Leave-one-group-out indices: each unique group value is held out once."""
    if group_column not in df.columns:
        raise ValueError(f"group_column {group_column!r} not in dataframe")
    groups = df[group_column].to_numpy()
    unique_groups = np.unique(groups)
    splits: list[tuple[np.ndarray, np.ndarray]] = []
    all_idx = np.arange(len(df))
    for value in unique_groups:
        test_mask = groups == value
        test_idx = all_idx[test_mask]
        train_idx = all_idx[~test_mask]
        if len(train_idx) == 0 or len(test_idx) == 0:
            continue
        splits.append((train_idx, test_idx))
    return splits


def _one_hot_columns(df: pd.DataFrame, columns: list[str]) -> tuple[np.ndarray, list[str]]:
    parts: list[np.ndarray] = []
    names: list[str] = []
    for column in columns:
        if column not in df.columns:
            raise ValueError(f"feature column {column!r} not in dataframe")
        if pd.api.types.is_numeric_dtype(df[column]):
            values = df[column].to_numpy(dtype=float).reshape(-1, 1)
            parts.append(values)
            names.append(column)
            continue
        dummies = pd.get_dummies(df[column].astype(str), prefix=column, dtype=float)
        parts.append(dummies.to_numpy())
        names.extend(dummies.columns.tolist())
    if not parts:
        return np.empty((len(df), 0)), names
    return np.column_stack(parts), names


def _ols_predict(x_train: np.ndarray, y_train: np.ndarray, x_test: np.ndarray) -> np.ndarray:
    coeffs, _, _, _ = np.linalg.lstsq(x_train, y_train, rcond=None)
    return x_test @ coeffs


def _mae(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    return float(np.mean(np.abs(y_true - y_pred)))


def _r2(y_true: np.ndarray, y_pred: np.ndarray) -> float:
    ss_res = float(np.sum((y_true - y_pred) ** 2))
    ss_tot = float(np.sum((y_true - np.mean(y_true)) ** 2))
    if ss_tot == 0.0:
        return 0.0
    return 1.0 - ss_res / ss_tot


def evaluate_incremental_signal(
    df: pd.DataFrame,
    target: str,
    controls: list[str],
    eabc_features: list[str],
) -> dict[str, float]:
    """
    Compare baseline (controls) vs extended (+ EABC) OLS on a single dataframe.

    Returns delta MAE/R² and component metrics. Cross-validated variant uses
    make_grouped_splits upstream on held-out folds.
    """
    if target not in df.columns:
        raise ValueError(f"target column {target!r} not in dataframe")
    y = df[target].to_numpy(dtype=float)
    x_base, _ = _one_hot_columns(df, controls)
    x_ext, _ = _one_hot_columns(df, controls + eabc_features)
    if x_base.size == 0:
        x_base = np.ones((len(df), 1))
    if x_ext.size == 0:
        x_ext = x_base
    pred_base = _ols_predict(x_base, y, x_base)
    pred_ext = _ols_predict(x_ext, y, x_ext)
    mae_base = _mae(y, pred_base)
    mae_ext = _mae(y, pred_ext)
    r2_base = _r2(y, pred_base)
    r2_ext = _r2(y, pred_ext)
    rmse_base = float(np.sqrt(np.mean((y - pred_base) ** 2)))
    rmse_ext = float(np.sqrt(np.mean((y - pred_ext) ** 2)))
    return {
        "mae_baseline": mae_base,
        "mae_extended": mae_ext,
        "delta_mae": mae_base - mae_ext,
        "r2_baseline": r2_base,
        "r2_extended": r2_ext,
        "delta_r2": r2_ext - r2_base,
        "rmse_baseline": rmse_base,
        "rmse_extended": rmse_ext,
        "delta_rmse": rmse_base - rmse_ext,
    }


def run_structured_permutation_test(
    df: pd.DataFrame,
    *,
    n_permutations: int,
    seed: int,
    mode: PermutationMode = "parity_class",
    target: str = "residual_pair_MeV",
    eabc_column: str = "eabc_joint_class",
) -> pd.DataFrame:
    """
    Structured permutation null stub — records observed delta_mae and placeholder nulls.

    Full null realizations are deferred to [B0]; scaffold returns schema-conform rows.
    """
    if mode not in NULLMODEL_MODES:
        raise ValueError(f"unknown nullmodel mode: {mode!r}")
    if target not in df.columns:
        raise ValueError(f"target column {target!r} not in dataframe")
    if eabc_column not in df.columns:
        raise ValueError(f"eabc column {eabc_column!r} not in dataframe")

    controls = ["A", "Z", "z_parity", "n_parity"]
    observed = evaluate_incremental_signal(
        df,
        target=target,
        controls=controls,
        eabc_features=[eabc_column],
    )
    rng = np.random.default_rng(seed)
    null_deltas = [
        float(observed["delta_mae"] * (0.5 + rng.random()))
        for _ in range(n_permutations)
    ]
    rows = [
        {
            "mode": mode,
            "permutation_id": idx,
            "delta_mae": null_delta,
            "observed_delta_mae": observed["delta_mae"],
            "seed": seed,
            "status": "stub",
        }
        for idx, null_delta in enumerate(null_deltas)
    ]
    return pd.DataFrame(rows)


def compute_residuals(
    df: pd.DataFrame,
    params_no_pair: SEMFParameters,
    params_pair: SEMFParameters,
) -> pd.DataFrame:
    """Add SEMF predictions and R_no_pair / R_pair residual columns."""
    work = compute_binding_energy(assign_eabc_classes(df))
    b_no_pair = predict_semf(work, params_no_pair, include_pairing=False)
    b_pair = predict_semf(work, params_pair, include_pairing=True)
    out = work.copy()
    out["binding_semf_no_pair_MeV"] = b_no_pair
    out["binding_semf_pair_MeV"] = b_pair
    out["residual_no_pair_MeV"] = out["binding_exp_MeV"] - b_no_pair
    out["residual_pair_MeV"] = out["binding_exp_MeV"] - b_pair
    return out


def file_sha256(path: Path) -> str:
    """SHA-256 hex digest for governance summaries."""
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(65536), b""):
            digest.update(chunk)
    return digest.hexdigest()
