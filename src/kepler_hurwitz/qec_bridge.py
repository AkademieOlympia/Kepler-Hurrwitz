from __future__ import annotations

import json
from collections import Counter
from dataclasses import asdict, dataclass
from itertools import permutations
from pathlib import Path
from typing import Iterable, Literal, Sequence

from kepler_hurwitz.discrete_time_flow import (
    Octonion,
    fano_triples,
    octonion_mul,
    octonion_norm_sq,
)
from kepler_hurwitz.metacommutation import (
    MetacommutationRecord,
    analyze_dyadic_metacommutation,
    enumerate_dyadic_norm2_integer_roots,
)

IMAGINARY_COUNT = 7
COMPONENT_TOLERANCE = 1e-9

SyndromeClass = Literal[
    "associative_dyadic",
    "associative_half_integer",
    "non_associative_dyadic",
    "non_associative_half_integer",
    "unresolved",
]

ShellStabilizationClass = Literal[
    "Fixpunkt",
    "Bifurkation",
    "Pumpen",
    "Ground shell",
    "Transitiv",
]


@dataclass(frozen=True)
class FanoStabilizerGenerator:
    line_index: int
    indices: tuple[int, int, int]
    parity_mask: int


@dataclass(frozen=True)
class DyadicRootClass:
    class_id: int
    support: frozenset[int]
    signed_support: tuple[tuple[int, int], ...]
    parity_mask: int
    fano_line_indices: tuple[int, ...]
    includes_real_axis: bool


@dataclass(frozen=True)
class SyndromeEntry:
    syndrome_id: int
    syndrome_class: SyndromeClass
    count: int
    degeneracy: int


@dataclass(frozen=True)
class SyndromeTable:
    total_pairs: int
    syndrome_count: int
    entries: tuple[SyndromeEntry, ...]
    class_totals: dict[str, int]


@dataclass(frozen=True)
class StabilizerStructureSummary:
    fano_line_count: int
    independent_generator_count: int
    dyadic_root_count: int
    dyadic_class_count: int
    fano_aligned_root_count: int
    real_axis_root_count: int
    syndrome_table: SyndromeTable
    shell_syndrome_map: dict[str, str]


@dataclass(frozen=True)
class CommutationRecord:
    left: int
    right: int
    product_index: int
    sign: int
    relation: Literal["same", "anticommute_to_third", "involution", "zero"]


@dataclass(frozen=True)
class CSSProjectionAnalysis:
    fano_line_count: int
    fano_line_rank: int
    kernel_dimension: int
    independent_generator_rows: tuple[tuple[int, ...], ...]
    kernel_basis_rows: tuple[tuple[int, ...], ...]
    generator_hamming_weights: tuple[int, ...]
    kernel_min_hamming_weight: int
    steane_hx_rank: int
    steane_hz_rank: int
    steane_hx_contained_in_fano_rowspace: bool
    fano_rowspace_contained_in_steane_hx: bool
    rowspace_intersection_dimension: int
    steane_classical_distance: int
    steane_css_generator_count: int


GF2Row = tuple[int, ...]


def _nonzero_indices(x: Octonion, *, tolerance: float = COMPONENT_TOLERANCE) -> tuple[tuple[int, int], ...]:
    entries: list[tuple[int, int]] = []
    for index, value in enumerate(x):
        if abs(value) <= tolerance:
            continue
        sign = 1 if value > 0 else -1
        entries.append((index, sign))
    return tuple(sorted(entries))


def _parity_mask_from_indices(indices: Iterable[int]) -> int:
    mask = 0
    for index in indices:
        if index == 0:
            continue
        mask |= 1 << (index - 1)
    return mask


def build_fano_stabilizer_generators() -> tuple[FanoStabilizerGenerator, ...]:
    """Map each Fano line to a 7-bit parity-check mask on imaginary units."""
    generators: list[FanoStabilizerGenerator] = []
    for line_index, triple in enumerate(fano_triples()):
        mask = _parity_mask_from_indices(triple)
        generators.append(
            FanoStabilizerGenerator(
                line_index=line_index,
                indices=triple,
                parity_mask=mask,
            )
        )
    return tuple(generators)


def independent_fano_generator_count() -> int:
    masks = [generator.parity_mask for generator in build_fano_stabilizer_generators()]
    return _gf2_rank(masks)


def parity_mask_to_bits(mask: int, *, width: int = IMAGINARY_COUNT) -> GF2Row:
    return tuple((mask >> bit) & 1 for bit in range(width))


def bits_to_parity_mask(bits: Sequence[int]) -> int:
    mask = 0
    for bit, value in enumerate(bits):
        if value & 1:
            mask |= 1 << bit
    return mask


def build_fano_parity_rows() -> tuple[GF2Row, ...]:
    return tuple(
        parity_mask_to_bits(generator.parity_mask)
        for generator in build_fano_stabilizer_generators()
    )


def steane_hx_reference_rows() -> tuple[GF2Row, ...]:
    """Classical X-check rows for the [[7,1,3]] Steane code (one standard embedding)."""
    return (
        (1, 1, 1, 0, 0, 0, 0),
        (1, 0, 1, 1, 0, 0, 0),
        (0, 1, 1, 1, 0, 0, 0),
    )


def steane_hz_reference_rows() -> tuple[GF2Row, ...]:
    """Classical Z-check rows for the [[7,1,3]] Steane code (dual CSS block)."""
    return (
        (0, 1, 1, 1, 0, 0, 0),
        (0, 0, 1, 1, 1, 0, 0),
        (1, 0, 0, 1, 1, 1, 0),
    )


def hamming_weight(row: Sequence[int]) -> int:
    return sum(value & 1 for value in row)


def gf2_rref(rows: Sequence[GF2Row]) -> tuple[GF2Row, ...]:
    """Reduced row echelon form over GF(2)."""
    if not rows:
        return ()
    width = len(rows[0])
    matrix = [list(row) for row in rows]
    pivot_row = 0
    for col in range(width):
        swap = None
        for row_index in range(pivot_row, len(matrix)):
            if matrix[row_index][col] & 1:
                swap = row_index
                break
        if swap is None:
            continue
        matrix[pivot_row], matrix[swap] = matrix[swap], matrix[pivot_row]
        for row_index in range(len(matrix)):
            if row_index != pivot_row and (matrix[row_index][col] & 1):
                matrix[row_index] = [
                    (left ^ right) & 1 for left, right in zip(matrix[row_index], matrix[pivot_row], strict=True)
                ]
        pivot_row += 1
    independent = [tuple(row) for row in matrix if any(value & 1 for value in row)]
    return tuple(independent)


def gf2_kernel_basis(rows: Sequence[GF2Row]) -> tuple[GF2Row, ...]:
    """Basis for the right kernel {v | M v = 0} over GF(2)."""
    if not rows:
        return tuple(tuple(1 if index == col else 0 for index in range(IMAGINARY_COUNT)) for col in range(IMAGINARY_COUNT))
    width = len(rows[0])
    rref = list(gf2_rref(rows))
    pivot_columns: list[int] = []
    for row in rref:
        for col, value in enumerate(row):
            if value & 1:
                pivot_columns.append(col)
                break
    free_columns = [col for col in range(width) if col not in pivot_columns]
    basis: list[GF2Row] = []
    for free_col in free_columns:
        vector = [0] * width
        vector[free_col] = 1
        for row, pivot_col in zip(rref, pivot_columns, strict=False):
            if row[pivot_col] & 1 and row[free_col] & 1:
                vector[pivot_col] ^= 1
        basis.append(tuple(vector))
    return tuple(basis)


def gf2_rowspace_dimension(rows: Sequence[GF2Row]) -> int:
    return len(gf2_rref(rows))


def gf2_rowspace_intersection_dimension(left: Sequence[GF2Row], right: Sequence[GF2Row]) -> int:
    combined = [row for row in left] + [row for row in right]
    return gf2_rowspace_dimension(left) + gf2_rowspace_dimension(right) - gf2_rowspace_dimension(combined)


def gf2_rowspace_contains(container: Sequence[GF2Row], candidate: Sequence[GF2Row]) -> bool:
    combined = [row for row in container] + [row for row in candidate]
    return gf2_rowspace_dimension(container) == gf2_rowspace_dimension(combined)


def kernel_min_hamming_weight(kernel_basis: Sequence[GF2Row]) -> int:
    if not kernel_basis:
        return 0
    dimension = len(kernel_basis)
    best = IMAGINARY_COUNT + 1
    for mask in range(1, 1 << dimension):
        vector = [0] * len(kernel_basis[0])
        for index, row in enumerate(kernel_basis):
            if (mask >> index) & 1:
                vector = [(left ^ right) & 1 for left, right in zip(vector, row, strict=True)]
        weight = hamming_weight(vector)
        if weight < best:
            best = weight
    return best


def analyze_css_projection() -> CSSProjectionAnalysis:
    fano_rows = build_fano_parity_rows()
    independent_rows = gf2_rref(fano_rows)
    kernel_basis = gf2_kernel_basis(independent_rows)
    hx_rows = steane_hx_reference_rows()
    hz_rows = steane_hz_reference_rows()
    fano_rank = len(independent_rows)
    hx_rank = gf2_rowspace_dimension(hx_rows)
    hz_rank = gf2_rowspace_dimension(hz_rows)
    kernel_min_weight = kernel_min_hamming_weight(kernel_basis)
    return CSSProjectionAnalysis(
        fano_line_count=len(fano_rows),
        fano_line_rank=fano_rank,
        kernel_dimension=len(kernel_basis),
        independent_generator_rows=independent_rows,
        kernel_basis_rows=kernel_basis,
        generator_hamming_weights=tuple(hamming_weight(row) for row in independent_rows),
        kernel_min_hamming_weight=kernel_min_weight,
        steane_hx_rank=hx_rank,
        steane_hz_rank=hz_rank,
        steane_hx_contained_in_fano_rowspace=gf2_rowspace_contains(fano_rows, hx_rows),
        fano_rowspace_contained_in_steane_hx=gf2_rowspace_contains(hx_rows, fano_rows),
        rowspace_intersection_dimension=gf2_rowspace_intersection_dimension(fano_rows, hx_rows),
        steane_classical_distance=3,
        steane_css_generator_count=hx_rank + hz_rank,
    )


def format_css_projection_summary(analysis: CSSProjectionAnalysis) -> str:
    return (
        f"fano_rank={analysis.fano_line_rank}, kernel_dim={analysis.kernel_dimension}, "
        f"kernel_min_weight={analysis.kernel_min_hamming_weight}, "
        f"steane_hx_in_fano={analysis.steane_hx_contained_in_fano_rowspace}, "
        f"rowspace_intersection={analysis.rowspace_intersection_dimension}, "
        f"steane_css_generators={analysis.steane_css_generator_count}"
    )


@dataclass(frozen=True)
class FanoKernelWord:
    word_id: int
    bits: GF2Row
    hamming_weight: int
    basis_coordinates: tuple[int, ...]
    is_zero: bool


@dataclass(frozen=True)
class ShellSyndromeCandidate:
    shell_label: str
    actual_norm: int
    operator_label: str
    parity_bits: GF2Row
    in_kernel: bool
    stabilization_classes: tuple[str, ...]
    syndrome_label_candidate: str
    interpretation_status: Literal["candidate"]
    distance_to_kernel: int
    nearest_kernel_word_id: int | None
    nearest_kernel_coordinates: tuple[int, ...] | None


@dataclass(frozen=True)
class KernelBasisInvarianceReport:
    gl3_matrix_count: int
    weight_profile_invariant: bool
    min_nonzero_weight_invariant: bool
    shell_distance_to_kernel_invariant: bool
    coordinate_labels_basis_dependent: bool


@dataclass(frozen=True)
class FanoKernelShellMapAnalysis:
    claim_class: Literal["C"]
    depends_on: tuple[str, ...]
    fano_kernel_dimension: int
    fano_kernel_basis: tuple[GF2Row, ...]
    kernel_words: tuple[FanoKernelWord, ...]
    weight_profile: dict[str, int]
    min_nonzero_weight: int
    kernel_basis_independent: bool
    basis_invariance: KernelBasisInvarianceReport
    shell_syndrome_candidates: tuple[ShellSyndromeCandidate, ...]
    interpretation: dict[str, str]


SHELL_E036_STABILIZATION_PROFILE: dict[str, dict[str, object]] = {
    "N=4": {
        "actual_norm": 4,
        "operator_label": "shell_proxy_N4_for_3",
        "stabilization_classes": ("Pumpen", "Fixpunkt"),
        "syndrome_label_candidate": "correction_transition",
        "interpretation_key": "pumping",
    },
    "N=6": {
        "actual_norm": 6,
        "operator_label": "shell_proxy_N6_for_5",
        "stabilization_classes": ("Bifurkation",),
        "syndrome_label_candidate": "syndrome_split",
        "interpretation_key": "bifurcation",
    },
    "N=8": {
        "actual_norm": 8,
        "operator_label": "shell_proxy_N8_for_7",
        "stabilization_classes": ("Fixpunkt",),
        "syndrome_label_candidate": "stable_code_subspace",
        "interpretation_key": "fixpoint",
    },
}


def gf2_add(left: Sequence[int], right: Sequence[int]) -> GF2Row:
    return tuple((a ^ b) & 1 for a, b in zip(left, right, strict=True))


def gf2_mat_vec_mul(rows: Sequence[GF2Row], vector: Sequence[int]) -> GF2Row:
    return tuple(
        sum((row[col] & vector[col]) for col in range(len(vector))) & 1
        for row in rows
    )


def gf2_basis_is_independent(basis: Sequence[GF2Row]) -> bool:
    return len(basis) == gf2_rowspace_dimension(basis)


def enumerate_kernel_words(kernel_basis: Sequence[GF2Row]) -> tuple[GF2Row, ...]:
    if not kernel_basis:
        return ((0,) * IMAGINARY_COUNT,)
    width = len(kernel_basis[0])
    words: list[GF2Row] = []
    for mask in range(1 << len(kernel_basis)):
        vector = [0] * width
        for index, row in enumerate(kernel_basis):
            if (mask >> index) & 1:
                vector = list(gf2_add(vector, row))
        words.append(tuple(vector))
    return tuple(words)


def kernel_weight_profile(
    kernel_words: Sequence[GF2Row],
    *,
    include_zero: bool = True,
) -> dict[str, int]:
    counter: Counter[int] = Counter()
    for word in kernel_words:
        weight = hamming_weight(word)
        if weight == 0 and not include_zero:
            continue
        counter[weight] += 1
    return {str(weight): count for weight, count in sorted(counter.items())}


def gf2_coordinates_in_basis(basis: Sequence[GF2Row], vector: Sequence[int]) -> tuple[int, ...] | None:
    if not basis:
        return None if any(vector) else ()
    width = len(basis[0])
    if len(vector) != width:
        raise ValueError("Vector width does not match kernel basis width.")
    for mask in range(1 << len(basis)):
        combined = [0] * width
        for index, row in enumerate(basis):
            if (mask >> index) & 1:
                combined = list(gf2_add(combined, row))
        if tuple(combined) == tuple(value & 1 for value in vector):
            return tuple((mask >> index) & 1 for index in range(len(basis)))
    return None


def gf2_invertible_matrices(dimension: int) -> tuple[tuple[GF2Row, ...], ...]:
    if dimension <= 0:
        return ((),)
    matrices: list[tuple[GF2Row, ...]] = []
    for mask in range(1 << (dimension * dimension)):
        rows: list[list[int]] = []
        for row_index in range(dimension):
            value = 0
            for col in range(dimension):
                if (mask >> (row_index * dimension + col)) & 1:
                    value |= 1 << col
            rows.append(
                [((value >> col) & 1) for col in range(dimension)]
            )
        if gf2_rowspace_dimension(tuple(tuple(row) for row in rows)) == dimension:
            matrices.append(tuple(tuple(row) for row in rows))
    return tuple(matrices)


def transform_kernel_basis(
    kernel_basis: Sequence[GF2Row],
    transform_rows: Sequence[GF2Row],
) -> tuple[GF2Row, ...]:
    """Apply an element of GL(d, GF(2)) to basis columns: b'_j = sum_i T[j,i] b_i."""
    dimension = len(kernel_basis)
    output: list[GF2Row] = []
    for new_index in range(dimension):
        vector = [0] * len(kernel_basis[0])
        for old_index in range(dimension):
            if transform_rows[new_index][old_index] & 1:
                vector = list(gf2_add(vector, kernel_basis[old_index]))
        output.append(tuple(vector))
    return tuple(output)


def distance_to_kernel(vector: Sequence[int], kernel_basis: Sequence[GF2Row]) -> int:
    words = enumerate_kernel_words(kernel_basis)
    best = IMAGINARY_COUNT + 1
    for word in words:
        distance = hamming_weight(gf2_add(vector, word))
        if distance < best:
            best = distance
    return best


def nearest_nonzero_kernel_word(
    vector: Sequence[int],
    kernel_basis: Sequence[GF2Row],
) -> tuple[GF2Row, tuple[int, ...]] | None:
    best_distance = IMAGINARY_COUNT + 1
    best_word: GF2Row | None = None
    best_coords: tuple[int, ...] | None = None
    for word in enumerate_kernel_words(kernel_basis):
        if hamming_weight(word) == 0:
            continue
        distance = hamming_weight(gf2_add(vector, word))
        if distance < best_distance:
            best_distance = distance
            best_word = word
            best_coords = gf2_coordinates_in_basis(kernel_basis, word)
    if best_word is None or best_coords is None:
        return None
    return best_word, best_coords


def build_fano_kernel_words(
    kernel_basis: Sequence[GF2Row] | None = None,
) -> tuple[FanoKernelWord, ...]:
    css = analyze_css_projection()
    kernel_basis = tuple(kernel_basis or css.kernel_basis_rows)
    words: list[FanoKernelWord] = []
    for word_id, bits in enumerate(enumerate_kernel_words(kernel_basis)):
        coords = gf2_coordinates_in_basis(kernel_basis, bits)
        if coords is None:
            raise RuntimeError("Kernel word is not representable in the supplied basis.")
        words.append(
            FanoKernelWord(
                word_id=word_id,
                bits=bits,
                hamming_weight=hamming_weight(bits),
                basis_coordinates=coords,
                is_zero=hamming_weight(bits) == 0,
            )
        )
    return tuple(words)


def verify_kernel_basis_invariance(
    kernel_basis: Sequence[GF2Row] | None = None,
    *,
    shell_parities: Sequence[GF2Row] | None = None,
) -> KernelBasisInvarianceReport:
    css = analyze_css_projection()
    kernel_basis = tuple(kernel_basis or css.kernel_basis_rows)
    shell_parities = tuple(shell_parities or _default_shell_parity_bits())
    reference_profile = kernel_weight_profile(enumerate_kernel_words(kernel_basis))
    reference_min = kernel_min_hamming_weight(kernel_basis)
    reference_distances = tuple(distance_to_kernel(vector, kernel_basis) for vector in shell_parities)
    gl3 = gf2_invertible_matrices(len(kernel_basis))
    weight_ok = True
    min_ok = True
    distance_ok = True
    for transform in gl3:
        rotated = transform_kernel_basis(kernel_basis, transform)
        profile = kernel_weight_profile(enumerate_kernel_words(rotated))
        if profile != reference_profile:
            weight_ok = False
        if kernel_min_hamming_weight(rotated) != reference_min:
            min_ok = False
        distances = tuple(distance_to_kernel(vector, rotated) for vector in shell_parities)
        if distances != reference_distances:
            distance_ok = False
    return KernelBasisInvarianceReport(
        gl3_matrix_count=len(gl3),
        weight_profile_invariant=weight_ok,
        min_nonzero_weight_invariant=min_ok,
        shell_distance_to_kernel_invariant=distance_ok,
        coordinate_labels_basis_dependent=True,
    )


def _octonion_imaginary_parity_bits(element: Octonion) -> GF2Row:
    mask = 0
    for index, value in enumerate(element):
        if abs(value) <= COMPONENT_TOLERANCE or index == 0:
            continue
        mask |= 1 << (index - 1)
    return parity_mask_to_bits(mask)


def _nearest_dyadic_parity_bits(element: Octonion) -> GF2Row:
    from kepler_hurwitz.discrete_time_flow import octonion_sub, project_to_hurwitz_lattice

    projected = project_to_hurwitz_lattice(element)
    nearest = min(
        enumerate_dyadic_norm2_integer_roots(),
        key=lambda root: octonion_norm_sq(octonion_sub(root, projected)),
    )
    return _octonion_imaginary_parity_bits(nearest)


def _default_shell_parity_bits() -> tuple[GF2Row, ...]:
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    parities: list[GF2Row] = []
    for operator in default_arithmetic_prime_operators():
        if operator.is_shell_proxy:
            parities.append(_nearest_dyadic_parity_bits(operator.element))
    return tuple(parities)


def analyze_fano_kernel_shell_map() -> FanoKernelShellMapAnalysis:
    css = analyze_css_projection()
    kernel_basis = css.kernel_basis_rows
    check_rows = css.independent_generator_rows
    kernel_words = build_fano_kernel_words(kernel_basis)
    weight_hist = kernel_weight_profile(tuple(word.bits for word in kernel_words))
    invariance = verify_kernel_basis_invariance(kernel_basis)
    shell_candidates: list[ShellSyndromeCandidate] = []
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    operators = {
        operator.label: operator
        for operator in default_arithmetic_prime_operators()
        if operator.is_shell_proxy
    }
    for shell_label, profile in SHELL_E036_STABILIZATION_PROFILE.items():
        operator = operators[str(profile["operator_label"])]
        parity_bits = _nearest_dyadic_parity_bits(operator.element)
        in_kernel = gf2_mat_vec_mul(check_rows, parity_bits) == (0,) * len(check_rows)
        nearest = nearest_nonzero_kernel_word(parity_bits, kernel_basis)
        shell_candidates.append(
            ShellSyndromeCandidate(
                shell_label=shell_label,
                actual_norm=int(profile["actual_norm"]),
                operator_label=str(profile["operator_label"]),
                parity_bits=parity_bits,
                in_kernel=in_kernel,
                stabilization_classes=tuple(str(item) for item in profile["stabilization_classes"]),  # type: ignore[arg-type]
                syndrome_label_candidate=str(profile["syndrome_label_candidate"]),
                interpretation_status="candidate",
                distance_to_kernel=distance_to_kernel(parity_bits, kernel_basis),
                nearest_kernel_word_id=(
                    next(
                        (word.word_id for word in kernel_words if word.bits == nearest[0]),
                        None,
                    )
                    if nearest is not None
                    else None
                ),
                nearest_kernel_coordinates=nearest[1] if nearest is not None else None,
            )
        )
    interpretation = {
        str(profile["interpretation_key"]): "candidate"
        for profile in SHELL_E036_STABILIZATION_PROFILE.values()
    }
    return FanoKernelShellMapAnalysis(
        claim_class="C",
        depends_on=("E-037", "E-038"),
        fano_kernel_dimension=len(kernel_basis),
        fano_kernel_basis=kernel_basis,
        kernel_words=kernel_words,
        weight_profile=weight_hist,
        min_nonzero_weight=kernel_min_hamming_weight(kernel_basis),
        kernel_basis_independent=gf2_basis_is_independent(kernel_basis),
        basis_invariance=invariance,
        shell_syndrome_candidates=tuple(shell_candidates),
        interpretation=interpretation,
    )


def export_fano_kernel_shell_map_json(
    analysis: FanoKernelShellMapAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "depends_on": list(analysis.depends_on),
        "fano_kernel": {
            "dimension": analysis.fano_kernel_dimension,
            "basis": [list(row) for row in analysis.fano_kernel_basis],
            "basis_independent": analysis.kernel_basis_independent,
            "words": [
                {
                    "word_id": word.word_id,
                    "bits": list(word.bits),
                    "hamming_weight": word.hamming_weight,
                    "basis_coordinates": list(word.basis_coordinates),
                    "is_zero": word.is_zero,
                }
                for word in analysis.kernel_words
            ],
            "weight_profile": analysis.weight_profile,
            "min_nonzero_weight": analysis.min_nonzero_weight,
        },
        "basis_invariance": asdict(analysis.basis_invariance),
        "shell_syndrome_map": {
            candidate.shell_label: {
                "actual_norm": candidate.actual_norm,
                "operator_label": candidate.operator_label,
                "parity_bits": list(candidate.parity_bits),
                "in_kernel": candidate.in_kernel,
                "stabilization_classes": list(candidate.stabilization_classes),
                "syndrome_label_candidate": candidate.syndrome_label_candidate,
                "interpretation_status": candidate.interpretation_status,
                "distance_to_kernel": candidate.distance_to_kernel,
                "nearest_kernel_word_id": candidate.nearest_kernel_word_id,
                "nearest_kernel_coordinates": (
                    list(candidate.nearest_kernel_coordinates)
                    if candidate.nearest_kernel_coordinates is not None
                    else None
                ),
            }
            for candidate in analysis.shell_syndrome_candidates
        },
        "interpretation": analysis.interpretation,
        "methodological_note": (
            "Classification and correlation structure only; not a causal identification. "
            "Coordinate labels are basis-dependent; distance-to-kernel and weight profile are GL(3,GF(2)) invariant."
        ),
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_fano_kernel_shell_map_summary(analysis: FanoKernelShellMapAnalysis) -> str:
    shells = ", ".join(
        f"{item.shell_label}:d={item.distance_to_kernel}"
        for item in analysis.shell_syndrome_candidates
    )
    return (
        f"claim_class={analysis.claim_class}, kernel_dim={analysis.fano_kernel_dimension}, "
        f"kernel_words={len(analysis.kernel_words)}, min_nonzero_weight={analysis.min_nonzero_weight}, "
        f"gl3_invariant={analysis.basis_invariance.weight_profile_invariant and analysis.basis_invariance.shell_distance_to_kernel_invariant}, "
        f"shells=[{shells}]"
    )


@dataclass(frozen=True)
class ShellCosetRecord:
    shell_label: str
    actual_norm: int
    parity_bits: GF2Row
    syndrome: GF2Row
    syndrome_id: str
    canonical_representative: GF2Row
    coset_weight_profile: dict[str, int]
    distance_to_kernel: int
    nearest_kernel_coordinates: tuple[int, ...] | None
    in_kernel: bool


@dataclass(frozen=True)
class CosetQuotientSummary:
    ambient_dimension: int
    kernel_dimension: int
    check_row_count: int
    number_of_cosets: int


@dataclass(frozen=True)
class CosetBasisInvarianceReport:
    gl3_matrix_count: int
    syndrome_labels_invariant: bool
    coset_weight_profiles_invariant: bool
    nearest_kernel_coordinates_not_used_as_invariant: bool


@dataclass(frozen=True)
class FanoShellCosetAnalysis:
    claim_class: Literal["C"]
    upgrade_candidate: str
    e039_upgrade_eligible: bool
    depends_on: tuple[str, ...]
    quotient: CosetQuotientSummary
    check_rows: tuple[GF2Row, ...]
    shell_cosets: tuple[ShellCosetRecord, ...]
    relations: dict[str, bool | None]
    basis_invariance: CosetBasisInvarianceReport
    methodological_note: str


def gf2_coset_syndrome(check_rows: Sequence[GF2Row], vector: Sequence[int]) -> GF2Row:
    """Syndrome sigma = R @ v (mod 2); coset label for v + ker(R)."""
    return gf2_mat_vec_mul(check_rows, vector)


def coset_equivalent(
    left: Sequence[int],
    right: Sequence[int],
    check_rows: Sequence[GF2Row],
) -> bool:
    return gf2_coset_syndrome(check_rows, left) == gf2_coset_syndrome(check_rows, right)


def syndrome_id(syndrome: Sequence[int]) -> str:
    return "".join(str(bit & 1) for bit in syndrome)


def canonical_coset_representative(
    vector: Sequence[int],
    kernel_basis: Sequence[GF2Row],
) -> GF2Row:
    best: GF2Row | None = None
    best_weight = IMAGINARY_COUNT + 1
    for kernel_word in enumerate_kernel_words(kernel_basis):
        candidate = gf2_add(vector, kernel_word)
        weight = hamming_weight(candidate)
        if weight < best_weight or (weight == best_weight and (best is None or candidate < best)):
            best = candidate
            best_weight = weight
    if best is None:
        raise RuntimeError("Could not build canonical coset representative.")
    return best


def coset_weight_profile(vector: Sequence[int], kernel_basis: Sequence[GF2Row]) -> dict[str, int]:
    weights: Counter[int] = Counter()
    for kernel_word in enumerate_kernel_words(kernel_basis):
        weights[hamming_weight(gf2_add(vector, kernel_word))] += 1
    return {str(weight): count for weight, count in sorted(weights.items())}


def verify_coset_syndrome_basis_invariant(
    *,
    check_rows: Sequence[GF2Row],
    kernel_basis: Sequence[GF2Row],
    shell_vectors: Sequence[GF2Row],
) -> CosetBasisInvarianceReport:
    reference_syndromes = tuple(gf2_coset_syndrome(check_rows, vector) for vector in shell_vectors)
    reference_profiles = tuple(coset_weight_profile(vector, kernel_basis) for vector in shell_vectors)
    gl3 = gf2_invertible_matrices(len(kernel_basis))
    syndrome_ok = True
    profile_ok = True
    for transform in gl3:
        rotated = transform_kernel_basis(kernel_basis, transform)
        syndromes = tuple(gf2_coset_syndrome(check_rows, vector) for vector in shell_vectors)
        profiles = tuple(coset_weight_profile(vector, rotated) for vector in shell_vectors)
        if syndromes != reference_syndromes:
            syndrome_ok = False
        if profiles != reference_profiles:
            profile_ok = False
    n4_coords = None
    n8_coords = None
    for vector, label in zip(shell_vectors, ("N=4", "N=6", "N=8"), strict=False):
        if label == "N=4":
            nearest = nearest_nonzero_kernel_word(vector, kernel_basis)
            n4_coords = nearest[1] if nearest else None
        if label == "N=8":
            nearest = nearest_nonzero_kernel_word(vector, kernel_basis)
            n8_coords = nearest[1] if nearest else None
    coords_may_collide = n4_coords == n8_coords and n4_coords is not None
    return CosetBasisInvarianceReport(
        gl3_matrix_count=len(gl3),
        syndrome_labels_invariant=syndrome_ok,
        coset_weight_profiles_invariant=profile_ok,
        nearest_kernel_coordinates_not_used_as_invariant=coords_may_collide,
    )


def analyze_shell_cosets_mod_kernel() -> FanoShellCosetAnalysis:
    css = analyze_css_projection()
    kernel_map = analyze_fano_kernel_shell_map()
    check_rows = css.independent_generator_rows
    kernel_basis = css.kernel_basis_rows
    shell_cosets: list[ShellCosetRecord] = []
    lookup: dict[str, ShellCosetRecord] = {}
    for candidate in kernel_map.shell_syndrome_candidates:
        syndrome = gf2_coset_syndrome(check_rows, candidate.parity_bits)
        record = ShellCosetRecord(
            shell_label=candidate.shell_label,
            actual_norm=candidate.actual_norm,
            parity_bits=candidate.parity_bits,
            syndrome=syndrome,
            syndrome_id=syndrome_id(syndrome),
            canonical_representative=canonical_coset_representative(candidate.parity_bits, kernel_basis),
            coset_weight_profile=coset_weight_profile(candidate.parity_bits, kernel_basis),
            distance_to_kernel=candidate.distance_to_kernel,
            nearest_kernel_coordinates=candidate.nearest_kernel_coordinates,
            in_kernel=candidate.in_kernel,
        )
        shell_cosets.append(record)
        lookup[candidate.shell_label] = record
    shell_vectors = tuple(record.parity_bits for record in shell_cosets)
    invariance = verify_coset_syndrome_basis_invariant(
        check_rows=check_rows,
        kernel_basis=kernel_basis,
        shell_vectors=shell_vectors,
    )
    n4 = lookup["N=4"]
    n6 = lookup["N=6"]
    n8 = lookup["N=8"]
    relations = {
        "N4_equals_N8_coset": coset_equivalent(n4.parity_bits, n8.parity_bits, check_rows),
        "N4_equals_N6_coset": coset_equivalent(n4.parity_bits, n6.parity_bits, check_rows),
        "N6_equals_N8_coset": coset_equivalent(n6.parity_bits, n8.parity_bits, check_rows),
    }
    upgrade_eligible = relations["N4_equals_N8_coset"] is False
    return FanoShellCosetAnalysis(
        claim_class="C",
        upgrade_candidate="E-039",
        e039_upgrade_eligible=upgrade_eligible,
        depends_on=("E-037", "E-038", "E-039-pre"),
        quotient=CosetQuotientSummary(
            ambient_dimension=IMAGINARY_COUNT,
            kernel_dimension=len(kernel_basis),
            check_row_count=len(check_rows),
            number_of_cosets=1 << (IMAGINARY_COUNT - len(kernel_basis)),
        ),
        check_rows=check_rows,
        shell_cosets=tuple(shell_cosets),
        relations=relations,
        basis_invariance=invariance,
        methodological_note=(
            "Coset classes are labeled by syndrome vectors sigma = R @ v and are basis-independent. "
            "Nearest kernel coordinates are not used as invariants. "
            "E-039 [B] requires distinct cosets for N=4 and N=8; current parity extraction yields sigma_4 = sigma_8."
        ),
    )


def export_fano_shell_cosets_json(
    analysis: FanoShellCosetAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "upgrade_candidate": analysis.upgrade_candidate,
        "e039_upgrade_eligible": analysis.e039_upgrade_eligible,
        "depends_on": list(analysis.depends_on),
        "quotient": asdict(analysis.quotient),
        "check_rows": [list(row) for row in analysis.check_rows],
        "shell_cosets": {
            record.shell_label: {
                "actual_norm": record.actual_norm,
                "parity_bits": list(record.parity_bits),
                "syndrome": list(record.syndrome),
                "syndrome_id": record.syndrome_id,
                "canonical_representative": list(record.canonical_representative),
                "coset_weight_profile": record.coset_weight_profile,
                "distance_to_kernel": record.distance_to_kernel,
                "nearest_kernel_coordinates": (
                    list(record.nearest_kernel_coordinates)
                    if record.nearest_kernel_coordinates is not None
                    else None
                ),
                "in_kernel": record.in_kernel,
            }
            for record in analysis.shell_cosets
        },
        "relations": analysis.relations,
        "basis_invariance": asdict(analysis.basis_invariance),
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_fano_shell_cosets_summary(analysis: FanoShellCosetAnalysis) -> str:
    syndromes = ", ".join(
        f"{record.shell_label}:sigma={record.syndrome_id}"
        for record in analysis.shell_cosets
    )
    return (
        f"claim_class={analysis.claim_class}, cosets={analysis.quotient.number_of_cosets}, "
        f"upgrade_eligible={analysis.e039_upgrade_eligible}, "
        f"relations={analysis.relations}, syndromes=[{syndromes}]"
    )


RefinementMode = Literal["hurwitz_residue", "signed_support", "real_axis"]


@dataclass(frozen=True)
class ShellProjectionBundle:
    operator_label: str
    element: Octonion
    projected: Octonion
    nearest_dyadic_root: Octonion
    residue: Octonion
    parity_bits: GF2Row
    syndrome: GF2Row
    syndrome_id: str


@dataclass(frozen=True)
class HurwitzResidueSignature:
    projected: Octonion
    nearest_dyadic_root: Octonion
    residue: Octonion
    residue_norm_sq: float
    projected_key: tuple[float, ...]
    nearest_key: tuple[float, ...]
    residue_key: tuple[float, ...]


@dataclass(frozen=True)
class SignedSupportSignature:
    positive_imaginary_mask: GF2Row
    negative_imaginary_mask: GF2Row
    signed_imaginary_support: tuple[tuple[int, int], ...]
    real_sign: int
    real_magnitude: float


@dataclass(frozen=True)
class RealAxisSignature:
    real_part: float
    imaginary_support_parity: GF2Row
    projected_norm_sq: float
    signature_key: tuple[float, GF2Row]


@dataclass(frozen=True)
class RefinedShellSignature:
    shell_label: str
    actual_norm: int
    operator_label: str
    old_syndrome_id: str
    hurwitz_residue: HurwitzResidueSignature
    signed_support: SignedSupportSignature
    real_axis: RealAxisSignature


@dataclass(frozen=True)
class RefinementModeReport:
    mode: RefinementMode
    signature_keys_by_shell: dict[str, str]
    separates_N4_N8: bool
    preserves_N6_separation_from_N4: bool
    preserves_N6_separation_from_N8: bool
    upgrade_eligible: bool


@dataclass(frozen=True)
class RefinedShellProjectionAnalysis:
    claim_class: Literal["C"]
    depends_on: tuple[str, ...]
    input_fact: dict[str, bool]
    signatures: tuple[RefinedShellSignature, ...]
    refinements: dict[str, RefinementModeReport]
    upgrade_condition: dict[str, object]
    any_mode_separates_N4_N8: bool
    methodological_note: str


def _round_octonion_canonical(element: Octonion, *, digits: int = 6) -> Octonion:
    return tuple(round(component, digits) for component in element)  # type: ignore[return-value]


def _octonion_key(element: Octonion, *, digits: int = 6) -> tuple[float, ...]:
    return _round_octonion_canonical(element, digits=digits)


def _nearest_dyadic_root(element: Octonion) -> Octonion:
    from kepler_hurwitz.discrete_time_flow import octonion_sub, project_to_hurwitz_lattice

    projected = project_to_hurwitz_lattice(element)
    return min(
        enumerate_dyadic_norm2_integer_roots(),
        key=lambda root: octonion_norm_sq(octonion_sub(root, projected)),
    )


def build_shell_projection_bundle(element: Octonion, *, operator_label: str = "") -> ShellProjectionBundle:
    from kepler_hurwitz.discrete_time_flow import octonion_sub, project_to_hurwitz_lattice

    css = analyze_css_projection()
    projected = _round_octonion_canonical(project_to_hurwitz_lattice(element))
    nearest = _round_octonion_canonical(_nearest_dyadic_root(element))
    residue = _round_octonion_canonical(
        tuple(a - b for a, b in zip(projected, nearest, strict=True))  # type: ignore[arg-type]
    )
    parity_bits = _octonion_imaginary_parity_bits(nearest)
    syndrome = gf2_coset_syndrome(css.independent_generator_rows, parity_bits)
    return ShellProjectionBundle(
        operator_label=operator_label,
        element=element,
        projected=projected,
        nearest_dyadic_root=nearest,
        residue=residue,
        parity_bits=parity_bits,
        syndrome=syndrome,
        syndrome_id=syndrome_id(syndrome),
    )


def hurwitz_residue_signature(bundle: ShellProjectionBundle) -> HurwitzResidueSignature:
    return HurwitzResidueSignature(
        projected=bundle.projected,
        nearest_dyadic_root=bundle.nearest_dyadic_root,
        residue=bundle.residue,
        residue_norm_sq=octonion_norm_sq(bundle.residue),
        projected_key=_octonion_key(bundle.projected),
        nearest_key=_octonion_key(bundle.nearest_dyadic_root),
        residue_key=_octonion_key(bundle.residue),
    )


def signed_support_signature(element: Octonion) -> SignedSupportSignature:
    from kepler_hurwitz.discrete_time_flow import project_to_hurwitz_lattice

    projected = _round_octonion_canonical(project_to_hurwitz_lattice(element))
    positive_mask = 0
    negative_mask = 0
    signed_entries: list[tuple[int, int]] = []
    real_sign = 0
    real_magnitude = 0.0
    for index, value in enumerate(projected):
        if abs(value) <= COMPONENT_TOLERANCE:
            continue
        sign = 1 if value > 0 else -1
        if index == 0:
            real_sign = sign
            real_magnitude = abs(value)
            continue
        signed_entries.append((index, sign))
        if sign > 0:
            positive_mask |= 1 << (index - 1)
        else:
            negative_mask |= 1 << (index - 1)
    return SignedSupportSignature(
        positive_imaginary_mask=parity_mask_to_bits(positive_mask),
        negative_imaginary_mask=parity_mask_to_bits(negative_mask),
        signed_imaginary_support=tuple(signed_entries),
        real_sign=real_sign,
        real_magnitude=real_magnitude,
    )


def real_axis_signature(element: Octonion) -> RealAxisSignature:
    bundle = build_shell_projection_bundle(element)
    real_part = bundle.projected[0]
    return RealAxisSignature(
        real_part=real_part,
        imaginary_support_parity=_octonion_imaginary_parity_bits(bundle.projected),
        projected_norm_sq=octonion_norm_sq(bundle.projected),
        signature_key=(round(real_part, 6), bundle.parity_bits),
    )


def _refinement_key_hurwitz_residue(signature: HurwitzResidueSignature) -> str:
    return json.dumps(
        {
            "projected": list(signature.projected_key),
            "nearest": list(signature.nearest_key),
            "residue": list(signature.residue_key),
        },
        sort_keys=True,
    )


def _refinement_key_signed_support(signature: SignedSupportSignature) -> str:
    return json.dumps(
        {
            "positive": list(signature.positive_imaginary_mask),
            "negative": list(signature.negative_imaginary_mask),
            "real_sign": signature.real_sign,
            "real_magnitude": round(signature.real_magnitude, 6),
        },
        sort_keys=True,
    )


def _refinement_key_real_axis(signature: RealAxisSignature) -> str:
    return json.dumps(
        {
            "real_part": round(signature.real_part, 6),
            "imaginary_support": list(signature.imaginary_support_parity),
            "projected_norm_sq": round(signature.projected_norm_sq, 6),
        },
        sort_keys=True,
    )


def _build_refinement_mode_report(
    mode: RefinementMode,
    signatures: Sequence[RefinedShellSignature],
) -> RefinementModeReport:
    keys: dict[str, str] = {}
    for item in signatures:
        if mode == "hurwitz_residue":
            keys[item.shell_label] = _refinement_key_hurwitz_residue(item.hurwitz_residue)
        elif mode == "signed_support":
            keys[item.shell_label] = _refinement_key_signed_support(item.signed_support)
        else:
            keys[item.shell_label] = _refinement_key_real_axis(item.real_axis)
    n4 = keys["N=4"]
    n6 = keys["N=6"]
    n8 = keys["N=8"]
    separates_n4_n8 = n4 != n8
    return RefinementModeReport(
        mode=mode,
        signature_keys_by_shell=keys,
        separates_N4_N8=separates_n4_n8,
        preserves_N6_separation_from_N4=n6 != n4,
        preserves_N6_separation_from_N8=n6 != n8,
        upgrade_eligible=separates_n4_n8 and n6 != n4 and n6 != n8,
    )


def analyze_refined_shell_projection() -> RefinedShellProjectionAnalysis:
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    coset_analysis = analyze_shell_cosets_mod_kernel()
    signatures: list[RefinedShellSignature] = []
    operators = {
        operator.label: operator
        for operator in default_arithmetic_prime_operators()
        if operator.is_shell_proxy
    }
    for shell_label, profile in SHELL_E036_STABILIZATION_PROFILE.items():
        operator = operators[str(profile["operator_label"])]
        bundle = build_shell_projection_bundle(operator.element, operator_label=operator.label)
        signatures.append(
            RefinedShellSignature(
                shell_label=shell_label,
                actual_norm=int(profile["actual_norm"]),
                operator_label=operator.label,
                old_syndrome_id=bundle.syndrome_id,
                hurwitz_residue=hurwitz_residue_signature(bundle),
                signed_support=signed_support_signature(operator.element),
                real_axis=real_axis_signature(operator.element),
            )
        )
    refinements = {
        mode: _build_refinement_mode_report(mode, signatures)
        for mode in ("hurwitz_residue", "signed_support", "real_axis")
    }
    any_mode_separates = any(report.separates_N4_N8 for report in refinements.values())
    return RefinedShellProjectionAnalysis(
        claim_class="C",
        depends_on=("E-039",),
        input_fact={
            "sigma_4_equals_sigma_8": coset_analysis.relations["N4_equals_N8_coset"] is True,
            "sigma_6_separated": coset_analysis.relations["N4_equals_N6_coset"] is False,
        },
        signatures=tuple(signatures),
        refinements=refinements,
        upgrade_condition={
            "required": "canonical_refinement_separates_N4_N8",
            "no_basis_choice": True,
            "no_posthoc_labeling": True,
            "any_mode_separates_N4_N8": any_mode_separates,
        },
        any_mode_separates_N4_N8=any_mode_separates,
        methodological_note=(
            "Refinements are defined from Hurwitz projection geometry before shell-role comparison. "
            "Residue-only keys may coincide for N=4 and N=8; projected and signed-support keys may differ. "
            "No upgrade to E-039 [B] without a pre-defined refinement that separates N=4 and N=8 while preserving N=6 separation."
        ),
    )


def export_refined_shell_projection_json(
    analysis: RefinedShellProjectionAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "depends_on": list(analysis.depends_on),
        "input_fact": analysis.input_fact,
        "signatures": [
            {
                "shell_label": item.shell_label,
                "actual_norm": item.actual_norm,
                "operator_label": item.operator_label,
                "old_syndrome_id": item.old_syndrome_id,
                "hurwitz_residue": {
                    "projected": list(item.hurwitz_residue.projected),
                    "nearest_dyadic_root": list(item.hurwitz_residue.nearest_dyadic_root),
                    "residue": list(item.hurwitz_residue.residue),
                    "residue_norm_sq": item.hurwitz_residue.residue_norm_sq,
                },
                "signed_support": {
                    "positive_imaginary_mask": list(item.signed_support.positive_imaginary_mask),
                    "negative_imaginary_mask": list(item.signed_support.negative_imaginary_mask),
                    "signed_imaginary_support": list(item.signed_support.signed_imaginary_support),
                    "real_sign": item.signed_support.real_sign,
                    "real_magnitude": item.signed_support.real_magnitude,
                },
                "real_axis": {
                    "real_part": item.real_axis.real_part,
                    "imaginary_support_parity": list(item.real_axis.imaginary_support_parity),
                    "projected_norm_sq": item.real_axis.projected_norm_sq,
                },
            }
            for item in analysis.signatures
        ],
        "refinements": {
            mode: {
                "mode": report.mode,
                "signature_keys_by_shell": report.signature_keys_by_shell,
                "separates_N4_N8": report.separates_N4_N8,
                "preserves_N6_separation_from_N4": report.preserves_N6_separation_from_N4,
                "preserves_N6_separation_from_N8": report.preserves_N6_separation_from_N8,
                "upgrade_eligible": report.upgrade_eligible,
            }
            for mode, report in analysis.refinements.items()
        },
        "upgrade_condition": analysis.upgrade_condition,
        "any_mode_separates_N4_N8": analysis.any_mode_separates_N4_N8,
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_refined_shell_projection_summary(analysis: RefinedShellProjectionAnalysis) -> str:
    modes = ", ".join(
        f"{mode}:sep48={report.separates_N4_N8}"
        for mode, report in analysis.refinements.items()
    )
    return f"claim_class={analysis.claim_class}, any_mode_separates_N4_N8={analysis.any_mode_separates_N4_N8}, modes=[{modes}]"


PrimaryCanonicalMode = Literal["signed_support", "full_hurwitz_projection"]


@dataclass(frozen=True)
class SignedShellSyndromeRecord:
    shell_label: str
    actual_norm: int
    operator_label: str
    old_syndrome_id: str
    signed_support: SignedSupportSignature
    signed_support_key: str
    full_hurwitz_projection_key: str
    residue_only_key: str
    real_axis_key: str


@dataclass(frozen=True)
class SignedShellSyndromeAnalysis:
    claim_class: Literal["B"]
    upgrade_status: Literal["upgraded_from_pre"]
    depends_on: tuple[str, ...]
    validated_by: str
    mode: PrimaryCanonicalMode
    control_mode: PrimaryCanonicalMode
    old_fact: dict[str, bool]
    refined_signatures: dict[str, dict[str, object]]
    relations: dict[str, bool]
    control_relations: dict[str, bool]
    auxiliary: dict[str, object]
    signed_support_basis_independent: bool
    core_result: dict[str, object]
    defensive_scope: str
    methodological_note: str


def _residue_only_key(signature: HurwitzResidueSignature) -> str:
    return json.dumps({"residue": list(signature.residue_key)}, sort_keys=True)


def _build_signed_shell_records() -> tuple[RefinedShellSignature, ...]:
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    operators = {
        operator.label: operator
        for operator in default_arithmetic_prime_operators()
        if operator.is_shell_proxy
    }
    records: list[RefinedShellSignature] = []
    for shell_label, profile in SHELL_E036_STABILIZATION_PROFILE.items():
        operator = operators[str(profile["operator_label"])]
        bundle = build_shell_projection_bundle(operator.element, operator_label=operator.label)
        records.append(
            RefinedShellSignature(
                shell_label=shell_label,
                actual_norm=int(profile["actual_norm"]),
                operator_label=operator.label,
                old_syndrome_id=bundle.syndrome_id,
                hurwitz_residue=hurwitz_residue_signature(bundle),
                signed_support=signed_support_signature(operator.element),
                real_axis=real_axis_signature(operator.element),
            )
        )
    return tuple(records)


def _relation_triplet(keys: dict[str, str]) -> dict[str, bool]:
    return {
        "N4_equals_N8_refined": keys["N=4"] == keys["N=8"],
        "N4_equals_N6_refined": keys["N=4"] == keys["N=6"],
        "N6_equals_N8_refined": keys["N=6"] == keys["N=8"],
    }


def _signed_support_basis_independent(records: Sequence[RefinedShellSignature]) -> bool:
    css = analyze_css_projection()
    reference = {
        item.shell_label: _refinement_key_signed_support(item.signed_support) for item in records
    }
    for transform in gf2_invertible_matrices(len(css.kernel_basis_rows)):
        _ = transform_kernel_basis(css.kernel_basis_rows, transform)
        current = {
            item.shell_label: _refinement_key_signed_support(item.signed_support) for item in records
        }
        if current != reference:
            return False
    return True


def _signed_support_symmetry_core_stats() -> dict[str, object]:
    group = model_symmetry_group_specification()
    transforms = enumerate_model_symmetry_group()
    reports = (
        verify_signed_support_separation_under_symmetry(
            left_label="N=4", right_label="N=8", transforms=transforms
        ),
        verify_signed_support_separation_under_symmetry(
            left_label="N=4", right_label="N=6", transforms=transforms
        ),
        verify_signed_support_separation_under_symmetry(
            left_label="N=6", right_label="N=8", transforms=transforms
        ),
    )
    return {
        "old_gf2_collision": "sigma_4 = sigma_8",
        "signed_support_separates": [
            "N4_vs_N8",
            "N4_vs_N6",
            "N6_vs_N8",
        ],
        "model_symmetry_group_size": group.total_elements,
        "separation_failures_under_G_model": sum(report.failing_transform_count for report in reports),
    }


E041_DEFENSIVE_SCOPE = (
    "No causal identification of pumping/fixpoint/bifurcation; only a canonical, "
    "symmetry-invariant refined signature separation."
)


def analyze_refined_shell_cosets(
    mode: PrimaryCanonicalMode = "signed_support",
) -> SignedShellSyndromeAnalysis:
    if mode != "signed_support":
        raise ValueError("E-041 canonical primary mode is signed_support.")
    coset_analysis = analyze_shell_cosets_mod_kernel()
    records = _build_signed_shell_records()
    signed_keys = {
        item.shell_label: _refinement_key_signed_support(item.signed_support) for item in records
    }
    hurwitz_keys = {
        item.shell_label: _refinement_key_hurwitz_residue(item.hurwitz_residue) for item in records
    }
    residue_keys = {item.shell_label: _residue_only_key(item.hurwitz_residue) for item in records}
    real_keys = {item.shell_label: _refinement_key_real_axis(item.real_axis) for item in records}
    relations = _relation_triplet(signed_keys)
    control_relations = _relation_triplet(hurwitz_keys)
    refined_signatures = {
        item.shell_label: {
            "old_syndrome_id": item.old_syndrome_id,
            "signed_support": {
                "positive_imaginary_mask": list(item.signed_support.positive_imaginary_mask),
                "negative_imaginary_mask": list(item.signed_support.negative_imaginary_mask),
                "signed_imaginary_support": list(item.signed_support.signed_imaginary_support),
                "real_sign": item.signed_support.real_sign,
                "real_magnitude": item.signed_support.real_magnitude,
            },
            "signed_support_key": signed_keys[item.shell_label],
        }
        for item in records
    }
    return SignedShellSyndromeAnalysis(
        claim_class="B",
        upgrade_status="upgraded_from_pre",
        depends_on=("E-039", "E-040", "E-042"),
        validated_by="E-042",
        mode="signed_support",
        control_mode="full_hurwitz_projection",
        old_fact={
            "sigma_4_equals_sigma_8": coset_analysis.relations["N4_equals_N8_coset"] is True,
            "sigma_6_separated": coset_analysis.relations["N4_equals_N6_coset"] is False,
        },
        refined_signatures=refined_signatures,
        relations=relations,
        control_relations=control_relations,
        auxiliary={
            "residue_only_keys": residue_keys,
            "residue_only_N4_equals_N8": residue_keys["N=4"] == residue_keys["N=8"],
            "real_axis_keys": real_keys,
            "real_axis_separates_N4_N8": real_keys["N=4"] != real_keys["N=8"],
            "real_axis_is_secondary_not_primary": True,
            "full_hurwitz_projection_keys": hurwitz_keys,
        },
        signed_support_basis_independent=_signed_support_basis_independent(records),
        core_result=_signed_support_symmetry_core_stats(),
        defensive_scope=E041_DEFENSIVE_SCOPE,
        methodological_note=(
            "E-041 [B]: signed_support separates N=4, N=6, and N=8 pairwise while preserving "
            "the E-039 GF(2) collision sigma_4=sigma_8. Symmetry invariance under G_model is "
            "validated by E-042. Control: full_hurwitz_projection. Excluded as primary: "
            "residue_key alone and real_axis (norm-squared too close to shell label)."
        ),
    )


def analyze_signed_shell_syndromes() -> SignedShellSyndromeAnalysis:
    """E-041 [B]: signierte Shell-Syndrome als kanonische Verfeinerung."""
    return analyze_refined_shell_cosets(mode="signed_support")


def export_signed_shell_syndromes_json(
    analysis: SignedShellSyndromeAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "upgrade_status": analysis.upgrade_status,
        "depends_on": list(analysis.depends_on),
        "validated_by": analysis.validated_by,
        "mode": analysis.mode,
        "control_mode": analysis.control_mode,
        "old_fact": analysis.old_fact,
        "refined_signatures": analysis.refined_signatures,
        "relations": analysis.relations,
        "control_relations": analysis.control_relations,
        "auxiliary": analysis.auxiliary,
        "signed_support_basis_independent": analysis.signed_support_basis_independent,
        "core_result": analysis.core_result,
        "defensive_scope": analysis.defensive_scope,
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_signed_shell_syndromes_summary(analysis: SignedShellSyndromeAnalysis) -> str:
    return (
        f"claim_class={analysis.claim_class}, mode={analysis.mode}, "
        f"relations={analysis.relations}, control={analysis.control_relations}, "
        f"basis_independent={analysis.signed_support_basis_independent}"
    )


MODEL_SYMMETRY_GROUP_DEFINITION = (
    "G_model := Aut(Fano_7) x Z2_global_imaginary_sign. "
    "Aut(Fano_7) is the set of permutations of imaginary axes {1,...,7} that map Fano lines "
    "from discrete_time_flow.fano_triples() to Fano lines. "
    "Z2_global_imaginary_sign multiplies all imaginary components by +1 or -1; the real axis is fixed. "
    "This group is fixed before any shell comparison."
)


@dataclass(frozen=True)
class ModelSymmetryTransform:
    transform_id: int
    imaginary_permutation: tuple[int, ...]
    global_imaginary_sign: int


@dataclass(frozen=True)
class SymmetryGroupSpecification:
    name: str
    definition: str
    fano_automorphism_count: int
    global_imaginary_sign_count: int
    total_elements: int


@dataclass(frozen=True)
class SymmetrySeparationReport:
    pair: str
    preserved_for_all_transforms: bool
    failing_transform_count: int


@dataclass(frozen=True)
class SignedSupportSymmetryAnalysis:
    claim_class: Literal["C"]
    upgrade_status: Literal["pre"]
    depends_on: tuple[str, ...]
    group: SymmetryGroupSpecification
    separation_reports: tuple[SymmetrySeparationReport, ...]
    all_separations_preserved: bool
    canonicality_verified: bool
    reproducibility_verified: bool
    e041_upgrade_eligible: bool
    upgrade_conditions: dict[str, bool]
    methodological_note: str


def _fano_line_set() -> frozenset[frozenset[int]]:
    return frozenset(frozenset(line) for line in fano_triples())


def enumerate_fano_automorphisms() -> tuple[tuple[int, ...], ...]:
    line_set = _fano_line_set()
    automorphisms: list[tuple[int, ...]] = []
    for permutation in permutations(range(1, IMAGINARY_COUNT + 1)):
        if all(
            frozenset(permutation[index - 1] for index in line) in line_set
            for line in line_set
        ):
            automorphisms.append(tuple(permutation))
    if len(automorphisms) != 168:
        raise RuntimeError(f"Expected 168 Fano automorphisms, got {len(automorphisms)}.")
    return tuple(automorphisms)


def enumerate_model_symmetry_group() -> tuple[ModelSymmetryTransform, ...]:
    transforms: list[ModelSymmetryTransform] = []
    transform_id = 0
    for permutation in enumerate_fano_automorphisms():
        for global_sign in (1, -1):
            transforms.append(
                ModelSymmetryTransform(
                    transform_id=transform_id,
                    imaginary_permutation=permutation,
                    global_imaginary_sign=global_sign,
                )
            )
            transform_id += 1
    return tuple(transforms)


def model_symmetry_group_specification() -> SymmetryGroupSpecification:
    fano_count = len(enumerate_fano_automorphisms())
    sign_count = 2
    return SymmetryGroupSpecification(
        name="G_model",
        definition=MODEL_SYMMETRY_GROUP_DEFINITION,
        fano_automorphism_count=fano_count,
        global_imaginary_sign_count=sign_count,
        total_elements=fano_count * sign_count,
    )


def apply_model_symmetry(element: Octonion, transform: ModelSymmetryTransform) -> Octonion:
    out = [0.0] * 8
    out[0] = element[0]
    for index in range(1, IMAGINARY_COUNT + 1):
        target = transform.imaginary_permutation[index - 1]
        out[target] = transform.global_imaginary_sign * element[index]
    return (
        out[0],
        out[1],
        out[2],
        out[3],
        out[4],
        out[5],
        out[6],
        out[7],
    )


def _shell_elements_by_label() -> dict[str, Octonion]:
    from kepler_hurwitz.arithmetic_evolution import default_arithmetic_prime_operators

    elements: dict[str, Octonion] = {}
    operators = {
        operator.label: operator
        for operator in default_arithmetic_prime_operators()
        if operator.is_shell_proxy
    }
    for shell_label, profile in SHELL_E036_STABILIZATION_PROFILE.items():
        elements[shell_label] = operators[str(profile["operator_label"])].element
    return elements


def _signed_support_key_for_element(element: Octonion) -> str:
    return _refinement_key_signed_support(signed_support_signature(element))


def verify_signed_support_separation_under_symmetry(
    *,
    left_label: str,
    right_label: str,
    transforms: Sequence[ModelSymmetryTransform] | None = None,
) -> SymmetrySeparationReport:
    transforms = tuple(transforms or enumerate_model_symmetry_group())
    elements = _shell_elements_by_label()
    left = elements[left_label]
    right = elements[right_label]
    failures = 0
    for transform in transforms:
        left_key = _signed_support_key_for_element(apply_model_symmetry(left, transform))
        right_key = _signed_support_key_for_element(apply_model_symmetry(right, transform))
        if left_key == right_key:
            failures += 1
    pair = f"{left_label}_vs_{right_label}"
    return SymmetrySeparationReport(
        pair=pair,
        preserved_for_all_transforms=failures == 0,
        failing_transform_count=failures,
    )


def analyze_signed_support_symmetry_invariance() -> SignedSupportSymmetryAnalysis:
    group = model_symmetry_group_specification()
    transforms = enumerate_model_symmetry_group()
    if len(transforms) != group.total_elements:
        raise RuntimeError("Symmetry group enumeration mismatch.")
    reports = (
        verify_signed_support_separation_under_symmetry(
            left_label="N=4",
            right_label="N=8",
            transforms=transforms,
        ),
        verify_signed_support_separation_under_symmetry(
            left_label="N=4",
            right_label="N=6",
            transforms=transforms,
        ),
        verify_signed_support_separation_under_symmetry(
            left_label="N=6",
            right_label="N=8",
            transforms=transforms,
        ),
    )
    all_preserved = all(report.preserved_for_all_transforms for report in reports)
    first = analyze_signed_shell_syndromes()
    second = analyze_signed_shell_syndromes()
    canonicality = first.relations == second.relations and first.refined_signatures.keys() == second.refined_signatures.keys()
    reproducibility = (
        first.signed_support_basis_independent
        and first.old_fact == second.old_fact
        and all_preserved
    )
    upgrade_conditions = {
        "canonicality": canonicality,
        "symmetry_invariance": all_preserved,
        "reproducibility": reproducibility,
    }
    e041_upgrade = all(upgrade_conditions.values())
    return SignedSupportSymmetryAnalysis(
        claim_class="C",
        upgrade_status="pre",
        depends_on=("E-041",),
        group=group,
        separation_reports=reports,
        all_separations_preserved=all_preserved,
        canonicality_verified=canonicality,
        reproducibility_verified=reproducibility,
        e041_upgrade_eligible=e041_upgrade,
        upgrade_conditions=upgrade_conditions,
        methodological_note=(
            "E-042 is the invariance validator for E-041 [B]. Symmetry group G_model is declared "
            "before evaluation. Invariance requires signed_support(N=4) != signed_support(N=8) "
            "for all g in G_model, and likewise for the N=6 separation pairs."
        ),
    )


def export_signed_support_symmetry_json(
    analysis: SignedSupportSymmetryAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "claim_class": analysis.claim_class,
        "upgrade_status": analysis.upgrade_status,
        "depends_on": list(analysis.depends_on),
        "group": asdict(analysis.group),
        "separation_reports": [asdict(report) for report in analysis.separation_reports],
        "all_separations_preserved": analysis.all_separations_preserved,
        "canonicality_verified": analysis.canonicality_verified,
        "reproducibility_verified": analysis.reproducibility_verified,
        "e041_upgrade_eligible": analysis.e041_upgrade_eligible,
        "upgrade_conditions": analysis.upgrade_conditions,
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_signed_support_symmetry_summary(analysis: SignedSupportSymmetryAnalysis) -> str:
    pairs = ", ".join(
        f"{report.pair}:ok={report.preserved_for_all_transforms}"
        for report in analysis.separation_reports
    )
    return (
        f"claim_class={analysis.claim_class}, |G|={analysis.group.total_elements}, "
        f"all_preserved={analysis.all_separations_preserved}, "
        f"e041_upgrade_eligible={analysis.e041_upgrade_eligible}, pairs=[{pairs}]"
    )


def _gf2_rank(masks: Sequence[int]) -> int:
    rows = [mask for mask in masks]
    rank = 0
    for bit in range(IMAGINARY_COUNT - 1, -1, -1):
        pivot = None
        for row_index in range(rank, len(rows)):
            if (rows[row_index] >> bit) & 1:
                pivot = row_index
                break
        if pivot is None:
            continue
        rows[rank], rows[pivot] = rows[pivot], rows[rank]
        for row_index in range(len(rows)):
            if row_index != rank and ((rows[row_index] >> bit) & 1):
                rows[row_index] ^= rows[rank]
        rank += 1
    return rank


def verify_fano_multiplication_closure() -> bool:
    """Every product of two basis indices resolves in the closed octonion basis table."""
    for left in range(IMAGINARY_COUNT + 1):
        for right in range(IMAGINARY_COUNT + 1):
            left_oct = _basis_element(left)
            right_oct = _basis_element(right)
            product = octonion_mul(left_oct, right_oct)
            if not _is_basis_element(product):
                return False
    return True


def verify_imaginary_involutions() -> bool:
    for index in range(1, IMAGINARY_COUNT + 1):
        basis = _basis_element(index)
        square = octonion_mul(basis, basis)
        expected = _basis_element(0, sign=-1)
        if octonion_norm_sq(tuple(a - b for a, b in zip(square, expected, strict=True))) > COMPONENT_TOLERANCE:
            return False
    return True


def enumerate_basis_commutation_records() -> tuple[CommutationRecord, ...]:
    records: list[CommutationRecord] = []
    for left in range(IMAGINARY_COUNT + 1):
        for right in range(left, IMAGINARY_COUNT + 1):
            if left == 0 or right == 0:
                continue
            if left == right:
                records.append(
                    CommutationRecord(
                        left=left,
                        right=right,
                        product_index=0,
                        sign=-1,
                        relation="involution",
                    )
                )
                continue
            forward = octonion_mul(_basis_element(left), _basis_element(right))
            backward = octonion_mul(_basis_element(right), _basis_element(left))
            diff_norm = octonion_norm_sq(tuple(a + b for a, b in zip(forward, backward, strict=True)))
            if diff_norm <= COMPONENT_TOLERANCE:
                product_index, sign = _decode_basis_element(forward)
                records.append(
                    CommutationRecord(
                        left=left,
                        right=right,
                        product_index=product_index,
                        sign=sign,
                        relation="same",
                    )
                )
            else:
                product_index, sign = _decode_basis_element(forward)
                records.append(
                    CommutationRecord(
                        left=left,
                        right=right,
                        product_index=product_index,
                        sign=sign,
                        relation="anticommute_to_third",
                    )
                )
    return tuple(records)


def classify_dyadic_roots(
    roots: Sequence[Octonion] | None = None,
) -> tuple[DyadicRootClass, ...]:
    roots = tuple(roots or enumerate_dyadic_norm2_integer_roots())
    fano_lines = build_fano_stabilizer_generators()
    classes: list[DyadicRootClass] = []
    for class_id, root in enumerate(roots):
        signed_support = _nonzero_indices(root)
        support = frozenset(index for index, _ in signed_support)
        aligned_lines = tuple(
            line.line_index
            for line in fano_lines
            if support.issubset(set(line.indices))
        )
        classes.append(
            DyadicRootClass(
                class_id=class_id,
                support=support,
                signed_support=signed_support,
                parity_mask=_parity_mask_from_indices(support),
                fano_line_indices=aligned_lines,
                includes_real_axis=0 in support,
            )
        )
    return tuple(classes)


def fano_line_for_support(support: frozenset[int]) -> tuple[int, ...]:
    lines = build_fano_stabilizer_generators()
    return tuple(
        line.line_index
        for line in lines
        if support.issubset(set(line.indices)) and 0 not in support
    )


def syndrome_class_for_record(record: MetacommutationRecord) -> SyndromeClass:
    if record.partner_count <= 0:
        return "unresolved"
    if record.is_associative_branch and record.partner_is_dyadic_integer:
        return "associative_dyadic"
    if record.is_associative_branch:
        return "associative_half_integer"
    if record.partner_is_dyadic_integer:
        return "non_associative_dyadic"
    return "non_associative_half_integer"


def build_syndrome_table(
    records: Sequence[MetacommutationRecord] | None = None,
) -> SyndromeTable:
    records = tuple(records or analyze_dyadic_metacommutation())
    grouped: dict[tuple[SyndromeClass, int], int] = Counter()
    class_totals: Counter[str] = Counter()
    for record in records:
        syndrome_class = syndrome_class_for_record(record)
        degeneracy = record.partner_count if record.partner_count > 0 else 0
        grouped[(syndrome_class, degeneracy)] += 1
        class_totals[syndrome_class] += 1

    entries: list[SyndromeEntry] = []
    for syndrome_id, ((syndrome_class, degeneracy), count) in enumerate(
        sorted(grouped.items(), key=lambda item: (-item[1], item[0][0], item[0][1]))
    ):
        entries.append(
            SyndromeEntry(
                syndrome_id=syndrome_id,
                syndrome_class=syndrome_class,
                count=count,
                degeneracy=degeneracy,
            )
        )
    return SyndromeTable(
        total_pairs=len(records),
        syndrome_count=len(entries),
        entries=tuple(entries),
        class_totals=dict(class_totals),
    )


def default_shell_syndrome_map() -> dict[str, str]:
    """Coarse QEC-compatible labels for E-036 stabilization classes."""
    return {
        "Fixpunkt": "stable_code_subspace",
        "Ground shell": "vacuum_syndrome",
        "Pumpen": "correction_transition",
        "Bifurkation": "syndrome_split",
        "Transitiv": "transient_syndrome",
    }


def build_stabilizer_structure_summary(
    *,
    records: Sequence[MetacommutationRecord] | None = None,
    roots: Sequence[Octonion] | None = None,
) -> StabilizerStructureSummary:
    roots = tuple(roots or enumerate_dyadic_norm2_integer_roots())
    classes = classify_dyadic_roots(roots)
    syndrome_table = build_syndrome_table(records)
    return StabilizerStructureSummary(
        fano_line_count=len(fano_triples()),
        independent_generator_count=independent_fano_generator_count(),
        dyadic_root_count=len(roots),
        dyadic_class_count=len({item.parity_mask for item in classes}),
        fano_aligned_root_count=sum(1 for item in classes if item.fano_line_indices),
        real_axis_root_count=sum(1 for item in classes if item.includes_real_axis),
        syndrome_table=syndrome_table,
        shell_syndrome_map=default_shell_syndrome_map(),
    )


def export_qec_bridge_json(
    summary: StabilizerStructureSummary,
    output_path: str | Path,
    *,
    commutation_records: Sequence[CommutationRecord] | None = None,
    dyadic_classes: Sequence[DyadicRootClass] | None = None,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    commutation_records = commutation_records or enumerate_basis_commutation_records()
    dyadic_classes = dyadic_classes or classify_dyadic_roots()
    css_projection = analyze_css_projection()
    payload = {
        "summary": {
            "fano_line_count": summary.fano_line_count,
            "independent_generator_count": summary.independent_generator_count,
            "dyadic_root_count": summary.dyadic_root_count,
            "dyadic_class_count": summary.dyadic_class_count,
            "fano_aligned_root_count": summary.fano_aligned_root_count,
            "real_axis_root_count": summary.real_axis_root_count,
            "shell_syndrome_map": summary.shell_syndrome_map,
        },
        "fano_stabilizer_generators": [
            {
                "line_index": generator.line_index,
                "indices": list(generator.indices),
                "parity_mask": generator.parity_mask,
            }
            for generator in build_fano_stabilizer_generators()
        ],
        "syndrome_table": {
            "total_pairs": summary.syndrome_table.total_pairs,
            "syndrome_count": summary.syndrome_table.syndrome_count,
            "class_totals": summary.syndrome_table.class_totals,
            "entries": [asdict(entry) for entry in summary.syndrome_table.entries],
        },
        "dyadic_root_class_histogram": dict(
            Counter(len(item.fano_line_indices) for item in dyadic_classes)
        ),
        "commutation_summary": {
            "pair_count": len(commutation_records),
            "involution_count": sum(1 for item in commutation_records if item.relation == "involution"),
            "anticommutation_count": sum(
                1 for item in commutation_records if item.relation == "anticommute_to_third"
            ),
        },
        "css_projection": {
            "fano_line_rank": css_projection.fano_line_rank,
            "kernel_dimension": css_projection.kernel_dimension,
            "independent_generator_rows": [list(row) for row in css_projection.independent_generator_rows],
            "kernel_basis_rows": [list(row) for row in css_projection.kernel_basis_rows],
            "generator_hamming_weights": list(css_projection.generator_hamming_weights),
            "kernel_min_hamming_weight": css_projection.kernel_min_hamming_weight,
            "steane_hx_rank": css_projection.steane_hx_rank,
            "steane_hz_rank": css_projection.steane_hz_rank,
            "steane_hx_contained_in_fano_rowspace": css_projection.steane_hx_contained_in_fano_rowspace,
            "fano_rowspace_contained_in_steane_hx": css_projection.fano_rowspace_contained_in_steane_hx,
            "rowspace_intersection_dimension": css_projection.rowspace_intersection_dimension,
            "steane_classical_distance": css_projection.steane_classical_distance,
            "steane_css_generator_count": css_projection.steane_css_generator_count,
        },
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_stabilizer_structure_summary(summary: StabilizerStructureSummary) -> str:
    table = summary.syndrome_table
    class_line = ", ".join(f"{key}={value}" for key, value in sorted(table.class_totals.items()))
    return (
        f"fano_lines={summary.fano_line_count}, "
        f"independent_generators={summary.independent_generator_count}, "
        f"dyadic_roots={summary.dyadic_root_count}, "
        f"dyadic_classes={summary.dyadic_class_count}, "
        f"fano_aligned={summary.fano_aligned_root_count}, "
        f"real_axis_roots={summary.real_axis_root_count}, "
        f"syndrome_bins={table.syndrome_count}, "
        f"class_totals=[{class_line}]"
    )


def _basis_element(index: int, *, sign: int = 1) -> Octonion:
    values = [0.0] * 8
    values[index] = float(sign)
    return (
        values[0],
        values[1],
        values[2],
        values[3],
        values[4],
        values[5],
        values[6],
        values[7],
    )


def _decode_basis_element(x: Octonion) -> tuple[int, int]:
    support = _nonzero_indices(x)
    if len(support) != 1:
        raise ValueError(f"Expected single basis element, got {support}.")
    index, sign = support[0]
    return index, sign


def _is_basis_element(x: Octonion) -> bool:
    support = _nonzero_indices(x)
    return len(support) == 1


# --- [[5,1,3]] five-qubit stabilizer bridge (E-044, `[C]` interface) ---

FIVE_QUBIT_GENERATORS: tuple[str, ...] = ("XZZXI", "IXZZX", "XIXZZ", "ZXIXZ")
FIVE_QUBIT_WIDTH = 5


@dataclass(frozen=True)
class QECStabilizerMatch:
    dyadic_root: tuple[int, ...]
    stabilizer_string: str
    commutation_signum: int
    is_code_space_projector: bool


@dataclass(frozen=True)
class FiveQubitStabilizerBridgeSummary:
    dyadic_root_count: int
    stabilizer_count: int
    match_count: int
    commuting_matches: int
    anticommuting_matches: int
    code_space_projector_ratio: float
    unique_dyadic_symplectic_classes: int
    shell_commutation_profile: dict[str, dict[str, float | tuple[int, ...]]]
    shell_commutation_ratios_degenerate: bool


def _pauli_char_to_int(character: str) -> int:
    mapping = {"I": 0, "X": 1, "Z": 2, "Y": 3}
    if character not in mapping:
        raise ValueError(f"Unsupported Pauli character: {character!r}")
    return mapping[character]


def pauli_string_to_symplectic(stabilizer: str) -> tuple[int, int]:
    if len(stabilizer) != FIVE_QUBIT_WIDTH:
        raise ValueError(f"Expected {FIVE_QUBIT_WIDTH}-qubit stabilizer, got {stabilizer!r}.")
    x_mask = 0
    z_mask = 0
    for qubit, character in enumerate(stabilizer):
        pauli = _pauli_char_to_int(character)
        if pauli in (1, 3):
            x_mask |= 1 << qubit
        if pauli in (2, 3):
            z_mask |= 1 << qubit
    return x_mask, z_mask


def symplectic_to_pauli_string(x_mask: int, z_mask: int, *, width: int = FIVE_QUBIT_WIDTH) -> str:
    characters: list[str] = []
    for qubit in range(width):
        x_bit = (x_mask >> qubit) & 1
        z_bit = (z_mask >> qubit) & 1
        if x_bit and z_bit:
            characters.append("Y")
        elif x_bit:
            characters.append("X")
        elif z_bit:
            characters.append("Z")
        else:
            characters.append("I")
    return "".join(characters)


def symplectic_inner_product(left: tuple[int, int], right: tuple[int, int]) -> int:
    x_left, z_left = left
    x_right, z_right = right
    parity = 0
    for qubit in range(FIVE_QUBIT_WIDTH):
        x_l = (x_left >> qubit) & 1
        z_l = (z_left >> qubit) & 1
        x_r = (x_right >> qubit) & 1
        z_r = (z_right >> qubit) & 1
        parity ^= (x_l & z_r) ^ (x_r & z_l)
    return parity


def multiply_commuting_pauli_strings(left: str, right: str) -> str:
    x_left, z_left = pauli_string_to_symplectic(left)
    x_right, z_right = pauli_string_to_symplectic(right)
    if symplectic_inner_product((x_left, z_left), (x_right, z_right)) != 0:
        raise ValueError(f"Pauli strings do not commute: {left!r}, {right!r}.")
    return symplectic_to_pauli_string(x_left ^ x_right, z_left ^ z_right)


def generate_five_qubit_stabilizers() -> tuple[str, ...]:
    """Return the 15 non-trivial stabilizers of the canonical [[5,1,3]] code."""
    stabilizers: set[str] = set()
    for mask in range(1, 1 << len(FIVE_QUBIT_GENERATORS)):
        selected = [FIVE_QUBIT_GENERATORS[index] for index in range(len(FIVE_QUBIT_GENERATORS)) if mask & (1 << index)]
        product = selected[0]
        for next_string in selected[1:]:
            product = multiply_commuting_pauli_strings(product, next_string)
        stabilizers.add(product)
    ordered = tuple(sorted(stabilizers))
    if len(ordered) != 15:
        raise RuntimeError(f"Expected 15 non-trivial [[5,1,3]] stabilizers, got {len(ordered)}.")
    return ordered


def verify_five_qubit_stabilizer_commutation() -> bool:
    stabilizers = generate_five_qubit_stabilizers()
    symplectic = [pauli_string_to_symplectic(item) for item in stabilizers]
    for left_index, left in enumerate(symplectic):
        for right in symplectic[left_index + 1 :]:
            if symplectic_inner_product(left, right) != 0:
                return False
    return True


def _octonion_to_integer_tuple(element: Octonion) -> tuple[int, ...]:
    return tuple(int(round(component)) for component in element)


def dyadic_root_to_symplectic(root: Octonion) -> tuple[int, int]:
    """Project an integer norm-2 Hurwitz root onto the five-qubit symplectic plane."""
    x_mask = 0
    z_mask = 0
    for index, value in enumerate(root):
        if abs(value) <= COMPONENT_TOLERANCE:
            continue
        qubit = index % FIVE_QUBIT_WIDTH
        if value > 0:
            x_mask |= 1 << qubit
        else:
            z_mask |= 1 << qubit
    return x_mask, z_mask


def commutation_signum_between_symplectic(left: tuple[int, int], right: tuple[int, int]) -> int:
    return 1 if symplectic_inner_product(left, right) == 0 else -1


def map_dyadic_to_stabilizers(
    dyadic_roots: Sequence[Octonion] | None = None,
    *,
    stabilizers: Sequence[str] | None = None,
) -> tuple[QECStabilizerMatch, ...]:
    """Pair every dyadic norm-2 root with every [[5,1,3]] stabilizer string."""
    roots = tuple(dyadic_roots or enumerate_dyadic_norm2_integer_roots())
    stabilizer_strings = tuple(stabilizers or generate_five_qubit_stabilizers())
    stabilizer_symplectic = {
        stabilizer: pauli_string_to_symplectic(stabilizer) for stabilizer in stabilizer_strings
    }
    matches: list[QECStabilizerMatch] = []
    for root in roots:
        root_key = _octonion_to_integer_tuple(root)
        root_symplectic = dyadic_root_to_symplectic(root)
        for stabilizer in stabilizer_strings:
            signum = commutation_signum_between_symplectic(root_symplectic, stabilizer_symplectic[stabilizer])
            matches.append(
                QECStabilizerMatch(
                    dyadic_root=root_key,
                    stabilizer_string=stabilizer,
                    commutation_signum=signum,
                    is_code_space_projector=signum == 1,
                )
            )
    return tuple(matches)


def _default_shell_proxy_operators() -> tuple[tuple[str, Octonion], ...]:
    return (
        ("N=4", (2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
        ("N=6", (2.0, 1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0)),
        ("N=8", (2.0, 2.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)),
    )


def analyze_shell_five_qubit_commutation_profile(
    matches: Sequence[QECStabilizerMatch] | None = None,
) -> dict[str, dict[str, float | tuple[int, ...]]]:
    """Compare shell-proxy nearest dyadic roots against the [[5,1,3]] stabilizer algebra."""
    matches = matches or map_dyadic_to_stabilizers()
    dyadic_roots = enumerate_dyadic_norm2_integer_roots()
    stabilizers = generate_five_qubit_stabilizers()
    lookup: dict[tuple[int, ...], dict[str, int]] = {}
    for match in matches:
        lookup.setdefault(match.dyadic_root, {})[match.stabilizer_string] = match.commutation_signum

    profile: dict[str, dict[str, float | tuple[int, ...]]] = {}
    for label, operator in _default_shell_proxy_operators():
        nearest = _nearest_dyadic_root(operator)
        root_key = _octonion_to_integer_tuple(nearest)
        symplectic = dyadic_root_to_symplectic(nearest)
        signa = lookup.get(root_key, {})
        values = [signa[stabilizer] for stabilizer in stabilizers if stabilizer in signa]
        if not values:
            continue
        profile[label] = {
            "nearest_dyadic_root": root_key,
            "symplectic_encoding": symplectic,
            "commuting_stabilizer_ratio": sum(1 for item in values if item == 1) / len(values),
            "anticommuting_stabilizer_ratio": sum(1 for item in values if item == -1) / len(values),
            "mean_commutation_signum": sum(values) / len(values),
        }
    return profile


def summarize_five_qubit_stabilizer_bridge(
    matches: Sequence[QECStabilizerMatch] | None = None,
) -> FiveQubitStabilizerBridgeSummary:
    matches = matches or map_dyadic_to_stabilizers()
    stabilizers = generate_five_qubit_stabilizers()
    roots = enumerate_dyadic_norm2_integer_roots()
    commuting = sum(1 for item in matches if item.commutation_signum == 1)
    symplectic_classes = {dyadic_root_to_symplectic(root) for root in roots}
    shell_profile = analyze_shell_five_qubit_commutation_profile(matches)
    shell_ratios = {
        float(values["commuting_stabilizer_ratio"])
        for values in shell_profile.values()
        if "commuting_stabilizer_ratio" in values
    }
    return FiveQubitStabilizerBridgeSummary(
        dyadic_root_count=len(roots),
        stabilizer_count=len(stabilizers),
        match_count=len(matches),
        commuting_matches=commuting,
        anticommuting_matches=len(matches) - commuting,
        code_space_projector_ratio=commuting / len(matches),
        unique_dyadic_symplectic_classes=len(symplectic_classes),
        shell_commutation_profile=shell_profile,
        shell_commutation_ratios_degenerate=len(shell_ratios) <= 1,
    )


def format_five_qubit_stabilizer_bridge_summary(summary: FiveQubitStabilizerBridgeSummary) -> str:
    shell_lines = ", ".join(
        f"{label}: commute={float(values['commuting_stabilizer_ratio']):.3f}"
        for label, values in sorted(summary.shell_commutation_profile.items())
    )
    return (
        f"dyadic_roots={summary.dyadic_root_count}, "
        f"stabilizers={summary.stabilizer_count}, "
        f"matches={summary.match_count}, "
        f"commuting={summary.commuting_matches}, "
        f"anticommuting={summary.anticommuting_matches}, "
        f"code_space_ratio={summary.code_space_projector_ratio:.3f}, "
        f"symplectic_classes={summary.unique_dyadic_symplectic_classes}, "
        f"shell_ratio_degenerate={summary.shell_commutation_ratios_degenerate}; "
        f"shell=[{shell_lines}]"
    )


def export_five_qubit_stabilizer_bridge_json(
    summary: FiveQubitStabilizerBridgeSummary,
    output_path: str | Path,
    *,
    sample_matches: Sequence[QECStabilizerMatch] | None = None,
    sample_limit: int = 24,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    matches = sample_matches or map_dyadic_to_stabilizers()
    payload = {
        "summary": asdict(summary),
        "generators": list(FIVE_QUBIT_GENERATORS),
        "stabilizers": list(generate_five_qubit_stabilizers()),
        "sample_matches": [asdict(item) for item in matches[:sample_limit]],
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


# --- E-045-pre: signed [[5,1,3]] stabilizer support profile ---

FIVE_QUBIT_CODE_SYMMETRY_DEFINITION = (
    "G_5-code := Aut([[5,1,3]]) x Z2_global_profile_sign. "
    "Aut([[5,1,3]]) is the set of qubit permutations on {0,...,4} that map the "
    "canonical stabilizer set to itself. Z2_global_profile_sign multiplies every "
    "entry of a signed stabilizer profile by -1. This group is fixed before any "
    "shell profile comparison."
)


@dataclass(frozen=True)
class FiveQubitCodeSymmetrySpecification:
    name: str
    definition: str
    qubit_automorphism_count: int
    global_profile_sign_count: int
    total_elements: int


@dataclass(frozen=True)
class SignedStabilizerSupportAnalysis:
    id: str
    claim_class: Literal["C"]
    upgrade_status: Literal["pre"]
    depends_on: tuple[str, ...]
    old_fact: dict[str, object]
    stabilizer_order: tuple[str, ...]
    signed_profiles: dict[str, list[int]]
    raw_relations: dict[str, bool | None]
    orbit_relations: dict[str, object]
    canonical_orbit_representatives: dict[str, tuple[int, ...]]
    symmetry_group: FiveQubitCodeSymmetrySpecification
    e045_upgrade_eligible: bool
    defensive_scope: str
    methodological_note: str


def _permute_pauli_string(stabilizer: str, qubit_permutation: Sequence[int]) -> str:
    return "".join(stabilizer[qubit_permutation[qubit]] for qubit in range(FIVE_QUBIT_WIDTH))


def _stabilizer_relabel_map(qubit_permutation: Sequence[int]) -> tuple[int, ...]:
    stabilizers = generate_five_qubit_stabilizers()
    stabilizer_list = list(stabilizers)
    relabel = [0] * len(stabilizer_list)
    for index, stabilizer in enumerate(stabilizer_list):
        permuted = _permute_pauli_string(stabilizer, qubit_permutation)
        relabel[index] = stabilizer_list.index(permuted)
    return tuple(relabel)


def enumerate_five_qubit_code_automorphisms() -> tuple[tuple[int, ...], ...]:
    stabilizers = set(generate_five_qubit_stabilizers())
    automorphisms: list[tuple[int, ...]] = []
    for permutation in permutations(range(FIVE_QUBIT_WIDTH)):
        mapped = {_permute_pauli_string(stabilizer, permutation) for stabilizer in stabilizers}
        if mapped == stabilizers:
            automorphisms.append(tuple(permutation))
    if not automorphisms:
        raise RuntimeError("No qubit automorphisms found for [[5,1,3]] stabilizer code.")
    return tuple(automorphisms)


def five_qubit_code_symmetry_specification() -> FiveQubitCodeSymmetrySpecification:
    automorphism_count = len(enumerate_five_qubit_code_automorphisms())
    return FiveQubitCodeSymmetrySpecification(
        name="G_5-code",
        definition=FIVE_QUBIT_CODE_SYMMETRY_DEFINITION,
        qubit_automorphism_count=automorphism_count,
        global_profile_sign_count=2,
        total_elements=automorphism_count * 2,
    )


def _apply_stabilizer_relabel(profile: Sequence[int], relabel: Sequence[int]) -> tuple[int, ...]:
    transformed = [0] * len(profile)
    for index, value in enumerate(profile):
        transformed[relabel[index]] = value
    return tuple(transformed)


def _apply_global_profile_sign(profile: Sequence[int]) -> tuple[int, ...]:
    return tuple(-value for value in profile)


def _canonical_signed_profile_orbit(
    profile: Sequence[int],
    *,
    automorphisms: Sequence[tuple[int, ...]],
) -> tuple[int, ...]:
    variants: set[tuple[int, ...]] = set()
    base = tuple(profile)
    for permutation in automorphisms:
        relabeled = _apply_stabilizer_relabel(base, _stabilizer_relabel_map(permutation))
        variants.add(relabeled)
        variants.add(_apply_global_profile_sign(relabeled))
    return min(variants)


def _build_shell_signed_stabilizer_profile(
    shell_label: str,
    operator: Octonion,
    *,
    stabilizers: Sequence[str],
    matches: Sequence[QECStabilizerMatch],
) -> tuple[int, ...]:
    nearest = _nearest_dyadic_root(operator)
    root_key = _octonion_to_integer_tuple(nearest)
    lookup = {
        match.stabilizer_string: match.commutation_signum
        for match in matches
        if match.dyadic_root == root_key
    }
    profile = tuple(lookup[stabilizer] for stabilizer in stabilizers)
    if len(profile) != len(stabilizers):
        raise RuntimeError(f"Incomplete signed stabilizer profile for {shell_label}.")
    return profile


def analyze_signed_stabilizer_support_profile() -> SignedStabilizerSupportAnalysis:
    """E-045-pre: signed [[5,1,3]] stabilizer profiles for shell proxies N=4,6,8."""
    symmetry_group = five_qubit_code_symmetry_specification()
    automorphisms = enumerate_five_qubit_code_automorphisms()
    stabilizers = generate_five_qubit_stabilizers()
    matches = map_dyadic_to_stabilizers()

    signed_profiles: dict[str, list[int]] = {}
    canonical_orbits: dict[str, tuple[int, ...]] = {}
    for label, operator in _default_shell_proxy_operators():
        profile = _build_shell_signed_stabilizer_profile(
            label,
            operator,
            stabilizers=stabilizers,
            matches=matches,
        )
        signed_profiles[label] = list(profile)
        canonical_orbits[label] = _canonical_signed_profile_orbit(profile, automorphisms=automorphisms)

    positive_count = sum(1 for value in signed_profiles["N=4"] if value == 1)
    old_fact = {
        "scalar_ratio_degenerate": True,
        "positive_count": positive_count,
        "total_nontrivial_stabilizers": len(stabilizers),
        "E-044_negative_result_preserved": all(
            sum(1 for value in profile if value == 1) == positive_count for profile in signed_profiles.values()
        ),
    }

    raw_relations = {
        "N4_equals_N6": signed_profiles["N=4"] == signed_profiles["N=6"],
        "N4_equals_N8": signed_profiles["N=4"] == signed_profiles["N=8"],
        "N6_equals_N8": signed_profiles["N=6"] == signed_profiles["N=8"],
    }

    orbit_relations = {
        "symmetry_group_defined_before_comparison": True,
        "symmetry_group_size": symmetry_group.total_elements,
        "N4_equals_N6_orbit": canonical_orbits["N=4"] == canonical_orbits["N=6"],
        "N4_equals_N8_orbit": canonical_orbits["N=4"] == canonical_orbits["N=8"],
        "N6_equals_N8_orbit": canonical_orbits["N=6"] == canonical_orbits["N=8"],
    }

    any_orbit_separation = not all(
        orbit_relations[key]
        for key in ("N4_equals_N6_orbit", "N4_equals_N8_orbit", "N6_equals_N8_orbit")
    )
    e045_upgrade_eligible = any_orbit_separation

    return SignedStabilizerSupportAnalysis(
        id="E-045-pre",
        claim_class="C",
        upgrade_status="pre",
        depends_on=("E-044",),
        old_fact=old_fact,
        stabilizer_order=stabilizers,
        signed_profiles=signed_profiles,
        raw_relations=raw_relations,
        orbit_relations=orbit_relations,
        canonical_orbit_representatives={
            label: orbit for label, orbit in canonical_orbits.items()
        },
        symmetry_group=symmetry_group,
        e045_upgrade_eligible=e045_upgrade_eligible,
        defensive_scope=(
            "No classification theorem; tests whether the 7/15 scalar degeneration "
            "survives in the full signed stabilizer profile."
        ),
        methodological_note=(
            "E-045-pre asks whether scalar E-044 degeneration (#(+1)=7/15) persists in "
            "full signed stabilizer profiles v_N in {±1}^15, and whether orbit classes "
            "under the pre-defined G_5-code separate N=4,6,8. E-044 negative scalar "
            "result is preserved regardless."
        ),
    )


def export_signed_stabilizer_support_json(
    analysis: SignedStabilizerSupportAnalysis,
    output_path: str | Path,
) -> Path:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "id": analysis.id,
        "claim_class": analysis.claim_class,
        "upgrade_status": analysis.upgrade_status,
        "depends_on": list(analysis.depends_on),
        "old_fact": analysis.old_fact,
        "stabilizer_order": list(analysis.stabilizer_order),
        "signed_profiles": analysis.signed_profiles,
        "raw_relations": analysis.raw_relations,
        "orbit_relations": analysis.orbit_relations,
        "canonical_orbit_representatives": {
            label: list(values) for label, values in analysis.canonical_orbit_representatives.items()
        },
        "symmetry_group": asdict(analysis.symmetry_group),
        "e045_upgrade_eligible": analysis.e045_upgrade_eligible,
        "defensive_scope": analysis.defensive_scope,
        "methodological_note": analysis.methodological_note,
    }
    destination.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    return destination


def format_signed_stabilizer_support_summary(analysis: SignedStabilizerSupportAnalysis) -> str:
    return (
        f"id={analysis.id}, claim_class={analysis.claim_class}, "
        f"positive_count={analysis.old_fact['positive_count']}/15, "
        f"raw=[N4=N6:{analysis.raw_relations['N4_equals_N6']}, "
        f"N4=N8:{analysis.raw_relations['N4_equals_N8']}, "
        f"N6=N8:{analysis.raw_relations['N6_equals_N8']}], "
        f"orbit=[N4=N6:{analysis.orbit_relations['N4_equals_N6_orbit']}, "
        f"N4=N8:{analysis.orbit_relations['N4_equals_N8_orbit']}, "
        f"N6=N8:{analysis.orbit_relations['N6_equals_N8_orbit']}], "
        f"e045_upgrade_eligible={analysis.e045_upgrade_eligible}"
    )
