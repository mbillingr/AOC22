require "./utils/puzzle"
require "./utils/vec2"

DAY = "22"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 6032)
Part1.new.run(raw_data) # wrong: 10372

Part2.new.check(EXAMPLE, 5031)
Part2.new.run(raw_data) # wrong: 87243 < A

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    rows = input
      .split("\n")
      .select { |x| x != "" }

    field = rows
      .take_while { |row| !row[0].number? }
      .map(&.chars)

    columns = field.map { |chs| chs.size }.max

    field = field
      .map { |chs| [' '] + chs + [' '] * (columns - chs.size + 1) }
    field.unshift([' ']*(columns + 2))
    field.push([' ']*(columns + 2))

    instructions = rows.skip_while { |row| !row[0].number? }[0]
    numbers = instructions.split(/L|R/).map { |x| x.to_i }
    turns = instructions.split(/\d+/).select { |x| x != "" }

    {field, numbers, turns}
  end

  def solve(data)
    field, numbers, turns = data
    puts field, numbers, turns

    pos = Vec2.new(field[1].index('.').as T, 1)
    heading = Vec2(T).new("R")
    handedness = "R"
    (0..).each do |turn|
      numbers[turn].times do
        last_pos, last_heading = pos, heading
        pos += heading

        if field[pos.y][pos.x] == ' '
          pos, heading, handedness = wrap_around(pos, heading, handedness, field)
        end

        if field[pos.y][pos.x] == '#'
          pos, heading = last_pos, last_heading
          break
        end
      end
      puts "#{numbers[turn]}  #{pos}"

      if turn >= turns.size
        break
      end

      puts "#{turns[turn]}"
      if turns[turn] == handedness
        heading = heading.rotate_left
      else
        heading = heading.rotate_right
      end
    end

    password = 0
    if heading.x == 1
      password = 0
    end
    if heading.x == -1
      password = 2
    end
    if heading.y == 1
      password = 1
    end
    if heading.y == -1
      password = 3
    end

    password += 1000 * pos.y + 4 * pos.x
    password
  end
end

alias T = Int32

class Part1 < Day
  @part = "Part 1"

  def wrap_around(pos, heading, handedness, field)
    pos -= heading
    while field[pos.y][pos.x] != ' '
      pos -= heading
    end
    pos += heading

    {pos, heading, handedness}
  end
end

class Part2 < Day
  @part = "Part 2"

  def wrap_around(pos, heading, handedness, field)
    h = handedness
    if field.size < 50
      # the example
      if pos.x == 13 && pos.y < 5
        pos = Vec2.new(16, 13 - pos.y)
        heading = Vec2.new(-1, 0)
      elsif pos.x == 13 && pos.y > 4 && pos.y < 9
        pos = Vec2.new(21 - pos.y, 9)
        heading = Vec2.new(0, 1)
      elsif pos.x > 8 && pos.x < 13 && pos.y == 13
        pos = Vec2.new(13 - pos.x, 8)
        heading = Vec2.new(0, -1)
      elsif pos.x > 4 && pos.x < 9 && pos.y == 4
        pos = Vec2.new(9, pos.x - 4)
        heading = Vec2.new(1, 0)
      else
        raise pos.to_s
      end
    else
      #   12
      #   3
      #  45
      #  6

      # This portal order works, but actually the implementation is broken
      # because it does not take into account that portals may overlap in certain corners.
      p = portal(pos, h, 51, 151..200, 51..100, 150) || # 6->5
          portal(pos, h, 1..50, 201, 101..150, 1) ||    # 6->2
          portal(pos, h, 0, 151..200, 51..100, 1) ||    # 6->1
          portal(pos, h, 51..100, 151, 50, 151..200) || # 5->6
          portal(pos, h, 101, 101..150, 150, 50..1) ||  # 5->2
          portal(pos, h, 1..50, 100, 51, 51..100) ||    # 4->3
          portal(pos, h, 0, 101..150, 51, 50..1) ||     # 4->1
          portal(pos, h, 50, 51..100, 1..50, 101) ||    # 3->4
          portal(pos, h, 101, 51..100, 101..150, 50) || # 3->2
          portal(pos, h, 51..100, 0, 1, 151..200) ||    # 1->6
          portal(pos, h, 101..150, 0, 1..50, 200) ||    # 2->6
          portal(pos, h, 151, 1..50, 100, 150..101) ||  # 2->5
          portal(pos, h, 101..150, 51, 100, 51..100) || # 2->3
          portal(pos, h, 50, 1..50, 1, 150..101)        # 1->4
      if p
        pos, heading, handedness = p
      else
        raise pos.to_s
      end
    end
    {pos, heading, handedness}
  end
end

def portal(pos, h, x_in : Number | Range, y_in : Number | Range, x_out : Number | Range, y_out : Number | Range)
  offset = portal_in(pos, x_in, y_in)
  if offset
    portal_out(offset, h, x_out, y_out)
  end
end

def portal_in(pos, x_in : Number, y_in : Range)
  if pos.x == x_in && y_in.includes? pos.y
    if y_in.end > y_in.begin
      pos.y - y_in.begin
    else
      y_in.begin - pos.y
    end
  end
end

def portal_in(pos, x_in : Range, y_in : Number)
  if pos.y == y_in && x_in.includes? pos.x
    if x_in.end > x_in.begin
      pos.x - x_in.begin
    else
      x_in.begin - pos.x
    end
  end
end

def portal_out(offset : Number, h, x_out : Number, y_out : Range)
  if y_out.end > y_out.begin
    pos = Vec2.new(x_out, y_out.begin + offset)
  else
    pos = Vec2.new(x_out, y_out.begin - offset)
    # h = {"L" => "R", "R" => "L"}[h]
  end

  if x_out % 2 == 0
    heading = Vec2.new(-1, 0)
  else
    heading = Vec2.new(1, 0)
  end

  {pos, heading, h}
end

def portal_out(offset : Number, h, x_out : Range, y_out : Number)
  if x_out.end > x_out.begin
    pos = Vec2.new(x_out.begin + offset, y_out)
  else
    pos = Vec2.new(x_out.begin - offset, y_out)
    # h = {"L" => "R", "R" => "L"}[h]
  end

  if y_out % 2 == 0
    heading = Vec2.new(0, -1)
  else
    heading = Vec2.new(0, 1)
  end

  {pos, heading, h}
end

EXAMPLE = "        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5
"
