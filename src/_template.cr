require "./utils/puzzle"

raw_data = File.read("../data/input01.txt")

class Day < Puzzle
  @day = "Day 01"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    puts data
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    puts data
  end
end

Part1.new.check(EXAMPLE, "expected")
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, "expected")
Part2.new.run(raw_data)

EXAMPLE = "ABC
XYZ
"
