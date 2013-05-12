class Enemy < Player
  def initialize(color=[0,0,255])
    super(color)
    @pos.x = rand(20..620)
    @pos.y = rand(20..620)

    @pieces = []
    @turns  = []
    @player = false

    change_direction
    5.times { add_piece }
    reset_time

    move
  end

  def reset_time
    @time_until_turn = rand(3..8) * 4
  end

  def update
    if @time_until_turn <= 0 || moving_off_screen?
      reset_time
      change_direction
    else
      @time_until_turn -= 1
    end
    super
  end

  def moving_off_screen?
    return true if up? && @pos.y <= 4 + Constants::PLAYER_SIZE
    return true if down? && @pos.y >= 636 - Constants::PLAYER_SIZE
    return true if left? && @pos.x <= 4 + Constants::PLAYER_SIZE
    return true if right? && @pos.x >= 636 - Constants::PLAYER_SIZE
  end

  def change_direction
    directions = []
    if (up? || down?)
      directions = [:left, :right]
    else
      directions = [:up, :down]
    end
    if on_top?
      directions.delete(:up)
    elsif on_bottom?
      directions.delete(:down)
    elsif on_left?
      directions.delete(:left)
    elsif on_right?
      directions.delete(:right)
    end
    choice = rand(0..directions.size)
    @direction = directions[choice]
    move
  end

  def on_edge?
    on_left? || on_right? || on_top? || on_bottom?
  end

  def on_top?
    @pos.y < 4
  end

  def on_bottom?
    @pos.y + Constants::PLAYER_SIZE >= 600
  end

  def on_left?
    @pos.x < 4
  end

  def on_right?
    @pos.x + Constants::PLAYER_SIZE > 600
  end
end
