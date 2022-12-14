require "./utils/puzzle"

DAY = "13"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 13)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 140)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map { |row| parse_v(row)[0] }
  end

  def parse_v(s : String) : Tuple(V, String)
    if s[0] == '['
      parse_l(s)
    else
      parse_i(s)
    end
  end

  def parse_l(s : String) : Tuple(L, String)
    items = [] of V
    s = eat_char('[', s)
    while s[0] != ']'
      v, s = parse_v(s)
      items.push(v)
      if s[0] == ']'
        break
      end
      s = eat_char(',', s)
    end
    {items, eat_char(']', s)}
  end

  def parse_i(s : String) : Tuple(I, String)
    n = 0
    while s[0].ascii_number?
      n *= 10
      n += s[0].to_i
      s = s[1..]
    end
    {n, s}
  end

  def eat_char(ch : Char, s : String) : String
    if s[0] != ch
      raise "Expected '#{ch}', got \"#{s}\""
    end
    s[1..]
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    index = 0
    data.each_slice(2)
      .map { |x| index += 1; {index, x} }
      .map { |idx, pair| {idx, in_order?(pair[0], pair[1])} }
      .select { |_, order| order == '<' }
      .map { |idx, _| idx }
      .sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    data.push([[2.as V].as V])
    data.push([[6.as V]. as V])
    sorted = data.sort { |a, b| {'<' => -1, '=' => 0, '>' => 1}[in_order?(a, b)] }
    puts sorted
    a = (sorted.index [[2]]).as Int32 + 1
    b = (sorted.index [[6]]).as Int32 + 1
    a * b
  end
end

alias I = Int32
alias L = Array(V)
alias V = I | Array(V)


def in_order?(a : I, b : I)
  if a < b
    '<'
  elsif a > b
    '>'
  else
    '='
  end
end

def in_order?(a : I, b : L)
  in_order?([a.as V], b)
end

def in_order?(a : L, b : I)
  in_order?(a, [b.as V])
end

def in_order?(a : L, b : L)
  if a.empty? && b.empty?
    '='
  elsif a.empty?
    '<'
  elsif b.empty?
    '>'
  else
    first = in_order?(a[0], b[0])
    if first == '='
      in_order?(a[1..], b[1..])
    else
      first
    end
  end
end

EXAMPLE = "[1,1,3,1,1]
[1,1,5,1,1]

[[1],[2,3,4]]
[[1],4]

[9]
[[8,7,6]]

[[4,4],4,4]
[[4,4],4,4,4]

[7,7,7,7]
[7,7,7]

[]
[3]

[[[]]]
[[]]

[1,[2,[3,[4,[5,6,7]]]],8,9]
[1,[2,[3,[4,[5,6,0]]]],8,9]
"
