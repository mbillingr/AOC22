from typing import Any

from utils.puzzle import Puzzle
from utils import parsing as p


PARSER = p.SeparatedList(
    p.Group(p.SeparatedList(p.Number(), "\n")),
    "\n\n",
)


class Day01(Puzzle):
    def __init__(self, part: Any):
        super().__init__(f"Day 01/{part}")

    def parse(self, input: str):
        return PARSER.parse(input)


class Part1(Day01):
    def __init__(self):
        super().__init__("1")

    def solve(self, parsed):
        return max(map(sum, parsed))


class Part2(Day01):
    def __init__(self):
        super().__init__("2")

    def solve(self, parsed):
        totals = sorted(map(sum, parsed))
        return sum(totals[-3:])


EXAMPLE1 = """1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"""


Part1().check(EXAMPLE1, 24000)
Part1().run("../data/input01.txt", wrong=(186,))  # or filename instead of DirectInput

Part2().check(EXAMPLE1, 45000)
Part2().run("../data/input01.txt")  # or filename instead of DirectInput
