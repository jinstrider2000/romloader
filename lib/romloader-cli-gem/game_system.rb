class GameSystem

  attr_accessor :name, :rom_index_url, :roms

  @@all = []
  
  def initialize(name:, rom_index_url: nil)
    self.name = name
    self.rom_index_url = rom_index_url
    self.roms = {}
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

  def get_roms_by_letter(letter_index)
    self.roms[letter_index]
  end

  def get_rom_index_url(letter_index)
    self.rom_index_url[letter_index]
  end

  def get_rom_indices
    self.rom_index_url.keys
  end

  def add_roms_to_collection_by_letter(letter_index, game_obj_array)
    game_obj_array.each { |game| game.system = self }
    self.roms[letter_index] = game_obj_array
  end

end