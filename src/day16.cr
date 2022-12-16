require "./utils/puzzle"

DAY = "16"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 1651)
Part2.new.check(EXAMPLE, 1707)
Part1.new.run(raw_data)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    data = input
      .split("\n")
      .select { |x| x != "" }
      .map(&.split("; "))
      .map do |row|
        {
          row[0].split[1],
          row[0].split("=")[1].to_i,
          row[1].strip("tunnels lead to valves ").split(", "),
        }
      end

    keys = data.map { |tunnel, _, _| tunnel }
    rates = data.map { |_, rate, _| rate }
    edges = data.map { |_, _, edge| edge }

    simplify_graph Hash.zip(keys, rates), Hash.zip(keys, edges)
  end

  def simplify_graph(rates, edges)
    new_edges = edges
      .each_key
      .map { |node| virtual_neighbors(node, rates, edges) }

    puts edges

    null_tunnels = rates.select { |k| rates[k] == 0 }
    null_tunnels.reject!("AA")

    edges_out = Hash.zip(edges.keys, new_edges.to_a)
    edges_out.reject!(null_tunnels.keys)

    {rates, edges_out}
  end

  def virtual_neighbors(start, rates, edges)
    visited = [start].to_set
    queue = [{start, 0}]
    vneighbors = {} of String => Int32
    while !queue.empty?
      v, d = queue.shift
      if rates[v] > 0 && v != start
        vneighbors[v] = d
      else
        edges[v]
          .select { |n| !visited.includes?(n) }
          .each do |n|
            visited.add(n)
            queue.push({n, d + 1})
          end
      end
    end
    vneighbors
  end
end

class Part1 < Day
  @part = "Part 1"
  @seen = Hash(Tuple(String, Int32, Hash(String, Int32)), Int32).new

  def solve(data)
    rates, edges = data
    puts edges
    brute_force("AA", 30, rates, edges)
  end

  def brute_force(pos, remaining_minutes, rates, edges)
    if remaining_minutes <= 0
      return 0
    end

    cached = @seen[{pos, remaining_minutes, rates}]?
    if cached
      return cached
    end

    # don't turn on
    flow1 = edges[pos]
      .each
      .map { |tgt, len| brute_force(tgt, remaining_minutes - len, rates, edges) }
      .max

    # turn on
    guaranteed_flow = rates[pos] * (remaining_minutes - 1)
    if guaranteed_flow == 0
      best_flow = flow1
    else
      flow2 = guaranteed_flow + brute_force(pos, remaining_minutes - 1, rates.merge({pos => 0}), edges)
      best_flow = [flow1, flow2].max
    end

    @seen[{pos, remaining_minutes, rates}] = best_flow

    best_flow
  end
end

class Part2 < Day
  @part = "Part 2"
  @seen = Hash(Tuple(String, String, Int32, Hash(String, Int32)), Int32).new

  def solve(data)
    rates, edges = data
    puts edges
    brute_force("AA", "AA", 26, rates, edges)
  end

  def brute_force(pos1, pos2, remaining_minutes, rates, edges)
    if remaining_minutes <= 0
      return 0
    end

    cached = @seen[{pos, pos2, remaining_minutes, rates}]?
    if cached
      return cached
    end

    # don't turn on
    flow1 = edges[pos1].each
      .map do |tgt, len|
        edges[pos1].each
          .map do |tgt, len|
            brute_force(tgt, pos2, remaining_minutes - len, rates, edges)
          end
      end
      .max

    # turn on
    guaranteed_flow = rates[pos] * (remaining_minutes - 1)
    if guaranteed_flow == 0
      best_flow = flow1
    else
      flow2 = guaranteed_flow + brute_force(pos, pos2, remaining_minutes - 1, rates.merge({pos => 0}), edges)
      best_flow = [flow1, flow2].max
    end

    @seen[{pos, remaining_minutes, rates}] = best_flow

    best_flow
  end
end

# def flow_upper_limit(remaining_minutes, closed_rates)

EXAMPLE = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
Valve BB has flow rate=13; tunnels lead to valves CC, AA
Valve CC has flow rate=2; tunnels lead to valves DD, BB
Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
Valve EE has flow rate=3; tunnels lead to valves FF, DD
Valve FF has flow rate=0; tunnels lead to valves EE, GG
Valve GG has flow rate=0; tunnels lead to valves FF, HH
Valve HH has flow rate=22; tunnel leads to valve GG
Valve II has flow rate=0; tunnels lead to valves AA, JJ
Valve JJ has flow rate=21; tunnel leads to valve II
"
