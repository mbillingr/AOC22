import utils
from utils.puzzle import Puzzle

print("Hello, Advent!")


class MyPuzzle(Puzzle):
    def __init__(self):
        super().__init__("Infrastructure Test")

    def parse(self, input: str):
        return map(int, input.split())

    def solve(self, input):
        return sum(input)


pz = MyPuzzle()
pz.check("1 2 3", 6)
pz.run("data/testin.txt")
