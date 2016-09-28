require_relative 'freeroms_scraper.rb'
require_relative 'game_rom.rb'
require_relative 'game_system.rb'

class RomloaderCli

  def initialize
    GameSystem.create_from_collection(FreeromsScraper.system_scrape("http://freeroms.com"))
  end
  
  def run
    
  end

  def list_systems
    GameSystem.all.each_with_index { |game_system, index| puts "#{index+1}. #{game_system.name}"}
  end

  def select_system(index)
    GameSystem.all[index.to_i-1]
  end

  def list_system_index(selected_system)
    selected_system.rom
  end

  def select_game_index(letter)
    
  end

  def list_games(index)
    
  end

  def select_game
    
  end
  
  
end