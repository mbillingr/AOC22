require "./utils/puzzle"
require "./utils/vec2"

DAY = "15"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.select_row(10).check(EXAMPLE, 26)
Part1.new.select_row(2000000).run(raw_data)

Part2.new.check(EXAMPLE, "expected")
Part2.new.run(raw_data)

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
    # .map(&.map {|p| xy_to_sensorspace(p) })
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
    # dx = xy_to_sensorspace Vec2.new(1, 0)
    sensor_ranges = data.map { |sensor, beacon| {sensor, (beacon - sensor).one_norm} }

    coverage = [] of Range(Int64, Int64)
    sensor_ranges
      .map { |pos, range| sensor_row_coverage(@row, pos, range) }
      .each do |r|
        if r
          coverage.push(r)
        end
      end

    beacon_x = data
      .select { |_, beacon| beacon.y == @row }
      .map { |_, beacon| beacon.x }
      .to_set

    (merge_ranges coverage)
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

  def solve(data)
    puts data
  end
end

def xy_to_sensorspace(p)
  Vec2.new p.x, p.y - p.x
end

def sensorspace_to_xp(q)
  Vec2.new q.x, q.y + q.x
end

def merge_ranges(ranges : Array(Range(Int64, Int64))) : Array(Range(Int64, Int64))
  if ranges.size < 2
    return ranges
  end

  r0 = ranges[0]

  affected, ranges = ranges.partition { |r| ranges_touch?(r, r0) }

  coords = affected.flat_map { |r| [r.begin, r.end] }
  new_range = coords.min..coords.max

  ranges.push(new_range)
  merge_ranges(ranges)
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
