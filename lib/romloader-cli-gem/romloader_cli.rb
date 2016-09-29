require_relative 'freeroms_scraper.rb'
require_relative 'game_rom.rb'
require_relative 'game_system.rb'

class RomloaderCli

  attr_accessor :download_queue

  def initialize
    GameSystem.create_from_collection(FreeromsScraper.system_scrape("http://freeroms.com"))
    self.download_queue = []
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

  def input_prompt(message,accepted_input_regexp)
    valid = false
    input = ""
    until valid 
      print message + " "
      input = gets.chomp =~ accepted_input_regexp ? valid = true : false
    end
    input
  end

  def download_rom(game)
    puts "Downloading #{game.name} (#{game.size})..."
    result = Dir.chdir(File.join(Dir.home,"roms")) do
      system("curl -Og# \"#{url}\"")
    end
    result ? print "Finished downloading.\n\n" : print "An error occured, the rom couldn't be downloaded.\n\n"
  end
  
end