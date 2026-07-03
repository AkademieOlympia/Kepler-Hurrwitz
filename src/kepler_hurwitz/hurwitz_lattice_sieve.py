from __future__ import annotations

from functools import lru_cache

DEFAULT_CUBE_RADIUS = 5
MAX_NORM_SQ_IN_CUBE = 8 * DEFAULT_CUBE_RADIUS * DEFAULT_CUBE_RADIUS

# Shell proxies documented in arithmetic_evolution.py for missing odd prime norms.
REQUESTED_ODD_PRIME_NORMS: tuple[int, ...] = (3, 5, 7)
SHELL_PROXY_NORMS: tuple[int, ...] = (4, 6, 8)


def half_integer_coords_in_cube(radius: int) -> tuple[float, ...]:
    """Hurwitz half-integer coordinates with |v| <= radius."""
    return tuple(k + 0.5 for k in range(-radius, radius) if abs(k + 0.5) <= radius)


def exists_integer_hurwitz_norm_sq(target: int, *, radius: int = DEFAULT_CUBE_RADIUS) -> bool:
    """
    True iff some integer Hurwitz point in [-radius, radius]^8 has squared norm ``target``.

    Integer Hurwitz points require an even coordinate sum.
    """
    if target < 0:
        return False
    found = False

    def backtrack(dim: int, coord_sum: int, norm_sq: int) -> None:
        nonlocal found
        if found or norm_sq > target:
            return
        remaining = 8 - dim
        if norm_sq + remaining * radius * radius < target:
            return
        if dim == 8:
            if norm_sq == target and coord_sum % 2 == 0:
                found = True
            return
        for x in range(-radius, radius + 1):
            backtrack(dim + 1, coord_sum + x, norm_sq + x * x)

    backtrack(0, 0, 0)
    return found


def exists_half_integer_hurwitz_norm_sq(target: int, *, radius: int = DEFAULT_CUBE_RADIUS) -> bool:
    """
    True iff some half-integer Hurwitz point in the cube has squared norm ``target``.

    Coordinates are k + 1/2 with even sum of k (equivalently even shifted sum).
    """
    if target < 0:
        return False
    coords = half_integer_coords_in_cube(radius)
    found = False

    def backtrack(dim: int, k_sum: int, norm_sq: float) -> None:
        nonlocal found
        if found or norm_sq > target + 1e-9:
            return
        remaining = 8 - dim
        max_tail = remaining * max(v * v for v in coords)
        if norm_sq + max_tail < target - 1e-9:
            return
        if dim == 8:
            if abs(norm_sq - target) <= 1e-9 and k_sum % 2 == 0:
                found = True
            return
        for v in coords:
            k = int(round(v - 0.5))
            backtrack(dim + 1, k_sum + k, norm_sq + v * v)

    backtrack(0, 0, 0.0)
    return found


def exists_hurwitz_norm_sq_in_cube(target: int, *, radius: int = DEFAULT_CUBE_RADIUS) -> bool:
    return exists_integer_hurwitz_norm_sq(target, radius=radius) or exists_half_integer_hurwitz_norm_sq(
        target, radius=radius
    )


@lru_cache(maxsize=1)
def collect_integer_hurwitz_norm_sq_in_cube(
    *,
    radius: int = DEFAULT_CUBE_RADIUS,
    max_norm_sq: int = MAX_NORM_SQ_IN_CUBE,
) -> frozenset[int]:
    norms: set[int] = set()

    def backtrack(dim: int, coord_sum: int, norm_sq: int) -> None:
        if norm_sq > max_norm_sq:
            return
        if dim == 8:
            if coord_sum % 2 == 0:
                norms.add(norm_sq)
            return
        for x in range(-radius, radius + 1):
            backtrack(dim + 1, coord_sum + x, norm_sq + x * x)

    backtrack(0, 0, 0)
    return frozenset(norms)


@lru_cache(maxsize=1)
def collect_half_integer_hurwitz_norm_sq_in_cube(
    *,
    radius: int = DEFAULT_CUBE_RADIUS,
    max_norm_sq: int = MAX_NORM_SQ_IN_CUBE,
) -> frozenset[int]:
    coords = half_integer_coords_in_cube(radius)
    norms: set[int] = set()

    def backtrack(dim: int, k_sum: int, norm_sq: float) -> None:
        if norm_sq > max_norm_sq + 1e-9:
            return
        if dim == 8:
            if k_sum % 2 == 0:
                norms.add(int(round(norm_sq)))
            return
        for v in coords:
            k = int(round(v - 0.5))
            backtrack(dim + 1, k_sum + k, norm_sq + v * v)

    backtrack(0, 0, 0.0)
    return frozenset(norms)


def collect_hurwitz_norm_sq_in_cube(
    *,
    radius: int = DEFAULT_CUBE_RADIUS,
    max_norm_sq: int = MAX_NORM_SQ_IN_CUBE,
) -> frozenset[int]:
    return collect_integer_hurwitz_norm_sq_in_cube(radius=radius, max_norm_sq=max_norm_sq) | collect_half_integer_hurwitz_norm_sq_in_cube(
        radius=radius, max_norm_sq=max_norm_sq
    )


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n % 2 == 0:
        return n == 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def odd_prime_norms_in_hurwitz_cube(
    *,
    radius: int = DEFAULT_CUBE_RADIUS,
    max_norm_sq: int = MAX_NORM_SQ_IN_CUBE,
    is_prime=_is_prime,
) -> tuple[int, ...]:
    """
    Return odd rational primes realized as squared norms on the Hurwitz cube.

    Half-integer Hurwitz points only produce even squared norms (eight quarters contribute
    an integer tail of 2), so the odd-prime scan restricts to the integer branch.
    """
    norms = collect_integer_hurwitz_norm_sq_in_cube(radius=radius, max_norm_sq=max_norm_sq)
    return tuple(
        sorted(
            norm
            for norm in norms
            if norm > 2 and norm % 2 == 1 and is_prime(norm)
        )
    )
