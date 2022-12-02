from typing import Any

from utils.puzzle import Puzzle, DirectInput
from utils import parsing as p


PARSER = p.SeparatedList(
    p.Group(p.AnyChar() + p.SkipWhitespace() + p.AnyChar()),
    p.Str("\n"),
)


class Day02(Puzzle):
    def __init__(self, part: Any):
        super().__init__(f"Day 02/{part}")

    def parse(self, input: str):
        return PARSER.parse(input)


class Part1(Day02):
    def __init__(self):
        super().__init__("1")

    def solve(self, parsed):
        score = 0
        for a, b in parsed:
            score += {"X": 1, "Y": 2, "Z": 3}[b]
            match (a, b):
                case ("A", "Z") | ("B", "X") | ("C", "Y"): score += 0
                case ("A", "X") | ("B", "Y") | ("C", "Z"): score += 3
                case ("A", "Y") | ("B", "Z") | ("C", "X"): score += 6
        return score


class Part2(Day02):
    def __init__(self):
        super().__init__("2")

    def solve(self, parsed):
        score = 0
        for a, b in parsed:
            match b:
                case "X": score += 0 + {"A": 3, "B": 1, "C": 2}[a]
                case "Y": score += 3 + {"A": 1, "B": 2, "C": 3}[a]
                case "Z": score += 6 + {"A": 2, "B": 3, "C": 1}[a]
        return score


EXAMPLE = """A Y
B X
C Z
"""

Part1().check(EXAMPLE, 15)
Part1().run("../data/input02.txt")  # or filename instead of DirectInput

Part2().check(EXAMPLE, 12)
Part2().run("../data/input02.txt")  # or filename instead of DirectInput
