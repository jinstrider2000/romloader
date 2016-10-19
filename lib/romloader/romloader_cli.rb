
# The CLI class
class RomLoader::RomLoaderCli

  def initialize
    RomLoader::GameSystem.create_from_collection(RomLoader::FreeromsScraper.system_scrape("http://freeroms.com"))
    raise RomLoader::ScrapingError::NoElementFound.exception("System index is currently unavailable. Exiting the program.") if RomLoader::GameSystem.all.size == 0
  end

  # Starts the CLI, called in romloader.rb
  def start
    input_stack = []
    control_flow_level = 1

    puts "Thanks for using RomLoader, powered by freeroms.com!\nNOTE: To play the games, please download an emulator for the desired system.\nConnecting to freeroms.com and retrieving the systems index...\n\n"
    sleep 3
    while control_flow_level > 0 
      case control_flow_level
      when 1
        list_systems
        input = input_prompt("Select a system (1-#{RomLoader::GameSystem.all.size}) [exit]:",1..RomLoader::GameSystem.all.size)
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
            raise RomLoader::ScrapingError::NoElementFound.exception("Requested system is currently unavailable. Try another one.")
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
            raise RomLoader::ScrapingError::NoElementFound.exception("Requested game index is currently unavailable. Try another one.")
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
            raise RomLoader::ScrapingError::NoElementFound.exception("Requested game is currently unavailable. Try another one.")
          rescue
            control_flow_level -= 1
            input_stack.shift
          end
        else
          display_rom_details(game)
          input = input_prompt("Download? (Y/n) [exit]:", /[yn]/, control_flow_level)
          if input == 'y' || input == ""
            file_or_dir_to_open = download_rom(game)
            if file_or_dir_to_open
              if /\".+\"/.match(file_or_dir_to_open)
                game_file = /\".+\"/.match(file_or_dir_to_open)[0]
                input = input_prompt("Play #{game_file}? (y/N) [exit]:", /[yn]/,control_flow_level)
              else
                input = input_prompt("Open #{file_or_dir_to_open}? (y/N) [exit]:", /[yn]/,control_flow_level)
              end
              
              if !isWindows?
                system("open #{file_or_dir_to_open}") if input == 'y'
              else
                system("powershell -command \"& { Invoke-Item '#{file_or_dir_to_open}' }\"") if input == 'y'
              end
            end 
          end
          input_stack.shift
          input == "exit" ? control_flow_level = 0 : control_flow_level -= 1
        end
      end
    end

    puts "Happy Gaming!"
  end

  # Sets control_flow_level in RomLoaderCli#start, manipulates input_stack in RomLoaderCli#start
  def flow_controller(input,control_flow_level,input_stack)
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

  # Lists the game systems scraped from http://freeroms.com and saved in Romloader::GameSystem.all
  # (e.g. 1. Amiga, 2. Atari, etc...)
  def list_systems 
    RomLoader::GameSystem.all.each_with_index { |game_system, index| puts "#{index+1}. #{game_system.name}"}
    print "\n"
  end

  # Retrieves an individual Romloader::GameSystem object from Romloader::GameSystem.all
  def select_system(index)
    RomLoader::GameSystem.all[index-1]
  end

  # List game index for the selected system by letter
  # (e.g. A B C D...)
  def list_system_index(selected_system)
    if selected_system.get_rom_indices.empty?
      selected_system.rom_indices = RomLoader::FreeromsScraper.rom_index_scrape(selected_system.rom_index_url)
    end
    
    puts "#{selected_system.name} index:"
    selected_system.get_rom_indices.each {|letter| print letter + " "}
    puts "\n\n"
  end

  # Retrieves all the games available for the selected system under the selected index
  # (e.g. NES,"G")
  def select_game_collection_by_index(system, letter)
    puts "Loading roms...\n"
    games_list = system.get_roms_by_letter(letter)
    games_list ||= system.add_roms_to_collection_by_letter(letter,RomLoader::GameRom.create_collection(RomLoader::FreeromsScraper.rom_scrape(system.get_rom_collection_url(letter))))
  end

  # List all the games available for the selected index
  # (e.g. "S": 1. Super Castlevania, 2. Super Mario World, etc...)
  def list_games(games)
    games.each_with_index {|game,index| puts "#{index+1}. #{game.name}"}
    print "\n"
  end

  # Selects an individual game from the provided collection via index
  def select_game(game_collection,index)
    game_collection[index-1].set_rom_details(RomLoader::FreeromsScraper.rom_details(game_collection[index-1].rom_detail_url))
    game_collection[index-1]
  end

  # List the details of the selected game
  # (e.g. Chrono Trigger | SNES | 5.38 MB | .zip)
  def display_rom_details(game)
    puts "Rom details:"
    puts "#{game.name} | System: #{game.system.name} | File size: #{game.size} | File type: #{game.file_ext}"
    print "\n"
  end

  # Prints a custom message, takes user input, asesses whether the input is valid, and returns the input
  def input_prompt(message,accepted_input,control_flow_level=nil)
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

  def isWindows?
    /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
  end

  # Downloads the selected game to the local directory (~/videogame_roms)
  def download_rom(game)
    file_or_dir_to_open = nil
    extract_dir = RomLoader::ArchiveExtractor.create_extract_dir(game)
    if !File.exist?(File.join(extract_dir,game.filename))
      puts "Downloading #{game.name} (#{game.size})..."
      if isWindows?
        result = Dir.chdir(extract_dir) { system("powershell -command \"& { Invoke-WebRequest '#{game.download_url}' -OutFile '#{game.filename}' }\"") }
      else
        result = Dir.chdir(extract_dir) { system("curl -Og# \"#{game.download_url}\"") }
      end

      if result && !isWindows? && game.system.name != "MAME"
        puts "Finished downloading #{game.filename} to #{extract_dir}. Extracting..."
        file_or_dir_to_open = RomLoader::ArchiveExtractor.extract(File.join(extract_dir,game.filename),extract_dir,game)
        RomLoader::ArchiveExtractor.delete_archive(File.join(extract_dir,game.filename))
      elsif result && !isWindows? && game.system.name == "MAME"
        puts "Finished downloading #{game.filename} to #{extract_dir}."
        puts "NOTE: No archive extraction. MAME roms must remain zipped to play."
        file_or_dir_to_open = extract_dir
      elsif result && isWindows?
        puts "Finished downloading #{game.filename} to #{extract_dir}."
        file_or_dir_to_open = extract_dir
      else
        puts "An error occured, the rom couldn't be downloaded.\n\n"
      end
    else
      puts "File already exists.\n\n"
    end

    sleep 2
    file_or_dir_to_open
  end
  
end


