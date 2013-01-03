require 'thor'

class Photor::CLI < Thor

  desc "copy [SOURCE] [DESTINATION]",
    "copies photos from SOURCE into an import folder in DESTINATION"
  long_desc <<-DESC
    Recursively searches the SOURCE directory and all sub-directories for JPEGs.

    Copies each found JPEG to an import folder in DESTINATION, which is assumed
    to be the root of your photo collection.

    Detects and avoids importing duplicates. A duplicate is a JPEG with the same
    name and date as another that already exists in DESTINATION. No attempt is
    made to compare using md5 because the existing copy may have been altered
    by auto-orient, tagging, etc.
  DESC
  method_option :dry_run, :type => :boolean, :desc => "report actions that would be taken without performing them"
  def copy(source, destination)
    copied = 0
    skipped  = 0

    import_folder = ::File.join(destination, "import #{Time.now.strftime "%Y%m%d-%H%M%S"}")
    FileUtils.mkdir_p(import_folder) unless options[:dry_run]

    puts "scanning:"
    Photor.each_jpeg(source) do |jpg|
      print "."

      d_path = ::File.join(destination, Photor.path(jpg.taken_at, jpg.name))

      if ::File.exists? d_path
        puts "#{d_path} exists" if options[:dry_run]
        skipped += 1
        next
      end

      copied += 1

      if options[:dry_run]
        puts "cp #{jpg.path} #{d_path}"
      else
        FileUtils.cp jpg.path, ::File.join(import_folder, jpg.name)
      end
    end
    puts "\n"
    puts "copied: #{copied} skipped: #{skipped}"
  end

end
