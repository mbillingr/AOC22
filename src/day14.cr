require "./utils/puzzle"
require "./utils/vec2"

DAY = "14"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 24)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 93)
Part2.new.run(raw_data)

ROCK = '#'
SAND = 'o'
AIR  = '.'

SAND_EMITTER = Vec2.new 500, 0

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split(" -> "))
      .map(&.map(&.split(",").map(&.to_i)))
  end

  def build_grid(paths)
    grid = Hash(Vec2, Char).new
    paths.each do |path|
      path.each_cons(2) do |part|
        x, y = part[0]
        x1, y1 = part[1]
        dx = (x1 - x).sign
        dy = (y1 - y).sign
        while true
          grid[Vec2.new x, y] = ROCK
          if x == x1 && y == y1
            break
          end
          x += dx
          y += dy
        end
      end
    end
    grid
  end

  def step_sand(pos, grid)
    newpos = pos + (Vec2.new "U")
    if !grid.has_key? newpos
      return newpos
    end

    newpos_l = newpos + (Vec2.new "L")
    if !grid.has_key? newpos_l
      return newpos_l
    end

    newpos_r = newpos + (Vec2.new "R")
    if !grid.has_key? newpos_r
      return newpos_r
    end

    return nil
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    grid = build_grid data
    max_y = grid.keys.map(&.y).max

    (0..).each do |i|
      if :void == move_sand SAND_EMITTER, max_y, grid
        return i
      end
    end
  end

  def move_sand(start, max_y, grid)
    newpos = start
    pos = start
    while newpos
      pos = newpos
      if pos.y > max_y
        return :void
      end
      newpos = step_sand(pos, grid)
    end
    grid[pos] = SAND

    if pos == start
      :block
    else
      :stop
    end
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    grid = build_grid data
    max_y = grid.keys.map(&.y).max

    (1..).each do |i|
      res = move_sand SAND_EMITTER, max_y + 2, grid
      if :block == res
        return i
      end
    end
  end

  def move_sand(start, max_y, grid)
    newpos = start
    pos = start
    while newpos && newpos.y < max_y
      pos = newpos
      newpos = step_sand(pos, grid)
    end
    grid[pos] = SAND

    if pos == start
      :block
    else
      :stop
    end
  end
end

EXAMPLE = "498,4 -> 498,6 -> 496,6
503,4 -> 502,4 -> 502,9 -> 494,9
"
