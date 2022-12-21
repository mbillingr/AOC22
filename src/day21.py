from typing import Any

from utils.puzzle import Puzzle
from utils import parsing as p

NUMBER = p.Number()
EXPR = p.String(p.Letter() * ...) + p.SkipWhitespace() + p.OneOf("+-*/") + p.SkipWhitespace() + p.String(p.Letter() * ...)

PARSER = p.SeparatedList(
    p.Group(p.String(p.Letter() * ...) + p.Drop(":") + p.SkipWhitespace() + (NUMBER | EXPR)),
    p.Str("\n"),
)


class Day00(Puzzle):
    def __init__(self, part: Any):
        super().__init__(f"Day 05/{part}")

    def parse(self, input: str):
        return {row[0]: self.row_to_expr(row) for row in PARSER.parse(input)}

    def row_to_expr(self, row):
        if len(row) == 2:
            return row[1]
        else:
            return (row[2], row[1], row[3])


class Part2(Day00):
    def __init__(self):
        super().__init__("2")

    def solve(self, data):
        print(data)


EXAMPLE = """root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
"""



Part2().check(EXAMPLE, 301)
Part2().run("../data/input21.txt")  # or filename instead of DirectInput
