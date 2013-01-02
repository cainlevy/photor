require 'thor'

module Photor
  class CLI < Thor

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

      import_folder = File.join(destination, "import #{Time.now.strftime "%Y%m%d-%H%M%S"}")
      FileUtils.mkdir_p(import_folder) unless options[:dry_run]

      puts "scanning:"
      Photor.each_jpeg(source) do |jpg|
        print "."

        d_path = File.join(destination, jpg.to_path)

        if File.exists? d_path
          puts "#{d_path} exists" if options[:dry_run]
          skipped += 1
          next
        end

        copied += 1

        if options[:dry_run]
          puts "cp #{jpg.path} #{d_path}"
        else
          FileUtils.cp jpg.path, File.join(import_folder, jpg.name)
        end
      end
      puts "\n"
      puts "copied: #{copied} skipped: #{skipped}"
    end

    desc "organize [SOURCE] [DESTINATION]",
      "moves photos from SOURCE to DESTINATION by date"
    long_desc <<-DESC
      Recursively searches the SOURCE directory and all sub-directories for JPEGs.
      Moves each found JPEG into a date hierarchy in DESTINATION.
    DESC
    method_option :dry_run, :type => :boolean, :desc => "report actions that would be taken without performing them"
    def organize(source, destination)
      Photor.each_jpeg(source) do |jpg|
        print "."

        d_path = File.join(destination, jpg.to_path)
        if options[:dry_run]
          puts "moving #{jpg.path} to #{d_path}"
        else
          FileUtils.mkdir_p File.dirname(d_path)
          FileUtils.mv jpg.path, d_path
        end
      end
      puts "\n"
    end

    desc "orient [FOLDER]",
      "auto-orients photos in FOLDER"
    long_desc <<-DESC
      Finds JPEGs in FOLDER where the Orientation is not 1, and rotates them. Sets
      Orientation=1 when it is finished.
    DESC
    def orient(folder)
      orientations = {
        2 => '-flip horizontal',
        3 => '-rotate 180',
        4 => '-flip vertical',
        5 => '-transpose',
        6 => '-rotate 90',
        7 => '-transverse',
        8 => '-rotate 270'
      }

      ct = 0
      puts "scanning:"
      Photor.each_jpeg(folder) do |jpg|
        print "."
        next unless transform = orientations[jpg.orientation]

        # losslessly transform
        `jpegtran -copy all -perfect #{transform} #{Photor.shellarg jpg.path} > #{$$}.tmp`

        if $?.exitstatus == 0
          puts 'oriented'
          `mv #{$$}.tmp #{Photor.shellarg jpg.path}`
          jpg.exif['Orientation'] = 1
          ct += 1
        else
          puts 'failed'
          `rm #{$$}.tmp`
          puts "could not orient #{jpg.path}"
        end
      end
      puts "\n"
      puts "oriented: #{ct}"
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
        exif_tags = jpg.tags.map(&:downcase)
        next if (options[:tags] & exif_tags).empty?

        puts jpg.path
      end
    end

  end
end
