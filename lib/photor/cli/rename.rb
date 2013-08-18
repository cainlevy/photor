require 'thor'

class Photor::CLI < Thor
  desc "rename [FOLDER]",
    "renames all photos in FOLDER with unique names"
  long_desc <<-DESC
    Renames every JPG in FOLDER with the unique name pattern
    employed by the `copy' command. Meant to convert an existing
    gallery to the new naming convention.
  DESC
  method_option :dry_run, :type => :boolean, :desc => "report actions that would be taken without performing them"
  def rename(folder)
    renamed = 0
    skipped = 0

    puts "scanning:"
    Photor.each_jpeg(folder) do |jpg|
      print "."
      if jpg.name.match(/^\d{14}-[0-9a-f]{Photor::JPEG::FINGERPRINT_LENGTH}\.[a-z]*$/)
        skipped += 1
      else
        renamed += 1
        new_path = jpg.path.sub(jpg.name, jpg.unique_name)
        if options[:dry_run]
          puts "#{jpg.path} -> #{new_path}"
        else
          FileUtils.mv(jpg.path, new_path)
        end
      end
    end
    puts "\n"
    puts "renamed: #{renamed} skipped #{skipped}"
  end
end
