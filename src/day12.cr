require "./utils/puzzle"
require "./utils/vec2"
require "math"

DAY = "12"

INF = 2u32 ** 31

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 31)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 29)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"
  @start : Vec2 = Vec2.new(0, 0)
  @target : Vec2 = Vec2.new(0, 0)
  @grid : Array(Array(Char)) = [] of Array(Char)

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

    @grid = grid
  end

  def edge_weight(current, neighbor)
    if neighbor.x < 0 || neighbor.x >= @grid.size || neighbor.y < 0 || neighbor.y >= @grid[0].size
      return INF
    end
    if current.x < 0 || current.x >= @grid.size || current.y < 0 || current.y >= @grid[0].size
      return INF
    end
    @grid[neighbor.x][neighbor.y] - @grid[current.x][current.y]
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    path = a_star
    return path.size - 1
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

    g_score = Hash(Vec2, Int64).new(INF)
    g_score[@start] = 0

    f_score = Hash(Vec2, Float64).new(INF)
    f_score[@start] = heuristic(@start)

    while !open_set.empty?
      current = key_with_lowest_value(f_score)
      if current == @target
        return reconstruct_path(came_from, current)
      end

      open_set.delete(current)
      f_score.delete(current)
      current.neighbors
        .select { |n| edge_weight(current, n) <= 1 }
        .each do |neighbor|
          tentative_gscore = g_score[current] + 1
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
    @grid = data

    distances = dijkstra(@target)

    min_dist = INF
    (0...@grid.size).each do |i|
      row = @grid[i]
      (0...row.size).each do |j|
        d = distances[Vec2.new(i, j)]
        if @grid[i][j] == 'a'
          if d < min_dist
            min_dist = d
          end
          print "("
        else
          print " "
        end
        if d == INF
          print "-"
        else
          print @grid[i][j]
        end
        if @grid[i][j] == 'a'
          print ")"
        else
          print " "
        end
      end
      puts
    end

    min_dist
  end

  def dijkstra(start)
    inf = 2u32 ** 31
    visited = Set(Vec2).new
    unvisited = [start].to_set
    distances = Hash(Vec2, UInt32).new(inf)
    distances[start] = 0

    current = start
    while true
      d = distances[current] + 1
      current.neighbors
        .select { |n| edge_weight(n, current) <= 1 }
        .each do |neighbor|
          if d < distances[neighbor]
            distances[neighbor] = d
          end

          if !visited.includes? neighbor
            unvisited.add neighbor
          end
        end
      visited.add current
      unvisited.delete current

      d = inf
      unvisited.each do |node|
        if distances[node] < d
          current = node
          d = distances[node]
        end
      end

      if d >= inf
        return distances
      end
    end
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
