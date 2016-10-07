module RomLoader

end

require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'zip'
require 'seven_zip_ruby'
require 'fileutils'
require_relative 'romloader/game_rom.rb'
require_relative 'romloader/game_system.rb'
require_relative 'romloader/archive_extractor.rb'
require_relative 'romloader/freeroms_scraper.rb'
require_relative 'romloader/scraping_error/errors.rb'
require_relative 'romloader/romloader_cli.rb'

def run
  Dir.mkdir(File.join(Dir.home,"videogame_roms")) unless Dir.exist?(File.join(Dir.home,"videogame_roms"))
  RomLoader::RomLoaderCli.new.start
end