require "./utils/puzzle"

DAY = "19"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 33)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 56 * 62)
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

  def maximize_output(time_remaining, costs)
    seen = Set(Tuple(Int32, Array(Int32), Array(Int32))).new

    queue = [{time_remaining, [0, 0, 0], [1, 0, 0], 0}]

    best = 0

    while !queue.empty?
      time_remaining, resources, bots, gathered = queue.pop

      if time_remaining <= 0
        best = Math.max(gathered, best)
        next
      end

      if possible_output_heuristic(time_remaining) + gathered <= best
        # if we can't possibly beat the best so far we don't need to expand this node
        next
      end

      if !seen.add?({time_remaining, resources, bots})
        next
      end

      res = [resources[0] + bots[0], resources[1] + bots[1], resources[2] + bots[2]]

      time_remaining -= 1

      queue.push({time_remaining, res, bots, gathered})
      [0, 1, 2, 3]
        .select { |b| costs[b].zip(resources).map { |c, r| c <= r }.all? }
        .each do |b|
          res_used = [res[0] - costs[b][0], res[1] - costs[b][1], res[2] - costs[b][2]]
          if b == 3
            queue.push({time_remaining, res_used, bots, gathered + time_remaining})
          else
            bo = bots.clone
            bo[b] = bo[b] + 1
            queue.push({time_remaining, res_used, bo, gathered})
          end
        end
    end

    best
  end

  def possible_output_heuristic(time_remaining)
    # assume we build one geode bot each round
    time_remaining * (time_remaining - 1) / 2
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data.zip(1..).map do |bp, nr|
      total = maximize_output(24, bp)
      puts "#{nr}: #{total}"
      total * nr
    end.sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data = data[...3]
    data.zip(1..).map do |bp, nr|
      total = maximize_output(32, bp)
      puts "#{nr}: #{total}"
      total
    end.product
  end
end

EXAMPLE = "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"
