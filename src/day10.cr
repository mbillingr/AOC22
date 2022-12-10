require "./utils/puzzle"

DAY = "10"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 13140)
Part1.new.run(raw_data)

Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split)
      .map do |cmd|
        if cmd[0] == "noop"
          NoOp.new
        elsif cmd[0] == "addx"
          AddX.new(cmd[1].to_i)
        else
          raise "Unknown Command #{cmd}"
        end
      end
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(instructions)
    result = 0
    next_probe_cycle = 20
    cycle, x = 0, 1

    instructions.each do |op|
      cycle, x_new = op.update_state(cycle, x)

      if cycle >= next_probe_cycle
        result += next_probe_cycle * x
        if next_probe_cycle == 220
          return result
        end
        next_probe_cycle += 40
      end

      x = x_new
    end
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(instructions)
    display_buffer = ['?'] * 40 * 6
    cycle, x = 0, 1

    instructions.each do |op|
      new_cycle, new_x = op.update_state(cycle, x)

      (cycle...new_cycle)
        .each do |cycle|
          hpos = cycle % 40
          display_buffer[cycle] = (hpos >= x - 1 && hpos <= x + 1) ? '█' : '░'
        end

      cycle, x = new_cycle, new_x
    end

    display_buffer
      .each_slice(40)
      .map(&.join)
      .map { |row| '\n' + row }
      .join
  end
end

abstract struct Op
  abstract def update_state(cycle, x)
end

struct NoOp < Op
  def update_state(cycle, x)
    {cycle + 1, x}
  end
end

struct AddX < Op
  def initialize(@n : Int32)
  end

  def update_state(cycle, x)
    {cycle + 2, x + @n}
  end
end

EXAMPLE = "addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop
"
