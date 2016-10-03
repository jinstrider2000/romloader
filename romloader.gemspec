Gem::Specification.new do |spec|
  spec.name = 'romloader'
  spec.version = '0.0.0'
  spec.date = '2016-10-01'
  spec.summary = 'A videogame rom downloader powered by freeroms.com!'
  spec.description = "This gem allows you to convieniently download videogame roms from freeroms.com to your home directory."
  spec.author = ["Efrain Perez Jr"]
  spec.email = "efrainperezjr@live.com"
  spec.homepage = "https://github.com/jinstrider2000/romloader-cli-gem"
  spec.files = Dir.glob([File.join("lib","**","*.rb"),File.join("bin","romloader"),File.join("spec","**","*"),"LICENSE","README.md","Gemfile"])
  spec.require_paths = "lib"
  spec.platform = Gem::Platform::RUBY
  spec.executables << 'romloader'
  spec.license = 'MIT'
  spec.add_runtime_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'nokogiri', '~> 1.6'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rspec', '~> 3.1'
end