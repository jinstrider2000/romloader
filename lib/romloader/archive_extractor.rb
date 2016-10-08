
class RomLoader::ArchiveExtractor

  #Extracts zip or 7-zip rom files, manages the extracted dirs, then deletes archive files
  def self.extract(dir,game_obj)
    file_or_dir_to_open = ""
    /(?<=\().+(?=\))/.match(game_obj.system.name) ? system_name = /(?<=\().+(?=\))/.match(game_obj.system.name)[0] : system_name = nil
    system_name ||= game_obj.system.name
    system_name = system_name.rstrip.gsub(/[[[:space:]]\/]/, "_").downcase
    dir_w_system = File.join(Dir.home,"videogame_roms",system_name)
    dir_game_name = game_obj.filename.split(game_obj.file_ext)[0]

    Dir.mkdir(dir_w_system) unless Dir.exist?(dir_w_system)
    
    if game_obj.system.name != "MAME"
      puts "Extracting #{game_obj.filename}"
      if game_obj.file_ext == ".zip"
        Zip::File.open(dir) do |zip_archive|
          zip_archive.glob("*htm").each { |entry| zip_archive.remove(entry) }
          Dir.mkdir(File.join(dir_w_system,dir_game_name)) if zip_archive.size > 1 && !Dir.exist?(File.join(dir_w_system,dir_game_name))
          zip_archive.each_entry do |rom|
            if Dir.exist?(File.join(dir_w_system,dir_game_name))
              rom.extract(File.join(dir_w_system,dir_game_name,rom.name)) unless File.exist?(File.join(dir_w_system,dir_game_name,rom.name))
            else
              rom.extract(File.join(dir_w_system,rom.name)) unless File.exist?(File.join(dir_w_system,rom.name))
            end
            zip_archive.size == 1 ? file_or_dir_to_open = File.join(dir_w_system,"\"#{rom.name}\"") : file_or_dir_to_open = File.join(dir_w_system,dir_game_name)
          end
        end
      else
        File.open(dir, "rb") do |seven_zip_archive|
          SevenZipRuby::Reader.open(seven_zip_archive) do |szr|
            if szr.entries.size > 2
              Dir.mkdir(File.join(dir_w_system,dir_game_name)) unless Dir.exist?(File.join(dir_w_system,dir_game_name))
              szr.extract_if(File.join(dir_w_system,dir_game_name)) { |entry| !/\.htm/.match(entry.inspect) }
              file_or_dir_to_open = File.join(dir_w_system,dir_game_name)
            else
              szr.extract_if(dir_w_system) do |entry|
                game_name = /(?<=file, |dir, |anti, )[.[^\.]]+\..+(?=>)/.match(entry.inspect)[0] unless /\.htm/.match(entry.inspect)
                !/\.htm/.match(entry.inspect)
              end
              file_or_dir_to_open = File.join(dir_w_system,"\"#{game_name}\"")
            end
          end
        end
      end
      File.delete(dir)
      file_or_dir_to_open
    else
      puts "NOTE: No archive extraction. MAME roms must remain zipped to play."
      FileUtils.move dir, dir_w_system
      file_or_dir_to_open = dir_w_system
    end
  end
  
end