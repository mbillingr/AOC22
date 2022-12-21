require "./utils/puzzle"

DAY = "21"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 152)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 301)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    parse_ops(input
      .split("\n")
      .select { |x| x != "" }
      .map do |row|
        row.split(/:?\s/)
      end)
  end

  def parse_ops(rows)
    lhs = rows.map { |row| row[0] }
    rhs = rows.map do |row|
      if row.size == 2
        row[1].to_i64
      else
        [row[2], row[1], row[3]]
      end
    end
    Hash.zip(lhs, rhs)
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    ops : Hash(String, Array(String)) = data.select { |k, v| !(Number === v) }.transform_values { |v| v.as Array(String) }
    waiting2 = ops.keys.to_set
    waiting1 = Set(String).new
    ready = Array(String).new
    values = data.select { |k, v| Number === v }.transform_values { |v| v.as Number }

    dependents = Hash(String, Array(String)).new { |h, k| h[k] = [] of String }
    ops
      .each { |k, v| dependents[v[1]].push(k); dependents[v[2]].push(k) }

    values.each_key do |r|
      dependents[r].each do |k|
        if waiting2.includes? k
          waiting2.delete k
          waiting1.add k
        elsif waiting1.includes? k
          waiting1.delete k
          ready.push k
        end
      end
    end

    while true
      monkey = ready.pop
      a = values[ops[monkey][1]]
      b = values[ops[monkey][2]]
      c = case ops[monkey][0]
          when "+"
            a + b
          when "-"
            a - b
          when "*"
            a * b
          when "/"
            a // b
          else
            raise "oops"
          end
      values[monkey] = c

      if monkey == "root"
        return c
      end

      dependents[monkey].each do |k|
        if waiting2.includes? k
          waiting2.delete k
          waiting1.add k
        elsif waiting1.includes? k
          waiting1.delete k
          ready.push k
        end
      end
    end
  end
end

alias Expr = String | Int64 | Tuple(String, Array(Expr))

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    lhs = build_expr data["root"].as(Array(String))[1], data
    rhs = build_expr data["root"].as(Array(String))[2], data

    puts lhs
    puts rhs
  end

  def build_expr(x, data) : Expr
    case x
    when String
      build_expr(data[x], data)
    when Number
      x
    when Array
      a : Expr = build_expr(data[x[1]], data)
      b : Expr = build_expr(data[x[2]], data)
      {x[0], [a, b]}
    else
      raise "oops"
    end
  end
end

EXAMPLE = "root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32
"
