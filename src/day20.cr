require "./utils/puzzle"
require "deque"

DAY = "20"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 3)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 1623178306)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    numbers = input
      .split("\n")
      .select { |x| x != "" }
      .map(&.to_i64)

    placeholders = (1..numbers.size).to_a

    placeholder_to_number = Hash(Int64, Int64).new
    numbers.zip(placeholders) do |nr, pl|
      placeholder_to_number[pl] = nr
    end

    placeholder_to_number
  end

  def mix(work, back_mapping)
    back_mapping.keys.each do |x|
      rotate_to work, x
      work.shift
      work.rotate! back_mapping[x]
      work.unshift x
    end
  end

  def get_coordinates(work, back_mapping)
    z = 0
    back_mapping.each do |k, v|
      if v == 0
        z = k
        break
      end
    end

    rotate_to work, z

    work.rotate! 1000
    a = back_mapping[work.first]

    work.rotate! 1000
    b = back_mapping[work.first]

    work.rotate! 1000
    c = back_mapping[work.first]

    puts [a, b, c]
    a + b + c
  end

  def rotate_to(dq, val)
    while dq.first != val
      dq.rotate!
    end
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(back_mapping)
    work = Deque.new(back_mapping.keys)

    mix(work, back_mapping)
    get_coordinates(work, back_mapping)
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(back_mapping)
    back_mapping = back_mapping.transform_values { |v| v * 811589153 }

    work = Deque.new(back_mapping.keys)

    10.times do
      mix(work, back_mapping)
    end

    get_coordinates(work, back_mapping)
  end
end

EXAMPLE = "1
2
-3
3
-2
0
4
"
