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
