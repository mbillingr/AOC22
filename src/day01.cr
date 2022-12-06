require "./utils/puzzle"

raw_data = File.read(__DIR__ + "/../data/input01.txt")

class Day < Puzzle
  @day = "Day 01"

  def parse(input)
    input
      .split("\n\n")
      .map { |blk| blk
        .split("\n")
        .select { |x| x != "" }
        .map { |x| x.to_i } }
      .map { |blk| blk.sum }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data
      .max
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data
      .sort[-3..]
      .sum
  end
end

Part1.new.check(EXAMPLE, 24000)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 45000)
Part2.new.run(raw_data)

EXAMPLE = "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"
