class GameObject
  attr_accessor :pos, :vel, :direction, :image, :hostile
  def initialize (color=[255,255,255])
    @image = Rubygame::Surface.new([Constants::PLAYER_SIZE, Constants::PLAYER_SIZE])
    @image.fill(color)

    @pos = Point.new(0, 0)
    @vel = Point.new(0, 0)
    @direction = nil

    @turns = []

    @hostile = false
  end

  def x
    @pos.x
  end

  def x= (nx)
    @pos.x = nx
  end

  def y
    @pos.y
  end

  def y= (ny)
    @pos.y = ny
  end

  def update
    turn_to @turns.shift if @pos == @turns.first
    @pos.x += @vel.x
    @pos.y += @vel.y
  end

  def collide? (other)
    return false if other.nil?

    col_x = 0
    col_y = 0

    if up?
      col_x = @pos.x + Constants::PLAYER_SIZE / 2
      col_y = @pos.y
    elsif down?
      col_x = @pos.x + Constants::PLAYER_SIZE / 2
      col_y = @pos.y + Constants::PLAYER_SIZE
    elsif left?
      col_x = @pos.x
      col_y = @pos.y + Constants::PLAYER_SIZE / 2
    elsif right?
      col_x = @pos.x + Constants::PLAYER_SIZE
      col_y = @pos.y + Constants::PLAYER_SIZE / 2
    end

    if col_x > other.pos.x && col_x < other.pos.x + Constants::PLAYER_SIZE
      if col_y > other.pos.y && col_y < other.pos.y + Constants::PLAYER_SIZE
        return true
      end
    end

    return false
  end

  def full_collide? (other)
    if (other.x >= @pos.x && other.x <= @pos.x + Constants::PLAYER_SIZE) || (other.x + Constants::PLAYER_SIZE >= @pos.x && other.x + Constants::PLAYER_SIZE <= @pos.x + Constants::PLAYER_SIZE)
      if (other.y >= @pos.y && other.y <= @pos.y + Constants::PLAYER_SIZE) || (other.y + Constants::PLAYER_SIZE >= @pos.y && other.y + Constants::PLAYER_SIZE <= @pos.y + Constants::PLAYER_SIZE)
        return true
      end
    end
    return false
  end

  def draw (surface)
    @image.blit(surface, [x, y])
  end

  def move
    if up?
      move_up
    elsif down?
      move_down
    elsif left?
      move_left
    else
      move_right
    end
  end

  def move_left
    @direction = :left
    @vel.x = -Constants::PLAYER_SPEED
    @vel.y = 0
    turn
  end

  def move_right
    @direction = :right
    @vel.x = Constants::PLAYER_SPEED
    @vel.y = 0
    turn
  end

  def move_up
    @direction = :up
    @vel.y = -Constants::PLAYER_SPEED
    @vel.x = 0
    turn
  end

  def move_down
    @direction = :down
    @vel.y = Constants::PLAYER_SPEED
    @vel.x = 0
    turn
  end

  def turn; end

  def add_turn (turning_point)
    @turns << turning_point
  end

  def turn_to (turning_point)
    self.send("move_#{turning_point.direction}") unless turning_point.nil?
  end

  def copy (other)
    @vel       = other.vel.dup
    @pos       = other.pos.dup
    @direction = other.direction.to_s.dup.to_sym
  end

  def up?
    @direction == :up
  end

  def down?
    @direction == :down
  end

  def left?
    @direction == :left
  end

  def right?
    @direction == :right
  end

  def vertical?
    up? || down?
  end

  def horizontal?
    left? || right?
  end

  def center
    Point.new(@pos.x + Constants::PLAYER_SIZE / 2, @pos.y + Constants::PLAYER_SIZE)
  end
end
