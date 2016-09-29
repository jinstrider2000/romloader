require_relative 'romloader-cli-gem/romloader-cli.rb'

def run
  Dir.mkdir(File.join(Dir.home,"roms")) unless Dir.exist?(File.join(Dir.home,"roms"))
  RomloaderCli.new.run
end