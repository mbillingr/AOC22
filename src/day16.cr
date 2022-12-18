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

  def all_distances(edges)
    distances = edges.keys.map { |k| dijkstra k, edges }
    distances = Hash.zip(edges.keys, distances)
    distances
  end

  def dijkstra(source, graph)
    inf = 999999999
    dist = Hash(String, Int32).new
    prev = Hash(String, String).new
    queue = Set(String).new
    graph.each_key do |k|
      dist[k] = inf
      prev[k] = ""
      queue.add k
    end
    dist[source] = 0

    while !queue.empty?
      d, u = queue.map { |v| {dist[v], v} }.min
      queue.delete u

      graph[u].each do |n, du|
        alt = d + du
        if alt < dist[n]
          dist[n] = alt
          prev[n] = u
        end
      end
    end
    dist
  end

  def recursive_search(time_remaining, visited, remaining)
    current_node = visited[-1]

    if time_remaining <= 0
      return 0
    end

    flow = 0

    if @rates[current_node] > 0
      time_remaining -= 1
      flow = time_remaining * @rates[current_node]
    end

    if !remaining.empty?
      flow += remaining.map { |v|
        recursive_search(time_remaining - @distances[current_node][v], visited + [v], remaining - [v].to_set)
      }.max
    end

    flow
  end
end

class Part1 < Day
  @part = "Part 1"
  @rates = Hash(String, Int32).new
  @distances = Hash(String, Hash(String, Int32)).new

  def solve(data)
    rates, edges = data
    @rates = rates
    @distances = all_distances edges

    visitable_edges = edges.keys.to_set - ["AA"].to_set
    recursive_search(30, ["AA"], visitable_edges)
  end
end

class Part2 < Day
  @part = "Part 2"
  @rates = Hash(String, Int32).new
  @distances = Hash(String, Hash(String, Int32)).new

  def solve(data)
    rates, edges = data
    @rates = rates
    @distances = all_distances edges

    visitable_edges = edges.keys.to_set - ["AA"].to_set

    maximum = 0

    all_partitions(visitable_edges).to_a.reverse.map do |a|
      b = visitable_edges - a
      flow1 = recursive_search(26, ["AA"], a)
      flow2 = recursive_search(26, ["AA"], b)
      flow = flow1 + flow2
      if flow > maximum
        maximum = flow
        puts "maximum so far: #{flow}"
      end
      flow
    end.max
  end

  def all_partitions(set)
    set = set.to_a
    partitions = Set(Set(String)).new
    (1..set.size/2).map do |i|
      puts "building partitions #{i} / #{set.size/2}"
      set.each_permutation(i) do |p|
        partitions.add(p.to_set)
      end
    end
    partitions
  end
end

def flow_upper_limit(remaining_minutes, closed_rates)
  closed_rates.values.sum * remaining_minutes
end

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
