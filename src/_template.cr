require "./utils/puzzle"

DAY = "XX"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, "expected")
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, "expected")
Part2.new.run(raw_data)


class Day < Puzzle
  @day = "Day #{DAY}"

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

EXAMPLE = "ABC
XYZ
"
