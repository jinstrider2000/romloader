require_relative 'freeroms_scraper.rb'
require_relative 'game_rom.rb'
require_relative 'game_system.rb'

class RomloaderCli

  def initialize
    Dir.mkdir(File.join(Dir.home,"roms")) unless Dir.exist?(File.join(Dir.home,"roms"))
    GameSystem.create_from_collection(FreeromsScraper.system_scrape("http://freeroms.com"))
  end
  
  def run
    
  end

  def list_systems
    GameSystem.all.each_with_index { |game_system, index| puts "#{index+1}. #{game_system.name}"}
    print "\n"
  end

  def select_system(index)
    GameSystem.all[index.to_i-1]
  end

  def list_system_index(selected_system)
    selected_system.rom_index_url.keys.each {|letter| print letter + " "}
    print "\n"
  end

  def select_game_index(system, letter)
    system.get_roms_by_letter(letter)
  end

  def list_games(games,index)
    games.each_with_index {|game,index| puts "#{index}. #{game.name}"}
    print "\n"
  end

  def select_game(game_collection,index)
    game_collection[index.to_i-1]
  end

  def input_prompt(message)
    print message + " "
    gets.chomp
  end
  
end