require "./utils/puzzle"

class Day < Puzzle
  @day = "Day 01"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map { |row| row.split }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data
      .map { |round|
        p1, p2 = round
        p2 = {"X" => "A", "Y" => "B", "Z" => "C"}[p2]
        score p1, p2
      }
      .sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data
      .map { |round|
        p1, _ = round
        p2 = {
          ["A", "X"] => "C",
          ["B", "X"] => "A",
          ["C", "X"] => "B",
          ["A", "Y"] => "A",
          ["B", "Y"] => "B",
          ["C", "Y"] => "C",
          ["A", "Z"] => "B",
          ["B", "Z"] => "C",
          ["C", "Z"] => "A",
        }[round]
        score p1, p2
      }
      .sum
  end
end

def score(p1, p2)
  score = {"A" => 1, "B" => 2, "C" => 3}[p2]
  case {p1, p2}
  when {"A", "C"}, {"B", "A"}, {"C", "B"}
    score += 0
  when {"A", "A"}, {"B", "B"}, {"C", "C"}
    score += 3
  when {"A", "B"}, {"B", "C"}, {"C", "A"}
    score += 6
  end
  score
end

raw_data = File.read(__DIR__ + "/../data/input02.txt")

Part1.new.check(EXAMPLE, 15)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 12)
Part2.new.run(raw_data)

EXAMPLE = "A Y
B X
C Z
"
