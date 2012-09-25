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
      Photor::Organizer.new(source, destination).run(:dry_run => options[:dry_run])
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
      Photor::Searcher.new(source).run(:tags => options[:tags])
    end

  end
end