require_relative 'romloader-cli-gem/romloader_cli.rb'
require 'pry'

def run
  Dir.mkdir(File.join(Dir.home,"videogame_roms")) unless Dir.exist?(File.join(Dir.home,"videogame_roms"))
  RomloaderCli.new.start
end

