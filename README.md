# RomLoader

A Ruby Gem for downloading videogame roms, powered by freeroms.com.

## Installation

    $ gem install romloader

## Usage

Type the command below into your shell and follow the on screen prompts.

    $ romloader

## Development

To develop further upon this gem, fork and clone the repository located at https://github.com/jinstrider2000/romloader.
Be sure to have the Bundler gem installed, and run:

    $ bundle install

This will download any dependencies for development. Rspec is among the dependencies, however, there are no tests included in the repo. I intend to add some eventually.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jinstrider2000/romloader.

## Version Changes

v. 1.2.6: Fixed system scraping functions to comply with updates to freeroms.com

v. 1.2.5: Fixed system scraping functions to comply with updates to freeroms.com

v. 1.2.4: Fixed bug in regexp checking when entering single characters 

v. 1.2.3: Updated error handling and scraping of file sizes from Freeroms.com

v. 1.2.2: Updated web scraping function

v. 1.2: Added basic file managment capability for Windows (requires Powershell v 3.0 or higher). Also updated UI slightly

v. 1.1: Added basic rom download capability for Windows (requires Powershell v 3.0 or higher)

v. 1.0: Changed the namespacing of classes, added zip/7-zip extraction and rom download directory management. Also, added the ability to open the newly downloaded game from the command line (requires a emulator)

v. 0.0: Basic rom listing from Freeroms.com, and rom download feature

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).