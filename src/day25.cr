require "./utils/puzzle"

DAY = "25"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, "2=-1=0")
Part1.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map { |row| Snafu.from_str(row) }
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    data.sum.to_s
  end
end

class Snafu
  @digits : Array(Char)

  def initialize(@digits)
  end

  def Snafu.zero
    Snafu.new(['0'])
  end

  def Snafu.from_str(s)
    Snafu.new(s.chars.reverse)
  end

  def to_s
    @digits.reverse.join
  end

  def +(other)
    result = [] of Char
    carry = '0'

    i = 0
    while i < @digits.size || i < other.@digits.size
      a = i < @digits.size ? @digits[i] : '0'
      b = i < other.@digits.size ? other.@digits[i] : '0'
      r, carry = full_adder(a, b, carry)
      result.push(r)
      i += 1
    end

    if carry != '0'
      result.push carry
    end

    Snafu.new result
  end
end

def full_adder(a, b, c)
  w, x = half_adder(a, b)
  y, z = half_adder(w, c)
  r, s = half_adder(x, z)
  {y, r}
end

def half_adder(a, b)
  case {a, b}
  when {'0', _}
    {b, '0'}
  when {_, '0'}
    {a, '0'}
  when {'=', '='}
    {'1', '-'}
  when {'=', '-'}
    {'2', '-'}
  when {'=', '1'}
    {'-', '0'}
  when {'=', '2'}
    {'0', '0'}
  when {'-', '='}
    {'2', '-'}
  when {'-', '-'}
    {'=', '0'}
  when {'-', '1'}
    {'0', '0'}
  when {'-', '2'}
    {'1', '0'}
  when {'1', '='}
    {'-', '0'}
  when {'1', '-'}
    {'0', '0'}
  when {'1', '1'}
    {'2', '0'}
  when {'1', '2'}
    {'=', '1'}
  when {'2', '='}
    {'0', '0'}
  when {'2', '-'}
    {'1', '0'}
  when {'2', '1'}
    {'=', '1'}
  when {'2', '2'}
    {'-', '1'}
  else
    raise "#{a} + #{b}"
  end
end

EXAMPLE = "1=-0-2
12111
2=0=
21
2=01
111
20012
112
1=-1=
1-12
12
1=
122
"
