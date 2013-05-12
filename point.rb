class Point
  attr_accessor :x, :y
  def initialize (x=0, y=0)
    @x = x
    @y = y
  end

  def to_s
    "#{@x},#{@y}"
  end

  def == (other)
    !other.nil? && @x == other.x && @y == other.y
  end

  def distance (other)
    dx = (other.x - @x).abs
    dy = (other.y - @y).abs

    return [dx, dy]
  end
end
