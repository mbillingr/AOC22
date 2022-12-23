require "./utils/puzzle"
require "./utils/vec2"

DAY = "23"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE1, 25)
Part1.new.check(EXAMPLE, 110)
Part1.new.run(raw_data) # wrong:  A < 4031

Part2.new.check(EXAMPLE, 20)
Part2.new.run(raw_data)

alias T = Int32

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    rows = input
      .split("\n")
      .select { |x| x != "" }
      .map(&.chars)

    (0...rows.size)
      .map { |i| (0...rows[i].size).map { |j| {i, j} } }
      .flatten
      .select { |i, j| rows[i][j] == '#' }
      .map { |i, j| Vec2.new(j, i) }
      .to_set
  end

  def round(elves, directions)
    maybe_move = elves.select { |e| e.eight_neighbors.any? { |n| elves.includes? n } }

    proposed_moves = {} of Vec2(T) => Vec2(T)
    proposed_counts = Hash(Vec2(T), Int32).new(0)
    maybe_move.each do |e|
      directions.each do |d|
        a = e + d
        b = a + d.rotate_left
        c = a + d.rotate_right

        if !elves.includes?(a) && !elves.includes?(b) && !elves.includes?(c)
          proposed_moves[e] = a
          proposed_counts[a] += 1
          break
        end
      end
    end

    elves_out = elves.map { |e|
      tgt = proposed_moves[e]?
      if !tgt
        e
      elsif proposed_counts[tgt] == 1
        tgt
      else
        e
      end
    }.to_set

    directions.push(directions.shift)

    {elves_out, directions}
  end

  def print(data)
    a = data.map { |e| e.x }.min
    b = data.map { |e| e.x }.max
    c = data.map { |e| e.y }.min
    d = data.map { |e| e.y }.max

    (c..d).each do |y|
      puts (a..b).map do |x|
        if data.includes? Vec2.new(x, y)
          '#'
        else
          '.'
        end
      end.join
    end
    puts
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    dirs = [Vec2.new(0, -1), Vec2.new(0, 1), Vec2.new(-1, 0), Vec2.new(1, 0)]
    10.times do
      data, dirs = round(data, dirs)
    end

    a = data.map { |e| e.x }.min
    b = data.map { |e| e.x }.max
    c = data.map { |e| e.y }.min
    d = data.map { |e| e.y }.max
    (b - a + 1) * (d - c + 1) - data.size
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    dirs = [Vec2.new(0, -1), Vec2.new(0, 1), Vec2.new(-1, 0), Vec2.new(1, 0)]
    (1..).each do |nr|
      old_data = data
      data, dirs = round(data, dirs)
      if data == old_data
        return nr
      end
    end
  end
end

EXAMPLE = "....#..
..###.#
#...#.#
.#...##
#.###..
##.#.##
.#..#..
"

EXAMPLE1 = ".....
..##.
..#..
.....
..##.
.....
"
