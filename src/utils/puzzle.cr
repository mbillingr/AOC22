class Puzzle
  def check(input, expected)
    result = solve(parse(input))
    if result != expected
      p result
      p expected
      raise "wrong output"
    else
      puts "OK"
    end
  end

  def run(input)
    puts "#{@day}, #{@part}: #{solve(parse(input))}"
  end
end
