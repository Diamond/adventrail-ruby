class Player < GameObject
  def initialize(color=[255, 255, 255])
    super(color)
    @pos.x = 312
    @pos.y = 600
    @direction = :up
    move_up

    @living = true
    @player = true

    @pieces = []
    @turns  = []
  end

  def living?
    @living
  end

  def update
    super

    if @player && (@pos.x < 0 || @pos.x + Constants::PLAYER_SIZE > 640 || @pos.y < 0 || @pos.y + Constants::PLAYER_SIZE > 640)
      @living = false
      return
    end

    remove_turns = []
    last_piece = self
    @pieces.each do |piece|
      piece.update
      if collide?(piece) && @player
        @living = false
        return
      end
      @turns.each_with_index do |turn, i|
        if piece.x == turn.x && piece.y == turn.y
          piece.turn_to(turn) 
          remove_turns << i if piece == @pieces.last
        end
      end
      last_piece = piece
    end
    remove_turns.each { |i| @turns.delete_at(i) }
  end

  def add_piece
    @pieces << piece_factory
  end

  def turn
    @turns << TurningPoint.new(@pos.x, @pos.y, @direction)
  end

  def draw (screen)
    @pieces.each { |piece| piece.draw(screen) }
    super(screen)
  end

  def piece_factory
    piece = GameObject.new([255-@pieces.size*5,255-@pieces.size*5,255-@pieces.size*5])
    tail = @pieces.last || self
    piece.copy(tail)
    offset = Constants::TRAIL_OFFSET # * (@pieces.size+1)
    if tail.left?
      piece.x += offset
    elsif tail.right?
      piece.x -= offset
    elsif tail.up?
      piece.y += offset
    elsif tail.down?
      piece.y -= offset
    end
    return piece
  end
end
