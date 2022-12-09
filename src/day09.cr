require "./utils/puzzle"
require "./utils/vec2"

DAY = "09"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 13)
Part1.new.run(raw_data)

#Part2.new.check(EXAMPLE, 1)
Part2.new.check(EXAMPLE2, 36)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split)
      .map { |row| {row[0], row[1].to_i} }
  end

  def move_rope_segment(head, tail)
    if (head - tail).inf_norm > 1
      tail + (head - tail).box_normalize
    else
      tail
    end
  end

end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    head = tail = Vec2.new(0i64, 0i64)
    visited = [tail].to_set

    data.each do |row|
      dir, n = row
      d = Vec2.new(dir)

      n.times do
        head += d
        tail = move_rope_segment(head, tail)
        visited.add tail
      end
    end

    visited.size
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    rope = [Vec2.new(0, 0)] * 10
    visited = [rope.last].to_set

    data.each do |row|
      dir, n = row
      d = Vec2.new(dir)

      n.times do
        rope[0] += d
        (1...rope.size).each do |i|
          rope[i] = move_rope_segment(rope[i-1], rope[i])
        end
        visited.add rope.last
      end
    end

    visited.size
  end
end


EXAMPLE = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2
"

EXAMPLE2 = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20
"