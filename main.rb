#!/usr/bin/env ruby

require_relative "lib_helper.rb"

#Rubygame::TTF.setup

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

game = Main.new
game.run
