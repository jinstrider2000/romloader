
class RomLoader::ArchiveExtractor

  #Extracts zip or 7-zip rom files, manages the extracted dirs, then deletes archive files
  def self.extract(archive_dir,extract_dir,game_obj)
    file_or_dir_to_open = nil
    dir_game_name = game_obj.filename.split(game_obj.file_ext)[0]
      
    if game_obj.file_ext == ".zip"
      puts "Extracting #{game_obj.filename}"
      Zip::File.open(archive_dir) do |zip_archive|
        zip_archive.glob("*htm").each { |entry| zip_archive.remove(entry) }
        Dir.mkdir(File.join(extract_dir,dir_game_name)) if zip_archive.size > 1 && !Dir.exist?(File.join(extract_dir,dir_game_name))
        zip_archive.each_entry do |rom|
          if Dir.exist?(File.join(extract_dir,dir_game_name))
            rom.extract(File.join(extract_dir,dir_game_name,rom.name)) unless File.exist?(File.join(extract_dir,dir_game_name,rom.name))
          else
            rom.extract(File.join(extract_dir,rom.name)) unless File.exist?(File.join(extract_dir,rom.name))
          end
          zip_archive.size == 1 ? file_or_dir_to_open = File.join(extract_dir,"\"#{rom.name}\"") : file_or_dir_to_open = File.join(extract_dir,dir_game_name)
        end
      end
    elsif game_obj.file_ext == ".7z"
      puts "Extracting #{game_obj.filename}"
      File.open(archive_dir, "rb") do |seven_zip_archive|
        SevenZipRuby::Reader.open(seven_zip_archive) do |szr|
          if szr.entries.size > 2
            Dir.mkdir(File.join(extract_dir,dir_game_name)) unless Dir.exist?(File.join(extract_dir,dir_game_name))
            szr.extract_if(File.join(extract_dir,dir_game_name)) { |entry| !/\.htm/.match(entry.inspect) }
            file_or_dir_to_open = File.join(extract_dir,dir_game_name)
          else
            szr.extract_if(extract_dir) do |entry|
              game_name = /(?<=file, |dir, |anti, )[.[^\.]]+\..+(?=>)/.match(entry.inspect)[0] unless /\.htm/.match(entry.inspect)
              !/\.htm/.match(entry.inspect)
            end
            file_or_dir_to_open = File.join(extract_dir,"\"#{game_name}\"")
          end
        end
      end
    else
      puts "NOTE: No archive extraction. Only Zip and 7-Zip extraction is supported."
      file_or_dir_to_open = extract_dir
    end
    file_or_dir_to_open
  end

  def self.create_extract_dir(game_obj)
    /(?<=\().+(?=\))/.match(game_obj.system.name) ? system_name = /(?<=\().+(?=\))/.match(game_obj.system.name)[0] : system_name = game_obj.system.name.rstrip.gsub(/[[[:space:]]\/]/, "_").downcase
    dir_w_system = File.join(Dir.home,"videogame_roms",system_name)
    Dir.mkdir(dir_w_system) unless Dir.exist?(dir_w_system)
    dir_w_system
  end

  def self.move_archive(src,dest)
    FileUtils.move src, dest
  end

  def self.delete_archive(dir)
    File.delete(dir)
  end
  
end