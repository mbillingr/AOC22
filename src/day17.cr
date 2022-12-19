require "big"
require "./utils/puzzle"
require "./utils/vec2"

DAY = "17"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 3068)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 1514285714288)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .first
      .chars
  end

  def compute(n : UInt64, data)
    solid_rock = [Vec2.new(0, 0), Vec2.new(1, 0), Vec2.new(2, 0), Vec2.new(3, 0), Vec2.new(4, 0), Vec2.new(5, 0), Vec2.new(6, 0)].to_set
    solid_rock = solid_rock.map { |p| Vec2.new(BigInt.new(p.x), BigInt.new(p.y))}.to_set

    jet_idx = 0u64
    rocks = ROCKS.cycle

    seen_states = Hash(Tuple(UInt64, Set(Vec2(BigInt))), Tuple(UInt64, BigInt)).new

    buffer_size = 100

    i = 0u64
    rocks.each do |rock|
      highest_point = solid_rock.map(&.y).max

      state = solid_rock
        .select { |p| p.y > highest_point - buffer_size }
        .map { |p| Vec2.new(p.x, p.y - (highest_point - buffer_size))}
        .to_set

      prev = seen_states[{jet_idx, state}]?
      if prev
        previ, prevh = prev
        puts "cycle #{previ} -> #{i}"
        cycle_length = i - previ
        cycle_height = highest_point - prevh
        remaining_steps = n - i
        cycles = remaining_steps // cycle_length
        solid_rock = state.map { |p| Vec2.new(p.x, p.y + highest_point - buffer_size + cycle_height * cycles)}.to_set
        highest_point = solid_rock.map(&.y).max
        i += cycles * cycle_length
        seen_states.clear
      end

      if i >= n
        break
      end

      seen_states[{jet_idx, state}] = {i, highest_point}

      rock = translate_rock(Vec2.new(BigInt.new(3), 4 + highest_point), rock)
      while true
        jet = data[jet_idx]
        jet_idx = (jet_idx + 1) % data.size
        if jet == '>'
          rock1 = translate_rock(Vec2.new(1, 0), rock)
          if rock1.map(&.x).max > 7
            rock1 = rock
          end
        else
          rock1 = translate_rock(Vec2.new(-1, 0), rock)
          if rock1.map(&.x).min < 1
            rock1 = rock
          end
        end

        if !solid_rock.intersects? rock1
          rock = rock1
        end

        rock1 = translate_rock(Vec2.new(0, -1), rock)

        if solid_rock.intersects? rock1
          solid_rock += rock
          break
        else
          rock = rock1
        end
      end
      i += 1
    end

    solid_rock.map(&.y).max
  end

  def translate_rock(delta, rock)
    rock.map { |p| p + delta }.to_set
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    compute(2022, data)
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    compute(1000000000000, data)
  end
end

ROCKS = [
  [Vec2.new(0, 0), Vec2.new(1, 0), Vec2.new(2, 0), Vec2.new(3, 0)].to_set,
  [Vec2.new(1, 0), Vec2.new(0, 1), Vec2.new(1, 1), Vec2.new(2, 1), Vec2.new(1, 2)].to_set,
  [Vec2.new(0, 0), Vec2.new(1, 0), Vec2.new(2, 0), Vec2.new(2, 1), Vec2.new(2, 2)].to_set,
  [Vec2.new(0, 0), Vec2.new(0, 1), Vec2.new(0, 2), Vec2.new(0, 3)].to_set,
  [Vec2.new(0, 0), Vec2.new(0, 1), Vec2.new(1, 0), Vec2.new(1, 1)].to_set,
].map { |r| r.map { |p| Vec2.new(BigInt.new(p.x), BigInt.new(p.y))}.to_set }

EXAMPLE = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
"
