require_relative 'freeroms_scraper.rb'
require_relative 'game_rom.rb'
require_relative 'game_system.rb'
require_relative 'scraping_error/no_element_found.rb'

# The CLI class
class RomloaderCli
  # Class Variables: none
  #
  # Instance Variables: none

  # Purpose: Instantiates a GameSystem collection from information scraped from http://freeroms.com
  def initialize
    # Arguments: None
    #
    # Return:
    # => RomloaderCli object
    GameSystem.create_from_collection(FreeromsScraper.system_scrape("http://freeroms.com"))
    raise ScrapingError::NoElementFound.exception("System index is currently unavailable. Exiting the program.") if GameSystem.all.size == 0
  end

  # Purpose: Starts the CLI, called in romloader.rb
  def start
    # Arguments: None
    #
    # Return:
    # => nil
    input_stack = []
    control_flow_level = 1

    puts "Thanks for using RomLoader, powered by freeroms.com!\nConnecting to freeroms.com and retrieving the system index...\n\n"
    sleep 1
    while control_flow_level > 0 
      case control_flow_level
      when 1
        list_systems
        input = input_prompt("Select a system (1-#{GameSystem.all.size}) [exit]:",1..GameSystem.all.size)
        if input == "exit"
          control_flow_level = 0
        else
          input_stack.unshift(input)
          control_flow_level += 1
        end
      when 2
        system = select_system(input_stack[0].to_i)
        list_system_index(system)
        if system.get_rom_indices.empty?
          begin
            raise ScrapingError::NoElementFound.exception("Requested system is currently unavailable. Try another one.")
          rescue
            control_flow_level -= 1
            input_stack.shift
          end 
        else
          input = input_prompt("Select a letter [back|exit]:", /[#{system.get_rom_indices.join.downcase}]/,control_flow_level)
          control_flow_level = flow_controller(input,control_flow_level,input_stack)
        end
      when 3
        game_collection = select_game_collection_by_index(system,input_stack[0].upcase)
        if game_collection.empty?
          begin
            raise ScrapingError::NoElementFound.exception("Requested game index is currently unavailable. Try another one.")
          rescue
            control_flow_level -= 1
            input_stack.shift
          end
        else
          list_games(game_collection)
          input = input_prompt("Select a game (1-#{game_collection.size}) [back|exit]", 1..game_collection.size,control_flow_level)
          control_flow_level = flow_controller(input,control_flow_level,input_stack)
        end
      when 4
        game = select_game(game_collection,input_stack[0].to_i)
        if game.download_url == nil
          begin
            raise ScrapingError::NoElementFound.exception("Requested game is currently unavailable. Try another one.")
          rescue
            control_flow_level -= 1
            input_stack.shift
          end
        else
          display_rom_details(game)
          input = input_prompt("Download (Y/n) [exit]:", /[yn]/, control_flow_level)
          if input == 'y' || input == ""
            download_rom(game)
          end
          input_stack.shift
          input == "exit" ? control_flow_level = 0 : control_flow_level -= 1
        end
      end
    end

    puts "Happy Gaming!"
  end

  # Purpose: Sets control_flow_level in RomloaderCli#start, manipulates input_stack in RomloaderCli#start
  def flow_controller(input,control_flow_level,input_stack)
    # Arguments:
    # => 1. input (String): Current user input from the CLI
    # => 2. control_flow_level (Fixnum): Indicator of current user progress through the CLI
    # => 3. input_stack (Array<String>): Buffer of previous user input from the CLI
    #
    # Return:
    # => Fixnum
    if input == "exit"
      0
    elsif input == "back"
      input_stack.shift
      control_flow_level - 1
    else
      input_stack.unshift(input)
      control_flow_level + 1
    end
  end

  # Purpose: Lists the game systems scraped from http://freeroms.com and saved in GameSystem.all (e.g. 1. Amiga, 2. Atari, etc...)
  def list_systems
    # Arguments: None
    #
    # Return:
    # => nil 
    GameSystem.all.each_with_index { |game_system, index| puts "#{index+1}. #{game_system.name}"}
    print "\n"
  end

  # Purpose: Retrieves an individual GameSystem object from GameSystem.all
  def select_system(index)
    # Arguments:
    # => 1. index (Fixnum): Retrieved from user input
    #
    # Return:
    # => GameSystem object
    GameSystem.all[index-1]
  end

  # Purpose: List game index for the selected system by letter (e.g. A B C D...)
  def list_system_index(selected_system)
    # Arguments:
    # => 1. selected_system (String): Retrieved from user input 
    #
    # Return:
    # => nil
    if selected_system.get_rom_indices.empty?
      selected_system.rom_indices = FreeromsScraper.rom_index_scrape(selected_system.rom_index_url)
    end
    
    puts "#{selected_system.name} index:"
    selected_system.get_rom_indices.each {|letter| print letter + " "}
    puts "\n\n"
  end

  # Purpose: Retrieves all the games available for the selected system under the selected index (e.g. NES,"G")
  def select_game_collection_by_index(system, letter)
    # Arguments:
    # => 1. system (GameSystem): Selected by user through CLI
    # => 2. letter (String): Retrieved from user input
    #
    # Return:
    # => Array<GameRom>
    puts "Loading roms...\n"
    games_list = system.get_roms_by_letter(letter)
    games_list ||= system.add_roms_to_collection_by_letter(letter,GameRom.create_collection(FreeromsScraper.rom_scrape(system.get_rom_collection_url(letter))))
  end

  # Purpose: List all the games available for the selected index (e.g. "S": 1. Super Castlevania, 2. Super Mario World, etc...)
  def list_games(games)
    # Arguments:
    # => 1. games (Array<GameRom>): Selected by user through CLI
    #
    # Return:
    # => nil
    games.each_with_index {|game,index| puts "#{index+1}. #{game.name}"}
    print "\n"
  end

  # Purpose: Selects an individual game from the provided collection via index
  def select_game(game_collection,index)
    # Arguments:
    # => 1. game_collection (GameRom): Selected by user through CLI
    # => 2. index (Fixnum): Retrieved from user input
    #
    # Return:
    # => GameRom object
    game_collection[index-1].set_rom_details(FreeromsScraper.rom_details(game_collection[index-1].rom_detail_url))
    game_collection[index-1]
  end

  # Purpose: List the details of the selected game (e.g. Chrono Trigger | 5.38 MB | .zip)
  def display_rom_details(game)
    # Arguments:
    # => 1. game (GameRom): Selected by user through CLI
    #
    # Return:
    # => nil
    puts "Rom details:"
    puts "#{game.name} | System: #{game.system.name} | File size: #{game.size} | File type: #{game.file_ext}"
    puts "NOTE: To uncompress 7-Zip (.7z) files, please download a system compatible version at http://www.7-zip.org/download.html" if game.file_ext == ".7z"
    print "\n"
  end

  # Purpose: Prints a custom message, takes user input, asesses whether the input is valid, and returns the input
  def input_prompt(message,accepted_input,control_flow_level=nil)
    # Arguments:
    # => 1. message (String): A custom message detailing the expected input
    # => 2. accepted_input (Regexp or Range): Will be checked against the input to verify validity
    # => 3. control_flow_level [optional] (Fixnum): Used to assess input in context specific situations (e.g. user providing "back" when CLI is on it's first screen)
    #
    # Return:
    # => Fixnum
    valid = false
    until valid 
      print message + " "
      input = gets.chomp.strip.downcase
      if accepted_input.class == Regexp && accepted_input.match(input)
        valid = true
      elsif accepted_input.class == Range && /\A\d+\Z/.match(input) && accepted_input.include?(input.to_i)
        valid = true
      elsif input == "exit" || (input == "back" &&  control_flow_level && control_flow_level.between?(2,3))
        valid = true
      elsif input == "" && control_flow_level == 4
        valid = true
      else
        print "Invalid input! "
      end
    end
    print "\n"
    input
  end

  # Purpose: Downloads the selected game to the local directory (~/videogame_roms)
  def download_rom(game)
    # Arguments:
    # => 1. game (GameRom): Selected by user through CLI
    #
    # Return:
    # => nil
    puts "Downloading #{game.name} (#{game.size})..."
    result = Dir.chdir(File.join(Dir.home,"videogame_roms")) do
      system("curl -Og# \"#{game.download_url}\"")
    end
    result ? puts("Finished downloading to #{File.join(Dir.home,"videogame_roms")}.\n") : puts("An error occured, the rom couldn't be downloaded.\n")
    sleep 3
    puts "\n"
  end
  
end


