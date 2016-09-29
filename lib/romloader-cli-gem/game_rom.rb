class GameRom

  attr_accessor :name, :download_url, :size, :file_name, :system

  def initialize(name:, download_url:, size:, system: nil)
    self.name = name
    self.download_url = download_url
    self.size = size
    self.system = system
    self.file_name = /(?=\/).+(\.zip|\.7z)/.match(download_url)[0]
  end

  def self.create_collection(game_array)
    game_array.collect do |game_details| 
      self.new(game_details)
    end
  end
  
end