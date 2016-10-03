
# The class whose instances represent an individual game system (e.g. Sega Genesis object) 
class GameSystem
  # Class Variables:
  # => 1. all (Array<GameSystem>): Contains an array of all GameSystem objects that have been instantiated.
  #
  # Instance Variables:
  # => 1. name (String): Contains the system's name (e.g. "Sega Genesis")
  # => 2. rom_indices (Hash): Contains key/value pairs of a rom index letter and a url (e.g. {"A" => "http://freeroms.com/genesis_games_that_start_with_a.html"}) 
  # => 3. roms (Hash): Contains key/value pairs of a rom index letter and an array of GameRom objects (e.g. {"S" => [Sonic the Hedgehog, Streets of Rage,...], "T" => [...], etc})
  # => 4. rom_index_url (String): Contains the url that leads to the rom index for the given system on http://freeroms.com
  
  attr_accessor :name, :rom_index_url
  attr_writer :rom_indices

  @@all = []
  
  # Purpose: Create individual game system objects from information scraped from http://freeroms.com, sets all instance variables
  def initialize(name:, rom_index_url:)
    # Arguments:
    # => 1. name (String): Contains the system's name (e.g. "Sega Genesis")
    # => 2. rom_index_url (String): Contains the url that leads to the rom index for the given system on http://freeroms.com
    #
    # Return:
    # => GameSystem object
    @name = name
    @rom_index_url = rom_index_url
    @rom_indices = {}
    @roms = {}
    @@all << self
  end

  # Purpose: Creates multiple GameSystem objects from information scraped from http://freeroms.com
  def self.create_from_collection(system_array)
    # Arguments:
    # => 1. system_array (Array<Hash>): Contains an array of key/value pairs of the GameSystem instance variables and values (e.g. [{:name =>"NES"...},{:name => "SNES"..,},etc])
    #
    # Return:
    # => nil
    system_array.each { |system_details| self.new(system_details)}
    nil
  end

  # Purpose: Retrieves an array of all GameSystem objects
  def self.all
    # Arguments: None
    #
    # Return:
    # => Array<GameSystem>
    @@all    
  end

  # Purpose: Retrieves an array of all GameRom objects starting which the provided letter index (e.g. [Sonic the Hedgehog, Streets of Rage,...])
  def get_roms_by_letter(letter_index)
    # Arguments:
    # => 1. letter_index (String): Letter used as key to retrieve array
    # Return:
    # => Array<GameRom>
    @roms[letter_index]
  end

  # Purpose: Retrieves an array of the indicies for the roms (i.e. ["A","B","C"...])
  def get_rom_indices
    # Arguments: None
    #
    # Return:
    # => Array<String>
    @rom_indices.keys
  end

  # Purpose: Retrieves the url for roms of a particular letter index (e.g. "A" => "http://freeroms.com/genesis_games_that_start_with_a.html")
  def get_rom_collection_url(letter_index)
    # Arguments:
    # => 1. letter_index (String): Letter used as key to retrieve url
    # Return:
    # => String
    @rom_indices[letter_index]
  end

  # Purpose: Add the game collection scraped from http://freeroms.com to the GameSystem object to the roms (Hash)
  def add_roms_to_collection_by_letter(letter_index, game_obj_array)
    # Arguments:
    # => 1. letter_index (String): Letter to be used as a key for the roms Hash
    # => 2. game_obj_array (Array<GameRom>): Contains array of GameRom objects (e.g. [Sonic the Hedgehog, Streets of Rage,...]
    #
    # Return:
    # => Array<GameRom>
    game_obj_array.each { |game| game.system = self }
    @roms[letter_index] = game_obj_array
  end

end