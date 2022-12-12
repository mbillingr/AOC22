require "./utils/puzzle"
require "./utils/vec2"
require "math"

DAY = "12"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 31)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, "expected")
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"
  @start : Vec2 = Vec2.new(0, 0)
  @target : Vec2 = Vec2.new(0, 0)

  def parse(input)
    grid = input
      .split("\n")
      .select { |x| x != "" }
      .map(&.chars)

    (0...grid.size).each do |i|
      row = grid[i]
      (0...row.size).each do |j|
        if row[j] == 'S'
          @start = Vec2.new(i, j)
          row[j] = 'a'
        elsif row[j] == 'E'
          @target = Vec2.new(i, j)
          row[j] = 'z'
        end
      end
    end

    # grid.map { |row| row.map { |x| x - 'a' } }
    grid
  end
end

class Part1 < Day
  @part = "Part 1"
  @grid : Array(Array(Char)) = [] of Array(Char)

  def solve(data)
    @grid = data

    # TODO
    #  breath_first may work?
    #  what's wrong with A*?

    path = breath_first(@start)
    return path.size - 1
    # path = a_star
    (0...@grid.size).each do |i|
      row = @grid[i]
      (0...row.size).each do |j|
        print row[j]
        print " "
      end
      puts
      puts
    end
  end

  def breath_first(start)
    queue = [start]
    came_from = Hash(Vec2, Vec2).new
    visited = [start].to_set
    while !queue.empty?
      current = queue.shift
      if current == @target
        return reconstruct_path(came_from, current)
      end
      current.neighbors
        .select { |n| edge_weight(current, n) <= 1 }
        .select { |n| !visited.includes?(n) }
        .each do |neighbor|
          came_from[neighbor] = current
          visited.add neighbor
          queue.push(neighbor)
        end
    end
    raise "No path found"
  end

  def a_star
    open_set = [@start].to_set
    came_from = {} of Vec2 => Vec2

    g_score = Hash(Vec2, Int64).new(999999999999)
    g_score[@start] = 0

    f_score = Hash(Vec2, Float64).new(999999999999)
    f_score[@start] = heuristic(@start)

    while !open_set.empty?
      current = key_with_lowest_value(f_score)
      if current == @target
        return reconstruct_path(came_from, current)
      end

      # puts "LOOP", open_set, current, f_score, g_score

      open_set.delete(current)
      f_score.delete(current)
      current.neighbors.each do |neighbor|
        w = edge_weight(current, neighbor)
        if w > 1
          next
        end
        tentative_gscore = g_score[current] + w
        if tentative_gscore < g_score[neighbor]
          came_from[neighbor] = current
          g_score[neighbor] = tentative_gscore
          f_score[neighbor] = tentative_gscore + heuristic(neighbor)
          open_set.add neighbor
        end
      end
    end
    raise "No path found"
  end

  def edge_weight(current, neighbor)
    if neighbor.x < 0 || neighbor.x >= @grid.size || neighbor.y < 0 || neighbor.y >= @grid[0].size
      return 999
    end
    @grid[neighbor.x][neighbor.y] - @grid[current.x][current.y]
  end

  def heuristic(pos)
    Math.sqrt((@target - pos).squared_norm.to_f64)
  end

  def reconstruct_path(came_from, current)
    total_path = [] of Vec2
    while current
      total_path.push(current)
      current = came_from[current]?
    end
    total_path.reverse
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    puts data
  end
end

def key_with_lowest_value(h)
  key = nil
  lowest = nil
  h.each do |k, v|
    if lowest
      if v < lowest
        lowest = v
        key = k
      end
    else
      lowest = v
      key = k
    end
  end
  if key
    key
  else
    raise "No key found"
  end
end

EXAMPLE = "Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"
