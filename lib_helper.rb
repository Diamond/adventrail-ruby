require "rubygame"

libs = %w(point turning_point rect game_object player enemy food)

libs.each { |lib| require_relative lib }
