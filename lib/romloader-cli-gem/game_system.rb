class GameSystem

  attr_accessor :name, :rom_url_index, :roms

  @@all
  
  def initialize(name:,rom_url_index: nil)
    @name = name
    @rom_url_index = rom_url_index
    @roms = []
    @@all << self
  end

  def self.create_from_collection(system_array)
    system_array.each { |game_system| self.new(game_system)}
  end

  def self.all
    @@all    
  end

  def self.destroy_all
    @@all = []
  end
  
end