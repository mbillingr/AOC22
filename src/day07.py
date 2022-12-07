from collections import defaultdict
from pathlib import Path
from typing import Any

from utils.puzzle import Puzzle
from utils import parsing as p

NAME = p.String(p.NotOneOf("\n \t") * ...)
CD_CMD = p.Group(p.Drop("$") + p.SkipWhitespace() + "cd" + p.SkipWhitespace() + NAME)
LS_OUT_DIR = p.Group(p.Str("dir") + p.SkipWhitespace() + NAME)
LS_OUT_FILE = p.Group(p.Number() + p.SkipWhitespace() + NAME)
LS_OUT = LS_OUT_DIR | LS_OUT_FILE
LS_CMD = p.Group(
    p.Drop("$") + p.SkipWhitespace() + "ls" + (p.Drop("\n") + LS_OUT) * ...
)
PARSER = p.SeparatedList(
    CD_CMD | LS_CMD,
    p.Str("\n"),
)


class Day07(Puzzle):
    def __init__(self, part: Any):
        super().__init__(f"Day 07/{part}")

    def parse(self, input: str):
        return PARSER.parse(input)


class Part1(Day07):
    def __init__(self):
        super().__init__("1")

    def solve(self, parsed):
        usages = cumulate_dir_usage(parse_dir_usage(parsed))
        return sum(size for size in usages.values() if size <= 100000)


class Part2(Day07):
    def __init__(self):
        super().__init__("2")

    def solve(self, parsed):
        usages = cumulate_dir_usage(parse_dir_usage(parsed))

        total_space = 70000000
        used_space = max(usages.values())
        free_space = total_space - used_space
        needed_space = 30000000
        must_free = needed_space - free_space

        return min(size for size in usages.values() if size >= must_free)


def _cumulate_dir_usage(dir_sizes):
    # This brute-force algorithm is quadratic in the number of paths
    # but still fast enough for this puzzle
    cum_sizes = dir_sizes.copy()
    for path1, size1 in dir_sizes.items():
        for path2, size2 in dir_sizes.items():
            if path1 == path2:
                continue
            if path1.is_relative_to(path2):
                cum_sizes[path2] += size1
    return cum_sizes


def cumulate_dir_usage(dir_sizes):
    # This version is more elegant and much faster
    cum_sizes = defaultdict(lambda: 0) | dir_sizes
    for path, size in dir_sizes.items():
        while path.parent != path:
            path = path.parent
            cum_sizes[path] += size
    return cum_sizes


def parse_dir_usage(input):
    current_path = None
    dir_sizes = {}

    for cmd in input:
        match cmd:
            case ("cd", "/"):
                current_path = Path("/")
            case ("cd", ".."):
                current_path = current_path.parent
            case ("cd", subdir):
                current_path = current_path / subdir
            case ("ls", *output):
                dir_sizes[current_path] = sum(file_sizes(output))
    return dir_sizes


def file_sizes(ls_output):
    def is_file(row):
        match row:
            case (int(), str()):
                return True
            case _:
                return False

    def get_size(file):
        return file[0]

    return map(get_size, filter(is_file, ls_output))


EXAMPLE = """$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"""

Part1().check(EXAMPLE, 95437)
Part1().run("../data/input07.txt")

Part2().check(EXAMPLE, 24933642)
Part2().run("../data/input07.txt")
