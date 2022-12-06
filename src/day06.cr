require "./utils/puzzle"

DAY = "06"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check("bvwbjplbgvbhsrlpgdmjqwftvncz", 5)
Part1.new.check("nppdvjthqldpwncqszvftbrmjlhg", 6)
Part1.new.check("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 10)
Part1.new.check("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 11)
Part1.new.run(raw_data)

Part2.new.check("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 19)
Part2.new.check("bvwbjplbgvbhsrlpgdmjqwftvncz", 23)
Part2.new.check("nppdvjthqldpwncqszvftbrmjlhg", 23)
Part2.new.check("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 29)
Part2.new.check("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 26)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input.split("\n").first
  end

  def solve(data)
    count = @n
    data.chars.each_cons(@n) do |seq|
      if seq.to_set.size == @n
        return count
      end
      count += 1
    end
  end
end

class Part1 < Day
  @part = "Part 1"
  @n = 4
end

class Part2 < Day
  @part = "Part 2"
  @n = 14
end
