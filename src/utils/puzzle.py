import abc
from datetime import datetime


class Puzzle(abc.ABC):
    def __init__(self, name):
        self.name = name

    @abc.abstractmethod
    def solve(self, inputlines):
        """compute puzzle solution"""

    def check(self, input, expected):
        start = datetime.now()
        result = self.solve(iter(input.splitlines()))
        if result == expected:
            print(f"{datetime.now() - start} -- OK  {result}")
        else:
            raise AssertionError(f"expected {expected}, got {result}")

    def run(self, filename=None, wrong=()):
        start = datetime.now()
        if filename is not None:
            with open(filename, "rt") as f:
                lines = (l.strip("\n") for l in f)
                result = self.solve(lines)
        else:
            lines = iter("")
            result = self.solve(lines)

        if result in wrong:
            raise AssertionError(f"wrong result: {result}")

        print(f"{datetime.now() - start} -- {self.name}: {result}")
