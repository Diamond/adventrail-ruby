#!/usr/bin/env ruby

#require "rubygems"
require "rubygame"
Rubygame::TTF.setup

class Main
  def initialize
    @screen = Rubygame::Screen.new([640, 480], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF])
    @screen.title = "Adventrail"

    @queue = Rubygame::EventQueue.new
    @clock = Rubygame::Clock.new
    @clock.target_framerate = 30

    @background = Rubygame::Surface.new([640, 480])
    @background.fill([0, 0, 0])

    @player = GameObject.new
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
    @screen.flip
  end

  def update
    @player.update

    @queue.each do |ev|
      case ev
        when Rubygame::QuitEvent
        Rubygame.quit
        exit
      end
    end
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
end

class GameObject
  def initialize
    @image = Rubygame::Surface.new([16, 16])
    @image.fill([255, 255, 255])

    @pos = Point.new(0, 0)
    @vel = Point.new(1, 1)
  end

  def x
    @pos.x
  end

  def y
    @pos.y
  end

  def update
    @pos.x += @vel.x
    @pos.y += @vel.y
  end

  def draw (surface)
    @image.blit(surface, [x, y])
  end
end

game = Main.new
game.run
