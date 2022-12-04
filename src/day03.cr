require "./utils/puzzle"

class Day < Puzzle
  @day = "Day 03"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map { |row| row.chars }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data
      .map { |chars|
        n = chars.size // 2
        left = chars[0, n].to_set
        right = chars[n, n].to_set
        [left, right]
      }
      .map { |bag|
        left = bag[0]
        right = bag[1]
        (left & right).to_a[0]
      }
      .map { |ch| priority(ch) }
      .sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data
      .map { |chars| chars.to_set }
      .in_groups_of(3)
      .map { |group|
        a = group[0]
        b = group[1]
        c = group[2]
        if a && b && c
          a & b & c
        else
          Set(Char).new
        end
      }
      .map { |item| item.to_a[0] }
      .map { |ch| priority(ch) }
      .sum
  end
end

def priority(ch)
  if ch >= 'a' && ch <= 'z'
    ch - 'a' + 1
  else
    ch - 'A' + 27
  end
end

raw_data = File.read(__DIR__ + "/../data/input03.txt")

Part1.new.check(EXAMPLE, 157)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 70)
Part2.new.run(raw_data)

EXAMPLE = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw
"
