Gem::Specification.new do |spec|
  spec.name = 'romloader'
  spec.version = '0.0.0'
  spec.date = '2016-10-01'
  spec.summary = 'A videogame rom downloader powered by freeroms.com!'
  spec.description = "This gem allows you to convieniently download videogame roms from freeroms.com to your home directory!"
  spec.authors = ["Efrain Perez Jr"]
  spec.email = "efrainperezjr@live.com"
  spec.files = Dir.glob([File.join("lib","**","*rb"),File.join("bin","*"),File.join("spec","**","*")])
  spec.require_paths = "lib"
  spec.platform = Gem::Platform::RUBY
end