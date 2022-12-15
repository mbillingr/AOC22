require "./utils/puzzle"
require "./utils/vec2"

DAY = "15"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.select_row(10).check(EXAMPLE, 26)
Part1.new.select_row(2000000).run(raw_data)

Part2.new.limit(20).check(EXAMPLE, 56000011)
Part2.new.limit(4000000).run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split)
      .map { |row| [row[2], row[3][...-1], row[8], row[9]] }
      .map(&.map(&.split('=')))
      .map(&.map { |num| num[1].strip(',').to_i })
      .map { |pairs| {Vec2.new(pairs[0], pairs[1]), Vec2.new(pairs[2], pairs[3])} }
  end

  def row_coverage(row, sensor_ranges)
    coverage = [] of Range(Int64, Int64)
    sensor_ranges
      .map { |pos, range| sensor_row_coverage(row, pos, range) }
      .each do |r|
        if r
          coverage.push(r)
        end
      end
    coverage
  end
end

class Part1 < Day
  @part = "Part 1"
  @row : Int64 = 0

  def select_row(y)
    @row = y
    self
  end

  def solve(data)
    sensor_ranges = data.map { |sensor, beacon| {sensor, (beacon - sensor).one_norm} }

    coverage = merge_ranges row_coverage(@row, sensor_ranges)

    beacon_x = data
      .select { |_, beacon| beacon.y == @row }
      .map { |_, beacon| beacon.x }
      .to_set

    coverage
      .map { |r| r.size - beacon_x.select { |x| r.covers? x }.size }
      .sum
  end
end

def sensor_row_coverage(row, pos, range)
  residual_range = range - (pos.y - row).abs
  if residual_range >= 0
    (pos.x - residual_range)..(pos.x + residual_range)
  end
end

class Part2 < Day
  @part = "Part 2"
  @limit : Int64 = 0

  def limit(limit)
    @limit = limit
    self
  end

  def solve(data)
    sensor_ranges = data.map { |sensor, beacon| {sensor, (beacon - sensor).one_norm} }

    sensor_ranges.each do |pos, r|
      trace_perimeter(pos, r) do |pos|
        if pos.x >= 0 && pos.x <= @limit && pos.y >= 0 && pos.y <= @limit
          if !in_range?(pos, sensor_ranges)
            return pos.x * 4000000 + pos.y
          end
        end
      end
    end

    # This is the brute-fore solution, that applies Part 1 to each row.
    #
    # (0..@limit).each do |row|
    #   coverage = merge_ranges row_coverage(row, sensor_ranges)
    #   if coverage.size == 2
    #     if coverage[1].begin > coverage[0].end
    #       x = coverage[1].begin - 1
    #     else
    #       x = coverage[0].begin - 1
    #     end
    #     return x * 4000000 + row
    #   end
    # end
  end

  def trace_perimeter(center, range)
    pos = center + Vec2.new(range + 1, 0)
    [Vec2.new(-1, 1), Vec2.new(-1, -1), Vec2.new(1, -1), Vec2.new(1, 1)].each do |d|
      (range + 1).times do
        pos += d
        yield pos
      end
      d
    end
  end
end

#  o
# o.o
# o.x.o
# o.o
#  o

def in_range?(pos, sensor_ranges)
  sensor_ranges.each do |p, range|
    dist = (p - pos).one_norm
    if dist <= range
      return true
    end
  end
  false
end

def merge_ranges(ranges : Array(Range(Int64, Int64))) : Array(Range(Int64, Int64))
  if ranges.size < 2
    return ranges
  end

  r0 = ranges[0]

  affected, notaffected = ranges.partition { |r| ranges_touch?(r, r0) }

  if affected.size <= 1
    return ranges
  end

  coords = affected.flat_map { |r| [r.begin, r.end] }
  new_range = coords.min..coords.max

  notaffected.push(new_range)
  merge_ranges(notaffected)
end

def ranges_touch?(r1 : Range(Int64, Int64), r2 : Range(Int64, Int64))
  r1 == r2 || r1.covers?(r2.begin - 1) || r1.covers?(r2.end + 1) || r2.covers?(r1.begin - 1) || r2.covers?(r1.end + 1)
end

EXAMPLE = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
Sensor at x=9, y=16: closest beacon is at x=10, y=16
Sensor at x=13, y=2: closest beacon is at x=15, y=3
Sensor at x=12, y=14: closest beacon is at x=10, y=16
Sensor at x=10, y=20: closest beacon is at x=10, y=16
Sensor at x=14, y=17: closest beacon is at x=10, y=16
Sensor at x=8, y=7: closest beacon is at x=2, y=10
Sensor at x=2, y=0: closest beacon is at x=2, y=10
Sensor at x=0, y=11: closest beacon is at x=2, y=10
Sensor at x=20, y=14: closest beacon is at x=25, y=17
Sensor at x=17, y=20: closest beacon is at x=21, y=22
Sensor at x=16, y=7: closest beacon is at x=15, y=3
Sensor at x=14, y=3: closest beacon is at x=15, y=3
Sensor at x=20, y=1: closest beacon is at x=15, y=3
"
