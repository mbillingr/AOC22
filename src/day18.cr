require "./utils/puzzle"

DAY = "18"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 64)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 58)
Part2.new.run(raw_data)


class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split(',').map(&.to_i))
      .to_set
  end

  def neighbors(cube)
    x, y, z = cube
    [[x+1, y, z], [x-1, y, z], [x, y+1, z], [x, y-1, z], [x, y, z+1], [x, y, z-1]]
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    surface_area = 0
    data.each do |cube|
      neighbors(cube).each do |neighbor|
        if !data.includes? neighbor
          surface_area += 1
        end
      end
    end
    surface_area
  end
end

class Part2 < Day
  @part = "Part 2"
  @xmin = 0
  @xmax = 0
  @ymin = 0
  @ymax = 0
  @zmin = 0
  @zmax = 0

  def solve(data)
    @xmin = data.map { |cube| cube[0] }.min - 1
    @xmax = data.map { |cube| cube[0] }.max + 1
    @ymin = data.map { |cube| cube[1] }.min - 1
    @ymax = data.map { |cube| cube[1] }.max + 1
    @zmin = data.map { |cube| cube[2] }.min - 1
    @zmax = data.map { |cube| cube[2] }.max + 1

    outside = Set(Array(Int32)).new

    fill([@xmin, @ymin, @zmin], outside, data)
  end

  def fill(p, outside, data)
    if p[0] < @xmin || p[0] > @xmax || p[1] < @ymin || p[1] > @ymax || p[2] < @zmin || p[2] > @zmax
      return 0
    end
    if outside.includes? p
      return 0
    end

    if data.includes? p
      return 1
    end

    outside.add p

    neighbors(p)
      .map { |n| fill(n, outside, data) }
      .sum
  end
end

EXAMPLE = "2,2,2
1,2,2
3,2,2
2,1,2
2,3,2
2,2,1
2,2,3
2,2,4
2,2,6
1,2,5
3,2,5
2,1,5
2,3,5
"
