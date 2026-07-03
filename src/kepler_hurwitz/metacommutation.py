from __future__ import annotations

import json
from collections import Counter
from dataclasses import asdict, dataclass
from functools import lru_cache
from pathlib import Path
from typing import Iterable, Sequence

from kepler_hurwitz.discrete_time_flow import (
    Octonion,
    associator,
    hurwitz_units_240,
    is_hurwitz_lattice_point,
    octonion_mul,
    octonion_norm_sq,
    octonion_sub,
    project_to_hurwitz_lattice,
)

NORM2_TOLERANCE = 1e-9
ASSOCIATOR_TOLERANCE = 1e-9


@dataclass(frozen=True)
class MetacommutationRecord:
    prime_root: Octonion
    unit_from: Octonion
    unit_to: Octonion
    prime_partner: Octonion
    partner_is_dyadic_integer: bool
    is_associative_branch: bool
    partner_count: int


@dataclass(frozen=True)
class MetacommutationSummary:
    dyadic_root_count: int
    unit_count: int
    pair_count: int
    resolved_pairs: int
    unresolved_pairs: int
    associative_resolutions: int
    non_associative_resolutions: int
    dyadic_integer_partner_resolutions: int
    half_integer_partner_resolutions: int
    max_partner_multiplicity: int
    unique_prime_partner_count: int


def octonion_conjugate(x: Octonion) -> Octonion:
    return (x[0], -x[1], -x[2], -x[3], -x[4], -x[5], -x[6], -x[7])


def octonion_inverse(x: Octonion) -> Octonion:
    norm_sq = octonion_norm_sq(x)
    if norm_sq <= NORM2_TOLERANCE:
        raise ValueError("Cannot invert zero-norm octonion.")
    conjugate = octonion_conjugate(x)
    return tuple(component / norm_sq for component in conjugate)  # type: ignore[return-value]


def _round_octonion(x: Octonion, *, digits: int = 6) -> Octonion:
    return tuple(round(component, digits) for component in x)  # type: ignore[return-value]


def _octonion_key(x: Octonion, *, digits: int = 6) -> Octonion:
    return _round_octonion(x, digits=digits)


def _is_norm2(x: Octonion) -> bool:
    return abs(octonion_norm_sq(x) - 2.0) <= NORM2_TOLERANCE


@lru_cache(maxsize=1)
def enumerate_dyadic_norm2_integer_roots() -> tuple[Octonion, ...]:
    roots: list[Octonion] = []
    for unit in hurwitz_units_240():
        if all(abs(component - round(component)) <= NORM2_TOLERANCE for component in unit):
            if _is_norm2(unit):
                roots.append(unit)
    roots.sort()
    if len(roots) != 112:
        raise RuntimeError(f"Expected 112 dyadic integer norm-2 roots, got {len(roots)}.")
    return tuple(roots)


def _is_associative_branch(prime_root: Octonion, unit_from: Octonion, unit_to: Octonion) -> bool:
    assoc = associator(prime_root, unit_from, unit_to)
    return octonion_norm_sq(assoc) <= ASSOCIATOR_TOLERANCE


def _is_dyadic_integer_root(x: Octonion, dyadic_roots: Sequence[Octonion]) -> bool:
    key = _round_octonion(x)
    return any(_round_octonion(root) == key for root in dyadic_roots)


def _build_right_product_index(
    prime_partners: Sequence[Octonion],
    units: Sequence[Octonion],
    *,
    round_digits: int = 6,
) -> dict[Octonion, tuple[tuple[Octonion, Octonion], ...]]:
    index: dict[Octonion, list[tuple[Octonion, Octonion]]] = {}
    for unit_to in units:
        for prime_partner in prime_partners:
            product = octonion_mul(unit_to, prime_partner)
            key = _octonion_key(product, digits=round_digits)
            index.setdefault(key, []).append((unit_to, prime_partner))
    return {key: tuple(values) for key, values in index.items()}


def find_metacommutation_partners(
    prime_root: Octonion,
    unit_from: Octonion,
    *,
    dyadic_roots: Sequence[Octonion] | None = None,
    units: Sequence[Octonion] | None = None,
    product_index: dict[Octonion, tuple[tuple[Octonion, Octonion], ...]] | None = None,
    round_digits: int = 6,
    first_match_only: bool = False,
) -> tuple[MetacommutationRecord, ...]:
    dyadic_roots = tuple(dyadic_roots or enumerate_dyadic_norm2_integer_roots())
    units = tuple(units or hurwitz_units_240())
    target = octonion_mul(prime_root, unit_from)
    target_key = _octonion_key(target, digits=round_digits)

    if product_index is None:
        product_index = _build_right_product_index(units, units, round_digits=round_digits)

    partners = product_index.get(target_key, ())
    records: list[MetacommutationRecord] = []
    partner_count = 0
    for unit_to, prime_partner in partners:
        if not _is_norm2(prime_partner):
            continue
        if not is_hurwitz_lattice_point(prime_partner):
            continue
        reconstructed = octonion_mul(unit_to, prime_partner)
        if octonion_norm_sq(octonion_sub(reconstructed, target)) > NORM2_TOLERANCE:
            continue
        partner_count += 1
        records.append(
            MetacommutationRecord(
                prime_root=prime_root,
                unit_from=unit_from,
                unit_to=unit_to,
                prime_partner=prime_partner,
                partner_is_dyadic_integer=_is_dyadic_integer_root(prime_partner, dyadic_roots),
                is_associative_branch=_is_associative_branch(prime_root, unit_from, unit_to),
                partner_count=partner_count,
            )
        )
        if first_match_only:
            records[-1] = MetacommutationRecord(
                prime_root=records[-1].prime_root,
                unit_from=records[-1].unit_from,
                unit_to=records[-1].unit_to,
                prime_partner=records[-1].prime_partner,
                partner_is_dyadic_integer=records[-1].partner_is_dyadic_integer,
                is_associative_branch=records[-1].is_associative_branch,
                partner_count=len(partners),
            )
            break
    if records and not first_match_only:
        final_count = len(records)
        records = [
            MetacommutationRecord(
                prime_root=record.prime_root,
                unit_from=record.unit_from,
                unit_to=record.unit_to,
                prime_partner=record.prime_partner,
                partner_is_dyadic_integer=record.partner_is_dyadic_integer,
                is_associative_branch=record.is_associative_branch,
                partner_count=final_count,
            )
            for record in records
        ]
    return tuple(records)


def analyze_dyadic_metacommutation(
    *,
    dyadic_roots: Sequence[Octonion] | None = None,
    units: Sequence[Octonion] | None = None,
    round_digits: int = 6,
) -> tuple[MetacommutationRecord, ...]:
    dyadic_roots = tuple(dyadic_roots or enumerate_dyadic_norm2_integer_roots())
    units = tuple(units or hurwitz_units_240())
    product_index = _build_right_product_index(units, units, round_digits=round_digits)

    records: list[MetacommutationRecord] = []
    for prime_root in dyadic_roots:
        for unit_from in units:
            partners = find_metacommutation_partners(
                prime_root,
                unit_from,
                dyadic_roots=dyadic_roots,
                units=units,
                product_index=product_index,
                round_digits=round_digits,
                first_match_only=True,
            )
            if partners:
                records.append(partners[0])
            else:
                records.append(
                    MetacommutationRecord(
                        prime_root=prime_root,
                        unit_from=unit_from,
                        unit_to=(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
                        prime_partner=prime_root,
                        partner_is_dyadic_integer=True,
                        is_associative_branch=False,
                        partner_count=0,
                    )
                )
    return tuple(records)


def metacommutation_partner_histogram(
    records: Sequence[MetacommutationRecord],
) -> dict[str, int]:
    histogram: Counter[str] = Counter()
    for record in records:
        if record.partner_count <= 0:
            histogram["unresolved"] += 1
            continue
        if record.is_associative_branch and record.partner_is_dyadic_integer:
            histogram["associative_dyadic"] += 1
        elif record.is_associative_branch:
            histogram["associative_half_integer"] += 1
        elif record.partner_is_dyadic_integer:
            histogram["non_associative_dyadic"] += 1
        else:
            histogram["non_associative_half_integer"] += 1
    return dict(histogram)


def summarize_metacommutation(
    records: Sequence[MetacommutationRecord],
    *,
    dyadic_root_count: int | None = None,
    unit_count: int | None = None,
) -> MetacommutationSummary:
    dyadic_root_count = dyadic_root_count or len({record.prime_root for record in records})
    unit_count = unit_count or len({record.unit_from for record in records})
    resolved = [record for record in records if record.partner_count > 0]
    unresolved = [record for record in records if record.partner_count == 0]
    associative = sum(1 for record in resolved if record.is_associative_branch)
    dyadic_partners = sum(1 for record in resolved if record.partner_is_dyadic_integer)
    multiplicities = Counter(record.partner_count for record in resolved)
    unique_partners = len({record.prime_partner for record in resolved})
    return MetacommutationSummary(
        dyadic_root_count=dyadic_root_count,
        unit_count=unit_count,
        pair_count=len(records),
        resolved_pairs=len(resolved),
        unresolved_pairs=len(unresolved),
        associative_resolutions=associative,
        non_associative_resolutions=len(resolved) - associative,
        dyadic_integer_partner_resolutions=dyadic_partners,
        half_integer_partner_resolutions=len(resolved) - dyadic_partners,
        max_partner_multiplicity=max(multiplicities) if multiplicities else 0,
        unique_prime_partner_count=unique_partners,
    )


def export_metacommutation_json(
    records: Sequence[MetacommutationRecord],
    summary: MetacommutationSummary,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "summary": asdict(summary),
        "partner_histogram": metacommutation_partner_histogram(records),
        "sample_records": [
            {
                "prime_root": list(record.prime_root),
                "unit_from": list(record.unit_from),
                "unit_to": list(record.unit_to),
                "prime_partner": list(record.prime_partner),
                "partner_is_dyadic_integer": record.partner_is_dyadic_integer,
                "is_associative_branch": record.is_associative_branch,
                "partner_count": record.partner_count,
            }
            for record in records[:16]
        ],
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_metacommutation_summary(summary: MetacommutationSummary) -> str:
    return (
        f"dyadic_roots={summary.dyadic_root_count}, units={summary.unit_count}, "
        f"pairs={summary.pair_count}, resolved={summary.resolved_pairs}, "
        f"unresolved={summary.unresolved_pairs}, "
        f"associative={summary.associative_resolutions}, "
        f"non_associative={summary.non_associative_resolutions}, "
        f"dyadic_partners={summary.dyadic_integer_partner_resolutions}, "
        f"half_integer_partners={summary.half_integer_partner_resolutions}, "
        f"max_partner_multiplicity={summary.max_partner_multiplicity}, "
        f"unique_prime_partners={summary.unique_prime_partner_count}"
    )


def classify_shell_operator_metacommutation(
    shell_operators: Sequence[Octonion],
    *,
    records: Sequence[MetacommutationRecord] | None = None,
) -> dict[str, dict[str, float]]:
    records = records or analyze_dyadic_metacommutation()
    lookup: dict[tuple[Octonion, Octonion], MetacommutationRecord] = {
        (record.prime_root, record.unit_from): record for record in records
    }
    dyadic_roots = enumerate_dyadic_norm2_integer_roots()
    units = hurwitz_units_240()
    report: dict[str, dict[str, float]] = {}
    for index, operator in enumerate(shell_operators):
        projected = project_to_hurwitz_lattice(operator)
        nearest_root = min(dyadic_roots, key=lambda root: octonion_norm_sq(octonion_sub(root, projected)))
        matched = [
            lookup[(nearest_root, unit)]
            for unit in units
            if (nearest_root, unit) in lookup
        ]
        if not matched:
            continue
        associative_ratio = sum(1 for item in matched if item.is_associative_branch) / len(matched)
        fixed_partner_ratio = sum(
            1 for item in matched if item.prime_partner == item.prime_root
        ) / len(matched)
        dyadic_partner_ratio = sum(1 for item in matched if item.partner_is_dyadic_integer) / len(matched)
        report[f"shell_operator_{index}"] = {
            "nearest_dyadic_norm2": octonion_norm_sq(nearest_root),
            "associative_ratio": associative_ratio,
            "fixed_partner_ratio": fixed_partner_ratio,
            "dyadic_partner_ratio": dyadic_partner_ratio,
            "mean_partner_count": sum(item.partner_count for item in matched) / len(matched),
        }
    return report
