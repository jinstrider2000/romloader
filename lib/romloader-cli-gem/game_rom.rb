class GameRom

  attr_accessor :name, :download_url, :size, :system

  def initialize(name:, download_url:, size:, system: nil)
    @name = name
    @download_url = download_url
    @size = size
    @system = system
  end

  def self.create_collection(game_array)
    game_array.collect do |game_details| 
      self.new(game_details)
    end
  end
  
end