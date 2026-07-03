from dataclasses import dataclass
from typing import Tuple


@dataclass(frozen=True)
class HurwitzSignature8D:
    e_plus: int
    e_minus: int
    a_plus: int
    a_minus: int
    b_plus: int
    b_minus: int
    c_plus: int
    c_minus: int

    def total_weight(self) -> int:
        return sum(self.as_tuple())

    def as_tuple(self) -> Tuple[int, ...]:
        return (
            self.e_plus,
            self.e_minus,
            self.a_plus,
            self.a_minus,
            self.b_plus,
            self.b_minus,
            self.c_plus,
            self.c_minus,
        )

    def orientation_balance(self) -> int:
        plus = self.e_plus + self.a_plus + self.b_plus + self.c_plus
        minus = self.e_minus + self.a_minus + self.b_minus + self.c_minus
        return plus - minus
