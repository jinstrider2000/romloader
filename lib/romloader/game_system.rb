
# The class whose instances represent an individual game system (e.g. Sega Genesis object) 
class RomLoader::GameSystem
  
  attr_accessor :name, :rom_index_url
  attr_writer :rom_indices

  @@all = []
  
  # Create individual game system objects from information scraped from http://freeroms.com, sets all instance variables
  def initialize(name:, rom_index_url:)
    @name = name
    @rom_index_url = rom_index_url
    @rom_indices = {}
    @roms = {}
    @@all << self
  end

  # Creates multiple GameSystem objects from information scraped from http://freeroms.com
  def self.create_from_collection(system_array)
    system_array.each { |system_details| self.new(system_details)}
    nil
  end

  # Retrieves an array of all GameSystem objects
  def self.all
    @@all    
  end

  # Retrieves an array of all GameRom objects starting which the provided letter index (e.g. [Sonic the Hedgehog, Streets of Rage,...])
  def get_roms_by_letter(letter_index)
    @roms[letter_index]
  end

  # Retrieves an array of the indicies for the roms (i.e. ["A","B","C"...])
  def get_rom_indices
    @rom_indices.keys
  end

  # Retrieves the url for roms of a particular letter index (e.g. "A" => "http://freeroms.com/genesis_games_that_start_with_a.html")
  def get_rom_collection_url(letter_index)
    @rom_indices[letter_index]
  end

  # Add the game collection scraped from http://freeroms.com to the GameSystem object to the roms (Hash)
  def add_roms_to_collection_by_letter(letter_index, game_obj_array)

    game_obj_array.each { |game| game.system = self }
    @roms[letter_index] = game_obj_array
  end

end