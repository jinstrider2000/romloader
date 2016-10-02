require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'pry'

class FreeromsScraper

  def self.system_scrape(url)
    system_list = Nokogiri::HTML(open(url)).css("dt.leftside > a")
    [].tap do |game_system|
      system_list.each do |system_info|
        if system_info.text != "Links" && system_info.text != "Flash Games" && system_info.text != ""
          system_name = system_info.text
          begin
            system_rom_url = system_info.attribute("href").value
          rescue NoMethodError
            #Do Nothing, catch the error and move on. This is fine, because the hash will not be added to the array being compiled.
          else
            system_rom_indices = rom_index_scrape(system_rom_url)
            game_system << {:name => system_name, :rom_index_url => system_rom_indices} unless system_rom_indices.empty? 
          end
        end
      end
    end
  end
  
  def self.rom_scrape(url)
    game_list = Nokogiri::HTML(open(url)).css("tr[class^=\"game\"] > td[align=\"left\"]")
    [].tap do |rom_list|
      game_list.each do |game_info|
        begin
          download_link = game_info.css("a").attribute("href").value
        rescue NoMethodError
          #Do Nothing, catch the error and move on. This is fine, because the hash will not be added to the array being compiled. 
        else
          download_link.gsub!(/[[:space:]]/) {|white_space| CGI::escape(white_space)} unless download_link.ascii_only?
          rom_info = rom_details(download_link)
          rom_list <<  rom_info unless rom_info.empty?  
        end
      end 
    end
  end

  def self.rom_details(url)
    direct_download = Nokogiri::HTML(open(url))
    {}.tap do |game|
      unless direct_download.css("td#romss > script").empty?
        game_name = direct_download.css("tr.gametitle > td[colspan=\"2\"]").text
        game_name = "N/A" if game_name == ""
        game_name.gsub!(/[[:space:]]{2,}/) {|white_spaces| " "}
        begin
          game_url = /http:\/\/.+(\.zip|\.7z)/.match(direct_download.css("td#romss > script").first.children.first.text)
        rescue NoMethodError
          #Do Nothing, catch the error and move on. This is fine, because the hash will be empty and not added to the array being compiled in #rom_scape
        else
          if game_url
            game[:name] = game_name
            game[:download_url] = game_url[0]
            begin
              game[:size] = direct_download.css("td#rom + td[colspan=\"2\"]").first.children.first.text.strip
            rescue NoMethodError
              game[:size] = "N/A"
            end    
          end      
        end
      end
    end
  end

  def self.rom_index_scrape(url)
    rom_letter_list = Nokogiri::HTML(open(url)).css("tr.letters > td[align=\"center\"] > font > a")
    {}.tap do |letter_hash|
      rom_letter_list.each do |letter_list|
        letter = letter_list.text.strip
        begin
          letter_hash[letter] = letter_list.attribute("href").value if letter =~ /\A[A-Z#]\Z/
        rescue NoMethodError
          #Do Nothing, catch the error and move on. This is fine, because the hash pair will not added.
        end
      end
    end
  end

  private_class_method :rom_index_scrape
end

# Test Sequence: To see if freeroms.com site can be completely scraped and that all roms have complete info.
# Results: Every rom collected, even ones that you can't download normally through website! (i.e. Balloon Fight for NES, or Faselei! French for NeoGeo Pocket)
#----------------------------------------------------------------------------------------        
#full_game_list = []
#
#system_list = FreeromsScraper.system_scrape("http://freeroms.com")
#
#system_list.each do |game_system|
#  game_system[:rom_url].each_value { |url| full_game_list << FreeromsScraper.rom_scrape(url) }
#  puts "#{game_system[:name]} done!"
#end
#
#no_links = full_game_list.flatten.find_all { |game| game[:download_url] == ""  }
#
#if no_links.empty?
#  puts "Every game has a download link!"
#else
#   puts "These games don't have download links:"
#   no_links.each { |game| puts game[:name]  }
#end 
#-----------------------------------------------------------------------------------------
