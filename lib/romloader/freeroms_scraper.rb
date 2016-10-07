
# The class which facilitates scraping freeroms.com. Uses the nokogiri gem to scrape the site
class RomLoader::FreeromsScraper
  
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
            game_system << {name: system_name, rom_index_url: system_rom_url}
          end
        end
      end
    end
  end
  
  # To retrieve the names and main rom urls of the individual games currently begin served by freeroms.com.  Returns this information in the form of an array of hashes
  def self.rom_scrape(url)
    
    game_list = Nokogiri::HTML(open(url)).css("tr[class^=\"game\"] > td[align=\"left\"]")
    [].tap do |rom_list|
      game_list.each do |game_info|
        begin
          download_link = game_info.css("a").attribute("href").value
        rescue NoMethodError
          #Do Nothing, catch the error and move on. This is fine, because the hash will not be added to the array being compiled. 
        else
          game_name = game_info.css("span").text
          unless game_name == ""
            game_name.gsub!(/[[:space:]]{2,}/) {|white_spaces| " "} 
            download_link.gsub!(/[[:space:]]/) {|white_space| CGI::escape(white_space)} unless download_link.ascii_only?
            rom_list << {name: game_name, rom_detail_url: download_link}
          end 
        end
      end 
    end
  end

  # To retrieve the detailed information of individual games currently begin served by freeroms.com.  Returns this information in the form of a hash
  def self.rom_details(url)
    
    direct_download = Nokogiri::HTML(open(url))
    {}.tap do |game|
      unless direct_download.css("td#romss > script").empty?
        game_name = direct_download.css("tr.gametitle > td[colspan=\"2\"]").text
        begin
          game_url = /http:\/\/.+(\.zip|\.7z)/.match(direct_download.css("td#romss > script").first.children.first.text)
        rescue NoMethodError
          #Do Nothing, catch the error and move on. This is fine, because the hash will be empty, which can be handled by GameRom#set_rom_details
        else
          if game_url
            game[:download_url] = game_url[0]
            game[:file_ext] = game_url[1]
            game[:filename] = /[.[^\/]]+(\.zip|\.7z)\Z/.match(game_url[0])[0]
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

  # Purpose: To retrieve the letter indices for the roms of the game systems currently begin served by freeroms.com.  Returns this information in the form of a hash
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
end
