
# The class whose instances represent an individual game rom (e.g. Chrono Trigger object)
class GameRom
  # Class Variables: none
  #
  # Instance Variables:
  # => 1. name (String): Contains the system's name (e.g. "Sega Genesis")
  # => 2. download_url (String): Contains a string with the url to download the game (e.g. "http://download.freeroms.com/genesis/a_roms/altered_beast.zip") 
  # => 3. rom_detail_url (String): Contains a string with the url to details of the game
  # => 4. size (String): Contains a string with the size of download, as published on freeroms.com
  # => 5. file_ext (String): Contains a string with the download file index (e.g. ".zip")
  # => 6. system (GameSystem): Points to the GameSystem object that contains this GameRom instance 
  attr_accessor :name, :system
  attr_reader :rom_detail_url ,:download_url, :size, :file_ext

  # Purpose: Create individual game rom objects from information scraped from freeroms.com, and sets the required name and rom_detail_url instance variables
  def initialize(name:, rom_detail_url:)
    # Arguments:
    # => 1. name (String): Contains the game's name (e.g. "Super Mario Bros 3")
    # => 2. rom_detail_url (String): Contains a string with the url to details of the game
    #
    # Return:
    # => GameRom object
    @name = name
    @rom_detail_url = rom_detail_url
  end

  # Purpose: Creates an array of GameRom objects from an array
  def self.create_collection(game_array)
    # Arguments:
    # => 1. game_array (Array<Hash>): Contains the game's information
    #
    # Return:
    # => Array<GameRom>
    game_array.collect {|game_details| self.new(game_details)}    
  end

  # Purpose: Sets all additional, optional rom details
  def set_rom_details(download_url: nil, size: nil, file_ext: nil)
    # Arguments:
    # => 1. download_url [optional] (String): Contains a string with the url to download the game
    # => 2. size [optional] (String): Contains a string with the size of download, as published on freeroms.com
    # => 3. file_ext (String): Contains a string with the download file index (e.g. ".zip")
    #
    # Return:
    # => nil
    @download_url = download_url
    @size = size
    @file_ext = file_ext
    nil
  end
  
end