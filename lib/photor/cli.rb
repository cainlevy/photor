require 'thor'

module Photor
  class CLI < Thor

    desc "import [SOURCE] [DESTINATION]",
      "copies photos from SOURCE and organizes them by date in DESTINATION"
    long_desc <<-DESC
      Recursively searches the SOURCE directory and all sub-directories for JPEGs.
      Copies each found JPEG to the DESTINATION directory, organized by YYYY/MM/DD/FILENAME.
      Will not copy duplicates.
    DESC
    method_option :dry_run, :type => :boolean, :desc => "report actions that would be taken without performing them"
    def import(source, destination)
      imported = 0
      skipped  = 0

      puts "scanning:"
      Photor.each_jpeg(source) do |jpg|
        print "."

        d_path = File.join(destination, jpg.to_path)

        if File.exists? d_path
          existing = Photor::JPEG.new(d_path)
          if jpg == existing
            puts "#{d_path} exists" if options[:dry_run]
            skipped += 1
            next
          else
            i = 0
            while File.exists? d_path
              i += 1
              d_path = d_path.sub(/\.([a-z]*$)/, ".#{i}.\\1")
            end
          end
        end

        imported += 1
        if options[:dry_run]
          puts "mkdir -p #{File.dirname(d_path)}"
          puts "cp #{jpg.path} #{d_path}"
        else
          FileUtils.mkdir_p(File.dirname(d_path))
          FileUtils.cp jpg.path, d_path
        end
      end
      puts "\n"
      puts "imported: #{imported} skipped: #{skipped}"
    end

    desc "search [SOURCE]",
      "finds photos in SOURCE that match specified criteria"
    long_desc <<-DESC
      Recursively searches the SOURCE directory for all JPEGs that match specified
      criteria, such as EXIF tags (aka keywords). Reports each found file, one
      per line.
    DESC
    method_option :tags, :type => :array, :desc => "only show files with matching EXIF keywords"
    def search(source)
      tags = (options[:tags] || []).map(&:downcase)

      Photor.each_jpeg(source) do |jpg|
        exif_tags = Array(jpg.exif['Keywords'] || jpg.exif['Subject']).map(&:downcase)
        next if (options[:tags] & exif_tags).empty?

        puts jpg.path
      end
    end

  end
end