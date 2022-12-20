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

  def maximal_output_iterative(time_remaining, costs)
    seen = Set(Tuple(Int32, Array(Int32), Array(Int32))).new

    best_gathered = [0] * time_remaining

    queue = [{time_remaining, [0, 0, 0], [1, 0, 0], 0}]

    best = 0

    while !queue.empty?
      best_idx = -1
      # best_score = [0]#, 0, 0, 0] # , 0, 0, 0]
      # i = 0
      # queue.each do |time_remaining, resources, bots, gathered|
      #   score = [gathered]#, bots[2], bots[1], bots[0]] # , resources[2], resources[1], resources[0]]
      #   if score > best_score
      #     best_idx = i
      #     best_score = score
      #   end
      #   i += 1
      # end
      # # puts best_score, best_idx

      time_remaining, resources, bots, gathered = queue.delete_at best_idx

      if time_remaining <= 0
        if gathered > best
          best = gathered
          puts best
        end
        next
      end

      state = {time_remaining, resources, bots}
      if seen.includes? state
        next
      end
      seen.add state

      res = [resources[0] + bots[0], resources[1] + bots[1], resources[2] + bots[2]]

      time_remaining -= 1

      queue.push({time_remaining, res, bots, gathered})
      [0, 1, 2, 3]
        .select { |b| costs[b].zip(resources).map { |c, r| c <= r }.all? }
        .each do |b|
          bo = bots.clone

          res_used = [res[0] - costs[b][0], res[1] - costs[b][1], res[2] - costs[b][2]]
          if b == 3
            collect = b == 3 ? time_remaining : 0
            queue.push({time_remaining, res_used, bo, gathered + collect})
          else
            bo[b] = bo[b] + 1
            queue.push({time_remaining, res_used, bo, gathered})
          end
        end
    end

    best
  end

  def maximal_output(time_remaining, resources, bots, seen, costs)
    if time_remaining <= 0
      return 0
    end

    #key = {time_remaining, resources, bots}
    #key = time_remaining + 100 * resources[0] + 10000 * resources[1] + 1000000 * resources[2] + 10000000 * bots[0] + 100000000 * bots[1] + 1000000000 * bots[2]
    key = [time_remaining] + resources + bots

    cached = seen[key]?
    if cached
      return cached
    end

    choices = [3, 2, 1, 0]
      .select { |b| costs[b].zip(resources).map { |c, r| c <= r }.all? }
      .map do |b|
        bo = bots.clone
        res = [resources[0] + bots[0], resources[1] + bots[1], resources[2] + bots[2]]

        res = [res[0] - costs[b][0], res[1] - costs[b][1], res[2] - costs[b][2]]
        if b == 3
          collect = b == 3 ? time_remaining - 1 : 0
          collect + maximal_output(time_remaining - 1, res, bo, seen, costs)
        else
          bo[b] = bo[b] + 1
          maximal_output(time_remaining - 1, res, bo, seen, costs)
        end
      end

    res = [resources[0] + bots[0], resources[1] + bots[1], resources[2] + bots[2]]
    choices.push maximal_output(time_remaining - 1, res, bots, seen, costs)

    result = choices.max

    seen[key] = result

    result
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    (1..data.size).map do |nr|
      # total = maximal_output(24, [0, 0, 0], [1, 0, 0], 0, Hash(Tuple(Int32, Array(Int32), Array(Int32)), Int32).new, data[nr - 1])
      # total = maximal_output(24, [0, 0, 0], [1, 0, 0], Hash(Array(Int32), Int32).new, data[nr - 1])
      total = maximal_output_iterative(24, data[nr - 1])
      puts "#{nr}: #{total}"
      total * nr
    end.sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    (1..3).map do |nr|
      total = maximal_output(32, [0, 0, 0], [1, 0, 0], Hash(Array(Int32), Int32).new, data[nr - 1])
      #total = maximal_output_iterative(32, data[nr - 1])
      puts "#{nr}: #{total}"
      total
    end.product
  end
end

EXAMPLE = "Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
"
