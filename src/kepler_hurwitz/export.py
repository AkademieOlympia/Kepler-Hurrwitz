from __future__ import annotations

import csv
import json
from datetime import datetime, timezone
from itertools import product
from pathlib import Path

from kepler_hurwitz.cyclic_words import canonical_representative
from kepler_hurwitz.octonionic_slice import (
    intersection_points,
    quaternionic_associator_vanishes,
    slice_constraint_record,
)
from kepler_hurwitz.primvierling import PrimvierlingAnalysis
from kepler_hurwitz.significance import (
    b_bound_summary,
    b_bound_trend_records,
    b_bound_trends,
    b_bound_matrix_records,
    chi_square_result_record,
    chi_square_smoothness_by_channel,
    scan_b_bound_matrix,
    scale_stability_records,
    scan_scale_stability,
)
from kepler_hurwitz.smoothness_channel_scan import SmoothnessSample, summarize_scan


def primvierling_analysis_records(
    analyses: list[PrimvierlingAnalysis],
) -> list[dict[str, object]]:
    records: list[dict[str, object]] = []
    for analysis in analyses:
        for invariant in analysis.invariants:
            records.append(
                {
                    "base": list(analysis.base),
                    "orbit": [list(state) for state in analysis.orbit],
                    "invariant_name": invariant.name,
                    "is_invariant": invariant.is_invariant,
                    "orbit_values": list(invariant.orbit_values),
                }
            )
    return records


def export_primvierling_analysis_json(
    analyses: list[PrimvierlingAnalysis],
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {"analyses": primvierling_analysis_records(analyses)}
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_primvierling_analysis_csv(
    analyses: list[PrimvierlingAnalysis],
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fields = ["base", "orbit", "invariant_name", "is_invariant", "orbit_values"]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in primvierling_analysis_records(analyses):
            writer.writerow(
                {
                    "base": json.dumps(record["base"]),
                    "orbit": json.dumps(record["orbit"]),
                    "invariant_name": record["invariant_name"],
                    "is_invariant": record["is_invariant"],
                    "orbit_values": json.dumps(record["orbit_values"]),
                }
            )
    return destination


def cyclic_word_class_records(words: list[str]) -> list[dict[str, object]]:
    classes: dict[str, list[str]] = {}
    for word in words:
        representative = canonical_representative(word)
        classes.setdefault(representative, []).append(word)
    return [
        {
            "canonical": canonical,
            "members": sorted(members),
            "size": len(members),
        }
        for canonical, members in sorted(classes.items())
    ]


def export_cyclic_word_classes_json(words: list[str], output_path: str | Path) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {"classes": cyclic_word_class_records(words)}
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_cyclic_word_classes_csv(words: list[str], output_path: str | Path) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fields = ["canonical", "size", "members"]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in cyclic_word_class_records(words):
            writer.writerow(
                {
                    "canonical": record["canonical"],
                    "size": record["size"],
                    "members": json.dumps(record["members"]),
                }
            )
    return destination


def smoothness_channel_records(samples: list[SmoothnessSample]) -> list[dict[str, object]]:
    return [
        {
            "m": sample.m,
            "mod8": sample.mod8,
            "delta_e": sample.delta_e,
            "channel": sample.channel,
            "next_core": sample.next_core,
            "b": sample.b,
            "is_b_smooth": sample.is_b_smooth,
        }
        for sample in samples
    ]


def smoothness_channel_summary_records(
    samples: list[SmoothnessSample],
) -> list[dict[str, object]]:
    summary = summarize_scan(samples)
    records: list[dict[str, object]] = []
    for channel in ("klein", "mittel", "tief"):
        total = summary[channel]["total"]
        b_smooth = summary[channel]["b_smooth"]
        ratio = 0.0 if total == 0 else b_smooth / total
        records.append(
            {
                "channel": channel,
                "total": total,
                "b_smooth": b_smooth,
                "ratio": ratio,
            }
        )
    return records


def export_smoothness_channels_json(
    samples: list[SmoothnessSample],
    output_path: str | Path,
    *,
    limit_m: int,
    b: int,
    script_version: str = "smoothness_channel_scan_v1",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "metadata": {
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "limit_m": limit_m,
            "b": b,
            "sample_count": len(samples),
            "script_version": script_version,
        },
        "summary": smoothness_channel_summary_records(samples),
        "samples": smoothness_channel_records(samples),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_smoothness_channels_csv(
    samples: list[SmoothnessSample],
    output_path: str | Path,
    *,
    limit_m: int,
    b: int,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fields = ["channel", "total", "b_smooth", "ratio", "limit_m", "b"]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in smoothness_channel_summary_records(samples):
            writer.writerow(
                {
                    "channel": record["channel"],
                    "total": record["total"],
                    "b_smooth": record["b_smooth"],
                    "ratio": record["ratio"],
                    "limit_m": limit_m,
                    "b": b,
                }
            )
    return destination


def export_smoothness_significance_json(
    samples: list[SmoothnessSample],
    output_path: str | Path,
    *,
    limit_m: int,
    b: int,
    test_name: str = "chi_square_independence",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    result = chi_square_smoothness_by_channel(samples)
    payload = {
        "metadata": {
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "limit_m": limit_m,
            "b": b,
            "sample_count": len(samples),
            "test_name": test_name,
        },
        "result": chi_square_result_record(result),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_smoothness_scale_stability_json(
    output_path: str | Path,
    *,
    b: int,
    limits: list[int],
    script_version: str = "smoothness_scale_stability_v1",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    points = scan_scale_stability(b=b, limits=limits)
    payload = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "b_bound": b,
        "script_version": script_version,
        "scales": scale_stability_records(points),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_smoothness_b_bound_matrix_json(
    output_path: str | Path,
    *,
    b_bounds: list[int],
    limits: list[int],
    script_version: str = "smoothness_b_bound_matrix_v1",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    rows = scan_b_bound_matrix(b_bounds=b_bounds, limits=limits)
    payload = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "script_version": script_version,
        "limits": limits,
        "scans": b_bound_matrix_records(rows),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_smoothness_b_bound_summary_json(
    output_path: str | Path,
    *,
    b_bounds: list[int],
    limits: list[int],
    script_version: str = "smoothness_b_bound_summary_v1",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    rows = scan_b_bound_matrix(b_bounds=b_bounds, limits=limits)
    trends = b_bound_trends(rows)
    payload = {
        "generated_at_utc": datetime.now(timezone.utc).isoformat(),
        "script_version": script_version,
        "limits": limits,
        "summary": b_bound_summary(trends, rows),
        "trends": b_bound_trend_records(trends),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def octonionic_slice_records(
    mu_values: list[float],
    q_values: list[float],
) -> list[dict[str, float | str]]:
    return [
        slice_constraint_record(mu, q)
        for mu, q in product(mu_values, q_values)
    ]


def export_octonionic_slice_json(
    output_path: str | Path,
    *,
    mu_values: list[float],
    q_values: list[float],
    script_version: str = "octonionic_slice_v1",
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "metadata": {
            "generated_at_utc": datetime.now(timezone.utc).isoformat(),
            "script_version": script_version,
            "mu_values": mu_values,
            "q_values": q_values,
            "grid_size": len(mu_values) * len(q_values),
        },
        "assumptions": {
            "quaternionic_associator_vanishes": quaternionic_associator_vanishes()
        },
        "interference_points": [
            {"mu": point.mu, "q": point.q}
            for point in intersection_points()
        ],
        "records": octonionic_slice_records(mu_values, q_values),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def export_octonionic_slice_csv(
    output_path: str | Path,
    *,
    mu_values: list[float],
    q_values: list[float],
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    fields = [
        "mu",
        "q",
        "s",
        "trace",
        "norm",
        "quartic_mu_q_residual",
        "circle_mu_q_residual",
        "quartic_mu_s_residual",
        "circle_mu_s_residual",
        "resultant_mu_residual",
        "resultant_s_residual",
        "is_admissible_interference",
        "quartic_trace_norm_residual",
        "circle_trace_norm_residual",
        "class",
    ]
    with destination.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fields)
        writer.writeheader()
        for record in octonionic_slice_records(mu_values, q_values):
            writer.writerow(record)
    return destination
