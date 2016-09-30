require_relative 'romloader-cli-gem/romloader_cli.rb'
require 'pry'

def run
  Dir.mkdir(File.join(Dir.home,"videogame_roms")) unless Dir.exist?(File.join(Dir.home,"videogame_roms"))
  cli = RomloaderCli.new
  cli.list_systems
  system = cli.select_system("28")
  cli.list_system_index(system)
  games_list = cli.select_game_index(system,"O")
  cli.list_games(games_list)
  game = cli.select_game(games_list,"1")
  cli.display_rom_details(game)
  if cli.input_prompt("Download (y/n)", /[yn]/) == 'y'
    cli.download_rom(game)
  end
end

list_systems

