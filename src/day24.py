import collections
import functools
from typing import Any

from utils.puzzle import Puzzle, DirectInput
from utils import parsing as p


class Day00(Puzzle):
    def __init__(self, part: Any):
        super().__init__(f"Day 05/{part}")

    def parse(self, input: str):
        blizzards = {}
        for i, row in enumerate(input.splitlines()):
            for j, ch in enumerate(row):
                if ch in ["<", ">", "v", "^"]:
                    blizzards[(i, j)] = ch

        x = [k[1] for k in blizzards]
        y = [k[0] for k in blizzards]
        walls = [min(y) - 1, min(x) - 1, max(y) + 1, max(x) + 1]

        return blizzards, walls

    def bfs(self, start_time, start, goal, bzs, walls):

        queue = collections.deque([(start_time, start)])
        visited = set()
        while queue:
            time, (y, x) = queue.popleft()
            if (time, (y, x)) in visited:
                continue
            visited.add((time, (y, x)))

            # print(time, y, x)
            if (y, x) == goal:
                return time

            # show(time, (y, x), bzs.at_time(time), walls)

            time += 1
            blz = bzs.at_time(time)
            for (yn, xn) in [(y + 1, x), (y - 1, x), (y, x + 1), (y, x - 1), (y, x)]:
                if (
                    (walls[0] < yn < walls[2] and walls[1] < xn < walls[3])
                    or (yn, xn) == start
                    or (yn, xn) == goal
                ):
                    if (yn, xn) not in blz:
                        queue.append((time, (yn, xn)))


class Part1(Day00):
    def __init__(self):
        super().__init__("1")

    def solve(self, parsed):
        blizzards, walls = parsed
        start = (0, 1)
        goal = (walls[-2], walls[-1] - 1)
        bzs = BlizzSim(blizzards)
        return self.bfs(0, start, goal, bzs, walls)


def show(time, pos, blz, walls):
    for i in range(walls[0], walls[2] + 1):
        chs = []
        for j in range(walls[1], walls[3] + 1):
            if (i, j) == pos:
                chs.append("O")
            else:
                chs.append(blz.get((i, j), "."))
        print("".join(chs))


class Part2(Day00):
    def __init__(self):
        super().__init__("2")

    def solve(self, parsed):
        blizzards, walls = parsed
        start = (0, 1)
        goal = (walls[-2], walls[-1] - 1)
        bzs = BlizzSim(blizzards)

        t1 = self.bfs(0, start, goal, bzs, walls)
        t2 = self.bfs(t1, goal, start, bzs, walls)
        return self.bfs(t2, start, goal, bzs, walls)


class BlizzSim:
    def __init__(self, blizzards):
        x = [k[1] for k in blizzards]
        y = [k[0] for k in blizzards]
        self.minx = min(x)
        self.maxx = max(x)
        self.miny = min(y)
        self.maxy = max(y)
        self.initial_blizzards = list(blizzards.items())

    @functools.cache
    def at_time(self, t):
        t = t % ((self.maxx - self.minx + 1) * (self.maxy - self.miny + 1))
        blz = {}
        for pos, ch in self._at_time(t):
            if pos in blz:
                blz[pos] = "X"
            else:
                blz[pos] = ch
        return blz

    @functools.cache
    def _at_time(self, t):
        if t == 0:
            return self.initial_blizzards
        assert t > 0
        blz = self._at_time(t - 1)
        return list(map(self.simstep, blz))

    def simstep(self, blz):
        ((y, x), d) = blz
        match d:
            case ">":
                x += 1
            case "<":
                x -= 1
            case "v":
                y += 1
            case "^":
                y -= 1

        if x < self.minx:
            x = self.maxx
        elif x > self.maxx:
            x = self.minx

        if y < self.miny:
            y = self.maxy
        elif y > self.maxy:
            y = self.miny

        return ((y, x), d)


EXAMPLE = """#.######
#>>.<^<#
#.<..<<#
#>v.><>#
#<^v^^>#
######.#
"""


Part1().check(EXAMPLE, 18)
Part1().run("../data/input24.txt")  # or filename instead of DirectInput

Part2().check(EXAMPLE, 54)
Part2().run("../data/input24.txt")  # or filename instead of DirectInput
