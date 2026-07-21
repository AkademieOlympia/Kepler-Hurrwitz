"""Quick arithmetic checks for affine cylinder block-descent examples."""

from __future__ import annotations


def odd_core_syracuse(n: int) -> int:
    m = 3 * n + 1
    while m % 2 == 0:
        m //= 2
    return m


def nu2(m: int) -> int:
    assert m > 0
    v = 0
    while m % 2 == 0:
        m //= 2
        v += 1
    return v


def realizes(n: int, word: tuple[int, ...]) -> bool:
    if n % 2 == 0:
        return False
    x = n
    for a in word:
        if nu2(3 * x + 1) != a:
            return False
        x = odd_core_syracuse(x)
    return True


def cumulative(word: tuple[int, ...]) -> list[int]:
    out = [0]
    s = 0
    for a in word:
        s += a
        out.append(s)
    return out


def block_constant(word: tuple[int, ...]) -> int:
    A = cumulative(word)
    k = len(word)
    return sum(3 ** (k - 1 - j) * 2 ** A[j] for j in range(k))


def affine_identity(n: int, word: tuple[int, ...]) -> bool:
    A = cumulative(word)
    k = len(word)
    Ak = A[k]
    Bk = block_constant(word)
    x = n
    for _ in word:
        x = odd_core_syracuse(x)
    return 2**Ak * x == 3**k * n + Bk


def test_word_1_2_constants_and_growth() -> None:
    word = (1, 2)
    assert cumulative(word)[-1] == 3
    assert block_constant(word) == 5
    assert 2**3 < 3**2
    assert realizes(11, word)
    assert affine_identity(11, word)
    x = odd_core_syracuse(odd_core_syracuse(11))
    assert x == 13
    assert x > 11


def test_word_2_2_constants_and_descent() -> None:
    word = (2, 2)
    assert cumulative(word)[-1] == 4
    assert block_constant(word) == 7
    assert 3**2 < 2**4
    assert realizes(33, word)
    assert affine_identity(33, word)
    x = odd_core_syracuse(odd_core_syracuse(33))
    assert x == 19
    assert x < 33
    # Margin test: B < (2^A - 3^k) * n ⇔ 7 < 7*33
    assert block_constant(word) < (2**4 - 3**2) * 33


def test_two_pow_ne_three_pow_small() -> None:
    for k in range(1, 12):
        for A in range(0, 20):
            assert 2**A != 3**k
