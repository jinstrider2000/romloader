
class RomLoader::ArchiveExtractor

  #Extracts zip or 7-zip rom files, manages the extracted dirs, then deletes archive files
  def self.extract(dir,game_obj)
    file_or_dir_to_open = ""
    /(?<=\().+(?=\))/.match(game_obj.system.name) ? system_dir = /(?<=\().+(?=\))/.match(game_obj.system.name)[0] : system_dir = nil
    system_dir ||= game_obj.system.name
    system_dir = system_dir.rstrip.gsub(/[[[:space:]]\/]/, "_").downcase
    Dir.mkdir(File.join(Dir.home,"videogame_roms",system_dir)) unless Dir.exist?(File.join(Dir.home,"videogame_roms",system_dir))
    
    if game_obj.system.name != "MAME"
      puts "Extracting #{game_obj.filename}"
      if game_obj.file_ext == ".zip"
        Zip::File.open(dir) do |zip_archive|
          zip_archive.glob("*htm").each { |entry| zip_archive.remove(entry) }
          Dir.mkdir(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0])) if zip_archive.size > 1 && !Dir.exist?(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
          zip_archive.each_entry do |rom|
            if Dir.exist?(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
              rom.extract(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0],rom.name)) unless File.exist?(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0],rom.name))
            else
              rom.extract(File.join(Dir.home,"videogame_roms",system_dir,rom.name)) unless File.exist?(File.join(Dir.home,"videogame_roms",system_dir,rom.name))
            end
            zip_archive.size == 1 ? file_or_dir_to_open = File.join(Dir.home,"videogame_roms",system_dir,"\"#{rom.name}\"") : file_or_dir_to_open = File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0])
          end
        end
      else
        File.open(dir, "rb") do |seven_zip_archive|
          Dir.mkdir(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0])) unless Dir.exist?(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
          SevenZipRuby::Reader.open(seven_zip_archive) do |szr|
            files_already_in_dir = Dir.entries(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
            if files_already_in_dir.size > 0
              files_to_be_extracted = szr.entries.select do |entry|
                file_match = /(file, |dir, |anti, )[.[^\.]]+\..+(?=>)/.match(entry.inspect)
                file_match ? file_name = file_match[0].split(file_match[1])[1] : file_name = nil
                !files_already_in_dir.any? { |file|  file == file_name || file_name =~ /\.htm/}
              end
              szr.extract(files_to_be_extracted, File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
            else
              szr.extract_all(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0]))
            end
          end
          Dir.chdir(File.join(Dir.home,"videogame_roms",system_dir,game_obj.filename.split(game_obj.file_ext)[0])) do
            Dir.entries(".").size == 1 ? file_or_dir_to_open = File.join(Dir.pwd,"\"#{Dir.entries(".").first}\"") : file_or_dir_to_open = Dir.pwd
          end
        end
      end
      File.delete(dir)
      file_or_dir_to_open
    else
      FileUtils.move "#{dir}", "#{File.join(Dir.home,"videogame_roms",system_dir)}"
      file_or_dir_to_open = File.join(Dir.home,"videogame_roms",system_dir)
    end
  end
  
end