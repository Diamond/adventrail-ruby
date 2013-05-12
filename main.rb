#!/usr/bin/env ruby

require "rubygame"
Rubygame::TTF.setup

class Constants
  PLAYER_SPEED = 4
  TRAIL_OFFSET = 16
  PLAYER_SIZE  = 16
  PELLETS      = 5
end

class Main
  def initialize
    @screen = Rubygame::Screen.new([640, 640], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF])
    @screen.title = "Adventrail"

    @queue = Rubygame::EventQueue.new
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 30

    @background = Rubygame::Surface.new([640, 640])
    @background.fill([0, 0, 0])

    @player = Player.new
    @enemy  = Enemy.new
    @food   = []
    Constants::PELLETS.times { @food << Food.new }
  end

  def run
    loop do
      update
      draw
      @clock.tick
    end
  end

  def draw
    @screen.fill [0, 0, 0]
    @player.draw(@screen)
    @enemy.draw(@screen)
    @food.each { |pellet| pellet.draw(@screen) }
    @screen.flip
  end

  def update
    @player.update
    @enemy.update

    @food.each do |pellet|
      if pellet.full_collide? @player
        @player.add_piece
        pellet.random_coord
      end
    end

    quit unless @player.living?

    @queue.each do |event|
      case event
        when Rubygame::QuitEvent
        Rubygame.quit
        exit
        when Rubygame::KeyDownEvent
        if event.key == Rubygame::K_UP
          @player.move_up unless @player.vertical?
        elsif event.key == Rubygame::K_DOWN
          @player.move_down unless @player.vertical?
        elsif event.key == Rubygame::K_LEFT
          @player.move_left unless @player.horizontal?
        elsif event.key == Rubygame::K_RIGHT
          @player.move_right unless @player.horizontal?
        elsif event.key == Rubygame::K_N
          @player.add_piece
        elsif event.key == Rubygame::K_ESCAPE
          quit
        end
      end
    end
  end

  def quit
    Rubygame.quit
    exit
  end
end

class Rect
  attr_accessor :x, :y, :w, :h
  def initialize (x=0, y=0, w=0, h=0)
    @x = x
    @y = y
    @w = w
    @h = h
  end
end

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

class Food < GameObject
  def initialize
    super ([255, 0, 0])
    random_coord
  end

  def random_coord
    @pos.x = rand(20..600)
    @pos.y = rand(20..600)
  end

  def update
  end

  def draw (screen)
    super screen
  end
end

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

game = Main.new
game.run
