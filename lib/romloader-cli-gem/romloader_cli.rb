require_relative 'freeroms_scraper.rb'
require_relative 'game_rom.rb'
require_relative 'game_system.rb'
require 'pry'

class RomloaderCli

  def initialize
    GameSystem.create_from_collection(FreeromsScraper.system_scrape("http://freeroms.com"))
  end

  def start
    input = ""
    input_stack = []
    selected_system = nil
    selected_game = nil
    control_flow_level = 1

    "Thanks for using RomLoader, powered by freeroms.com!\nConnecting to freeroms.com and retrieving system index...\n"
    while control_flow_level > 0
      case control_flow_level
      when 1
        list_systems
        input = input_prompt("Select a system [(1-#{GameSystem.all.size})|(exit)]:",1..GameSystem.all.size)
        input_stack.unshift(input)
        control_flow_level += 1 if input != "exit"
      when 2
        list_system_index(select_system(input))
      when 3
      else
        
      end
    end
    puts "Happy Gaming!"
  end

  def list_systems
    GameSystem.all.each_with_index { |game_system, index| puts "#{index+1}. #{game_system.name}"}
    print "\n"
  end

  def select_system(index)
    GameSystem.all[index.to_i-1]
  end

  def list_system_index(selected_system)
    puts "#{selected_system.name} index:"
    selected_system.rom_index_url.keys.each {|letter| print letter + " "}
    print "\n"
  end

  def select_game_index(system, letter)
    puts "Loading roms...\n"
    games_list = system.get_roms_by_letter(letter)
    games_list ||= system.add_roms_to_collection_by_letter(letter,GameRom.create_collection(FreeromsScraper.rom_scrape(system.get_rom_index_url(letter))))
  end

  def list_games(games)
    games.each_with_index {|game,index| puts "#{index+1}. #{game.name}"}
    print "\n"
  end

  def select_game(game_collection,index)
    game_collection[index.to_i-1]
  end

  def display_rom_details(game)
    puts "Rom details:"
    puts "#{game.name} | File size: #{game.size} | File type: #{game.file_ext}"
    puts "NOTE: To uncompress 7-Zip (.7z) files, please download a system compatible version at http://www.7-zip.org/download.html" if game.file_ext == ".7z"
  end

  def input_prompt(message,accepted_input)
    valid = false
    until valid 
      print message + " "
      input = gets.chomp.strip
      if accepted_input.class == Regexp && accepted_input.match(input)
        valid = true
      elsif accepted_input.class == Range && /\A\d+\Z/.match(input) && accepted_input.include?(input.to_i)
        valid = true
      elsif input == "exit" || (input == "b" &&  !(caller[0] =~ /list_systems/) && !(caller[0] =~ /display_rom_details/))
        valid = true
      end
    end
    input
  end

  def download_rom(game)
    puts "Downloading #{game.name} (#{game.size})..."
    result = Dir.chdir(File.join(Dir.home,"videogame_roms")) do
      system("curl -Og# \"#{game.download_url}\"")
    end
    result ? puts("Finished downloading to #{File.join(Dir.home,"videogame_roms")}.\n") : puts("An error occured, the rom couldn't be downloaded.\n")
  end
  
end


