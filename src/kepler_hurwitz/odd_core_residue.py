"""Projected oddCoreStep on odd residues modulo a power of two.

Binds to the repository Syracuse / Lean ``oddCoreStep`` arithmetic
(``odd_core(3n+1)`` via ``next_odd_core_after_kick``), not a placeholder
Collatz map. Phase-A scans use ``T_m(r) = oddCoreStep(r) mod m`` on
canonical odd residues for ``m = 2^k``.
"""

from __future__ import annotations

from collections.abc import Callable

from kepler_hurwitz.octonionic_collatz_freeze_diagnostic import odd_core_step

__all__ = [
    "require_power_of_two",
    "odd_residues_mod",
    "odd_core_step_mod",
    "projected_odd_core_step",
]


def require_power_of_two(modulus: int) -> None:
    """Enforce Phase-A modulus convention ``m = 2^k`` with ``m >= 2``."""
    if modulus < 2 or modulus & (modulus - 1) != 0:
        raise ValueError(
            f"modulus must be a power of two >= 2, got {modulus!r}"
        )


def odd_residues_mod(modulus: int) -> tuple[int, ...]:
    """Canonical odd residues ``{1, 3, ..., m-1}`` for power-of-two ``m``."""
    require_power_of_two(modulus)
    return tuple(r for r in range(1, modulus, 2))


def odd_core_step_mod(residue: int, modulus: int) -> int:
    """``T_m(r) = oddCoreStep(r) mod m`` with production ``odd_core_step``.

    ``residue`` must be a positive odd integer representative; ``modulus``
    must be a power of two (Phase-A convention).
    """
    require_power_of_two(modulus)
    if residue <= 0 or residue % 2 == 0:
        raise ValueError(
            f"residue must be a positive odd integer, got {residue!r}"
        )
    return odd_core_step(residue) % modulus


def projected_odd_core_step(modulus: int) -> Callable[[int], int]:
    """Return ``r ↦ odd_core_step_mod(r, modulus)`` for graph construction."""
    require_power_of_two(modulus)

    def step(residue: int) -> int:
        return odd_core_step_mod(residue, modulus)

    return step
