require "./utils/puzzle"

DAY = "08"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 21)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 8)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"
  @height = 0
  @width = 0

  def parse(input)
    grid = input
      .split("\n")
      .select { |x| x != "" }
      .map { |row| row.chars.map(&.to_i) }
    @height = grid.size
    @width = grid[0].size
    grid
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(grid)
    visible = Set(Tuple(Int32, Int32)).new

    grid = grid.map { |row| row.map { |x| x + 1 } }

    (0...@height).each do |y|
      visible |= watch_along_ray grid, 0, y, 1, 0
      visible |= watch_along_ray grid, @width - 1, y, -1, 0
    end

    (0...@width).each do |x|
      visible |= watch_along_ray grid, x, 0, 0, 1
      visible |= watch_along_ray grid, x, @height - 1, 0, -1
    end

    visible.size
  end

  def watch_along_ray(grid, x, y, dx, dy)
    visible = Set(Tuple(Int32, Int32)).new
    max_height = 0
    while x >= 0 && y >= 0 && x < @width && y < @height
      if grid[y][x] > max_height
        visible.add({x, y})
        max_height = grid[y][x]
      end
      x += dx
      y += dy
    end
    visible
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(grid)
    highest_score = 0
    (0...@height).each do |y|
      (0...@width).each do |x|
        score = view_distance(grid, x, y, 1, 0) *
                view_distance(grid, x, y, -1, 0) *
                view_distance(grid, x, y, 0, 1) *
                view_distance(grid, x, y, 0, -1)
        if score > highest_score
          highest_score = score
        end
      end
    end
    highest_score
  end

  def view_distance(grid, x, y, dx, dy)
    starting_height = grid[y][x]
    distance = 1
    x += dx
    y += dy

    while x >= 0 && y >= 0 && x < @width && y < @height
      if grid[y][x] >= starting_height
        return distance
      end
      x += dx
      y += dy
      distance += 1
    end

    distance - 1
  end
end

EXAMPLE = "30373
25512
65332
33549
35390
"
