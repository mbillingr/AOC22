raw_data = File.read("../data/input01.txt")

def parse_input(raw_data)
  raw_data
    .split("\n\n")
    .map { |blk| to_numbers(blk) }
end

def to_numbers(blk)
  blk.split("\n")
    .select { |x| x != "" }
    .map { |x| x.to_i }
end

totals = parse_input(raw_data)
  .map { |blk| blk.sum }

printf "Day 01/1: %d\n", totals.max

printf "Day 01/2: %d\n", totals.sort[-3, 3].sum
