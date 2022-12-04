require "./utils/puzzle"

DAY = "04"

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map do |row|
        row.split(",")
          .map { |rng| rng.split("-").map(&.to_i) }
          .map { |pair| Interval.new(pair[0], pair[1]) }
      end
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data
      .select do |pair|
        pair[0].fully_overlaps?(pair[1]) || pair[1].fully_overlaps?(pair[0])
      end
      .size
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data
      .select do |pair|
        pair[0].overlaps?(pair[1]) || pair[1].overlaps?(pair[0])
      end
      .size
  end
end

class Interval
  def initialize(@first : Int32, @last : Int32)
  end

  def fully_overlaps?(other : Interval)
    @first >= other.@first && @last <= other.@last
  end

  def overlaps?(other : Interval)
    @first <= other.@first && @last >= other.@first || @first <= other.@last && @last >= other.@last
  end
end

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 2)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 4)
Part2.new.run(raw_data)

EXAMPLE = "2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8
"
