
struct Vec2
  getter x : Int64
  getter y : Int64

  def initialize(@x, @y)
  end

  def initialize(direction : String)
    if direction == "R"
      @x, @y = 1i64, 0i64
    elsif direction == "L"
      @x, @y = -1i64, 0i64
    elsif direction == "U"
      @x, @y = 0i64, 1i64
    elsif direction == "D"
      @x, @y = 0i64, -1i64
    else
      raise "Invalid direction #{direction}"
    end
  end

  def +(other : Vec2)
    Vec2.new(@x + other.x, @y + other.y)
  end

  def -(other : Vec2)
    Vec2.new(@x - other.x, @y - other.y)
  end

  def inf_norm
    if @x.abs > @y.abs
      @x.abs
    else
      @y.abs
    end
  end

  def box_normalize
    if @x > 1
      @x = 1
    elsif @x < -1
      @x = -1
    end

    if @y > 1
      @y = 1
    elsif @y < -1
      @y = -1
    end

    Vec2.new(@x, @y)
  end
end
