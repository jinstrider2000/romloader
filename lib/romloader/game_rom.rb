
# The class whose instances represent an individual game rom (e.g. Chrono Trigger object)
class RomLoader::GameRom
  
  attr_accessor :name, :system
  attr_reader :rom_detail_url ,:download_url, :size, :file_ext, :filename

  # Create individual game rom objects from information scraped from freeroms.com, and sets the required name and rom_detail_url instance variables
  def initialize(name:, rom_detail_url:)
    @name = name
    @rom_detail_url = rom_detail_url
  end

  # Creates an array of GameRom objects from an array
  def self.create_collection(game_array)
    game_array.collect {|game_details| self.new(game_details)}    
  end

  # Sets all additional, optional rom details
  def set_rom_details(download_url: nil, size: nil, file_ext: nil, filename: nil)
    @download_url = download_url
    @size = size
    @file_ext = file_ext
    @filename = filename
    nil
  end
  
end