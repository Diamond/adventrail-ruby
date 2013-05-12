class TurningPoint < Point
  attr_accessor :direction
  def initialize (x=0, y=0, direction=nil)
    super x, y
    @direction = direction
  end

  def to_s
    super + ",#{@direction}"
  end
end
