class GameSystem

  attr_accessor :name, :rom_url_index, :roms

  @@all
  
  def initialize(name:, rom_url_index: nil)
    @name = name
    @rom_url_index = rom_url_index
    @roms = {}
    @@all << self
  end

  def self.create_from_collection(system_array)
    system_array.each { |system_details| self.new(system_details)}
  end

  def self.all
    @@all    
  end

  def self.destroy_all
    @@all = []
  end

end