from typing import Any

from utils.puzzle import Puzzle
from utils import parsing as p

NUMBER = p.Number()
EXPR = (
    p.String(p.Letter() * ...)
    + p.SkipWhitespace()
    + p.OneOf("+-*/")
    + p.SkipWhitespace()
    + p.String(p.Letter() * ...)
)

PARSER = p.SeparatedList(
    p.Group(
        p.String(p.Letter() * ...) + p.Drop(":") + p.SkipWhitespace() + (NUMBER | EXPR)
    ),
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
        del data["humn"]

        lhs = build_expression(data["root"][1], data)
        rhs = build_expression(data["root"][2], data)

        lhs = partial_eval(lhs)
        rhs = partial_eval(rhs)

        return solve_equal(lhs, rhs)


def solve_equal(lhs, rhs):
    match (lhs, rhs):
        case str(), int():
            return rhs

        case ("/", a, int(b)), int():
            return solve_equal(a, rhs * b)

        case ("+", int(a), b), int():
            return solve_equal(b, rhs - a)
        case ("+", a, int(b)), int():
            return solve_equal(a, rhs - b)

        case ("-", a, int(b)), int():
            return solve_equal(a, rhs + b)
        case ("-", int(a), b), int():
            return solve_equal(b, a - rhs)

        case ("*", int(a), b), int():
            return solve_equal(b, rhs // a)
        case ("*", a, int(b)), int():
            return solve_equal(a, rhs // b)

        case _:
            raise NotImplementedError(f"{lhs} = {rhs}")


def build_expression(x, data):
    match x:
        case str():
            if x not in data:
                return x
            else:
                return build_expression(data[x], data)
        case int():
            return x
        case (op, a, b):
            return (
                op,
                build_expression(a, data),
                build_expression(b, data),
            )


def partial_eval(exp):
    match exp:
        case (op, a, b):
            a = partial_eval(a)
            b = partial_eval(b)
            match (op, a, b):
                case ("+", int(), int()):
                    return a + b
                case ("-", int(), int()):
                    return a - b
                case ("*", int(), int()):
                    return a * b
                case ("/", int(), int()):
                    return a // b
                case other:
                    return other
        case _:
            return exp


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
