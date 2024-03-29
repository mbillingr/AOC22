require "./utils/puzzle"

DAY = "05"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, "CMZ")
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, "MCD")
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
  end
end

class Parser
  def initialize(@rows : Array(String))
  end

  def parse_puzzle
    stacks = parse_crates()
    index = parse_index()
    moves = parse_moves()

    {stacks, moves}
  end

  def parse_crates
    crates = [] of Array(Char)
    while !@rows[0].starts_with?(" 1")
      crates << @rows[0][1..].chars.each_slice(4).map(&.first).to_a
      @rows = @rows[1..]
    end

    # transpose
    (0...crates[-1].size)
      .map do |idx|
        crates
          .reverse_each
          .map { |row| row.fetch(idx, ' ') }
          .select { |ch| ch != ' ' }
          .to_a
      end
  end

  def parse_index
    @rows = @rows[1..]
  end

  def parse_moves
    @rows.map do |row|
      _, n, _, src, _, dst = row.split
      {n.to_i, src.to_i - 1, dst.to_i - 1}
    end
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    stacks, cmds = Parser.new(data).parse_puzzle

    cmds.each do |cmd|
      n, src, dst = cmd
      n.times do
        crate = stacks[src].pop
        stacks[dst].push(crate)
      end
    end

    stacks.map(&.last).join
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    stacks, cmds = Parser.new(data).parse_puzzle

    cmds.each do |cmd|
      n, src, dst = cmd
      stacks[dst] += stacks[src][-n..]
      stacks[src].pop(n)
    end

    stacks.map(&.last).join
  end
end

EXAMPLE = "
    [D]
[N] [C]
[Z] [M] [P]
 1   2   3

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2
"
