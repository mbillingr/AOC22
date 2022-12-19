require "./utils/puzzle"

DAY = "19"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 33)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, "expected")
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split(". ").map(&.split))
      .map { |bp| [
        [bp[0][-2], "0", "0"],
        [bp[1][-2], "0", "0"],
        [bp[2][-5], bp[2][-2], "0"],
        [bp[3][-5], "0", bp[3][-2]],
      ] }
      .map { |bp| bp.map { |cost| cost.map(&.to_i) } }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    (1..data.size).map do |nr|
      puts nr
      total = maximal_output(24, [0, 0, 0], [1, 0, 0], Hash(Tuple(Int32, Array(Int32), Array(Int32)), Int32).new, data[nr - 1])
      total * nr
    end.sum
  end

  def maximal_output(time_remaining, resources, bots, seen, costs)
    if time_remaining <= 0
      return 0
    end

    cached = seen[{time_remaining, resources, bots}]?
    if cached
      return cached
    end

    result = [4, 3, 2, 1, 0].map do |b|
      bo = bots.clone
      res = [resources[0] + bots[0], resources[1] + bots[1], resources[2] + bots[2]]
      if b == 4
        maximal_output(time_remaining - 1, res, bo, seen, costs)
      else
        if costs[b].zip(resources).map { |c, r| c <= r }.all?
          res = [res[0] - costs[b][0], res[1] - costs[b][1], res[2] - costs[b][2]]
          if b == 3
            collect = b == 3 ? time_remaining - 1 : 0
            collect + maximal_output(time_remaining - 1, res, bo, seen, costs)
          else
            bo[b] = bo[b] + 1
            maximal_output(time_remaining - 1, res, bo, seen, costs)
          end
        else
          0
        end
      end
    end.max

    seen[{time_remaining, resources, bots}] = result

    result
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    puts data
  end
end

EXAMPLE = "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"
