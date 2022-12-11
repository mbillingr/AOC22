require "./utils/puzzle"
require "big"

DAY = "11"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 10605)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 2713310158)
Part2.new.run(raw_data) # wrong: 12284204335

struct ModuloNumber
  @n : UInt64

  def initialize(n : UInt64)
    # These are all divisors used in the example and the input.
    # I'm not happy with hard-coding them, but I don't know how to set them dynamically
    @n = n % (23 * 19 * 13 * 17 * 7 * 5 * 11 * 2 * 3)
  end

  def initialize(n : String)
    @n = n.to_u64 % (23 * 19 * 13 * 17)
  end

  def *(other : ModuloNumber)
    ModuloNumber.new @n * other.@n
  end

  def *(other : UInt64)
    ModuloNumber.new @n * other
  end

  def +(other : ModuloNumber)
    ModuloNumber.new @n * other.@n
  end

  def +(other : UInt64)
    ModuloNumber.new @n + other
  end

  def //(other : UInt64)
    ModuloNumber.new @n // other
  end

  def %(other : UInt64)
    @n % other
  end
end

class Day(T) < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    rows = input
      .split("\n")
      .select { |x| x != "" }

    monkeys = [] of Monkey(T)
    while !rows.empty?
      monkeys.push(Monkey(T).new(rows))
    end

    monkeys
  end

  def simulate(num_rounds, monkeys)
    num_rounds.times do
      monkeys.each do |monkey|
        monkey.turn(monkeys)
      end
    end

    partial_mb = monkeys.each.map(&.items_thrown).to_a.sort
    monkey_business = partial_mb[-1] * partial_mb[-2]
    monkey_business
  end
end

class Part1 < Day(UInt64)
  @part = "Part 1"

  def solve(monkeys)
    self.simulate(20, monkeys)
  end
end

class Part2 < Day(ModuloNumber)
  @part = "Part 2"

  def solve(monkeys)
    monkeys.each { |m| m.very_worried = true }
    self.simulate(10000, monkeys)
  end
end

class Monkey(T)
  getter items_thrown : UInt64
  setter very_worried : Bool

  def initialize(@id : Int32, @items : Array(T), @operator : Proc(T, T), @divisor : UInt64, @on_true : Int32, @on_false : Int32, @very_worried : Bool = false)
    @items_thrown = 0
  end

  def initialize(rows)
    @very_worried = false
    @items_thrown = 0

    /Monkey (\d+):/.match(rows.shift)
    @id = $1.to_i

    /Starting items: (.*)/.match rows.shift
    @items = $1.split(", ").map { |x| T.new(x) }

    /Operation: new = old ([*+]) (\w+|\d+)/.match rows.shift
    case {$1, $2}
    when {"*", "old"}
      @operator = ->(old : T) { old * old }
    when {"*", _}
      n = $2.to_u64
      @operator = ->(old : T) { old * n }
    when {"+", "old"}
      @operator = ->(old : T) { old + old }
    when {"+", _}
      n = $2.to_u64
      @operator = ->(old : T) { old + n }
    else
      raise "Invalid operation #{$1} #{$2}"
    end

    /Test: divisible by (\d+)/.match rows.shift
    @divisor = $1.to_u64

    /If true: throw to monkey (\d+)/.match rows.shift
    @on_true = $1.to_i
    /If false: throw to monkey (\d+)/.match rows.shift
    @on_false = $1.to_i
  end

  def catch(item)
    @items.push(item)
  end

  def turn(monkeys : Array(Monkey))
    while !@items.empty?
      treat_next_item(@items.shift, monkeys)
    end
  end

  def treat_next_item(item : T, monkeys : Array(Monkey))
    @items_thrown += 1
    worry_level = @operator.call item

    if !@very_worried
      worry_level //= 3
    end

    if worry_level % @divisor == 0
      monkeys[@on_true].catch(worry_level)
    else
      monkeys[@on_false].catch(worry_level)
    end
  end
end

EXAMPLE = "Monkey 0:
  Starting items: 79, 98
  Operation: new = old * 19
  Test: divisible by 23
    If true: throw to monkey 2
    If false: throw to monkey 3

Monkey 1:
  Starting items: 54, 65, 75, 74
  Operation: new = old + 6
  Test: divisible by 19
    If true: throw to monkey 2
    If false: throw to monkey 0

Monkey 2:
  Starting items: 79, 60, 97
  Operation: new = old * old
  Test: divisible by 13
    If true: throw to monkey 1
    If false: throw to monkey 3

Monkey 3:
  Starting items: 74
  Operation: new = old + 3
  Test: divisible by 17
    If true: throw to monkey 0
    If false: throw to monkey 1
"
