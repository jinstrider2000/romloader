require "open-uri"
require "nokogiri"
require "cgi"
require "pry"

class FreeromsScraper

  def self.system_scrape(url)
    system_list = Nokogiri::HTML(open(url)).css("dt.leftside > a")
    [].tap do |game_system|
      system_list.each do |system_info|
        if system_info.text != "Links" && system_info.text != "Flash Games"
          system_name = system_info.text
          system_rom_url = system_info.attribute("href").value
          game_system << {:name => system_name, :rom_index_url => rom_index_scrape(system_rom_url)}
        end
      end
    end
  end
  
  def self.rom_scrape(url)
    game_list = Nokogiri::HTML(open(url)).css("tr[class^=\"game\"] > td[align=\"left\"]")
    [].tap do |rom_list|
      game_list.each do |game_info|
        download_link = game_info.css("a").attribute("href").value
        download_link.gsub!(/[[:space:]]/) {|white_space| CGI::escape(white_space)} unless download_link.ascii_only?
        rom_list << rom_details(download_link)
      end 
    end
  end

  def self.rom_details(url)
    direct_download = Nokogiri::HTML(open(url))
    {}.tap do |game|
      unless direct_download.css("td#rom > script").empty?
        game_name = direct_download.css("tr.gametitle > td[colspan=\"2\"]").text
        game_name.gsub!(/[[:space:]]{2,}/) {|white_spaces| " "}
        game_url = /http:\/\/.+(\.zip|\.7z)/.match(direct_download.css("td#rom > script").first.children.first.text)
        game[:name] = game_name
        game_url ? game[:download_url] = game_url[0] : game[:download_url] = ""
        game[:size] = direct_download.css("td#rom + td[colspan=\"2\"]").first.children.first.text.strip
      end
    end
  end

  def self.rom_index_scrape(url)
    rom_letter_list = Nokogiri::HTML(open(url)).css("tr.letters > td[align=\"center\"] > font > a")
    {}.tap do |letter_hash|
      rom_letter_list.each do |letter_list|
        letter = letter_list.text.strip
        letter_hash[letter] = letter_list.attribute("href").value if letter =~ /\A[A-Z#]\Z/
      end
    end
  end

  private_class_method :rom_index_scrape
end

# Test: To see if freeroms.com site can be completely scraped and all roms have complete info.
# Results: Every rom collected, except Neo Geo Pocket game "Faselei! French"
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
