from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class WordOrbit:
    word: str
    orbit: tuple[str, ...]
    canonical: str


def rotations(word: str) -> tuple[str, ...]:
    if not word:
        return ("",)
    n = len(word)
    return tuple(word[i:] + word[:i] for i in range(n))


def orbit_under_cyclic_shift(word: str) -> tuple[str, ...]:
    return tuple(sorted(set(rotations(word))))


def canonical_representative(word: str) -> str:
    return min(orbit_under_cyclic_shift(word))


def analyze_word_orbit(word: str) -> WordOrbit:
    orbit = orbit_under_cyclic_shift(word)
    return WordOrbit(word=word, orbit=orbit, canonical=min(orbit))


def reduce_words_by_orbit(words: list[str]) -> dict[str, list[str]]:
    classes: dict[str, list[str]] = {}
    for word in words:
        representative = canonical_representative(word)
        classes.setdefault(representative, []).append(word)
    return classes
