from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from math import asin, atan2, cos, exp, inf, log, pi, sin, sqrt, tan
from random import Random
from typing import Iterable, Literal, Sequence

Octonion = tuple[float, float, float, float, float, float, float, float]

_FANO_TRIPLES: tuple[tuple[int, int, int], ...] = (
    (1, 2, 3),
    (1, 4, 5),
    (1, 7, 6),
    (2, 4, 6),
    (2, 5, 7),
    (3, 4, 7),
    (3, 6, 5),
)


def fano_triples() -> tuple[tuple[int, int, int], ...]:
    """Seven lines of the Fano plane underlying octonion multiplication."""
    return _FANO_TRIPLES


@dataclass(frozen=True)
class KeplerOrbitState:
    a: float
    epsilon: float
    E: float
    omega: float
    Omega: float
    i: float
    tau: float
    sigma: float


@dataclass(frozen=True)
class InverseDecode:
    a: float
    epsilon: float
    E: float
    i: float
    Omega: float
    phase: float
    E_alt: float
    E_consistency_error: float


@dataclass(frozen=True)
class PhysicalStepDiagnostics:
    state: Octonion
    was_projected: bool
    epsilon_corrected: bool
    norm_corrected: bool
    epsilon: float
    norm_sq: float
    loss: float | None = None


@dataclass(frozen=True)
class SimulationStepRecord:
    t: int
    operator: Octonion
    state: Octonion
    epsilon: float
    norm_sq: float
    norm_drift_sq: float


@dataclass(frozen=True)
class SimulationResult:
    initial_state: Octonion
    target_norm_sq: float
    records: tuple[SimulationStepRecord, ...]

    def max_norm_drift_sq(self) -> float:
        if not self.records:
            return 0.0
        return max(record.norm_drift_sq for record in self.records)

    def unique_state_count(self) -> int:
        return len({record.state for record in self.records})

    def norm_variance(self) -> float:
        if len(self.records) < 2:
            return 0.0
        norms = [record.norm_sq for record in self.records]
        mean = sum(norms) / len(norms)
        return sum((norm - mean) ** 2 for norm in norms) / len(norms)

    def states(self) -> tuple[Octonion, ...]:
        return tuple(record.state for record in self.records)


@dataclass(frozen=True)
class PhaseSpaceGridRecord:
    w_norm: float
    w_dist: float
    alpha: float
    max_norm_drift_sq: float
    unique_states: int
    norm_variance: float
    regime: str
    use_second_ring: bool
    score: float = 0.0
    recurrence_ratio: float = 0.0
    period: int | None = None


@dataclass(frozen=True)
class RankedPhaseSpaceRecord:
    w_norm: float
    w_dist: float
    alpha: float
    regime: str
    score: float
    unique_states: int
    max_norm_drift_sq: float
    norm_variance: float
    recurrence_ratio: float
    period: int | None
    end_state: Octonion
    use_second_ring: bool


@dataclass(frozen=True)
class LongRunValidationRecord:
    steps: int
    w_norm: float
    w_dist: float
    alpha: float
    regime: str
    score: float
    unique_states: int
    tail_unique_states: int
    recurrence_ratio: float
    period: int | None
    tail_period: int | None
    max_norm_drift_sq: float
    norm_variance: float
    end_state: Octonion
    use_second_ring: bool


@dataclass(frozen=True)
class AttractorSummary:
    regime: str
    tail_period: int | None
    tail_unique_states: int
    unique_states: int
    max_norm_drift_sq: float
    norm_variance: float
    recurrence_ratio: float
    score: float
    end_state: Octonion


@dataclass(frozen=True)
class NullModelControlRecord:
    control: str
    label: str
    steps: int
    regime: str
    tail_period: int | None
    tail_unique_states: int
    unique_states: int
    max_norm_drift_sq: float
    norm_variance: float
    recurrence_ratio: float
    score: float
    attractor_match_baseline: bool | None
    attractor_isomorphic_baseline: bool | None
    isomorphism_reason: str | None
    is_subset_of_baseline: bool | None
    spectrally_equivalent_baseline: bool | None
    spectral_cum_dist_diff: float | None
    end_state: Octonion


@dataclass(frozen=True)
class AttractorIsomorphismResult:
    isomorphic: bool
    reason: str
    is_subset: bool
    cyclic_shift: int | None = None
    reversed: bool | None = None
    cycle_distance: float | None = None


@dataclass(frozen=True)
class SpectralEquivalenceResult:
    is_spectrally_equivalent: bool
    size_a: int
    size_b: int
    kumulierte_distanz_differenz: float
    fingerprint_a: tuple[float, ...]
    fingerprint_b: tuple[float, ...]


def phi(orbit: KeplerOrbitState, *, a_0: float = 1.0) -> Octonion:
    if a_0 <= 0.0:
        raise ValueError("a_0 must be positive.")
    if orbit.a <= 0.0:
        raise ValueError("a must be positive.")
    if orbit.epsilon < 0.0 or orbit.epsilon >= 1.0:
        raise ValueError("epsilon must satisfy 0 <= epsilon < 1.")

    e = orbit.E
    eps = orbit.epsilon
    axis_factor = sqrt(max(0.0, 1.0 - eps * eps))
    x0 = log(orbit.a / a_0)
    x1 = eps * cos(e)
    x2 = eps * sin(e)
    x3 = axis_factor * cos(e)
    x4 = axis_factor * sin(e)
    x5 = sin(orbit.i) * cos(orbit.Omega)
    x6 = sin(orbit.i) * sin(orbit.Omega)
    x7 = orbit.omega + orbit.tau + orbit.sigma
    return (x0, x1, x2, x3, x4, x5, x6, x7)


def phi_inv(x: Octonion, *, a_0: float = 1.0) -> InverseDecode:
    if a_0 <= 0.0:
        raise ValueError("a_0 must be positive.")

    a = a_0 * exp(x[0])
    epsilon = sqrt(max(0.0, x[1] * x[1] + x[2] * x[2]))
    E_main = atan2(x[2], x[1])
    E_alt = atan2(x[4], x[3])
    E_consistency_error = abs(wrap_angle(E_alt - E_main))

    sin_i = sqrt(max(0.0, x[5] * x[5] + x[6] * x[6]))
    sin_i = min(1.0, sin_i)
    i_angle = asin(sin_i)
    Omega = atan2(x[6], x[5])
    phase = x[7]

    return InverseDecode(
        a=a,
        epsilon=epsilon,
        E=E_main,
        i=i_angle,
        Omega=Omega,
        phase=phase,
        E_alt=E_alt,
        E_consistency_error=E_consistency_error,
    )


def wrap_angle(angle: float) -> float:
    return atan2(sin(angle), cos(angle))


def _basis_mul(i: int, j: int) -> tuple[int, int]:
    if i == 0:
        return (1, j)
    if j == 0:
        return (1, i)
    if i == j:
        return (-1, 0)

    table = _basis_mul_table()
    k = table.get((i, j))
    if k is None:
        raise RuntimeError(f"Missing octonion basis entry for ({i}, {j}).")
    return k


@lru_cache(maxsize=1)
def _basis_mul_table() -> dict[tuple[int, int], tuple[int, int]]:
    table: dict[tuple[int, int], tuple[int, int]] = {}
    for a, b, c in _FANO_TRIPLES:
        table[(a, b)] = (1, c)
        table[(b, c)] = (1, a)
        table[(c, a)] = (1, b)

        table[(b, a)] = (-1, c)
        table[(c, b)] = (-1, a)
        table[(a, c)] = (-1, b)
    return table


def octonion_mul(left: Octonion, right: Octonion) -> Octonion:
    out = [0.0] * 8
    for i, li in enumerate(left):
        for j, rj in enumerate(right):
            if li == 0.0 or rj == 0.0:
                continue
            sign, k = _basis_mul(i, j)
            out[k] += sign * li * rj
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


def octonion_norm_sq(x: Octonion) -> float:
    return sum(v * v for v in x)


def evolve_right(state: Octonion, operators: Iterable[Octonion]) -> Octonion:
    out = state
    for op in operators:
        out = octonion_mul(out, op)
    return out


def associator(x: Octonion, y: Octonion, z: Octonion) -> Octonion:
    return octonion_sub(
        octonion_mul(octonion_mul(x, y), z),
        octonion_mul(x, octonion_mul(y, z)),
    )


def octonion_sub(a: Octonion, b: Octonion) -> Octonion:
    return tuple(ai - bi for ai, bi in zip(a, b, strict=True))  # type: ignore[return-value]


def orbit_distance(
    orbit_a: InverseDecode,
    orbit_b: InverseDecode,
    *,
    w_a: float = 1.0,
    w_eps: float = 1.0,
    w_E: float = 1.0,
    w_i: float = 1.0,
    w_Omega: float = 1.0,
) -> float:
    return (
        w_a * abs(orbit_a.a - orbit_b.a)
        + w_eps * abs(orbit_a.epsilon - orbit_b.epsilon)
        + w_E * abs(wrap_angle(orbit_a.E - orbit_b.E))
        + w_i * abs(orbit_a.i - orbit_b.i)
        + w_Omega * abs(wrap_angle(orbit_a.Omega - orbit_b.Omega))
    )


def project_to_hurwitz_lattice(x: Octonion) -> Octonion:
    integer_candidate = _nearest_even_integer_vector(x)
    half_candidate_shifted = _nearest_even_integer_vector(tuple(v - 0.5 for v in x))
    half_candidate = tuple(v + 0.5 for v in half_candidate_shifted)

    d_int = _dist_sq(x, integer_candidate)
    d_half = _dist_sq(x, half_candidate)
    if d_int <= d_half:
        return integer_candidate
    return half_candidate  # type: ignore[return-value]


def nearest_hurwitz_unit(x: Octonion) -> Octonion:
    units = hurwitz_units_240()
    best = units[0]
    best_dot = _dot(x, best)
    for unit in units[1:]:
        score = _dot(x, unit)
        if score > best_dot:
            best_dot = score
            best = unit
    return best


@lru_cache(maxsize=1)
def hurwitz_units_240() -> tuple[Octonion, ...]:
    units: list[Octonion] = []
    # 112 roots with two nonzero +-1 entries.
    for i in range(8):
        for j in range(i + 1, 8):
            for si in (-1.0, 1.0):
                for sj in (-1.0, 1.0):
                    v = [0.0] * 8
                    v[i] = si
                    v[j] = sj
                    units.append(tuple(v))  # type: ignore[arg-type]

    # 128 roots with all entries +-1/2 and even number of minus signs.
    for mask in range(256):
        minus_count = 0
        coords = [0.0] * 8
        for k in range(8):
            bit_set = ((mask >> k) & 1) == 1
            if bit_set:
                coords[k] = -0.5
                minus_count += 1
            else:
                coords[k] = 0.5
        if minus_count % 2 == 0:
            units.append(tuple(coords))  # type: ignore[arg-type]

    if len(units) != 240:
        raise RuntimeError(f"Expected 240 units, got {len(units)}.")
    return tuple(units)


def _nearest_even_integer_vector(x: Octonion | tuple[float, ...]) -> tuple[float, ...]:
    rounded = [float(int(round(v))) for v in x]
    parity = int(sum(rounded)) % 2
    if parity == 0:
        return tuple(rounded)

    best_index = 0
    best_penalty = float("inf")
    best_delta = 1.0
    for idx, v in enumerate(x):
        down = rounded[idx] - 1.0
        up = rounded[idx] + 1.0
        penalty_down = abs((v - down) ** 2 - (v - rounded[idx]) ** 2)
        penalty_up = abs((v - up) ** 2 - (v - rounded[idx]) ** 2)
        if penalty_down < best_penalty:
            best_penalty = penalty_down
            best_index = idx
            best_delta = -1.0
        if penalty_up < best_penalty:
            best_penalty = penalty_up
            best_index = idx
            best_delta = 1.0

    rounded[best_index] += best_delta
    return tuple(rounded)


def _dist_sq(a: Octonion | tuple[float, ...], b: Octonion | tuple[float, ...]) -> float:
    return sum((ai - bi) ** 2 for ai, bi in zip(a, b, strict=True))


def _dot(a: Octonion, b: Octonion) -> float:
    return sum(ai * bi for ai, bi in zip(a, b, strict=True))


def is_hurwitz_lattice_point(x: Octonion, *, tol: float = 1e-9) -> bool:
    ints = all(abs(v - round(v)) <= tol for v in x)
    halves = all(abs((v - 0.5) - round(v - 0.5)) <= tol for v in x)
    if not ints and not halves:
        return False
    if ints:
        return int(round(sum(x))) % 2 == 0
    shifted_sum = sum(v - 0.5 for v in x)
    return int(round(shifted_sum)) % 2 == 0


def default_demo_orbit() -> KeplerOrbitState:
    return KeplerOrbitState(
        a=1.5,
        epsilon=0.4,
        E=pi / 4.0,
        omega=0.1,
        Omega=0.5,
        i=0.2,
        tau=0.0,
        sigma=0.0,
    )


def orbit_with_combined_phase_shift(orbit: KeplerOrbitState, shift: float) -> KeplerOrbitState:
    return KeplerOrbitState(
        a=orbit.a,
        epsilon=orbit.epsilon,
        E=orbit.E,
        omega=orbit.omega,
        Omega=orbit.Omega,
        i=orbit.i,
        tau=orbit.tau + shift,
        sigma=orbit.sigma,
    )


def physical_step_filter(
    x_candidate: Octonion,
    *,
    target_norm_sq: float | None = None,
    epsilon_bound: float = 0.999999,
    resolver_mode: Literal["hard", "soft"] = "hard",
    w_dist: float = 1.0,
    w_norm: float = 5.0,
    alpha: float = 10.0,
    use_second_ring: bool = False,
    norm_tolerance: float = 1e-9,
    max_epsilon_iterations: int = 8,
) -> PhysicalStepDiagnostics:
    if epsilon_bound <= 0.0:
        raise ValueError("epsilon_bound must be positive.")
    if epsilon_bound >= 1.0:
        raise ValueError("epsilon_bound must satisfy epsilon_bound < 1.")
    if target_norm_sq is not None and target_norm_sq < 0.0:
        raise ValueError("target_norm_sq must be nonnegative.")

    if resolver_mode not in ("hard", "soft"):
        raise ValueError("resolver_mode must be one of: hard, soft.")

    state = project_to_hurwitz_lattice(x_candidate)
    was_projected = state != x_candidate
    loss: float | None = None

    if resolver_mode == "soft":
        # Local E8 neighbor search around the nearest lattice point.
        state, loss = soft_e8_resolver(
            x_candidate,
            target_norm_sq=target_norm_sq,
            epsilon_bound=epsilon_bound,
            w_dist=w_dist,
            w_norm=w_norm,
            alpha=alpha,
            use_second_ring=use_second_ring,
        )
        was_projected = True
        eps = sqrt(max(0.0, state[1] * state[1] + state[2] * state[2]))
        return PhysicalStepDiagnostics(
            state=state,
            was_projected=was_projected,
            epsilon_corrected=eps < epsilon_bound,
            norm_corrected=target_norm_sq is not None
            and abs(octonion_norm_sq(state) - target_norm_sq) <= norm_tolerance,
            epsilon=eps,
            norm_sq=octonion_norm_sq(state),
            loss=loss,
        )

    epsilon_corrected = False
    norm_corrected = False

    state, bounded = _enforce_bound_epsilon(
        state,
        epsilon_bound=epsilon_bound,
        max_iterations=max_epsilon_iterations,
    )
    if not bounded:
        # Guaranteed fallback to a bound-safe lattice point.
        state = project_to_hurwitz_lattice((state[0], 0.0, 0.0, state[3], state[4], state[5], state[6], state[7]))
    epsilon_corrected = bounded or (state[1] == 0.0 and state[2] == 0.0)

    if target_norm_sq is not None:
        state_after_norm, corrected = _enforce_target_norm(
            state,
            target_norm_sq=target_norm_sq,
            epsilon_bound=epsilon_bound,
            norm_tolerance=norm_tolerance,
        )
        state = state_after_norm
        norm_corrected = corrected
        # Re-check epsilon bound after norm adjustment.
        state, bounded = _enforce_bound_epsilon(
            state,
            epsilon_bound=epsilon_bound,
            max_iterations=max_epsilon_iterations,
        )
        if not bounded:
            state = project_to_hurwitz_lattice((state[0], 0.0, 0.0, state[3], state[4], state[5], state[6], state[7]))

    state = project_to_hurwitz_lattice(state)
    eps = sqrt(max(0.0, state[1] * state[1] + state[2] * state[2]))
    return PhysicalStepDiagnostics(
        state=state,
        was_projected=was_projected,
        epsilon_corrected=epsilon_corrected,
        norm_corrected=norm_corrected,
        epsilon=eps,
        norm_sq=octonion_norm_sq(state),
        loss=loss,
    )


def simulate_physical_flow(
    initial_state: Octonion,
    *,
    steps: int,
    operators: Sequence[Octonion] | None = None,
    mode: Literal["cyclic", "random"] = "cyclic",
    seed: int = 11,
    enforce_norm: bool = True,
    epsilon_bound: float = 0.999999,
    resolver_mode: Literal["hard", "soft"] = "hard",
    w_dist: float = 1.0,
    w_norm: float = 5.0,
    alpha: float = 10.0,
    use_second_ring: bool = False,
    perturb_at_step: int | None = None,
    perturb_operator: Octonion | None = None,
) -> SimulationResult:
    if steps < 0:
        raise ValueError("steps must be nonnegative.")
    if operators is None:
        operators = hurwitz_units_240()
    if len(operators) == 0:
        raise ValueError("operators must not be empty.")
    if mode not in ("cyclic", "random"):
        raise ValueError("mode must be one of: cyclic, random.")
    if perturb_at_step is not None:
        if perturb_at_step <= 0 or perturb_at_step > steps:
            raise ValueError("perturb_at_step must satisfy 1 <= perturb_at_step <= steps.")
        if perturb_operator is None:
            raise ValueError("perturb_operator is required when perturb_at_step is set.")

    target_norm_sq = octonion_norm_sq(initial_state)
    state = initial_state
    records: list[SimulationStepRecord] = []
    rng = Random(seed)

    for t in range(1, steps + 1):
        if mode == "cyclic":
            op = operators[(t - 1) % len(operators)]
        else:
            op = operators[rng.randrange(0, len(operators))]

        candidate = octonion_mul(state, op)
        diagnostics = physical_step_filter(
            candidate,
            target_norm_sq=target_norm_sq if enforce_norm else None,
            epsilon_bound=epsilon_bound,
            resolver_mode=resolver_mode,
            w_dist=w_dist,
            w_norm=w_norm,
            alpha=alpha,
            use_second_ring=use_second_ring,
        )
        state = diagnostics.state
        records.append(
            SimulationStepRecord(
                t=t,
                operator=op,
                state=state,
                epsilon=diagnostics.epsilon,
                norm_sq=diagnostics.norm_sq,
                norm_drift_sq=abs(diagnostics.norm_sq - target_norm_sq),
            )
        )

        if perturb_at_step is not None and t == perturb_at_step:
            perturbed = octonion_mul(state, perturb_operator)  # type: ignore[arg-type]
            perturb_diagnostics = physical_step_filter(
                perturbed,
                target_norm_sq=target_norm_sq if enforce_norm else None,
                epsilon_bound=epsilon_bound,
                resolver_mode=resolver_mode,
                w_dist=w_dist,
                w_norm=w_norm,
                alpha=alpha,
                use_second_ring=use_second_ring,
            )
            state = perturb_diagnostics.state
            records.append(
                SimulationStepRecord(
                    t=t,
                    operator=perturb_operator,  # type: ignore[arg-type]
                    state=state,
                    epsilon=perturb_diagnostics.epsilon,
                    norm_sq=perturb_diagnostics.norm_sq,
                    norm_drift_sq=abs(perturb_diagnostics.norm_sq - target_norm_sq),
                )
            )

    return SimulationResult(
        initial_state=initial_state,
        target_norm_sq=target_norm_sq,
        records=tuple(records),
    )


def _enforce_bound_epsilon(
    state: Octonion,
    *,
    epsilon_bound: float,
    max_iterations: int,
) -> tuple[Octonion, bool]:
    current = state
    for _ in range(max_iterations):
        eps_sq = current[1] * current[1] + current[2] * current[2]
        if eps_sq < epsilon_bound * epsilon_bound:
            return current, True
        eps = sqrt(max(0.0, eps_sq))
        if eps == 0.0:
            return current, True
        scale = epsilon_bound / eps
        trial = (
            current[0],
            current[1] * scale,
            current[2] * scale,
            current[3],
            current[4],
            current[5],
            current[6],
            current[7],
        )
        current = project_to_hurwitz_lattice(trial)
    return current, False


def _enforce_target_norm(
    state: Octonion,
    *,
    target_norm_sq: float,
    epsilon_bound: float,
    norm_tolerance: float,
) -> tuple[Octonion, bool]:
    norm_sq = octonion_norm_sq(state)
    if abs(norm_sq - target_norm_sq) <= norm_tolerance:
        return state, False
    if norm_sq == 0.0:
        return state, False

    scale = sqrt(target_norm_sq / norm_sq) if target_norm_sq > 0.0 else 0.0
    scaled = tuple(v * scale for v in state)
    projected = project_to_hurwitz_lattice(scaled)

    candidates = [state, projected]
    if target_norm_sq > 0.0:
        unit = nearest_hurwitz_unit(state)
        unit_norm_sq = octonion_norm_sq(unit)
        if unit_norm_sq > 0.0:
            scale_unit = sqrt(target_norm_sq / unit_norm_sq)
            candidates.append(project_to_hurwitz_lattice(tuple(scale_unit * v for v in unit)))

    best = state
    best_score = float("inf")
    for cand in candidates:
        eps_sq = cand[1] * cand[1] + cand[2] * cand[2]
        if eps_sq >= epsilon_bound * epsilon_bound:
            continue
        score = abs(octonion_norm_sq(cand) - target_norm_sq) + 0.05 * _dist_sq(state, cand)
        if score < best_score:
            best_score = score
            best = cand  # type: ignore[assignment]
    return best, True


def generate_second_ring_points(
    x_base: Octonion,
    *,
    units: Sequence[Octonion] | None = None,
) -> tuple[Octonion, ...]:
    if units is None:
        return tuple(octonion_add(x_base, displacement) for displacement in _second_ring_displacements())
    seen: set[tuple[float, ...]] = {x_base}
    candidates: list[Octonion] = [x_base]
    for u1 in units:
        point = octonion_add(x_base, u1)
        if point not in seen:
            seen.add(point)
            candidates.append(point)
        for u2 in units:
            point = octonion_add(octonion_add(x_base, u1), u2)
            if point not in seen:
                seen.add(point)
                candidates.append(point)
    return tuple(candidates)


def classify_regime(
    result: SimulationResult,
    *,
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
    use_tail_period: bool = False,
    tail_length: int = 64,
) -> str:
    unique = result.unique_state_count()
    drift = result.max_norm_drift_sq()
    var = result.norm_variance()
    period = (
        detected_tail_period(result, tail_length=tail_length)
        if use_tail_period
        else detected_period(result)
    )
    recur = recurrence_ratio(result)

    if unique <= collapse_unique_threshold:
        return "ZENONISCHER KOLLAPS"
    if drift <= drift_tol and var <= variance_tol and period is not None:
        return "STABIL / PERIODISCH"
    if drift <= drift_tol and var <= variance_tol and recur > 0:
        return "STABIL / QUASI-PERIODISCH"
    if drift <= 3 * drift_tol:
        return "KONTROLLIERT DISSIPATIV"
    return "DIFFUS / INSTABIL"


def recurrence_count(result: SimulationResult) -> int:
    seen: set[Octonion] = set()
    count = 0
    for state in result.states():
        if state in seen:
            count += 1
        else:
            seen.add(state)
    return count


def recurrence_ratio(result: SimulationResult) -> float:
    steps = max(1, len(result.records))
    return recurrence_count(result) / steps


def detected_period(result: SimulationResult) -> int | None:
    states = result.states()
    if len(states) < 2:
        return None
    last = states[-1]
    for index in range(len(states) - 2, -1, -1):
        if states[index] == last:
            return len(states) - 1 - index
    return None


def detected_tail_period(result: SimulationResult, *, tail_length: int = 64) -> int | None:
    states = result.states()
    if len(states) < 4:
        return None
    if tail_length <= 0:
        raise ValueError("tail_length must be positive.")

    effective_tail_length = min(tail_length, len(states))
    tail = states[-effective_tail_length:]
    max_period = len(tail) // 2
    for period in range(1, max_period + 1):
        periodic = True
        for index in range(period, len(tail)):
            if tail[index] != tail[index - period]:
                periodic = False
                break
        if periodic:
            return period
    return None


def tail_unique_state_count(result: SimulationResult, *, tail_length: int = 64) -> int:
    states = result.states()
    if not states:
        return 0
    if tail_length <= 0:
        raise ValueError("tail_length must be positive.")
    tail = states[-min(tail_length, len(states)) :]
    return len(set(tail))


def quasi_periodic_score(result: SimulationResult) -> float:
    steps = max(1, len(result.records))
    unique_ratio = result.unique_state_count() / steps
    drift_penalty = result.max_norm_drift_sq()
    var_penalty = result.norm_variance()
    return unique_ratio / (1.0 + drift_penalty + var_penalty)


def map_phase_space_regimes(
    initial_state: Octonion,
    *,
    steps: int,
    operators: Sequence[Octonion] | None = None,
    grid_w_norm: Sequence[float] = (1.0, 5.0, 10.0, 20.0),
    grid_w_dist: Sequence[float] = (0.5, 1.0, 2.0),
    grid_alpha: Sequence[float] = (10.0,),
    use_second_ring: bool = True,
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
    mode: Literal["cyclic", "random"] = "cyclic",
    seed: int = 11,
) -> tuple[PhaseSpaceGridRecord, ...]:
    records: list[PhaseSpaceGridRecord] = []
    for w_norm in grid_w_norm:
        for w_dist in grid_w_dist:
            for alpha in grid_alpha:
                simulation = simulate_physical_flow(
                    initial_state,
                    steps=steps,
                    operators=operators,
                    mode=mode,
                    seed=seed,
                    enforce_norm=True,
                    resolver_mode="soft",
                    w_dist=w_dist,
                    w_norm=w_norm,
                    alpha=alpha,
                    use_second_ring=use_second_ring,
                )
                regime = classify_regime(
                    simulation,
                    drift_tol=drift_tol,
                    variance_tol=variance_tol,
                    collapse_unique_threshold=collapse_unique_threshold,
                )
                records.append(
                    PhaseSpaceGridRecord(
                        w_norm=w_norm,
                        w_dist=w_dist,
                        alpha=alpha,
                        max_norm_drift_sq=simulation.max_norm_drift_sq(),
                        unique_states=simulation.unique_state_count(),
                        norm_variance=simulation.norm_variance(),
                        regime=regime,
                        use_second_ring=use_second_ring,
                        score=quasi_periodic_score(simulation),
                        recurrence_ratio=recurrence_ratio(simulation),
                        period=detected_period(simulation),
                    )
                )
    return tuple(records)


def rank_phase_space_regimes(
    initial_state: Octonion,
    *,
    steps: int,
    operators: Sequence[Octonion] | None = None,
    w_norm_values: Sequence[float] = (2.0, 5.0, 10.0, 20.0, 50.0, 100.0),
    w_dist_values: Sequence[float] = (0.1, 0.25, 0.5, 1.0, 2.0, 5.0),
    alpha_values: Sequence[float] = (0.05, 0.1, 0.2, 0.35, 0.5, 0.75),
    top_k: int = 20,
    use_second_ring: bool = True,
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
    mode: Literal["cyclic", "random"] = "cyclic",
    seed: int = 11,
) -> tuple[RankedPhaseSpaceRecord, ...]:
    if top_k <= 0:
        raise ValueError("top_k must be positive.")

    rows: list[RankedPhaseSpaceRecord] = []
    for w_norm in w_norm_values:
        for w_dist in w_dist_values:
            for alpha in alpha_values:
                simulation = simulate_physical_flow(
                    initial_state,
                    steps=steps,
                    operators=operators,
                    mode=mode,
                    seed=seed,
                    enforce_norm=True,
                    resolver_mode="soft",
                    w_dist=w_dist,
                    w_norm=w_norm,
                    alpha=alpha,
                    use_second_ring=use_second_ring,
                )
                rows.append(
                    RankedPhaseSpaceRecord(
                        w_norm=w_norm,
                        w_dist=w_dist,
                        alpha=alpha,
                        regime=classify_regime(
                            simulation,
                            drift_tol=drift_tol,
                            variance_tol=variance_tol,
                            collapse_unique_threshold=collapse_unique_threshold,
                        ),
                        score=quasi_periodic_score(simulation),
                        unique_states=simulation.unique_state_count(),
                        max_norm_drift_sq=simulation.max_norm_drift_sq(),
                        norm_variance=simulation.norm_variance(),
                        recurrence_ratio=recurrence_ratio(simulation),
                        period=detected_period(simulation),
                        end_state=simulation.states()[-1] if simulation.records else initial_state,
                        use_second_ring=use_second_ring,
                    )
                )

    rows.sort(key=lambda row: row.score, reverse=True)
    return tuple(rows[:top_k])


def validate_ranked_windows_longrun(
    records: Sequence[RankedPhaseSpaceRecord],
    *,
    initial_state: Octonion,
    steps_values: Sequence[int] = (200, 500),
    top_k: int = 3,
    operators: Sequence[Octonion] | None = None,
    tail_length: int = 64,
    mode: Literal["cyclic", "random"] = "cyclic",
    seed: int = 11,
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
) -> tuple[LongRunValidationRecord, ...]:
    if top_k <= 0:
        raise ValueError("top_k must be positive.")
    if len(records) == 0:
        return ()

    validations: list[LongRunValidationRecord] = []
    for record in records[:top_k]:
        for steps in steps_values:
            if steps <= 0:
                raise ValueError("steps_values entries must be positive.")
            simulation = simulate_physical_flow(
                initial_state,
                steps=steps,
                operators=operators,
                mode=mode,
                seed=seed,
                enforce_norm=True,
                resolver_mode="soft",
                w_dist=record.w_dist,
                w_norm=record.w_norm,
                alpha=record.alpha,
                use_second_ring=record.use_second_ring,
            )
            validations.append(
                LongRunValidationRecord(
                    steps=steps,
                    w_norm=record.w_norm,
                    w_dist=record.w_dist,
                    alpha=record.alpha,
                    regime=classify_regime(
                        simulation,
                        drift_tol=drift_tol,
                        variance_tol=variance_tol,
                        collapse_unique_threshold=collapse_unique_threshold,
                        use_tail_period=True,
                        tail_length=tail_length,
                    ),
                    score=quasi_periodic_score(simulation),
                    unique_states=simulation.unique_state_count(),
                    tail_unique_states=tail_unique_state_count(
                        simulation,
                        tail_length=tail_length,
                    ),
                    recurrence_ratio=recurrence_ratio(simulation),
                    period=detected_period(simulation),
                    tail_period=detected_tail_period(
                        simulation,
                        tail_length=tail_length,
                    ),
                    max_norm_drift_sq=simulation.max_norm_drift_sq(),
                    norm_variance=simulation.norm_variance(),
                    end_state=simulation.states()[-1] if simulation.records else initial_state,
                    use_second_ring=record.use_second_ring,
                )
            )
    return tuple(validations)


def summarize_attractor(
    result: SimulationResult,
    *,
    tail_length: int = 64,
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
) -> AttractorSummary:
    end_state = result.states()[-1] if result.records else result.initial_state
    return AttractorSummary(
        regime=classify_regime(
            result,
            drift_tol=drift_tol,
            variance_tol=variance_tol,
            collapse_unique_threshold=collapse_unique_threshold,
            use_tail_period=True,
            tail_length=tail_length,
        ),
        tail_period=detected_tail_period(result, tail_length=tail_length),
        tail_unique_states=tail_unique_state_count(result, tail_length=tail_length),
        unique_states=result.unique_state_count(),
        max_norm_drift_sq=result.max_norm_drift_sq(),
        norm_variance=result.norm_variance(),
        recurrence_ratio=recurrence_ratio(result),
        score=quasi_periodic_score(result),
        end_state=end_state,
    )


def attractor_state_set(result: SimulationResult, *, tail_length: int = 64) -> frozenset[Octonion]:
    states = result.states()
    if not states:
        return frozenset()
    period = detected_tail_period(result, tail_length=tail_length)
    if period is not None:
        return frozenset(states[-period:])
    tail = states[-min(tail_length, len(states)) :]
    return frozenset(tail)


def attractor_cycle(result: SimulationResult, *, tail_length: int = 64) -> tuple[Octonion, ...]:
    states = result.states()
    if not states:
        return ()
    period = detected_tail_period(result, tail_length=tail_length)
    if period is not None:
        return states[-period:]
    return states[-min(tail_length, len(states)) :]


def _cycle_total_distance(cycle_a: tuple[Octonion, ...], cycle_b: tuple[Octonion, ...]) -> float:
    if len(cycle_a) != len(cycle_b):
        return inf
    return sum(_dist_sq(cycle_a[index], cycle_b[index]) for index in range(len(cycle_a)))


def check_attractor_isomorphism(
    cycle_a: Sequence[Octonion],
    cycle_b: Sequence[Octonion],
    *,
    tol: float = 1e-9,
) -> AttractorIsomorphismResult:
    list_a = tuple(cycle_a)
    list_b = tuple(cycle_b)
    if len(list_a) == 0 or len(list_b) == 0:
        return AttractorIsomorphismResult(
            isomorphic=len(list_a) == len(list_b) == 0,
            reason="Empty cycle",
            is_subset=True,
            cycle_distance=0.0 if len(list_a) == len(list_b) == 0 else None,
        )

    if len(list_a) != len(list_b):
        set_a = frozenset(list_a)
        set_b = frozenset(list_b)
        return AttractorIsomorphismResult(
            isomorphic=False,
            reason=f"Dimension mismatch ({len(list_a)} vs {len(list_b)})",
            is_subset=set_a.issubset(set_b) or set_b.issubset(set_a),
        )

    best_shift: int | None = None
    best_reversed: bool | None = None
    best_distance = inf
    length = len(list_a)

    for reversed_flag in (False, True):
        oriented_b = list(reversed(list_b)) if reversed_flag else list(list_b)
        for shift in range(length):
            rotated_b = tuple(oriented_b[shift:] + oriented_b[:shift])
            distance = _cycle_total_distance(list_a, rotated_b)
            if distance < best_distance:
                best_distance = distance
                best_shift = shift
                best_reversed = reversed_flag

    if best_distance <= tol:
        orientation = "reversed cyclic" if best_reversed else "cyclic"
        return AttractorIsomorphismResult(
            isomorphic=True,
            reason=f"{orientation} shift by {best_shift}",
            is_subset=False,
            cyclic_shift=best_shift,
            reversed=best_reversed,
            cycle_distance=best_distance,
        )

    return AttractorIsomorphismResult(
        isomorphic=False,
        reason="Distinct geometric tracks",
        is_subset=False,
        cycle_distance=best_distance,
    )


def check_attractor_isomorphism_from_results(
    baseline: SimulationResult,
    candidate: SimulationResult,
    *,
    tail_length: int = 64,
    tol: float = 1e-9,
) -> AttractorIsomorphismResult:
    period_a = detected_tail_period(baseline, tail_length=tail_length)
    period_b = detected_tail_period(candidate, tail_length=tail_length)
    if period_a is None or period_b is None:
        set_a = attractor_state_set(baseline, tail_length=tail_length)
        set_b = attractor_state_set(candidate, tail_length=tail_length)
        if period_a is None and period_b is None:
            return AttractorIsomorphismResult(
                isomorphic=set_a == set_b,
                reason="Non-periodic tail set comparison",
                is_subset=set_a.issubset(set_b) or set_b.issubset(set_a),
            )
        return AttractorIsomorphismResult(
            isomorphic=False,
            reason="Periodic tail mismatch",
            is_subset=set_a.issubset(set_b) or set_b.issubset(set_a),
        )

    return check_attractor_isomorphism(
        attractor_cycle(baseline, tail_length=tail_length),
        attractor_cycle(candidate, tail_length=tail_length),
        tol=tol,
    )


def attractor_unique_cycle(result: SimulationResult, *, tail_length: int = 64) -> tuple[Octonion, ...]:
    cycle = attractor_cycle(result, tail_length=tail_length)
    unique: list[Octonion] = []
    seen: set[Octonion] = set()
    for state in cycle:
        if state not in seen:
            seen.add(state)
            unique.append(state)
    return tuple(unique)


def attractor_spectral_fingerprint(cycle_states: Sequence[Octonion]) -> tuple[float, ...]:
    states = tuple(cycle_states)
    if len(states) <= 1:
        return ()

    distances: list[float] = []
    for index in range(len(states)):
        for other in range(index + 1, len(states)):
            distances.append(sqrt(_dist_sq(states[index], states[other])))
    distances.sort()
    return tuple(distances)


def check_spectral_equivalence(
    cycle_a: Sequence[Octonion],
    cycle_b: Sequence[Octonion],
    *,
    tolerance: float = 1e-5,
) -> SpectralEquivalenceResult:
    fingerprint_a = attractor_spectral_fingerprint(cycle_a)
    fingerprint_b = attractor_spectral_fingerprint(cycle_b)

    if len(fingerprint_a) != len(fingerprint_b):
        return SpectralEquivalenceResult(
            is_spectrally_equivalent=False,
            size_a=len(tuple(cycle_a)),
            size_b=len(tuple(cycle_b)),
            kumulierte_distanz_differenz=inf,
            fingerprint_a=fingerprint_a,
            fingerprint_b=fingerprint_b,
        )

    total_diff = sum(abs(a - b) for a, b in zip(fingerprint_a, fingerprint_b, strict=True))
    return SpectralEquivalenceResult(
        is_spectrally_equivalent=total_diff < tolerance,
        size_a=len(tuple(cycle_a)),
        size_b=len(tuple(cycle_b)),
        kumulierte_distanz_differenz=total_diff,
        fingerprint_a=fingerprint_a,
        fingerprint_b=fingerprint_b,
    )


def check_spectral_equivalence_from_results(
    baseline: SimulationResult,
    candidate: SimulationResult,
    *,
    tail_length: int = 64,
    tolerance: float = 1e-5,
    use_unique_states: bool = True,
) -> SpectralEquivalenceResult:
    if use_unique_states:
        cycle_a = attractor_unique_cycle(baseline, tail_length=tail_length)
        cycle_b = attractor_unique_cycle(candidate, tail_length=tail_length)
    else:
        cycle_a = attractor_cycle(baseline, tail_length=tail_length)
        cycle_b = attractor_cycle(candidate, tail_length=tail_length)
    return check_spectral_equivalence(cycle_a, cycle_b, tolerance=tolerance)


def attractors_match(
    baseline: SimulationResult,
    candidate: SimulationResult,
    *,
    tail_length: int = 64,
) -> bool:
    baseline_period = detected_tail_period(baseline, tail_length=tail_length)
    candidate_period = detected_tail_period(candidate, tail_length=tail_length)
    if baseline_period != candidate_period:
        return False
    return attractor_state_set(baseline, tail_length=tail_length) == attractor_state_set(
        candidate,
        tail_length=tail_length,
    )


def _null_record_from_result(
    *,
    control: str,
    label: str,
    result: SimulationResult,
    baseline: SimulationResult | None,
    tail_length: int,
    drift_tol: float,
    variance_tol: float,
    collapse_unique_threshold: int,
) -> NullModelControlRecord:
    summary = summarize_attractor(
        result,
        tail_length=tail_length,
        drift_tol=drift_tol,
        variance_tol=variance_tol,
        collapse_unique_threshold=collapse_unique_threshold,
    )
    match: bool | None = None
    isomorphic: bool | None = None
    iso_reason: str | None = None
    is_subset: bool | None = None
    spectral_equiv: bool | None = None
    spectral_diff: float | None = None
    if baseline is not None:
        match = attractors_match(baseline, result, tail_length=tail_length)
        iso = check_attractor_isomorphism_from_results(
            baseline,
            result,
            tail_length=tail_length,
        )
        isomorphic = iso.isomorphic
        iso_reason = iso.reason
        is_subset = iso.is_subset
        spectral = check_spectral_equivalence_from_results(
            baseline,
            result,
            tail_length=tail_length,
        )
        spectral_equiv = spectral.is_spectrally_equivalent
        spectral_diff = spectral.kumulierte_distanz_differenz
    return NullModelControlRecord(
        control=control,
        label=label,
        steps=len(result.records),
        regime=summary.regime,
        tail_period=summary.tail_period,
        tail_unique_states=summary.tail_unique_states,
        unique_states=summary.unique_states,
        max_norm_drift_sq=summary.max_norm_drift_sq,
        norm_variance=summary.norm_variance,
        recurrence_ratio=summary.recurrence_ratio,
        score=summary.score,
        attractor_match_baseline=match,
        attractor_isomorphic_baseline=isomorphic,
        isomorphism_reason=iso_reason,
        is_subset_of_baseline=is_subset,
        spectrally_equivalent_baseline=spectral_equiv,
        spectral_cum_dist_diff=spectral_diff,
        end_state=summary.end_state,
    )


def run_nullmodel_control_suite(
    *,
    orbit: KeplerOrbitState | None = None,
    steps: int = 500,
    operators: Sequence[Octonion] | None = None,
    w_norm: float = 2.0,
    w_dist: float = 0.25,
    alpha: float = 0.1,
    use_second_ring: bool = True,
    tail_length: int = 64,
    perturb_at_step: int = 100,
    perturb_operator: Octonion | None = None,
    random_seed: int = 11,
    gauge_shifts: Sequence[float] = (pi / 4.0, pi / 2.0),
    drift_tol: float = 1.0,
    variance_tol: float = 0.5,
    collapse_unique_threshold: int = 2,
) -> tuple[NullModelControlRecord, ...]:
    if steps <= 0:
        raise ValueError("steps must be positive.")
    if perturb_at_step <= 0 or perturb_at_step >= steps:
        raise ValueError("perturb_at_step must satisfy 0 < perturb_at_step < steps.")

    orbit = orbit or default_demo_orbit()
    initial_state = phi(orbit)
    if operators is None:
        operators = hurwitz_units_240()[:8]
    operator_pool = tuple(operators)
    if perturb_operator is None:
        operator_set = set(operator_pool)
        for unit in hurwitz_units_240():
            if unit not in operator_set:
                perturb_operator = unit
                break
        if perturb_operator is None:
            perturb_operator = hurwitz_units_240()[0]

    flow_kwargs = {
        "steps": steps,
        "operators": operator_pool,
        "enforce_norm": True,
        "epsilon_bound": 0.999999,
        "resolver_mode": "soft",
        "w_dist": w_dist,
        "w_norm": w_norm,
        "alpha": alpha,
        "use_second_ring": use_second_ring,
    }

    baseline = simulate_physical_flow(initial_state, mode="cyclic", seed=random_seed, **flow_kwargs)
    records: list[NullModelControlRecord] = [
        _null_record_from_result(
            control="baseline",
            label="cyclic_operator_chain",
            result=baseline,
            baseline=None,
            tail_length=tail_length,
            drift_tol=drift_tol,
            variance_tol=variance_tol,
            collapse_unique_threshold=collapse_unique_threshold,
        )
    ]

    random_result = simulate_physical_flow(
        initial_state,
        mode="random",
        seed=random_seed,
        **flow_kwargs,
    )
    records.append(
        _null_record_from_result(
            control="operator_chain",
            label=f"random_chain_seed_{random_seed}",
            result=random_result,
            baseline=baseline,
            tail_length=tail_length,
            drift_tol=drift_tol,
            variance_tol=variance_tol,
            collapse_unique_threshold=collapse_unique_threshold,
        )
    )

    for shift in gauge_shifts:
        shifted_orbit = orbit_with_combined_phase_shift(orbit, shift)
        shifted_state = phi(shifted_orbit)
        gauge_result = simulate_physical_flow(
            shifted_state,
            mode="cyclic",
            seed=random_seed,
            **flow_kwargs,
        )
        records.append(
            _null_record_from_result(
                control="gauge_phase",
                label=f"phase_shift_{shift:.4f}",
                result=gauge_result,
                baseline=baseline,
                tail_length=tail_length,
                drift_tol=drift_tol,
                variance_tol=variance_tol,
                collapse_unique_threshold=collapse_unique_threshold,
            )
        )

    perturb_result = simulate_physical_flow(
        initial_state,
        mode="cyclic",
        seed=random_seed,
        perturb_at_step=perturb_at_step,
        perturb_operator=perturb_operator,
        **flow_kwargs,
    )
    records.append(
        _null_record_from_result(
            control="perturbation",
            label=f"inject_at_step_{perturb_at_step}",
            result=perturb_result,
            baseline=baseline,
            tail_length=tail_length,
            drift_tol=drift_tol,
            variance_tol=variance_tol,
            collapse_unique_threshold=collapse_unique_threshold,
        )
    )

    return tuple(records)


def soft_e8_resolver(
    x_ideal: Octonion,
    *,
    target_norm_sq: float | None,
    epsilon_bound: float = 0.999999,
    w_dist: float = 1.0,
    w_norm: float = 5.0,
    alpha: float = 10.0,
    use_second_ring: bool = False,
) -> tuple[Octonion, float]:
    x_base = project_to_hurwitz_lattice(x_ideal)
    if use_second_ring:
        candidates = list(generate_second_ring_points(x_base))
    else:
        candidates = [x_base]
        candidates.extend(octonion_add(x_base, unit) for unit in hurwitz_units_240())

    best = x_base
    best_loss = inf

    for cand in candidates:
        eps_sq = cand[1] * cand[1] + cand[2] * cand[2]
        eps = sqrt(max(0.0, eps_sq))
        if eps >= 1.0:
            continue

        barrier = 0.0
        if eps >= 0.95:
            barrier = alpha * tan((pi / 2.0) * eps)

        dist_loss = _dist_sq(cand, x_ideal)
        norm_loss = 0.0
        if target_norm_sq is not None:
            norm_loss = abs(octonion_norm_sq(cand) - target_norm_sq)

        total_loss = w_dist * dist_loss + w_norm * norm_loss + barrier
        if total_loss < best_loss:
            best_loss = total_loss
            best = cand

    if best_loss is inf:
        fallback = project_to_hurwitz_lattice((x_base[0], 0.0, 0.0, x_base[3], x_base[4], x_base[5], x_base[6], x_base[7]))
        return fallback, inf
    return best, best_loss


def octonion_add(a: Octonion, b: Octonion) -> Octonion:
    return tuple(ai + bi for ai, bi in zip(a, b, strict=True))  # type: ignore[return-value]


@lru_cache(maxsize=1)
def _second_ring_displacements() -> tuple[Octonion, ...]:
    zero = (0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    units = hurwitz_units_240()
    seen: set[tuple[float, ...]] = {zero}
    displacements: list[Octonion] = [zero]
    for u1 in units:
        if u1 not in seen:
            seen.add(u1)
            displacements.append(u1)
        for u2 in units:
            combined = octonion_add(u1, u2)
            if combined not in seen:
                seen.add(combined)
                displacements.append(combined)
    return tuple(displacements)
