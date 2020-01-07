require 'thor'

class Photor::CLI < Thor
  desc "rename [FOLDER]",
    "standardizes naming for all media in FOLDER"
  long_desc <<-DESC
    Renames every JPG, MOV, or MP4 in FOLDER with the standardized name pattern.
  DESC
  method_option :dry_run, type: :boolean, desc: "report actions that would be taken without performing them"
  def rename(folder)
    renamed = 0
    skipped = 0

    puts "scanning:"
    Photor.each_file(folder) do |f|
      print "."
      if !f.taken_at
        skipped += 1
      elsif f.name.match(/^\d{14}-[0-9a-f]{#{Photor::JPEG::FINGERPRINT_LENGTH}}\.[a-z]*$/)
        skipped += 1
      else
        renamed += 1
        new_path = f.path.sub(f.name, f.unique_name)
        if options[:dry_run]
          puts "#{f.path} -> #{new_path}"
        else
          FileUtils.mv(f.path, new_path)
        end
      end
    end
    puts "\n"
    puts "renamed: #{renamed} skipped #{skipped}"
  end
end
